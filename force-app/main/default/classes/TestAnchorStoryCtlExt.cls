@isTest 
public class TestAnchorStoryCtlExt {

    static testMethod void test_recordAccess() {
        Id userId = UserInfo.getUserId();
        AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');      
        
        Test.startTest();
        List<UserRecordAccess> results = AnchorStoryControllerExt.recordAccess(testAnchorStory.Id);
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userAS12','standarduserAS12@agourasoftware.com','Testing AS12','standarduserAS12@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AnchorStoryControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AnchorStoryControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void test_getRecordTitle() {
        AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        User testUser = createTestUser('userAS2','standarduserAS2@agourasoftware.com','Testing AS2','standarduserAS2@agourasoftware.com'); 
        
        Test.startTest();
        List<AnchorStory__c> results = AnchorStoryControllerExt.getWebPageTitle(testAnchorStory.Id);
        System.runas(testUser) {
            try {
                List<AnchorStory__c> accessResult = AnchorStoryControllerExt.getWebPageTitle(testAnchorStory.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Record', results.get(0).Title__c);
    } 
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        User testUser = createTestUser('userAS3','standarduserAS3@agourasoftware.com','Testing AS3','standarduserAS3@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = AnchorStoryControllerExt.getUsers(testAnchorStory.Id);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = AnchorStoryControllerExt.getUsers(testAnchorStory.Id);
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
    
    static testMethod void test_anchorStorySearch() {
        Id [] fixedResults = new Id[1]; 
        AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        fixedResults.add(testAnchorStory.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userAS4','standarduserAS4@agourasoftware.com','Testing AS4','standarduserAS4@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = AnchorStoryControllerExt.anchorStorySearch('Test Record', selectedIds, '');
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = AnchorStoryControllerExt.anchorStorySearch('Test Record', selectedIds, ''); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAnchorStory.Id, results.get(0).getId());
    }
    
    static testMethod void test_cloneAndMasterTask() {
        Id [] fixedResults = new Id[1];
        AnchorStory__c testAnchorStoryMaster = createTestAnchorStory('Test Record'); 
        AnchorStory__c testAnchorStory = createTestAnchorStoryBig('Test Record', 'Test String', 10, testAnchorStoryMaster.Id);
        fixedResults.add(testAnchorStoryMaster.Id);
        Test.setFixedSearchResults(fixedResults);
        User testUser = createTestUser('userAS5','standarduserAS5@agourasoftware.com','Testing AS5','standarduserAS5@agourasoftware.com'); 
        
        Test.startTest();
        Id result = AnchorStoryControllerExt.createCloneAnchorStory(testAnchorStory.Id);        
        List<AnchorStory__c> resultMasterTask = AnchorStoryControllerExt.getMasterTask(testAnchorStory.Id);
        System.runas(testUser) {
            try {
                Id accessResult = AnchorStoryControllerExt.createCloneAnchorStory(testAnchorStory.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AnchorStory__c> accessResult2 = AnchorStoryControllerExt.getMasterTask(testAnchorStory.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();

        System.assert(result != null);
        System.assertEquals(testAnchorStoryMaster.Id, resultMasterTask.get(0).Master_Task__c);        
    }
    
    static testMethod void test_subTask() {
        Id [] fixedResults = new Id[1];
        AnchorStory__c testAnchorStoryMaster = createTestAnchorStory('Test Record'); 
        AnchorStory__c testAnchorStory = createTestAnchorStoryBig('Test Record', 'Test String', 10, testAnchorStoryMaster.Id);
        fixedResults.add(testAnchorStory.Id);
        Test.setFixedSearchResults(fixedResults);
        User testUser = createTestUser('userAS6','standarduserAS6@agourasoftware.com','Testing AS6','standarduserAS6@agourasoftware.com'); 
        
        Test.startTest();        
        List<AnchorStory__c> resultSubTask = AnchorStoryControllerExt.getSubTasks(testAnchorStoryMaster.Id);
        System.runas(testUser) {
            try {
                List<AnchorStory__c> accessResult = AnchorStoryControllerExt.getSubTasks(testAnchorStoryMaster.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
  		Test.stopTest();

        System.assertEquals(1, resultSubTask.size());
        System.assertEquals(testAnchorStory.Id, resultSubTask.get(0).Id);
    }
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        User testUser = createAdminUser('userAS7','standarduserAS7@agourasoftware.com','Testing AS7','standarduserAS7@agourasoftware.com'); 
        User testUser2 = createTestUser('userAS8','standarduserAS8@agourasoftware.com','Testing AS8','standarduserAS8@agourasoftware.com'); 
        
        Test.startTest();
        AnchorStory__c updateTest = AnchorStoryControllerExt.updateDocumentOwner(testAnchorStory.Id, testUser.id);
        System.runas(testUser2) {
            try {
                AnchorStory__c accessResult = AnchorStoryControllerExt.updateDocumentOwner(testAnchorStory.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userAS9','standarduserAS9@agourasoftware.com','Testing AS9','standarduserAS9@agourasoftware.com'); 
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = AnchorStoryControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        User testUser1 = createTestUser('userAS10','standarduserAS10@agourasoftware.com','Testing AS10','standarduserAS10@agourasoftware.com'); 
        User testUser2 = createTestUser('userAS11','standarduserAS11@agourasoftware.com','Testing AS11','standarduserAS11@agourasoftware.com'); 
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = AnchorStoryControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }
    
    static testMethod void test_projectSearch() {
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Id [] fixedResults = new Id[1]; 
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userAS13','standarduserAS13@agourasoftware.com','Testing AS13','standarduserAS13@agourasoftware.com');
        
        Test.startTest();
        List<LookupSearchResult> results = AnchorStoryControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = AnchorStoryControllerExt.projectSearch('Test', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void test_doCreateProjectTask() {
        AnchorStory__c testAnchorStory = createTestAnchorStoryBig('Test Record', 'Test String', 10, null);
        Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createAdminUser('userAS14','standarduserAS14@agourasoftware.com','Testing AS14','standarduserAS14@agourasoftware.com'); 
        
        Test.startTest();
        Id results2 = AnchorStoryControllerExt.doCreateProjectTask(testAnchorStory.Id, testProject.Id);
        System.runas(testUser) {
            try {
                Id accessResult = AnchorStoryControllerExt.doCreateProjectTask(testAnchorStory.Id, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertNotEquals(Null, results2);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Acceptance_Criteria__c');
        Test.startTest();
        
        Map<String, String> results = AnchorStoryControllerExt.getFieldLabelMap('AnchorStory__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Acceptance_Criteria__c'));     
		Test.stopTest();
    }
    
    //
    // create test data
    //
    private static AnchorStory__c createTestAnchorStory(String anchorStoryName) {
        AnchorStory__c testAnchorStory = new AnchorStory__c(Title__c=anchorStoryName,
                                                                            Type__c='User Story');        
        insert testAnchorStory;
        return testAnchorStory;
    }
    
    private static AnchorStory__c createTestAnchorStoryBig(String anchorStoryName, String testString, Decimal testDecimal, Id recId) {
        AnchorStory__c testAnchorStory = new AnchorStory__c(Title__c=anchorStoryName,
                                                                            Acceptance_Criteria__c=testString, 
                                                                            Comments__c=testString, 
                                                                            Components__c=testString, 
                                                                            Dependencies__c=testString, 
                                                                            Description__c=testString, 
                                                                            Master_Task__c=recId, 
                                                                            Points__c=testDecimal, 
                                                                            Priority__c='High', 
                                                                            Search_Terms__c=testString, 
                                                                            Time_Estimate__c=testDecimal, 
                                                                            Value__c=testString,
                                                                            Type__c='User Story');        
        insert testAnchorStory;
        return testAnchorStory;
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
}
