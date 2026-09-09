public with sharing class JiraCalloutService {

    public class JiraResponseWrapper {
        public Boolean isSuccess;
        public Integer statusCode;
        public String issueKey;
        public String issueId;
        public String errorMessage;

        public JiraResponseWrapper(Boolean isSuccess, Integer statusCode, String issueKey, String issueId, String errorMessage) {
            this.isSuccess = isSuccess;
            this.statusCode = statusCode;
            this.issueKey = issueKey;
            this.issueId = issueId;
            this.errorMessage = errorMessage;
        }
    }

    public static JiraResponseWrapper createJiraIssueDetailed(String projectKey, String summary, String description, String issueType) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        // Endpoint using Legacy Named Credential JIRA
        req.setEndpoint('callout:JIRA/rest/api/3/issue');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000); // 120-second timeout enforcement

        // Build Atlassian Document Format (ADF) payload
        Map<String, Object> payload = buildAdfPayload(projectKey, summary, description, issueType);
        req.setBody(JSON.serialize(payload));

        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 201) {
                Map<String, Object> jsonResponseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String createdKey = (String) jsonResponseBody.get('key');
                String createdId = (String) jsonResponseBody.get('id');
                return new JiraResponseWrapper(true, res.getStatusCode(), createdKey, createdId, null);
            } else {
                // Extract Atlassian error messages if present
                String errorDetail = 'HTTP ' + res.getStatusCode() + ' - ' + res.getStatus() + ': ' + res.getBody();
                return new JiraResponseWrapper(false, res.getStatusCode(), null, null, errorDetail);
            }
        } catch (System.CalloutException e) {
            return new JiraResponseWrapper(false, 0, null, null, 'Callout Exception (Network/Auth/Timeout): ' + e.getMessage());
        } catch (Exception e) {
            return new JiraResponseWrapper(false, 0, null, null, 'Unexpected Exception: ' + e.getMessage());
        }
    }

    private static Map<String, Object> buildAdfPayload(String projectKey, String summary, String description, String issueType) {
        Map<String, Object> textContent = new Map<String, Object>{
            'type' => 'text',
            'text' => String.isNotBlank(description) ? description : 'No description provided.'
        };

        Map<String, Object> paragraphContent = new Map<String, Object>{
            'type' => 'paragraph',
            'content' => new List<Object>{ textContent }
        };

        Map<String, Object> descriptionAdf = new Map<String, Object>{
            'type' => 'doc',
            'version' => 1,
            'content' => new List<Object>{ paragraphContent }
        };

        Map<String, Object> fields = new Map<String, Object>{
            'project' => new Map<String, Object>{ 'key' => projectKey },
            'summary' => summary,
            'description' => descriptionAdf,
            'issuetype' => new Map<String, Object>{ 'name' => issueType }
        };

        return new Map<String, Object>{ 'fields' => fields };
    }
}