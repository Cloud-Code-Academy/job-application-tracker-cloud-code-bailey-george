public with sharing class JobApplicationTriggerHelper extends TriggerHandler{

    public static void setStatusToSaved(List<Opportunity> jobAppsTriggered){
        for (Opportunity jobApp : jobAppsTriggered){
            jobApp.StageName = 'Saved';
        }
    }

    public static void generateTaskNewJobApp(List<Opportunity> jobAppsTriggered){
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity jobApp : jobAppsTriggered){
            Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks when Saved', priority = 'High');
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
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks when Applying', priority = 'High');
                newTask.Description = 'Find and research someone who works at the company and add them as a contact \nSet up an informational interview to learn more about the role/company\nIdentify potential referrals to help get your application on the top of the pile\nCustomize your work achievements using the job description keywords\nSubmit your application on the company website if possible';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Applied'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks after Applied', priority = 'High');
                newTask.Description = 'Reach out to the hiring manager or recruiter\nFollow up on your application via email weekly\nContinue identifying and saving similar job opportunities\nSet up weekly networking calls to explore similar companies/roles';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Interviewing'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks when Interviewing', priority = 'High');
                newTask.Description = 'Prepare your blurb or “tell me about yourself” response\nPractice answering behavioral interview questions\nResearch the company and your interviewers\nSet up your virtual interview space and test your tech\nSend thank you emails within 24 hours';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Negotiating'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks when Negotiating', priority = 'High');
                newTask.Description = 'Research your market value and know your numbers\nPrepare your negotiation scripts\nEvaluate your offer and decline or accept';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Accepted'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks once Accepted', priority = 'High');
                newTask.Description = 'Plan your resignation if applicable\nTake some time to relax and recharge\nPrepare for your first day of onboarding';
                tasksToInsert.add(newTask);
            }
            if((jobApp.StageName != oldJobApp.StageName)&& jobApp.StageName == 'Closed'){
                Task newTask = new Task(whatId = jobApp.Id, ActivityDate = Date.today().addDays(1), subject = 'Job Application Tasks when Closed', priority = 'High');
                newTask.Description = 'Send a follow-up email thanking the interviewer and asking for feedback\nReview your notes and reflect on areas of improvement';
                tasksToInsert.add(newTask);
            }
        }
        Insert tasksToInsert;
    }

    public static void calculateTakeHomePay(List<Opportunity> jobAppsTriggered){
        Decimal annualSalary = 0;
        Decimal spousesSalary = 0;
        String filingStatus = null;
        for (Opportunity jobApp : jobAppsTriggered){
            if (jobApp.annual_gross_salary__c != null && jobApp.Salary_Lowest__c != null && jobApp.annual_gross_salary__c == 'Salary - Lowest' && jobApp.filing_Status__c != null){
                spousesSalary = jobApp.spouse_s_salary__c;
                annualSalary = jobApp.Salary_Lowest__c;
                Decimal fedIncomeTax = JobApplicationTriggerHelper.calculateFedIncomeTax(jobApp.Salary_lowest__c, jobApp.filing_status__c, spousesSalary);
                jobApp.federal_income_tax__c = fedIncomeTax;
                jobApp.medicare__c = annualSalary * .0145;
                jobApp.social_Security__c = annualSalary * .062;
                jobApp.take_Home_Pay__c = annualSalary - (fedIncomeTax + jobApp.medicare__c + jobApp.social_Security__c);
            }
            else if (jobApp.annual_gross_salary__c != null && jobApp.Salary_Highest__c != null && jobApp.annual_gross_salary__c == 'Salary - Highest' && jobApp.filing_Status__c != null){
                spousesSalary = jobApp.spouse_s_Salary__c;
                annualSalary = jobApp.Salary_Highest__c;
                Decimal fedIncomeTax = JobApplicationTriggerHelper.calculateFedIncomeTax(jobApp.Salary_Highest__c, jobApp.filing_status__c, spousesSalary);
                jobApp.federal_income_tax__c = fedIncomeTax;
                jobApp.medicare__c = annualSalary * .0145;
                jobApp.social_Security__c = annualSalary * .062;
                jobApp.take_Home_Pay__c = annualSalary - (jobApp.federal_income_tax__c + jobApp.medicare__c + jobApp.social_Security__c);
            } else {
                jobApp.federal_income_tax__c = null;
                jobApp.medicare__c = null;
                jobApp.social_Security__c = null;
                jobApp.take_Home_Pay__c = null;
            }
        }
    }

    public static Decimal calculateFedIncomeTax (Decimal salary, String filingStatus, Decimal spousesSalary){
        Decimal fedIncomeTax = 0;
        if (filingStatus == 'Single'){
            fedIncomeTax = JobApplicationTriggerHelper.filingSingle(salary);     
        }
        else if (filingStatus == 'Married filing jointly'){
            fedIncomeTax = JobApplicationTriggerHelper.marriedFilingJointly(salary, spousesSalary);
        }
        else if (filingStatus == 'Married filing separately'){
            fedIncomeTax = JobApplicationTriggerHelper.marriedFilingSeparately(salary);
        }
        else if (filingStatus == 'Head of household'){
            fedIncomeTax = JobApplicationTriggerHelper.headOfHousehold(salary);
        }
        return fedIncomeTax.setScale(2);
    }

    public static Decimal filingSingle(Decimal salary){
        Decimal tax = 0;
        Decimal previousLimit = 0;
        Decimal runningSalary = salary; 
        Map<Decimal, Decimal> taxBrackets = new Map<Decimal, Decimal>();
            taxBrackets.put(11600, .10);
            taxBrackets.put(47150, .12);
            taxBrackets.put(100525, .22);
            taxBrackets.put(191950, .24);
            taxBrackets.put (243725, .32);
            taxBrackets.put (609350, .35);
            taxBrackets.put (999999, .37);

        for (Decimal bracket : taxBrackets.keySet()){
            if (bracket < salary){ 
                tax += (bracket - previousLimit) * taxBrackets.get(bracket); 
                runningSalary = (salary - bracket);
                previousLimit = bracket; 
            } else if (bracket >= salary){
                tax += runningSalary * taxBrackets.get(bracket);
                break;    
            }  
        }
        return tax.setScale(2);
    }
            
    public static Decimal marriedFilingJointly(Decimal salary, Decimal spousesSalary){
        Decimal tax = 0;
        Decimal previousLimit = 0;
        Decimal combinedSalary = salary + spousesSalary;
        Decimal runningSalary = combinedSalary;
        Decimal removeSpousesTaxes = 0;
        Map<Decimal, Decimal> taxBrackets = new Map<Decimal, Decimal>();
            taxBrackets.put(23200, .10);
            taxBrackets.put(94300, .12);
            taxBrackets.put(201050, .22);
            taxBrackets.put(383900, .24);
            taxBrackets.put (487450, .32);
            taxBrackets.put (731200, .35);
            taxBrackets.put (999999, .37);
        for (Decimal bracket : taxBrackets.keySet()){
            if (bracket < combinedSalary){ 
                tax += (bracket - previousLimit) * taxBrackets.get(bracket);
                runningSalary = (combinedSalary - bracket);
                previousLimit = bracket; 
            } else if (bracket >= combinedSalary){
                tax += runningSalary * taxBrackets.get(bracket); 
                break;
            }
        }
            removeSpousesTaxes = ((spousesSalary / combinedSalary) * tax);
            tax -= removeSpousesTaxes;
            return tax.setScale(2); 
    }

    public static Decimal marriedFilingSeparately(Decimal salary){
        Decimal tax = 0;
        Decimal previousLimit = 0;
        Decimal runningSalary = salary;
        Map<Decimal, Decimal> taxBrackets = new Map<Decimal, Decimal>();
            taxBrackets.put(11600, .10);
            taxBrackets.put(47150, .12);
            taxBrackets.put(100525, .22);
            taxBrackets.put(191950, .24);
            taxBrackets.put (243725, .32);
            taxBrackets.put (365600, .35);
            taxBrackets.put (999999, .37);

        for (Decimal bracket : taxBrackets.keySet()){
            if (bracket < salary){ 
                tax += (bracket - previousLimit) * taxBrackets.get(bracket);
                runningSalary = (salary - bracket);
                previousLimit = bracket; 
            } else if (bracket >= salary){
                tax += runningSalary * taxBrackets.get(bracket);
                break;
            }
        }
        return tax.setScale(2);
    }

    public static Decimal headOfHousehold(Decimal salary){
        Decimal tax = 0;
        Decimal previousLimit = 0;
        Decimal runningSalary = salary;
        Map<Decimal, Decimal> taxBrackets = new Map<Decimal, Decimal>();
            taxBrackets.put(16550, .10);
            taxBrackets.put(63100, .12);
            taxBrackets.put(100500, .22);
            taxBrackets.put(191950, .24);
            taxBrackets.put (243700, .32);
            taxBrackets.put (609350, .35);
            taxBrackets.put (999999, .37);

        for (Decimal bracket : taxBrackets.keySet()){
            if (bracket < salary){ 
                tax += (bracket - previousLimit) * taxBrackets.get(bracket);
                runningSalary = (salary - bracket);
                previousLimit = bracket; 
            } else if (bracket >= salary){
                tax += runningSalary * taxBrackets.get(bracket); 
                break;
            }
        }
        return tax.setScale(2);
    }

    public static void populatePrimaryContact(List<Opportunity> jobAppsTriggered, Map<Id, Opportunity> newJobAppMapTrigg){
        Map<Id, OpportunityContactRole> primaryContactRolesById = new Map<Id, OpportunityContactRole>([SELECT Id, ContactId, IsPrimary, OpportunityId 
                                                                                                       FROM OpportunityContactRole 
                                                                                                       WHERE (isPrimary = true) AND (OpportunityId IN :newJobAppMapTrigg.values())]);
        Map<Id, Id> primaryContactIdByAppId = new Map<Id, Id>();
        for(Id appContact : primaryContactRolesById.keySet()){
            Id appId = primaryContactRolesById.get(appContact).OpportunityId;
            Id contactId = primaryContactRolesById.get(appContact).ContactId;
            primaryContactIdByAppId.put(appId, contactId);                                                                                      
        }

        Map<Id, OpportunityContactRole> notPrimaryContactRolesById = new Map<Id, OpportunityContactRole>([SELECT Id, ContactId, IsPrimary, OpportunityId 
                                                                                                          FROM OpportunityContactRole 
                                                                                                          WHERE (isPrimary = false) AND (OpportunityId IN :newJobAppMapTrigg.values()) ORDER BY CreatedDate ASC]);
        Map<Id, Id> notPrimaryContactIdByAppId = new Map<Id, Id>();
        for(Id appContact : notPrimaryContactRolesById.keySet()){
            Id appId = notPrimaryContactRolesById.get(appContact).OpportunityId;
            Id contactId = notPrimaryContactRolesById.get(appContact).ContactId;
            if(!notPrimaryContactIdByAppId.containsKey(appId)){
                notPrimaryContactIdByAppId.put(appId, contactId); 
            }
        }

        Map<Id, Opportunity> appsWithoutContactsById = new Map<Id, Opportunity>();
        Set<Id> acctsForAppsWithNoContact = new Set<Id>();
        for (Opportunity jobApp : jobAppsTriggered){
            if (primaryContactIdByAppId.containsKey(jobApp.Id)){
                Id primaryContactId = primaryContactIdByAppId.get(jobApp.Id);
                jobApp.primary_contact__c = primaryContactId;
            } else if (notPrimaryContactIdByAppId.containsKey(jobApp.Id)){
                Id newPrimaryContactId = notPrimaryContactIdByAppId.get(jobApp.Id);
                jobApp.primary_contact__c = newPrimaryContactId;
            } else {
                appsWithoutContactsById.put(jobApp.Id, jobApp);
                acctsForAppsWithNoContact.add(jobApp.AccountId);
            }
        }
        Map<Id, Contact> contactsFromAcctById = new Map<Id, Contact>([SELECT Id, Name, CreatedDate, AccountId 
                                                                      FROM Contact 
                                                                      WHERE AccountId IN :acctsForAppsWithNoContact ORDER BY CreatedDate DESC]);
        Map<Id, Contact> contactsByAcctId = new Map<Id, Contact>();
        for(Id contact : contactsFromAcctById.keySet()){
            Id acctId = contactsFromAcctById.get(contact).AccountId;
            contactsByAcctId.put(acctId, contactsFromAcctById.get(contact)); 
        }
        for(Id appWithoutContact : appsWithoutContactsById.keySet()){
            Opportunity appToUpdate = appsWithoutContactsById.get(appWithoutContact);
            Id acctId = appToUpdate.AccountId;
            if(contactsByAcctId.containsKey(acctId)){
                appToUpdate.primary_contact__c = contactsByAcctId.get(acctId).Id;
            } else {
                break;
            }
        }
    }
}


    

