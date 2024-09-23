/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class EventTriggerTest {
    @isTest
    static void testNoOverlap() {

        Date tomorrow = Date.today().addDays(1);

        // Create an event that does not overlap
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 10, 0, 0),
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 11, 0, 0)
        );
        insert event1;

        // Create another event that does not overlap
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 12, 0, 0),
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 13, 0, 0)
        );
        insert event2;

        // Verify that both events were inserted successfully
        System.assertEquals(2, [SELECT COUNT() FROM Event WHERE Subject LIKE 'Interview%']);
    }

    @isTest
    static void testOverlap() {
        Date tomorrow = Date.today().addDays(1);

        // Create an event
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 10, 0, 0),
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 11, 0, 0)
        );
        insert event1;

        // Create another event that overlaps with the first event
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 10, 30, 0),
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 11, 30, 0)
        );

        // Try to insert the overlapping event and catch the exception
        try {
            insert event2;
            System.assert(false, 'Expected an exception due to overlapping events.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Interview meetings cannot overlap with existing meetings.'));
        }
    } 
    
    @isTest
    static void testUpdateOverlap() {
        Date tomorrow = Date.today().addDays(1);

        // Create an event
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 10, 0, 0),
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 11, 0, 0)
        );
        insert event1;

        // Create another event that does not overlap initially
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 12, 0, 0),
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 13, 0, 0)
        );
        insert event2;

        // Update the second event to overlap with the first event
        event2.StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 10, 30, 0);
        event2.EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 11, 30, 0);

        // Try to update the overlapping event and catch the exception
        try {
            update event2;
            System.assert(false, 'Expected an exception due to overlapping events.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Interview meetings cannot overlap with existing meetings.'));
        }
    }
}