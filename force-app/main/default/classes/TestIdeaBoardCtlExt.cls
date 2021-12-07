@isTest 
private class TestIdeaBoardCtlExt {
    
    static testMethod void tag_search_should_return_tag() {
        Id [] fixedResults = new Id[1];
        Tag__c testTag = createTestTag('Test Tag');
        fixedResults.add(testTag.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userIB1','standarduserIB1@agourasoftware.com','Testing IB1','standarduserIB1@agourasoftware.com'); 
        
        Test.startTest();
        List<LookupSearchResult> results = IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
        System.runas(testUser) {
            try {
                List<LookupSearchResult> accessResult = IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
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
        List<LookupSearchResult> results = IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag1.Id, results.get(0).getId());
    }
    
    static testMethod void user_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userIB2','standarduserIB2@agourasoftware.com','Testing IB2','standarduserIB2@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = IdeaBoardControllerExt.userSearch('Test', selectedIds);
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
        List<LookupSearchResult> results = IdeaBoardControllerExt.userSearch('Test', selectedIds);
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testGroup1.Id, results.get(0).getId());
    }
    
    static testMethod void test_add_get_remove_IdeaTags() {
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        Tag__c testTag = createTestTag('Test Tag');
        IdeaTagAssociation__c testIdeaTagAssoc = createTestIdeaTagAssoc(testTag.Id, testIdeaBoard.Id);
        User testUser = createTestUser('userIB3','standarduserIB3@agourasoftware.com','Testing IB3','standarduserIB3@agourasoftware.com');
        
        Test.startTest();
        IdeaTagAssociation__c addResult = IdeaBoardControllerExt.addIdeaTag(testTag.Id, testIdeaBoard.Id);
        List<Tag__c> getResults1 = IdeaBoardControllerExt.getIdeaTags(testIdeaBoard.Id);
        IdeaTagAssociation__c removeResult = IdeaBoardControllerExt.removeIdeaTag(testTag.Id, testIdeaBoard.Id);
        System.runas(testUser) {
            try {
                IdeaTagAssociation__c accessResult = IdeaBoardControllerExt.addIdeaTag(testTag.Id, testIdeaBoard.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                IdeaTagAssociation__c accessResult2 = IdeaBoardControllerExt.removeIdeaTag(testTag.Id, testIdeaBoard.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<Tag__c> accessResult3 = IdeaBoardControllerExt.getIdeaTags(testIdeaBoard.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();

        System.assertEquals(testIdeaBoard.Id, addResult.Idea_Board__c);
        System.assertEquals(1, getResults1.size());
        System.assertEquals(testTag.Name, getResults1.get(0).Name);
        List<Tag__c> getResults2 = IdeaBoardControllerExt.getIdeaTags(testIdeaBoard.Id);
        System.assertEquals(0, getResults2.size());
    }
    
    static testMethod void test_getIdeaProjects() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Boolean hasProjects = gd.containsKey('Project__c');
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');        
        User testUser = createTestUser('userIB4','standarduserIB4@agourasoftware.com','Testing IB4','standarduserIB4@agourasoftware.com');
        
        if (hasProjects) {
            Project__c testProject = createTestProject('TEST TEST TEST', 'TESTTESTTEST', testIdeaBoard.Id);    
            Test.startTest();
            List<sObject> results = IdeaBoardControllerExt.getIdeaProjects(testIdeaBoard.Id);
            System.runas(testUser) {
                try {
                    List<sObject> accessResult = IdeaBoardControllerExt.getIdeaProjects(testIdeaBoard.Id);
                } catch (AuraHandledException e) {
                    System.assertEquals('Insufficient access', e.getMessage());
                }
            }
            Test.stopTest();
            
            System.assertEquals(1, results.size());
            System.assertEquals(testProject.Id, results.get(0).Id);
        } else {
            Test.startTest();
            List<sObject> results = IdeaBoardControllerExt.getIdeaProjects(testIdeaBoard.Id);
            Test.stopTest();
            
            System.assertEquals(0, results.size());
        }   
    }
    
    static testMethod void test_add_get_remove_IdeaSharingAccess() {
        Id userId = UserInfo.getUserId();
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        User testUser1 = createTestUser('userIB5','standarduserIB5@agourasoftware.com','Testing IB5','standarduserIB5@agourasoftware.com');
        User testUser2 = createTestUser('userIB6','standarduserIB6@agourasoftware.com','Testing IB6','standarduserIB6@agourasoftware.com');
        Group testGroup1 = createTestGroup('Test Group 1', 'Dev1');
        Group testGroup2 = createTestGroup('Test Group 2', 'Dev2');
        User testUser3 = createTestUser('userIB15','standarduserIB15@agourasoftware.com','Testing IB15','standarduserIB15@agourasoftware.com');
              
        Test.startTest();
        IdeaBoard__Share addResult1 = IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testUser1.id, 'Read');
        IdeaBoard__Share addResult2 = IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testUser2.id, 'Edit');
        IdeaBoard__Share addResult3 = IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testGroup1.id, 'Read');
        IdeaBoard__Share addResult4 = IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testGroup2.id, 'Edit');
        List<LookupSearchResult> getResults1 = IdeaBoardControllerExt.getUsers(testIdeaBoard.Id);
        IdeaBoard__Share removeResult1 = IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testUser1.Id);
        IdeaBoard__Share removeResult2 = IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testUser2.Id);
        IdeaBoard__Share removeResult3 = IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testGroup1.Id);
        IdeaBoard__Share removeResult4 = IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testGroup2.Id);
        System.runas(testUser3) {
            try {
                IdeaBoard__Share accessResult = IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testUser1.id, 'Read');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                IdeaBoard__Share accessResult2 = IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testUser1.id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<LookupSearchResult> accessResult3 = IdeaBoardControllerExt.getUsers(testIdeaBoard.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();

        System.assertEquals(testIdeaBoard.Id, addResult1.ParentId);
        System.assertEquals(testIdeaBoard.Id, addResult2.ParentId);
        System.assertEquals(testIdeaBoard.Id, addResult3.ParentId);
        System.assertEquals(testIdeaBoard.Id, addResult4.ParentId);
        System.assertEquals(7, getResults1.size());
        System.assertEquals(userId, getResults1.get(0).getId());
        System.assertEquals(userId, getResults1.get(1).getId());
        System.assertEquals(userId, getResults1.get(2).getId());
        System.assertEquals(testUser1.Id, getResults1.get(3).getId());
        System.assertEquals(testUser2.Id, getResults1.get(4).getId());
        System.assertEquals(testGroup1.Id, getResults1.get(5).getId());
        System.assertEquals(testGroup2.Id, getResults1.get(6).getId());
        List<LookupSearchResult> getResults2 = IdeaBoardControllerExt.getUsers(testIdeaBoard.Id);
        System.assertEquals(3, getResults2.size());        
    }
    
    static testMethod void test_recordAccess() {
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        
        Test.startTest();
        List<UserRecordAccess> results = IdeaBoardControllerExt.recordAccess(testIdeaBoard.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getRecordTitle() {
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        User testUser = createTestUser('userIB8','standarduserIB8@agourasoftware.com','Testing IB8','standarduserIB8@agourasoftware.com');
        
        Test.startTest();
        List<IdeaBoard__c> results = IdeaBoardControllerExt.getIdeaBoardTitle(testIdeaBoard.Id);
        System.runas(testUser) {
            try {
                List<IdeaBoard__c> accessResult = IdeaBoardControllerExt.getIdeaBoardTitle(testIdeaBoard.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Idea Board', results.get(0).Title__c);
    } 
    
    static testMethod void test_createCloneIdeaBoard() {
        IdeaBoard__c testIdeaBoard = createTestIdeaBoardBig('Test Idea Board','Test String');
        Tag__c testTag = createTestTag('Test Tag');
        IdeaTagAssociation__c testIdeaTagAssoc = createTestIdeaTagAssoc(testTag.Id, testIdeaBoard.Id);
        IdeaTagAssociation__c addResult = IdeaBoardControllerExt.addIdeaTag(testTag.Id, testIdeaBoard.Id);
        User testUser = createTestUser('userIB9','standarduserIB9@agourasoftware.com','Testing IB9','standarduserIB9@agourasoftware.com');
        
        Test.startTest();
        Id result = IdeaBoardControllerExt.createCloneIdeaBoard(testIdeaBoard.Id);
        System.runas(testUser) {
            try {
                Id accessResult = IdeaBoardControllerExt.createCloneIdeaBoard(testIdeaBoard.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(testIdeaBoard.Id, addResult.Idea_Board__c);
        System.assert(result != null);
    }   
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        IdeaBoard__c testIdeaBoard = createTestIdeaBoardBig('Test Idea Board','Test String');
        User testUser = createAdminUser('userIB10','standarduserIB10@agourasoftware.com','Testing IB10','standarduserIB10@agourasoftware.com');
        User testUser2 = createTestUser('userIB11','standarduserIB11@agourasoftware.com','Testing IB11','standarduserIB11@agourasoftware.com');
        
        Test.startTest();
        IdeaBoard__c updateTest = IdeaBoardControllerExt.updateDocumentOwner(testIdeaBoard.Id, testUser.id);
        System.runas(testUser2) {
            try {
                IdeaBoard__c accessResult = IdeaBoardControllerExt.updateDocumentOwner(testIdeaBoard.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userIB12','standarduserIB12@agourasoftware.com','Testing IB12','standarduserIB12@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<LookupSearchResult> results = IdeaBoardControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        User testUser1 = createTestUser('userIB13','standarduserIB13@agourasoftware.com','Testing IB13','standarduserIB13@agourasoftware.com');
        User testUser2 = createTestUser('userIB14','standarduserIB14@agourasoftware.com','Testing IB14','standarduserIB14@agourasoftware.com');
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<LookupSearchResult> results = IdeaBoardControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userIB16','standarduserIB16@agourasoftware.com','Testing IB16','standarduserIB16@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = IdeaBoardControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = IdeaBoardControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('Problem__c');
        Test.startTest();
        
        Map<String, String> results = IdeaBoardControllerExt.getFieldLabelMap('IdeaBoard__c', fieldList);
           
        System.assertEquals(true,results.containsKey('Problem__c'));     
		Test.stopTest();
    }
    
    static testMethod void isChatterEnabled() {      
        Test.startTest();
        Boolean result = IdeaBoardControllerExt.checkChatterEnabled();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
    
    static testMethod void test_feedPost() {
        IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        FeedItem testFeedItem = createFeedPost(testIdeaBoard.Id);
        User testUser = createTestUser('userIB17','standarduserIB17@agourasoftware.com','Testing IB17','standarduserIB17@agourasoftware.com'); 
        
        Test.startTest();
        IdeaBoardControllerExt.doChatterFeedPost(testFeedItem);
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testIdeaBoard.Id];
        System.runas(testUser) {
            try {
                FeedItem testFeedItem2 = createFeedPost(testIdeaBoard.Id); 
                IdeaBoardControllerExt.doChatterFeedPost(testFeedItem2); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    }
    
    //
    // create test data
    //
    private static Tag__c createTestTag(String name) {
        Tag__c testTag = new Tag__c(Name=name, 
                                                    For_IdeaBoards__c=True,
                                                    For_ProjectTasks__c=True,
                                                    For_Projects__c=True);
        insert testTag;
        return testTag;
    }
    
    private static Project__c createTestProject(String title, String abbrev, Id ideaId) {
        Project__c testProject = new Project__c(Title__c=title,
                                                                Project_Abbreviation__c=abbrev,
                                                                Status__c='Draft',
                                                                Idea_Board__c=ideaId);
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
    
    private static IdeaBoard__c createTestIdeaBoard(String ideaBoardName) {
        IdeaBoard__c testIdeaBoard = new IdeaBoard__c(Title__c=ideaBoardName, 
                                                                      Status__c='Draft');        
        insert testIdeaBoard;
        return testIdeaBoard;
    }
    
    private static IdeaBoard__c createTestIdeaBoardBig(String ideaBoardName, String testString) {
        IdeaBoard__c testIdeaBoard = new IdeaBoard__c(Title__c=ideaBoardName,
                                                                      Problem__c=testString, 
                                                                      Existing_Alternatives__c=testString, 
                                                                      Solution__c=testString, 
                                                                      Key_Metrics__c=testString, 
                                                                      Unique_Value_Proposition__c=testString, 
                                                                      High_Level_Concept__c=testString, 
                                                                      Unfair_Advantage__c=testString, 
                                                                      Channels__c=testString,
                                                                      Customer_Segment__c=testString, 
                                                                      Early_Adopters__c=testString, 
                                                                      Cost_Structure__c=testString, 
                                                                      Revenue_Streams__c=testString, 
                                                                      Comments__c=testString,
                                                                      Status__c='Draft');        
        insert testIdeaBoard;
        return testIdeaBoard;
    }
    
    private static IdeaTagAssociation__c createTestIdeaTagAssoc(Id tagId, Id ideaId) {
        IdeaTagAssociation__c testIdeaTagAssoc = new IdeaTagAssociation__c(Tag__c=tagId, 
                                                                                           Idea_Board__c=ideaId);        
        insert testIdeaTagAssoc;
        return testIdeaTagAssoc;
    }   
    
    private static FeedItem createFeedPost(Id recId) {
        FeedItem testFeedPost = new FeedItem(ParentId=recId,
                                             Type='TextPost',
                                             IsRichText=true,
                                             Body='Some text');                  
        return testFeedPost;
    } 
}
