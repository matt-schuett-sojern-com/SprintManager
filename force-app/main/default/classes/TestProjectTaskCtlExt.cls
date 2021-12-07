@isTest 
public class TestProjectTaskCtlExt {
    
    static testMethod void test_recordAccess() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        
        Test.startTest();
        List<UserRecordAccess> results = ProjectTaskControllerExt.recordAccess(testProjectTask.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT2','standarduserPT2@agourasoftware.com','Testing PT2','standarduserPT2@agourasoftware.com');
        
        Test.startTest();
        List<ProjectTask__c> results = ProjectTaskControllerExt.getWebPageTitle(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<ProjectTask__c> accessResult = ProjectTaskControllerExt.getWebPageTitle(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project Task', results.get(0).Title__c);
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, userId, null, 'User Story');
        User testUser = createTestUser('userPT3','standarduserPT3@agourasoftware.com','Testing PT3','standarduserPT3@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.getUsers(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectTaskControllerExt.getUsers(testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(3, results.size());
        System.assertEquals(userId, results.get(0).getId());
        System.assertEquals(userId, results.get(1).getId());
        System.assertEquals(userId, results.get(2).getId());
    }
    
    static testMethod void test_getProject() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT4','standarduserPT4@agourasoftware.com','Testing PT4','standarduserPT4@agourasoftware.com');
        
        Test.startTest();
        List<Project__c> results = ProjectTaskControllerExt.getProject(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<Project__c> accessResult = ProjectTaskControllerExt.getProject(testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).Id);      
    }
    
    static testMethod void test_getSprint() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, testSprint.Id, 'User Story');
        User testUser = createTestUser('userPT5','standarduserPT5@agourasoftware.com','Testing PT5','standarduserPT5@agourasoftware.com');
        
        Test.startTest();
        List<Sprint__c> results = ProjectTaskControllerExt.getSprint(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<Sprint__c> accessResult = ProjectTaskControllerExt.getSprint(testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testSprint.Id, results.get(0).Id);        
    }
    
    static testMethod void test_getMasterTask() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, testProjectTask.Id, 1.0, null, 
                                                                        null, 'User Story');
        User testUser = createTestUser('userPT6','standarduserPT6@agourasoftware.com','Testing PT6','standarduserPT6@agourasoftware.com');
        
        Test.startTest();
        List<ProjectTask__c> results = ProjectTaskControllerExt.getMasterTask(testProjectTask2.Id);
        System.runas(testUser) {
            try {
                List<ProjectTask__c> accessResult = ProjectTaskControllerExt.getMasterTask(testProjectTask2.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask.Id, results.get(0).Master_Task__c);      
    }
    
    static testMethod void test_getSubTasks() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, testProjectTask.Id, 1.0, null, 
                                                                        null, 'User Story');
        User testUser = createTestUser('userPT7','standarduserPT7@agourasoftware.com','Testing PT7','standarduserPT7@agourasoftware.com');
        
        Test.startTest();
        List<ProjectTask__c> results = ProjectTaskControllerExt.getSubTasks(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<ProjectTask__c> accessResult = ProjectTaskControllerExt.getSubTasks(testProjectTask.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask2.Id, results.get(0).Id);       
    }
    
    static testMethod void test_projectSearch() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Id [] fixedResults = new Id[1]; 
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT8','standarduserPT8@agourasoftware.com','Testing PT8','standarduserPT8@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectTaskControllerExt.projectSearch('Test', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void test_doStartWork() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT9','standarduserPT9@agourasoftware.com','Testing PT9','standarduserPT9@agourasoftware.com');
        
        Test.startTest();
        ProjectTaskControllerExt.doStartWork(testProjectTask.Id);
        System.runas(testUser) {
            try {
                ProjectTaskControllerExt.doStartWork(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<ProjectTask__c> taskList = [SELECT Id, Status__c FROM ProjectTask__c];        
        System.assertEquals(1, taskList.size());
        System.assertEquals('In Progress', taskList.get(0).Status__c);         
    }
    
    static testMethod void test_doCompleteWork() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, null, null, 1.0, null, testSprint.Id, 'User Story');
        ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task 2', 5.0, null, null, 2.0, null, testSprint.Id, 'Bug');
        User testUser = createTestUser('userPT10','standarduserPT10@agourasoftware.com','Testing PT10','standarduserPT10@agourasoftware.com');
        
        Test.startTest();
        ProjectTaskControllerExt.doCompleteWork(testProjectTask.Id, testSprint.Id, testProject.Id);
        ProjectTaskControllerExt.doCompleteWork(testProjectTask2.Id, testSprint.Id, testProject.Id);  
        System.runas(testUser) {
            try {
                ProjectTaskControllerExt.doCompleteWork(testProjectTask.Id, testSprint.Id, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }      
        Test.stopTest();
        
        List<ProjectTask__c> taskList = [SELECT Id, Status__c FROM ProjectTask__c ORDER BY Title__c];  
        System.assertEquals(2, taskList.size());
        System.assertEquals('Done', taskList.get(0).Status__c); 
        List<ProjectTask__c> taskList2 = [SELECT Id, Status__c FROM ProjectTask__c ORDER BY Title__c]; 
        System.assertEquals(2, taskList2.size());
        System.assertEquals('Resolved', taskList2.get(1).Status__c);        
        List<Sprint__c> sprintList = [SELECT Id, Completed_Points__c FROM Sprint__c];
        System.assertEquals(1, sprintList.size());
        System.assertEquals(10.0, sprintList.get(0).Completed_Points__c);       
    }
    
    static testMethod void test_userOnlySearch() {
        User testUser = createTestUser('userPT11','standarduserPT11@agourasoftware.com','Testing PT11','standarduserPT11@agourasoftware.com'); 
        Id [] fixedResults = new Id[1];
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());      
    }
    
    static testMethod void test_getProjectSwimLanes() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');  
        User testUser = createTestUser('userPT12','standarduserPT12@agourasoftware.com','Testing PT12','standarduserPT12@agourasoftware.com');     
        
        Test.startTest();
        List<ProjectItem__c> getResults = ProjectTaskControllerExt.getProjectSwimLanes(testProject.Id);
        System.runas(testUser) {
            try {
                List<ProjectItem__c> accessResult = ProjectTaskControllerExt.getProjectSwimLanes(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults.size());
        System.assertEquals(testProjectItem.Id, getResults.get(0).Id);        
    }
    
    static testMethod void test_sprintSearch() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Id [] fixedResults = new Id[1];
        fixedResults.add(testSprint.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT13','standarduserPT13@agourasoftware.com','Testing PT13','standarduserPT13@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.sprintSearch('Sprint 1', selectedIds, testProject.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectTaskControllerExt.sprintSearch('Sprint 1', selectedIds, testProject.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testSprint.Id, results.get(0).getId());      
    }
    
    static testMethod void test_projectTaskSearch() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task');
        insert testProjectTask;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testProjectTask.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT14','standarduserPT14@agourasoftware.com','Testing PT14','standarduserPT14@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.projectTaskSearch('Task', selectedIds, testProject.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectTaskControllerExt.projectTaskSearch('Task', selectedIds, testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask.Id, results.get(0).getId());     
    }
    
    static testMethod void test_getRelatedAccount() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Account testAccount = createTestAccount('Test Account');
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Account__c=testAccount.Id);
        insert testProjectTask;
        User testUser = createTestUser('userPT15','standarduserPT15@agourasoftware.com','Testing PT15','standarduserPT15@agourasoftware.com'); 
        
        Test.startTest();
        List<Account> results = ProjectTaskControllerExt.getRelatedAccount(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<Account> accessResult = ProjectTaskControllerExt.getRelatedAccount(testProjectTask.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount.Id, results.get(0).Id);           
    }
    
    static testMethod void test_accountSearch() {
        Account testAccount1 = createTestAccount('Test Account 1');
        Account testAccount2 = createTestAccount('Test Account 2');
        Id [] fixedResults = new Id[1];
        fixedResults.add(testAccount1.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.accountSearch('Account 1', selectedIds);
        Test.stopTest();
                
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount1.Id, results.get(0).getId());         
    }
    
    static testMethod void test_tagSearch() {
        Tag__c testTag1 = createTestTag('Test Tag 1');
        Tag__c testTag2 = createTestTag('Test Tag 2');
        Id [] fixedResults = new Id[1];
        fixedResults.add(testTag1.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT16','standarduserPT16@agourasoftware.com','Testing PT16','standarduserPT16@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectTaskControllerExt.tagSearch('Tag 1', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectTaskControllerExt.tagSearch('Tag 1', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag1.Id, results.get(0).getId());          
    }
    
    static testMethod void test_Project_Task_Tags() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');        
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task');
        Tag__c testTag = createTestTag('Test Tag 1');
        insert testProjectTask;
        User testUser = createTestUser('userPT17','standarduserPT17@agourasoftware.com','Testing PT17','standarduserPT17@agourasoftware.com'); 
        User testUser2 = createTestUser('userPT18','standarduserPT18@agourasoftware.com','Testing PT18','standarduserPT18@agourasoftware.com'); 
        
        Test.startTest();
        ProjectTaskTagAssoc__c results = ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id);
        List<Tag__c> results2 = ProjectTaskControllerExt.getProjectTaskTags(testProjectTask.Id);
        ProjectTaskTagAssoc__c results3 = ProjectTaskControllerExt.removeProjectTaskTag(testTag.Id, testProjectTask.Id);
        List<Tag__c> results4 = ProjectTaskControllerExt.getProjectTaskTags(testProjectTask.Id);
        System.runas(testUser) {
            try {
                ProjectTaskTagAssoc__c accessResult = ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                ProjectTaskTagAssoc__c accessResult2 = ProjectTaskControllerExt.removeProjectTaskTag(testTag.Id, testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<Tag__c> accessResult3 = ProjectTaskControllerExt.getProjectTaskTags(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results2.size());
        System.assertEquals(testTag.Id, results2.get(0).Id);
        System.assertEquals(0, results4.size());
    }
    
    static testMethod void test_getDefaultProject() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userPT19','standarduserPT19@agourasoftware.com','Testing PT19','standarduserPT19@agourasoftware.com'); 
        
        Test.startTest();
        List<Project__c> results = ProjectTaskControllerExt.getDefaultProject(testProject.Id);
        System.runas(testUser) {
            try {
                List<Project__c> accessResult = ProjectTaskControllerExt.getDefaultProject(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).Id);
    }
    
    static testMethod void test_createCloneTask() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectItem__c testSwimLane = ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');
        Account testAccount = createTestAccount('Test Account');
        Tag__c testTag = createTestTag('Test Tag');
        ProjectTask__c testProjectTaskMaster = new ProjectTask__c(Project__c=testProject.Id,
                                                                                  Title__c='Test Project Task');
        ProjectTask__c testProjectTask = new ProjectTask__c(Accept__c='Test String', 
                                                                            Account__c=testAccount.Id, 
                                                                            Affected_Version__c='Test String',
                                                                            Bug_Type__c='Blocker',   
                                                                            Comments__c='Test String', 
                                                                            Components__c='Test String',       
                                                                            Dependencies__c='Test String',                                                                    
                                                                            Description__c='Test String', 
                                                                            Due_Date__c=Date.today(), 
                                                                            Fix_Version__c='Test String',
                                                                            Master_Task__c=testProjectTaskMaster.Id,
                                                                            Priority__c='High',
                                                                            Project__c=testProject.Id, 
                                                                            Points__c=5.0, 
                                                                            Reported_By__c='Test String', 
                                                                            Reported_Date__c=Date.today(), 
                                                                            Swim_Lane__c=testSwimLane.Id, 
                                                                            Time_Estimate__c=1.0, 
                                                                            Title__c='Test Project Task',
                                                                            Type__c='Bug',
                                                                            Value__c='Test String',  
                                                                            Version__c='Unreleased');
        insert testProjectTask;
        ProjectTaskTagAssoc__c results = ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id);
        User testUser = createTestUser('userPT20','standarduserPT20@agourasoftware.com','Testing PT20','standarduserPT20@agourasoftware.com'); 
        
        Test.startTest();
        Id results2 = ProjectTaskControllerExt.createCloneTask(testProjectTask.Id, testProject.Id);
        System.runas(testUser) {
            try {
                Id accessResult = ProjectTaskControllerExt.createCloneTask(testProjectTask.Id, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertNotEquals(Null, results2);
    }
    
    static testMethod void test_saveProjectTaskData() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Sprint__c testSprint2 = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Sprint__c=testSprint2.Id,
                                                                            Status__c='Canceled');
        insert testProjectTask;
        ProjectTask__c testProjectTask2 = new ProjectTask__c(Project__c=testProject.Id,
                                                                             Title__c='Test Project Task 2',
                                                                             Order__c=2.0);
        insert testProjectTask2;
        ProjectTask__c testProjectTask3 = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task 3',
                                                                            Status__c='Open');
        insert testProjectTask3;
        User testUser = createTestUser('userPT21','standarduserPT21@agourasoftware.com','Testing PT21','standarduserPT21@agourasoftware.com');
        
        Test.startTest();
        ProjectTask__c results = ProjectTaskControllerExt.saveProjectTaskData(testProjectTask.Id, testSprint.Id);
        ProjectTask__c results3 = ProjectTaskControllerExt.saveProjectTaskData(testProjectTask3.Id, null);
        System.runas(testUser) {
            try {
                ProjectTask__c accessResult = ProjectTaskControllerExt.saveProjectTaskData(testProjectTask.Id, testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testProjectTask.Id, results.Id);
        System.assertEquals(testProjectTask3.Id, results3.Id);
    }
    
    static testMethod void test_updateOrderCompletedPoints() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Sprint__c testSprint2 = createTestSprint(testProject.Id, '2 weeks');
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Sprint__c=testSprint2.Id,
                                                                            Status__c='Canceled');
        insert testProjectTask;
        ProjectTask__c testProjectTask2 = new ProjectTask__c(Project__c=testProject.Id,
                                                                             Title__c='Test Project Task 2',
                                                                             Order__c=2.0);
        insert testProjectTask2;
        User testUser = createTestUser('userPT22','standarduserPT22@agourasoftware.com','Testing PT22','standarduserPT22@agourasoftware.com');
        
        Test.startTest();
        ProjectTaskControllerExt.updateOrderCompletedPoints(testProject.Id, testSprint.Id);
        System.runas(testUser) {
            try {
                ProjectTaskControllerExt.updateOrderCompletedPoints(testProject.Id, testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<ProjectTask__c> taskList = [SELECT Id, Order__c FROM ProjectTask__c ORDER BY Order__c NULLS LAST];        
        System.assertEquals(2, taskList.size());
        System.assertEquals(1, taskList.get(0).Order__c); 
    }
    
    static testMethod void test_updateOrder() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Status__c='Canceled');
        insert testProjectTask;
        ProjectTask__c testProjectTask2 = new ProjectTask__c(Project__c=testProject.Id,
                                                                             Title__c='Test Project Task 2',
                                                                             Order__c=2.0);
        insert testProjectTask2;
        User testUser = createTestUser('userPT23','standarduserPT23@agourasoftware.com','Testing PT23','standarduserPT23@agourasoftware.com');
        
        Test.startTest();
        ProjectTaskControllerExt.updateOrder(testProject.Id);
        System.runas(testUser) {
            try {
                ProjectTaskControllerExt.updateOrder(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<ProjectTask__c> taskList = [SELECT Id, Order__c FROM ProjectTask__c ORDER BY Order__c NULLS LAST];        
        System.assertEquals(2, taskList.size());
        System.assertEquals(1, taskList.get(0).Order__c); 
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userPT24','standarduserPT24@agourasoftware.com','Testing PT24','standarduserPT24@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = ProjectTaskControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = ProjectTaskControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void test_feedPost() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, null, null, 1.0, null, null, 'User Story');
        FeedItem testFeedItem = createFeedPost(testProjectTask.Id);
        User testUser = createTestUser('userPT25','standarduserPT25@agourasoftware.com','Testing PT25','standarduserPT25@agourasoftware.com');
        
        Test.startTest();
        ProjectTaskControllerExt.doChatterFeedPost(testFeedItem);
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testProjectTask.Id];
        System.runas(testUser) {
            try {
                FeedItem testFeedItem2 = createFeedPost(testProjectTask.Id);
                ProjectTaskControllerExt.doChatterFeedPost(testFeedItem2); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    }
    
    static testMethod void test_doAssignToMe() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT26','standarduserPT26@agourasoftware.com','Testing PT26','standarduserPT26@agourasoftware.com');
        
        Test.startTest();
        ProjectTaskControllerExt.doAssignToMe(testProjectTask.Id);
        System.runas(testUser) {
            try {
                ProjectTaskControllerExt.doAssignToMe(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<ProjectTask__c> taskList = [SELECT Id, Assigned_To__c FROM ProjectTask__c];        
        System.assertEquals(1, taskList.size());
        System.assertEquals(userId, taskList.get(0).Assigned_To__c);         
    }
    
    static testMethod void test_moveProjectTask() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Project__c testProject2 = createTestProject('Test Project 2', 'TESTTESTTEST2');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Account testAccount = createTestAccount('Test Account');
        Tag__c testTag = createTestTag('Test Tag');
        ProjectTask__c testProjectTaskMaster = new ProjectTask__c(Project__c=testProject.Id,
                                                                                  Title__c='Test Project Task');
        ProjectTask__c testProjectTask = new ProjectTask__c(Accept__c='Test String', 
                                                                            Account__c=testAccount.Id, 
                                                                            Affected_Version__c='Test String',
                                                                            Bug_Type__c='Blocker',   
                                                                            Comments__c='Test String', 
                                                                            Components__c='Test String',       
                                                                            Dependencies__c='Test String',                                                                    
                                                                            Description__c='Test String', 
                                                                            Due_Date__c=Date.today(), 
                                                                            Fix_Version__c='Test String',
                                                                            Priority__c='High',
                                                                            Project__c=testProject.Id, 
                                                                            Points__c=5.0, 
                                                                            Reported_By__c='Test String', 
                                                                            Reported_Date__c=Date.today(), 
                                                                            Sprint__c=testSprint.Id,
                                                                            Time_Estimate__c=1.0, 
                                                                            Title__c='Test Project Task',
                                                                            Type__c='Bug',
                                                                            Value__c='Test String',  
                                                                            Version__c='Unreleased');
        insert testProjectTask;
        ProjectTaskTagAssoc__c results = ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id);
        ProjectTask__c testProjectTask2 = new ProjectTask__c(Project__c=testProject.Id,
                                                                             Title__c='Test Project Task 2',
                                                                             Status__c='Canceled');
        insert testProjectTask2;
        User testUser = createTestUser('userPT27','standarduserPT27@agourasoftware.com','Testing PT27','standarduserPT27@agourasoftware.com'); 
        
        Test.startTest();
        ProjectTaskControllerExt.doMoveProjectTask(testProjectTask.Id, testProject2.Id);
        ProjectTaskControllerExt.doMoveProjectTask(testProjectTask2.Id, testProject2.Id);
        System.runas(testUser) {
            try {
                ProjectTaskControllerExt.doMoveProjectTask(testProjectTask.Id, testProject2.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<ProjectTask__c> taskList = [SELECT Id, Project__c, Title__c FROM ProjectTask__c ORDER BY Title__c];        
        System.assertEquals(2, taskList.size());
        System.assertEquals(testProject2.Id, taskList.get(0).Project__c); 
        System.assertEquals(testProject2.Id, taskList.get(1).Project__c);  
    }
    
    static testMethod void isChatterEnabled() {      
        Test.startTest();
        Boolean result = ProjectTaskControllerExt.checkChatterEnabled();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Accept__c');
        Test.startTest();
        
        Map<String, String> results = ProjectTaskControllerExt.getFieldLabelMap('ProjectTask__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Accept__c'));     
		Test.stopTest();
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
    
    private static ProjectTask__c createTestProjectTask(Id projectId, String title, Decimal points, Id swimLane, Id masterTask, Decimal order,
                                                                Id userId, Id sprintId, String typeStr) {
		ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=projectId,
                                                                            Title__c=title,
                                                                            Points__c=points,
                                                                            Swim_Lane__c=swimLane,
                                                                            Master_Task__c=masterTask,
                                                                            Order__c=order,
                                                                            Assigned_To__c=userId,
                                                                            Sprint__c=sprintId,
                                                                            Type__c=typeStr);
        insert testProjectTask;
		return testProjectTask;
    }
    
    private static ProjectTask__c createTestProjectTaskBase(Id projectId, String title) {
		ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=projectId,
                                                                            Title__c=title);
		return testProjectTask;
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
    
    private static Sprint__c createTestSprint(Id projectId, String sprintLength) {
        Sprint__c testSprint = new Sprint__c(Project__c=projectId,
                                                             Sprint_Length__c=sprintLength,
                                                             Sprint_Name__c='Sprint 1',
                                                             Sprint_Number__c=1);
        insert testSprint;
        return testSprint;
    }
    
    private static ProjectItem__c createTestProjectItem(Id projectId, String typeStr, String title) {
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=projectId,
                                                                            Type__c=typeStr,
                                                                            Title__c=title);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static Account createTestAccount(String name) {
        Account testAccount = new Account(Name=name);
        insert testAccount;
        return testAccount;
    }
    
    private static Tag__c createTestTag(String name) {
        Tag__c testTag = new Tag__c(Name=name, 
                                                    For_IdeaBoards__c=True,
                                                    For_ProjectTasks__c=True,
                                                    For_Projects__c=True);
        insert testTag;
        return testTag;
    }
    
    private static FeedItem createFeedPost(Id recId) {
        FeedItem testFeedPost = new FeedItem(ParentId=recId,
                                             Type='TextPost',
                                             IsRichText=true,
                                             Body='Some text');                  
        return testFeedPost;
    }
}
