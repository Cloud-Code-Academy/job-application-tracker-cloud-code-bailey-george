public with sharing class JobApplicationTriggerHelper extends TriggerHandler{

    public static void generateTaskNewJobApp(List<Opportunity> jobAppsTriggered){
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity jobApp : jobAppsTriggered){
            Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
            newTask.Description = 'Check if the job description aligns with your interests and values \nReview the highlighted skills to see if the role is a good fit \nResearch the company or role and mark your excitement level';
            tasksToInsert.add(newTask);
            }
            Insert tasksToInsert;
        } 

    public static void generateTaskAfterUpdate(List<Opportunity> jobAppsTriggered, List<Opportunity> oldJobAppsTriggered, Map<Id, Opportunity> newJobAppMapTrigg, Map<Id, Opportunity> oldJobAppMapTrigg){
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity jobApp : jobAppsTriggered){
            Opportunity oldJobApp = oldJobAppMapTrigg.get(jobApp.Id);
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Applying'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
                newTask.Description = 'Find and research someone who works at the company and add them as a contact \nSet up an informational interview to learn more about the role/company\nIdentify potential referrals to help get your application on the top of the pile\nCustomize your work achievements using the job description keywords\nSubmit your application on the company website if possible';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Applied'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
                newTask.Description = 'Reach out to the hiring manager or recruiter\nFollow up on your application via email weekly\nContinue identifying and saving similar job opportunities\nSet up weekly networking calls to explore similar companies/roles';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Interviewing'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
                newTask.Description = 'Prepare your blurb or “tell me about yourself” response\nPractice answering behavioral interview questions\nResearch the company and your interviewers\nSet up your virtual interview space and test your tech\nSend thank you emails within 24 hours';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Negotiating'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
                newTask.Description = 'Research your market value and know your numbers\nPrepare your negotiation scripts\nEvaluate your offer and decline or accept';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Accepted'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
                newTask.Description = 'Plan your resignation if applicable\nTake some time to relax and recharge\nPrepare for your first day of onboarding';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Closed'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks To Complete', priority = 'High');
                newTask.Description = 'Send a follow-up email thanking the interviewer and asking for feedback\nReview your notes and reflect on areas of improvement';
                tasksToInsert.add(newTask);
            }
            Insert tasksToInsert;
        }
    }

    public static void setStatusToSaved(List<Opportunity> jobAppsTriggered){
        for (Opportunity jobApp : jobAppsTriggered){
            jobApp.StageName = 'Saved';
        }
    }
}

    

