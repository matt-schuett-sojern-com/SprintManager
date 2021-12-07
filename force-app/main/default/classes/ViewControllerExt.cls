public with sharing class ViewControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    public class PagedResult {        
        @AuraEnabled
        public Integer pageSize { get;set; }        
        @AuraEnabled
        public Integer page { get;set; }        
        @AuraEnabled
        public Integer total { get;set; }        
        @AuraEnabled
        public Integer ideaBoardTotal { get;set; }        
        @AuraEnabled
        public Integer projectTotal { get;set; }        
        @AuraEnabled
        public Integer sprintTotal { get;set; }        
        @AuraEnabled
        public Integer taskTotal { get;set; }        
        @AuraEnabled
        public List<ViewRecord> viewItems { get;set; }        
    }
    
    public class Filter {        
        @AuraEnabled
        public String searchKey { get;set; }        
        @AuraEnabled
        public String statusKey { get;set; }        
        @AuraEnabled
        public String assignedKey { get;set; }        
        @AuraEnabled
        public String rowKey { get;set; }         
    }  
    
    public class ObjectAccess {        
        @AuraEnabled
        public Boolean canCreateAnchorStory { get;set; }        
        @AuraEnabled
        public Boolean canCreateTag { get;set; }          
    } 
    
    @AuraEnabled
    public static List<String> getStatusKeys(String viewName) {
        List<String> values = new list <String>();
        List<String> uniqueValues = new list <String>();
        List<String> tempList = new list <String>();
        List<String> ignoreValues = new List<String>();
        Integer index = 0;
        
        if (viewName == 'Home') {
            Schema.DescribeFieldResult result1 = IdeaBoard__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            Schema.DescribeFieldResult result2 = Project__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> entries2 = result2.getPicklistValues();
            Schema.DescribeFieldResult result3 = ProjectTask__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> entries3 = result3.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                values.add(entry.getValue());
            } 
            
            for (Schema.PicklistEntry entry: entries2) {
                values.add(entry.getValue());
            } 
            
            for (Schema.PicklistEntry entry: entries3) {
                values.add(entry.getValue());
            }    
            ignoreValues.add('Approved');
            ignoreValues.add('Canceled');
            ignoreValues.add('Closed');
            ignoreValues.add('Done');
            ignoreValues.add('Resolved');
            
            // sort and remove duplicates
            values.sort();            
            for (String val: values) {               
                if (index > 0) {
                    if (val != values[index-1]) {
                        tempList.add(val);
                    }
                } else {
                    tempList.add(val);
                }
                index += 1;
            }            
            for (String val: tempList) {
                if(ignoreValues.indexOf(val) < 0) {                   
                    uniqueValues.add(val);              
                }
            }
        } else if (viewName == 'Idea Boards') {
            Schema.DescribeFieldResult result1 = IdeaBoard__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                uniqueValues.add(entry.getValue());
            }
        } else if (viewName == 'Project Tasks') {
            Schema.DescribeFieldResult result1 = ProjectTask__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                uniqueValues.add(entry.getValue());
            }
        } else if (viewName == 'Projects' || viewName == 'Project Templates') {
            Schema.DescribeFieldResult result1 = Project__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                uniqueValues.add(entry.getValue());
            }
        } else if (viewName == 'Sprints') {            
            uniqueValues.add('Closed');          
            uniqueValues.add('Open');
        }
        
        RETURN uniqueValues;
    }  
    
    @AuraEnabled
    public static PagedResult getHomeRecordList(String filters, Decimal pageSize, Decimal pageNumber) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.Project__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible() || 
            !Schema.sObjectType.ProjectItem__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, ViewControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String searchKey = '%' + filter.searchKey + '%';
        String statusKey = filter.statusKey;
        String assignedKey = filter.assignedKey;
        List<String> ignoreStatus = new List<String>();
        ignoreStatus.add('Approved');
        ignoreStatus.add('Canceled');
        ignoreStatus.add('Closed');
        ignoreStatus.add('Done');
        ignoreStatus.add('Resolved');
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        Id userId = UserInfo.getUserId();
        List<ViewRecord> homeResults = new List<ViewRecord>();
        Integer skipRecords = offset;   
        
        // set SOQL query strings
        String ideaBoardTotalQuery = 'SELECT count() FROM IdeaBoard__c WHERE Title__c LIKE :searchKey';
        String ideaBoardRecordQuery = 'SELECT Id, Name, Title__c, Status__c, CreatedDate, LastModifiedDate, UserRecordAccess.HasEditAccess ' +
            'FROM IdeaBoard__c  WHERE Title__c LIKE :searchKey';
        String projectTotalQuery = 'SELECT count() FROM Project__c ' +
            'WHERE Id IN (SELECT Project__c FROM ProjectItem__c WHERE User__c = :userId ' +
            'AND Type__c != \'Project Link\') ' +
            'AND Title__c LIKE :searchKey';
        String projectRecordQuery = 'SELECT Id, Name, Title__c, Status__c, CreatedDate, LastModifiedDate, UserRecordAccess.HasEditAccess ' +
            'FROM Project__c ' +
            'WHERE Id IN (SELECT Project__c FROM ProjectItem__c WHERE User__c = :userId AND Type__c != \'Project Link\') ' +
            'AND Title__c LIKE :searchKey';
        String sprintTotalQuery = 'SELECT count() FROM Sprint__c ' +
            'WHERE Start_Date__c <= today ' +
            'AND (End_Date__c = null or End_Date__c >= today) ' +
            'AND Project__c IN (SELECT Project__c FROM ProjectItem__c ' + 
            'WHERE User__c = :userId ' +    
            'AND Project__r.Title__c LIKE :searchKey ' +
            'AND Project__r.Status__c NOT IN :ignoreStatus ' +
            'AND Type__c != \'Project Link\')';
        String sprintRecordQuery = 'SELECT Id, Name, Project__r.Title__c, Sprint_Name__c, CreatedDate, LastModifiedDate, ' +
            'UserRecordAccess.HasEditAccess FROM Sprint__c ' +
            'WHERE Start_Date__c <= today ' +
            'AND (End_Date__c = null or End_Date__c >= today) ' +
            'AND Project__c IN ( ' +
            'SELECT Project__c FROM ProjectItem__c ' +
            'WHERE User__c = :userId ' +                    
            'AND Project__r.Title__c LIKE :searchKey ' +
            'AND Project__r.Status__c NOT IN :ignoreStatus ' +
            'AND Type__c != \'Project Link\')';
        String taskTotalQuery = 'SELECT count() FROM ProjectTask__c ' +
            'WHERE Title__c LIKE :searchKey ';
        String taskRecordQuery = 'SELECT Id, Name, Task_Number_Int__c, Task_Number__c, Title__c, Status__c, ' +
            'CreatedDate, LastModifiedDate, Project__r.Project_Abbreviation__c, UserRecordAccess.HasEditAccess ' +
            'FROM ProjectTask__c WHERE Title__c LIKE :searchKey';
        
        if (assignedKey != '') {
            ideaBoardTotalQuery += ' AND OwnerId = :userId';
            ideaBoardRecordQuery += ' AND OwnerId = :userId';
            taskTotalQuery += ' AND Assigned_To__c = :userId';
            taskRecordQuery += ' AND Assigned_To__c = :userId';
        } else {
            taskTotalQuery += ' AND (Assigned_To__c = :userId OR CreatedById = :userId)';
            taskRecordQuery += ' AND (Assigned_To__c = :userId OR CreatedById = :userId)';
        }
        if (statusKey  == '') {
            ideaBoardTotalQuery += ' AND Status__c NOT IN :ignoreStatus';
            ideaBoardRecordQuery += ' AND Status__c NOT IN :ignoreStatus';
            projectTotalQuery += ' AND Status__c NOT IN :ignoreStatus';
            projectRecordQuery += ' AND Status__c NOT IN :ignoreStatus';
            taskTotalQuery += ' AND Status__c NOT IN :ignoreStatus';
            taskRecordQuery += ' AND Status__c NOT IN :ignoreStatus';
        } else {
            ideaBoardTotalQuery += ' AND Status__c = :statusKey';  
            ideaBoardRecordQuery += ' AND Status__c = :statusKey';  
            projectTotalQuery += ' AND Status__c = :statusKey';  
            projectRecordQuery += ' AND Status__c = :statusKey';   
            taskTotalQuery += ' AND Status__c = :statusKey';     
            taskRecordQuery += ' AND Status__c = :statusKey';            
        }
        
        // perform SOQL queries
        r.ideaBoardTotal = Database.countQuery(ideaBoardTotalQuery);
        r.projectTotal = Database.countQuery(projectTotalQuery);
        if (statusKey == '' || statusKey == 'Open') {
            r.sprintTotal = Database.countQuery(sprintTotalQuery);
        } else {
            r.sprintTotal = 0;
        }
        r.taskTotal = Database.countQuery(taskTotalQuery);
        r.total = r.ideaBoardTotal + r.projectTotal + r.sprintTotal + r.taskTotal;
        
        skipRecords = skipRecords - r.ideaBoardTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            ideaBoardRecordQuery += ' ORDER BY Title__c LIMIT :pSize OFFSET :offset';
            List<IdeaBoard__c> ideaBoardList = Database.query(ideaBoardRecordQuery);   
            for (IdeaBoard__c ideaBoard : ideaBoardList) {
                homeResults.add(new ViewRecord(ideaBoard.Id, ideaBoard.Name, 'IdeaBoard__c', 'standard:drafts', 
                                               ideaBoard.Title__c, ideaBoard.Status__c, null, null, null,
                                               ideaBoard.CreatedDate, ideaBoard.LastModifiedDate, ideaBoard.UserRecordAccess.HasEditAccess));
            }
            pSize = pSize - ideaBoardList.size();
            offset = 0;
        } else {
            offset = offset - r.ideaBoardTotal;
        }
        
        skipRecords = skipRecords - r.projectTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            projectRecordQuery += ' ORDER BY Title__c LIMIT :pSize OFFSET :offset';
            List<Project__c> projectList = Database.query(projectRecordQuery);    
            for (Project__c project : projectList) {
                homeResults.add(new ViewRecord(project.Id, project.Name, 'Project__c', 'standard:drafts', 
                                               project.Title__c, project.Status__c, null, null, null, 
                                               project.CreatedDate, project.LastModifiedDate, project.UserRecordAccess.HasEditAccess));
            }
            pSize = pSize - projectList.size();
            offset = 0;
        } else {
            offset = offset - r.projectTotal;
        }
        
        skipRecords = skipRecords - r.sprintTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            if (statusKey == '' || statusKey == 'Open') {
                sprintRecordQuery += ' ORDER BY Sprint_Name__c LIMIT :pSize OFFSET :offset';
                List<Sprint__c> sprintList = Database.query(sprintRecordQuery);      
                for (Sprint__c sprint : sprintList) {
                    homeResults.add(new ViewRecord(sprint.Id, sprint.Name, 'Sprint__c', 'standard:work_order', 
                                                   sprint.Project__r.Title__c + ' ' + sprint.Sprint_Name__c, 'Open', null, null, null,
                                                   sprint.CreatedDate, sprint.LastModifiedDate, sprint.UserRecordAccess.HasEditAccess));
                }
                pSize = pSize - sprintList.size();
                offset = 0;
            } 
        } else {
            offset = offset - r.sprintTotal;
        }
        
        skipRecords = skipRecords - r.taskTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            taskRecordQuery += ' ORDER BY Project__r.Project_Abbreviation__c, Task_Number_Int__c LIMIT :pSize OFFSET :offset';
            List<ProjectTask__c> taskList = Database.query(taskRecordQuery);    
            for (ProjectTask__c task : taskList) {
                homeResults.add(new ViewRecord(task.Id, task.Name, 'ProjectTask__c', 'standard:task', 
                                               task.Task_Number__c + ' ' + task.Title__c, task.Status__c, 
                                               null, null, null, task.CreatedDate, task.LastModifiedDate, task.UserRecordAccess.HasEditAccess));
            }
        }  
                
        r.viewItems = homeResults;
        RETURN r;
    }
    
    @AuraEnabled
    public static User getUserInfo() {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT Name, Title, CompanyName, Phone, Email, MobilePhone FROM User WHERE Id = :userId LIMIT 1];
    }
    
    @AuraEnabled
    public static Organization getOrgInfo() {
        RETURN [SELECT Id FROM Organization LIMIT 1];
    }
    
    @AuraEnabled
    public static void sendFeedback(String mbody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'feedback@agourasoftware.com'}; 
            mail.setToAddresses(toAddresses);
        mail.setSubject('Agoura Feedback');
        mail.setPlainTextBody(mbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @AuraEnabled
    public static PagedResult getViewRecordList(String filters, Decimal pageSize, Decimal pageNumber, String viewName) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.Project__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible() || 
            !Schema.sObjectType.ProjectItem__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.Tag__c.isAccessible() || 
            !Schema.sObjectType.AnchorStory__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, ViewControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String searchTerm = filter.searchKey + '*';
        String statusKey = filter.statusKey + '%';
        String assignedKey = filter.assignedKey;
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        List<ViewRecord> queryResults = new List<ViewRecord>();
        Id userId = UserInfo.getUserId();
        String otherString = '';
        String totalQuery = '';
        String recordQuery = '';
        
        if (viewName == 'Anchor Stories') {
            // Anchor Story Query   
            List<AnchorStory__c> results = new List<AnchorStory__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AnchorStory__c WHERE Id != null';
                recordQuery = 'SELECT Id, Name, Points__c, Search_Terms__c, Title__c' +
                    ' FROM AnchorStory__c ORDER BY Points__c, Name LIMIT :pSize OFFSET :offset';
                r.total = Database.countQuery(totalQuery);
                List<AnchorStory__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AnchorStory__c';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING' +
                    ' AnchorStory__c (Id, Name, Points__c, Search_Terms__c, Title__c' +
                    ' ORDER BY Points__c, Name LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AnchorStory__c> searchResultsCount = (List<AnchorStory__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AnchorStory__c>) searchResults[0]);   
            }            
            for (AnchorStory__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AnchorStory__c', 'standard:task', item.Title__c, 
                                                null, null, item.Points__c, item.Search_Terms__c, null, null, false));
            }
            
        } else if (viewName == 'Idea Boards') {
            // Idea Board Query
            List<IdeaBoard__c> results = new List<IdeaBoard__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM IdeaBoard__c WHERE Status__c LIKE :statusKey';
                recordQuery = 'SELECT Id, Name, Title__c, Status__c, CreatedDate, LastModifiedDate' +
                    ' FROM IdeaBoard__c WHERE Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery += ' AND OwnerId = :userId';
                    recordQuery += ' AND OwnerId = :userId';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY Title__c LIMIT :pSize OFFSET :offset';
                List<IdeaBoard__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING IdeaBoard__c (Id WHERE Status__c LIKE :statusKey)';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' +
                    ' IdeaBoard__c (Id, Name, Title__c, Status__c, CreatedDate, LastModifiedDate WHERE Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING IdeaBoard__c (Id WHERE Status__c LIKE :statusKey AND OwnerId = :userId)';
                    recordQuery += ' AND OwnerId = :userId';
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<IdeaBoard__c> searchResultsCount = (List<IdeaBoard__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY Title__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<IdeaBoard__c>) searchResults[0]);   
            }           
            for (IdeaBoard__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'IdeaBoard__c', 'standard:drafts', 
                                                item.Title__c, item.Status__c, null, null, null,
                                                item.CreatedDate, item.LastModifiedDate, false));
            } 
            
        } else if (viewName == 'Project Tasks') {
            // Project Task Query
            List<ProjectTask__c> results = new List<ProjectTask__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM ProjectTask__c WHERE Status__c LIKE :statusKey';
                recordQuery = 'SELECT Id, Name, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c,' + 
                    ' Status__c, CreatedDate, LastModifiedDate, Project__r.Project_Abbreviation__c' +
                    ' FROM ProjectTask__c WHERE Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery += ' AND Assigned_To__c = :userId';
                    recordQuery += ' AND Assigned_To__c = :userId';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY Project__r.Project_Abbreviation__c, Task_Number_Int__c LIMIT :pSize OFFSET :offset';
                List<ProjectTask__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ProjectTask__c (Id WHERE Status__c LIKE :statusKey)';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' +
                    ' ProjectTask__c (Id, Name, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c,' +
                    ' Status__c, CreatedDate, LastModifiedDate, Project__r.Project_Abbreviation__c' +
                    ' WHERE Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ProjectTask__c (Id WHERE Status__c LIKE :statusKey' +
                        ' AND Assigned_To__c = :userId)';
                    recordQuery += ' AND Assigned_To__c = :userId';
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<ProjectTask__c> searchResultsCount = (List<ProjectTask__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY Project__r.Project_Abbreviation__c, Task_Number_Int__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<ProjectTask__c>) searchResults[0]);   
            }            
            for (ProjectTask__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'ProjectTask__c', 'standard:task', 
                                                item.Task_Number__c + ' ' + item.Title__c, item.Status__c, 
                                                null, null, null, item.CreatedDate, item.LastModifiedDate, false));
            }
            
        } else if (viewName == 'Projects' || viewName == 'Project Templates') {
            // Project Query
            List<Project__c> results = new List<Project__c>();
            String isProjectTemplate = '';
            if (viewName == 'Project Templates') {
                isProjectTemplate = ' AND IsTemplate__c = TRUE';                 
            }
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM Project__c WHERE Status__c LIKE :statusKey' + isProjectTemplate;
                recordQuery = 'SELECT Id, Name, Title__c, Status__c, CreatedDate, LastModifiedDate ' +
                    ' FROM Project__c WHERE Status__c LIKE :statusKey' + isProjectTemplate;
                if (assignedKey != '') {
                    totalQuery += ' AND Id IN (SELECT Project__c FROM ProjectItem__c WHERE User__c = :userId' +
                        ' AND Type__c != \'Project Link\')';
                    recordQuery += ' AND Id IN (SELECT Project__c FROM ProjectItem__c WHERE User__c = :userId' +
                        ' AND Type__c != \'Project Link\')';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY Title__c LIMIT :pSize OFFSET :offset';
                List<Project__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING Project__c (Id WHERE Status__c LIKE :statusKey' +
                     isProjectTemplate + ')';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING' +
                    ' Project__c (Id, Name, Title__c, Status__c, CreatedDate, LastModifiedDate WHERE Status__c LIKE :statusKey' +
                     isProjectTemplate;
                if (assignedKey != '') {
                    totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING Project__c (Id WHERE Status__c LIKE :statusKey' + isProjectTemplate +
                        ' AND Id IN (SELECT Project__c FROM ProjectItem__c  WHERE User__c = :userId AND Type__c != \'Project Link\'))';
                    recordQuery += ' AND Id IN (SELECT Project__c FROM ProjectItem__c' +
                        ' WHERE User__c = :userId AND Type__c != \'Project Link\')';
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<Project__c> searchResultsCount = (List<Project__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY Title__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<Project__c>) searchResults[0]);   
            }            
            for (Project__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'Project__c', 'standard:drafts', item.Title__c, item.Status__c, 
                                                null, null, null, item.CreatedDate, item.LastModifiedDate, false));
            }
            
        } else if (viewName == 'Sprints') {
            // Sprint Query
            List<Sprint__c> results = new List<Sprint__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM Sprint__c WHERE Id != null';
                recordQuery = 'SELECT Id, Name, Project__r.Title__c, Sprint_Number__c, Start_Date__c, End_Date__c,' + 
                    ' CreatedDate, LastModifiedDate FROM Sprint__c WHERE Id != null';
                if (statusKey == 'Open%') {
                    totalQuery += ' AND Start_Date__c <= today AND (End_Date__c = null or End_Date__c >= today)';
                    recordQuery += ' AND Start_Date__c <= today AND (End_Date__c = null or End_Date__c >= today)';
                } else if (statusKey == 'Closed%') {
                    totalQuery += ' AND (Start_Date__c > today OR End_Date__c < today)';
                    recordQuery += ' AND (Start_Date__c > today OR End_Date__c < today)';
                }
                if (assignedKey != '') {
                    totalQuery += ' AND Project__c IN (SELECT Project__c FROM ProjectItem__c WHERE User__c = :userId' + 
                        ' AND Type__c != \'Project Link\')';
                    recordQuery += ' AND Project__c IN (SELECT Project__c FROM ProjectItem__c WHERE User__c = :userId' + 
                        ' AND Type__c != \'Project Link\')';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY Project__r.Title__c, Sprint_Number__c LIMIT :pSize OFFSET :offset';
                List<Sprint__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING Sprint__c';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING Sprint__c (Id, Name, Project__r.Title__c,' +
                    ' Sprint_Number__c, Start_Date__c, End_Date__c, CreatedDate, LastModifiedDate';
                if (assignedKey != '') {
                    totalQuery += ' (Id WHERE Project__c IN (SELECT Project__c FROM ProjectItem__c ' +
                        ' WHERE User__c = :userId AND Type__c != \'Project Link\')';
                    recordQuery += ' WHERE Project__c IN (SELECT Project__c FROM ProjectItem__c ' +
                        ' WHERE User__c = :userId  AND Type__c != \'Project Link\')';
                    if (statusKey == 'Open%') {
                        totalQuery += ' AND Start_Date__c <= today AND (End_Date__c = null or End_Date__c >= today)';
                        recordQuery += ' AND Start_Date__c <= today AND (End_Date__c = null or End_Date__c >= today)';
                    } else if (statusKey == 'Closed%') {
                        totalQuery += ' AND (Start_Date__c > today OR End_Date__c < today)';  
                        recordQuery += ' AND (Start_Date__c > today OR End_Date__c < today)';
                    }
                    totalQuery += ')';
                } else {
                    if (statusKey == 'Open%') {
                        totalQuery += ' (Id WHERE Start_Date__c <= today AND (End_Date__c = null or End_Date__c >= today))';
                        recordQuery += ' WHERE Start_Date__c <= today AND (End_Date__c = null or End_Date__c >= today)';
                    } else if (statusKey == 'Closed%') {
                        totalQuery += ' (Id WHERE Start_Date__c > today OR End_Date__c < today)';
                        recordQuery += ' WHERE Start_Date__c > today OR End_Date__c < today';
                    }                   
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<Sprint__c> searchResultsCount = (List<Sprint__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY Project__r.Title__c, Sprint_Number__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<Sprint__c>) searchResults[0]);   
            }            
            Date thisDay = Date.today();
            String sprintStatus;
            for (Sprint__c item : results) {
                sprintStatus = 'Closed';
                if (item.Start_Date__c <= thisDay && (item.End_Date__c == null || item.End_Date__c >= thisDay)) {
                    sprintStatus = 'Open';
                }
                queryResults.add(new ViewRecord(item.Id, item.Name, 'Sprint__c', 'standard:work_order', 
                                                item.Project__r.Title__c + ' Sprint ' + item.Sprint_Number__c, 
                                                sprintStatus, null, null, null, item.CreatedDate, item.LastModifiedDate, false));                
            } 
            
        } else if (viewName == 'Tags') {
            // Tag Query
            List<Tag__c> results = new List<Tag__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM Tag__c WHERE Id != null';
                recordQuery = 'SELECT Id, Name, For_IdeaBoards__c, For_ProjectTasks__c, For_Projects__c, CreatedDate, LastModifiedDate' +
                    ' FROM Tag__c ORDER BY Name LIMIT :pSize OFFSET :offset';
                r.total = Database.countQuery(totalQuery);
                List<Tag__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING Tag__c';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING' +
                    ' Tag__c (Id, Name, For_IdeaBoards__c, For_ProjectTasks__c, For_Projects__c, CreatedDate, LastModifiedDate' +
                    ' ORDER BY Name LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<Tag__c> searchResultsCount = (List<Tag__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<Tag__c>) searchResults[0]);   
            }            
            for (Tag__c item : results) {
                otherString = '';
                if (item.For_IdeaBoards__c) {otherString += 'Idea Boards, ';}
                if (item.For_ProjectTasks__c) {otherString += 'Project Tasks, ';}
                if (item.For_Projects__c) {otherString += 'Projects, ';}
                if (otherString.length() > 3) {
                    otherString = otherString.substring(0, otherString.length() - 2);
                }
                queryResults.add(new ViewRecord(item.Id, item.Name, 'Tag__c', 'standard:topic', item.Name, 
                                                null, null, null, otherString, item.CreatedDate, item.LastModifiedDate, false));
            }
            
        }
        
        r.viewItems = queryResults; 
        RETURN r;
    }
    
    @AuraEnabled
    public static ObjectAccess objectAccess() {   
        Boolean hasProjects = hasProjectObject();
        ObjectAccess result = new ObjectAccess();
        result.canCreateAnchorStory = false;
        result.canCreateTag = false;
        
        if (hasProjects) {
            if (AnchorStory__c.sObjectType.getDescribe().isCreateable()) {
                result.canCreateAnchorStory = true;
            }
        }
        if (Tag__c.sObjectType.getDescribe().isCreateable()) {
            result.canCreateTag = true;
        }
        return result;
    }
    
    @AuraEnabled
    public static Boolean hasProjectObject() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('Project__c');
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
