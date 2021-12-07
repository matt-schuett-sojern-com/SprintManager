@isTest 
public class TestProjectItemCtlExt {
    
    static testMethod void test_recordAccess() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');       
        
        Test.startTest();
        List<UserRecordAccess> results = ProjectItemControllerExt.recordAccess(testProjectItem.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');  
        User testUser = createTestUser('userPI1','standarduserPI1@agourasoftware.com','Testing PI1','standarduserPI1@agourasoftware.com');      
        
        Test.startTest();
        ProjectItem__c results = ProjectItemControllerExt.getWebPageTitle(testProjectItem.Id);
        System.runas(testUser) {
            try {
                ProjectItem__c accessResult = ProjectItemControllerExt.getWebPageTitle(testProjectItem.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals('Test Swim Lane', results.get('Title__c'));
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectItem__c testProjectItem = createTestProjectStakeholder(userId, testProject.Id, 'Executive Sponsor', 'Informed');
        User testUser = createTestUser('userPI2','standarduserPI2@agourasoftware.com','Testing PI2','standarduserPI2@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectItemControllerExt.getUsers(testProjectItem.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectItemControllerExt.getUsers(testProjectItem.Id); 
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
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane'); 
        User testUser = createTestUser('userPI3','standarduserPI3@agourasoftware.com','Testing PI3','standarduserPI3@agourasoftware.com');       
        
        Test.startTest();
        Project__c results = ProjectItemControllerExt.getProject(testProjectItem.Id);
        System.runas(testUser) {
            try {
                Project__c accessResult = ProjectItemControllerExt.getProject(testProjectItem.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals('Test Project', results.get('Title__c'));
    } 
    
    static testMethod void test_projectSearch() {
        Id [] fixedResults = new Id[1]; 
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPI4','standarduserPI4@agourasoftware.com','Testing PI4','standarduserPI4@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectItemControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = ProjectItemControllerExt.projectSearch('Test', selectedIds);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userPI5','standarduserPI5@agourasoftware.com','Testing PI5','standarduserPI5@agourasoftware.com'); 
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = ProjectItemControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void test_getProjectSwimLanes() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');  
        User testUser = createTestUser('userPI6','standarduserPI6@agourasoftware.com','Testing PI6','standarduserPI6@agourasoftware.com');       
        
        Test.startTest();
        List<ProjectItem__c> getResults = ProjectItemControllerExt.getProjectSwimLanes(testProject.Id);
        System.runas(testUser) {
            try {
                List<ProjectItem__c> accessResult = ProjectItemControllerExt.getProjectSwimLanes(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults.size());
        System.assertEquals(testProjectItem.Id, getResults.get(0).Id);       
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userPI7','standarduserPI7@agourasoftware.com','Testing PI7','standarduserPI7@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = ProjectItemControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = ProjectItemControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Comments__c');
        Test.startTest();
        
        Map<String, String> results = ProjectItemControllerExt.getFieldLabelMap('ProjectItem__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Comments__c'));     
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
    
    private static ProjectItem__c createTestProjectItem(Id projectId, String typeStr, String title) {
        ProjectItem__c testProjectItem = new ProjectItem__c(Project__c=projectId,
                                                                            Type__c=typeStr,
                                                                            Title__c=title);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static ProjectItem__c createTestProjectStakeholder(Id userId, Id projectId, String typeStr, String raci) {
        ProjectItem__c testProjectItem = new ProjectItem__c(Title__c = userId,
                                                                            Project__c = projectId,
                                                                            Type__c = typeStr,
                                                                            User__c = userId,
                                                                            RACI__c = raci);
        insert testProjectItem;
        return testProjectItem;
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
