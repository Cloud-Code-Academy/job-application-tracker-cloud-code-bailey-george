public class StaleJobApplicationCleanup implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query for stale job applications
        String query = 'SELECT Id, StageName, Follow_Up_Date__c, Description FROM Opportunity ' +
                        'WHERE StageName NOT IN (\'Closed\', \'Accepted\') ' +
                        'AND Follow_Up_Date__c <= N_DAYS_AGO:30';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            opp.StageName = 'Closed';
            opp.Notes__c = (opp.Description == null ? '' : opp.Description + '\n') + 
                                'Job application was closed by an automated process.';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: Add any post-processing logic here
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new StaleJobApplicationCleanup());
    }
}
