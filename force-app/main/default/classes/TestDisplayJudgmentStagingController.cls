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
    
    static {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;
        
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI';//endpointurl
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000; 
        insert settings;
        
        Placement_Status_Code_Mapping__c reasons = new Placement_Status_Code_Mapping__c();
        reasons.Status__c = 'In Process';
        reasons.Parent_Status__c = 'Pre - Legal';
        reasons.Placement_Status_Code__c = '210000';
        reasons.Name = '210000';
        insert reasons;
        
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
        
        Judgment_product_codes_mapping__c JudProdmapping = new Judgment_product_codes_mapping__c();
        JudProdmapping.Judgment_Legal_Status__c = 'Pre-Legal';
        JudProdmapping.Judgment_Legal_Sub_Status__c = 'Recommended for legal action';
        JudProdmapping.Codes__c = '210000';
        JudProdmapping.Name = 'A-0001';
        insert JudProdmapping;
     }
    
    public static testMethod void testMethod1(){
        Placement__c place = new Placement__c();
        place.Name = '89';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      	
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;        
                
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_one__c = 5;
        judg.Product_1__c = prod2.Name;
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod2.id;
        prodpay6.Payment_Amount__c = 1000;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1000';
        prodpay6.Payment_Source__c = '2';
        prodpay6.Ignore_Warning__c = true;
        insert prodpay6;
       
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Case_Number__c = '1234';
        judgStaging.County__c = 'MILTON';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Document_Storage__c =docInfo.ID;
        judgStaging.First_Name__c = 'Smith';
        judgStaging.Garnishment_Amount__c = 100;
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Amount__c = 200;
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Last_Name__c = 'John';
        judgStaging.Legal_Agency__c = '29';
        judgStaging.Legal_Firm__c = 'Test';
        judgStaging.Placement_Status__c = '210000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Suit_Amount__c = 400; 
        judgStaging.Type_of_Court__c = 'Superior Court of Justice';
        judgStaging.Writ_Amount__c = 100;
        judgStaging.Judgment_Province__c = 'ON';
        judgStaging.Status__c = 'Pending';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Expected_Value__c ='';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Date_Writ_Issued_Text__c = '2017-02-28';
        judgStaging.Filing_Date_Text__c ='2017-02-28';
        judgStaging.Garnishment_Date_Text__c = '2017-02-28';
        judgStaging.Judgment_Date_Text__c ='2017-02-28';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        insert judgStaging;
        
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.executeWarning = false;
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        send.Save();
    }
    
    public static testMethod void testMethod2(){
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        //Create produt record
        Product__C prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        INSERT prod2;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c=prod2.id;
        prodpay.Payment_Source__c = '2';
        prodpay.Payment_Type__c ='1000';
        prodpay.Payment_Amount__c=1002;
        prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Provided_Agency__c=place.id;
        prodpay.Pay_Due__c = 200;
        insert prodpay;
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
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
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
        
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Document_Storage__c =docInfo.ID;
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Date__c = '';
        judgStaging.Legal_Agency__c = '29';
        judgStaging.Placement_Status__c = '295000';
        judgStaging.Product_Status__c ='290000';
        judgStaging.Suit_Amount__c = 400; 
        judgStaging.Writ_Amount__c = 100;
        judgStaging.Judgment_Province__c = 'ON';
        judgStaging.Status__c = 'Processed';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Expected_Value__c ='';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        insert judgStaging;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.payStaging = judgStaging; 
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.Save();
        Test.stopTest();
    }
    
    public static testMethod void testMethod3(){
        Placement__c place = new Placement__c();
        place.Name = '29';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      	
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;   
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_two__c = 5;
        judg.Product_2__c = prod2.Name;
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
       
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Placement_Status__c = '210000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Status__c = 'Pending';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        judgStaging.Document_Storage__c =docInfo.ID;
        insert judgStaging;
        
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.executeWarning = false;
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        send.Save();
    }
    
    public static testMethod void testMethod4(){
        Placement__c place = new Placement__c();
        place.Name = '29';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      	
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;   
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_two__c = 5;
        judg.Product_3__c = prod2.Name;
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
       
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Placement_Status__c = '210000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Status__c = 'Pending';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        judgStaging.Document_Storage__c =docInfo.ID;
        insert judgStaging;
        
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.executeWarning = false;
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        send.Save();
    }
    
    public static testMethod void testMethod5(){
        Placement__c place = new Placement__c();
        place.Name = '29';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      	
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;   
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_two__c = 5;
        judg.Product_4__c = prod2.Name;
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
       
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Placement_Status__c = '210000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Status__c = 'Pending';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        judgStaging.Document_Storage__c =docInfo.ID;
        insert judgStaging;
        
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.executeWarning = false;
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        send.Save();
    }
    
    public static testMethod void testMethod6(){
        Placement__c place = new Placement__c();
        place.Name = '29';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      	
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;   
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_two__c = 5;
        judg.Product_5__c = prod2.Name;
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
       
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Placement_Status__c = '210000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Status__c = 'Pending';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        judgStaging.Document_Storage__c =docInfo.ID;
        insert judgStaging;
        
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.executeWarning = false;
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        send.Save();
    }
    
    public static testMethod void testMethod7(){
        Placement__c place = new Placement__c();
        place.Name = '29';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
      	
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Status__c = 'Requested';
        insert workAssgn;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        insert docInfo;
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;        
                
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_one__c = 5;
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
       
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        judgStaging.Agency_Initiated_Legal_Action__c = '29';
        judgStaging.Data_Id__c = prod2.Name;
        judgStaging.Date_Writ_Issued__c = '2017-02-28';
        judgStaging.Filing_Date__c ='2017-02-28';
        judgStaging.Garnishment_Date__c = '2017-02-28';
        judgStaging.Judgment_Date__c = '2017-02-28';
        judgStaging.Placement_Status__c = '210000';
        judgStaging.Product_Status__c ='301000';
        judgStaging.Status__c = 'Pending';
        judgStaging.Interest_Rate__c = '5';
        judgStaging.Placement_Agency__c = '29';
        judgStaging.Product_Id__c = Prod2.ID;
        judgStaging.Balance__c = '100';
        judgStaging.Identifier__c = docInfo.ID;
        judgStaging.Comment__c = 'In Progress';
        judgStaging.Document_Storage__c =docInfo.ID;
        insert judgStaging;
        
        ApexPages.currentPage().getParameters().put('id', docInfo.Id);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        send.executeWarning = false;
        DisplayJudgmentStagingController.judgmentStagingWrapper ccisw = new DisplayJudgmentStagingController.judgmentStagingWrapper(judgStaging, False);
        ccisw.selected = true;
        send.Save();
    }
    
    public static testMethod void testMethod8(){ 
        list<Judgment__c> listNewJudgments = new list<Judgment__c>();
        map<String, Product__c> mapProductData = new map<String, Product__c>();
        Map<String,Product_Payments__c> ProductPaymentList = new Map<String,Product_Payments__c>();
        map<String, Product__c> mapProductDataDetails = new map<String, Product__c>();
            
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId=[SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Placement_Status__c = '210000';
        prod2.Collection_Agency__c = 29;
        insert prod2;
		mapProductData.put(prod2.name,prod2);        
                
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.RecordTypeId=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '106';
        judg.Interest_Rate_one__c = 5;
        judg.Product_1__c = prod2.Name;
        insert judg;
        listNewJudgments.add(judg);
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod2.id;
        prodpay6.Payment_Amount__c = 1000;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1000';
        prodpay6.Payment_Source__c = '2';
        prodpay6.Ignore_Warning__c = true;
        insert prodpay6;
        ProductPaymentList.put(prod2.name,prodpay6);
        
        DisplayJudgmentStagingController send = new DisplayJudgmentStagingController();
        DisplayJudgmentStagingController.calculateJudgmentInterestAdjustment(listNewJudgments,mapProductData,
                                       prod2.Name,1000,18,'2017-02-28',
                                        ProductPaymentList,mapProductDataDetails);
    }
        
}