public with sharing class JoobleJobExtract {
    public static void fetchAndSaveJobs(String keywords, String location, String startDate) {
    //public static void fetchAndSaveJobs(String keywords, String location, String startDate, String page) {
        
        System.debug('******************************');
        System.debug('*** Start FetchAndSaveJobs ***');

        List<JoobleResponse> callResults = new List<JoobleResponse>();
        Integer page = 1;
        Integer resultOnPage = 100;

        String endpoint = 'https://jooble.org/api';            
        String callEndpoint = 'callout:JoobleAPI'; // This is a Named Credential
        String apiKey = '616f76a6-f012-48d1-ab55-959ec666d436';
        
        String requestBody = '{ "keywords": "' + keywords + '", ' + 
                                '"location": "' + location + '", ' + 
                                '"datecreatedfrom": "' + startDate + '", ' + 
                                '"radius": "50",' +  
                                '"page": "' + page + '", ' +  
                                '"resultonpage": "' + String.valueOf(resultOnPage) + '", ' +  
                                '"companysearch": "False"}';
        /*    
        String requestBody = '{ "keywords": "' + keywords + '", ' + 
                                '"location": "' + location + '", ' + 
                                '"radius": "50",' +  
                                '"page": "' + page + '", ' +  
                                '"resultonpage": "' + String.valueOf(resultOnPage) + '", ' +  
                                '"companysearch": "False"}';
        */
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint + '/' + apiKey);
        //req.setEndpoint(callEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        System.debug('res.getStatus() = ' + res.getStatus());
        System.debug('res.getStatusCode() = ' + res.getStatusCode());
        System.debug('res.getBody() = ' + res.getBody());
        
        if (res.getStatusCode() == 200) {

            // Deserialize the JSON string to JoobleResponse wrapper class
            JoobleResponse jobsResponse = (JoobleResponse) JSON.deserialize(res.getBody(), JoobleResponse.Class);

            System.debug('jobsResponse = ' + jobsResponse);

            if (jobsResponse.jobs != null){
                callResults.add(jobsResponse);
            }

            // Create all the Opportunity Job Application records for upsert
            processJobs(callResults);

        } else {
            System.debug('Error: ' + res.getStatus());
        }
    }
    
    @TestVisible
    private static void processJobs(List<JoobleResponse> callResults) {

        System.debug('******************************');
        System.debug('*** Start processJobs      ***');

        // Create a Set of the Jooble Ids returned from the callout
        Set<String> jobIds = new Set<String>();
        for (JoobleResponse jobsResponse : callResults) {
            for (JoobleJobs j : jobsResponse.jobs){
                if (!String.isEmpty(j.company)) {
                    jobIds.add(j.id);
                }
            }
        }

        // G e t   E x i s t i n g   O p p o r t u n i t i e s  
        System.debug('******************************');
        System.debug('*** Get Existing Opportunities      ***');

        // Retrieve any existing Opportunity records that have a Jooble Id in the Set
        List<Opportunity> existingOpportunities = [SELECT Id, Jooble_External_Id__c,Name,StageName,CloseDate,NextStep,AccountId,Type,Job_Location__c,Jooble_Salary__c,Job_Description__c,URL__c,Job_Board_Site__c,LeadSource,Job_Posting_Date__c FROM Opportunity WHERE Jooble_External_Id__c IN :jobIds];

        // Create a Map of the Jooble Id to the existing Opportunity record
        Map<String, Opportunity> existingOpportunitiesMap = new Map<String, Opportunity>();
        for (Opportunity opp : existingOpportunities) {
            existingOpportunitiesMap.put(opp.Jooble_External_Id__c, opp);
        }
        
        // G e t  E x i s t i n g  A c c o u n t s 
        System.debug('******************************');
        System.debug('*** Get Existing Accounts  ***');

        // Create a Set to store all Jooble Company names returned from Jooble
        Set<String> jobCompanyNames = new Set<String>();
        for (JoobleResponse jobsResponse : callResults) {
            for (JoobleJobs job : jobsResponse.jobs){
                if (!String.isEmpty(job.company)){
                    jobCompanyNames.add(job.company);
                }
            }
        }
        System.debug('**jobCompanyNames = ' + jobCompanyNames);

        // Retrieve all the existing Accounts with a Name in the Set
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name IN :jobCompanyNames];
        System.debug('**List existingAccounts = ' + existingAccounts);

        // Look through each unique Company Name returned from Jooble to determine if it exists already
        for (String jobCompanyName : jobCompanyNames) {
            System.debug('**In for (String jobCompanyName : jobCompanyNames): ');
            System.debug('**jobCompanyName: ' + jobCompanyName);

            Boolean accountExists = false;
            for (Account acc : existingAccounts) {
                if (jobCompanyName.equalsIgnoreCase(acc.Name)) {
                    accountExists = true;
                    break;
                }
            }            
            // If the Account does not exist, add a new Account record
            System.debug('**Do accountExists = ' + accountExists);

            if (!accountExists) {
                existingAccounts.add(new Account(Name = jobCompanyName));
                System.debug('**List existingAccounts = ' + existingAccounts);
                System.debug('**Added Account: ' + jobCompanyName);
            }
            accountExists = false;
        }
        
        // Upsert all existing Accounts
        Database.upsert(existingAccounts, AccessLevel.SYSTEM_MODE);

        // Create a Map of the Jooble Company name to the existing Account record
        Map<String, Account> existingAccountsMap = new Map<String, Account>();
        for (Account acc : existingAccounts) {
            existingAccountsMap.put(acc.Name, acc);
        }

        // C r e a t e   a n d   I n s e r t   N e w   A c c o u n t s   a n d   O p p o r t u t i e s
        System.debug('******************************');
        System.debug('*** Create & Insert New Accounts & Opportunities      ***');

        Integer totalCallResults = callResults.size();
        System.debug('totalCallResults = ' + totalCallResults );
        
        //Integer totaljobsResponsejobs = jobsResponse.size();
        //System.debug('totaljobsResponsejobs = ' + totaljobsResponsejobs );


        // List to store all the Opportunity records
        List<Opportunity> newOpportunities = new List<Opportunity>();

        List<Account> newAccounts = new List<Account>();

        // Iterate through the List of Jobs to create the Job_Application__c records

        for (JoobleResponse jobsResponse : callResults) {
            for (JoobleJobs job : jobsResponse.jobs){
                if (!existingOpportunitiesMap.containsKey(job.id) && !String.isEmpty(job.company)) {
                    Account account;
                    if (existingAccountsMap.containsKey(job.company)) {
                        account = existingAccountsMap.get(job.company);
                    } else {
                        account = new Account(Name = job.company);
                        newAccounts.add(account);
                    }
                    
                    //String jobDesc = 'This is a job description. Salary Range: $80,000 - $100,000 per year. Other details...';
                    if (job.salary == '') {
                        String jobDescSalary = JoobleJobExtract.getSalaryInSnippet(job.snippet);
                        System.debug('Extracted Salary Range: ' + jobDescSalary);
                        if (jobDescSalary != null) {
                            job.salary = jobDescSalary; 
                        }
                    } 
                                      
                    //String jobDesc = 'This is a job description. Salary Range: $80,000 - $100,000 per year. Other details...';
                    if (job.type == null) {
                        String jobDescType = JoobleJobExtract.getJobTypeInSnippet(job.snippet);
                        System.debug('Extracted Type: ' + jobDescType);
                        if (jobDescType != null) {
                            job.type= jobDescType ; 
                        }                    
                    }
                    
                    System.debug('******************************');
                    System.debug('*** Build Opportunity Records    ***');
                    System.debug('**account.Id = ' + account.Id);
                    System.debug('**job.company = ' + job.company);
                    System.debug('**job.id = ' + job.id);
                    System.debug('**job.title = ' + job.title);
                    
                    System.debug('**job.salary = ' + String.valueOf(job.salary));
                    System.debug('**job.location = ' + job.location);
                    System.debug('**job.source = ' + job.source);
                    System.debug('**job.type = ' + job.type);
                    
                    System.debug('**LeadSource = ' + 'Jooble');
                    System.debug('**job.link = ' + job.link);
                    System.debug('**job.updated= ' + Date.valueOf(job.updated));
                    
                    Opportunity opp = new Opportunity(
                        Name = account.Name + ' - ' + job.title,
                        StageName = 'Saved',
                        CloseDate = Date.today().addMonths(1),
                        NextStep = 'Apply for Position',
                        AccountId = account.Id,
                        Type = job.type,
                        //Type = job.JobType,
                        Job_Location__c = job.location,
                        Jooble_Salary__c = String.valueOf(job.salary),
                        Job_Description__c = job.snippet,
                        Jooble_External_Id__c = job.id,
                        URL__c = job.link,
                        Job_Board_Site__c = job.source,
                        LeadSource = 'Jooble',
                        Job_Posting_Date__c = Date.valueOf(job.updated)
                    );
                    newOpportunities.add(opp);
                }
            }
        }
        
        if (!newAccounts.isEmpty()) {
            System.debug('******************************');
            System.debug('*** Insert New Accounts    ***');

            insert newAccounts;
        }
        
        if (!newOpportunities.isEmpty()) {

            System.debug('******************************');
            System.debug('*** Insert New Opportunities    ***');

            insert newOpportunities;
        }
    }
      
    public static String getSalaryInSnippet(String jobDesc) {
        //String searchString = 'Salary Range: ';
        String searchString = 'Salary';
        Integer searchStringLength = searchString.length();
        String jobDescSalary = '';
        String jobDescSalary2 = '';
        String jobDescSalaryBefore = '';
        String jobDescSalaryAfter = '';

        if (jobDesc != null && jobDesc.contains(searchString)) {
            Integer startIndex = jobDesc.indexOf(searchString) + searchStringLength;
            Integer endIndex = startIndex + 30;

            if (endIndex > jobDesc.length()) {
                endIndex = jobDesc.length();
            }
    
            jobDescSalary = jobDesc.substring(startIndex, endIndex).trim();
            if (jobDescSalary.contains('$')) {
                jobDescSalaryBefore = jobDescSalary.substringBefore('$');
                jobDescSalaryAfter = jobDescSalary.replaceFirst(jobDescSalaryBefore, '');
                jobDescSalary = jobDescSalaryAfter;
            }
            
            if (jobDescSalary.contains(': ')) {            
                jobDescSalaryAfter = jobDescSalary.replaceFirst(': ','');
                jobDescSalary = jobDescSalaryAfter;
            }

            if (!jobDescSalary.containsAny('0123456789')) {            
                jobDescSalary = '';
            }
        }

        return jobDescSalary;
    }
          
    public static String getJobTypeInSnippet(String jobDesc) {
        String searchString = 'Type';
        Integer searchStringLength = searchString.length();
        String jobDescType = '';

        if (jobDesc != null && jobDesc.contains(searchString)) {
            Integer startIndex = jobDesc.indexOf(searchString) + searchStringLength;
            Integer endIndex = startIndex + 20;

            if (endIndex > jobDesc.length()) {
                endIndex = jobDesc.length();
            }

            jobDescType = jobDesc.substring(startIndex, endIndex).trim();
            
            String originalString = 'Hello, World!';
            String lowerCaseString = jobDescType.toLowerCase();
            
            if (jobDescType.contains('Permanent') || 
                jobDescType.contains('PERMANENT') || 
                jobDescType.contains('Fulltime') || 
                jobDescType.contains('Full-time')) {
                jobDescType = 'Full-Time';
            } 
            /*
            else if (j.salary.contains('k')){
                tempJob.Salary__c = Decimal.valueOf(j.salary.substringBefore('k').substring(1)) * 1000;
                tempJob.Salary_Type__c = 'Annual';
            } else if (j.salary.contains('-')) {
                tempJob.Salary__c = Decimal.valueOf(j.salary.deleteWhitespace().substringBefore('-').substring(1).replaceAll(',', ''));
                tempJob.Salary_Type__c = 'Hourly';
            } else {
                tempJob.Salary__c = Decimal.valueOf(j.salary.substringBefore(' ').substring(1));
                tempJob.Salary_Type__c = 'Hourly';
            }
            */
        }

        return jobDescType ;
    }
    
    // Wrapper Class for the JoobleResponses
    public class JoobleResponse {
        public Integer totalCount;
        public JoobleJobs[] jobs;
    }

    // Wrapper Class for the JoobleJobs array in the JoobleResponses Class
    public class JoobleJobs {
        public String title;
        public String location;
        public String snippet;
        public String salary;
        public String source;
        public String type;
        public String link;
        public String company;
        public String updated;
        public String id;
    }
}