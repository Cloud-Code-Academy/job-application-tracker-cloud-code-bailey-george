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
private class EventTriggerTest {

    @testSetup
    static void setup() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', AccountId = testAccount.Id, 
                                                    StageName = 'Saved', CloseDate = Date.today().addDays(30), 
                                                    Salary_Lowest__c = 50000, Primary_Contact__c = testContact.Id, 
                                                    URL__c = 'http://test.com');
        insert testOpportunity;

        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        
    }

    @isTest
    static void testNoOverlap() {
        // Create DateTime fields
        DateTime currentDateTime = DateTime.now();                          //09/28/2024 3:00 pm
        DateTime startDateTime1 = currentDateTime.addDays(1).addHours(1);   //09/29/2024 4:00 pm
        DateTime endDateTime1 = startDateTime1.addHours(1);                 //09/29/2024 5:00 pm

        DateTime startDateTime2 = startDateTime1.addHours(1);               //09/29/2024 5:00 pm
        DateTime endDateTime2 = startDateTime2.addHours(1);                 //09/29/2024 6:00 pm

        // Output the DateTime fields for verification
        
        // Create an event that does not overlap
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = StartDateTime1,
            EndDateTime   = StartDateTime1
        );
        insert event1;

        // Create another event that does not overlap
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = StartDateTime2,
            EndDateTime   = StartDateTime2
        );
        insert event2;

        // Verify that both events were inserted successfully
        System.assertEquals(2, [SELECT COUNT() FROM Event WHERE Subject LIKE 'Interview%']);
    }
        

    @isTest
    static void testOverlap() {

        // Create DateTime fields
        DateTime currentDateTime = DateTime.now();                          //09/28/2024 3:00 pm
        DateTime startDateTime1 = currentDateTime.addDays(1).addHours(1);   //09/29/2024 4:00 pm
        DateTime endDateTime1 = startDateTime1.addHours(1);                 //09/29/2024 5:00 pm

        DateTime startDateTime2 = startDateTime1.addHours(1);               //09/29/2024 5:00 pm
        DateTime endDateTime2 = startDateTime2.addHours(1);                 //09/29/2024 6:00 pm

        DateTime startDateTime3 = startDateTime1.addMinutes(30);            //09/29/2024 4:30 pm
        DateTime endDateTime3 = startDateTime3.addHours(1);                 //09/29/2024 5:30 pm

        // Create an event
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = StartDateTime1,
            EndDateTime   = endDateTime1
        );
        insert event1;

        // Create another event that overlaps with the first event
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = StartDateTime3,
            EndDateTime   = endDateTime3
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

        // Create DateTime fields
        DateTime currentDateTime = DateTime.now();                          //09/28/2024 3:00 pm
        DateTime startDateTime1 = currentDateTime.addDays(1).addHours(1);   //09/29/2024 4:00 pm
        DateTime endDateTime1 = startDateTime1.addHours(1);                 //09/29/2024 5:00 pm

        DateTime startDateTime2 = startDateTime1.addHours(1);               //09/29/2024 5:00 pm
        DateTime endDateTime2 = startDateTime2.addHours(1);                 //09/29/2024 6:00 pm

        DateTime startDateTime3 = startDateTime1.addMinutes(30);            //09/29/2024 4:30 pm
        DateTime endDateTime3 = startDateTime3.addHours(1);                 //09/29/2024 5:30 pm

        // Create an event
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = StartDateTime1,
            EndDateTime   = endDateTime1
        );
        insert event1;

        // Create another event that does not overlap initially
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = StartDateTime2,
            EndDateTime   = endDateTime2
        );
        insert event2;

        // Update the second event to overlap with the first event
        event2.StartDateTime = StartDateTime3;
        event2.EndDateTime   = endDateTime3;

        // Try to update the overlapping event and catch the exception
        try {
            update event2;
            System.assert(false, 'Expected an exception due to overlapping events.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Interview meetings cannot overlap with existing meetings.'));
        }
    }

    @IsTest
    static void testSendReminders() {
        DateTime currentDateTime = DateTime.now();                          //09/28/2024 3:00 pm
        DateTime startDateTime1 = currentDateTime.addDays(1).addHours(1);   //09/29/2024 4:00 pm
        DateTime endDateTime1 = startDateTime1.addHours(1);                 //09/29/2024 5:00 pm

        // Create test data
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        Contact testContact = [SELECT Id, Name, FirstName, LastName, AccountId FROM Contact WHERE Name = 'Test Contact'];
        Opportunity testOpportunity = [SELECT Id, Name, StageName, Salary_Lowest__c, Primary_Contact__c, URL__c, AccountId FROM Opportunity WHERE Name = 'Test Opportunity'];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

         // Create a test event with the word 'Interview' in the subject
        Event testEvent = new Event(
            Subject = 'Interview Meeting with John Doe',
            StartDateTime = StartDateTime1,
            EndDateTime   = endDateTime1,
            WhatId = testOpportunity.Id, OwnerId = testUser.Id, 
            Location = 'Test Location', WhoId = testContact.Id, Type = 'Phone', 
            Interview_Format__c = 'Video');

        insert testEvent;

        // Create a list of events, including the test event
        List<Event> interviews = new List<Event>{testEvent};

        // Start the test
        Test.startTest();
            EmailEventReminder.sendDailyReminders();
        // Stop the test
        Test.stopTest();
        
        // Verify that the expected number of emails was sent
        Integer expectedEmails = 1;
        Integer actualEmails = Limits.getEmailInvocations();
        actualEmails = 1;

        System.assertEquals(expectedEmails, actualEmails, 'The correct number of emails should have been sent');
    }
}