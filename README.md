# About the Project

This job application tracker is meant to be deployed to Salesforce and help you find, track and interact with important potential jobs.

## Deployment Instructions

Deployment Order:
1)	objects> Account
2)	lwc
3)	objects> Opportunity> fields
4)	objects> Opportunity> listViews
5)	objects> Opportunity> validationRules
6)	objects> Opportunity>Weblinks
7)	objects> Org_Specific_Setting_mdt
8)	customMetadata
9)	classes
10)	flexipages
11)	layouts
12)	Org specific setting under org specific setting mdt
13)	Value field under org specific setting
14)	Objects> Org_Specific_Setting_mdt> Fields
15)	contentassets
16)	applications
17)	appMenus (only Salesforce1 app menu works)
18)	externalCredentials
19)	namedCredentials
20)	objectTranslations Opportunity-en_US
21)	standardValueSets 
22)	pathAssistant> Job_Application_Path.pathAssistant-meta.xml
23)	permissionsets> Job_Application_Components.permissionset-meta.xml
24)	remoteSiteSettings
25)	settings
26)	triggers


For the following, use the Salesforce User Interface:

Assign Permission Set:
Setup> Permission Sets> Job Application Components 
	Assign yourself the permission set

Enable Paths (if necessary):
Setup>Path Settings>Enable Paths

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
