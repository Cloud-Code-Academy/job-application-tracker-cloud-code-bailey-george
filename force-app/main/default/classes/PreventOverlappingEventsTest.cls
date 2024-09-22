@isTest
public class PreventOverlappingEventsTest {
    @isTest
    static void testNoOverlap() {
        // Create an event that does not overlap
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = DateTime.newInstance(2024, 9, 22, 10, 0, 0),
            EndDateTime = DateTime.newInstance(2024, 9, 22, 11, 0, 0)
        );
        insert event1;

        // Create another event that does not overlap
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = DateTime.newInstance(2024, 9, 22, 12, 0, 0),
            EndDateTime = DateTime.newInstance(2024, 9, 22, 13, 0, 0)
        );
        insert event2;

        // Verify that both events were inserted successfully
        System.assertEquals(2, [SELECT COUNT() FROM Event WHERE Subject LIKE 'Interview%']);
    }

    @isTest
    static void testOverlap() {
        // Create an event
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = DateTime.newInstance(2024, 9, 22, 10, 0, 0),
            EndDateTime = DateTime.newInstance(2024, 9, 22, 11, 0, 0)
        );
        insert event1;

        // Create another event that overlaps with the first event
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = DateTime.newInstance(2024, 9, 22, 10, 30, 0),
            EndDateTime = DateTime.newInstance(2024, 9, 22, 11, 30, 0)
        );

        // Try to insert the overlapping event and catch the exception
        try {
            insert event2;
            System.assert(false, 'Expected an exception due to overlapping events.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Interview meetings cannot overlap with existing meetings.'));
        }
    }
}