@IsTest
private class JiraWrapperTest {
    @IsTest
    static void parsesMockProjectResponse() {
        JiraWrapper.ProjectResponse response =
            JiraWrapper.parseProjectResponse(
                '{"id":"10011","key":"ED","self":"https://example.com/project/10011"}'
            );

        System.assertNotEquals(null, response);
        System.assertEquals('10011', response.id);
        System.assertEquals('ED', response.key);
    }

    @IsTest
    static void parsesMockIssueResponse() {
        JiraWrapper.IssueResponse response =
            JiraWrapper.parseIssueResponse(
                '{"id":"10000","key":"ED-24","self":"https://example.com/issue/10000"}'
            );

        System.assertNotEquals(null, response);
        System.assertEquals('10000', response.id);
        System.assertEquals('ED-24', response.key);
    }
} 