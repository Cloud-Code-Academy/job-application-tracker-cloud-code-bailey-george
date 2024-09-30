/**
 * The EmailEventReminder class is responsible for sending daily interview event reminders.
 * It retrieves events scheduled for the next day and sends reminder emails to the event owners.
 */
//public with sharing class EmailEventReminder implements Schedulable {
public with sharing class EmailEventReminder {

    /**
     * Sends daily reminders for interview events scheduled for the next day.
     */
    public static void sendDailyReminders() {
        // Query to retrieve events scheduled for tomorrow with 'Interview' in the subject
        List<Event> events = [SELECT Id, StartDateTime, Subject, WhatId, OwnerId, AccountId, Location, WhoId, Who.Name,
                                        Type, Interview_Format__c 
                                FROM Event 
                                WHERE StartDateTime = TOMORROW 
                                AND Subject LIKE '%Interview%'];
        
        // Debug the total number of events returned

        // If there are events, send reminders
        if (!events.isEmpty()) {
            sendReminders(events);
        }
    }

    /**
     * Sends reminder emails for the given list of events.
     *
     * @param events List of events to send reminders for
     */
    public static void sendReminders(List<Event> events) {
        // Retrieve related records
        List<Opportunity> opportunities = getOpportunities(events);
        List<User> users = getUsers(events);
        List<Contact> contacts = getContacts(opportunities);
        List<Account> accounts = getAccounts(events);

        // Create maps for easy access to related records
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(opportunities);
        Map<Id, User> usersMap = new Map<Id, User>(users);
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(contacts);
        Map<Id, Account> accountsMap = new Map<Id, Account>(accounts);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Iterate through events and send reminder emails
        for (Event evt : events) {
            Opportunity opp = opportunitiesMap.get(evt.WhatId);
            // Create and send email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(UserInfo.getUserId());
            email.setSaveAsActivity(false);
            email.setSubject('Interview Reminder: ' + opp.Name);
            email.setHtmlBody(createEmailBody(evt, opportunitiesMap, usersMap, contactsMap, accountsMap));

            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);  // Send all emails at once to avoid loop issues
        }
    }

    /**
     * Retrieves opportunities related to the given list of events.
     *
     * @param events List of events
     * @return List of related opportunities
     */
    private static List<Opportunity> getOpportunities(List<Event> events) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Event evt : events) {
            opportunityIds.add(evt.WhatId);
        }
        return [SELECT Id, Name, Salary_Lowest__c, Primary_Contact__c, URL__c FROM Opportunity WHERE Id IN :opportunityIds];
    }

    /**
     * Retrieves users related to the given list of events.
     *
     * @param events List of events
     * @return List of related users
     */
    private static List<User> getUsers(List<Event> events) {
        Set<Id> userIds = new Set<Id>();
        for (Event evt : events) {
            userIds.add(evt.OwnerId);
        }
        return [SELECT Id, Email FROM User WHERE Id IN :userIds];
    }

    /**
     * Retrieves contacts related to the given list of opportunities.
     *
     * @param opportunities List of opportunities
     * @return List of related contacts
     */
    private static List<Contact> getContacts(List<Opportunity> opportunities) {
        Set<Id> contactIds = new Set<Id>();
        for (Opportunity opp : opportunities) {
            contactIds.add(opp.Primary_Contact__c);
        }
        return [SELECT Id, Name FROM Contact WHERE Id IN :contactIds];
    }

    /**
     * Retrieves accounts related to the given list of events.
     *
     * @param events List of events
     * @return List of related accounts
     */
    private static List<Account> getAccounts(List<Event> events) {
        Set<Id> accountIds = new Set<Id>();
        for (Event evt : events) {
            accountIds.add(evt.AccountId);
        }
        return [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
    }

    /**
     * Creates the HTML body for the reminder email.
     *
     * @param evt The event record
     * @param opportunitiesMap Map of opportunities
     * @param usersMap Map of users
     * @param contactsMap Map of contacts
     * @param accountsMap Map of accounts
     * @return The HTML body for the email
     */
    private static String createEmailBody(Event evt, Map<Id, Opportunity> opportunitiesMap, Map<Id, User> usersMap, Map<Id, Contact> contactsMap, Map<Id, Account> accountsMap) {
        Opportunity opp = opportunitiesMap.get(evt.WhatId);
        Contact contact = contactsMap.get(opp.Primary_Contact__c);
        Account account = accountsMap.get(evt.AccountId);

        String emailBody = '<html><body>';
        emailBody += 'You have an interview at ' + '<strong>' + evt.StartDateTime.format() + ' at ' + evt.Location + ' with ' + evt.Who.Name + '</strong> <br /><br />';
        emailBody += '<strong><u>Job Information</u></strong><br /><br />';        
        emailBody += '    <strong>Subject: </strong>     ' + evt.Subject + '<br /><br />';
        emailBody += '    <strong>Job Application Name:</strong>     ' + opp.Name + '<br /><br />';
        emailBody += '    <strong>Interview Type:</strong>     ' + evt.Type + '<br /><br />';
        emailBody += '    <strong>Interview Format:</strong>     ' + evt.Interview_Format__c + '<br /><br />';
        emailBody += '    <strong>Company Name:</strong>     ' + account.Name + '<br /><br />';
        emailBody += '    <strong>Primary Contact:</strong>     ' + contact.Name + '<br /><br />';
        if (opp.Salary_Lowest__c != null) {
            emailBody += '    <strong>Salary:</strong>     $' + opp.Salary_Lowest__c + '<br /><br />';
        }
        emailBody += '    <strong>Job Posting URL:</strong>     ' + opp.URL__c  + '<br /><br />';
        emailBody += 'Remember, prepare for your interview, have a set of questions, arrive early and remember you are also interviewing them.<br /><br />';

        return emailBody;
    }
}