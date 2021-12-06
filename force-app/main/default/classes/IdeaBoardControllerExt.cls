public with sharing class IdeaBoardControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
        
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.IdeaBoard__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    // Search methods
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> tagSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Tag__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             Tag__c (Id, Name WHERE id NOT IN :selectedIds AND For_IdeaBoards__c = True ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        Tag__c [] tags = ((List<Tag__c>) searchResults[0]);
        for (Tag__c tag : tags) {
            results.add(new AgouraFree.LookupSearchResult(tag.Id, 'Tag__c', 'standard:topic', 
                                                      tag.Name, 'Tag • ' + tag.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> userSearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             User (Id, Name, Title, SmallPhotoUrl WHERE Id NOT IN :selectedIds ORDER BY Name),
                                             Group (Id, Name WHERE Type = 'Regular' AND Id NOT IN :selectedIds ORDER BY Name)                                             
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User • ' + user.Title));
        }
        
        Group [] groups = ((List<Group>) searchResults[1]);
        for (Group groupItem : groups) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Group • ' + groupItem.Name));
        }
        
        RETURN results;
    }
    
    // Idea Tag Association - Get, Add, & Remove
    @AuraEnabled
    public static List<Tag__c> getIdeaTags(Id ideaId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Tag__c.isAccessible() ||
            !Schema.sObjectType.IdeaTagAssociation__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        
        RETURN [SELECT Id, Name
                FROM Tag__c
                WHERE Id IN (SELECT Tag__c FROM IdeaTagAssociation__c WHERE Idea_Board__c = :ideaId)
                AND For_IdeaBoards__c = True
                ORDER BY Name]; 
    }
    
    @AuraEnabled
    public static IdeaTagAssociation__c addIdeaTag(Id tagId, Id ideaId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Tag__c', 'Idea_Board__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.IdeaTagAssociation__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        IdeaTagAssociation__c item = new IdeaTagAssociation__c();
        item.Tag__c = tagId;
        item.Idea_Board__c = ideaId;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static IdeaTagAssociation__c removeIdeaTag(Id tagId, Id ideaId) {
        // CRUD and FLS Enforcement
        if (!IdeaTagAssociation__c.sObjectType.getDescribe().isAccessible() || !IdeaTagAssociation__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<IdeaTagAssociation__c> deleteMe = [SELECT Id FROM IdeaTagAssociation__c WHERE Tag__c = :tagId AND Idea_Board__c = :ideaId];
        delete deleteMe;
        RETURN null;
    } 
    
    // Idea Project Association 
    @AuraEnabled
    public static List<sObject> getIdeaProjects(Id ideaId) {
        Boolean hasProjects = hasProjectObject();
        List<sObject> results = new List<sObject>();
        
        if (hasProjects) {
            // CRUD and FLS Enforcement
            if (!Schema.sObjectType.Project__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
            
            results= [SELECT Id, Name, Title__c
                      FROM Project__c
                      WHERE Idea_Board__c = :ideaId 
                      ORDER BY Title__c];  
        } 
        return results;        
    }
    
    // Idea Board Sharing - Get, Add, & Remove
    @AuraEnabled
    public static IdeaBoard__Share addIdeaSharingAccess(Id ideaId, Id userId, String accessLevel) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'ParentId', 'UserOrGroupId', 'AccessLevel' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.IdeaBoard__Share.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        IdeaBoard__Share item = new IdeaBoard__Share();
        item.ParentId = ideaId;
        item.UserOrGroupId = userId;
        item.AccessLevel = accessLevel;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static IdeaBoard__Share removeIdeaSharingAccess(Id ideaId, Id userId) {
        // CRUD and FLS Enforcement
        if (!IdeaBoard__Share.sObjectType.getDescribe().isAccessible() || !IdeaBoard__Share.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        List<IdeaBoard__Share> deleteMe = [SELECT Id FROM IdeaBoard__Share WHERE ParentId = :ideaId AND UserOrGroupId = :userId];
        delete deleteMe;
        RETURN null;
    } 
    
    // User record access
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }
    
    // Idea Board Users
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id ideaId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.IdeaBoard__Share.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT OwnerId FROM IdeaBoard__c WHERE Id = :ideaId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM IdeaBoard__c WHERE Id = :ideaId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM IdeaBoard__c WHERE Id = :ideaId)
                                     ORDER BY Name];
        List<User> searchResults4 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM IdeaBoard__Share 
                                                  WHERE ParentId = :ideaId AND AccessLevel = 'Read')
                                     ORDER BY Name];
        List<User> searchResults5 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM IdeaBoard__Share 
                                                  WHERE ParentId = :ideaId AND AccessLevel = 'Edit')
                                     ORDER BY Name];
        List<Group> searchResults6 = [SELECT Id, Name FROM Group
                                      WHERE Id IN (SELECT UserOrGroupId FROM IdeaBoard__Share 
                                                   WHERE ParentId = :ideaId AND AccessLevel = 'Read')
                                      ORDER BY Name];
        List<Group> searchResults7 = [SELECT Id, Name FROM Group
                                      WHERE Id IN (SELECT UserOrGroupId FROM IdeaBoard__Share 
                                                   WHERE ParentId = :ideaId AND AccessLevel = 'Edit')
                                      ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Owner'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults4) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Read Access'));
        }
        for (User user : searchResults5) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Edit Access'));
        }
        for (Group groupItem : searchResults6) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Read Access'));
        }
        for (Group groupItem : searchResults7) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Edit Access'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<IdeaBoard__c> getIdeaBoardTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Title__c FROM IdeaBoard__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static Id createCloneIdeaBoard(Id recId) {                      
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.fields.Title__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Problem__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Existing_Alternatives__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Solution__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Key_Metrics__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Unique_Value_Proposition__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.High_Level_Concept__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Unfair_Advantage__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Channels__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Customer_Segment__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Early_Adopters__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Cost_Structure__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Revenue_Streams__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Comments__c.isCreateable() ||
            !Schema.sObjectType.IdeaBoard__c.fields.Status__c.isCreateable() ||
            !Schema.sObjectType.IdeaTagAssociation__c.fields.Tag__c.isCreateable() ||
            !Schema.sObjectType.IdeaTagAssociation__c.fields.Idea_Board__c.isCreateable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }   
        
        IdeaBoard__c ideaBoard = [SELECT Title__c, Problem__c, Existing_Alternatives__c, Solution__c, Key_Metrics__c, 
                                          Unique_Value_Proposition__c, High_Level_Concept__c, Unfair_Advantage__c, Channels__c,
                                          Customer_Segment__c, Early_Adopters__c, Cost_Structure__c, Revenue_Streams__c, 
                                          Comments__c
                                          FROM IdeaBoard__c
                                          WHERE Id = :recId
                                          LIMIT 1];
        String titleStr = ideaBoard.Title__c;
        
        IdeaBoard__c newIdeaBoard = new IdeaBoard__c (
            Title__c = titleStr.left(248) + ' (Copy)',
            Problem__c = ideaBoard.Problem__c,
            Existing_Alternatives__c = ideaBoard.Existing_Alternatives__c,
            Solution__c = ideaBoard.Solution__c,
            Key_Metrics__c = ideaBoard.Key_Metrics__c,
            Unique_Value_Proposition__c = ideaBoard.Unique_Value_Proposition__c,
            High_Level_Concept__c = ideaBoard.High_Level_Concept__c,
            Unfair_Advantage__c = ideaBoard.Unfair_Advantage__c,
            Channels__c = ideaBoard.Channels__c,
            Customer_Segment__c = ideaBoard.Customer_Segment__c,
            Early_Adopters__c = ideaBoard.Early_Adopters__c,
            Cost_Structure__c = ideaBoard.Cost_Structure__c,
            Revenue_Streams__c = ideaBoard.Revenue_Streams__c,
            Comments__c = ideaBoard.Comments__c,
            Status__c = 'Draft'
        );  
        insert newIdeaBoard;    
        
        // create tag association
        List<IdeaTagAssociation__c> tagAssocList = [SELECT Tag__c                
                                                            FROM IdeaTagAssociation__c
                                                            WHERE Idea_Board__c = :recId];
        
        for (IdeaTagAssociation__c tagAssoc : tagAssocList) {
            IdeaTagAssociation__c newTagAssoc = new IdeaTagAssociation__c (
                Tag__c = tagAssoc.Tag__c,
                Idea_Board__c = newIdeaBoard.Id);
            insert newTagAssoc;
        }
        RETURN newIdeaBoard.Id;
    }
    
    @AuraEnabled
    public static IdeaBoard__c updateDocumentOwner(Id recId, Id userId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'OwnerId'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.IdeaBoard__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        IdeaBoard__c item = [SELECT Id, OwnerId FROM IdeaBoard__c WHERE Id = :recId];
        item.OwnerId = userId;
        update item;
        RETURN item;
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
    public static Boolean hasProjectObject() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('Project__c');
    }
    
    @AuraEnabled
    public static Boolean checkChatterEnabled() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('FeedItem');
    }
    
    @AuraEnabled
    public static void doChatterFeedPost(FeedItem newPost) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.fields.Id.isAccessible() || 
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
}
