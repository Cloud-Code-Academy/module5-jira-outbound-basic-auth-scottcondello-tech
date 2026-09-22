/**
Wrapper classes and JSON parsers for Jira REST API requests and responses.
*/
public class JiraWrapper {
// --- Request Wrappers ---
public class ProjectWrapper {
public String key;
public String name;
public String description;
public String projectTypeKey;
public String projectTemplateKey;
public ProjectWrapper(
String name,
String key,
String description
) {
this.name = name;
this.key = key;
this.description = description;
this.projectTypeKey = 'software';
this.projectTemplateKey =
'com.pyaxis.jira.plugins.jira-servicedesk-custom-fields:next-gen-software';
}
}
public class IssueWrapper {
public Fields fields;
/*
Keep this order aligned with JiraCalloutQueueable:
summary, description, projectKey, issueType.
*/
public IssueWrapper(
String summary,
String description,
String projectKey,
String issueType
) {
this.fields = new Fields(
summary,
description,
projectKey,
issueType
);
}
/*
Retain this method if JiraAPIService expects a Map<String, Object>.
JSON.serialize(this) already creates the required JSON structure.
*/
public Map<String, Object> generateIssuePayloadMap() {
return (Map<String, Object>) JSON.deserializeUntyped(
JSON.serialize(this)
);
}
}
public class Fields {
public String summary;
public AdfDocument description;
public ProjectRef project;
public IssueTypeRef issuetype;
public Fields(
String summary,
String descriptionText,
String projectKey,
String issueType
) {
this.summary = summary;
this.description = new AdfDocument(descriptionText);
this.project = new ProjectRef(projectKey);
this.issuetype = new IssueTypeRef(issueType);
}
}
public class ProjectRef {
public String key;
public ProjectRef(String key) {
this.key = key;
}
}
public class IssueTypeRef {
public String name;
public IssueTypeRef(String name) {
this.name = name;
}
}
// --- Atlassian Document Format Wrappers ---
public class AdfDocument {
public String type = 'doc';
public Integer version = 1;
public List<AdfParagraph> content;
public AdfDocument(String descriptionText) {
content = new List<AdfParagraph>{
new AdfParagraph(descriptionText)
};
}
}
public class AdfParagraph {
public String type = 'paragraph';
public List<AdfTextNode> content;
public AdfParagraph(String text) {
content = new List<AdfTextNode>{
new AdfTextNode(
String.isBlank(text)
? 'No description provided.'
: text
)
};
}
}
public class AdfTextNode {
public String type = 'text';
public String text;
public AdfTextNode(String text) {
this.text = text;
}
}
// --- Response Wrappers ---
public class ProjectResponse {
public String id;
public String key;
public String self;
}
public class IssueResponse {
public String id;
public String key;
public String self;
}
// --- Static Parsers ---
public static ProjectResponse parseProjectResponse(String jsonBody) {
if (String.isBlank(jsonBody)) {
return null;
}
return (ProjectResponse) JSON.deserialize(
jsonBody,
ProjectResponse.class
);
}
public static IssueResponse parseIssueResponse(String jsonBody) {
if (String.isBlank(jsonBody)) {
return null;
}
return (IssueResponse) JSON.deserialize(
jsonBody,
IssueResponse.class
);
}
}