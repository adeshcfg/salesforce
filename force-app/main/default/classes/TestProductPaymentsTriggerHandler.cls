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
    
    }
    public static testMethod void productAfterInsertTest(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
         
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
       
        set<Id> setProductId = new set<Id>();
        set<ID> setPlacementID = new set<ID>();
        list<String> validPaymentTypes = new list<String>();
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        
        //Placement Record
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;

        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        PoolTriggerHandler.runPoolTrigger = false;
        insert pool;
        PoolTriggerHandler.runPoolTrigger = true;
        //Product record creation
        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Data_Status_Description__c='closed test';
        prod.Purchase_Status__c='Buyback  Approved';
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
        prod.State__c = 'Manitoba';
        prod.Collection_Agency__c = 9999;
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
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Purchase_Province__c='PE';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
         
        Product__c prod1 = new Product__c();
        prod1.Name = '1000P001';
                prod1.Data_Status_Description__c='Closed test';
        prod1.Current_Bal_NSF_Fees__c=10;
        prod1.Current_Balance__c=1002;
        prod1.RecordTypeId= rtid;
        prod1.Current_Bal_Court_Fees__c=0;
        prod1.Current_Bal_Attorney_Fees__c=0;
        prod1.Current_Interest_Amount__c = 200;
        prod1.Current_Bal_General_Fees__c=0;
        prod1.Current_Bal_Other_Fees__c=0;
        prod1.Current_Principal_Balance__c  = 50000;
        prod1.Recoverable_Fee__c = 100;
        prod1.Non_Recoverable_Fee__c = 100;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.State__c = 'AB';
        prod1.Collection_Agency__c = 9999;
        prod1.Payment_Apportionment__c = 'Fees > Interest > Principal';
        prod1.Commission_Rate__c = 20;
        prod1.Commission_Adjustment__c = -5;
        prod1.Settlement_Rate__c = 95;
        prod1.Collection_Sub_Status__c = 'Annulled';
        prod1.Account_Portfolio_ID__c = '2111P';
        prod1.Interest_Waived_Off__c = true;
        prod1.Interest_Waived_Off_Start_Date__c = System.today();
        prod1.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod1.Interest_Rate__c = 2;
        prod1.Recalled_Date__c = System.today();
                prod1.Purchase_Province__c='PE';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = placement.id
            
        );
        insert placementhistorycObj;
        
        Placement_history__c placementhistorycObj1 = new Placement_history__c (
            product__c = prod1.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = placement.id
            
        );
        insert placementhistorycObj1;
       //Test.startTest();
        
        //Judgment record
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert judg;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = False;
        insert accjudg;
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = True;
         
        //product payment record creation
        List<Product_Payments__c> paylist=new list< Product_Payments__c>();
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
       // prodpay.Product_Commission_Rate__c = 2 ;
        prodpay.Payment_Type__c='1000';
        
        //prodpay.Payment_Amount__c=-98;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod1.id;
        prodpay2.Payment_Amount__c = 50;
        prodpay2.Payment_Posting_Date__c= System.today().addDays(-3);
        prodpay2.Payment_Type__c = '1000';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Deposit_Account_Type__c='ETC';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Agency_Calculated_Comm__c = 20;
        prodpay2.Interest_Adjustment__c = 5;
        prodpay2.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay2.Pay_Recoverable_Fee__c = 5;
        prodpay2.Pay_NSF__c = '100';
        prodpay2.Product_Commission_Rate__c = 2 ;

        Product_Payments__c prodpay4= new  Product_Payments__c();
        prodpay4.CCS_Account__c = prod1.id;
        prodpay4.Payment_Amount__c = 50;
        prodpay4.Payment_Posting_Date__c= System.today().addDays(-3);
        prodpay4.Payment_Type__c = '1000';
        prodpay4.Payment_Source__c = '2';
        prodpay4.Deposit_Account_Type__c='ETC';
        prodpay4.Ignore_Warning__c = true;
        prodpay4.Interest_Adjustment__c = 5;
        prodpay4.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay4.Pay_Recoverable_Fee__c = 5;
        prodpay4.Pay_NSF__c = '100';
        prodpay4.Product_Commission_Rate__c = 2 ;

        Product_Payments__c prodpay5= new  Product_Payments__c();
        prodpay5.CCS_Account__c = prod1.id;
        prodpay5.Payment_Amount__c = 50;
        prodpay5.Pay_NSF__c = '100';
        prodpay5.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay5.Payment_Type__c = '1000';
        prodpay5.Payment_Source__c = '2';
        prodpay5.Deposit_Account_Type__c='ETC';
        prodpay5.Ignore_Warning__c = true;
        prodpay5.Interest_Adjustment__c = 5;
        prodpay5.Pay_Non_Recoverable_Fee__c = 5;
        prodpay5.Pay_Recoverable_Fee__c = 5;
        prodpay5.Product_Commission_Rate__c = 2 ;
        
        Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod1.id;
        prodpay6.Payment_Amount__c = 50;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1000';
        prodpay6.Payment_Source__c = '2';
        prodpay6.Deposit_Account_Type__c='ETC';
        prodpay6.Original_Of_Payment_Reversal__c = prodpay5.id;
        prodpay6.Ignore_Warning__c = true;
        prodpay6.Interest_Adjustment__c = 5;
        prodpay6.Pay_Non_Recoverable_Fee__c = 5;
        prodpay6.Pay_Recoverable_Fee__c = 5;
        prodpay6.Pay_NSF__c = '100';
        prodpay6.Product_Commission_Rate__c = 2 ;
        
        Product_Payments__c prodpay9= new  Product_Payments__c();
        prodpay9.CCS_Account__c = prod1.id;
        prodpay9.Payment_Amount__c = 50;
        prodpay9.Pay_NSF__c = '100';
        prodpay9.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay9.Payment_Type__c = '3000';
        prodpay9.Payment_Source__c = '2';
        prodpay9.Deposit_Account_Type__c='ETC';
        prodpay9.Ignore_Warning__c = true;
        prodpay9.Interest_Adjustment__c = 5;
        prodpay9.Pay_Non_Recoverable_Fee__c = 5;
        prodpay9.Pay_Recoverable_Fee__c = 5;
        prodpay9.Product_Commission_Rate__c = 2 ;
         
        Product_Payments__c prodpay10= new  Product_Payments__c();
        prodpay10.CCS_Account__c = prod1.id;
        prodpay10.Payment_Amount__c = 50;
        prodpay10.Pay_NSF__c = '100';
        prodpay10.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay10.Payment_Type__c = '4000';
        prodpay10.Payment_Source__c = '2';
        prodpay10.Deposit_Account_Type__c='ETC';
        prodpay10.Ignore_Warning__c = true;
        prodpay10.Interest_Adjustment__c = 5;
        prodpay10.Pay_Non_Recoverable_Fee__c = 5;
        prodpay10.Pay_Recoverable_Fee__c = 5;
        prodpay10.Product_Commission_Rate__c = 2 ;
        
        Product_Payments__c prodpay12= new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod1.id;
        prodpay12.Payment_Amount__c = 50;
        prodpay12.Pay_NSF__c = '100';
        prodpay12.Payment_Posting_Date__c= System.today()-2;
        prodpay12.Payment_Type__c = '5000';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Deposit_Account_Type__c='ETC';
        prodpay12.Ignore_Warning__c = true;
        prodpay12.Interest_Adjustment__c = 5;
        prodpay12.Pay_Non_Recoverable_Fee__c = 5;
        prodpay12.Pay_Recoverable_Fee__c = 5;
        prodpay12.Product_Commission_Rate__c = 2 ;
        
                
        List<Product_Payments__c> paylist1=new list< Product_Payments__c>();
        paylist1.add(prodpay);
        paylist1.add(prodpay2);
        paylist1.add(prodpay4);
        paylist1.add(prodpay6);
        paylist1.add(prodpay9);
        paylist1.add(prodpay10);
        paylist1.add(prodpay12);
       
        insert paylist1;         
        
        //Test.stopTest();
       
        
     }
    
    public static testMethod void productAfterInsertTest1(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
        
       
        
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
        
        set<Id> setProductId = new set<Id>();
        set<ID> setPlacementID = new set<ID>();
        list<String> validPaymentTypes = new list<String>();
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        //Placement Record
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        setPlacementID.add(placement.id);
        
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
        
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
         
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
        prod1.Account_Portfolio_ID__c = '2111P';
        prod1.Interest_Waived_Off__c = true;
        prod1.Interest_Waived_Off_Start_Date__c = System.today();
        prod1.Interest_Waived_Of_End_Date__c = System.today() + 2;
        prod1.Interest_Rate__c = 2;
                prod1.Purchase_Province__c='PE';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;
        
        
        Test.startTest(); 

        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert judg;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = False;
        insert accjudg;
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = True;
         
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
        prodpay.Payment_Posting_Date__c = System.today()-1;
        prodpay.Payment_Provided_Agency__c = placement.id;
       	
        Product_Payments__c prodpayData = new  Product_Payments__c();
        prodpayData.CCS_Account__c = prod.id;
        prodpayData.Payment_Amount__c = 50;
        prodpayData.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpayData.Payment_Type__c = '1000';
        prodpayData.Payment_Source__c = '1';
        prodpayData.Deposit_Account_Type__c='ETC';
        prodpayData.Payment_Posting_Date_Text__c = 'Thursday';
        prodpayData.Ignore_Warning__c = true;
        prodpayData.Interest_Adjustment__c = 5;
        prodpayData.Payment_Posting_Date__c = System.today()-1;
        prodpayData.Payment_Provided_Agency__c = placement.id;
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod1.id;
        prodpay1.Payment_Amount__c = 1002;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay1.Payment_Type__c = '1002';
        prodpay1.Payment_Source__c = '2';
        prodpay1.Deposit_Account_Type__c='ETC';
        prodpay1.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
                
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod1.id;
        prodpay2.Payment_Amount__c = 1002;
        prodpay2.Payment_Posting_Date__c= System.today().addDays(-3);
        prodpay2.Payment_Type__c = '1000';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Deposit_Account_Type__c='ETC';
        prodpay2.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Agency_Calculated_Comm__c = 20;
        prodpay2.Interest_Adjustment__c = 5;
         
        Product_Payments__c prodpay3= new  Product_Payments__c();
        prodpay3.CCS_Account__c = prod1.id;
        prodpay3.Payment_Amount__c = 1002;
        prodpay3.Payment_Posting_Date__c= System.today().addDays(-4);
        prodpay3.Payment_Type__c = '1001';
        prodpay3.Payment_Source__c = '2';
        prodpay3.Deposit_Account_Type__c='ETC';
        prodpay3.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay3.Ignore_Warning__c = true;
        prodpay3.Interest_Adjustment__c = 5;
       

        Product_Payments__c prodpay5= new  Product_Payments__c();
        prodpay5.CCS_Account__c = prod1.id;
        prodpay5.Payment_Amount__c = 1002;
        prodpay5.Pay_NSF__c = '1';
        prodpay5.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay5.Payment_Type__c = '1000';
        prodpay5.Payment_Source__c = '2';
        prodpay5.Ignore_Warning__c = true;
        prodpay5.Interest_Adjustment__c = 5;
        
        Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod1.id;
        prodpay6.Payment_Amount__c = 1002;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1001';
        prodpay6.Payment_Source__c = '2';
        prodpay6.Original_Of_Payment_Reversal__c = prodpay5.id;
        prodpay6.Ignore_Warning__c = true;
        prodpay6.Interest_Adjustment__c = 5;
        
        
        List<Product_Payments__c> paylist1=new list< Product_Payments__c>();
        paylist1.add(prodpay);
        paylist1.add(prodpay1);
        paylist1.add(prodpay2);
        paylist1.add(prodpay3);
        paylist1.add(prodpay6);
        paylist1.add(prodpayData);
        insert paylist1;
        
        Test.stopTest();
     }
    
    
    public static testMethod void productPaymentReversalTest2(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
         
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
        
        set<Id> setProductId = new set<Id>();
        set<ID> setPlacementID = new set<ID>();
        list<String> validPaymentTypes = new list<String>();
        Test.startTest(); 
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        //Placement Record
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
        setPlacementID.add(placement.id);
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        insert pool;
        //Product record creation
        Product__c prod = new Product__c();
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
          
        List<Product_Payments__c> paylist=new list< Product_Payments__c>();
        Product_Payments__c prodpay11 = new  Product_Payments__c();
        prodpay11.CCS_Account__c = prod1.id;
        prodpay11.Payment_Amount__c = -1002;
        prodpay11.Pay_NSF__c = '1';
        prodpay11.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay11.Payment_Type__c = '1004';
        prodpay11.Payment_Source__c = '2';
        prodpay11.Payment_Agency__c = '89';
        prodpay11.Ignore_Warning__c = true;
        prodpay11.Interest_Adjustment__c = 5;
        prodpay11.Interest_Payment_Amount__c = 10;
       // prodpay11.Pay_Due__c=0;
        insert prodpay11;
        
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod1.id;
        prodpay12.Payment_Amount__c = 1002;
        prodpay12.Pay_NSF__c = '1';
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1001';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Agency__c = '89';
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
        insert prodpay8;
          
         Test.stopTest();
     }
    
    public static testMethod void productAfterInsertTest3(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
         
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
       
        set<Id> setProductId = new set<Id>();
        set<ID> setPlacementID = new set<ID>();
        list<String> validPaymentTypes = new list<String>();
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
        
        //Placement Record
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        insert placement;
        
        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        PoolTriggerHandler.runPoolTrigger = false;
        insert pool;
        PoolTriggerHandler.runPoolTrigger = true;
        //Product record creation
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
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        //Judgment record
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert judg;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = False;
        insert accjudg;
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = True;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Recall_Date__c = system.today() - 50; 
        placeHist.CreatedDate = system.today() - 2; 
        placeHist.Product_Commission_rate__C = 20; 
        insert placeHist;
        
        //product payment record creation
        List<Product_Payments__c> paylist=new list< Product_Payments__c>();
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
        
        
        List<Product_Payments__c> paylist1=new list< Product_Payments__c>();
        paylist1.add(prodpay);
        insert paylist1; 
     }
    
    public static testMethod void productAfterInsertTest4(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
        
       
        
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
        
        set<Id> setProductId = new set<Id>();
        set<ID> setPlacementID = new set<ID>();
        list<String> validPaymentTypes = new list<String>();
        
        ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;
         
        //Placement Record
        Placement__c placement = new Placement__c();
        placement.Name= '68';
        placement.Commission_Rate__c = 25;
        placement.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert placement;
        setPlacementID.add(placement.id);
        
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
 ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
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
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert judg;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = False;
        insert accjudg;
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = True;
         
        //product payment record creation
        List<Product_Payments__c> paylist=new list< Product_Payments__c>();
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
       	
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod.id;
        prodpay12.Payment_Amount__c = 1002;
        prodpay12.Pay_NSF__c = '1';
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1000';
        prodpay12.Payment_Source__c = '2';
        prodpay12.Payment_Agency__c = '89';
        prodpay12.Ignore_Warning__c = true;
        prodpay12.Interest_Adjustment__c = 5;
        prodpay12.Interest_Payment_Amount__c = 10;
        prodpay12.Payment_Posting_Date_Text__c = '2022-10-15';
        //insert prodpay12;
        
        Product_Payments__c prodpay8 = new  Product_Payments__c();
        prodpay8.CCS_Account__c = prod.id;
        prodpay8.Payment_Amount__c = -1002;
        prodpay8.Pay_NSF__c = '1';
        prodpay8.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay8.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay8.Payment_Type__c = '1003';
        prodpay8.Payment_Source__c = '2';
        prodpay8.Payment_Agency__c = '89';
        prodpay8.Ignore_Warning__c = true;
        prodpay8.Interest_Adjustment__c = 5;
        prodpay8.Interest_Payment_Amount__c = 10;
        
        
        
        
        
        List<Product_Payments__c> paylist1=new list< Product_Payments__c>();
        paylist1.add(prodpay);
        //paylist1.add(prodpay12);
        //paylist1.add(prodpay9);
        insert paylist1;
        
        Test.stopTest();
     }
    
    
	public static testMethod void productAfterInsertTest5(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
        
        Loan_ReEngineering__c confi = Loan_ReEngineering__c.getOrgDefaults();
        confi.Run_Product_Payment_Trigger__c = True;
        insert confi;
        
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
 ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True; 
        
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId= rtid;
        prod2.Name = '671999';
        prod2.Current_Principal_Balance__c = 500;
        prod2.Payment_Apportionment__c = 'Fees > Principal > Interest';
        prod2.Collection_Sub_Status__c = 'Annulled';
        prod2.Interest_Waived_Off__c = true;
        prod2.Interest_Waived_Off_Start_Date__c = System.today().addDays(-1);
        prod2.Interest_Waived_Of_End_Date__c = System.today().addDays(+10);
        prod2.Interest_Rate__c = 10;
        prod2.Collection_Agency__c = 9999;
        prod2.Current_Interest_Amount__c = 300;
        prod2.Recalled_Date__c = System.today().addDays(-30);
        prod2.Settlement_Rate__c = NULL;
        prod2.Status__c = 'Recall - Fraud';
               prod2.Purchase_Province__c='PE';
 ProductTriggerHandler.runProductTrigger = False;
        insert prod2;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__c prod1 = new Product__c();
        prod1.RecordTypeId= rtid;
        prod1.Name = '671998';
        prod1.Collection_Sub_Status__c = 'Annulled';
        prod1.Collection_Agency__c = 29;
        prod1.Recalled_Date__c = System.today().addDays(-30);
        prod1.Status__c = 'Recall - Fraud';
                prod1.Purchase_Province__c='PE';
ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = placement.id
            
        );
        insert placementhistorycObj;
        
         Placement_history__c placementhistorycObj1 = new Placement_history__c (
            product__c = prod2.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = placement.id
            
        );
        insert placementhistorycObj1;
        Test.startTest(); 
        //product payment record creation
        Product_Payments__c prodpay12 = new  Product_Payments__c();
        prodpay12.CCS_Account__c = prod.id;
        prodpay12.Payment_Amount__c = 50;
        prodpay12.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay12.Payment_Type__c = '1000';
        prodpay12.Payment_Source__c = '1';
        prodpay12.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay12.Principal_Payment_Amount__c = 100;
        prodpay12.Ignore_Warning__c = true;
        
        Product_Payments__c prodpay13 = new  Product_Payments__c();
        prodpay13.CCS_Account__c = prod.id;
        prodpay13.Payment_Amount__c = 50;
        prodpay13.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay13.Payment_Type__c = '1002';
        prodpay13.Payment_Source__c = '1';
        prodpay13.Payment_Posting_Date_Text__c = '2022-10-15';
        prodpay13.Principal_Payment_Amount__c = 100;
        prodpay13.Ignore_Warning__c = true;
        prodpay13.Original_Of_Payment_Reversal__c = NULL;
        
        Product_Payments__c prodpay14 = new  Product_Payments__c();
        prodpay14.CCS_Account__c = prod1.id;
        prodpay14.Payment_Type__c = '1000';
        prodpay14.Payment_Source__c = '1';
        prodpay14.Payment_Amount__c = 50;
        prodpay14.Ignore_Warning__c = true;
        prodpay14.Pay_Due__c = 0;
        prodpay14.Tax_Amount__c = 0;
        prodpay14.Payment_Posting_Date__c= System.today().addDays(-2);
        
        Product_Payments__c prodpay15 = new  Product_Payments__c();
        prodpay15.CCS_Account__c = prod2.id;
        prodpay15.Payment_Type__c = '1000';
        prodpay15.Payment_Source__c = '1';
        prodpay15.Payment_Amount__c = 50;
        prodpay15.Ignore_Warning__c = true;
        prodpay15.Payment_Posting_Date__c= System.today().addDays(-2);
        
        List<Product_Payments__c> paylist1=new list< Product_Payments__c>();
        paylist1.add(prodpay12);
        paylist1.add(prodpay13);
        paylist1.add(prodpay14);
        paylist1.add(prodpay15);
        insert paylist1;
        
        Test.stopTest();
     }    
 /*@isTest
    static void testhandleBeforeInsertmethod(){
               ID rtid=[Select id from RecordType where sobjecttype='product__C' AND RecordType.Name = 'Distressed Account'].id;

        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 20;
        PoolTriggerHandler.runPoolTrigger = false;
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
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        list<Product_Payments__c> listNewProductPayments=new list<Product_Payments__c>();
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
       //prodpay.Payment_Provided_Agency__c = placement.id;
        prodpay.Pay_Non_Recoverable_Fee__c = 5; 
        prodpay.Pay_Recoverable_Fee__c = 5;
        prodpay.Pay_NSF__c = '100';
        prodpay.Product_Commission_Rate__c = 2 ;
        listNewProductPayments.add(prodpay);
        insert listNewProductPayments;
        productpaymentstriggerhandler.handleBeforeInsert(listNewProductPayments);
    }*/
}