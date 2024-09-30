public with sharing class JobApplicationTriggerHandler extends TriggerHandler{
    private List<Opportunity> newJobAppList;
    private List<Opportunity> oldJobAppList;
    private Map<Id, Opportunity> newJobAppMap;
    private Map<Id, Opportunity> oldJobAppMap;

    public JobApplicationTriggerHandler() {
        this.newJobAppList = (List<Opportunity>)Trigger.new;
        this.oldJobAppList = (List<Opportunity>)Trigger.old;
        this.newJobAppMap = (Map<Id, Opportunity>)Trigger.newMap;
        this.oldJobAppMap = (Map<Id, Opportunity>)Trigger.oldMap;
    }

    public override void beforeInsert(){
        JobApplicationTriggerHelper.setStatusToSaved(newJobAppList);  
        JobApplicationTriggerHelper.requirePositiveSalaries(newJobAppList);
        JobApplicationTriggerHelper.pullSalaryFromJoobleSalary(newJobAppList);
    }

    public override void beforeUpdate(){
        JobApplicationTriggerHelper.calculateTakeHomePay(newJobAppList);
        JobApplicationTriggerHelper.populatePrimaryContact(newJobAppList, newJobAppMap);
        JobApplicationTriggerHelper.requirePositiveSalaries(newJobAppList);
        JobApplicationTriggerHelper.updateFieldWhenStageChanges(newJobAppList, oldJobAppList, newJobAppMap, oldJobAppMap);
    }

    public override void afterInsert(){
        JobApplicationTriggerHelper.generateTaskNewJobApp(newJobAppList);
    }
    
    public override void afterUpdate(){
        JobApplicationTriggerHelper.generateTaskAfterUpdate(newJobAppList, oldJobAppList, newJobAppMap, oldJobAppMap);
    }

    /*public override void beforeDelete(){

    }

    public override void afterDelete(){

    }

    public override void afterUndelete(){

    }*/
}