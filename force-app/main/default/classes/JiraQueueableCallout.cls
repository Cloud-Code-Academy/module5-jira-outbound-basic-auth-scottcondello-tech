public class JiraQueueableCallout implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIds;

    public JiraQueueableCallout(List<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {
        if (caseIds == null || caseIds.isEmpty()) return;

        List<Case> casesToUpdate = [SELECT Id, Subject, Description, Priority FROM Case WHERE Id IN :caseIds];
        List<Case> updates = new List<Case>();

        for (Case c : casesToUpdate) {
            String projectKey = 'SCRUM';
            String summary = 'Escalated Case: ' + (c.Subject != null ? c.Subject : 'No Subject');
            String description = c.Description != null ? c.Description : 'No details provided.';
            String issueType = 'Bug';

            JiraCalloutService.JiraResponseWrapper response = JiraCalloutService.createJiraIssueDetailed(projectKey, summary, description, issueType);

            if (response.isSuccess) {
                System.debug(LoggingLevel.INFO, 'SUCCESS: Jira Issue Created - Key: ' + response.issueKey);
                // Store callout success details on Case or Log record
                // c.Jira_Issue_Key__c = response.issueKey; // Enable if custom field exists
            } else {
                System.debug(LoggingLevel.ERROR, 'FAILURE: Jira Callout Error Code ' + response.statusCode + ' - ' + response.errorMessage);
                // Write persistent error logs or set status on Case
            }
        }
    }
}