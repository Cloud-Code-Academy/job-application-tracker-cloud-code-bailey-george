public with sharing class DailyEventReminderScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        EmailEventReminder.sendDailyReminders(); 
    }
}