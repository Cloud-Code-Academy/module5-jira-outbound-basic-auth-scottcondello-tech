@IsTest
public class JiraHttpCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (req.getEndpoint().contains('/project')) {
            res.setStatusCode(201);
            res.setBody(
                '{"id":"10011","key":"ED",' +
                '"self":"https://your-domain.atlassian.net/rest/api/3/project/10011"}'
            );
        } else if (req.getEndpoint().contains('/issue')) {
            res.setStatusCode(201);
            res.setBody(
                '{"id":"10000","key":"ED-24",' +
                '"self":"https://your-domain.atlassian.net/rest/api/3/issue/10000"}'
            );
        } else {
            res.setStatusCode(404);
            res.setBody(
                '{"errorMessages":["Unsupported endpoint in test mock."]}'
            );
        }

        return res;
    }
}
