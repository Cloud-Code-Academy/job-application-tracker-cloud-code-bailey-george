@isTest
public with sharing class JobApplicationTriggerTest {
   @TestSetup
   static void setUp(){
    List<Account> accountsToInsert = new List<Account>();
    Account testAcct1 = new Account(Name = 'First Test Account');
    Account testAcct2 = new Account(Name = 'Second Test Account');
    Account testAcct3 = new Account(Name = 'Third Test Account');
    accountsToInsert.add(testAcct1);
    accountsToInsert.add(testAcct2);
    accountsToInsert.add(testAcct3);

    List<Opportunity> jobAppsToInsert = new List<Opportunity>();
    for(Integer i = 0; i < 200; i++){
        Opportunity jobApp = new Opportunity(Name = 'Test Job App ' + i, Salary_Lowest__c = (60000 + (i*10)), Salary_Highest__c = (80000 + (i*10)), Spouse_s_Salary__c = (60000 + (i*10)), CloseDate = Date.today().addDays(30));
        if(i < 50){
            jobApp.filing_status__c = 'Single';
        } else if (i >=50 && i < 100){
            jobApp.filing_status__c = 'Married filing jointly';
        } else if (i>=100 && i<150){
            jobApp.filing_status__c = 'Married filing separately';
        } else {
            jobApp.filing_status__c = 'Head of household';
        }
        jobAppsToInsert.add(jobApp);
    }

    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.allowSave = true;
    dml.DuplicateRuleHeader.runAsCurrentUser = true;
    Database.insert(accountsToInsert, dml);
    Database.insert(jobAppsToInsert, dml);
    }

    @isTest
    public static void testSetStatusToSaved(){
        List<Opportunity> appsJustInserted = [SELECT Id, Name, StageName FROM Opportunity];
        for(Opportunity app : appsJustInserted){
            System.assertEquals(app.StageName, 'Saved', 'Initial stage set to Saved as expected');
        }
    }

    @isTest
    public static void testGenerateTaskNewJobApp() { 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name FROM Opportunity];
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps]);
        for(Id task : tasksById.keySet()){
            Task taskToEval = tasksById.get(task);
            System.assertEquals(taskToEval.description, 'Check if the job description aligns with your interests and values \nReview the highlighted skills to see if the role is a good fit \nResearch the company or role and mark your excitement level', 'Task for inserted job application was created as expected');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGenerateTaskAfterUpdate_applying(){ 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName FROM Opportunity];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity jobApp : insertedApps){
            jobApp.StageName = 'Applying';
            oppsToUpdate.add(jobApp);
        }
        Update oppsToUpdate;
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT Id, WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps AND Subject = 'Job Application Tasks when Applying']); 
        Map<Id, Task> tasksByJobAppId = new Map<Id, Task>();
        for(Id task : tasksById.keySet()){
            Id jobApp = tasksById.get(task).WhatId;
            tasksByJobAppId.put(jobApp,tasksById.get(task));
        }
        for(Opportunity apps : insertedApps){
            Task taskForApp = tasksByJobAppId.get(apps.Id);
            System.assertNotEquals(taskForApp, null, 'No appropriate task exists for this opportunity');
            System.assertEquals(taskForApp.subject, 'Job Application Tasks when Applying', 'Task does not have the right details');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGenerateTaskAfterUpdate_applied(){ 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName FROM Opportunity];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity jobApp : insertedApps){
            jobApp.StageName = 'Applied';
            oppsToUpdate.add(jobApp);
        }
        Update oppsToUpdate;
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT Id, WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps AND Subject = 'Job Application Tasks after Applied']); 
        Map<Id, Task> tasksByJobAppId = new Map<Id, Task>();
        for(Id task : tasksById.keySet()){
            Id jobApp = tasksById.get(task).WhatId;
            tasksByJobAppId.put(jobApp,tasksById.get(task));
        }
        for(Opportunity apps : insertedApps){
            Task taskForApp = tasksByJobAppId.get(apps.Id);
            System.assertNotEquals(taskForApp, null, 'No appropriate task exists for this opportunity');
            System.assertEquals(taskForApp.subject, 'Job Application Tasks after Applied', 'Task does not have the right details');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGenerateTaskAfterUpdate_interviewing(){ 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName FROM Opportunity];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity jobApp : insertedApps){
            jobApp.StageName = 'Interviewing';
            oppsToUpdate.add(jobApp);
        }
        Update oppsToUpdate;
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT Id, WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps AND Subject = 'Job Application Tasks when Interviewing']); 
        Map<Id, Task> tasksByJobAppId = new Map<Id, Task>();
        for(Id task : tasksById.keySet()){
            Id jobApp = tasksById.get(task).WhatId;
            tasksByJobAppId.put(jobApp,tasksById.get(task));
        }
        for(Opportunity apps : insertedApps){
            Task taskForApp = tasksByJobAppId.get(apps.Id);
            System.assertNotEquals(taskForApp, null, 'No appropriate task exists for this opportunity');
            System.assertEquals(taskForApp.subject, 'Job Application Tasks when Interviewing', 'Task does not have the right details');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGenerateTaskAfterUpdate_negotiating(){ 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName FROM Opportunity];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity jobApp : insertedApps){
            jobApp.StageName = 'Negotiating';
            oppsToUpdate.add(jobApp);
        }
        Update oppsToUpdate;
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT Id, WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps AND Subject = 'Job Application Tasks when Negotiating']); 
        Map<Id, Task> tasksByJobAppId = new Map<Id, Task>();
        for(Id task : tasksById.keySet()){
            Id jobApp = tasksById.get(task).WhatId;
            tasksByJobAppId.put(jobApp,tasksById.get(task));
        }
        for(Opportunity apps : insertedApps){
            Task taskForApp = tasksByJobAppId.get(apps.Id);
            System.assertNotEquals(taskForApp, null, 'No appropriate task exists for this opportunity');
            System.assertEquals(taskForApp.subject, 'Job Application Tasks when Negotiating', 'Task does not have the right details');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGenerateTaskAfterUpdate_accepted(){ 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName FROM Opportunity];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity jobApp : insertedApps){
            jobApp.StageName = 'Accepted';
            oppsToUpdate.add(jobApp);
        }
        Update oppsToUpdate;
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT Id, WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps AND Subject = 'Job Application Tasks once Accepted']); 
        Map<Id, Task> tasksByJobAppId = new Map<Id, Task>();
        for(Id task : tasksById.keySet()){
            Id jobApp = tasksById.get(task).WhatId;
            tasksByJobAppId.put(jobApp,tasksById.get(task));
        }
        for(Opportunity apps : insertedApps){
            Task taskForApp = tasksByJobAppId.get(apps.Id);
            System.assertNotEquals(taskForApp, null, 'No appropriate task exists for this opportunity');
            System.assertEquals(taskForApp.subject, 'Job Application Tasks once Accepted', 'Task does not have the right details');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGenerateTaskAfterUpdate_closed(){ 
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName FROM Opportunity];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity jobApp : insertedApps){
            jobApp.StageName = 'Closed';
            oppsToUpdate.add(jobApp);
        }
        Update oppsToUpdate;
        Map<Id, Task> tasksById = new Map<Id, Task>([SELECT Id, WhatId, Subject, Description FROM TASK WHERE WhatId IN :insertedApps AND Subject = 'Job Application Tasks when Closed']); 
        Map<Id, Task> tasksByJobAppId = new Map<Id, Task>();
        for(Id task : tasksById.keySet()){
            Id jobApp = tasksById.get(task).WhatId;
            tasksByJobAppId.put(jobApp,tasksById.get(task));
        }
        for(Opportunity apps : insertedApps){
            Task taskForApp = tasksByJobAppId.get(apps.Id);
            System.assertNotEquals(taskForApp, null, 'No appropriate task exists for this opportunity');
            System.assertEquals(taskForApp.subject, 'Job Application Tasks when Closed', 'Task does not have the right details');
        }
        Test.stopTest();
    }

    @isTest
    public static void testCalculateTakeHomePay(){
        Test.startTest();
        List<Opportunity> insertedApps = [SELECT Id, Name, StageName, Salary_Lowest__c, Salary_Highest__c, Annual_Gross_Salary__c, Filing_Status__c, Spouse_s_Salary__c, Federal_Income_Tax__c, Social_Security__c, Medicare__c, Take_Home_Pay__c
                                          FROM Opportunity];
        List<Opportunity> appsToUpdate = new List<Opportunity>();
        Opportunity appHighSalary = insertedApps[0];
        appHighSalary.Annual_Gross_Salary__c = 'Salary - Lowest';
        appHighSalary.Name = 'A Job App';
        appsToUpdate.add(appHighSalary);

        Opportunity appLowSalary = insertedApps[1];
        appLowSalary.Annual_Gross_Salary__c = 'Salary - Highest';
        appLowSalary.Name = 'B Job App';
        appsToUpdate.add(appLowSalary);

        Opportunity appNoGrossSalary = insertedApps[2];
        appNoGrossSalary.Annual_Gross_Salary__c = null;
        appNoGrossSalary.Name = 'C Job App';
        appsToUpdate.add(appNoGrossSalary);

        Opportunity appNoFilingStatus = insertedApps[3];
        appNoFilingStatus.Filing_Status__c = null;
        appNoFilingStatus.Name = 'D Job App';
        appsToUpdate.add(appNoFilingStatus);

        Update appsToUpdate;

        List<Opportunity> updatedApps = [SELECT Id, Name, StageName, Salary_Lowest__c, Salary_Highest__c, Annual_Gross_Salary__c, Filing_Status__c, Spouse_s_Salary__c, Federal_Income_Tax__c, Social_Security__c, Medicare__c, Take_Home_Pay__c 
                                         FROM Opportunity
                                         WHERE Id IN :appsToUpdate ORDER BY Name ASC];
        Opportunity appToCheck1 = updatedApps[0];
        Opportunity appToCheck2 = updatedApps[1];
        Opportunity appToCheck3 = updatedApps[2];
        Opportunity appToCheck4 = updatedApps[3];
        Test.stopTest();

        System.assert(appToCheck1.Federal_Income_Tax__c != null, 'Federal Income Tax was not calculated');
        System.assert(appToCheck2.Social_Security__c != null, 'Social Security was not calculated');
        System.assert(appToCheck3.Medicare__c == null, 'Medicare should have been null since Annual Gross Salary was null');
        System.assert(appToCheck4.Federal_Income_Tax__c == null, 'Federal Income Tax should have been null since Filing Status was null');
        
        }                           
    

    @isTest
    public static void testCalculateFedIncomeTaxMethod(){
        Test.startTest();
        Decimal calcFedIncomeTaxSingle = JobApplicationTriggerHelper.calculateFedIncomeTax(60000, 'Single', 0);
        Decimal calcFedIncomeTaxMarriedJoint = JobApplicationTriggerHelper.calculateFedIncomeTax(150000, 'Married filing jointly', 75000);
        Decimal calcFedIncomeTaxMarriedSeparate = JobApplicationTriggerHelper.calculateFedIncomeTax(300000, 'Married filing separately', 0);
        Decimal calcFedIncomeTaxHeadHousehold = JobApplicationTriggerHelper.calculateFedIncomeTax(45000, 'Head of household', 0);
        Test.stopTest();

        System.assertEquals(8253, calcFedIncomeTaxSingle, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(26723.33, calcFedIncomeTaxMarriedJoint, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(75374.75, calcFedIncomeTaxMarriedSeparate, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(5069, calcFedIncomeTaxHeadHousehold, 'Federal Income Tax was not calculated correctly');
    }

    @isTest
    public static void testFilingSingleMethod(){
        Test.startTest();
        Decimal fedIncomeTaxSingle1 = JobApplicationTriggerHelper.filingSingle(60000); 
        Decimal fedIncomeTaxSingle2 = JobApplicationTriggerHelper.filingSingle(95000); 
        Decimal fedIncomeTaxSingle3 = JobApplicationTriggerHelper.filingSingle(80000); 
        Decimal fedIncomeTaxSingle4 = JobApplicationTriggerHelper.filingSingle(200000); 
        Test.stopTest();

        System.assertEquals(8253, fedIncomeTaxSingle1,'Federal Income Tax was not calculated correctly');
        System.assertEquals(15953, fedIncomeTaxSingle2,'Federal Income Tax was not calculated correctly');
        System.assertEquals(12653, fedIncomeTaxSingle3, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(41686.5, fedIncomeTaxSingle4, 'Federal Income Tax was not calculated correctly'); 
    }

    @isTest
    public static void testMarriedFilingJointlyMethod(){
        Test.startTest();
        Decimal fedIncomeTaxMarriedJoint1 = JobApplicationTriggerHelper.marriedFilingJointly(60000, 100000); 
        Decimal fedIncomeTaxMarriedJoint2 = JobApplicationTriggerHelper.marriedFilingJointly(95000, 40000); 
        Decimal fedIncomeTaxMarriedJoint3 = JobApplicationTriggerHelper.marriedFilingJointly(80000, 255000); 
        Decimal fedIncomeTaxMarriedJoint4 = JobApplicationTriggerHelper.marriedFilingJointly(200000, 200000); 
        Test.stopTest();

        System.assertEquals(9489.75, fedIncomeTaxMarriedJoint1,'Federal Income Tax was not calculated correctly');
        System.assertEquals(13937.56, fedIncomeTaxMarriedJoint2,'Federal Income Tax was not calculated correctly');
        System.assertEquals(15877.01, fedIncomeTaxMarriedJoint3, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(41686.50, fedIncomeTaxMarriedJoint4, 'Federal Income Tax was not calculated correctly');
    }

    @isTest
    public static void testMarriedFilingSeparatelyMethod(){
        Test.startTest();
        Decimal fedIncomeTaxFilingSingle1 = JobApplicationTriggerHelper.marriedFilingSeparately(40000); 
        Decimal fedIncomeTaxFilingSingle2 = JobApplicationTriggerHelper.marriedFilingSeparately(72000); 
        Decimal fedIncomeTaxFilingSingle3 = JobApplicationTriggerHelper.marriedFilingSeparately(99000); 
        Decimal fedIncomeTaxFilingSingle4 = JobApplicationTriggerHelper.marriedFilingSeparately(350000); 
        Test.stopTest();

        System.assertEquals(4568, fedIncomeTaxFilingSingle1,'Federal Income Tax was not calculated correctly');
        System.assertEquals(10893, fedIncomeTaxFilingSingle2,'Federal Income Tax was not calculated correctly');
        System.assertEquals(16833, fedIncomeTaxFilingSingle3, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(92874.75, fedIncomeTaxFilingSingle4, 'Federal Income Tax was not calculated correctly'); 
    }

    @isTest
    public static void testHeadOfHouseholdMethod(){
        Test.startTest();
        Decimal fedIncomeTaxHeadOfHouse1 = JobApplicationTriggerHelper.headOfHousehold(30000); 
        Decimal fedIncomeTaxHeadOfHouse2 = JobApplicationTriggerHelper.headOfHousehold(72000); 
        Decimal fedIncomeTaxHeadOfHouse3 = JobApplicationTriggerHelper.headOfHousehold(155000); 
        Decimal fedIncomeTaxHeadOfHouse4 = JobApplicationTriggerHelper.headOfHousehold(650000); 
        Test.stopTest();

        System.assertEquals(3269, fedIncomeTaxHeadOfHouse1,'Federal Income Tax was not calculated correctly');
        System.assertEquals(9199, fedIncomeTaxHeadOfHouse2,'Federal Income Tax was not calculated correctly');
        System.assertEquals(28549, fedIncomeTaxHeadOfHouse3, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(196995, fedIncomeTaxHeadOfHouse4, 'Federal Income Tax was not calculated correctly'); 
    }

    @isTest
    public static void testPopulatePrimaryContactFromAccount(){
        //When a Job Application is edited, if there are no contact roles on the application, the first created contact on the account should be populated
        List<Opportunity> insertedApps = [SELECT Id, Name, Primary_Contact__c, AccountId, Filing_Status__c FROM Opportunity Limit 200];
        List<Account> insertedAccts = [SELECT Id, Name FROM Account ORDER BY Name ASC];

        Account testAccount1 = insertedAccts [0];
        Account testAccount2 = insertedAccts [1];
        Account testAccount3 = insertedAccts [2];

        List<Contact> contactsToInsert = new List<Contact>();
        //Contacts to put on testAccount1
        Contact testFirstContact1 = new Contact(FirstName = 'FirstContact1', LastName = 'Contact1Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testFirstContact1);
        Contact testSecondContact2 = new Contact(FirstName = 'SecondContact2', LastName = 'Contact2Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testSecondContact2);
        //Contacts to put on testAccount2
        Contact testFirstContact3 = new Contact(FirstName = 'FirstContact3', LastName = 'Contact3Last', AccountId = testAccount2.Id);
        contactsToInsert.add(testFirstContact3);
        Contact testSecondContact4 = new Contact(FirstName = 'SecondContact4', LastName = 'Contact4Last', AccountId = testAccount2.Id);
        contactsToInsert.add(testSecondContact4);
        //Contacts to put on testAccount3
        Contact testFirstContact5 = new Contact(FirstName = 'FirstContact5', LastName = 'Contact5Last', AccountId = testAccount3.Id);
        contactsToInsert.add(testFirstContact5);
        Contact testSecondContact6 = new Contact(FirstName = 'SecondContact6', LastName = 'Contact6Last', AccountId = testAccount3.Id);
        contactsToInsert.add(testSecondContact6);
        Contact testThirdContact7 = new Contact(FirstName = 'ThirdContact7', LastName = 'Contact7Last', AccountId = testAccount3.Id);
        contactsToInsert.add(testThirdContact7);
        insert contactsToInsert;

        //In order to confirm that the first created contact is what will get populated as the primary contact, we need to adjust the created dates for some
        Test.setCreatedDate(testFirstContact1.Id, dateTime.newInstance(2022,12,12)); 
        Test.setCreatedDate(testFirstContact3.Id, dateTime.newInstance(2023,12,12)); 
        Test.setCreatedDate(testFirstContact5.Id, dateTime.newInstance(2024,02,12)); 
        Test.setCreatedDate(testSecondContact6.Id, dateTime.Now()-1); 
        System.debug('created date for first contact is ' + testFirstContact1.CreatedDate);

        List<Opportunity> appsToUpdate = new List<Opportunity>();
        //Break out our 200 test opportunities into 3 groups based on Filing Status to be added to the 3 different accounts
        for(Opportunity app : insertedApps){
            if(app.Filing_Status__c == 'Single'){
                app.AccountId = testAccount1.Id;
                appsToUpdate.add(app);
            } else if (app.Filing_Status__c == 'Married Filing Jointly'){
                app.AccountId = testAccount2.Id;
                appsToUpdate.add(app);
            } else {
                app.AccountId = testAccount3.Id;
                appsToUpdate.add(app);
            }
        }
        Update appsToUpdate;

        //Query the contact with the earliest created date for each account
        List<Opportunity> updatedJobApps =[SELECT Id, Name, Primary_Contact__c, AccountId FROM Opportunity WHERE Id IN :appsToUpdate];
        Contact firstContactOnAcct1 = [SELECT Id, Name, CreatedDate, AccountId FROM Contact WHERE AccountId = :testAccount1.Id ORDER BY CreatedDate ASC LIMIT 1];
        Contact firstContactOnAcct2 = [SELECT Id, Name, CreatedDate, AccountId FROM Contact WHERE AccountId = :testAccount2.Id ORDER BY CreatedDate ASC LIMIT 1];
        Contact firstContactOnAcct3 = [SELECT Id, Name, CreatedDate, AccountId FROM Contact WHERE AccountId = :testAccount3.Id ORDER BY CreatedDate ASC LIMIT 1];

        //Confirm that the primary contact on the Job Application actually is the first created contact on the account
        for(Opportunity app : updatedJobApps){
            if(app.AccountId == testAccount1.Id){
                System.debug('first created date is ' + firstContactOnAcct1.createdDate);
                System.assertEquals(firstContactOnAcct1.Id, app.Primary_Contact__c, 'Primary Contact was not set properly');
            } else if (app.AccountId == testAccount2.Id){
                System.assertEquals(firstContactOnAcct2.Id, app.Primary_Contact__c, 'Primary Contact was not set properly');
            } else if (app.AccountId == testAccount3.Id){
                System.assertEquals(firstContactOnAcct3.Id, app.Primary_Contact__c,'Primary Contact was not set properly');
            }
        }
    }

    @isTest
    public static void testPopulatePrimaryContactFromContactRole(){
        //On a Job Application, if contact roles exist, use the "Primary" contact role for the "Primary Contact". If no contact role is "Primary", find the contact with the earliest created date
        List<Opportunity> insertedApps = [SELECT Id, Name, Primary_Contact__c, AccountId, Filing_Status__c FROM Opportunity Limit 200];
        List<Account> insertedAccts = [SELECT Id, Name FROM Account ORDER BY Name ASC];

        Account testAccount1 = insertedAccts [0];
        Account testAccount2 = insertedAccts [1];
        Account testAccount3 = insertedAccts [2];

        //All contacts will be associated with an account that is different than the Job Application accounts to ensure the account isn't what is populating the "Primary Contact"
        List<Contact> contactsToInsert = new List<Contact>();
        //Contacts to put on first grouping of Job Applications
        Contact testFirstContact1 = new Contact(FirstName = 'AFirstContact1', LastName = 'Contact1Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testFirstContact1);
        Contact testSecondContact2 = new Contact(FirstName = 'BSecondContact2', LastName = 'Contact2Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testSecondContact2);
        //Contacts to put on second grouping of Job Applications
        Contact testFirstContact3 = new Contact(FirstName = 'CFirstContact3', LastName = 'Contact3Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testFirstContact3);
        Contact testSecondContact4 = new Contact(FirstName = 'DSecondContact4', LastName = 'Contact4Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testSecondContact4);
        //Contacts to put on third grouping of Job Applications
        Contact testFirstContact5 = new Contact(FirstName = 'EFirstContact5', LastName = 'Contact5Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testFirstContact5);
        Contact testSecondContact6 = new Contact(FirstName = 'FSecondContact6', LastName = 'Contact6Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testSecondContact6);
        Contact testThirdContact7 = new Contact(FirstName = 'GThirdContact7', LastName = 'Contact7Last', AccountId = testAccount1.Id);
        contactsToInsert.add(testThirdContact7);
        
        insert contactsToInsert;

        //Update created date of some of the contacts to ensure that, if no contact role is designated as "Primary", the first created contact on that Job Application is found
        Test.setCreatedDate(testFirstContact1.Id, dateTime.newInstance(2022,12,12)); 
        Test.setCreatedDate(testFirstContact3.Id, dateTime.newInstance(2023,12,12)); 
        Test.setCreatedDate(testFirstContact5.Id, dateTime.newInstance(2024,02,12)); 
        Test.setCreatedDate(testSecondContact6.Id, dateTime.Now()-1); 

        //Break out our 200 test opportunities into 3 groups based on Filing Status to have 3 different contact role scenarios tested
        List<Opportunity> appsToUpdate = new List<Opportunity>();
        List<OpportunityContactRole> contactRolesToInsert = new List<OpportunityContactRole>();
        for(Opportunity app : insertedApps){
            if(app.Filing_Status__c == 'Single'){
                //In Scenario 1, there are 2 contact roles on the application and the later created contact is the "Primary". testSecondContact2 should be set as the "Primary Contact"
                app.AccountId = testAccount2.Id;
                appsToUpdate.add(app);
                OpportunityContactRole contactRoleToCreate = new OpportunityContactRole(ContactId = testFirstContact1.Id, isPrimary = false, OpportunityId = app.Id);
                OpportunityContactRole contactRoleToCreate2 = new OpportunityContactRole(ContactId = testSecondContact2.Id, isPrimary = true, OpportunityId = app.Id);
                contactRolesToInsert.add(contactRoleToCreate);
                contactRolesToInsert.add(contactRoleToCreate2);
            } else if (app.Filing_Status__c == 'Married Filing Jointly'){
                //In Scenario 2, there are 2 contact roles on the application and the earlier created contact is the "Primary". testFirstContact3 should be set as the "Primary Contact"
                OpportunityContactRole contactRoleToCreate3 = new OpportunityContactRole(ContactId = testFirstContact3.Id, isPrimary = true, OpportunityId = app.Id);
                OpportunityContactRole contactRoleToCreate4 = new OpportunityContactRole(ContactId = testSecondContact4.Id, isPrimary = false, OpportunityId = app.Id);
                contactRolesToInsert.add(contactRoleToCreate3);
                contactRolesToInsert.add(contactRoleToCreate4);
                app.AccountId = testAccount3.Id;
                appsToUpdate.add(app);
            } else {
                //In Scenario 3, there are 3 contact roles on the application with varying created dates. No contact is designated as the "Primary" so the first created contact (testFirstContact5) should be set as the "Primary Contact"
                OpportunityContactRole contactRoleToCreate5 = new OpportunityContactRole(ContactId = testFirstContact5.Id, isPrimary = false, OpportunityId = app.Id);
                OpportunityContactRole contactRoleToCreate6 = new OpportunityContactRole(ContactId = testSecondContact6.Id, isPrimary = false, OpportunityId = app.Id);
                OpportunityContactRole contactRoleToCreate7 = new OpportunityContactRole(ContactId = testThirdContact7.Id, isPrimary = false, OpportunityId = app.Id);
                contactRolesToInsert.add(contactRoleToCreate5);
                contactRolesToInsert.add(contactRoleToCreate6);
                contactRolesToInsert.add(contactRoleToCreate7);
                app.AccountId = testAccount2.Id;
                appsToUpdate.add(app);
            }
        }
        Insert contactRolesToInsert;
        Update appsToUpdate;

        //Query for the inserted contacts to make sure we have the most up to date CreatedDate
        List<Contact> insertedContacts = [SELECT Id, FirstName, LastName, AccountId, CreatedDate 
                                          FROM Contact 
                                          WHERE Id IN :contactsToInsert ORDER BY FirstName ASC];
        testFirstContact1 = insertedContacts[0];
        testSecondContact2 = insertedContacts[1];
        testFirstContact3 = insertedContacts[2];
        testSecondContact4 = insertedContacts[3];
        testFirstContact5 = insertedContacts[4];
        testSecondContact6 = insertedContacts[5];
        testThirdContact7 = insertedContacts[6];
    
        List<Opportunity> updatedJobApps =[SELECT Id, Name, Primary_Contact__c, Filing_Status__c FROM Opportunity WHERE Id IN :appsToUpdate];
        for(Opportunity app : updatedJobApps){
            if(app.Filing_Status__c == 'Single'){
                System.assertEquals(testSecondContact2.Id, app.Primary_Contact__c, 'Primary Contact for first scenario was not set properly');                
            } else if (app.Filing_Status__c == 'Married Filing Jointly'){
                System.assertEquals(testFirstContact3.Id, app.Primary_Contact__c, 'Primary Contact for second scenario was not set properly');
            } else {
                System.assertEquals(testFirstContact5.Id, app.Primary_Contact__c,'Primary Contact for third scenario was not set properly');
            }
        }
    }
}




