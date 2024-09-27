public with sharing class ContactRoleTriggerHandler extends TriggerHandler{
    private List<OpportunityContactRole> newContactRoleList;
    private List<OpportunityContactRole> oldContactRoleList;
    private Map<Id, OpportunityContactRole> newContactRoleMap;
    private Map<Id, OpportunityContactRole> oldContactRoleMap;

    public ContactRoleTriggerHandler() {
            this.newContactRoleList = (List<OpportunityContactRole>)Trigger.new;
            this.oldContactRoleList = (List<OpportunityContactRole>)Trigger.old;
            this.newContactRoleMap = (Map<Id, OpportunityContactRole>)Trigger.newMap;
            this.oldContactRoleMap = (Map<Id, OpportunityContactRole>)Trigger.oldMap;
    }

    public override void beforeInsert(){

    }

    public override void afterInsert(){
        ContactRoleTriggerHelper.updateJobApplicationWhenOCRCreated(newContactRoleList);
    }

    public override void beforeUpdate(){

    }

    public override void afterUpdate(){

    }

    public override void beforeDelete(){

    }

    public override void afterDelete(){

    }

    public override void afterUndelete(){
        
    }

}
