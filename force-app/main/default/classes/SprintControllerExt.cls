public with sharing class SprintControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    public class PagedResult {        
        @AuraEnabled
        public Integer pageSize { get;set; }        
        @AuraEnabled
        public Integer page { get;set; }        
        @AuraEnabled
        public Integer total { get;set; }        
        @AuraEnabled
        public List<ProjectTask__c> items { get;set; }        
    }
    
    public class Filter {        
        @AuraEnabled
        public String searchKey { get;set; }        
        @AuraEnabled
        public String typeKey { get;set; }       
    }
    
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }   
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.Sprint__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<Sprint__c> getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Project__r.Title__c, Sprint_Number__c FROM Sprint__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<Sprint__c> getEndDate(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT End_Date__c FROM Sprint__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM Sprint__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM Sprint__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
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
                WHERE Id IN (SELECT Project__c FROM Sprint__c WHERE Id = :recId)
                LIMIT 1]; 
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
    public static List<Sprint__c> getDefaultFields(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Sprint_Length__c, Work_Days_Report__c, Target_Points__c, Version__c, End_Date__c
                FROM Sprint__c
                WHERE Project__c = :recId
                ORDER BY CreatedDate DESC
                LIMIT 1]; 
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
    public static List<String> getStatuses() {
        Schema.DescribeFieldResult result = ProjectTask__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getTypeKeys() {
        Schema.DescribeFieldResult result = ProjectTask__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }    
    
    @AuraEnabled
    public static PagedResult getProjectTasks(String filters, Decimal pageSize, Decimal pageNumber, Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, SprintControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String key = '%' + filter.searchKey + '%';
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        r.total = [SELECT count() FROM ProjectTask__c
                   WHERE Project__c IN (SELECT Project__c FROM Sprint__c WHERE Id = :sprintId)
                   AND Sprint__c = ''
                   AND Status__c NOT IN ('Canceled','Resolved','Done')
                   AND Title__c LIKE :key
                   AND Type__c like : (filter.typeKey  == '' ? '%' : filter.typeKey )];
        r.items = [SELECT Id, Swim_Lane__r.Name, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c, 
                   Status__c, Points__c, Assigned_To__r.Name, Blocked__c, Project__c, Formatted_Status__c 
                   FROM ProjectTask__c
                   WHERE Project__c IN (SELECT Project__c FROM Sprint__c WHERE Id = :sprintId)
                   AND Sprint__c = ''
                   AND Status__c NOT IN ('Canceled','Resolved','Done')
                   AND Title__c LIKE :key
                   AND Type__c like : (filter.typeKey  == '' ? '%' : filter.typeKey )
                   ORDER BY Order__c, Task_Number_Int__c, Title__c
                   LIMIT :pSize OFFSET :offset];
        RETURN r;
    }  
    
    @AuraEnabled
    public static List<ProjectTask__c> getSprintTaskItems(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Swim_Lane__c, Swim_Lane__r.Title__c, Task_Number_Int__c, Task_Number__c, Title__c, 
                Formatted_Type__c, Status__c, Points__c, Assigned_To__c, Assigned_To__r.Name, Blocked__c, 
                Project__c, Formatted_Status__c
                FROM ProjectTask__c
                WHERE Sprint__c = :sprintId
                AND Project__c IN (SELECT Project__c FROM Sprint__c WHERE Id = :sprintId)
                ORDER BY Order__c NULLS LAST, Task_Number_Int__c, Title__c];        
    }
    
    @AuraEnabled
    public static ProjectTask__c updateSprintTaskItem(Id sprintTaskId, Id sprintId, String doAction) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.fields.Status__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Formatted_Status__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Assigned_To__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Start_Date__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Resolution__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Resolved_Date__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Project__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Sprint__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Blocked__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.End_Date__c.isUpdateable() ||  
            !Schema.sObjectType.ProjectTask__c.fields.Order__c.isUpdateable() || 
            !Schema.sObjectType.ProjectTask__c.fields.Time_Remaining__c.isUpdateable() || 
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isUpdateable() ||             
            !Schema.sObjectType.Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        ProjectTask__c projectTask = [SELECT Id, Type__c, Status__c, Project__c, Sprint__c 
                                              FROM ProjectTask__c WHERE Id = :sprintTaskId];
        Date thisDay = Date.today();
        List<String> sprintIds = new List<String>();  
        if (projectTask.Sprint__c != null) {
            sprintIds.add(String.valueOf(projectTask.Sprint__c));
        }
        if (sprintId != null) {
            if (sprintIds.indexOf(String.valueOf(sprintId)) < 0) {
                sprintIds.add(String.valueOf(sprintId));
            }
        }
        
        if (doAction == 'Start') {
            if (projectTask.Status__c == 'Open') {
                projectTask.Status__c = 'In Progress';
                projectTask.Formatted_Status__c = 'inprogress';
                projectTask.Assigned_To__c = UserInfo.getUserId();
                projectTask.Start_Date__c = thisDay;      
                update projectTask;
            }
        } else if (doAction == 'Complete') {
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
            projectTask.Blocked__c = false;
            projectTask.End_Date__c = thisDay;
            projectTask.Order__c = Null;
            projectTask.Time_Remaining__c = Null;
            update projectTask;            
        } else if (doAction == 'Remove') {
            projectTask.Sprint__c = null;      
            update projectTask;
        } else if (doAction == 'AddItem') {
            projectTask.Sprint__c = sprintId;        
            update projectTask;
        }
        
        if (doAction == 'Complete') {
            // update sort order of all project tasks in batches of 1000
            Id projectId = projectTask.Project__c;
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
        
        // update sprint completed field
        if (doAction == 'Complete' || doAction == 'Remove') {
            for (Integer i = 0; i < sprintIds.size(); i++) {
                if (sprintIds[i] != '') {
                    // sum the points of completed tasks
                    Sprint__c Sprnt = [SELECT id, Completed_Points__c 
                                               FROM Sprint__c 
                                               WHERE Id = :sprintIds[i]]; 
                    AggregateResult taskTotal = [SELECT Sum(Points__c) completedPoints 
                                                 FROM ProjectTask__c
                                                 WHERE Sprint__c = :sprintIds[i]
                                                 AND Status__c IN ('Resolved','Done')];
                    Integer completedPointsValue = Integer.valueOf((taskTotal.get('completedPoints')));
                    if (Sprnt.Completed_Points__c != completedPointsValue) {
                        Sprnt.Completed_Points__c = completedPointsValue;
                        update Sprnt;
                    }
                }
            }     
        }
        RETURN projectTask;
    } 
    
    @AuraEnabled
    public static ProjectTask__c updateTaskSwimLane(Id sprintTaskId, Id swimLaneId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Swim_Lane__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        } 
        
        ProjectTask__c projectTask = [SELECT Id, Swim_Lane__c from ProjectTask__c WHERE Id = :sprintTaskId];
        projectTask.Swim_Lane__c = swimLaneId;        
        update projectTask;
        RETURN projectTask;
    }
    
    @AuraEnabled
    public static List<Sprint__c> getTargetPoints(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Target_Points__c FROM Sprint__c WHERE Id = :sprintId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<Sprint__c> getStartDate(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }        
        
        RETURN [SELECT Start_Date__c, End_Date__c, Sprint_Length__c, Target_Points__c, Work_Days_Report__c 
                FROM Sprint__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AggregateResult> getCompletedPoints(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT SUM(Points__c) points, End_Date__c 
                FROM ProjectTask__c 
                WHERE Status__c IN ('Resolved','Done')
                AND Sprint__c = :sprintId
                GROUP BY End_Date__c
                ORDER BY End_Date__c]; 
    }
    
    @AuraEnabled
    public static List<ProjectItem__c> getProjectSwimLanes(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.ProjectItem__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Title__c
                FROM ProjectItem__c
                WHERE Project__c IN (SELECT Project__c FROM Sprint__c WHERE Id = :recId)
                AND Type__c = 'Project Swim Lane'
                ORDER BY Title__c]; 
    }
    
    @AuraEnabled
    public static List<LookupSearchResult> getAssignedToList(Id recId) {
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT Assigned_To__c FROM ProjectTask__c WHERE Sprint__c = :recId)
                                     ORDER BY Name];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Assigned To'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static Boolean removeAccess(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Id userId = UserInfo.getUserId();
        Boolean hasRemoveAccess = false;
        List<Project__c> projects = [SELECT Id
                                             FROM Project__c
                                             WHERE Id IN (SELECT Project__c FROM Sprint__c WHERE Id = :recId)
                                             AND (Product_Owner__c = :userId OR Scrum_Master__c = :userId)
                                             LIMIT 1]; 
        if (projects.size() == 1) {
            hasRemoveAccess = true;
        }
        RETURN hasRemoveAccess;
    }
    
    @AuraEnabled
    public static void doCloseSprint(Id recId, FeedItem newPost, Boolean postChatter) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Id'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        }
        
        list<ProjectTask__c> taskList = [SELECT Id, Sprint__c 
                                                 FROM ProjectTask__c
                                                 WHERE Sprint__c = :recId
                                                 AND Status__c IN ('Open','In Progress','Ready to Test','Testing','Ready to Deploy')];
        for (ProjectTask__c task : taskList) {
            task.Sprint__c = null;
        }        
        update taskList; 
        if (postChatter == true) {
            insert newPost;
        }
    }
    
    @AuraEnabled
    public static Sprint__c updateSprintNumberCompletedPoints(Id projectId, Id sprintId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Sprint_Number__c', 'Completed_Points__c'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Sprint__c .fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable() || !m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        }
        
        Sprint__c tmpSprint = new Sprint__c();
        
        if (String.valueOf(projectId) != null) {
         
            // assign the next sprint number 
            if (String.valueOf(sprintId) == null) {
                list<Sprint__c> Sprnt = [SELECT Sprint_Number__c 
                                                 FROM Sprint__c 
                                                 WHERE Project__c = :projectId
                                                 ORDER BY Sprint_Number__c DESC LIMIT 1];                
                if(Sprnt.size() > 0) {
                    Integer nextSprintNumber = Integer.valueOf(Sprnt[0].Sprint_Number__c)+1;
                    tmpSprint.Sprint_Number__c = nextSprintNumber;
                } else {
                    tmpSprint.Sprint_Number__c = 1;
                } 
            }
            
            // sum the points of completed tasks
            if (String.valueOf(sprintId) != null) {
                Sprint__c Sprnt = [SELECT Id, Sprint_Number__c, Completed_Points__c 
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
                    tmpSprint.Completed_Points__c = completedPointsValue;
                    tmpSprint.Sprint_Number__c = Sprnt.Sprint_Number__c;
                }
            }
        }
        
        RETURN tmpSprint;
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
    public static List<Sprint__c> getCurrentSprint(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Project__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Number__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Length__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Target_Points__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Start_Date__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.End_Date__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Version__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Goal__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Name__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.What_went_well__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.What_did_not_go_well__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.What_can_we_do_different_next_time__c.isAccessible() ||
            !Schema.sObjectType.Project__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.Project__c.fields.Title__c.isAccessible() ||
            !ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        Date thisDay = Date.today();
        List<Sprint__c> currentSprint =  [SELECT Id, Name, Project__c, Project__r.Title__c, Sprint_Number__c, 
                                                  Sprint_Length__c, Target_Points__c, Completed_Points__c, Start_Date__c, 
                                                  End_Date__c, Version__c, Sprint_Goal__c, Sprint_Name__c, 
                                                  What_went_well__c, What_did_not_go_well__c, What_can_we_do_different_next_time__c
                                                  FROM Sprint__c 
                                                  WHERE Project__c = :projectId
                                                  AND Start_Date__c <= :thisDay AND (End_Date__c = null OR End_Date__c >= :thisDay)
                                                  ORDER BY Sprint_Number__c DESC LIMIT 1];
        if (currentSprint.size() == 0) {
            currentSprint =  [SELECT Id, Name, Project__c, Project__r.Title__c, Sprint_Number__c, 
                              Sprint_Length__c, Target_Points__c, Completed_Points__c, Start_Date__c, 
                              End_Date__c, Version__c, Sprint_Goal__c, Sprint_Name__c, 
                              What_went_well__c, What_did_not_go_well__c, What_can_we_do_different_next_time__c
                              FROM Sprint__c 
                              WHERE Project__c = :projectId
                              ORDER BY Sprint_Number__c DESC LIMIT 1];            
        }
        return currentSprint;
    }
    
    @AuraEnabled
    public static List<Sprint__c> getSprint(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Project__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Number__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Length__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Target_Points__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Completed_Points__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Start_Date__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.End_Date__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Version__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Goal__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.Sprint_Name__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.What_went_well__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.What_did_not_go_well__c.isAccessible() ||
            !Schema.sObjectType.Sprint__c.fields.What_can_we_do_different_next_time__c.isAccessible() ||
            !Schema.sObjectType.Project__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.Project__c.fields.Title__c.isAccessible() ||
            !ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        List<Sprint__c> sprint = new List<Sprint__c>();
        sprint =  [SELECT Id, Name, Project__c, Project__r.Title__c, Sprint_Number__c, 
                   Sprint_Length__c, Target_Points__c, Completed_Points__c, Start_Date__c, 
                   End_Date__c, Version__c, Sprint_Goal__c, Sprint_Name__c, 
                   What_went_well__c, What_did_not_go_well__c, What_can_we_do_different_next_time__c
                   FROM Sprint__c 
                   WHERE Id = :sprintId];
        return sprint;
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
}
