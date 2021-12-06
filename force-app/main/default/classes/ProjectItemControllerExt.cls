public with sharing class ProjectItemControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    // User record access
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.ProjectItem__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static ProjectItem__c getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Type__c, Title__c FROM ProjectItem__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM ProjectItem__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM ProjectItem__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT User__c FROM ProjectItem__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User__c'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static Project__c getProject(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, Title__c
                FROM Project__c
                WHERE Id IN (SELECT Project__c FROM ProjectItem__c WHERE Id = :recId)
                LIMIT 1]; 
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> projectSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             Project__c (Id, Name, Title__c WHERE Id NOT IN :selectedIds ORDER BY Title__c)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        Project__c [] projects = ((List<Project__c>) searchResults[0]);
        for (Project__c project : projects) {
            results.add(new AgouraFree.LookupSearchResult(project.Id, 'Project__c', 'standard:drafts', project.Title__c, 'Project • ' + project.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> userOnlySearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             User (Id, Name, Title, SmallPhotoUrl WHERE Id NOT IN :selectedIds ORDER BY Name)                                          
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User • ' + user.Title));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<ProjectItem__c> getProjectSwimLanes(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Title__c
                FROM ProjectItem__c
                WHERE Project__c = :projectId 
                AND Type__c = 'Project Swim Lane'
                ORDER BY Title__c]; 
    }
    
    @AuraEnabled        
    public static Map<String, String> getFieldLabelMap(String objectName, List<String> fieldList){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        for(String  fieldName : fieldList) {                 
            fieldLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());                
        }
        return fieldLabelMap;
    }
}
