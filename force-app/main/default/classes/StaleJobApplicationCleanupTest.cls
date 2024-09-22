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
public class StaleJobApplicationCleanupTest {
    @testSetup
    static void setup() {
        // Create test data for Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        
        // Opportunity that is not stale
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Open',
            CloseDate = Date.today().addMonths(1),
            Follow_Up_Date__c = Date.today().addDays(-10),            
            Notes__c = '',
            Description = 'Test description 1'
        ));
        
        // Stale Opportunity
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Open',
            CloseDate = Date.today().addMonths(1),
            Follow_Up_Date__c = Date.today().addDays(-40),            
            Notes__c = '',
            Description = 'Test description 2'
        ));
        
        // Another stale Opportunity
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 3',
            StageName = 'In Progress',
            CloseDate = Date.today().addMonths(1),
            Follow_Up_Date__c = Date.today().addDays(-50),
            Notes__c = '',
            Description = 'Test description 3'
        ));
        
        insert opportunities;
    }
    
    @isTest
    static void testBatchable() {
        // Execute the batch job
        Test.startTest();
        Database.executeBatch(new StaleJobApplicationCleanup());
        Test.stopTest();
        
        // Verify the results
        Opportunity[] updatedOpportunities = [SELECT Id, StageName, Description, Notes__c FROM Opportunity WHERE StageName = 'Closed'];
        System.assertEquals(2, updatedOpportunities.size(), 'Two opportunities should be closed');
        
        for (Opportunity opp : updatedOpportunities) {
            System.assert(opp.Notes__c.contains('Job application was closed by an automated process.'), 'Description should be updated');
        }
    }
    
    @isTest
    static void testSchedulable() {
        // Execute the schedulable job
        Test.startTest();
        String jobId = System.schedule('Test Job', '0 0 0 1 1 ? 2025', new StaleJobApplicationCleanup());
        Test.stopTest();
        
        // Verify the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 1 1 ? 2025', ct.CronExpression, 'Cron expression should match');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have triggered yet');
    }
}