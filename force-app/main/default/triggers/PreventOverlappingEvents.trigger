trigger PreventOverlappingEvents on Event (before insert, before update) {

    for (Event newEvent : Trigger.new) {
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