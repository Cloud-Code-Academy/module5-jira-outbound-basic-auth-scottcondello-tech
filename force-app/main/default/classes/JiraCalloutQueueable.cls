/**
 * Queueable class to make asynchronous callouts to Jira API.
 */
public class JiraCalloutQueueable implements Queueable, Database.AllowsCallouts {
    public static final String TYPE_PROJECT = 'PROJECT';
    public static final String TYPE_ISSUE = 'ISSUE';

    private String calloutType;
    private Id recordId;
    private JiraWrapper.ProjectWrapper projectWrapper;
    private JiraWrapper.IssueWrapper issueWrapper;

    /**
     * Constructor for a Jira Project callout.
     */
    public JiraCalloutQueueable(
        Id recordId,
        String projectName,
        String projectKey,
        String description
    ) {
        this.calloutType = TYPE_PROJECT;
        this.recordId = recordId;
        this.projectWrapper = new JiraWrapper.ProjectWrapper(
            projectName,
            projectKey,
            description
        );
    }

    /**
     * Constructor for a Jira Issue callout.
     */
    public JiraCalloutQueueable(
        Id recordId,
        String projectKey,
        String summary,
        String description,
        String issueType
    ) {
        this.calloutType = TYPE_ISSUE;
        this.recordId = recordId;
        this.issueWrapper = new JiraWrapper.IssueWrapper(
            summary,
            description,
            projectKey,
            issueType
        );
    }

    /**
     * Executes the appropriate Jira API callout and updates the source record.
     */
    public void execute(QueueableContext context) {
        if (recordId == null) {
            throw new JiraCalloutQueueableException(
                'A Salesforce record ID is required for the Jira callout.'
            );
        }

        if (calloutType == TYPE_PROJECT) {
            if (projectWrapper == null) {
                throw new JiraCalloutQueueableException(
                    'Project request data is missing.'
                );
            }
            String jiraProjectId = JiraAPIService.createProject(projectWrapper);
            if (String.isBlank(jiraProjectId)) {
                throw new JiraCalloutQueueableException(
                    'Jira did not return a project ID.'
                );
            }
            updateJiraProject(jiraProjectId);
        } else if (calloutType == TYPE_ISSUE) {
            if (issueWrapper == null) {
                throw new JiraCalloutQueueableException(
                    'Issue request data is missing.'
                );
            }
            String jiraIssueKey = JiraAPIService.createIssue(issueWrapper);
            if (String.isBlank(jiraIssueKey)) {
                throw new JiraCalloutQueueableException(
                    'Jira did not return an issue key.'
                );
            }
            updateJiraIssue(jiraIssueKey);
        } else {
            throw new JiraCalloutQueueableException(
                'Unsupported Jira callout type: ' + calloutType
            );
        }
    }

    /**
     * Updates the Salesforce project record with Jira's returned project ID.
     */
    private void updateJiraProject(String jiraProjectId) {
        update new Jira_Project__c(
            Id = recordId,
            Project_ID__c = jiraProjectId
        );
    }

    /**
     * Updates the Salesforce issue record with Jira's returned issue key.
     */
    private void updateJiraIssue(String jiraIssueKey) {
        update new Jira_Issue__c(
            Id = recordId,
            Issue_Key__c = jiraIssueKey,
            Last_Updated__c = System.now()
        );
    }

    public class JiraCalloutQueueableException extends Exception {
    }
}