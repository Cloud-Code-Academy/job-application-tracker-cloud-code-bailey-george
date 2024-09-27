trigger ContactRoleTrigger on OpportunityContactRole (before Insert, after Insert, before Update, after Update, before Delete, after Delete, after Undelete) {
    if (Org_Specific_Setting__mdt.getInstance('Run_All_Triggers')?.Value__c==true){
        ContactRoleTriggerHandler handler = new ContactRoleTriggerHandler();
        handler.run(); 
    }
}