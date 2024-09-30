# About the Project

This job application tracker is meant to be deployed to Salesforce and help you find, track and interact with important potential jobs.

## Deployment Instructions

Deployment Order:
1)	lwc
2)	objects> Account
3)	objects> Opportunity> fields
4)	objects> Opportunity> listViews
5)	objects> Opportunity> validationRules
6)	objects> Opportunity> webLinks
7)	objects> Org_Specific_Setting_mdt
8)	customMetadata
9)  flexipages
10) objects> Event
11) objects> Activity
12)	classes
13)	layouts
14)	contentassets
15)	applications
16)	appMenus
17)	externalCredentials
18)	namedCredentials
19)	objectTranslations Opportunity-en_US
20)	standardValueSets 
21)	pathAssistant> Job_Application_Path.pathAssistant-meta.xml
22)	permissionsets> Job_Application_Components.permissionset-meta.xml
23)	remoteSiteSettings
24)	settings
25)	triggers

For the following, use the Salesforce User Interface:

Assign Permission Set:
Setup> Permission Sets> Job Application Components 
	Assign yourself the permission set

Enable Paths (if necessary):
Setup> Path Settings>Enable Paths

Assign Contact Role Layout:
Setup> Job Application Contact Role> Page Layout Assignments> Edit Assignment> Select relevant profiles to assign Opportunity Contact Role Page Layout to

Update App Menu:
Setup> App Menu> Click "Hide in App Launcher" next to every App except "Job Application"

Add the Weekly Scheduling of the Apex Class ‘StaleJobApplicationCleanup’:
Setup> Jobs> Scheduled Jobs
	Job Name = ‘Weekly Stale Job Application Cleanup’
	Apex Class = ‘StaleJobApplicationCleanup’
	Schedule Using CRON Expression = Check
	Cron Expression = ‘0 0 1 ? * MON *’
        This will schedule the Job to run weekly at 1 AM on Mondays indefinitely

Add the Weekly Scheduling of the Apex Class ‘Weekly Jooble Job Applications’:
Setup> Jobs> Scheduled Jobs
	Job Name = ‘Weekly Jooble Job Applications’
	Apex Class = ‘JoobleJobExtractScheduler
	Schedule Using CRON Expression = Check
	Cron Expression = ‘0 0 8 ? * MON *’
        This will schedule the Job to run weekly at 8 AM on Mondays indefinitely
