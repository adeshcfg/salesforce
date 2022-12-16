/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of DisplayJudgmentStagingController
*  @author : A5E Consulting
*  @date : 09/08/2022

*************************************************************************************************/
@isTest
public class TestDisplayJudgmentStagingController {
    //static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
     public static API_Call_Details__c testDocumentAPI(){
        // API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        //system.debug('settings:'+settings);
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
         settings.API_Request_Timeout__c = 90000;
        insert settings;
        return settings;
     }
    public static testMethod void testMethod1(){
      API_Call_Details__c api = testDocumentAPI();
        //get values from custom settings
        List<Agency_Portal_Fields_Mapping__c> settings1 = Agency_Portal_Fields_Mapping__c.getall().values();
        system.debug('settings1::'+settings1);
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Name';
        FieldMap.Field_JSON_Tag__c ='Name';
        FieldMap.Object_Name__c = 'Product';
        FieldMap.Name = 'Name';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
         Agency_Portal_Fields_Mapping__c FieldMap2= new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Legal_Status__c';
        FieldMap2.Field_JSON_Tag__c ='Legal_Status';
        FieldMap2.Object_Name__c = 'Judgment';
        FieldMap2.Name = 'Legal_Status';
        
        insert FieldMap2;
        
        Agency_Portal_Fields_Mapping__c FieldMap3= new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Judgment_Number__c';
        FieldMap3.Field_JSON_Tag__c ='Judgment_Number';
        FieldMap3.Object_Name__c = 'Judgment';
        FieldMap3.Name = 'Judgment_Number';
        
        insert FieldMap3;
        
        //Create placement record
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      
        //Create produt record
        Product__C prod2 = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.RecordTypeId=recrdid;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod2;
        ProductTriggerHandler.runProductTrigger = True;
                     
        String mMonth;
        String mYear;
        String mDay;
        if(Integer.valueOf(System.Today().month()) - 1 == 0) {
            mMonth = '12';
            mYear = String.valueOf(Integer.valueOf(System.Today().year()) - 1);
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
        } else {
            mMonth= String.valueOf(Integer.valueOf(System.Today().month()) - 1);
            mYear = String.valueOf(Integer.valueOf(System.Today().year()));
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
        } 
        
        //Create Prod Pay
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c=prod2.id;
        prodpay.Payment_Source__c = '2';
        prodpay.Payment_Type__c ='1003';
        prodpay.Payment_Amount__c=1002;
        prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Provided_Agency__c=place.id;
        prodpay.Pay_Due__c = 200;
        prodpay.Payment_Posting_Date__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay;
        ProductPaymentsTriggerHandler.runProductTrigger = true;
        
        //Judgment Record Creation
         Judgment__c judg= new Judgment__c();
         string recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
         accjudg.Product__c=prod2.id;
         accjudg.Judgment__c=judg.id;
         accjudg.Status__c='Active';
         INSERT accjudg;
        
        //Create Work assignment record
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
            workAssgn.Description__c = 'Test';
            workAssgn.Purpose__c = 'Excel File Processing';
            workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
            workAssgn.Placement_Agency__c = place.ID;
            workAssgn.Requested_Date__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        	workAssgn.Status__c = 'Requested';
        	WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
            insert workAssgn;
       	    WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        //Create document storage record
        List<Id> docList = new List<Id>();
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        //docInfo.Document_URL__c = 'Test';//parsedResponse.DocUrl
        //docInfo.Document_Id__c = '122312312';//parsedResponse.docId
        docInfo.Document_URL__c = 'task@c4990412-40c4-4e32-8e55-9c364d9ba761_xlsx';
        docInfo.Document_Id__c = 'c4990412-40c4-4e32-8e55-9c364d9ba761';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = False;
        insert docInfo;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = True;
        docList.add(docInfo.Id);
        
        //Create judgment staging record
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Case_Number__c = '1234';
        judgStaging.County__c = 'MILTON';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Document_Storage__c =docInfo.ID;
        //judgStaging.Document_Storage__r.Work_Assignment__c
        judgStaging.First_Name__c = 'Smith';
        judgStaging.Garnishment_Amount__c = 100;
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Amount__c = 200;
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Last_Name__c = 'John';
        judgStaging.Legal_Agency__c = '29';
        judgStaging.Legal_Firm__c = 'Test';
        judgStaging.Placement_Status__c = '220000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Suit_Amount__c = 400; 
        judgStaging.Type_of_Court__c = 'Superior Court of Justice';
        judgStaging.Writ_Amount__c = 100;
        judgStaging.Comment__c = '';
        judgStaging.Judgment_Province__c = 'ON';
        judgStaging.Status__c = 'Pending';
        //judgStaging.County_Identifier__c
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Expected_Value__c ='';
        //judgStaging.Document_Storage__r.Work_Assignment_Identifier__c
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Date_Writ_Issued_Text__c = '2017-02-28';
        judgStaging.Filing_Date_Text__c ='2017-02-28';
        judgStaging.Garnishment_Date_Text__c = '2017-02-28';
        judgStaging.Judgment_Date_Text__c ='2017-02-28';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        insert judgStaging;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.payStaging = judgStaging;
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.Save();
        
       
        Test.stopTest();
        send.postDocumentAPI();
    }
    
    public static testMethod void testMethod2(){
      API_Call_Details__c api = testDocumentAPI();
        //get values from custom settings
        List<Agency_Portal_Fields_Mapping__c> settings1 = Agency_Portal_Fields_Mapping__c.getall().values();
        
        //Create placement record
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        //Create produt record
        Product__C prod2 = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.RecordTypeId=recrdid;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod2;
        ProductTriggerHandler.runProductTrigger = True;

        String mMonth;
        String mYear;
        String mDay;
        if(Integer.valueOf(System.Today().month()) - 1 == 0) {
            mMonth = '12';
            mYear = String.valueOf(Integer.valueOf(System.Today().year()) - 1);
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
        } else {
            mMonth= String.valueOf(Integer.valueOf(System.Today().month()) - 1);
            mYear = String.valueOf(Integer.valueOf(System.Today().year()));
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
        } 
        
        //Create Prod Pay
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c=prod2.id;
        prodpay.Payment_Source__c = '2';
        prodpay.Payment_Type__c ='1003';
        prodpay.Payment_Amount__c=1002;
        prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Provided_Agency__c=place.id;
        prodpay.Pay_Due__c = 200;
        prodpay.Payment_Posting_Date__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay;
        ProductPaymentsTriggerHandler.runProductTrigger = true;
        
        //Judgment Record Creation
         Judgment__c judg= new Judgment__c();
         string recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
         accjudg.Product__c=prod2.id;
         accjudg.Judgment__c=judg.id;
         accjudg.Status__c='Active';
         INSERT accjudg;
        
        //Create Work assignment record
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
            workAssgn.Description__c = 'Test';
            workAssgn.Purpose__c = 'Excel File Processing';
            workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
            workAssgn.Placement_Agency__c = place.ID;
            workAssgn.Requested_Date__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        	workAssgn.Status__c = 'Requested';
        	WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
            insert workAssgn;
       	    WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        //Create document storage record
        List<Id> docList = new List<Id>();
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        //docInfo.Document_URL__c = 'Test';//parsedResponse.DocUrl
        //docInfo.Document_Id__c = '122312312';//parsedResponse.docId
        docInfo.Document_URL__c = 'task@c4990412-40c4-4e32-8e55-9c364d9ba761_xlsx';
        docInfo.Document_Id__c = 'c4990412-40c4-4e32-8e55-9c364d9ba761';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = False;
        insert docInfo;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = True;
        docList.add(docInfo.Id);
        
        //Create judgment staging record
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Case_Number__c = '1234';
        judgStaging.County__c = 'MILTON';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Document_Storage__c =docInfo.ID;
        //judgStaging.Document_Storage__r.Work_Assignment__c
        judgStaging.First_Name__c = 'Smith';
        judgStaging.Garnishment_Amount__c = 100;
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Amount__c = null;
        judgStaging.Judgment_Date__c = '';
        judgStaging.Last_Name__c = 'John';
        judgStaging.Legal_Agency__c = '29';
        judgStaging.Legal_Firm__c = 'Test';
        judgStaging.Placement_Status__c = '295000';
        judgStaging.Product_Status__c ='290000';
        judgStaging.Suit_Amount__c = 400; 
        judgStaging.Type_of_Court__c = 'Superior Court of Justice';
        judgStaging.Writ_Amount__c = 100;
        judgStaging.Comment__c = '';
        judgStaging.Judgment_Province__c = 'ON';
        judgStaging.Status__c = 'Processed';
        //judgStaging.County_Identifier__c
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Expected_Value__c ='';
        //judgStaging.Document_Storage__r.Work_Assignment_Identifier__c
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Date_Writ_Issued_Text__c = '2017-02-28';
        judgStaging.Filing_Date_Text__c ='2017-02-28';
        judgStaging.Garnishment_Date_Text__c = '2017-02-28';
        judgStaging.Judgment_Date_Text__c ='2017-02-28';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        insert judgStaging;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.payStaging = judgStaging;
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.Save();
        
        
        Test.stopTest();
        send.postDocumentAPI();
    }
}