public with sharing class JiraCalloutService {

    /**
     * Inner response wrapper expected by JiraQueueableCallout
     */
    public class JiraResponseWrapper {
        public Boolean isSuccess { get; set; }
        public String issueKey { get; set; }
        public Integer statusCode { get; set; }
        public String errorMessage { get; set; }

        public JiraResponseWrapper() {
            this.isSuccess = false;
        }
    }

    /**
     * Creates a Jira issue via HTTP callout with detailed response info
     * Parameter order: (projectKey, summary, description, issueType)
     */
    public static JiraResponseWrapper createJiraIssueDetailed(String projectKey, String summary, String description, String issueType) {
        JiraResponseWrapper response = new JiraResponseWrapper();

        if (String.isBlank(projectKey) || String.isBlank(summary)) {
            response.statusCode = 400;
            response.errorMessage = 'Required parameters missing (projectKey or summary).';
            return response;
        }

        Map<String, Object> fields = new Map<String, Object>{
            'project'     => new Map<String, String>{ 'key' => projectKey },
            'summary'     => summary,
            'description' => description,
            'issuetype'   => new Map<String, String>{ 'name' => issueType }
        };

        Map<String, Object> payload = new Map<String, Object>{
            'fields' => fields
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Jira_Named_Credential/rest/api/2/issue');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res = http.send(req);

        response.statusCode = res.getStatusCode();

        if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
            response.isSuccess = true;
            if (String.isNotBlank(res.getBody())) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (responseMap.containsKey('key')) {
                    response.issueKey = (String) responseMap.get('key');
                } else if (responseMap.containsKey('id')) {
                    response.issueKey = (String) responseMap.get('id');
                }
            }
        } else {
            response.isSuccess = false;
            response.errorMessage = res.getBody();
        }

        return response;
    }

    /**
     * Backwards-compatible overload returning String key
     */
    public static String createJiraIssue(String summary, String description, String issueType, String projectKey) {
        JiraResponseWrapper response = createJiraIssueDetailed(projectKey, summary, description, issueType);
        return response.isSuccess ? response.issueKey : null;
    }
}