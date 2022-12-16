@IsTest
private class TestCreatePublicNotesCntrl {
    static testMethod void save(){
        // insert the public note record
        Insolvency__c recordInsolvency= new Insolvency__c(name='dummy');
        insert recordInsolvency;
        Note recordNote = new Note(parentid = recordInsolvency.id, body ='hi', title = 'Bye');
        insert recordNote;
       
        test.startTest();
        PageReference pageRef = Page.CreatePublicNotes;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('parent_id',recordInsolvency.id);
        ApexPages.StandardController sc = new ApexPages.standardController(recordNote);
        
        CreatePublicNotesCntrl CreatePublicNotesCntrlController = new CreatePublicNotesCntrl(sc);
        CreatePublicNotesCntrlController.createNote.title = 'Test';
        CreatePublicNotesCntrlController.createNote.body = 'Test';
        CreatePublicNotesCntrlController.save();
        //CreatePublicNotesCntrlController.Cancel();
       //CreatePublicNotesCntrlController.getCommunityUrl();
        test.stopTest();
        
    }
  
    static testMethod void cancel(){
        // insert the public note record
        Insolvency__c recordInsolvency= new Insolvency__c(name='dummy');
        insert recordInsolvency;
        Note recordNote = new Note(parentid = recordInsolvency.id, body ='hi', title = 'Bye');
        insert recordNote;
       
        test.startTest();
        PageReference pageRef = Page.CreatePublicNotes;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('parent_id',recordInsolvency.id);
        ApexPages.currentPage().getParameters().put('id',recordNote.id);
        ApexPages.StandardController sc = new ApexPages.standardController(recordNote);
        
        CreatePublicNotesCntrl CreatePublicNotesCntrlController = new CreatePublicNotesCntrl(sc);
        //CreatePublicNotesCntrlController.createNote.title = 'Test';
        //CreatePublicNotesCntrlController.createNote.body = 'Test';
        //CreatePublicNotesCntrlController.save();
        CreatePublicNotesCntrlController.Cancel();
        test.stopTest();
        
    }
    
     static testMethod void testsave(){
         
         //Custom setting record creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Display_Duplicate_Accounts_List_View__c=10;
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;
         
         //Insolvency insertion
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        
        //insolv.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolv.Insolvency_Date__c = Date.Today().addMonths(-1);
        
        insolv.Insolvency_Type__c='Bankruptcy';
        insert insolv;

         Id devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        
         //Insolvency Account record insertion
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestDup -1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Excluded_from_Purchase__c=False;
        insolAcct.Excluded_Account_Comments__c='TestData';
        insolAcct.Is_Duplicate_Resolved__c=False;
        insolAcct.Insolvency_Type__c='Bankruptcy';
        insolAcct.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct.Product_Code__c='MOR';
        insolAcct.Debtor__c='test';
        insolAcct.PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct.Asset_Status__c='Bulk Purchased';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';    
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.recordTypeId = devRecordTypeId;
        insert insolAcct; 
       
       //Note record insertion
        Note recordNote = new Note(parentid = insolAcct.id, body ='hi', title = 'Bye');
        insert recordNote;
       
        test.startTest();
        PageReference pageRef = Page.CreatePublicNotes;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('parent_id',insolAcct.id);
        ApexPages.StandardController sc = new ApexPages.standardController(recordNote);
        
        //Calling methods 
        CreatePublicNotesCntrl CreatePublicNotesCntrlController = new CreatePublicNotesCntrl(sc);
        CreatePublicNotesCntrlController.createNote.title = 'Test';
        CreatePublicNotesCntrlController.createNote.body = 'Test';
        CreatePublicNotesCntrlController.save();
        CreatePublicNotesCntrlController.Cancel();
       //CreatePublicNotesCntrlController.getCommunityUrl();
        test.stopTest();
        
    } 
}