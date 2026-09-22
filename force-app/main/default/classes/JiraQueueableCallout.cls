public class JiraQueueableCallout implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIds;
    private String projectKey;
    private String issueType;

    // Default constructor for standard Case sync
    public JiraQueueableCallout(List<Id> caseIds) {
        this(caseIds, 'SCRUM', 'Bug');
    }

    // Flexible constructor for dynamic project/issue types
    public JiraQueueableCallout(List<Id> caseIds, String projectKey, String issueType) {
        this.caseIds = caseIds;
        this.projectKey = String.isNotBlank(projectKey) ? projectKey : 'SCRUM';
        this.issueType = String.isNotBlank(issueType) ? issueType : 'Bug';
    }

    public void execute(QueueableContext context) {
        if (caseIds == null || caseIds.isEmpty()) {
            return;
        }

        // Query cases needing sync
        List<Case> casesToUpdate = [
            SELECT Id, Subject, Description 
            FROM Case 
            WHERE Id IN :caseIds 
            LIMIT 100 // Enforce max callouts per transaction limit
        ];

        List<Case> successfulCases = new List<Case>();

        for (Case c : casesToUpdate) {
            String summary = 'Escalated Case: ' + (String.isNotBlank(c.Subject) ? c.Subject : 'No Subject');
            String description = String.isNotBlank(c.Description) ? c.Description : 'No details provided.';

            // Execute Callout
            JiraCalloutService.JiraResponseWrapper response = 
                JiraCalloutService.createJiraIssueDetailed(this.projectKey, summary, description, this.issueType);

            if (response != null && response.isSuccess) {
                System.debug(LoggingLevel.INFO, 'SUCCESS: Jira Issue Created - Key: ' + response.issueKey);
                
                // Track update if custom field Jira_Issue_Key__c exists
                /*
                c.Jira_Issue_Key__c = response.issueKey;
                successfulCases.add(c);
                */
            } else {
                String errorMsg = (response != null) 
                    ? 'HTTP ' + response.statusCode + ': ' + response.errorMessage 
                    : 'Null response returned from JiraCalloutService';
                
                System.debug(LoggingLevel.ERROR, 'FAILURE: Jira Callout Error - Case ID: ' + c.Id + ' | Error: ' + errorMsg);
            }
        }

        // Perform single DML update for updated cases
        if (!successfulCases.isEmpty()) {
            Database.update(successfulCases, false);
        }
    }
}