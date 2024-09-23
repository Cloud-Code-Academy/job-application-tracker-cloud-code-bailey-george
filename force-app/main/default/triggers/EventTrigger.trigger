trigger EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if (Org_Specific_Setting__mdt.getInstance('Run_All_Triggers')?.Value__c==true){
        EventTriggerHandler handler = new EventTriggerHandler();
        handler.run();
    }
}