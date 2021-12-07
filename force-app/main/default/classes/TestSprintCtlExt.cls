@isTest 
public class TestSprintCtlExt {
    
    static testMethod void test_recordAccess() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        
        Test.startTest();
        List<UserRecordAccess> results = SprintControllerExt.recordAccess(testSprint.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS1','standarduserS1@agourasoftware.com','Testing S1','standarduserS1@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getWebPageTitle(testSprint.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getWebPageTitle(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results.get(0).Project__r.Title__c);
    }
    
    static testMethod void test_getEndDate() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Date thisDay = Date.today();
        testSprint.End_Date__c = thisDay;
        update testSprint;
        User testUser = createTestUser('userS2','standarduserS2@agourasoftware.com','Testing S2','standarduserS2@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getEndDate(testSprint.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getEndDate(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(thisDay, results.get(0).End_Date__c);
    }
    
    static testMethod void test_getUsers() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userS3','standarduserS3@agourasoftware.com','Testing S3','standarduserS3@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = SprintControllerExt.getUsers(testSprint.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = SprintControllerExt.getUsers(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(2, results.size());
        System.assertEquals(userId, results.get(0).getId());
        System.assertEquals(userId, results.get(1).getId());
    }
    
    static testMethod void test_getProject() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS4','standarduserS4@agourasoftware.com','Testing S4','standarduserS4@agourasoftware.com');
        
        Test.startTest();
        List<Project__c> results = SprintControllerExt.getProject(testSprint.Id);
        System.runas(testUser) {
            try {
                List<Project__c> accessResult = SprintControllerExt.getProject(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).Id);
    }
    
    static testMethod void test_getDefaultProject() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS5','standarduserS5@agourasoftware.com','Testing S5','standarduserS5@agourasoftware.com');
        
        Test.startTest();
        List<Project__c> results = SprintControllerExt.getDefaultProject(testProject.Id);
        System.runas(testUser) {
            try {
                List<Project__c> accessResult = SprintControllerExt.getDefaultProject(testProject.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results.get(0).Title__c);
    }
    
    static testMethod void test_getDefaultFields() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS6','standarduserS6@agourasoftware.com','Testing S6','standarduserS6@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getDefaultFields(testProject.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getDefaultFields(testProject.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('2 weeks', results.get(0).Sprint_Length__c);
    }
    
    static testMethod void test_projectSearch() {
        Id [] fixedResults = new Id[1]; 
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userS7','standarduserS7@agourasoftware.com','Testing S7','standarduserS7@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = SprintControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = SprintControllerExt.projectSearch('Test', selectedIds);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void test_getStatuses() {
        Test.startTest();
        List<String> getResults = SprintControllerExt.getStatuses();
        Test.stopTest();
        
        System.assertEquals(8, getResults.size());
        System.assertEquals('Open', getResults.get(0));
    }
    
    static testMethod void test_getTypeKeys() {
        Test.startTest();
        List<String> getResults = SprintControllerExt.getTypeKeys();
        Test.stopTest();
        
        System.assertEquals(8, getResults.size());
        System.assertEquals('Bug', getResults.get(0));
    }
    
    static testMethod void test_getProjectTasks() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', null);
        List<ProjectTask__c> taskList = new List<ProjectTask__c>{};
            String searchFilter = createTestFilter('','');
        User testUser = createTestUser('userS8','standarduserS8@agourasoftware.com','Testing S8','standarduserS8@agourasoftware.com');
        
        Test.startTest();
        SprintControllerExt.PagedResult results = SprintControllerExt.getProjectTasks(searchFilter, 10.0, 1.0, testSprint.Id);
        System.runas(testUser) {
            try {
                SprintControllerExt.PagedResult accessResult = SprintControllerExt.getProjectTasks(searchFilter, 10.0, 1.0, testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        taskList = results.items;
        System.assertEquals(1, results.total);  
        System.assertEquals(testProjectTask.Id, taskList.get(0).Id);  
        
    }
    
    static testMethod void test_getSprintTaskItems() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        List<ProjectTask__c> taskList = new List<ProjectTask__c>{};
            String searchFilter = createTestFilter('','');
        User testUser = createTestUser('userS9','standarduserS9@agourasoftware.com','Testing S9','standarduserS9@agourasoftware.com');
        
        Test.startTest();
        List<ProjectTask__c> results = SprintControllerExt.getSprintTaskItems(testSprint.Id);
        System.runas(testUser) {
            try {
                List<ProjectTask__c> accessResult = SprintControllerExt.getSprintTaskItems(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask.Id, results.get(0).Id);         
    }
    
    static testMethod void test_updateSprintTaskItem() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        testProjectTask2.Type__c='Bug';
        testProjectTask2.Order__c=2;
        update testProjectTask2;
        List<ProjectTask__c> taskList = new List<ProjectTask__c>{};
            String searchFilter = createTestFilter('','');
        User testUser = createTestUser('userS10','standarduserS10@agourasoftware.com','Testing S10','standarduserS10@agourasoftware.com');
        
        Test.startTest();
        ProjectTask__c result1 = SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Start');
        ProjectTask__c result2 = SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Complete');
        ProjectTask__c result3 = SprintControllerExt.updateSprintTaskItem(testProjectTask2.Id, testSprint.Id, 'Complete');
        ProjectTask__c result4 = SprintControllerExt.updateSprintTaskItem(testProjectTask2.Id, testSprint.Id, 'Remove');
        ProjectTask__c result5 = SprintControllerExt.updateSprintTaskItem(testProjectTask2.Id, testSprint.Id, 'AddItem');
        System.runas(testUser) {
            try {
                ProjectTask__c accessResult = SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Start');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals('In Progress', result1.Status__c);  
        System.assertEquals('Done', result2.Status__c);   
        System.assertEquals('Resolved', result3.Status__c); 
        System.assertEquals(null, result4.Sprint__c);       
        System.assertEquals(testSprint.Id, result5.Sprint__c);         
    }
    
    static testMethod void test_updateTaskSwimLane() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', null);
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');
        User testUser = createTestUser('userS11','standarduserS11@agourasoftware.com','Testing S11','standarduserS11@agourasoftware.com');
        
        Test.startTest();
        ProjectTask__c results = SprintControllerExt.updateTaskSwimLane(testProjectTask.Id, testProjectItem.Id);
        System.runas(testUser) {
            try {
                ProjectTask__c accessResult = SprintControllerExt.updateTaskSwimLane(testProjectTask.Id, testProjectItem.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(testProjectItem.Id, results.Swim_Lane__c);   
    }
    
    static testMethod void test_getTargetPoints() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        testSprint.Target_Points__c = 10;
        update testSprint;
        User testUser = createTestUser('userS12','standarduserS12@agourasoftware.com','Testing S12','standarduserS12@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getTargetPoints(testSprint.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getTargetPoints(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(10, results.get(0).Target_Points__c);
    }
    
    static testMethod void test_getStartDate() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Date thisDay = Date.today();
        testSprint.Start_Date__c = thisDay;
        update testSprint;
        User testUser = createTestUser('userS13','standarduserS13@agourasoftware.com','Testing S13','standarduserS13@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getStartDate(testSprint.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getStartDate(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(thisDay, results.get(0).Start_Date__c);
    }
    
    static testMethod void test_getCompletedPoints() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        testProjectTask.Points__c = 10;
        update testProjectTask;
        ProjectTask__c result1 = SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Complete');
        User testUser = createTestUser('userS14','standarduserS14@agourasoftware.com','Testing S14','standarduserS14@agourasoftware.com');
        
        Test.startTest();
        List<AggregateResult> results2 = SprintControllerExt.getCompletedPoints(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AggregateResult> accessResult = SprintControllerExt.getCompletedPoints(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results2.size());
        System.assertEquals(10, results2.get(0).get('points'));
    }
    
    static testMethod void test_getProjectSwimLanes() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');
        User testUser = createTestUser('userS15','standarduserS15@agourasoftware.com','Testing S15','standarduserS15@agourasoftware.com');
        
        Test.startTest();
        List<ProjectItem__c> results = SprintControllerExt.getProjectSwimLanes(testSprint.Id);
        System.runas(testUser) {
            try {
                List<ProjectItem__c> accessResult = SprintControllerExt.getProjectSwimLanes(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectItem.Id, results.get(0).Id);   
    }
    
    static testMethod void test_getAssignedToList() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');        
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        testProjectTask.Assigned_To__c = userId;
        update testProjectTask;
        
        Test.startTest();
        List<LookupSearchResult> results = SprintControllerExt.getAssignedToList(testSprint.Id);
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(userId, results.get(0).getId()); 
    }
    
    static testMethod void test_removeAccess() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        testProject.Product_Owner__c = userId;
        update testProject;
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');    
        User testUser = createTestUser('userS16','standarduserS16@agourasoftware.com','Testing S16','standarduserS16@agourasoftware.com'); 
        
        Test.startTest();
        Boolean result = SprintControllerExt.removeAccess(testSprint.Id);
        System.runas(testUser) {
            try {
                Boolean accessResult = SprintControllerExt.removeAccess(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(true, result); 
    }
    
    static testMethod void test_doCloseSprint() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');  
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);   
        FeedItem testFeedItem = createFeedPost(testProject.Id);
        User testUser = createTestUser('userS17','standarduserS17@agourasoftware.com','Testing S17','standarduserS17@agourasoftware.com');
        
        Test.startTest();
        SprintControllerExt.doCloseSprint(testSprint.Id, testFeedItem, true);
        System.runas(testUser) {
            try {
                SprintControllerExt.doCloseSprint(testSprint.Id, testFeedItem, true);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testProject.Id];        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    } 
    
    static testMethod void test_updateSprintNumberCompletedPoints() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST'); 
        User testUser = createTestUser('userS18','standarduserS18@agourasoftware.com','Testing S18','standarduserS18@agourasoftware.com');
        
        Test.startTest();
        Sprint__c result = SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, null);
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks'); 
        Sprint__c result2 = SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, null);
        Sprint__c testSprint2 = new Sprint__c(Project__c=testProject.Id,
                                                                      Sprint_Length__c='2 weeks',
                                                                      Sprint_Number__c=2);
        insert testSprint2;
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint2.Id); 
        testProjectTask.Status__c = 'Done';
        testProjectTask.Points__c = 5;
        update testProjectTask;
        Sprint__c result3 = SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, testSprint2.Id);
        System.runas(testUser) {
            try {
                Sprint__c accessResult = SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, null);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, result.Sprint_Number__c); 
        System.assertEquals(2, result2.Sprint_Number__c);   
        System.assertEquals(2, result3.Sprint_Number__c); 
        System.assertEquals(5, result3.Completed_Points__c);
    }     
    
    static testMethod void test_createAccess() {
        User testUser = createTestUser('userS19','standarduserS19@agourasoftware.com','Testing S19','standarduserS19@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = SprintControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = SprintControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
        Test.stopTest();
        
        System.assertEquals(True, results);
    }  
    
    static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Completed_Points__c');
        Test.startTest();
        
        Map<String, String> results = SprintControllerExt.getFieldLabelMap('Sprint__c', fieldList);
        
        System.assertEquals(true,results.containsKey('Completed_Points__c'));     
        Test.stopTest();
    }
    
    static testMethod void test_getCurrentSprint() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Integer userNum = 20;
        User testUser = createTestUser('userS'+userNum,'standarduserS'+userNum+'@agourasoftware.com','Testing S'+userNum,'standarduserS'+userNum+'@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getCurrentSprint(testProject.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getCurrentSprint(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void test_getSprint() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Integer userNum = 21;
        User testUser = createTestUser('userS'+userNum,'standarduserS'+userNum+'@agourasoftware.com','Testing S'+userNum,'standarduserS'+userNum+'@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = SprintControllerExt.getSprint(testSprint.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = SprintControllerExt.getSprint(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void test_removeProjectSprint() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Integer userNum = 22;
        User testUser = createTestUser('userS'+userNum,'standarduserS'+userNum+'@agourasoftware.com','Testing S'+userNum,'standarduserS'+userNum+'@agourasoftware.com');
        
        Test.startTest();
        Sprint__c result = SprintControllerExt.removeProjectSprint(testSprint.Id);
        System.runas(testUser) {
            try {
                Sprint__c accessResult = SprintControllerExt.removeProjectSprint(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(null, result);
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
    
    private static Sprint__c createTestSprint(Id projectId, String sprintLength) {
        Sprint__c testSprint = new Sprint__c(Project__c=projectId,
                                                                     Sprint_Length__c=sprintLength,
                                                                     Sprint_Number__c=1,
                                                                     Sprint_Name__c='Sprint 1');
        insert testSprint;
        return testSprint;
    }
    
    private static ProjectTask__c createTestProjectTask(Id projectId, String title, Id SprintId) {
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=projectId,
                                                                                    Title__c=title,
                                                                                    Sprint__c=sprintId,
                                                                                    Status__c='Open',
                                                                                    Type__c='User Story');
        insert testProjectTask;
        return testProjectTask;
    }
    
    private static String createTestFilter(String searchKeyStr, String typeKeyStr) {
        SprintControllerExt.Filter testFilter = new SprintControllerExt.Filter();
        testFilter.searchKey = searchKeyStr;
        testFilter.typeKey = typeKeyStr;
        String myJSON = JSON.serialize(testFilter);
        return myJSON;
    }
    
    private static ProjectItem__c createTestProjectItem(Id projectId, String typeStr, String title) {
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=projectId,
                                                                                    Type__c=typeStr,
                                                                                    Title__c=title);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static FeedItem createFeedPost(Id projectId) {
        FeedItem testFeedPost = new FeedItem(ParentId=projectId,
                                             Type='TextPost',
                                             IsRichText=false,
                                             Body='Some text');                  
        return testFeedPost;
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
