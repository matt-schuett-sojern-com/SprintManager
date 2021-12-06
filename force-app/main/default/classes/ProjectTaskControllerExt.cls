public with sharing class ProjectTaskControllerExt {
    
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
        if (Schema.sObjectType.ProjectTask__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<ProjectTask__c> getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Task_Number__c, Title__c, Status__c, Blocked__c, Type__c,
                Time_Estimate__c, Time_Logged__c, Time_Remaining__c
                FROM ProjectTask__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM ProjectTask__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM ProjectTask__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT Assigned_To__c FROM ProjectTask__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults3) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Assigned To'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<Project__c> getProject(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, Title__c
                FROM Project__c
                WHERE Id IN (SELECT Project__c FROM ProjectTask__c WHERE Id = :recId)
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<Sprint__c> getSprint(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Sprint_Name__c
                FROM Sprint__c
                WHERE Id IN (SELECT Sprint__c FROM ProjectTask__c WHERE Id = :recId)
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<ProjectTask__c> getMasterTask(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Master_Task__c, Master_Task__r.Name, Master_Task__r.Task_Number__c
                FROM ProjectTask__c
                WHERE Id = :recId
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<ProjectTask__c> getSubTasks(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, Task_Number__c
                FROM ProjectTask__c
                WHERE Master_Task__c = :recId]; 
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
    public static void doStartWork(Id taskId){
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Status__c', 'Formatted_Status__c', 'Assigned_To__c', 'Start_Date__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }        
        
        ProjectTask__c projectTask = New ProjectTask__c(Id=taskId);
        projectTask.Status__c = 'In Progress';
        projectTask.Formatted_Status__c = 'inprogress';
        projectTask.Assigned_To__c = UserInfo.getUserId();
        Date thisDay = Date.today();
        projectTask.Start_Date__c = thisDay;
        update projectTask;
    }
    
    @AuraEnabled
    public static void doAssignToMe(Id taskId){
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Assigned_To__c'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }        
        
        ProjectTask__c projectTask = New ProjectTask__c(Id=taskId);
        projectTask.Assigned_To__c = UserInfo.getUserId();
        update projectTask;
    }
    
    @AuraEnabled
    public static void doCompleteWork(Id taskId, Id sprintId, Id projectId){
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Blocked__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Time_Remaining__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Formatted_Status__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Resolution__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Resolved_Date__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.End_Date__c.isUpdateable() || 
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isUpdateable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        ProjectTask__c projectTask = [SELECT Id, Type__c FROM ProjectTask__c WHERE Id = :taskId];
        projectTask.Blocked__c = false;
        projectTask.Order__c = Null;
        projectTask.Time_Remaining__c = Null;
        Date thisDay = Date.today();
        projectTask.End_Date__c = thisDay;
        if (projectTask.Type__c == 'Bug') {
            projectTask.Status__c = 'Resolved';
            projectTask.Formatted_Status__c = 'resolved';
            projectTask.Resolution__c = 'Fixed';
            projectTask.Resolved_Date__c = thisDay;
        } else {
            projectTask.Status__c = 'Done';  
            projectTask.Formatted_Status__c = 'done';
            projectTask.Resolution__c = null;
            projectTask.Resolved_Date__c = null;
        }
        update projectTask;

        updateOrderCompletedPoints(projectId, sprintId);
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
    public static List<LookupSearchResult> sprintSearch(String searchTerm, List<String> selectedIds, String recStr) {   
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm = '%' + searchTerm + '%';
        Id recId = Id.valueOf(recStr);
        List<Sprint__c> sprints = [SELECT Id, Name, Sprint_Name__c
                                           FROM Sprint__c
                                           WHERE Sprint_Name__c LIKE :searchTerm
                                           AND Project__c = :recId
                                           AND Id NOT IN :selectedIds 
                                           ORDER BY Sprint_Name__c
                                           LIMIT 12];    
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        for (Sprint__c sprint : sprints) {
            results.add(new LookupSearchResult(sprint.Id, 'Sprint__c', 'standard:work_order', sprint.Sprint_Name__c, 'Sprint • ' + sprint.Name));
        }
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<LookupSearchResult> projectTaskSearch(String searchTerm, List<String> selectedIds, String recStr) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';
        Id recId = Id.valueOf(recStr);        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             ProjectTask__c (Id, Name, Task_Number__c, Title__c 
                                                                     WHERE Project__c = :recId                                      
                                                                     AND Id NOT IN :selectedIds 
                                                                     ORDER BY Task_Number__c)
                                             LIMIT 12];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        ProjectTask__c [] tasks = ((List<ProjectTask__c>) searchResults[0]);
        for (ProjectTask__c task : tasks) {
            results.add(new LookupSearchResult(task.Id, 'ProjectTask__c', 'standard:task', task.Task_Number__c, task.Title__c));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<Account> getRelatedAccount(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name
                FROM Account
                WHERE Id IN (SELECT Account__c FROM ProjectTask__c WHERE Id = :recId) 
                ORDER BY Name]; 
    }
    
    @AuraEnabled    
    public static List<LookupSearchResult> accountSearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             Account (Id, Name WHERE Id NOT IN :selectedIds ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            results.add(new LookupSearchResult(account.Id, 'Account', 'standard:account', account.Name, 'Account • ' + account.Id));
        }
        
        RETURN results;
    }
    
    // Project Task Tag Association - Get, Add, & Remove
    @AuraEnabled
    public static List<LookupSearchResult> tagSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Tag__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             Tag__c (Id, Name WHERE Id NOT IN :selectedIds AND For_ProjectTasks__c = True ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        Tag__c [] tags = ((List<Tag__c>) searchResults[0]);
        for (Tag__c tag : tags) {
            results.add(new LookupSearchResult(tag.Id, 'Tag__c', 'standard:topic', tag.Name, 'Tag • ' + tag.Name));
        }
        
        RETURN results;
    }    
    
    @AuraEnabled
    public static List<Tag__c> getProjectTaskTags(Id projectTaskId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Tag__c.isAccessible() || 
            !Schema.sObjectType.ProjectTaskTagAssoc__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name
                FROM Tag__c
                WHERE Id IN (SELECT Tag__c FROM ProjectTaskTagAssoc__c WHERE Project_Task__c = :projectTaskId) 
                ORDER BY Name]; 
    }
    
    @AuraEnabled
    public static ProjectTaskTagAssoc__c addProjectTaskTag(Id tagId, Id projectTaskId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Tag__c', 'Project_Task__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTaskTagAssoc__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        ProjectTaskTagAssoc__c item = new ProjectTaskTagAssoc__c();
        item.Tag__c = tagId;
        item.Project_Task__c = projectTaskId;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static ProjectTaskTagAssoc__c removeProjectTaskTag(Id tagId, Id projectTaskId) {
        // CRUD and FLS Enforcement
        if (!ProjectTaskTagAssoc__c.sObjectType.getDescribe().isAccessible() || !ProjectTaskTagAssoc__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<ProjectTaskTagAssoc__c> deleteMe = [SELECT Id FROM ProjectTaskTagAssoc__c 
                                                         WHERE Tag__c = :tagId AND Project_Task__c = :projectTaskId];
        delete deleteMe;
        RETURN null;
    } 
    
    @AuraEnabled
    public static List<Project__c> getDefaultProject(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, Title__c
                FROM Project__c
                WHERE Id = :recId
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static Id createCloneTask(Id recId, Id projectId) {   
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Accept__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Account__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Affected_Version__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Bug_Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Comments__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Components__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Dependencies__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Description__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Due_Date__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Fix_Version__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Formatted_Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Master_Task__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Points__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Priority__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Reported_By__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Reported_Date__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Time_Estimate__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.URL__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Value__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Version__c.isCreateable() ||
            !Schema.sObjectType.ProjectTaskTagAssoc__c.fields.Tag__c.isCreateable() ||
            !Schema.sObjectType.ProjectTaskTagAssoc__c.fields.Project_Task__c.isCreateable() ||            
            !Schema.sObjectType.Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        ProjectTask__c projectTask = [SELECT Title__c, Description__c, Type__c, Points__c, Reported_By__c, 
                                              Reported_Date__c, Swim_Lane__c, Value__c, Due_Date__c, Priority__c, 
                                              Bug_Type__c, Accept__c, Affected_Version__c, Time_Estimate__c, Version__c, 
                                              Fix_Version__c, Components__c, Dependencies__c, Comments__c, Project__c, 
                                              Master_Task__c, Account__c, URL__c
                                              FROM ProjectTask__c
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
        String titleStr = projectTask.Title__c;
        
        ProjectTask__c newProjectTask = new ProjectTask__c (
            Accept__c = projectTask.Accept__c,
            Account__c = projectTask.Account__c,
            Affected_Version__c = projectTask.Affected_Version__c,
            Bug_Type__c = projectTask.Bug_Type__c,
            Comments__c = projectTask.Comments__c,
            Components__c = projectTask.Components__c,
            Dependencies__c = projectTask.Dependencies__c,
            Description__c = projectTask.Description__c,
            Due_Date__c = projectTask.Due_Date__c,
            Fix_Version__c = projectTask.Fix_Version__c,
            Formatted_Status__c = 'open',
            Master_Task__c = projectTask.Master_Task__c,
            Order__c = nextOrderNumber,
            Points__c = projectTask.Points__c,
            Priority__c = projectTask.Priority__c,
            Project__c = projectId,
            Reported_By__c = projectTask.Reported_By__c,
            Reported_Date__c = projectTask.Reported_Date__c,
            Status__c = 'Open',
            Swim_Lane__c = projectTask.Swim_Lane__c,
            Task_Number__c = projectAbbreviation + '-' + nextTaskNumber,
            Task_Number_Int__c = nextTaskNumber,
            Time_Estimate__c = projectTask.Time_Estimate__c,
            Title__c = titleStr.left(248) + ' (Copy)',
            Type__c = projectTask.Type__c,
            URL__c = projectTask.URL__c,
            Value__c = projectTask.Value__c,
            Version__c = projectTask.Version__c);  
        insert newProjectTask;    
        
        // create tag association
        List<ProjectTaskTagAssoc__c> projectTaskTagAssocList = [SELECT Tag__c, Project_Task__c                
                                                                        FROM ProjectTaskTagAssoc__c
                                                                        WHERE Project_Task__c = :recId];
        for (ProjectTaskTagAssoc__c projectTaskTagAssoc : projectTaskTagAssocList) {
            ProjectTaskTagAssoc__c newProjectTaskTagAssoc = new ProjectTaskTagAssoc__c (
                Tag__c = projectTaskTagAssoc.Tag__c,
                Project_Task__c = newProjectTask.Id);
            insert newProjectTaskTagAssoc;
        }
        RETURN newProjectTask.Id;
    }
    
    @AuraEnabled
    public static ProjectTask__c saveProjectTaskData(Id recId, Id oldSprintId) { 
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Time_Remaining__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Time_Remaining__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Time_Remaining__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Blocked__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Blocked__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Blocked__c.isUpdateable() ||
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isCreateable() ||
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isUpdateable() ||
            !Schema.sObjectType.Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        ProjectTask__c projectTaskData = [Select Id, Task_Number__c, Task_Number_Int__c, Project__c, Sprint__c,
                                                  Status__c, Order__c, Time_Remaining__c
                                                  From ProjectTask__c WHERE Id = :recId];
        Id projectId = projectTaskData.Project__c;
        Id sprintId = projectTaskData.Sprint__c;
                                                                
        // set task number if needed        
        if (projectTaskData.Task_Number_Int__c == null) {
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
            projectTaskData.Task_Number__c = projectAbbreviation + '-' + nextTaskNumber;
            projectTaskData.Task_Number_Int__c = nextTaskNumber;
        }
        
        // update sort order   
        if (projectTaskData.Status__c == 'Canceled' || projectTaskData.Status__c == 'Done' || projectTaskData.Status__c == 'Resolved') {
            projectTaskData.Blocked__c = false;
            projectTaskData.Order__c = null;
            projectTaskData.Time_Remaining__c = null;       
        } else {
            if (projectTaskData.Order__c == null) {                
                AggregateResult[] taskOrderTotal = [SELECT MAX(Order__c)lastNumber
                                                    FROM ProjectTask__c 
                                                    WHERE Project__c = :projectId];                 
                decimal lastOrderNumber = taskOrderTotal[0].get('lastNumber') == null ? 0 : (decimal)taskOrderTotal[0].get('lastNumber'); 
                decimal nextOrderNumber = lastOrderNumber + 1; 
                projectTaskData.Order__c = nextOrderNumber;
            }
        }        
        upsert projectTaskData;
        
        updateOrderCompletedPoints(projectId, sprintId);
                
        // sum the points of completed tasks in oldSprintId
        if (String.valueOf(sprintId) != String.valueOf(oldSprintId) && String.valueOf(oldSprintId) != null) {
            Sprint__c Sprnt2 = [SELECT Id, Completed_Points__c 
                                        FROM Sprint__c 
                                        WHERE Project__c = :projectId
                                        AND Id = :oldSprintId]; 
            if (Sprnt2 != null) {
                AggregateResult sprintTotal2 = [SELECT Sum(Points__c) completedPoints 
                                                FROM ProjectTask__c
                                                WHERE Project__c = :projectId 
                                                AND Sprint__c = :oldSprintId
                                                AND Status__c IN ('Resolved','Done')];
                Integer completedPointsValue2 = Integer.valueOf((sprintTotal2.get('completedPoints')));
                if (Sprnt2.Completed_Points__c != completedPointsValue2) {
                    Sprnt2.Completed_Points__c = completedPointsValue2;
                    update Sprnt2;
                }
            }
        }
       
        RETURN projectTaskData;
    }
    
    @AuraEnabled
    public static void updateOrderCompletedPoints(Id projectId, Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Order__c.isUpdateable() ||
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isUpdateable()) 
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        if (String.valueOf(projectId) != null) {
            // update sort order of all project tasks in batches of 1000
            Integer taskTotal = [SELECT Count()  
                                 FROM ProjectTask__c
                                 WHERE Project__c = :projectId
                                 AND Order__c != NULL];
            Integer loopTimes = (Integer)Math.ceil(taskTotal/1000.0);
            List<ProjectTask__c> newList = new List<ProjectTask__c>();
            decimal goodIndex = 1;
            for (Integer i = 0; i < loopTimes; i++) {
                Integer loopStart = i * 1000;
                Integer loopEnd = loopStart + 999;
                if (loopTimes == (i + 1) ) {
                    loopEnd = 999999;
                }
                list<ProjectTask__c> origList = [SELECT Id, Order__c 
                                                         FROM ProjectTask__c
                                                         WHERE Project__c = :projectId
                                                         AND Order__c >= :loopStart
                                                         AND Order__c <= :loopEnd
                                                         ORDER BY Order__c
                                                         LIMIT 2000];
                Integer arrayLength = origList.size();            
                for (Integer j = 0; j < arrayLength; j++) {
                    decimal thisOrder = origList[j].Order__c;
                    if (thisOrder != goodIndex) {
                        ProjectTask__c resultItem = new ProjectTask__c(Id=origList[j].Id);                
                        resultItem.Order__c = goodIndex;
                        newList.add(resultItem);    
                    } 
                    goodIndex += 1;
                }    
                update newList; 
                newList.clear();    
            }
            
            // sum the points of completed tasks
            if (String.valueOf(sprintId) != null) {
                Sprint__c Sprnt = [SELECT Id, Completed_Points__c 
                                           FROM Sprint__c 
                                           WHERE Project__c = :projectId
                                           AND Id = :sprintId]; 
                if (Sprnt != null) {
                    AggregateResult sprintTotal = [SELECT Sum(Points__c) completedPoints 
                                                   FROM ProjectTask__c
                                                   WHERE Project__c = :projectId 
                                                   AND Sprint__c = :sprintId
                                                   AND Status__c IN ('Resolved','Done')];
                    Integer completedPointsValue = Integer.valueOf((sprintTotal.get('completedPoints')));
                    if (Sprnt.Completed_Points__c != completedPointsValue) {
                        Sprnt.Completed_Points__c = completedPointsValue;
                        update Sprnt;
                    }
                }
            }
        }
    }
        
    @AuraEnabled
    public static void updateOrder(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Order__c.isUpdateable()) 
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        if (String.valueOf(projectId) != null) {
            // update sort order of all project tasks in batches of 1000
            Integer taskTotal = [SELECT Count()  
                                 FROM ProjectTask__c
                                 WHERE Project__c = :projectId
                                 AND Order__c != NULL];
            Integer loopTimes = (Integer)Math.ceil(taskTotal/1000.0);
            List<ProjectTask__c> newList = new List<ProjectTask__c>();
            decimal goodIndex = 1;
            for (Integer i = 0; i < loopTimes; i++) {
                Integer loopStart = i * 1000;
                Integer loopEnd = loopStart + 999;
                if (loopTimes == (i + 1) ) {
                    loopEnd = 999999;
                }
                list<ProjectTask__c> origList = [SELECT Id, Order__c 
                                                         FROM ProjectTask__c
                                                         WHERE Project__c = :projectId
                                                         AND Order__c >= :loopStart
                                                         AND Order__c <= :loopEnd
                                                         ORDER BY Order__c
                                                         LIMIT 2000];
                Integer arrayLength = origList.size();            
                for (Integer j = 0; j < arrayLength; j++) {
                    decimal thisOrder = origList[j].Order__c;
                    if (thisOrder != goodIndex) {
                        ProjectTask__c resultItem = new ProjectTask__c(Id=origList[j].Id);                
                        resultItem.Order__c = goodIndex;
                        newList.add(resultItem);    
                    } 
                    goodIndex += 1;
                }    
                update newList; 
                newList.clear();    
            }
        }
    }
    
    @AuraEnabled
    public static void doChatterFeedPost(FeedItem newPost) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Id.isAccessible() || 
            !Schema.sObjectType.FeedItem.isCreateable() || 
            !Schema.sObjectType.FeedItem.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        } 
        
        insert newPost;
    }
    
    @AuraEnabled
    public static void doMoveProjectTask(Id recId, Id projectId) { 
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Master_Task__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Master_Task__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Master_Task__c.isUpdateable() ||            
            !Schema.sObjectType.ProjectTask__c.fields.Swim_Lane__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Swim_Lane__c.isUpdateable() ||            
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Points__c.isAccessible() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isAccessible() || 
            !Schema.sObjectType.Project__c.fields.Project_Abbreviation__c.isAccessible() ||  
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isCreateable() ||
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isUpdateable() ||
            !Schema.sObjectType.Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        } 
        
        ProjectTask__c projectTaskData = [Select Id, Status__c, Sprint__c, Order__c
                                                  From ProjectTask__c WHERE Id = :recId];
        Id oldSprintId = projectTaskData.Sprint__c;
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
                
        ProjectTask__c projectTask = New ProjectTask__c(Id=recId);
        projectTask.Master_Task__c = null;
        projectTask.Project__c = projectId;
        projectTask.Sprint__c = null;
        projectTask.Swim_Lane__c = null;
        projectTask.Task_Number__c = projectAbbreviation + '-' + nextTaskNumber;
        projectTask.Task_Number_Int__c = nextTaskNumber;           
        
        // update sort order   
        if (projectTaskData.Status__c == 'Canceled' || projectTaskData.Status__c == 'Done' || projectTaskData.Status__c == 'Resolved') {
            projectTask.Order__c = null;      
        } else {              
            AggregateResult[] taskOrderTotal = [SELECT MAX(Order__c)lastNumber
                                                FROM ProjectTask__c 
                                                WHERE Project__c = :projectId];                 
            decimal lastOrderNumber = taskOrderTotal[0].get('lastNumber') == null ? 0 : (decimal)taskOrderTotal[0].get('lastNumber'); 
            decimal nextOrderNumber = lastOrderNumber + 1; 
            projectTask.Order__c = nextOrderNumber;
        } 
        update projectTask;
        
        // sum the points of completed tasks in oldSprintId
        if (String.valueOf(oldSprintId) != null) {
            Sprint__c Sprnt2 = [SELECT Id, Completed_Points__c 
                                        FROM Sprint__c 
                                        WHERE Id = :oldSprintId]; 
            if (Sprnt2 != null) {
                AggregateResult sprintTotal2 = [SELECT Sum(Points__c) completedPoints 
                                                FROM ProjectTask__c
                                                WHERE Sprint__c = :oldSprintId
                                                AND Status__c IN ('Resolved','Done')];
                Integer completedPointsValue2 = Integer.valueOf((sprintTotal2.get('completedPoints')));
                if (Sprnt2.Completed_Points__c != completedPointsValue2) {
                    Sprnt2.Completed_Points__c = completedPointsValue2;
                    update Sprnt2;
                }
            }
        }
    }
    
    @AuraEnabled
    public static Boolean checkChatterEnabled() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('FeedItem');
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
