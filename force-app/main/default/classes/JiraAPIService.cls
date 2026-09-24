/**
 * Service class for making callouts to the Jira API
 */
public with sharing class JiraAPIService {
    private static final String NC_NAME = 'callout:Jira_Named_Credential';

    /**
     * Creates a project in Jira
     * @param projectWrapper The project wrapper object containing all necessary data
     * @return String The Jira project ID
     */
    public static String createProject(JiraWrapper.ProjectWrapper projectWrapper) {
        if (projectWrapper == null) {
            return null;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NC_NAME + '/rest/api/3/project');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(projectWrapper));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
            JiraWrapper.ProjectResponse projRes = JiraWrapper.parseProjectResponse(res.getBody());
            return projRes != null ? projRes.id : null; 
        } else {
            System.debug(LoggingLevel.ERROR, 'Jira Project Creation Failed: ' + res.getStatusCode() + ' ' + res.getBody());
        }

        return null;
    }

    /**
     * Creates an issue in Jira
     * @param issueWrapper The issue wrapper object containing all necessary data
     * @return String The Jira issue key
     */
    public static String createIssue(JiraWrapper.IssueWrapper issueWrapper) {
        if (issueWrapper == null) {
            return null;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NC_NAME + '/rest/api/3/issue');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        
        // Generate ADF payload via wrapper method
        Map<String, Object> payloadMap = issueWrapper.generateIssuePayloadMap();
        req.setBody(JSON.serialize(payloadMap));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
            JiraWrapper.IssueResponse issueRes = JiraWrapper.parseIssueResponse(res.getBody());
            return issueRes != null ? issueRes.key : null;
        } else {
            System.debug(LoggingLevel.ERROR, 'Jira Issue Creation Failed: ' + res.getStatusCode() + ' ' + res.getBody());
        }

        return null;
    }
}