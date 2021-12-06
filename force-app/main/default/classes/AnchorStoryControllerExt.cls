public with sharing class AnchorStoryControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.AnchorStory__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<AnchorStory__c> getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Title__c, Time_Estimate__c
                FROM AnchorStory__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AnchorStory__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AnchorStory__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AnchorStory__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT OwnerId FROM AnchorStory__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults3) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Owner'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<LookupSearchResult> anchorStorySearch(String searchTerm, List<String> selectedIds, String recStr) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             AnchorStory__c (Id, Name, Title__c
                                                                     WHERE Id NOT IN :selectedIds AND Id != :recStr
                                                                     ORDER BY Title__c) LIMIT 12];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        AnchorStory__c [] stories = ((List<AnchorStory__c>) searchResults[0]);
        for (AnchorStory__c story : stories) {
            results.add(new LookupSearchResult(story.Id, 'AnchorStory__c', 'standard:task', story.Title__c, 'Anchor Story • ' + story.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AnchorStory__c> getMasterTask(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Master_Task__c, Master_Task__r.Name, Master_Task__r.Title__c
                FROM AnchorStory__c
                WHERE Id = :recId LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AnchorStory__c> getSubTasks(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, Title__c
                FROM AnchorStory__c
                WHERE Master_Task__c = :recId]; 
    }
    
    @AuraEnabled
    public static Id createCloneAnchorStory(Id recId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Acceptance_Criteria__c', 'Comments__c', 'Components__c', 'Dependencies__c', 
            'Description__c', 'Master_Task__c', 'Points__c', 'Priority__c', 
            'Search_Terms__c', 'Time_Estimate__c', 'Value__c', 'Title__c', 'Type__c', 'URL__c' };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.AnchorStory__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable() || !m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AnchorStory__c anchorStory = [SELECT Acceptance_Criteria__c, Comments__c, Components__c, Dependencies__c, 
                                              Description__c, Master_Task__c, Points__c, Priority__c, Search_Terms__c, 
                                              Time_Estimate__c, Value__c, Title__c, Type__c, URL__c                
                                              FROM AnchorStory__c
                                              WHERE Id = :recId
                                              LIMIT 1];  
        String titleStr = anchorStory.Title__c;
        
        AnchorStory__c newAnchorStory = new AnchorStory__c (
            Title__c = titleStr.left(248) + ' (Copy)',
            Acceptance_Criteria__c = anchorStory.Acceptance_Criteria__c,
            Comments__c = anchorStory.Comments__c,
            Components__c = anchorStory.Components__c,
            Dependencies__c = anchorStory.Dependencies__c,
            Description__c = anchorStory.Description__c,
            Master_Task__c = anchorStory.Master_Task__c,
            Points__c = anchorStory.Points__c,
            Priority__c = anchorStory.Priority__c,
            Search_Terms__c = anchorStory.Search_Terms__c,
            Time_Estimate__c = anchorStory.Time_Estimate__c,
            Type__c = anchorStory.Type__c,
            URL__c = anchorStory.URL__c,
            Value__c  = anchorStory.Value__c );
        insert newAnchorStory;
        RETURN newAnchorStory.Id;
    }
    
    @AuraEnabled
    public static AnchorStory__c updateDocumentOwner(Id recId, Id userId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'OwnerId'};
            Map<String,Schema.SObjectField> m = Schema.SObjectType.AnchorStory__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AnchorStory__c item = [SELECT Id, OwnerId FROM AnchorStory__c WHERE Id = :recId];
        item.OwnerId = userId;
        update item;
        RETURN item;
    }
    
    @AuraEnabled
    public static List<LookupSearchResult> userOnlySearch(String searchTerm, List<String> selectedIds) {        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             User (Id, Name, Title, SmallPhotoUrl WHERE Id NOT IN :selectedIds ORDER BY Name)                                          
                                             LIMIT :MAX_RESULTS];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User • ' + user.Title));
        }
        
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<LookupSearchResult> projectSearch(String searchTerm, List<String> selectedIds) {
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
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        Project__c [] projects = ((List<Project__c>) searchResults[0]);
        for (Project__c project : projects) {
            results.add(new LookupSearchResult(project.Id, 'Project__c', 'standard:drafts', project.Title__c, 'Project • ' + project.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static Id doCreateProjectTask(Id recId, Id projectId) {  
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Accept__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Comments__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Components__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Dependencies__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Description__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Formatted_Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Points__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Priority__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Time_Estimate__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.URL__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Value__c.isCreateable() ||            
            !Schema.sObjectType.AnchorStory__c.fields.Acceptance_Criteria__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Comments__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Components__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Dependencies__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Description__c.isAccessible() ||           
            !Schema.sObjectType.AnchorStory__c.fields.Priority__c.isAccessible() ||            
            !Schema.sObjectType.AnchorStory__c.fields.Time_Estimate__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Title__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Type__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.URL__c.isAccessible() ||
            !Schema.sObjectType.AnchorStory__c.fields.Value__c.isAccessible() ||                    
            !Schema.sObjectType.Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        AnchorStory__c anchorStory = [SELECT Acceptance_Criteria__c, Comments__c, Components__c, Dependencies__c, 
                                              Description__c, Points__c, Priority__c, Time_Estimate__c, Value__c, 
                                              Title__c, Type__c, URL__c                
                                              FROM AnchorStory__c
                                              WHERE Id = :recId
                                              LIMIT 1]; 
        AggregateResult[] taskOrderTotal = [SELECT MAX(Order__c)lastNumber
                                            FROM ProjectTask__c 
                                            WHERE Project__c = :projectId];                 
        decimal lastOrderNumber = taskOrderTotal[0].get('lastNumber') == null ? 0 : (decimal)taskOrderTotal[0].get('lastNumber'); 
        decimal nextOrderNumber = lastOrderNumber + 1;
        list<Project__c> Project = [SELECT Project_Abbreviation__c 
                                            FROM Project__c 
                                            WHERE Id = :projectId 
                                            ORDER BY Project_Abbreviation__c DESC LIMIT 1];
        string projectAbbreviation = Project[0].Project_Abbreviation__c;
        AggregateResult[] taskTotal = [SELECT MAX(Task_Number_Int__c)lastNumber
                                       FROM ProjectTask__c 
                                       WHERE Project__c = :projectId];                 
        decimal lastNumber = taskTotal[0].get('lastNumber') == null ? 0 : (decimal)taskTotal[0].get('lastNumber');                
        Integer nextTaskNumber = Integer.valueOf(lastNumber) + 1; 
 
        ProjectTask__c newProjectTask = new ProjectTask__c (
            Accept__c = anchorStory.Acceptance_Criteria__c,
            Comments__c = anchorStory.Comments__c,
            Components__c = anchorStory.Components__c,
            Dependencies__c = anchorStory.Dependencies__c,
            Description__c = anchorStory.Description__c,
            Formatted_Status__c = 'open',
            Order__c = nextOrderNumber,
            Points__c = anchorStory.Points__c,
            Priority__c = anchorStory.Priority__c,
            Project__c = projectId,
            Status__c = 'Open',
            Task_Number__c = projectAbbreviation + '-' + nextTaskNumber,
            Task_Number_Int__c = nextTaskNumber,
            Time_Estimate__c = anchorStory.Time_Estimate__c,
            Title__c = anchorStory.Title__c,
            Type__c = anchorStory.Type__c,
            URL__c = anchorStory.URL__c,
            Value__c = anchorStory.Value__c);

        insert newProjectTask;   
        RETURN newProjectTask.Id;
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
