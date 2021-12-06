public with sharing class ProjectSortControllerExt {
    
    public class PagedResult {        
        @AuraEnabled
        public Integer pageSize { get;set; }        
        @AuraEnabled
        public Integer page { get;set; }        
        @AuraEnabled
        public Integer total { get;set; }        
        @AuraEnabled
        public List<ProjectTask__c> sortlist { get;set; }        
        @AuraEnabled
        public List<ProjectTask__c> items { get;set; }        
    }
    
    public class Filter {        
        @AuraEnabled
        public String searchKey { get;set; }        
        @AuraEnabled
        public String typeKey { get;set; }        
        @AuraEnabled
        public String rowKey { get;set; }        
        @AuraEnabled
        public String sprintKey { get;set; }        
    }
    
    @AuraEnabled
    public static ProjectTask__c removeProjectTask(Id taskId) {
        // CRUD and FLS Enforcement
        if (!ProjectTask__c.sObjectType.getDescribe().isAccessible() || !ProjectTask__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<ProjectTask__c> deleteMe = [SELECT Id FROM ProjectTask__c WHERE id = :taskId];
        delete deleteMe;
        RETURN null;
    }
    
    @AuraEnabled
    public static List<ProjectTask__c> sortProjectTasks(Id projectId, List<ProjectTask__c> projectTasksData){
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Order__c' };
            Map<String,Schema.SObjectField> m = Schema.SObjectType.ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e; 
            }
        }
        update projectTasksData;
        
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
        }
        update newList;        
        RETURN null;
    }
    
    @AuraEnabled
    public static PagedResult getProjectTasks(String filters, Decimal pageSize, Decimal pageNumber, Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Project__c.isAccessible() || 
            !Schema.sObjectType.ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, ProjectSortControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String searchKey = '%' + filter.searchKey + '%';
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        Integer sprintNumber = 0;
        
        if (filter.sprintKey == 'All') {
            r.sortlist = [SELECT Id, Order__c
                          FROM ProjectTask__c
                          WHERE Project__c = :projectId
                          AND Order__c != NULL
                          AND Title__c LIKE :searchKey
                          AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, 
                          Sprint__r.Sprint_Number__c NULLS LAST, Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )];
            r.items = [SELECT Id, Order__c, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c, Status__c, 
                       Points__c, Assigned_To__r.Name, Blocked__c, Sprint__r.Start_Date__c, 
                       Sprint__r.Sprint_Name__c, Sprint__r.Sprint_Number__c, Formatted_Status__c, Priority__c, 
                       Due_Date__c, CreatedDate 
                       FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, Sprint__r.Sprint_Number__c NULLS LAST, 
                       Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];  
        } else if (filter.sprintKey == 'BacklogLatest') {              
            List<Sprint__c> Sprnts = [SELECT Id
                                              FROM Sprint__c
                                              WHERE Project__c = :projectId
                                              ORDER BY Start_Date__c DESC, Sprint_Number__c DESC LIMIT 1]; 
            Id sprintId;
            if (Sprnts.size() > 0) {
                sprintId = Sprnts[0].Id;
            }             
            r.sortlist = [SELECT Id, Order__c
                          FROM ProjectTask__c
                          WHERE Project__c = :projectId
                          AND ((Order__c != NULL AND Sprint__c = '') OR Sprint__c = :sprintId)
                          AND Title__c LIKE :searchKey
                          AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, 
                          Sprint__r.Sprint_Number__c NULLS LAST, Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND ((Order__c != NULL AND Sprint__c = '') OR Sprint__c = :sprintId)
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )];
            r.items = [SELECT Id, Order__c, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c, Status__c, 
                       Points__c, Assigned_To__r.Name, Blocked__c, Sprint__r.Start_Date__c, 
                       Sprint__r.Sprint_Name__c, Sprint__r.Sprint_Number__c, Formatted_Status__c, Priority__c, 
                       Due_Date__c, CreatedDate 
                       FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND ((Order__c != NULL AND Sprint__c = '') OR Sprint__c = :sprintId)
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )           
                       ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, Sprint__r.Sprint_Number__c NULLS LAST, 
                       Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];    
        } else if (filter.sprintKey == 'Backlog') {
            r.sortlist = [SELECT Id, Order__c
                          FROM ProjectTask__c
                          WHERE Project__c = :projectId
                          AND Order__c != NULL
                          AND Title__c LIKE :searchKey
                          AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          AND Sprint__c = ''
                          ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, 
                          Sprint__r.Sprint_Number__c NULLS LAST, Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND Order__c != NULL
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND Sprint__c = ''];
            r.items = [SELECT Id, Order__c, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c, Status__c, 
                       Points__c, Assigned_To__r.Name, Blocked__c, Sprint__r.Start_Date__c, 
                       Sprint__r.Sprint_Name__c, Sprint__r.Sprint_Number__c, Formatted_Status__c, Priority__c, 
                       Due_Date__c, CreatedDate  
                       FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND Order__c != NULL
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND Sprint__c = ''
                       ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, Sprint__r.Sprint_Number__c NULLS LAST, 
                       Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];   
        } else {
            sprintNumber = Integer.valueOf(filter.sprintKey);
            r.sortlist = [SELECT Id, Order__c
                          FROM ProjectTask__c
                          WHERE Project__c = :projectId
                          AND Order__c != NULL
                          AND Title__c LIKE :searchKey
                          AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          AND Sprint__r.Sprint_Number__c = :sprintNumber
                          ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, 
                          Sprint__r.Sprint_Number__c NULLS LAST, Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND Sprint__r.Sprint_Number__c = :sprintNumber];
            r.items = [SELECT Id, Order__c, Task_Number_Int__c, Task_Number__c, Title__c, Formatted_Type__c, 
                       Status__c, Points__c, Assigned_To__r.Name, Blocked__c, Sprint__r.Start_Date__c, 
                       Sprint__r.Sprint_Name__c, Sprint__r.Sprint_Number__c, Formatted_Status__c, Priority__c, 
                       Due_Date__c, CreatedDate  
                       FROM ProjectTask__c
                       WHERE Project__c = :projectId
                       AND Title__c LIKE :searchKey
                       AND Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND Sprint__r.Sprint_Number__c = :sprintNumber
                       ORDER BY Order__c NULLS LAST, Sprint__r.Start_Date__c NULLS LAST, Sprint__r.Sprint_Number__c NULLS LAST, 
                       Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];            
        }
        
        RETURN r;
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
    public static List<String> getSprintKeys(Id projectId) {        
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        List<Sprint__c> Sprnts = [SELECT Sprint_Number__c
                                          FROM Sprint__c
                                          WHERE Project__c = :projectId
                                          ORDER BY Start_Date__c DESC, Sprint_Number__c
                                          LIMIT 10];         
        List<String> values = new list <String>();
        Integer arrayLength = Sprnts.size();     
        String sprintNumber = '';
        for(Integer i = Sprnts.size() - 1; i >= 0; i--){
            sprintNumber = String.valueOf(Sprnts[i].Sprint_Number__c);
            values.add(sprintNumber);
        }  
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getIdeaBoardStatusKeys() {
        Schema.DescribeFieldResult result = IdeaBoard__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getProjectStatusKeys() {
        Schema.DescribeFieldResult result = Project__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getProjectTaskStatusKeys() {
        Schema.DescribeFieldResult result = ProjectTask__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
}
