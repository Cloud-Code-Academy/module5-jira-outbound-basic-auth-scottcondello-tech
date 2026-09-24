/**
 * Helper class for Jira triggers
 */
public with sharing class JiraTriggerHelper {
    private static final Integer MAX_QUEUEABLE_JOBS = 50;

    /**
     * Process Jira_Project__c records after insert
     * @param newProjects List of newly inserted Jira_Project__c records
     */
    public static void processProjectAfterInsert(List<Jira_Project__c> newProjects) {
        if (newProjects == null || newProjects.isEmpty()) {
            return;
        }

        List<Jira_Project__c> projectsToProcess = new List<Jira_Project__c>();

        // Filter out projects that already have a Jira project ID
        for (Jira_Project__c project : newProjects) {
            if (String.isBlank(project.Project_ID__c)) {
                projectsToProcess.add(project);
            }
        }

        // Bulkified enqueuing with governor limit safeguards
        Integer queuedCount = 0;
        for (Jira_Project__c project : projectsToProcess) {
            if (Limits.getQueueableJobs() >= MAX_QUEUEABLE_JOBS) {
                break; // Prevent System.LimitException: Too many queueable jobs added to the queue
            }

            JiraCalloutQueueable callout = new JiraCalloutQueueable(
                project.Id,
                project.Project_Name__c,
                project.Project_Key__c,
                project.Description__c
            );

            System.enqueueJob(callout);
            queuedCount++;
        }
    }

    /**
     * Process Jira_Issue__c records after insert
     * @param newIssues List of newly inserted Jira_Issue__c records
     */
    public static void processIssueAfterInsert(List<Jira_Issue__c> newIssues) {
        if (newIssues == null || newIssues.isEmpty()) {
            return;
        }

        List<Jira_Issue__c> issuesToProcess = new List<Jira_Issue__c>();

        // Filter out issues that already have a key or missing required project key
        for (Jira_Issue__c issue : newIssues) {
            if (String.isBlank(issue.Issue_Key__c) && String.isNotBlank(issue.Project_Key__c)) {
                issuesToProcess.add(issue);
            }
        }

        // Enqueue callouts within limits
        for (Jira_Issue__c issue : issuesToProcess) {
            if (Limits.getQueueableJobs() >= MAX_QUEUEABLE_JOBS) {
                break;
            }

            JiraCalloutQueueable callout = new JiraCalloutQueueable(
                issue.Id,
                issue.Project_Key__c,
                issue.Summary__c,
                issue.Description__c,
                issue.Issue_Type__c
            );

            System.enqueueJob(callout);
        }
    }
}