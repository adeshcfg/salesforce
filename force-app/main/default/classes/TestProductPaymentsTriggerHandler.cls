/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of ProductPaymentsTriggerHandler
*  @author : A5E Consulting
*  @date : 11/01/2019
* 
*************************************************************************************************/
@isTest
public class TestProductPaymentsTriggerHandler {
   
    @testSetup
    static void testData(){
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
        insert settings;
        
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Name = 'Test';
        config.Run_Product_Coll_Sub_Status_Validation__c = true;
        insert config;
        
        Agency_Portal_Fields_Mapping__c fieldMapping = new Agency_Portal_Fields_Mapping__c();
        fieldMapping.Object_Name__c = 'Product';
        fieldMapping.Field_API__c = 'Name';
        fieldMapping.Field_JSON_Tag__c = 'Name';
        fieldMapping.Field_Type__c = 'Text';
        fieldMapping.Name = 'Name';
        insert fieldMapping;
        
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        portalSettings.Work_Assignment_Status__c = 'Requested,In Progress';
        portalSettings.Agency_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.CFG_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.Media_Status__c = 'Requested,In Progress';
        portalSettings.Excel_File_Processing_Status__c = 'Requested,In Progress,Completed';
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;     
        
        Province_Tax_Rate_Mapping__mdt province = new Province_Tax_Rate_Mapping__mdt();
        province.Label = 'Ab';
        province.Province_Acronym__c = 'AB';
        province.Province_Name__c = 'AB';
        province.Province_Tax_Rate__c = 10;
        province.Canada_Tax_Rate__c = 15;
        province.Total_Tax_Rate__c = 25;
        
        Province_Tax_Rate_Mapping__mdt province1 = new Province_Tax_Rate_Mapping__mdt();
        province1.Label = 'Ab';
        province1.Province_Acronym__c = 'AB';
        province1.Province_Name__c = 'Ab';
        province1.Province_Tax_Rate__c = 10;
        province1.Canada_Tax_Rate__c = 15;
        province1.Total_Tax_Rate__c = 25;
        
        Province_Tax_Rate_Mapping__mdt province2 = new Province_Tax_Rate_Mapping__mdt();
        province2.Label = 'Alberta';
        province2.Province_Acronym__c = 'AB';
        province2.Province_Name__c = 'Alberta';
        province2.Province_Tax_Rate__c = 5;
        province2.Canada_Tax_Rate__c = 5;
        province2.Total_Tax_Rate__c = 10;
        
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '9999';
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;
        
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
    
    }
    
    public static testMethod void productAfterInsertTest(){
        Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Product Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );
        insert documentstoragecObj2;
        
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c =true;
        insert plcmnt;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 2;
        insert pool;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Current_Balance__c = 7000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today() -20;
        prod.Collection_Agency__c =29;
        prod.Pool_Name__c = pool.id;
        prod.Data_Status_Description__c = 'Closed-test';
       	prod.Purchase_Province__c = 'BC';
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj; 
        
        Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = 100, 
            Payment_Type__c ='1001', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c =  null,
            Payment_Agency__c = '29',
            Payment_Source__c = '2',
            Ignore_Warning__c = true
            );
        insert productpaymentscObj;
    }
    
    public static testMethod void productAfterInsertTest1(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Alberta';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = 'Fees > Principal > Interest';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Agency_Placement__c=placement.Id;
        prod.Purchase_Province__c='PE';
        insert prod;
         
        Product__c prod1 = new Product__c();
        prod1.Name = '1000P001';
        prod1.Current_Bal_NSF_Fees__c=10;
        prod1.Current_Balance__c=1002;
        prod1.RecordTypeId= rtid;
        prod1.Current_Bal_Court_Fees__c=0;
        prod1.Current_Bal_Attorney_Fees__c=0;
        prod1.Current_Interest_Amount__c = NULL;
        prod1.Current_Bal_General_Fees__c=0;
        prod1.Current_Bal_Other_Fees__c=0;
        prod1.Current_Principal_Balance__c  = NULL;
        prod1.Recoverable_Fee__c = 100;
        prod1.Non_Recoverable_Fee__c = 100;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.State__c = 'AB';
        prod1.Collection_Agency__c = 68;
        prod1.Payment_Apportionment__c = 'Fees > Interest > Principal';
        prod1.Commission_Rate__c = 20;
        prod1.Commission_Adjustment__c = -5;
        prod1.Settlement_Rate__c = 95;
        //prod1.Account_Portfolio_ID__c = '2111P';
        prod1.Interest_Waived_Off__c = true;
        prod1.Interest_Waived_Off_Start_Date__c = System.today();
        prod1.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod1.Interest_Rate__c = 2;
        prod1.Purchase_Province__c='PE';
        insert prod1;  
        
        Test.startTest(); 
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        settlement__c settlementData = new settlement__c();
        settlementData.Product__c = prod1.id;
        settlementData.Required_Amount__c = 10;
        settlementData.Payment_Frequency__c = 'One Time Payment';
        settlementData.Status__c = 'Approved';
        insert settlementData;
        
        //product payment record creation
        List<Product_Payments__c> paylist=new list< Product_Payments__c>();
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 5000;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Agency__c = '68';
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod1.id;
        prodpay1.Payment_Amount__c = 1002;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay1.Payment_Type__c = '1002';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Payment_Agency__c = '68';
        prodpay1.Interest_Adjustment__c = 5;
                
        Product_Payments__c prodpay2= new  Product_Payments__c();
        ID rtPayid=[Select id from RecordType where sobjecttype='Product_Payments__c' AND RecordType.Name = 'Distressed Product Payment'].id;
        prodpay2.CCS_Account__c = prod1.id;
        prodpay2.RecordTypeId = rtPayid;
        prodpay2.Payment_Amount__c = 1002;
        prodpay2.Payment_Posting_Date__c= System.today().addDays(-3);
        prodpay2.Payment_Type__c = '4000';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Deposit_Account_Type__c='ETC';
        prodpay2.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Agency_Calculated_Comm__c = 20;
        prodpay2.Payment_Agency__c = '68';
        prodpay2.Interest_Adjustment__c = 5;
        
        Product_Payments__c prodpay3= new  Product_Payments__c();
        ID rtPayid1=[Select id from RecordType where sobjecttype='Product_Payments__c' AND RecordType.Name = 'Distressed Product Payment'].id;
        prodpay3.CCS_Account__c = prod1.id;
        prodpay3.RecordTypeId = rtPayid1;
        prodpay3.Payment_Amount__c = 1002;
        prodpay3.Payment_Posting_Date__c= System.today().addDays(-3);
        prodpay3.Payment_Type__c = '3000';
        prodpay3.Payment_Source__c = '2';
        prodpay3.Deposit_Account_Type__c='ETC';
        prodpay3.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay3.Ignore_Warning__c = true;
        prodpay3.Agency_Calculated_Comm__c = 20;
        prodpay3.Payment_Agency__c = '68';
        prodpay3.Interest_Adjustment__c = 5;
        
        Product_Payments__c prodpay4= new  Product_Payments__c();
        ID rtPayid2=[Select id from RecordType where sobjecttype='Product_Payments__c' AND RecordType.Name = 'Distressed Product Payment'].id;
        prodpay4.CCS_Account__c = prod1.id;
        prodpay4.RecordTypeId = rtPayid2;
        prodpay4.Payment_Amount__c = 1002;
        prodpay4.Payment_Posting_Date__c= System.today().addDays(-3);
        prodpay4.Payment_Type__c = '5000';
        prodpay4.Payment_Source__c = '2';
        prodpay4.Deposit_Account_Type__c='ETC';
        prodpay4.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay4.Ignore_Warning__c = true;
        prodpay4.Agency_Calculated_Comm__c = 20;
        prodpay4.Payment_Agency__c = '68';
        prodpay4.Interest_Adjustment__c = 5;
        
        List<Product_Payments__c> paylist1=new list< Product_Payments__c>();
        paylist1.add(prodpay);
        //paylist1.add(prodpay1);
        paylist1.add(prodpay2);
        paylist1.add(prodpay3);
        //paylist1.add(prodpay4);
        insert paylist1;
        
        Test.stopTest();
     }
    
    public static testMethod void productPaymentReversalTest2(){
        Test.startTest(); 
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Agency_Name__c = 'Keyser Mason Ball LLP';
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
         
        Product__c prod1 = new Product__c();
        prod1.Name = '1000P001';
        prod1.Current_Bal_NSF_Fees__c=10;
        prod1.Current_Balance__c=1002;
        prod1.RecordTypeId= rtid;
        prod1.Current_Bal_Court_Fees__c=0;
        prod1.Current_Interest_Amount__c = 200;
        prod1.Current_Principal_Balance__c  = 1000;
        prod1.Recoverable_Fee__c = 100;
        prod1.Non_Recoverable_Fee__c = 100;
        prod1.State__c = 'AB';
        prod1.Collection_Agency__c = 68;
        prod1.Payment_Apportionment__c = 'Fees > Interest > Principal';
        prod1.Commission_Rate__c = 20;
        prod1.Interest_Rate__c = 2;
        prod1.Commission_Adjustment__c=1;
        prod1.Purchase_Province__c='PE';
		insert prod1;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod1.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 5; 
       	placehist.Product_Commission_rate__C=2;
        placeHist.CreatedDate = system.today() - 2; 
        insert placeHist;
          
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod1.id;
        prodpay12.Payment_Amount__c = 1002;
        prodpay12.Pay_NSF__c = '1';
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1001';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Agency__c = '68';
        prodpay12.Ignore_Warning__c = true;
        prodpay12.Interest_Adjustment__c = -5;
        prodpay12.Interest_Payment_Amount__c = 0;
        insert prodpay12;
        
        Product_Payments__c prodpay8= new  Product_Payments__c();
        prodpay8.CCS_Account__c = prod1.id;
        prodpay8.Payment_Amount__c = -1002;
        prodpay8.Pay_NSF__c = '1';
        prodpay8.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay8.Payment_Agency__c = '68';
        prodpay8.Payment_Type__c = '1003';
        prodpay8.Payment_Source__c = '2';
        prodpay8.Pay_Recoverable_Fee__c = 100;
        prodpay8.Ignore_Warning__c=true;
        prodpay8.Tax_Amount__c = 12;
        insert prodpay8;
        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest3(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=1000;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Alberta';
        prod.Collection_Agency__c = 9999;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = 'Fees > Principal';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Purchase_Province__c='PE';        
        insert prod;
        
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 50; 
        placeHist.CreatedDate = system.today() - 2; 
        placeHist.Product_Commission_rate__C = 20; 
        insert placeHist;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 50;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        prodpay.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay.Pay_Recoverable_Fee__c = 5;
        prodpay.Pay_NSF__c = '100';
        prodpay.Pay_Revenue__c = 30;
        prodpay.Product_Commission_Rate__c = 2 ;
        prodpay.Pay_Due__c = 20;
        insert prodpay; 
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 50;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        prodpay1.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay1.Pay_Recoverable_Fee__c = 5;
        prodpay1.Pay_NSF__c = '100';
        prodpay1.Pay_Revenue__c = 30;
        prodpay1.Product_Commission_Rate__c = 2 ;
        prodpay1.Pay_Due__c = 20;
        insert prodpay1;
     }
    
    public static testMethod void productAfterInsertTest4(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Alberta';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = 20
        );
        insert placementhistorycObj;
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Judgment';
        judg.Legal_Sub_Status__c='Granted';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
         
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 45;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        prodpay.Payment_Agency__c = '29';
        insert prodpay;
		
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 45;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        prodpay1.Payment_Agency__c = '29';
        insert prodpay1;
        Test.stopTest();
     }
    
	public static testMethod void productAfterInsertTest5(){
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
		
        Product__c prod = new Product__c();
        prod.RecordTypeId= rtid;
        prod.Name = '671997';
        prod.Current_Principal_Balance__c = 500;
        prod.Payment_Apportionment__c = 'Fees > Principal > Interest';
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today().addDays(-1);
        prod.Interest_Waived_Of_End_Date__c = System.today().addDays(+10);
        prod.Interest_Rate__c = 10;
        prod.Collection_Agency__c = 9999;
        prod.Current_Interest_Amount__c = 300;
        prod.Recalled_Date__c = System.today().addDays(-10);
        prod.Settlement_Rate__c = NULL;
        prod.Status__c = 'Recall - Fraud';
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id; 
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = placement.id
            
        );
        insert placementhistorycObj;
       
        Test.startTest(); 
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod.id;
        prodpay12.Payment_Amount__c = 50;
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1000';
        prodpay12.Payment_Source__c = '1';
        prodpay12.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay12.Principal_Payment_Amount__c = 100;
        prodpay12.Payment_Provided_Agency__c = placement.id;
        prodpay12.Ignore_Warning__c = true;
        // insert prodpay12;
        
        Product_Payments__c prodpay13 = new  Product_Payments__c();
        prodpay13.CCS_Account__c = prod.id;
        prodpay13.Payment_Amount__c = 50;
        prodpay13.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay13.Payment_Type__c = '1002';
        prodpay13.Payment_Source__c = '1';
        prodpay13.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay13.Principal_Payment_Amount__c = 100;
        prodpay13.Ignore_Warning__c = true;
        prodpay13.Payment_Provided_Agency__c = placement.id;
        prodpay13.Original_Of_Payment_Reversal__c = NULL;
        // insert prodpay13;
        
        Product_Payments__c prodpay14 = new  Product_Payments__c();
        prodpay14.CCS_Account__c = prod.id;
        prodpay14.Payment_Type__c = '1000';
        prodpay14.Payment_Source__c = '1';
        prodpay14.Payment_Amount__c = 50;
        prodpay14.Ignore_Warning__c = true;
        prodpay14.Pay_Due__c = 0;
        prodpay14.Tax_Amount__c = 0;
        prodpay14.Payment_Provided_Agency__c = placement.id;
        prodpay14.Payment_Posting_Date__c= System.today().addDays(-2);
        // insert prodpay14;
        insert new List<Product_Payments__c>{prodpay12, prodpay13, prodpay14};
                
        Test.stopTest();
     }

	public static testMethod void productAfterInsertTest6(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        
        Placement__c placement = new Placement__c();
        placement.Name= '34';
        placement.Commission_Rate__c = 25;
        placement.Agency_Name__c = 'Keyser Mason Ball LLP';
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=1000;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Alberta';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = 'Fees > Principal';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Purchase_Province__c='PE';
		prod.Collection_Agency_Placement__c = placement.id;        
        insert prod;
        
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 50; 
        placeHist.CreatedDate = system.today() - 172; 
        placeHist.Product_Commission_rate__C = 20; 
        placeHist.Placement__c = placement.id; 
        insert placeHist;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 50;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        prodpay.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay.Pay_Recoverable_Fee__c = 5;
        prodpay.Pay_NSF__c = '100';
        prodpay.Pay_Revenue__c = 30;
        prodpay.Product_Commission_Rate__c = 2 ;
        prodpay.Pay_Due__c = 20;
        prodpay.Payment_Agency__c = '68';
        insert prodpay; 
     } 
    
    public static testMethod void productAfterInsertTest7(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=1000;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'AB';
        prod.Collection_Agency__c = 9999;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = 'Fees > Principal';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today() - 20;
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Purchase_Province__c='PE';        
        insert prod;
        
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 50; 
        placeHist.CreatedDate = system.today() - 2; 
        placeHist.Product_Commission_rate__C = 20; 
        placeHist.Placement__c = placement.id;
        insert placeHist;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 50;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Provided_Agency__c = placement.id;
        prodpay.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay.Pay_Recoverable_Fee__c = 5;
        prodpay.Pay_NSF__c = '100';
        prodpay.Pay_Revenue__c = 30;
        prodpay.Product_Commission_Rate__c = 2 ;
        prodpay.Ignore_Warning__c = true;
        prodpay.Pay_Due__c = 20;
        insert prodpay; 
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 50;
        prodpay1.Payment_Posting_Date__c= System.today();
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        prodpay1.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay1.Pay_Recoverable_Fee__c = 5;
        prodpay1.Pay_NSF__c = '100';
        prodpay1.Pay_Revenue__c = 30;
        prodpay1.Product_Commission_Rate__c = 2 ;
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Pay_Due__c = 20;
        insert prodpay1;
 
     }
	
	public static testMethod void productAfterInsertTest8(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Alberta';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id;
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = 20
        );
        insert placementhistorycObj;
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Judgment';
        judg.Legal_Sub_Status__c='Granted';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
         
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 45;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        insert prodpay;

        Test.stopTest();
     }  
    
    public static testMethod void productAfterInsertTest9(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Alberta';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id;
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = 20
        );
        insert placementhistorycObj;
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Pre-legal';
        judg.Legal_Sub_Status__c='Demand Letter Sent';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
         
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 45;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        insert prodpay;
		
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 45;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        insert prodpay1;
        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest10(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'AB';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = 20
        );
        insert placementhistorycObj;
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Judgment';
        judg.Legal_Sub_Status__c='Granted';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
         
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 45;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        insert prodpay;
		
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 45;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        insert prodpay1;
        
        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest11(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'AB';
        prod.Collection_Agency__c = 68;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = NULL;        
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id;
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = NULL,
            placement__c = placement.id
        );
        insert placementhistorycObj;
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Judgment';
        judg.Legal_Sub_Status__c='Granted';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
         
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 45;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        insert prodpay;

        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest12(){
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
		
        Product__c prod = new Product__c();
        prod.RecordTypeId= rtid;
        prod.Name = '671997';
        prod.Current_Principal_Balance__c = 500;
        prod.Payment_Apportionment__c = 'Fees > Principal > Interest';
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today().addDays(-1);
        prod.Interest_Waived_Of_End_Date__c = System.today().addDays(+10);
        prod.Interest_Rate__c = 10;
        prod.Collection_Agency__c = 9999;
        prod.Current_Interest_Amount__c = 300;
        prod.Recalled_Date__c = System.today().addDays(-10);
        prod.Settlement_Rate__c = NULL;
        prod.Status__c = 'Recall - Fraud';
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id; 
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = placement.id
            
        );
        insert placementhistorycObj;
       
        Test.startTest(); 
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod.id;
        prodpay12.Payment_Amount__c = 50;
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1000';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay12.Principal_Payment_Amount__c = 100;
        prodpay12.Payment_Provided_Agency__c = placement.id;
        prodpay12.Ignore_Warning__c = true;
        // insert prodpay12;
        
        Product_Payments__c prodpay13 = new  Product_Payments__c();
        prodpay13.CCS_Account__c = prod.id;
        prodpay13.Payment_Amount__c = 50;
        prodpay13.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay13.Payment_Type__c = '1002';
        prodpay13.Payment_Source__c = '2';
        prodpay13.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay13.Principal_Payment_Amount__c = 100;
        prodpay13.Ignore_Warning__c = true;
        prodpay13.Payment_Provided_Agency__c = placement.id;
        prodpay13.Original_Of_Payment_Reversal__c = NULL;
        // insert prodpay13;
        
        Product_Payments__c prodpay14 = new  Product_Payments__c();
        prodpay14.CCS_Account__c = prod.id;
        prodpay14.Payment_Type__c = '1000';
        prodpay14.Payment_Source__c = '2';
        prodpay14.Payment_Amount__c = 50;
        prodpay14.Ignore_Warning__c = true;
        prodpay14.Pay_Due__c = 0;
        prodpay14.Tax_Amount__c = 0;
        prodpay14.Payment_Provided_Agency__c = placement.id;
        prodpay14.Payment_Posting_Date__c= System.today().addDays(-2);
        // insert prodpay14;
        insert new List<Product_Payments__c>{prodpay12, prodpay13, prodpay14};
        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest13(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'Ontario';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id;
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = 20
        );
        insert placementhistorycObj;
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
		
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 45;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        insert prodpay1;
        
        prod.State__c = 'AB';
        update prod;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod.id;
        prodpay2.Payment_Amount__c = 45;
        prodpay2.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay2.Payment_Type__c = '1000';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Deposit_Account_Type__c='ETC';
        prodpay2.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Interest_Adjustment__c = 5;
        prodpay2.Payment_Posting_Date__c = System.today()-1;
        prodpay2.Payment_Provided_Agency__c = placement.id;
        insert prodpay2;
       
        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest14(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.RecordTypeId= rtid;
        prod.State__c = 'Ontario';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        prod.Collection_Agency_Placement__c = placement.id;
        insert prod;
        
        Product__c prod1 = new Product__c();
        prod1.Name = '12346';
        prod1.RecordTypeId= rtid;
        prod1.State__c = 'Ontario';
        prod1.Collection_Agency__c = 68;
        prod1.Commission_Rate__c = 25;
        prod1.Commission_Adjustment__c = 2;        
        prod1.Purchase_Province__c='PE';
        prod1.Collection_Agency_Placement__c = placement.id;
        insert prod1;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Placement__c = placement.id,
            Commission_Rate__c = NULL
        );
        insert placementhistorycObj;
        
        Placement_history__c placementhistorycObj1 = new Placement_history__c (
            product__c = prod1.id,
            Placement_Recall_Date__c = Date.today() - 20,
            CreatedDate = system.today() - 50,
            Placement__c = placement.id,
            Commission_Rate__c = NULL
        );
        insert placementhistorycObj1;
        
        Test.startTest();   
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 45;
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        insert prodpay1;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod1.id;
        prodpay2.Payment_Amount__c = 45;
        prodpay2.Payment_Type__c = '1000';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Payment_Posting_Date__c = System.today()-1;
        prodpay2.Payment_Provided_Agency__c = placement.id;
        insert prodpay2;
        Test.stopTest();
     }
    
    public static testMethod void productPaymentReversalTest15(){
        Test.startTest(); 
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Agency_Name__c = 'Keyser Mason Ball LLP';
        insert placement;
       
        Product__c prod1 = new Product__c();
        prod1.Name = '1000P001';
        prod1.RecordTypeId= [Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        prod1.State__c = 'AB';
        prod1.Collection_Agency__c = 68;
		insert prod1;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod1.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 5; 
       	placehist.Product_Commission_rate__C=2;
        placeHist.CreatedDate = system.today() - 2; 
        insert placeHist;
          
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod1.id;
        prodpay12.Payment_Amount__c = 1002;
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1002';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Agency__c = '68';
        prodpay12.Ignore_Warning__c = true;
        insert prodpay12;
        
        Product_Payments__c prodpay8= new  Product_Payments__c();
        prodpay8.CCS_Account__c = prod1.id;
        prodpay8.Payment_Amount__c = -1002;
        prodpay8.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay8.Payment_Agency__c = '68';
        prodpay8.Payment_Type__c = '1003';
        prodpay8.Payment_Source__c = '2';
        prodpay8.Ignore_Warning__c=true;
        insert prodpay8; 
        Test.stopTest();
     }
    
    public static testMethod void productPaymentReversalTest16(){
        Test.startTest();          
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Agency_Name__c = 'Warehouse';
        insert placement;
         
        Product__c prod1 = new Product__c();
        prod1.Name = '1000P001';
        prod1.Current_Bal_NSF_Fees__c=10;
        prod1.Current_Balance__c=1002;
        prod1.RecordTypeId= [Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        prod1.Current_Bal_Court_Fees__c=0;
        prod1.Current_Interest_Amount__c = 2000;
        prod1.Current_Principal_Balance__c  = 1000;
        prod1.Recoverable_Fee__c = 10000;
        prod1.Non_Recoverable_Fee__c = 10000;
        prod1.State__c = 'AB';
        prod1.Collection_Agency__c = 68;
        prod1.Payment_Apportionment__c = 'Fees > Interest > Principal';
        prod1.Commission_Rate__c = 20;
        prod1.Interest_Rate__c = 2;
        prod1.Commission_Adjustment__c=1;
        prod1.Purchase_Province__c='PE';
        prod1.Collection_Agency_Placement__c = placement.id;
        prod1.Placement_Status__c = '806000';
		insert prod1;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod1.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 5; 
       	placehist.Product_Commission_rate__C=2;
        placeHist.CreatedDate = system.today() - 2; 
        insert placeHist;
          
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod1.id;
        prodpay12.Payment_Amount__c = 1002;
        prodpay12.Pay_NSF__c = '1';
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1001';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Agency__c = '68';
        prodpay12.Ignore_Warning__c = true;
        prodpay12.Interest_Adjustment__c = 5;
        prodpay12.Interest_Payment_Amount__c = 0;
        insert prodpay12;
        
        Product_Payments__c prodpay13 = new  Product_Payments__c();
        prodpay13.CCS_Account__c = prod1.id;
        prodpay13.Payment_Amount__c = 1002;
        prodpay13.Pay_NSF__c = '1';
        prodpay13.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay13.Payment_Type__c = '1002';
        prodpay13.Payment_Source__c = '2';
        prodpay13.Payment_Agency__c = '68';
        prodpay13.Ignore_Warning__c = true;
        prodpay13.Interest_Adjustment__c = 5;
        prodpay13.Interest_Payment_Amount__c = 0;
        insert prodpay13;
        
        /*Product_Payments__c prodpay8= new  Product_Payments__c();
        prodpay8.CCS_Account__c = prod1.id;
        prodpay8.Payment_Amount__c = -1002;
        prodpay8.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay8.Payment_Agency__c = '68';
        prodpay8.Payment_Type__c = '1003';
        prodpay8.Payment_Source__c = '2';
        prodpay8.Ignore_Warning__c=true;
        insert prodpay8;*/ 
        
        ProductPaymentsTriggerHandler.productWrapper wrapper = new ProductPaymentsTriggerHandler.productWrapper(prod1.name,'806000','302000','68');
        Test.stopTest();
     }
    	
    public static testMethod void productAfterInsertTest18(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=1000;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'AB';
        prod.Collection_Agency__c = 9999;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = 'Fees > Principal';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Purchase_Province__c='PE';        
        insert prod;
        
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 50; 
        placeHist.CreatedDate = system.today() - 2; 
        placeHist.Product_Commission_rate__C = 20; 
        insert placeHist;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 50;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        prodpay.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay.Pay_Recoverable_Fee__c = 5;
        prodpay.Pay_NSF__c = '100';
        prodpay.Pay_Revenue__c = 30;
        prodpay.Product_Commission_Rate__c = 2 ;
        prodpay.Pay_Due__c = 20;
        insert prodpay; 
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 50;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1000';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Payment_Provided_Agency__c = placement.id;
        prodpay1.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay1.Pay_Recoverable_Fee__c = 5;
        prodpay1.Pay_NSF__c = '100';
        prodpay1.Pay_Revenue__c = 30;
        prodpay1.Product_Commission_Rate__c = 2 ;
        prodpay1.Pay_Due__c = 20;
        insert prodpay1;
        
     }
    
    public static testMethod void productAfterInsertTest19(){
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;
		
        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Current_Bal_NSF_Fees__c=10;
        prod.Current_Balance__c=1200;
        prod.RecordTypeId= rtid;
        prod.Current_Bal_Court_Fees__c=0;
        prod.Current_Bal_Attorney_Fees__c=0;
        prod.Current_Interest_Amount__c = 20;
        prod.Current_Bal_Other_Fees__c=0;
        prod.Current_Bal_General_Fees__c=0;
        prod.Current_Principal_Balance__c  = 1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'AB';
        prod.Collection_Agency__c = 68;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Pool_Name__c = pool.ID;
        prod.Payment_Apportionment__c = '';
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = NULL;
        prod.Commission_Adjustment__c = 2;        
        prod.Purchase_Province__c='PE';
        prod.Payment_Apportionment__c = 'Fees > Principal > Interest';
        insert prod;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Commission_Rate__c = 20
        );
        insert placementhistorycObj;
        
        Test.startTest();  
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.RecordTypeId =[Select id from RecordType where sobjecttype='Product_Payments__c' AND RecordType.Name = 'Distressed Product Payment'].id;
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 45;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '3000';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c='ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
        insert prodpay;
        Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest20(){
        Test.startTest(); 
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Agency_Name__c = 'Keyser Mason Ball LLP';
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;

        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
         
        Product__c prod1 = new Product__c();
        prod1.Name = '1000P001';
        prod1.Current_Bal_NSF_Fees__c=10;
        prod1.Current_Balance__c=1002;
        prod1.RecordTypeId= rtid;
        prod1.Current_Bal_Court_Fees__c=0;
        prod1.Current_Interest_Amount__c = 200;
        prod1.Current_Principal_Balance__c  = 1000;
        prod1.Recoverable_Fee__c = 100;
        prod1.Non_Recoverable_Fee__c = 100;
        prod1.State__c = 'AB';
        prod1.Collection_Agency__c = 68;
        prod1.Payment_Apportionment__c = 'Fees > Interest > Principal';
        prod1.Commission_Rate__c = 20;
        prod1.Interest_Rate__c = 2;
        prod1.Commission_Adjustment__c=1;
        prod1.Purchase_Province__c='PE';
		insert prod1;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod1.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 5; 
       	placehist.Product_Commission_rate__C=2;
        placeHist.CreatedDate = system.today() - 182; 
        insert placeHist;
          
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod1.id;
        prodpay12.Payment_Amount__c = 1002;
        prodpay12.Pay_NSF__c = '1';
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1001';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Agency__c = '68';
        prodpay12.Ignore_Warning__c = true;
        prodpay12.Interest_Adjustment__c = 5;
        prodpay12.Interest_Payment_Amount__c = 0;
        insert prodpay12;
        
        Product_Payments__c prodpay8= new  Product_Payments__c();
        prodpay8.CCS_Account__c = prod1.id;
        prodpay8.Payment_Amount__c = -1002;
        prodpay8.Pay_NSF__c = '1';
        prodpay8.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay8.Payment_Agency__c = '68';
        prodpay8.Payment_Type__c = '1003';
        prodpay8.Payment_Source__c = '2';
        prodpay8.Pay_Recoverable_Fee__c = 100;
        prodpay8.Ignore_Warning__c=true;
        prodpay8.Tax_Amount__c = 12;
        prodpay8.Original_Of_Payment_Reversal__c = prodpay12.id;
        insert prodpay8;
        Test.stopTest();
        
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod1.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        accjudg.CreatedDate = System.today();
        insert accjudg;
     }
    
}