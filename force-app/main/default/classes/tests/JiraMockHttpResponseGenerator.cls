@isTest
public class JiraMockHttpResponseGenerator implements HttpCalloutMock {
    private Boolean isSuccess;
    private Boolean isProject;

    public static String getMockProjectId() {
        return '10011';
    }

    public static String getMockIssueKey() {
        return 'ED-24';
    }

    public JiraMockHttpResponseGenerator(Boolean isSuccess, Boolean isProject) {
        this.isSuccess = isSuccess;
        this.isProject = isProject;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (!this.isSuccess) {
            res.setStatusCode(400);
            res.setBody('{"errorMessages":["Operation failed due to invalid input."],"errors":{}}');
            return res;
        }

        res.setStatusCode(201);
        
        String endpoint = req.getEndpoint();
        if (this.isProject || endpoint.contains('/project')) {
            res.setBody('{"id":"' + getMockProjectId() + '","key":"TP1","self":"https://your-domain.atlassian.net/rest/api/3/project/10011"}');
        } else {
            res.setBody('{"id":"10000","key":"' + getMockIssueKey() + '","self":"https://your-domain.atlassian.net/rest/api/3/issue/10000"}');
        }

        return res;
    }
}