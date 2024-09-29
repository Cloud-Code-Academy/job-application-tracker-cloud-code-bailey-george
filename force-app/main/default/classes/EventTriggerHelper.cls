public with sharing class EventTriggerHelper extends TriggerHandler{

    public static Decimal tax = 0;
    public static Decimal previousLimit = 0;
    public static String filingStatus;

    public static void PreventOverlappingEvents(List<Event> eventsTriggered){

        for (Event newEvent : eventsTriggered) { 
            List<Event> overlappingEvents = [
                SELECT Id 
                FROM Event
                WHERE (
                    (StartDateTime < :newEvent.EndDateTime AND EndDateTime > :newEvent.StartDateTime)
                    AND Id != :newEvent.Id
                )
            ];
            
            if (!overlappingEvents.isEmpty()) {
                newEvent.addError('Interview meetings cannot overlap with existing meetings.');
            }
        }
    }  

    /**
     * Sets IsReminderSet to True if the Subject contains 'Interview'.
     *
     * @param events List of Event records to process
     */
    /*
     public static void setReminderForInterviews(List<Event> eventsreminderSet) {
        for (Event evt : eventsreminderSet) {
            if (evt.Subject != null && evt.Subject.containsIgnoreCase('Interview')) {
                evt.IsReminderSet = true;
            }
            System.debug('Current Event Records: ' + evt.Subject + ' IsReminderSet: ' + evt.IsReminderSet);
        }
    }
        */
}