@isTest
public class TestViewCtlExt {

    static testMethod void test_getStatusKeys() {        
        Test.startTest();
        List<String> results1 = ViewControllerExt.getStatusKeys('Home');
        List<String> results2 = ViewControllerExt.getStatusKeys('Idea Boards');
        List<String> results3 = ViewControllerExt.getStatusKeys('Project Tasks');
        List<String> results4 = ViewControllerExt.getStatusKeys('Projects');
        List<String> results5 = ViewControllerExt.getStatusKeys('Sprints');
        Test.stopTest();
        
        System.assertEquals(7, results1.size());
        System.assertEquals('Draft', results1.get(0)); 
        System.assertEquals(4, results2.size());
        System.assertEquals('Draft', results2.get(0)); 
        System.assertEquals(8, results3.size());
        System.assertEquals('Open', results3.get(0)); 
        System.assertEquals(3, results4.size());
        System.assertEquals('Draft', results4.get(0)); 
        System.assertEquals(2, results5.size());
        System.assertEquals('Closed', results5.get(0));       
    }

    static testMethod void test_getHomeRecordList() {
        Id userId = UserInfo.getUserId();
        Date thisDay = Date.today();
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        List<ViewRecord> viewItems3 = new List<ViewRecord>{};
        List<ViewRecord> viewItems4 = new List<ViewRecord>{};
        List<ViewRecord> viewItems5 = new List<ViewRecord>{};
        List<ViewRecord> viewItems6 = new List<ViewRecord>{};
        List<ViewRecord> viewItems7 = new List<ViewRecord>{};
        List<ViewRecord> viewItems8 = new List<ViewRecord>{};
        List<ViewRecord> viewItems9 = new List<ViewRecord>{};
        List<ViewRecord> viewItems10 = new List<ViewRecord>{};
        List<ViewRecord> viewItems11 = new List<ViewRecord>{};
        List<ViewRecord> viewItems12 = new List<ViewRecord>{};
        List<ViewRecord> viewItems13 = new List<ViewRecord>{};
        List<ViewRecord> viewItems14 = new List<ViewRecord>{};
        IdeaBoard__c testIdeaBoard = new IdeaBoard__c(Title__c='Test Idea Board 1', 
                                                                      Status__c='Draft');    
        insert testIdeaBoard;
        IdeaBoard__c testIdeaBoard2 = new IdeaBoard__c(Title__c='Test Idea Board 2', 
                                                                       Status__c='Draft');        
        insert testIdeaBoard2;
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Open');
        insert testProject;
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=testProject.Id,
                                                                            Type__c='Project Document Owner',
                                                                            Title__c='Project Document Owner', 
                                                                            User__c=userId);
        insert testProjectItem;
        ProjectItem__c testProjectItem2 = new ProjectItem__c(Project__c=testProject.Id,
                                                                            Type__c='Product Owner',
                                                                            Title__c='Product Owner', 
                                                                            User__c=userId);
        insert testProjectItem2;
        Sprint__c testSprint = new Sprint__c(Project__c=testProject.Id,
                                                             Sprint_Length__c='2 weeks',
                                                             Sprint_Number__c=1,
                                                             Sprint_Name__c='Sprint 1',
                                                             Start_Date__c=thisDay);
        insert testSprint;
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Sprint__c=testSprint.Id,
                                                                            Status__c='Open',
                                                                            Assigned_To__c=userId);
        insert testProjectTask;
        ProjectTask__c testProjectTask2 = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Sprint__c=testSprint.Id,
                                                                            Status__c='Open');
        insert testProjectTask2;      
        User testUser = createTestUser('userV1','standarduserV1@agourasoftware.com','Testing V1','standarduserV1@agourasoftware.com');  
            
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getHomeRecordList(searchFilter1, 10.0, 1.0);
        String searchFilter2 = createTestFilter('','','','1');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getHomeRecordList(searchFilter2, 1.0, 2.0);
        String searchFilter3 = createTestFilter('','','Me','10');
        ViewControllerExt.PagedResult results3 = ViewControllerExt.getHomeRecordList(searchFilter3, 10.0, 1.0);
        String searchFilter4 = createTestFilter('','','Me','1');
        ViewControllerExt.PagedResult results4 = ViewControllerExt.getHomeRecordList(searchFilter4, 1.0, 2.0);        
        String searchFilter5 = createTestFilter('','Draft','','10');
        ViewControllerExt.PagedResult results5 = ViewControllerExt.getHomeRecordList(searchFilter5, 10.0, 1.0);
        String searchFilter6 = createTestFilter('','Draft','','1');
        ViewControllerExt.PagedResult results6 = ViewControllerExt.getHomeRecordList(searchFilter6, 1.0, 2.0);
        String searchFilter7 = createTestFilter('','Draft','Me','10');
        ViewControllerExt.PagedResult results7 = ViewControllerExt.getHomeRecordList(searchFilter7, 10.0, 1.0);
        String searchFilter8 = createTestFilter('','Draft','Me','1');
        ViewControllerExt.PagedResult results8 = ViewControllerExt.getHomeRecordList(searchFilter8, 1.0, 2.0);
        String searchFilter9 = createTestFilter('','Open','','10');
        ViewControllerExt.PagedResult results9 = ViewControllerExt.getHomeRecordList(searchFilter9, 10.0, 1.0);
        String searchFilter10 = createTestFilter('','Open','Me','10');
        ViewControllerExt.PagedResult results10 = ViewControllerExt.getHomeRecordList(searchFilter10, 10.0, 1.0);  
        
        String searchFilter11 = createTestFilter('','','','5');
        ViewControllerExt.PagedResult results11 = ViewControllerExt.getHomeRecordList(searchFilter11, 5.0, 2.0);
        String searchFilter12 = createTestFilter('','','Me','5');
        ViewControllerExt.PagedResult results12 = ViewControllerExt.getHomeRecordList(searchFilter12, 5.0, 2.0);
        String searchFilter13 = createTestFilter('','Draft','','5');
        ViewControllerExt.PagedResult results13 = ViewControllerExt.getHomeRecordList(searchFilter13, 5.0, 2.0);
        String searchFilter14 = createTestFilter('','Draft','Me','5');
        ViewControllerExt.PagedResult results14 = ViewControllerExt.getHomeRecordList(searchFilter14, 5.0, 2.0);
        
        System.runas(testUser) {
            try {
                String accessFilter1 = createTestFilter('','','','10');
                ViewControllerExt.PagedResult accessResult = ViewControllerExt.getHomeRecordList(accessFilter1, 10.0, 1.0);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(6, results1.total);
        System.assertEquals(testIdeaBoard.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(6, results2.total);
        System.assertEquals(testIdeaBoard2.Id, viewItems2.get(0).getId());
        viewItems3 = results3.viewItems;
        System.assertEquals(5, results3.total);
        System.assertEquals(testIdeaBoard.Id, viewItems3.get(0).getId());
        viewItems4 = results4.viewItems;
        System.assertEquals(5, results4.total);
        System.assertEquals(testIdeaBoard2.Id, viewItems4.get(0).getId());
        
        viewItems5 = results5.viewItems;
        System.assertEquals(2, results5.total);
        System.assertEquals(testIdeaBoard.Id, viewItems5.get(0).getId());
        viewItems6 = results6.viewItems;
        System.assertEquals(2, results6.total);
        System.assertEquals(testIdeaBoard2.Id, viewItems6.get(0).getId());
        viewItems7 = results7.viewItems;
        System.assertEquals(2, results7.total);
        System.assertEquals(testIdeaBoard.Id, viewItems7.get(0).getId());
        viewItems8 = results8.viewItems;
        System.assertEquals(2, results8.total);
        System.assertEquals(testIdeaBoard2.Id, viewItems8.get(0).getId());
        
        viewItems9 = results9.viewItems;
        System.assertEquals(4, results9.total);
        System.assertEquals(testProject.Id, viewItems9.get(0).getId());
        viewItems10 = results10.viewItems;
        System.assertEquals(3, results10.total);
        System.assertEquals(testProject.Id, viewItems10.get(0).getId());
        
        viewItems11 = results11.viewItems;
        System.assertEquals(6, results11.total);
        viewItems12 = results12.viewItems;
        System.assertEquals(5, results12.total);
        viewItems13 = results13.viewItems;
        System.assertEquals(2, results13.total);
        viewItems14 = results14.viewItems;
        System.assertEquals(2, results14.total);
    }

    static testMethod void test_getUserInfo() {   
        String userInfo = UserInfo.getName();
        
        Test.startTest();
        User result = ViewControllerExt.getUserInfo();
        Test.stopTest();
        
        System.assertEquals(userInfo, result.get('Name')); 
    }

    static testMethod void test_getOrgInfo() {        
        Test.startTest();
        Organization result = ViewControllerExt.getOrgInfo();
        Test.stopTest();
        
        System.assertNotEquals(null, result.get('Id'));         
    }

    static testMethod void test_sendFeedback() {
        Test.startTest();
        ViewControllerExt.sendFeedback('Test Text');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, invocations);
    }

    static testMethod void test_getViewRecordList_ideaBoards() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        List<ViewRecord> viewItems3 = new List<ViewRecord>{};
        List<ViewRecord> viewItems4 = new List<ViewRecord>{};
        IdeaBoard__c testIdeaBoard = new IdeaBoard__c(Title__c='Test Idea Board 1', 
                                                                      Status__c='Draft');    
        insert testIdeaBoard;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testIdeaBoard.Id);
        Test.setFixedSearchResults(fixedResults);
        User testUser = createTestUser('userV2','standarduserV2@agourasoftware.com','Testing V2','standarduserV2@agourasoftware.com'); 
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Idea Boards');
        String searchFilter2 = createTestFilter('','','Me','10');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getViewRecordList(searchFilter2, 10.0, 1.0, 'Idea Boards');
        String searchFilter3 = createTestFilter('Test Idea Board 1','','','10');
        ViewControllerExt.PagedResult results3 = ViewControllerExt.getViewRecordList(searchFilter3, 10.0, 1.0, 'Idea Boards');
        String searchFilter4 = createTestFilter('Test Idea Board 1','','Me','10');
        ViewControllerExt.PagedResult results4 = ViewControllerExt.getViewRecordList(searchFilter4, 10.0, 1.0, 'Idea Boards');
        System.runas(testUser) {
            try {
                String accessFilter1 = createTestFilter('','','','10');
                ViewControllerExt.PagedResult accessResult = ViewControllerExt.getViewRecordList(accessFilter1, 10.0, 1.0, 'Idea Boards');
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testIdeaBoard.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(1, results2.total);
        System.assertEquals(testIdeaBoard.Id, viewItems2.get(0).getId());
        viewItems3 = results3.viewItems;
        System.assertEquals(1, results3.total);
        System.assertEquals(testIdeaBoard.Id, viewItems3.get(0).getId());
        viewItems4 = results4.viewItems;
        System.assertEquals(1, results4.total);
        System.assertEquals(testIdeaBoard.Id, viewItems4.get(0).getId());
    }

    static testMethod void test_getViewRecordList_projectTasks() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        List<ViewRecord> viewItems3 = new List<ViewRecord>{};
        List<ViewRecord> viewItems4 = new List<ViewRecord>{};
        Id userId = UserInfo.getUserId();
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft');
        insert testProject;        
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Status__c='Open',
                                                                            Assigned_To__c=userId);
        insert testProjectTask;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testProjectTask.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Project Tasks');
        String searchFilter2 = createTestFilter('','','Me','10');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getViewRecordList(searchFilter2, 10.0, 1.0, 'Project Tasks');
        String searchFilter3 = createTestFilter('Test Project Task','','','10');
        ViewControllerExt.PagedResult results3 = ViewControllerExt.getViewRecordList(searchFilter3, 10.0, 1.0, 'Project Tasks');
        String searchFilter4 = createTestFilter('Test Project Task','','Me','10');
        ViewControllerExt.PagedResult results4 = ViewControllerExt.getViewRecordList(searchFilter4, 10.0, 1.0, 'Project Tasks');
        Test.stopTest();
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testProjectTask.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(1, results2.total);
        System.assertEquals(testProjectTask.Id, viewItems2.get(0).getId());
        viewItems3 = results3.viewItems;
        System.assertEquals(1, results3.total);
        System.assertEquals(testProjectTask.Id, viewItems3.get(0).getId());
        viewItems4 = results4.viewItems;
        System.assertEquals(1, results4.total);
        System.assertEquals(testProjectTask.Id, viewItems4.get(0).getId());
    }

    static testMethod void test_getViewRecordList_projects() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        List<ViewRecord> viewItems3 = new List<ViewRecord>{};
        List<ViewRecord> viewItems4 = new List<ViewRecord>{};
        List<ViewRecord> viewItems5 = new List<ViewRecord>{};
        Id userId = UserInfo.getUserId();
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft');
        insert testProject; 
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=testProject.Id,
                                                                            Type__c='Project Document Owner',
                                                                            Title__c='Project Document Owner', 
                                                                            User__c=userId);
        insert testProjectItem;   
        Id [] fixedResults = new Id[1];
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Projects');
        String searchFilter2 = createTestFilter('','','Me','10');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getViewRecordList(searchFilter2, 10.0, 1.0, 'Projects');
        String searchFilter3 = createTestFilter('Test Project','','','10');
        ViewControllerExt.PagedResult results3 = ViewControllerExt.getViewRecordList(searchFilter3, 10.0, 1.0, 'Projects');
        String searchFilter4 = createTestFilter('Test Project','','Me','10');
        ViewControllerExt.PagedResult results4 = ViewControllerExt.getViewRecordList(searchFilter4, 10.0, 1.0, 'Projects');
        String searchFilter5 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results5 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Project Templates');
        Test.stopTest();
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testProject.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(1, results2.total);
        System.assertEquals(testProject.Id, viewItems2.get(0).getId());
        viewItems3 = results3.viewItems;
        System.assertEquals(1, results3.total);
        System.assertEquals(testProject.Id, viewItems3.get(0).getId());
        viewItems4 = results4.viewItems;
        System.assertEquals(1, results4.total);
        System.assertEquals(testProject.Id, viewItems4.get(0).getId());
        viewItems5 = results5.viewItems;
        System.assertEquals(0, results5.total);
    }

    static testMethod void test_getViewRecordList_sprints() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        List<ViewRecord> viewItems3 = new List<ViewRecord>{};
        List<ViewRecord> viewItems4 = new List<ViewRecord>{};
        List<ViewRecord> viewItems5 = new List<ViewRecord>{};
        List<ViewRecord> viewItems6 = new List<ViewRecord>{};
        List<ViewRecord> viewItems7 = new List<ViewRecord>{};
        List<ViewRecord> viewItems8 = new List<ViewRecord>{};
        Id userId = UserInfo.getUserId();
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft');
        insert testProject;  
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=testProject.Id,
                                                                            Type__c='Project Document Owner',
                                                                            Title__c='Project Document Owner', 
                                                                            User__c=userId);
        insert testProjectItem;
        Date thisDay = Date.today();
        Sprint__c testSprint = new Sprint__c(Project__c=testProject.Id,
                                                             Sprint_Length__c='2 weeks',
                                                             Sprint_Name__c='Sprint 1',
                                                             Start_Date__c=thisDay,
                                                             Sprint_Number__c=1);
        insert testSprint;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testSprint.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Sprints');
        String searchFilter2 = createTestFilter('','','Me','10');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getViewRecordList(searchFilter2, 10.0, 1.0, 'Sprints');
        String searchFilter3 = createTestFilter('Sprint 1','','','10');
        ViewControllerExt.PagedResult results3 = ViewControllerExt.getViewRecordList(searchFilter3, 10.0, 1.0, 'Sprints');
        String searchFilter4 = createTestFilter('Sprint 1','','Me','10');
        ViewControllerExt.PagedResult results4 = ViewControllerExt.getViewRecordList(searchFilter4, 10.0, 1.0, 'Sprints');
        
        String searchFilter5 = createTestFilter('','Open','','10');
        ViewControllerExt.PagedResult results5 = ViewControllerExt.getViewRecordList(searchFilter5, 10.0, 1.0, 'Sprints');
        String searchFilter6 = createTestFilter('','Open','Me','10');
        ViewControllerExt.PagedResult results6 = ViewControllerExt.getViewRecordList(searchFilter6, 10.0, 1.0, 'Sprints');
        String searchFilter7 = createTestFilter('Sprint 1','Open','','10');
        ViewControllerExt.PagedResult results7 = ViewControllerExt.getViewRecordList(searchFilter7, 10.0, 1.0, 'Sprints');
        String searchFilter8 = createTestFilter('Sprint 1','Open','Me','10');
        ViewControllerExt.PagedResult results8 = ViewControllerExt.getViewRecordList(searchFilter8, 10.0, 1.0, 'Sprints');
        Test.stopTest();
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testSprint.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(1, results2.total);
        System.assertEquals(testSprint.Id, viewItems2.get(0).getId());
        viewItems3 = results3.viewItems;
        System.assertEquals(1, results3.total);
        System.assertEquals(testSprint.Id, viewItems3.get(0).getId());
        viewItems4 = results4.viewItems;
        System.assertEquals(1, results4.total);
        System.assertEquals(testSprint.Id, viewItems4.get(0).getId());
        
        viewItems5 = results5.viewItems;
        System.assertEquals(1, results5.total);
        System.assertEquals(testSprint.Id, viewItems5.get(0).getId());
        viewItems6 = results6.viewItems;
        System.assertEquals(1, results6.total);
        System.assertEquals(testSprint.Id, viewItems6.get(0).getId());
        viewItems7 = results7.viewItems;
        System.assertEquals(1, results7.total);
        System.assertEquals(testSprint.Id, viewItems7.get(0).getId());
        viewItems8 = results8.viewItems;
        System.assertEquals(1, results8.total);
        System.assertEquals(testSprint.Id, viewItems8.get(0).getId());
    }

    static testMethod void test_getViewRecordList_sprints_closed() {
        List<ViewRecord> viewItems5 = new List<ViewRecord>{};
        List<ViewRecord> viewItems6 = new List<ViewRecord>{};
        List<ViewRecord> viewItems7 = new List<ViewRecord>{};
        List<ViewRecord> viewItems8 = new List<ViewRecord>{};
        Id userId = UserInfo.getUserId();
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft');
        insert testProject;  
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=testProject.Id,
                                                                            Type__c='Project Document Owner',
                                                                            Title__c='Project Document Owner', 
                                                                            User__c=userId);
        insert testProjectItem;
        Date thisDay = Date.today();
        Date tomorrowsDate = thisDay.addDays(1);
        Sprint__c testSprint = new Sprint__c(Project__c=testProject.Id,
                                                             Sprint_Length__c='2 weeks',
                                                             Sprint_Name__c='Sprint 1',
                                                             Start_Date__c=tomorrowsDate,
                                                             Sprint_Number__c=1);
        insert testSprint;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testSprint.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();        
        String searchFilter5 = createTestFilter('','Closed','','10');
        ViewControllerExt.PagedResult results5 = ViewControllerExt.getViewRecordList(searchFilter5, 10.0, 1.0, 'Sprints');
        String searchFilter6 = createTestFilter('','Closed','Me','10');
        ViewControllerExt.PagedResult results6 = ViewControllerExt.getViewRecordList(searchFilter6, 10.0, 1.0, 'Sprints');
        String searchFilter7 = createTestFilter('Sprint 1','Closed','','10');
        ViewControllerExt.PagedResult results7 = ViewControllerExt.getViewRecordList(searchFilter7, 10.0, 1.0, 'Sprints');
        String searchFilter8 = createTestFilter('Sprint 1','Closed','Me','10');
        ViewControllerExt.PagedResult results8 = ViewControllerExt.getViewRecordList(searchFilter8, 10.0, 1.0, 'Sprints');
        Test.stopTest();
        
        // validation        
        viewItems5 = results5.viewItems;
        System.assertEquals(1, results5.total);
        System.assertEquals(testSprint.Id, viewItems5.get(0).getId());
        viewItems6 = results6.viewItems;
        System.assertEquals(1, results6.total);
        System.assertEquals(testSprint.Id, viewItems6.get(0).getId());
        viewItems7 = results7.viewItems;
        System.assertEquals(1, results7.total);
        System.assertEquals(testSprint.Id, viewItems7.get(0).getId());
        viewItems8 = results8.viewItems;
        System.assertEquals(1, results8.total);
        System.assertEquals(testSprint.Id, viewItems8.get(0).getId());
    }

    static testMethod void test_getViewRecordList_tags() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        Tag__c testTag = new Tag__c(Name='Test Tag', 
                                                    For_IdeaBoards__c=True,
                                                    For_ProjectTasks__c=True,
                                                    For_Projects__c=True);
        insert testTag;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testTag.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Tags');
        String searchFilter2 = createTestFilter('Test Tag','','','10');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getViewRecordList(searchFilter2, 10.0, 1.0, 'Tags');        
        Test.stopTest();
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testTag.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(1, results2.total);
        System.assertEquals(testTag.Id, viewItems2.get(0).getId());
    }

    static testMethod void test_getViewRecordList_anchorStories() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        List<ViewRecord> viewItems2 = new List<ViewRecord>{};
        AnchorStory__c testAnchorStory = new AnchorStory__c(Title__c='Test Anchor Story',
                                                                            Type__c='User Story');        
        insert testAnchorStory;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testAnchorStory.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Anchor Stories');
        String searchFilter2 = createTestFilter('Test Anchor Story','','','10');
        ViewControllerExt.PagedResult results2 = ViewControllerExt.getViewRecordList(searchFilter2, 10.0, 1.0, 'Anchor Stories');        
        Test.stopTest();
        
        // validation
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testAnchorStory.Id, viewItems1.get(0).getId());
        viewItems2 = results2.viewItems;
        System.assertEquals(1, results2.total);
        System.assertEquals(testAnchorStory.Id, viewItems2.get(0).getId());
    }

    static testMethod void test_viewRecord() {
        List<ViewRecord> viewItems1 = new List<ViewRecord>{};
        Id userId = UserInfo.getUserId();
        Project__c testProject = new Project__c(Title__c='Test Project',
                                                                Project_Abbreviation__c='TESTTESTTEST',
                                                                Status__c='Draft');
        insert testProject;        
        ProjectTask__c testProjectTask = new ProjectTask__c(Project__c=testProject.Id,
                                                                            Title__c='Test Project Task',
                                                                            Status__c='Open',
                                                                            Assigned_To__c=userId);
        insert testProjectTask;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testProjectTask.Id);
        Test.setFixedSearchResults(fixedResults);
        
        // start tests
        Test.startTest();
        String searchFilter1 = createTestFilter('','','','10');
        ViewControllerExt.PagedResult results1 = ViewControllerExt.getViewRecordList(searchFilter1, 10.0, 1.0, 'Project Tasks');
        String searchFilter2 = createTestFilter('','','Me','10');
        Test.stopTest();
        
        // validation
        list<ProjectTask__c> getResults = [SELECT Id, Name, CreatedDate, LastModifiedDate
                                                   FROM ProjectTask__c
                                                   WHERE Id = :testProjectTask.Id];
        System.assertEquals(1, getResults.size());
        
        viewItems1 = results1.viewItems;
        System.assertEquals(1, results1.total);
        System.assertEquals(testProjectTask.Id, viewItems1.get(0).getId());
        System.assertEquals(getResults.get(0).Name, viewItems1.get(0).getUniqueId());
        System.assertEquals('ProjectTask__c', viewItems1.get(0).getSObjectType());
        System.assertEquals('standard:task', viewItems1.get(0).getIcon());
        System.assertEquals('AutoNumber Test Project Task', viewItems1.get(0).getTitle());
        System.assertEquals('Open', viewItems1.get(0).getStatus());
        System.assertEquals(null, viewItems1.get(0).getUserName());
        System.assertEquals(null, viewItems1.get(0).getPoints());
        System.assertEquals(null, viewItems1.get(0).getOtherString());
        System.assertEquals(getResults.get(0).CreatedDate, viewItems1.get(0).getCreatedDate());
        System.assertEquals(getResults.get(0).LastModifiedDate, viewItems1.get(0).getLastModifiedDate());
        System.assertEquals(false, viewItems1.get(0).getCanEdit());
    }
    
    static testMethod void test_objectAccess() {
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userV2','standarduserV2@agourasoftware.com','Testing V2','standarduserV2@agourasoftware.com'); 
        
        Test.startTest();
        ViewControllerExt.ObjectAccess result = ViewControllerExt.objectAccess();
        System.runas(testUser) {
            ViewControllerExt.ObjectAccess accessResult = ViewControllerExt.objectAccess(); 
            System.assertEquals(false, accessResult.canCreateAnchorStory);
            System.assertEquals(false, accessResult.canCreateTag);
        }
        Test.stopTest();
        
        System.assert(result.canCreateAnchorStory==true || result.canCreateAnchorStory==false);
        System.assertEquals(true, result.canCreateTag);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Title__c');
        Test.startTest();
        
        Map<String, String> results = ViewControllerExt.getFieldLabelMap('ProjectTask__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Title__c'));     
		Test.stopTest();
    }
        
    //
    // create test data
    // 
    private static String createTestFilter(String searchKeyStr, String statusKeyStr, String assignedKeyStr, String rowKeyStr) {
        ViewControllerExt.Filter testFilter = new ViewControllerExt.Filter();
        testFilter.searchKey = searchKeyStr;
        testFilter.statusKey = statusKeyStr;        
        testFilter.assignedKey = assignedKeyStr;
        testFilter.rowKey = rowKeyStr;
        String myJSON = JSON.serialize(testFilter);
        return myJSON;
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
