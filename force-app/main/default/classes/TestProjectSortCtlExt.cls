@isTest 
public class TestProjectSortCtlExt {
    
    static testMethod void test_removeProjectTask() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0);
        List<ProjectTask__c> taskList = new List<ProjectTask__c>{};
        User testUser = createTestUser('userPS1','standarduserPS1@agourasoftware.com','Testing PS1','standarduserPS1@agourasoftware.com');
        
        Test.startTest();
        ProjectTask__c results = ProjectSortControllerExt.removeProjectTask(testProjectTask.Id);
        System.runas(testUser) {
            try {
                ProjectTask__c accessResult = ProjectSortControllerExt.removeProjectTask(testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        String searchFilter1 = createTestFilter('','','10','All');
        ProjectSortControllerExt.PagedResult results1 = ProjectSortControllerExt.getProjectTasks(searchFilter1, 10.0, 1.0, testProject.Id);
        taskList = results1.items;
        System.assertEquals(0, results1.total);        
    }
    
    static testMethod void test_sortProjectTasks() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask1 = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, null, null, 1.0);
        ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task 2', 5.0, null, null, 1.1);
        ProjectTask__c testProjectTask3 = createTestProjectTask(testProject.Id, 'Test Project Task 3', 5.0, null, null, 2.0);
        List<ProjectTask__c> taskList = [SELECT Id, Order__c FROM ProjectTask__c];
        List<ProjectTask__c> taskList1 = new List<ProjectTask__c>{};
        User testUser = createTestUser('userPS2','standarduserPS2@agourasoftware.com','Testing PS2','standarduserPS2@agourasoftware.com');
        
        Test.startTest();
        List<ProjectTask__c> results = ProjectSortControllerExt.sortProjectTasks(testProject.Id, taskList);
        System.runas(testUser) {
            try {
                List<ProjectTask__c> accessResult = ProjectSortControllerExt.sortProjectTasks(testProject.Id, taskList);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        String searchFilter1 = createTestFilter('','','10','All');
        ProjectSortControllerExt.PagedResult results1 = ProjectSortControllerExt.getProjectTasks(searchFilter1, 10.0, 1.0, testProject.Id);
        taskList1 = results1.items;        
        System.assertEquals(3, results1.total);        
        System.assertEquals(3, taskList1.get(2).Order__c);
    }
    
    static testMethod void test_getProjectTasks() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0);
        List<ProjectTask__c> taskList = new List<ProjectTask__c>{};
        String searchFilter1 = createTestFilter('','','10','All');        
        String searchFilter2 = createTestFilter('','','10','BacklogLatest');
        String searchFilter3 = createTestFilter('','','10','Backlog');    
        String searchFilter4 = createTestFilter('','','10','1');
        User testUser = createTestUser('userPS3','standarduserPS3@agourasoftware.com','Testing PS3','standarduserPS3@agourasoftware.com');
        
        Test.startTest();
        ProjectSortControllerExt.PagedResult results1 = ProjectSortControllerExt.getProjectTasks(searchFilter1, 10.0, 1.0, testProject.Id);
        ProjectSortControllerExt.PagedResult results2 = ProjectSortControllerExt.getProjectTasks(searchFilter2, 10.0, 1.0, testProject.Id);
        ProjectSortControllerExt.PagedResult results3 = ProjectSortControllerExt.getProjectTasks(searchFilter3, 10.0, 1.0, testProject.Id);
        ProjectSortControllerExt.PagedResult results4 = ProjectSortControllerExt.getProjectTasks(searchFilter4, 10.0, 1.0, testProject.Id);
        System.runas(testUser) {
            try {
                ProjectSortControllerExt.PagedResult accessResult = ProjectSortControllerExt.getProjectTasks(searchFilter1, 10.0, 1.0, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        taskList = results1.items;
        System.assertEquals(1, results1.total);        
        System.assertEquals(testProjectTask.Id, taskList.get(0).Id);
        taskList = results2.items;
        System.assertEquals(1, results2.total);        
        System.assertEquals(testProjectTask.Id, taskList.get(0).Id);
        taskList = results3.items;
        System.assertEquals(1, results3.total);        
        System.assertEquals(testProjectTask.Id, taskList.get(0).Id);        
        System.assertEquals(0, results4.total);        
    }
    
    static testMethod void test_getTypeKeys() {
        Test.startTest();
        List<String> getResults = ProjectSortControllerExt.getTypeKeys();
        Test.stopTest();
        
        System.assertEquals(8, getResults.size());
        System.assertEquals('Bug', getResults.get(0));
    }
    
    static testMethod void test_getSprintKeys() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userPS4','standarduserPS4@agourasoftware.com','Testing PS4','standarduserPS4@agourasoftware.com');
        
        Test.startTest();
        List<String> getResults = ProjectSortControllerExt.getSprintKeys(testProject.Id);
        System.runas(testUser) {
            try {
                List<String> accessResult = ProjectSortControllerExt.getSprintKeys(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults.size());
        System.assertEquals('1', getResults.get(0));       
    }
    
    static testMethod void test_getIdeaBoardStatusKeys() {
        Test.startTest();
        List<String> getResults = ProjectSortControllerExt.getIdeaBoardStatusKeys();
        Test.stopTest();
        
        System.assertEquals(4, getResults.size());
        System.assertEquals('Draft', getResults.get(0));      
    }
    
    static testMethod void test_getProjectStatusKeys() {
        Test.startTest();
        List<String> getResults = ProjectSortControllerExt.getProjectStatusKeys();
        Test.stopTest();
        
        System.assertEquals(3, getResults.size());
        System.assertEquals('Draft', getResults.get(0));         
    }
    
    static testMethod void test_getProjectTaskStatusKeys() {
        Test.startTest();
        List<String> getResults = ProjectSortControllerExt.getProjectTaskStatusKeys();
        Test.stopTest();
        
        System.assertEquals(8, getResults.size());
        System.assertEquals('Open', getResults.get(0));      
    }
    
    //
    // create test data
    // 
    private static Project__c createTestProject(String title, String abbrev) {
        Project__c testProject = new Project__c(Title__c=title,
                                                                Project_Abbreviation__c=abbrev,
                                                                Status__c='Draft');
        insert testProject;
        return testProject;
    }
    
    private static ProjectTask__c createTestProjectTask(Id projectId, String title, Decimal points, Id swimLane, Id masterTask, Decimal order) {
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=projectId,
                                                                            Title__c=title,
                                                                            Points__c=points,
                                                                            Swim_Lane__c=swimLane,
                                                                            Master_Task__c=masterTask,
                                                                            Order__c=order);
        insert testProjectTask;
        return testProjectTask;
    }
    
    private static String createTestFilter(String searchKeyStr, String typeKeyStr, String rowKeyStr, String sprintKeyStr) {
        ProjectSortControllerExt.Filter testFilter = new ProjectSortControllerExt.Filter();
        testFilter.searchKey = searchKeyStr;
        testFilter.typeKey = typeKeyStr;
        testFilter.rowKey = rowKeyStr;
        testFilter.sprintKey = sprintKeyStr;
        String myJSON = JSON.serialize(testFilter);
        return myJSON;
    }
    
    private static Sprint__c createTestSprint(Id projectId, String sprintLength) {
        Sprint__c testSprint = new Sprint__c(Project__c=projectId,
                                                             Sprint_Length__c=sprintLength,
                                                             Sprint_Number__c=1,
                                                             Sprint_Name__c='Sprint 1');
        insert testSprint;
        return testSprint;
    }
    
    private static User createTestUser(String alias, String email, String lastName, String userName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(Alias=alias, Email=email, 
                                 EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName=userName);        
        insert testUser;
        return testUser;
    }
}
