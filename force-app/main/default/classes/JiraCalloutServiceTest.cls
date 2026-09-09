@isTest
private class JiraCalloutServiceTest {

    /**
     * Mock class to simulate a successful 201 Created response from Jira API
     */
    private class JiraSuccessHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Verify endpoint and method
            System.assertEquals('callout:Jira/rest/api/3/issue', req.getEndpoint(), 'Endpoint should match Named Credential path');
            System.assertEquals('POST', req.getMethod(), 'HTTP Method should be POST');
            System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content-Type header missing');

            // Construct successful 201 Created JSON response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"10000","key":"SCRUM-101","self":"https://scottcondello.atlassian.net/rest/api/3/issue/10000"}');
            res.setStatusCode(201);
            return res;
        }
    }

    /**
     * Mock class to simulate an error response (400 Bad Request) from Jira API
     */
    private class JiraFailureHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"errorMessages":["Project key \'INVALID\' does not exist."],"errors":{}}');
            res.setStatusCode(400);
            return res;
        }
    }

    @isTest
    static void testCreateJiraIssueSuccess() {
        // Set the HTTP mock
        Test.setMock(HttpCalloutMock.class, new JiraSuccessHttpMock());

        Test.startTest();
        String issueKey = JiraCalloutService.createJiraIssue(
            'SCRUM',
            'Test Issue Summary',
            'Test issue description content',
            'Task'
        );
        Test.stopTest();

        // Verify the created key returned by the service
        System.assertEquals('SCRUM-101', issueKey, 'Service should return the expected Jira Issue Key');
    }

    @isTest
    static void testCreateJiraIssueFailure() {
        // Set the HTTP failure mock
        Test.setMock(HttpCalloutMock.class, new JiraFailureHttpMock());

        Boolean exceptionCaught = false;

        Test.startTest();
        try {
            JiraCalloutService.createJiraIssue(
                'INVALID',
                'Invalid Project Test',
                'Should fail',
                'Task'
            );
        } catch (CalloutException e) {
            exceptionCaught = true;
            System.assert(e.getMessage().contains('400'), 'Exception message should contain the 400 status code');
        }
        Test.stopTest();

        System.assertEquals(true, exceptionCaught, 'A CalloutException should be thrown when Jira returns a non-201 status');
    }
}