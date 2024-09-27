public with sharing class ContactRoleTriggerHelper extends TriggerHandler{

    public static void updateJobApplicationWhenOCRCreated(List<OpportunityContactRole> newOCRsCreated){
        Set<Id> appId = new Set<Id>();
        for (OpportunityContactRole contactRole : newOCRsCreated){
            appId.add(contactRole.OpportunityId);
        }
        List<Opportunity> appsToUpdate = [SELECT Id, Name FROM Opportunity WHERE Id IN :appId];
        
        update appsToUpdate;
    }
}