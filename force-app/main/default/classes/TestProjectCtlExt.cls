@isTest 
public class TestProjectCtlExt {
    
    static testMethod void test_add_get_remove_ProjectSharingAccess() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser1 = createTestUser('userP1','standarduserP1@agourasoftware.com','Testing P1','standarduserP1@agourasoftware.com'); 
        User testUser2 = createTestUser('userP2','standarduserP2@agourasoftware.com','Testing P2','standarduserP2@agourasoftware.com');
        Group testGroup1 = createTestGroup('Test Group 1', 'Dev1');
        Group testGroup2 = createTestGroup('Test Group 2', 'Dev2');
        
        Test.startTest();
        Project__Share addResult1 = ProjectControllerExt.addProjectSharingAccess(testProject.Id, testUser1.id, 'Read');
        Project__Share addResult2 = ProjectControllerExt.addProjectSharingAccess(testProject.Id, testUser2.id, 'Edit');
        Project__Share addResult3 = ProjectControllerExt.addProjectSharingAccess(testProject.Id, testGroup1.id, 'Read');
        Project__Share addResult4 = ProjectControllerExt.addProjectSharingAccess(testProject.Id, testGroup2.id, 'Edit');
        List<LookupSearchResult> getResults = ProjectControllerExt.getUsers(testProject.Id);
        Project__Share removeResult1 = ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testUser1.Id);
        Project__Share removeResult2 = ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testUser2.Id);
        Project__Share removeResult3 = ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testGroup1.Id);
        Project__Share removeResult4 = ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testGroup2.Id);
        System.runas(testUser1) {
            try {
                Project__Share accessResult = ProjectControllerExt.addProjectSharingAccess(testProject.Id, testUser1.id, 'Read');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                Project__Share accessResult2 = ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testUser1.id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testProject.Id, addResult1.ParentId);
        System.assertEquals(testProject.Id, addResult2.ParentId);
        System.assertEquals(testProject.Id, addResult3.ParentId);
        System.assertEquals(testProject.Id, addResult4.ParentId);
        System.assertEquals(7, getResults.size());
        System.assertEquals(userId, getResults.get(0).getId());
        System.assertEquals(userId, getResults.get(1).getId());
        System.assertEquals(userId, getResults.get(2).getId());
        System.assertEquals(testUser1.Id, getResults.get(3).getId());
        System.assertEquals(testUser2.Id, getResults.get(4).getId());
        System.assertEquals(testGroup1.Id, getResults.get(5).getId());
        System.assertEquals(testGroup2.Id, getResults.get(6).getId());        
        List<LookupSearchResult> getResults2 = ProjectControllerExt.getUsers(testProject.Id);
        System.assertEquals(3, getResults2.size());        
    }
     
    static testMethod void test_recordAccess() {        
        User testUser = createTestUser('userP3','standarduserP3@agourasoftware.com','Testing P3','standarduserP3@agourasoftware.com');
        PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'Agoura_StandardUserAccess'];
        PermissionSet ps2 = [SELECT ID From PermissionSet WHERE Name = 'Agoura_AddStandardUserDelete'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id ); 
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps2.Id ); 
        
        Test.startTest();
        System.runas(testUser) {
            Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
            ProjectControllerExt.ProjectAccess results = ProjectControllerExt.recordAccess(testProject.Id);
            System.assertEquals(True, results.hasEditAccess);
            System.assertEquals(True, results.hasDeleteAccess);
            System.assertEquals(True, results.hasDeleteSprintTaskAccess);
        }
        Test.stopTest();        
    }
    
    // test search
    static testMethod void tag_search_should_return_tag() {
        Id [] fixedResults = new Id[1];
        Tag__c testTag = createTestTag('Test Tag');
        fixedResults.add(testTag.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userP4','standarduserP4@agourasoftware.com','Testing P4','standarduserP4@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.tagSearch('Test Tag', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectControllerExt.tagSearch('Test Tag', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag.Id, results.get(0).getId());
    }
    
    static testMethod void tag_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Tag__c testTag1 = createTestTag('Test Tag 1');
        fixedResults.add(testTag1.Id);
        Tag__c testTag2 = createTestTag('Test Tag 2');
        fixedResults.add(testTag2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testTag2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.tagSearch('Test Tag', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag1.Id, results.get(0).getId());
    }
    
    static testMethod void ideaboard_search_should_return_ideaboard() {
        Id [] fixedResults = new Id[1];
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        fixedResults.add(testIdeaBoard.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userP5','standarduserP5@agourasoftware.com','Testing P5','standarduserP5@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.ideaBoardSearch('Test Idea Board', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectControllerExt.ideaBoardSearch('Test Idea Board', selectedIds);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testIdeaBoard.Id, results.get(0).getId());
    }
    
    static testMethod void ideaboard_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        IdeaBoard__c testIdeaBoard1 = createTestIdeaBoard('Test Idea Board 1');
        fixedResults.add(testIdeaBoard1.Id);
        IdeaBoard__c testIdeaBoard2 = createTestIdeaBoard('Test Idea Board 2');
        fixedResults.add(testIdeaBoard2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testIdeaBoard2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.ideaBoardSearch('Test Idea Board', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testIdeaBoard1.Id, results.get(0).getId());
    }
    
    static testMethod void user_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userP6','standarduserP6@agourasoftware.com','Testing P6','standarduserP6@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.userSearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void user_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Group testGroup1 = createTestGroup('Test Group 1', 'Dev1');
        fixedResults.add(testGroup1.Id);
        Group testGroup2 = createTestGroup('Test Group 2', 'Dev2');
        fixedResults.add(testGroup2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testGroup2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.userSearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testGroup1.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userP7','standarduserP7@agourasoftware.com','Testing P7','standarduserP7@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        User testUser1 = createTestUser('userP8','standarduserP8@agourasoftware.com','Testing P8','standarduserP8@agourasoftware.com');
        User testUser2 = createTestUser('userP9','standarduserP9@agourasoftware.com','Testing P9','standarduserP9@agourasoftware.com');
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }
    
    static testMethod void related_account_search_should_return_account() {
        Id [] fixedResults = new Id[1];
        Account testAccount = createTestAccount('Test Account');
        Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', testAccount.Id, null, null, 'Test String');        
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userP10','standarduserP10@agourasoftware.com','Testing P10','standarduserP10@agourasoftware.com');
        
        Test.startTest();
        List<Account> results = ProjectControllerExt.getRelatedAccount(testProject.Id);
        System.runas(testUser) {
            try {
                List<Account> accessResult = ProjectControllerExt.getRelatedAccount(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount.Id, results.get(0).Id);
    }
    
    static testMethod void account_search_should_return_account() {
        Id [] fixedResults = new Id[1];
        Account testAccount = createTestAccount('Test Account');
        fixedResults.add(testAccount.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.accountSearch('Test Account', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount.Id, results.get(0).getId());
    }
    
    static testMethod void account_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Account testAccount1 = createTestAccount('Test Account 1');
        fixedResults.add(testAccount1.Id);
        Account testAccount2 = createTestAccount('Test Account 2');
        fixedResults.add(testAccount2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testAccount2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.accountSearch('Test Account', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount1.Id, results.get(0).getId());
    }
    
    static testMethod void test_tags() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Tag__c testTag = createTestTag('Test Tag');
        User testUser = createTestUser('userP11','standarduserP11@agourasoftware.com','Testing P11','standarduserP11@agourasoftware.com');
        
        Test.startTest();
        ProjectTagAssociation__c addResult = ProjectControllerExt.addProjectTag(testTag.id, testProject.Id);
        List<Tag__c> getResults = ProjectControllerExt.getProjectTags(testProject.Id);
        ProjectTagAssociation__c removeResult = ProjectControllerExt.removeProjectTag(testTag.Id, testProject.Id);
        System.runas(testUser) {
            try {
                ProjectTagAssociation__c accessResult = ProjectControllerExt.addProjectTag(testTag.id, testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                ProjectTagAssociation__c accessResult2 = ProjectControllerExt.removeProjectTag(testTag.id, testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<Tag__c> accessResult3 = ProjectControllerExt.getProjectTags(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
               
        System.assertEquals(testTag.Id, addResult.Tag__c);
        System.assertEquals(testProject.Id, addResult.Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals(testTag.Name, getResults.get(0).Name);
        List<Tag__c> getResults2 = ProjectControllerExt.getProjectTags(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_ideaProjects() {
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', null, testIdeaBoard.Id, null, 'Test String');
        User testUser = createTestUser('userP12','standarduserP12@agourasoftware.com','Testing P12','standarduserP12@agourasoftware.com');
        
        Test.startTest();
        List<IdeaBoard__c> getResults = ProjectControllerExt.getIdeaProjects(testProject.Id);
        System.runas(testUser) {
            try {
                List<IdeaBoard__c> accessResult = ProjectControllerExt.getIdeaProjects(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
                
        System.assertEquals(1, getResults.size());
        System.assertEquals(testIdeaBoard.Id, getResults.get(0).Id);       
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', null, null, userId, 'Test String');
        User testUser = createTestUser('userP28','standarduserP28@agourasoftware.com','Testing P28','standarduserP28@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectControllerExt.getUsers(testProject.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectControllerExt.getUsers(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(6, results.size());
        System.assertEquals(userId, results.get(0).getId());
        System.assertEquals(userId, results.get(1).getId());
        System.assertEquals(userId, results.get(2).getId());
        System.assertEquals(userId, results.get(3).getId());
        System.assertEquals(userId, results.get(4).getId());
        System.assertEquals(userId, results.get(5).getId());
    }
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createAdminUser('userP13','standarduserP13@agourasoftware.com','Testing P13','standarduserP13@agourasoftware.com');
        User testUser2 = createTestUser('userP14','standarduserP14@agourasoftware.com','Testing P14','standarduserP14@agourasoftware.com');
        
        Test.startTest();
        Project__c updateTest = ProjectControllerExt.updateDocumentOwner(testProject.Id, testUser.id);
        System.runas(testUser2) {
            try {
                Project__c accessResult = ProjectControllerExt.updateDocumentOwner(testProject.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void test_unassigned_points() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null); 
        User testUser = createTestUser('userP15','standarduserP15@agourasoftware.com','Testing P15','standarduserP15@agourasoftware.com');
        
        Test.startTest();
        AggregateResult getResults = ProjectControllerExt.getUnassignedPoints(testProject.Id);
        System.runas(testUser) {
            try {
                AggregateResult accessResult = ProjectControllerExt.getUnassignedPoints(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(5.0, getResults.get('unassignedPoints'));  
    }
    
    static testMethod void test_getRecordTitle() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP16','standarduserP16@agourasoftware.com','Testing P16','standarduserP16@agourasoftware.com');
        
        Test.startTest();
        List<Project__c> results = ProjectControllerExt.getProjectTitle(testProject.Id);
        System.runas(testUser) {
            try {
                List<Project__c> accessResult = ProjectControllerExt.getProjectTitle(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results.get(0).Title__c);
    }     

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userP29','standarduserP29@agourasoftware.com','Testing P29','standarduserP29@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = ProjectControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = ProjectControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void isChatterEnabled() {      
        Test.startTest();
        Boolean result = ProjectControllerExt.checkChatterEnabled();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
    
    // 
    // related objects
    // 
    static testMethod void test_goals() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Date thisDay = Date.today();
        User testUser = createTestUser('userP17','standarduserP17@agourasoftware.com','Testing P17','standarduserP17@agourasoftware.com');
        
        Test.startTest();
        ProjectItem__c addResult = ProjectControllerExt.addGoal(testProject.Id, 'Project Goal','Test Goal', string.valueofGmt(thisDay), 
                                                                               string.valueofGmt(thisDay), '10', '');
        List<ProjectItem__c> getResults = ProjectControllerExt.getProjectGoals(testProject.Id);
        ProjectItem__c removeResult = ProjectControllerExt.removeProjectItem(addResult.Id);
        
        ProjectItem__c addResult2 = ProjectControllerExt.addGoal(testProject.Id, 'Project Goal','Test Goal 2', '', 
                                                                                string.valueofGmt(thisDay), '10', '');
        System.runas(testUser) {
            try {
                ProjectItem__c accessResult = ProjectControllerExt.addGoal(testProject.Id, 'Project Goal','Test Goal', string.valueofGmt(thisDay),
                                                                                          string.valueofGmt(thisDay), '10', ''); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                ProjectItem__c accessResult2 = ProjectControllerExt.removeProjectItem(addResult2.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<ProjectItem__c> accessResult3 = ProjectControllerExt.getProjectGoals(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        ProjectItem__c removeResult2 = ProjectControllerExt.removeProjectItem(addResult2.Id);
		Test.stopTest();
        
        System.assertEquals('Test Goal', addResult.Title__c);
        System.assertEquals(testProject.Id, addResult.Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals('Test Goal', addResult.Title__c);        
        List<ProjectItem__c> getResults2 = ProjectControllerExt.getProjectGoals(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }  
    
    static testMethod void test_risks() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP18','standarduserP18@agourasoftware.com','Testing P18','standarduserP18@agourasoftware.com');
        
        Test.startTest();
        ProjectItem__c addResult = ProjectControllerExt.addRisk(testProject.Id, 'Test Risk', 'High', 'High', 'Open', 'Test String');
        List<ProjectItem__c> getResults = ProjectControllerExt.getProjectRisks(testProject.Id);
        ProjectItem__c removeResult = ProjectControllerExt.removeProjectItem(addResult.Id); 
        System.runas(testUser) {
            try {
                ProjectItem__c accessResult = ProjectControllerExt.addRisk(testProject.Id, 'Test Risk', 'High', 'High', 'Open', 'Test String'); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<ProjectItem__c> accessResult2 = ProjectControllerExt.getProjectRisks(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }       
        Test.stopTest();
        
        System.assertEquals('Test Risk', addResult.Title__c);
        System.assertEquals(testProject.Id, addResult.Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals('Test Risk', addResult.Title__c);
        List<ProjectItem__c> getResults2 = ProjectControllerExt.getProjectRisks(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    } 
    
    static testMethod void test_stakeholders() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser1 = createTestUser('userP19','standarduserP19@agourasoftware.com','Testing P19','standarduserP19@agourasoftware.com');
        User testUser2 = createTestUser('userP20','standarduserP20@agourasoftware.com','Testing P20','standarduserP20@agourasoftware.com');
        ProjectItem__c testSwimLane = ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');
        
        Test.startTest();
        ProjectItem__c addResult1 = ProjectControllerExt.addStakeholder(testProject.Id, 'Project Stakeholder', testUser1.Id, 'Responsible', 
                                                                                       testSwimLane.Id, 'Edit Access');
        ProjectItem__c addResult2 = ProjectControllerExt.addStakeholder(testProject.Id, 'Project Stakeholder', testUser2.Id, 'Informed', 
                                                                                       '', 'Read Access');
        List<ProjectItem__c> getResults = ProjectControllerExt.getProjectStakeholders(testProject.Id);
        ProjectItem__c removeResult1 = ProjectControllerExt.removeProjectItem(addResult1.Id);
        ProjectItem__c removeResult2 = ProjectControllerExt.removeProjectItem(addResult2.Id);
        System.runas(testUser1) {
            try {
                ProjectItem__c accessResult = ProjectControllerExt.addStakeholder(testProject.Id, 'Project Stakeholder', testUser1.Id, 'Responsible', 
                                                                                       testSwimLane.Id, 'Edit Access'); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<ProjectItem__c> accessResult2 = ProjectControllerExt.getProjectStakeholders(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser1.Id, addResult1.User__c);
        System.assertEquals(testProject.Id, addResult1.Project__c);
        System.assertEquals(testUser2.Id, addResult2.User__c);
        System.assertEquals(testProject.Id, addResult2.Project__c);
        System.assertEquals(2, getResults.size());
        System.assertEquals(testUser1.Id, getResults.get(0).User__c);
        System.assertEquals(testUser2.Id, getResults.get(1).User__c);      
        List<ProjectItem__c> getResults2 = ProjectControllerExt.getProjectStakeholders(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_swimlanes() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP21','standarduserP21@agourasoftware.com','Testing P21','standarduserP21@agourasoftware.com');
        
        Test.startTest();
        ProjectItem__c testSwimLane = ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');
        List<ProjectItem__c> getResults = ProjectControllerExt.getProjectSwimLanes(testProject.Id);
        ProjectItem__c removeResult = ProjectControllerExt.removeProjectItem(testSwimLane.Id);
        System.runas(testUser) {
            try {
                ProjectItem__c accessResult = ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<ProjectItem__c> accessResult2 = ProjectControllerExt.getProjectSwimLanes(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals('Test Swim Lane', testSwimLane.Title__c);
        System.assertEquals(testProject.Id, testSwimLane.Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals(testSwimLane.Id, getResults.get(0).Id);
        List<ProjectItem__c> getResults2 = ProjectControllerExt.getProjectSwimLanes(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_sprints() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userP22','standarduserP22@agourasoftware.com','Testing P22','standarduserP22@agourasoftware.com');
                        
        Test.startTest();
        List<Sprint__c> getResults1 = ProjectControllerExt.getProjectSprints(testProject.Id);
        Sprint__c removeResult = ProjectControllerExt.removeProjectSprint(testSprint.Id);
        List<Sprint__c> getResults2 = ProjectControllerExt.getProjectSprints(testProject.Id);
        System.runas(testUser) {
            try {
                Sprint__c accessResult = ProjectControllerExt.removeProjectSprint(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<Sprint__c> accessResult2 = ProjectControllerExt.getProjectSprints(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults1.size());
        System.assertEquals(testSprint.Id, getResults1.get(0).Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_links() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP23','standarduserP23@agourasoftware.com','Testing P23','standarduserP23@agourasoftware.com');
        
        Test.startTest();
        ProjectItem__c addResult1 = ProjectControllerExt.addLink(testProject.Id, 'Test Link 1', 'http://www.salesforce.com', testUser.Id);
        ProjectItem__c addResult2 = ProjectControllerExt.addLink(testProject.Id, 'Test Link 2', 'http://www.salesforce.com', '');
        List<ProjectItem__c> getResults = ProjectControllerExt.getProjectLinks(testProject.Id);
        ProjectItem__c removeResult1 = ProjectControllerExt.removeProjectItem(addResult1.Id);
        ProjectItem__c removeResult2 = ProjectControllerExt.removeProjectItem(addResult2.Id);
        System.runas(testUser) {
            try {
                ProjectItem__c accessResult = ProjectControllerExt.addLink(testProject.Id, 'Test Link 1', 'http://www.salesforce.com', testUser.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<ProjectItem__c> accessResult2 = ProjectControllerExt.getProjectLinks(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(2, getResults.size());
        System.assertEquals('Test Link 1', getResults.get(0).Title__c);
        System.assertEquals('Test Link 2', getResults.get(1).Title__c);
        System.assertEquals(testUser.Id, addResult1.User__c);
        System.assertEquals(testProject.Id, addResult1.Project__c);
        System.assertEquals(null, addResult2.User__c);
        System.assertEquals(testProject.Id, addResult2.Project__c);

        List<ProjectItem__c> getResults2 = ProjectControllerExt.getProjectLinks(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_createCloneProject() {
        Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', null, null, null, 'Test String');
        List<String> cloneWhat = new List<String>{ 'Tags', 'Tasks', 'Project Swim Lane' };
        User testUser = createTestUser('userP24','standarduserP24@agourasoftware.com','Testing P24','standarduserP24@agourasoftware.com');
            
        ProjectItem__c testSwimLane = ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');        
        System.assertEquals('Test Swim Lane', testSwimLane.Title__c);
        System.assertEquals(testProject.Id, testSwimLane.Project__c);
        
        Tag__c testTag = createTestTag('Test Tag');
        ProjectTagAssociation__c addResult2 = ProjectControllerExt.addProjectTag(testTag.id, testProject.Id);
        System.assertEquals(testTag.Id, addResult2.Tag__c);
        System.assertEquals(testProject.Id, addResult2.Project__c);

        ProjectTask__c testProjectTask1 = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, testSwimLane.Id, null); 
        ProjectTaskTagAssoc__c testProjectTaskTagAssoc = createTestProjectTaskTagAssoc(testTag.Id, testProjectTask1.Id);
        ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task 2', 5.0, testSwimLane.Id, testProjectTask1.Id);         
        
        Test.startTest();
        Id result = ProjectControllerExt.createCloneProject(testProject.Id, cloneWhat);
        System.runas(testUser) {
            try {
                Id accessResult = ProjectControllerExt.createCloneProject(testProject.Id, cloneWhat); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    static testMethod void test_feedPost() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        FeedItem testFeedItem = createFeedPost(testProject.Id);
        User testUser = createTestUser('userP25','standarduserP25@agourasoftware.com','Testing P25','standarduserP25@agourasoftware.com');
        
        Test.startTest();
        ProjectControllerExt.doChatterFeedPost(testFeedItem);
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testProject.Id];
        System.runas(testUser) {
            try {
                FeedItem testFeedItem2 = createFeedPost(testProject.Id); 
                ProjectControllerExt.doChatterFeedPost(testFeedItem2); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    }
    
    static testMethod void test_updateProjectTaskAbbreviation() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');        
        ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null); 
        User testUser = createTestUser('userP26','standarduserP26@agourasoftware.com','Testing P26','standarduserP26@agourasoftware.com');      
        testProject.Project_Abbreviation__c = 'TESTTESTTEST2';
        update testProject;
        
        Test.startTest();
        ProjectControllerExt.updateProjectTaskAbbreviation(testProject.Id, 'TESTTESTTEST2'); 
        System.runas(testUser) {
            try {
                ProjectControllerExt.updateProjectTaskAbbreviation(testProject.Id, 'TESTTESTTEST'); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();

        List<ProjectTask__c> results = [SELECT Id, Task_Number__c FROM ProjectTask__c WHERE Project__c = :testProject.Id];        
        System.assertEquals(1, results.size());
        System.assertEquals('TESTTESTTEST2-1', results.get(0).Task_Number__c);   
    }
    
    static testMethod void test_updateProjectStakeholders() {
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userP27','standarduserP27@agourasoftware.com','Testing P27','standarduserP27@agourasoftware.com');
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft',
                                                                Executive_Sponsor__c = userId,
                                                                Product_Owner__c = testUser.Id,
                                                                Scrum_Master__c = userId);
        
        Test.startTest();
        insert testProject;
        ProjectItem__c testProjectItem = new ProjectItem__c(Title__c = 'Executive Sponsor',
                                                                            Project__c = testProject.Id,
                                                                            Type__c = 'Executive Sponsor',
                                                                            User__c = testUser.Id,
                                                                            RACI__c = 'Informed');
        insert testProjectItem;
        ProjectControllerExt.updateProjectStakeholders(testProject.Id, userId, userId, userId, userId);
        ProjectControllerExt.updateProjectStakeholders(testProject.Id, userId, userId, userId, null);          
        System.runas(testUser) {
            try {
                ProjectControllerExt.updateProjectStakeholders(testProject.Id, userId, userId, userId, userId); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();

        List<ProjectItem__c> results = [SELECT Id, User__c FROM ProjectItem__c WHERE Project__c = :testProject.Id
                                               ORDER BY Type__c];        
        System.assertEquals(3, results.size());
        System.assertEquals(userId, results.get(0).User__c);   
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Account__c');
        Test.startTest();
        
        Map<String, String> results = ProjectControllerExt.getFieldLabelMap('Project__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Account__c'));     
		Test.stopTest();
    }
            
	static testMethod void test_getFieldHelpMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Project_Abbreviation__c');
        Test.startTest();
        
        Map<String, String> results = ProjectControllerExt.getFieldHelpMap('Project__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Project_Abbreviation__c'));     
		Test.stopTest();
    }
    
    static testMethod void test_getNumRecords() {
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userP30','standarduserP30@agourasoftware.com','Testing P30','standarduserP30@agourasoftware.com');
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft',
                                                                Executive_Sponsor__c = userId,
                                                                Product_Owner__c = testUser.Id,
                                                                Scrum_Master__c = userId);
        Project__c testProject2 = new Project__c(Title__c='Test Project 2',
                                                                Project_Abbreviation__c='TESTTESTTEST2',
                                                                Status__c='Draft',
                                                                Executive_Sponsor__c = userId,
                                                                Product_Owner__c = testUser.Id,
                                                                Scrum_Master__c = userId);
        
        Test.startTest();
        insert testProject;
        insert testProject2;        
        Map<String, Integer> results = ProjectControllerExt.getNumRecords(testProject.Id);        
        System.runas(testUser) {
            try {
                Map<String, Integer> results2 = ProjectControllerExt.getNumRecords(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
       
        System.assertEquals(1, results.get('projects'));           
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
    
    private static Project__c createTestProjectBig(String title, String abbrev, Id accountId, Id ideaBoardId, Id userId, String testString) {
        Project__c testProject = new Project__c(Title__c=title,
                                                                Project_Abbreviation__c=abbrev,
                                                                Status__c='Draft',
                                                                Account__c = accountId,
                                                                Idea_Board__c = ideaBoardId,
                                                                Executive_Sponsor__c = userId,
                                                                Product_Owner__c = userId,
                                                                Scrum_Master__c = userId,
                                                                Mission_Statement__c=testString, 
                                                                Product__c=testString, 
                                                                Deliverables__c=testString, 
                                                                KPIs__c=testString, 
                                                                Value_Trackers__c=testString, 
                                                                Assumptions__c=testString, 
                                                                Constraints__c=testString, 
                                                                Comments__c=testString);
        insert testProject;
        return testProject;
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
    
    private static User createAdminUser(String alias, String email, String lastName, String userName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User testUser = new User(Alias=alias, Email=email, 
                                 EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName=userName);        
        insert testUser;
        return testUser;
    }
    
    private static Group createTestGroup(String name, String developerName) {
        Group testGroup = new Group(Name=name, 
                                    DeveloperName=developerName);        
        insert testGroup;
        return testGroup;
    }
    
    private static Tag__c createTestTag(String name) {
        Tag__c testTag = new Tag__c(Name=name, 
                                                    For_IdeaBoards__c=True,
                                                    For_ProjectTasks__c=True,
                                                    For_Projects__c=True);
        insert testTag;
        return testTag;
    }
    
    private static IdeaBoard__c createTestIdeaBoard(String ideaBoardName) {
        IdeaBoard__c testIdeaBoard = new IdeaBoard__c(Title__c=ideaBoardName, 
                                                                      Status__c='Draft');        
        insert testIdeaBoard;
        return testIdeaBoard;
    }
    
    private static Account createTestAccount(String name) {
        Account testAccount = new Account(Name=name);
        insert testAccount;
        return testAccount;
    }
    
    private static ProjectTask__c createTestProjectTask(Id projectId, String title, Decimal points, Id swimLane, Id masterTask) {
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=projectId,
                                                                            Title__c=title,
                                                                            Points__c=points,
                                                                            Swim_Lane__c=swimLane,
                                                                            Master_Task__c=masterTask,
                                                                            Task_Number_Int__c=1);
        insert testProjectTask;
        return testProjectTask;
    }
    
    private static Sprint__c createTestSprint(Id projectId, String sprintLength) {
        Sprint__c testSprint = new Sprint__c(Project__c=projectId,
                                                             Sprint_Length__c=sprintLength,
                                                             Sprint_Number__c=1,
                                                             Sprint_Name__c='Sprint 1');
        insert testSprint;
        return testSprint;
    }
    
    private static ProjectTaskTagAssoc__c createTestProjectTaskTagAssoc(Id tagId, Id taskId) {
        ProjectTaskTagAssoc__c testProjectTaskTagAssoc = new ProjectTaskTagAssoc__c(Tag__c=tagId, 
                                                                                                    Project_Task__c=taskId);        
        insert testProjectTaskTagAssoc;
        return testProjectTaskTagAssoc;
    }
    
    private static FeedItem createFeedPost(Id recId) {
        FeedItem testFeedPost = new FeedItem(ParentId=recId,
                                             Type='TextPost',
                                             IsRichText=true,
                                             Body='Some text');                  
        return testFeedPost;
    } 
}
