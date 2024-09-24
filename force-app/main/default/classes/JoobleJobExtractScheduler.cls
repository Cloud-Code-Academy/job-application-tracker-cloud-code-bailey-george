// This Schedulable Class can be scheduled to run weekly and 
// will call the JoobleJobExtract.fetchAndSaveJobs method to 
// to retrieve the Jooble jobs and save them as Opportunities
//
// To schedule the class, you can use the following Anonymous Apex code:
//   String cronExpression = '0 0 8 ? * MON *'; // This cron expression schedules the job to run weekly at 8 AM
//   System.schedule('Weekly Jooble Job Fetch', cronExpression, new JoobleJobScheduler());

global class JoobleJobExtractScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {

        // Calculate the date 2 weeks ago from today
        String startDate = Date.today().addDays(-14).format();

        // Call the fetchAndSaveJobs method with the specified parameters
        joobleJobExtract.fetchAndSaveJobs('Salesforce Developer', 'Dallas, Texas', startDate);

    }

}