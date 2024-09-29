public with sharing class EventTriggerHandler extends TriggerHandler{
    private List<Event> neweventList;
    private List<Event> oldeventList;
    private Map<Id, Event> neweventMap;
    private Map<Id, Event> oldeventMap; 

    public EventTriggerHandler() {
        this.neweventList = (List<Event>)Trigger.new;
        this.oldeventList = (List<Event>)Trigger.old;
        this.neweventMap = (Map<Id, Event>)Trigger.newMap;
        this.oldeventMap = (Map<Id, Event>)Trigger.oldMap;
    }

    public override void beforeInsert(){
        EventTriggerHelper.PreventOverlappingEvents(neweventList);        
        //EventTriggerHelper.setReminderForInterviews(neweventList);
    }

    public override void beforeUpdate(){
        EventTriggerHelper.PreventOverlappingEvents(neweventList);
        //EventTriggerHelper.setReminderForInterviews(neweventList);
    }
    /*
    public override void afterInsert(){
    }
    
    public override void afterUpdate(){
    }
    
    public override void beforeDelete(){
    }

    public override void afterDelete(){
    }

    public override void afterUndelete(){
    }
    */
}