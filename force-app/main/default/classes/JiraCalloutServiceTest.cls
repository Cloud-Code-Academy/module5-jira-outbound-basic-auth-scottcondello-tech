@isTest
private class JiraCalloutServiceTest {

    private class JiraCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(201);
            res.setBody('{"id":"10024","key":"ED-24"}');
            return res;
        }
    }

    @isTest
    static void testCreateJiraIssueCallout() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());

        // Create requisite parent record if method expects an ID parameter
        Jira_Project__c proj = new Jira_Project__c(Name = 'Test Proj', Project_Key__c = 'ED');
        insert proj;

        Jira_Issue__c issue = new Jira_Issue__c(
            Summary__c = 'Test Bug', 
            Issue_Type__c = 'Bug', 
            Jira_Project__c = proj.Id
        );
        insert issue;

        Test.startTest();
        // Update this call to match JiraCalloutService method signature:
        // Example A (If ID expected): JiraCalloutService.createJiraIssue(issue.Id);
        // Example B (If 3 params expected): JiraCalloutService.createJiraIssue(issue.Summary__c, issue.Issue_Type__c, 'ED');
        JiraCalloutService.createJiraIssue(issue.Summary__c, 'Description', issue.Issue_Type__c, 'ED');
        Test.stopTest();

        Assert.areEqual(1, Limits.getCallouts(), 'A callout should have executed.');
    }
}