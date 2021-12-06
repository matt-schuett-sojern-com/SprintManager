public with sharing class ProjectControllerExt {
    
    private final static Integer MAX_RESULTS = 5; 
         
    public class ProjectAccess {        
        @AuraEnabled
        public Boolean hasReadAccess { get;set; }
        @AuraEnabled
        public Boolean hasEditAccess { get;set; }
        @AuraEnabled
        public Boolean hasDeleteAccess { get;set; }
        @AuraEnabled
        public Boolean hasTransferAccess { get;set; }
        @AuraEnabled
        public Boolean hasDeleteSprintTaskAccess { get;set; }      
    }
    
    // User record access
    @AuraEnabled
    public static ProjectAccess recordAccess(Id recId) {
        ProjectAccess result = new ProjectAccess();
        Id userId = UserInfo.getUserId();
        UserRecordAccess recordAccess = [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess 
                                         FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                                         LIMIT 1];               
        Integer permissionSetAssignment = [SELECT Count()
                                           FROM PermissionSetAssignment
                                           WHERE AssigneeId = :userId
                                           AND (PermissionSet.Name = 'Agoura_AddStandardUserDelete' OR PermissionSet.Name = 'Agoura_Admin')];        
        
        result.hasReadAccess = recordAccess.HasReadAccess;
        result.hasEditAccess = recordAccess.HasEditAccess;
        result.hasDeleteAccess = recordAccess.HasDeleteAccess;
        result.hasTransferAccess = recordAccess.HasTransferAccess;
        result.hasDeleteSprintTaskAccess = false;
        if (permissionSetAssignment > 0 && recordAccess.HasEditAccess) {
           result.hasDeleteSprintTaskAccess = true; 
        }    
        return result;
    }
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.Project__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    // Project Sharing - Get, Add, & Remove
    @AuraEnabled
    public static Project__Share addProjectSharingAccess(Id projectId, Id userId, String accessLevel) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'ParentId', 'UserOrGroupId', 'AccessLevel' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Project__Share.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        Project__Share item = new Project__Share();
        item.ParentId = projectId;
        item.UserOrGroupId = userId;
        item.AccessLevel = accessLevel;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static Project__Share removeProjectSharingAccess(Id projectId, Id userId) {
        // CRUD and FLS Enforcement
        if (!Project__Share.sObjectType.getDescribe().isAccessible() || !Project__Share.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<Project__Share> deleteMe = [SELECT Id FROM Project__Share WHERE ParentId = :projectId AND UserOrGroupId = :userId];
        delete deleteMe;
        RETURN null;
    }
    
    // Search methods
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
                                             Tag__c (Id, Name WHERE Id NOT IN :selectedIds AND For_Projects__c = True ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        Tag__c [] tags = ((List<Tag__c>) searchResults[0]);
        for (Tag__c tag : tags) {
            results.add(new LookupSearchResult(tag.Id, 'Tag__c', 'standard:topic', tag.Name, 'Tag • ' + tag.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<LookupSearchResult> ideaBoardSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             IdeaBoard__c (Id, Name, Title__c WHERE Id NOT IN :selectedIds ORDER BY Title__c)
                                             LIMIT :MAX_RESULTS];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        IdeaBoard__c [] ideas = ((List<IdeaBoard__c>) searchResults[0]);
        for (IdeaBoard__c idea : ideas) {
            results.add(new LookupSearchResult(idea.Id, 'IdeaBoard__c', 'standard:drafts', idea.Title__c, 'Idea Board • ' + idea.Name));
        }
        
        RETURN results;
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
    public static List<LookupSearchResult> userSearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             User (Id, Name, Title, SmallPhotoUrl WHERE Id NOT IN :selectedIds ORDER BY Name),
                                             Group (Id, Name WHERE Type = 'Regular' AND Id NOT IN :selectedIds ORDER BY Name)                                             
                                             LIMIT :MAX_RESULTS];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User • ' + user.Title));
        }
        
        Group [] groups = ((List<Group>) searchResults[1]);
        for (Group groupItem : groups) {
            results.add(new LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Group • ' + groupItem.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<Account> getRelatedAccount(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name
                FROM Account
                WHERE Id IN (SELECT Account__c FROM Project__c WHERE Id = :projectId) 
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
    
    // Project Tag Association - Get, Add, & Remove
    @AuraEnabled
    public static List<Tag__c> getProjectTags(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Tag__c.isAccessible() || 
            !Schema.sObjectType.ProjectTagAssociation__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name
                FROM Tag__c
                WHERE Id IN (SELECT Tag__c FROM ProjectTagAssociation__c WHERE Project__c = :projectId) 
                ORDER BY Name]; 
    }
    
    @AuraEnabled
    public static ProjectTagAssociation__c addProjectTag(Id tagId, Id projectId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Tag__c', 'Project__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTagAssociation__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        ProjectTagAssociation__c item = new ProjectTagAssociation__c();
        item.Tag__c = tagId;
        item.Project__c = projectId;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static ProjectTagAssociation__c removeProjectTag(Id tagId, Id projectId) {
        // CRUD and FLS Enforcement
        if (!ProjectTagAssociation__c.sObjectType.getDescribe().isAccessible() || !ProjectTagAssociation__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<ProjectTagAssociation__c> deleteMe = [SELECT Id FROM ProjectTagAssociation__c 
                                                           WHERE Tag__c = :tagId AND Project__c = :projectId];
        delete deleteMe;
        RETURN null;
    } 
    
    // Idea Project Association - Get, Add, & Remove
    @AuraEnabled
    public static List<IdeaBoard__c> getIdeaProjects(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.Project__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name, Title__c
                FROM IdeaBoard__c
                WHERE Id IN (SELECT Idea_Board__c FROM Project__c WHERE Id = :projectId)]; 
    } 
    
    // Project Users
    @AuraEnabled
    public static List<LookupSearchResult> getUsers(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible() || 
            !Schema.sObjectType.Project__Share.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT Executive_Sponsor__c FROM Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT Product_Owner__c FROM Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT Scrum_Master__c FROM Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults4 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT OwnerId FROM Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults5 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults6 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults7 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM Project__Share 
                                                  WHERE ParentId = :projectId AND AccessLevel = 'Read')
                                     ORDER BY Name];
        List<User> searchResults8 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM Project__Share 
                                                  WHERE ParentId = :projectId AND AccessLevel = 'Edit')
                                     ORDER BY Name];
        List<Group> searchResults9 = [SELECT Id, Name FROM Group
                                      WHERE Id IN (SELECT UserOrGroupId FROM Project__Share 
                                                   WHERE ParentId = :projectId AND AccessLevel = 'Read')
                                      ORDER BY Name];
        List<Group> searchResults10 = [SELECT Id, Name FROM Group
                                       WHERE Id IN (SELECT UserOrGroupId FROM Project__Share 
                                                    WHERE ParentId = :projectId AND AccessLevel = 'Edit')
                                       ORDER BY Name];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Executive Sponsor'));
        }
        for (User user : searchResults2) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Product Owner'));
        }
        for (User user : searchResults3) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Scrum Master'));
        }
        for (User user : searchResults4) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Owner'));
        }
        for (User user : searchResults5) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults6) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults7) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Read Access'));
        }
        for (User user : searchResults8) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Edit Access'));
        }
        for (Group groupItem : searchResults9) {
            results.add(new LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Read Access'));
        }
        for (Group groupItem : searchResults10) {
            results.add(new LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Edit Access'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static Project__c updateDocumentOwner(Id recId, Id userId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'OwnerId'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Project__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        Project__c item = [SELECT Id, OwnerId FROM Project__c WHERE Id = :recId];
        item.OwnerId = userId;
        update item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AggregateResult getUnassignedPoints(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Sum(Points__c) unassignedPoints 
                FROM ProjectTask__c
                WHERE Project__c = :projectId 
                AND Status__c NOT IN ('Done','Resolved','Canceled')
                AND Sprint__c = null]; 
    }
    
    @AuraEnabled
    public static List<Project__c> getProjectTitle(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Title__c, Project_Abbreviation__c, IsTemplate__c FROM Project__c WHERE Id = :projectId LIMIT 1];  
    }
    
    // related objects
    @AuraEnabled
    public static List<ProjectItem__c> getProjectGoals(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Title__c, Type__c, Start_Date__c, Target_Date__c, Progress__c, Comments__c
                FROM ProjectItem__c
                WHERE Project__c = :projectId 
                AND (Type__c = 'Project Goal' OR Type__c = 'Project Milestone')
                ORDER BY Target_Date__c ASC NULLS LAST, Start_Date__c ASC NULLS LAST, Title__c]; 
    }
    
    @AuraEnabled
    public static ProjectItem__c addGoal(Id projectId, String typeStr, String title, String startDate, String targetDate, String progress, String comments) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Project__c', 'Type__c', 'Title__c', 'Start_Date__c', 'Target_Date__c', 
            'Progress__c', 'Comments__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        ProjectItem__c item = new ProjectItem__c();
        item.Project__c = projectId;
        item.Type__c = typeStr;
        item.Title__c = title;
        if (typeStr == 'Project Goal' && String.isNotBlank(startDate)) {
            item.Start_Date__c = Date.valueOf(startDate);  
        }
        if (String.isNotBlank(targetDate)) {
            item.Target_Date__c = Date.valueOf(targetDate);  
        }
        if (String.isNotBlank(progress)) {
            Decimal progressDec = Decimal.valueOf(progress);
            item.Progress__c = progressDec;
        }  
        item.Comments__c = comments;
        insert item;
        return item;
    }
    
    @AuraEnabled
    public static ProjectItem__c removeProjectItem(Id recId) {
        // CRUD and FLS Enforcement
        if (!ProjectItem__c.sObjectType.getDescribe().isAccessible() || !ProjectItem__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }        
        
        List<ProjectItem__c> deleteMe = [SELECT Id FROM ProjectItem__c WHERE id = :recId];
        delete deleteMe;
        RETURN null;
    }
    
    @AuraEnabled
    public static List<ProjectItem__c> getProjectRisks(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Title__c, Probability__c, Impact__c, Status__c, Response__c
                FROM ProjectItem__c
                WHERE Project__c = :projectId 
                AND Type__c = 'Project Risk'
                ORDER BY Title__c]; 
    }
    
    @AuraEnabled
    public static ProjectItem__c addRisk(Id projectId, String title, String probability, String impact, String status, String response) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Type__c', 'Project__c', 'Title__c', 'Probability__c', 'Impact__c', 
            'Status__c', 'Response__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        ProjectItem__c item = new ProjectItem__c();
        item.Type__c = 'Project Risk';
        item.Project__c = projectId;
        item.Title__c = title;
        item.Probability__c = probability;
        item.Impact__c = impact;
        item.Status__c = status;
        item.Response__c = response;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static List<ProjectItem__c> getProjectStakeholders(Id projectId) {        
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Type__c, Swim_Lane__r.Title__c, RACI__c, User__r.Name, User__r.Title
                FROM ProjectItem__c
                WHERE Project__c = :projectId 
                AND (Type__c = 'Project Team Member' OR Type__c = 'Project Stakeholder')
                ORDER BY User__r.Name]; 
    }
    
    @AuraEnabled
    public static ProjectItem__c addStakeholder(Id projectId, String stakeholderType, Id userId, String raci, String swimLane, String grantAccess) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.User__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.RACI__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.Project__Share.fields.ParentId.isCreateable() ||
            !Schema.sObjectType.Project__Share.fields.UserOrGroupId.isCreateable() ||
            !Schema.sObjectType.Project__Share.fields.AccessLevel.isCreateable() ||
            !ProjectItem__c.sObjectType.getDescribe().isAccessible() || 
            !ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }  
        
        list<ProjectItem__c> itemList = [SELECT Id FROM ProjectItem__c
                                                 WHERE Project__c = :projectId
                                                 AND (Type__c = 'Project Stakeholder' OR Type__c = 'Project Team Member')
                                                 AND User__c = :userId];
        delete itemList;
        
        ProjectItem__c item = new ProjectItem__c();
        item.Title__c = userId;
        item.Project__c = projectId;
        item.Type__c = stakeholderType;
        item.User__c = userId;
        item.RACI__c = raci;
        if (swimLane == '') {
            item.Swim_Lane__c = null;
        } else {
            item.Swim_Lane__c = swimLane;
        }
        insert item;
        
        if (grantAccess == 'Read Access') {
            Project__Share shareItem = new Project__Share();
            shareItem.ParentId = projectId;
            shareItem.UserOrGroupId = userId;
            shareItem.AccessLevel = 'Read';
            insert shareItem;
        } else if (grantAccess == 'Edit Access') {
            Project__Share shareItem = new Project__Share();
            shareItem.ParentId = projectId;
            shareItem.UserOrGroupId = userId;
            shareItem.AccessLevel = 'Edit';
            insert shareItem;
        }
        RETURN item;
    }
    
    @AuraEnabled
    public static ProjectItem__c addSwimLane(Id projectId, String title) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Type__c', 'Project__c', 'Title__c' };
            Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        ProjectItem__c item = new ProjectItem__c();
        item.Type__c = 'Project Swim Lane';
        item.Project__c = projectId;
        item.Title__c = title;
        insert item;
        RETURN item;
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
    public static List<Sprint__c> getProjectSprints(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Sprint_Number__c, Target_Points__c, Completed_Points__c, Start_Date__c, End_Date__c,
                What_went_well__c, What_did_not_go_well__c, What_can_we_do_different_next_time__c
                FROM Sprint__c
                WHERE Project__c = :projectId
                ORDER BY Start_Date__c NULLS LAST, Sprint_Number__c];         
    }
    
    @AuraEnabled
    public static Sprint__c removeProjectSprint(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Sprint__c.sObjectType.getDescribe().isAccessible() || !Sprint__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }       
        
        List<Sprint__c> deleteMe = [SELECT Id FROM Sprint__c WHERE Id = :sprintId];
        delete deleteMe;
        RETURN null;
    }
    
    @AuraEnabled
    public static ProjectItem__c addLink(Id projectId, String title, String url, String ownerId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Type__c', 'Project__c', 'Title__c', 'URL__c', 'User__c' };
            Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        ProjectItem__c item = new ProjectItem__c();
        item.Type__c = 'Project Link';
        item.Project__c = projectId;
        item.Title__c = title;
        item.URL__c = url; 
        if (ownerId == '') {
            item.User__c = null;  
        } else {
            item.User__c = ownerId;  
        }
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static List<ProjectItem__c> getProjectLinks(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Title__c, URL__c, User__r.Name 
                FROM ProjectItem__c
                WHERE Project__c = :projectId 
                AND Type__c = 'Project Link'
                ORDER BY Title__c]; 
    }
    
    @AuraEnabled
    public static Id createCloneProject(Id recId, List<String> cloneWhat) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Idea_Board__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Mission_Statement__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Project_Abbreviation__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Executive_Sponsor__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Product_Owner__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Scrum_Master__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Product__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Deliverables__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.KPIs__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Value_Trackers__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Assumptions__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Constraints__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Comments__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Account__c.isCreateable() ||
            !Schema.sObjectType.Project__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Target_Date__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Progress__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Comments__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Probability__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Impact__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Response__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Description__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.URL__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.User__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.RACI__c.isCreateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTagAssociation__c.fields.Tag__c.isCreateable() ||
            !Schema.sObjectType.ProjectTagAssociation__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Description__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Points__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Reported_By__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Reported_Date__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Value__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Due_Date__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Priority__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Bug_Type__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Accept__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Affected_Version__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Time_Estimate__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Version__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Fix_Version__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Components__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Dependencies__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Comments__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Formatted_Status__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Task_Number__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Master_Task__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Account__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Swim_Lane__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.URL__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.URL__c.isUpdateable() ||
            !Schema.sObjectType.ProjectTaskTagAssoc__c.fields.Tag__c.isCreateable() ||
            !Schema.sObjectType.ProjectTaskTagAssoc__c.fields.Project_Task__c.isCreateable() ||
            !Schema.sObjectType.ProjectTask__c.fields.Master_Task__c.isUpdateable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        System.debug('Start Project Cloning'); 
        List<ProjectTask__c> newTaskList = new List<ProjectTask__c>();
        List<ProjectTask__c> newTaskList2 = new List<ProjectTask__c>();
        List<ProjectTagAssociation__c> newTagList = new List<ProjectTagAssociation__c>();
        List<ProjectItem__c> newItemList = new List<ProjectItem__c>();
        List<ProjectTaskTagAssoc__c> newProjectTaskTagAssocList = new List<ProjectTaskTagAssoc__c>();
        Map<Id, String> taskOldIdMap = new Map<Id, String>(); 
        Map<Id, String> taskNewIdMap = new Map<Id, String>(); 
        Map<Id, Id> taskIdMap = new Map<Id, Id>();   
        Map<Id, Id> swimLaneIdMap = new Map<Id, Id>();   
        
        Project__c project = [SELECT Title__c, Mission_Statement__c, Project_Abbreviation__c, Executive_Sponsor__c, 
                                      Product_Owner__c, Scrum_Master__c, Product__c, Deliverables__c, 
                                      KPIs__c, Value_Trackers__c, Assumptions__c, Constraints__c,
                                      Comments__c, Idea_Board__c, Account__c              
                                      FROM Project__c
                                      WHERE Id = :recId
                                      LIMIT 1];      
        String titleStr = project.Title__c;
        String abbreviationStr = project.Project_Abbreviation__c;  
        
        Project__c newProject = new Project__c (
            Title__c = titleStr.left(248) + ' (Copy)',
            Idea_Board__c = project.Idea_Board__c,
            Mission_Statement__c = project.Mission_Statement__c,
            Project_Abbreviation__c = abbreviationStr.left(16) + 'COPY',
            Executive_Sponsor__c = project.Executive_Sponsor__c,
            Product_Owner__c = project.Product_Owner__c,
            Scrum_Master__c = project.Scrum_Master__c,
            Product__c = project.Product__c,
            Deliverables__c = project.Deliverables__c,
            KPIs__c = project.KPIs__c,
            Value_Trackers__c = project.Value_Trackers__c,
            Assumptions__c = project.Assumptions__c,
            Constraints__c = project.Constraints__c,
            Comments__c = project.Comments__c,
            Account__c = project.Account__c,
            Status__c = 'Draft');  
        insert newProject;    
         
        // clone related objects
        for (String cloneWhatItem : cloneWhat) {
            List<ProjectItem__c> projectItemList = [SELECT Title__c, Type__c, Target_Date__c, Progress__c, Comments__c, 
                                                            User__c, Probability__c, Impact__c, Status__c, Response__c, 
                                                            Description__c, URL__c, Swim_Lane__c, RACI__c           
                                                            FROM ProjectItem__c
                                                            WHERE Project__c = :recId AND Type__c = :cloneWhatItem LIMIT 1000];   
            
            for (ProjectItem__c projectItem : projectItemList) {
                ProjectItem__c newProjectItem = new ProjectItem__c (
                    Title__c = projectItem.Title__c,
                    Type__c = projectItem.Type__c,
                    Target_Date__c = projectItem.Target_Date__c,
                    Progress__c = projectItem.Progress__c,
                    Comments__c = projectItem.Comments__c,
                    Probability__c = projectItem.Probability__c,
                    Impact__c = projectItem.Impact__c,
                    Status__c = projectItem.Status__c,
                    Response__c = projectItem.Response__c,
                    Description__c = projectItem.Description__c,
                    URL__c = projectItem.URL__c,
                    User__c = projectItem.User__c,
                    Swim_Lane__c = projectItem.Swim_Lane__c,
                    RACI__c = projectItem.RACI__c,
                    Project__c = newProject.Id);
                newItemList.add(newProjectItem); 
            }
            insert newItemList;
            for (Integer i = 0; i < projectItemList.size(); i++) {
                ProjectItem__c projectItem = projectItemList[i];
                ProjectItem__c newProjectItem = newItemList[i];
                if (projectItem.Type__c == 'Project Swim Lane') {
                    swimLaneIdMap.put(projectItem.Id,newProjectItem.Id); 
                }                
            }
            newItemList.clear();
        }
        
        if (cloneWhat.indexOf('Tags') >= 0) {
            List<ProjectTagAssociation__c> tagList = [SELECT Tag__c               
                                                              FROM ProjectTagAssociation__c
                                                              WHERE Project__c = :recId];
            for (ProjectTagAssociation__c tag : tagList) {
                ProjectTagAssociation__c newTag = new ProjectTagAssociation__c (
                    Tag__c = tag.Tag__c,
                    Project__c = newProject.Id);                    
                newTagList.add(newTag); 
            }
        }
        insert newTagList;
        
        if (cloneWhat.indexOf('Tasks') >= 0) {
            List<ProjectTaskTagAssoc__c> projectTaskTagAssocList = [SELECT Tag__c, Project_Task__c              
                                                                            FROM ProjectTaskTagAssoc__c
                                                                            WHERE Project_Task__c IN (SELECT Id FROM ProjectTask__c
                                                                                                              WHERE Project__c = :recId)];
            
            List<ProjectTask__c> taskList = [SELECT Id, Title__c, Description__c, Type__c, Points__c, Reported_By__c, 
                                                     Reported_Date__c, Value__c, Due_Date__c, Priority__c, Bug_Type__c, 
                                                     Accept__c, Affected_Version__c, Time_Estimate__c, Version__c, 
                                                     Fix_Version__c, Components__c, Dependencies__c, Comments__c, 
                                                     Task_Number_Int__c, Swim_Lane__c, Master_Task__c, Account__c, URL__c
                                                     FROM ProjectTask__c
                                                     WHERE Project__c = :recId
                                                     ORDER BY Order__c NULLS LAST, Task_Number_Int__c
                                                     LIMIT 1000];
            decimal goodIndex = 1;
            for (ProjectTask__c task : taskList) {
                ProjectTask__c newTask = new ProjectTask__c (
                    Title__c = task.Title__c,
                    Description__c = task.Description__c,
                    Type__c = task.Type__c,
                    Points__c = task.Points__c,
                    Reported_By__c = task.Reported_By__c,
                    Reported_Date__c = task.Reported_Date__c,
                    Value__c = task.Value__c,
                    Due_Date__c = task.Due_Date__c,
                    Priority__c = task.Priority__c,
                    Bug_Type__c = task.Bug_Type__c,
                    Accept__c = task.Accept__c,
                    Affected_Version__c = task.Affected_Version__c,
                    Time_Estimate__c = task.Time_Estimate__c,
                    Version__c = task.Version__c,
                    Fix_Version__c = task.Fix_Version__c,
                    Components__c = task.Components__c,
                    Dependencies__c = task.Dependencies__c,
                    Comments__c = task.Comments__c,
                    Status__c = 'Open',
                    Formatted_Status__c = 'open',
                    Task_Number_Int__c = goodIndex,                        
                    Task_Number__c = newProject.Project_Abbreviation__c + '-' + goodIndex,
                    Order__c = goodIndex,
                    Master_Task__c = task.Master_Task__c, // update later
                    Account__c = task.Account__c,
                    URL__c = task.URL__c,
                    Project__c = newProject.Id);
                
                if (task.Swim_Lane__c != null) {
                    for (Id key : swimLaneIdMap.keySet()) { 
                        if (task.Swim_Lane__c == key) {
                            newTask.Swim_Lane__c = swimLaneIdMap.get(key);
                        }
                    }
                } 
                newTaskList.add(newTask);               
                goodIndex += 1;
            } 
            insert newTaskList;
            for (Integer i = 0; i < taskList.size(); i++) {
                ProjectTask__c task = taskList[i];
                ProjectTask__c newTask = newTaskList[i];
                taskIdMap.put(task.Id,newTask.Id); 
                
                // create tag association
                for (ProjectTaskTagAssoc__c projectTaskTagAssoc : projectTaskTagAssocList) {
                    if (task.Id == projectTaskTagAssoc.Project_Task__c) {
                        ProjectTaskTagAssoc__c newProjectTaskTagAssoc = new ProjectTaskTagAssoc__c (
                            Tag__c = projectTaskTagAssoc.Tag__c,
                            Project_Task__c = newTask.Id);
                        newProjectTaskTagAssocList.add(newProjectTaskTagAssoc);
                    }                    
                }
            }            
            insert newProjectTaskTagAssocList; 
            
            // update Master Task ids
            for (ProjectTask__c task : newTaskList) {                 
                for (Id key : taskIdMap.keySet()) { 
                    if (task.Master_Task__c == key) {
                        task.Master_Task__c = taskIdMap.get(key);
                        newTaskList2.add(task);
                    }
                }
            } 
            update newTaskList2;              
        }
        
        RETURN newProject.Id;
    }
    
    @AuraEnabled
    public static void doChatterFeedPost(FeedItem newPost) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.fields.Id.isAccessible() || 
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
    public static void updateProjectTaskAbbreviation(Id projectId, String projectAbbrev) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Task_Number__c'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        } 
        
        Integer taskTotal = [SELECT Count()  
                             FROM ProjectTask__c
                             WHERE Project__c = :projectId];
        Integer loopTimes = (Integer)Math.ceil(taskTotal/1000.0);
        List<ProjectTask__c> newList = new List<ProjectTask__c>();
        for (Integer i = 0; i < loopTimes; i++) {
            Integer loopStart = i * 1000;
            Integer loopEnd = loopStart + 999;
            if (loopTimes == (i + 1) ) {
                loopEnd = 999999;
            }
            list<ProjectTask__c> origList = [SELECT Id, Task_Number_Int__c 
                                                     FROM ProjectTask__c
                                                     WHERE Project__c = :projectId
                                                     AND Task_Number_Int__c >= :loopStart
                                                     AND Task_Number_Int__c <= :loopEnd
                                                     ORDER BY Task_Number_Int__c
                                                     LIMIT 2000];
            Integer arrayLength = origList.size();            
            for (Integer j = 0; j < arrayLength; j++) {
                ProjectTask__c resultItem = new ProjectTask__c(Id=origList[j].Id);                
                resultItem.Task_Number__c = projectAbbrev + '-' + origList[j].Task_Number_Int__c;
                newList.add(resultItem); 
            }
            update newList; 
            newList.clear(); 
        }       
    } 
    
    @AuraEnabled
    public static void updateProjectStakeholders(Id projectId, Id execSponsorId, Id productOwnerId, Id docOwnerId, Id scrumMasterId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.fields.Project__c.isCreateable() || 
            !Schema.sObjectType.ProjectItem__c.fields.Project__c.isUpdateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Type__c.isCreateable() || 
            !Schema.sObjectType.ProjectItem__c.fields.Type__c.isUpdateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.Title__c.isCreateable() || 
            !Schema.sObjectType.ProjectItem__c.fields.Title__c.isUpdateable() ||
            !Schema.sObjectType.ProjectItem__c.fields.User__c.isCreateable() || 
            !Schema.sObjectType.ProjectItem__c.fields.User__c.isUpdateable() ||    
            !ProjectItem__c.sObjectType.getDescribe().isAccessible() || 
            !ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        // update project stakeholders as needed
        list<ProjectItem__c> existList = [SELECT Id, Type__c, User__c
                                                  FROM ProjectItem__c
                                                  WHERE Project__c = :projectId
                                                  AND Type__c IN ('Executive Sponsor', 'Project Document Owner', 'Product Owner', 'Scrum Master')
                                                  ORDER BY Type__C];
        list<Id> deleteList = new list<Id>();
        list<ProjectItem__c> upsertList = new list<ProjectItem__c>(); 
        boolean foundIt;        
        
        if (execSponsorId != null) {
            upsertList.add(new ProjectItem__c(Project__c=projectId, Type__c='Executive Sponsor',
                                                      Title__c='Executive Sponsor', User__c=execSponsorId));
        }
        if (docOwnerId != null) {
            upsertList.add(new ProjectItem__c(Project__c=projectId ,Type__c='Project Document Owner',
                                                      Title__c='Project Document Owner', User__c=docOwnerId));
        }
        if (productOwnerId != null) {
            upsertList.add(new ProjectItem__c(Project__c=projectId, Type__c='Product Owner',
                                                      Title__c='Product Owner', User__c=productOwnerId));
        }
        if (scrumMasterId != null) {
            upsertList.add(new ProjectItem__c(Project__c=projectId, Type__c='Scrum Master',
                                                      Title__c='Scrum Master', User__c=scrumMasterId));
        }
     
        // update as needed
        for (ProjectItem__c item1 : upsertList) {
            for (ProjectItem__c item2 : existList) {
                if (item2.Type__c == item1.Type__c) {  
                    item1.Id = item2.Id;               
                }
            }
        }        
        
        // delete as needed
        for (ProjectItem__c item2 : existList) {
            foundIt = false;
            for (ProjectItem__c item1 : upsertList) {
                if (item2.Type__c == item1.Type__c) {  
                    foundIt = true;              
                }
            }
            if (foundIt == false) {
                deleteList.add(item2.Id);
            }
        }
        
        upsert upsertList;
        List<ProjectItem__c> deleteMe = [SELECT Id FROM ProjectItem__c WHERE Id IN :deleteList];
        delete deleteMe;      
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
    
    @AuraEnabled        
    public static Map<String, String> getFieldHelpMap(String objectName, List<String> fieldList){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        for(String  fieldName : fieldList) {                 
            fieldLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getInlineHelpText());                
        }
        return fieldLabelMap;
    }
  
    @AuraEnabled
    public static Map<String, Integer> getNumRecords(Id recId) {
        return specialClass.getAllNumRecords(recId);
    }
}
