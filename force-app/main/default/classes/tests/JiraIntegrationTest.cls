@isTest
private class JiraIntegrationTest {

    @testSetup
    static void setupTestData() {
        Jira_Issue__c testIssue = new Jira_Issue__c(
            Summary__c = 'Test Issue Summary',
            Description__c = 'Test Description',
            Project_Key__c = 'SCRUM',
            Issue_Type__c = 'Task'
        );
        insert testIssue;
    }

    @isTest
    static void testCreateProjectSuccess() {
        String mockBody = '{"id": "10011", "key": "SCRUM", "self": "https://your-domain.atlassian.net/rest/api/3/project/10011"}';
        Test.setMock(HttpCalloutMock.class, new JiraHttpCalloutMock(201, mockBody));

        JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper('Test Project', 'TP', 'Test Project Description');

        Test.startTest();
        String projectId = JiraAPIService.createProject(projectWrapper);
        Test.stopTest();

        Assert.areEqual('10011', projectId, 'Project ID should match the mock response.');
    }

    @isTest
    static void testCreateIssueSuccess() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpCalloutMock(200, '{"key": "ED-24", "id": "10024"}'));
        
        Jira_Issue__c issue = [SELECT Id, Issue_Key__c FROM Jira_Issue__c LIMIT 1];

        Test.startTest();
        JiraAPIService.createIssue(issue.Id);
        Test.stopTest();

        issue = [SELECT Issue_Key__c FROM Jira_Issue__c WHERE Id = :issue.Id];
        Assert.areEqual('ED-24', issue.Issue_Key__c, 'Issue key should match mock response');
    }

    @isTest
    static void testProjectTriggerAndQueueable() {
        String mockBody = '{"id": "10011", "key": "PROJ", "self": "https://your-domain.atlassian.net/rest/api/3/project/10011"}';
        Test.setMock(HttpCalloutMock.class, new JiraHttpCalloutMock(201, mockBody));

        Jira_Project__c proj = new Jira_Project__c(
            Project_Name__c = 'New Mobile App',
            Project_Key__c = 'NMA',
            Description__c = 'Project for mobile app build'
        );

        Test.startTest();
        insert proj;
        Test.stopTest(); 

        Jira_Project__c updatedProj = [SELECT Id, Project_ID__c FROM Jira_Project__c WHERE Id = :proj.Id];
        Assert.areEqual('10011', updatedProj.Project_ID__c, 'Project ID should match the mock response');
    }

    @isTest
    static void testIssueTriggerAndQueueable() {
        String mockBody = '{"id": "10002", "key": "ED-24", "self": "https://your-domain.atlassian.net/rest/api/3/issue/10002"}';
        Test.setMock(HttpCalloutMock.class, new JiraHttpCalloutMock(201, mockBody));

        Jira_Issue__c issue = new Jira_Issue__c(
            Summary__c = 'Fix Login Bug',
            Description__c = 'Users cannot log in via SSO',
            Project_Key__c = 'SCRUM',
            Issue_Type__c = 'Bug'
        );

        Test.startTest();
        insert issue;
        Test.stopTest();

        Jira_Issue__c updatedIssue = [SELECT Id, Issue_Key__c FROM Jira_Issue__c WHERE Id = :issue.Id];
        Assert.areEqual('ED-24', updatedIssue.Issue_Key__c, 'Issue key should be updated by Queueable.');
    }

    @isTest
    static void testApiFailureHandling() {
        String mockErrorBody = '{"errorMessages":["Project key already exists."],"errors":{}}';
        Test.setMock(HttpCalloutMock.class, new JiraHttpCalloutMock(400, mockErrorBody));

        JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper('Duplicate Project', 'DUP', 'Description');

        Test.startTest();
        String projectId = JiraAPIService.createProject(projectWrapper);
        Test.stopTest();

        Assert.isNull(projectId, 'Project ID should be null on API error response.');
    }
}