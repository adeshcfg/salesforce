@isTest
public class TestDisplayProdPymntStagingController {
	static{
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
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
		
        Agency_Portal_Fields_Mapping__c fieldMapping = new Agency_Portal_Fields_Mapping__c();
        fieldMapping.Object_Name__c = 'Product';
        fieldMapping.Field_API__c = 'Name';
        fieldMapping.Field_JSON_Tag__c = 'Name';
        fieldMapping.Field_Type__c = 'Text';
        fieldMapping.Name = 'Name';
        insert fieldMapping;
        
        Placement__c placementcObj = new Placement__c(
            Name = '123'
        );
        insert placementcObj;
		Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;
	}
    
    @isTest
    static void testMethod1(){
		Placement__c placement1 = new Placement__c();
        placement1.name = '11';
        insert placement1;
        
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        docSto1.Direct_Payment__c = true;
        insert docSto1;
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;
		
        Product_Payments__c prodpay5= new  Product_Payments__c();
        prodpay5.CCS_Account__c = prod.id;
        prodpay5.Payment_Amount__c = 1002;
        prodpay5.Pay_NSF__c = '100';
        prodpay5.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay5.Payment_Type__c = '1000';
        prodpay5.Payment_Source__c = '2';
        prodpay5.Deposit_Account_Type__c='ETC';
        prodpay5.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay5.Ignore_Warning__c = true;
        prodpay5.Interest_Adjustment__c = 5;
        prodpay5.Pay_Non_Recoverable_Fee__c = 5;
        prodpay5.Pay_Recoverable_Fee__c = 5;
        prodpay5.Product_Commission_Rate__c = 2 ;
        insert prodpay5;
		
		Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod.id;
        prodpay6.Payment_Amount__c = 1002;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1000';
        prodpay6.Payment_Source__c = '2';
        prodpay6.Deposit_Account_Type__c='ETC';
        prodpay6.Payment_Posting_Date_Text__c = 'Thursday';
		prodpay6.Original_Of_Payment_Reversal__c = prodpay5.id;
        prodpay6.Ignore_Warning__c = true;
        prodpay6.Interest_Adjustment__c = 5;
        prodpay6.Pay_Non_Recoverable_Fee__c = 5;
        prodpay6.Pay_Recoverable_Fee__c = 5;
        prodpay6.Pay_NSF__c = '100';
        prodpay6.Product_Commission_Rate__c = 2 ;
        insert prodpay6; 
        
        Product_payment_staging__c productpaymentstagingcObj = new Product_payment_staging__c(
            CCS_Account__c = 'test value',
            Cheque_Number__c = 'Test Value',
            Commission_Amount__c = 1.1,
            Payment_Amount__c = 1.1,
            Payment_Source__c = '1',
            Payment_Type__c = '3000',
            Placement_Agency__c = 'test value',
            Comment__c = 'Test Value',
            Status__c = 'Pending',
            Payment_Posting_Date__c = 'test value',
            Interest_Payment_Amount__c = 1.1,
            Principal_Payment_Amount__c = 1.1,
            Pay_Court__c = 'test value',
            Pay_Attorney__c = 'test value',
            Pay_NSF__c = 'test value',
            Pay_Other__c = 1.1,
            Pay_Fees__c = 1.1,
            Product_ID__c = prod.Id,
            Expected_Value__c = 'test value',
            Agency_Calculated_Comm__c = '1.0',
            Document_Storage__c = docSto1.Id,
            Tax_Amount__c = 1.1,
            Pay_Posting_Date__c = Date.today(),
            Billing_Entity__c = 'test value',
            Fee_Type__c = 'test value',
            Primary_Account_Number__c = 'test value',
            Tax_Type__c = 'test value',
            Tax_Province__c = 'test value',
            Legal_Product_Identifier__c = 'test value',
            Direct_Payment_Type__c = 'Direct Payment',
            Original_Of_Payment_Reversal__c = prodpay5.id
        );
        insert productpaymentstagingcObj;

        DisplayProductPaymentStagingController instance = new DisplayProductPaymentStagingController();
        instance.SaveBalanceAdjustment();
        DisplayProductPaymentStagingController.productWrapper prodWrapper = new DisplayProductPaymentStagingController.productWrapper(prod.name,'900000','800300','29');
        DisplayProductPaymentStagingController.productPaymentStagingWrapper wrapper = new DisplayProductPaymentStagingController.productPaymentStagingWrapper(productpaymentstagingcObj, true);
        wrapper.selected = true;
        instance.save();
    }
    
    @isTest
    static void testMethod2() {
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        insert docSto1;
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;
		
        Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod.id;
        prodpay6.Payment_Amount__c = 1002;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1000';
        prodpay6.Payment_Source__c = '2';
        prodpay6.Deposit_Account_Type__c='ETC';
        prodpay6.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay6.Ignore_Warning__c = true;
        prodpay6.Interest_Adjustment__c = 5;
        prodpay6.Pay_Non_Recoverable_Fee__c = 5;
        prodpay6.Pay_Recoverable_Fee__c = 5;
        prodpay6.Pay_NSF__c = '100';
        prodpay6.Product_Commission_Rate__c = 2 ;
        insert prodpay6; 
        
        Product_payment_staging__c productpaymentstagingcObj = new Product_payment_staging__c(
            CCS_Account__c = 'test value',
            Cheque_Number__c = 'Test Value',
            Commission_Amount__c = 1.1,
            Payment_Amount__c = 1.1,
            Payment_Source__c = '2',
            Payment_Type__c = '3000',
            Placement_Agency__c = 'test value',
            Comment__c = 'Test Value',
            Status__c = 'Pending',
            Payment_Posting_Date__c = 'test value',
            Interest_Payment_Amount__c = 1.1,
            Principal_Payment_Amount__c = 1.1,
            Pay_Court__c = 'test value',
            Pay_Attorney__c = 'test value',
            Pay_NSF__c = 'test value',
            Pay_Other__c = 1.1,
            Pay_Fees__c = 1.1,
            Product_ID__c = prod.Id,
            Expected_Value__c = 'test value',
            Agency_Calculated_Comm__c = '1.0',
            Document_Storage__c = docSto1.Id,
            Tax_Amount__c = 1.1,
            Pay_Posting_Date__c = Date.today(),
            Billing_Entity__c = 'test value',
            Fee_Type__c = 'test value',
            Primary_Account_Number__c = 'test value',
            Tax_Type__c = 'test value',
            Tax_Province__c = 'test value',
            Legal_Product_Identifier__c = 'test value',
            Direct_Payment_Type__c = 'Direct Payment',
            Original_Of_Payment_Reversal__c = prodpay6.id
        );
        insert productpaymentstagingcObj;

        DisplayProductPaymentStagingController instance = new DisplayProductPaymentStagingController();
        DisplayProductPaymentStagingController.productPaymentStagingWrapper wrapper = new DisplayProductPaymentStagingController.productPaymentStagingWrapper(productpaymentstagingcObj, true);
        wrapper.selected = true;
        instance.save();
    }
    
    @isTest
    static void testMethod3(){
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        insert docSto1;
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;

        Product_payment_staging__c productpaymentstagingcObj = new Product_payment_staging__c(
            CCS_Account__c = 'test value',
            Cheque_Number__c = 'Test Value',
            Commission_Amount__c = 1.1,
            Payment_Amount__c = 1.1,
            Payment_Source__c = '2',
            Payment_Type__c = '3000',
            Placement_Agency__c = 'test value',
            Comment__c = 'Test Value',
            Status__c = 'Processed',
            Payment_Posting_Date__c = 'test value',
            Interest_Payment_Amount__c = 1.1,
            Principal_Payment_Amount__c = 1.1,
            Pay_Court__c = 'test value',
            Pay_Attorney__c = 'test value',
            Pay_NSF__c = 'test value',
            Pay_Other__c = 1.1,
            Pay_Fees__c = 1.1,
            Product_ID__c = prod.Id,
            Expected_Value__c = 'test value',
            Agency_Calculated_Comm__c = '1.0',
            Document_Storage__c = docSto1.Id,
            Tax_Amount__c = 1.1,
            Pay_Posting_Date__c = Date.today(),
            Billing_Entity__c = 'test value',
            Fee_Type__c = 'test value',
            Primary_Account_Number__c = 'test value',
            Tax_Type__c = 'test value',
            Tax_Province__c = 'test value',
            Legal_Product_Identifier__c = 'test value'
        );
        insert productpaymentstagingcObj;

        DisplayProductPaymentStagingController instance = new DisplayProductPaymentStagingController();
        DisplayProductPaymentStagingController.productPaymentStagingWrapper wrapper = new DisplayProductPaymentStagingController.productPaymentStagingWrapper(productpaymentstagingcObj, true);
        wrapper.selected = true;
        instance.save();
    }
    
    @isTest
    static void testMethod4(){

        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        insert docSto1;
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;

        Product_payment_staging__c productpaymentstagingcObj = new Product_payment_staging__c(
            CCS_Account__c = 'test value',
            Cheque_Number__c = 'Test Value',
            Commission_Amount__c = 1.1,
            Payment_Amount__c = 1.1,
            Payment_Source__c = '1',
            Payment_Type__c = '3000',
            Placement_Agency__c = 'test value',
            Comment__c = 'Test Value',
            Status__c = 'Processed',
            Payment_Posting_Date__c = 'test value',
            Interest_Payment_Amount__c = 1.1,
            Principal_Payment_Amount__c = 1.1,
            Pay_Court__c = 'test value',
            Pay_Attorney__c = 'test value',
            Pay_NSF__c = 'test value',
            Pay_Other__c = 1.1,
            Pay_Fees__c = 1.1,
            Product_ID__c = prod.Id,
            Expected_Value__c = 'test value',
            Agency_Calculated_Comm__c = '1.0',
            Document_Storage__c = docSto1.Id,
            Tax_Amount__c = 1.1,
            Pay_Posting_Date__c = Date.today(),
            Billing_Entity__c = 'test value',
            Fee_Type__c = 'test value',
            Primary_Account_Number__c = 'test value',
            Tax_Type__c = 'test value',
            Tax_Province__c = 'test value',
            Legal_Product_Identifier__c = 'test value'
        );
        insert productpaymentstagingcObj;

        DisplayProductPaymentStagingController instance = new DisplayProductPaymentStagingController();
        DisplayProductPaymentStagingController.productPaymentStagingWrapper wrapper = new DisplayProductPaymentStagingController.productPaymentStagingWrapper(productpaymentstagingcObj, true);
        wrapper.selected = true;
        instance.save();
    }
    
    @isTest
    static void testMethod5(){
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Status__c = 'Requested';
        insert wrkAss;

        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Direct_Payment__c = true;
        insert docSto1;
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;
		
        Product_Payments__c prodpay5= new  Product_Payments__c();
        prodpay5.CCS_Account__c = prod.id;
        prodpay5.Payment_Amount__c = 1002;
        prodpay5.Pay_NSF__c = '100';
        prodpay5.Payment_Type__c = '1000';
        prodpay5.Payment_Source__c = '2';
        prodpay5.Ignore_Warning__c = true;
        prodpay5.Interest_Adjustment__c = 5;
        insert prodpay5;
		
		Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod.id;
        prodpay6.Payment_Amount__c = 1002;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '1000';
        prodpay6.Payment_Source__c = '2';
		prodpay6.Original_Of_Payment_Reversal__c = prodpay5.id;
        prodpay6.Ignore_Warning__c = true;
        prodpay6.Interest_Adjustment__c = 5;
        prodpay6.Pay_NSF__c = '100';
        insert prodpay6; 
        
        Product_payment_staging__c productpaymentstagingcObj = new Product_payment_staging__c(
            CCS_Account__c = 'test value',
            Commission_Amount__c = 1.1,
            Payment_Amount__c = 1.1,
            Payment_Source__c = '1',
            Payment_Type__c = '3000',
            Comment__c = 'Test Value',
            Status__c = 'Pending',
            Interest_Payment_Amount__c = 1.1,
            Principal_Payment_Amount__c = 1.1,
            Product_ID__c = prod.Id,
            Agency_Calculated_Comm__c = '1.0',
            Document_Storage__c = docSto1.Id,
            Tax_Amount__c = 1.1,
            Pay_Posting_Date__c = System.today().addDays(-1),
            Original_Of_Payment_Reversal__c = prodpay5.id
        );
        insert productpaymentstagingcObj;

        DisplayProductPaymentStagingController instance = new DisplayProductPaymentStagingController();
        DisplayProductPaymentStagingController.productPaymentStagingWrapper wrapper = new DisplayProductPaymentStagingController.productPaymentStagingWrapper(productpaymentstagingcObj, true);
        wrapper.selected = true;
        instance.save();
    }
    
    @isTest
    static void testMethod6(){
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Status__c = 'Requested';
        insert wrkAss;

        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Balance_Adjustment__c = true;
        insert docSto1;
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;
		
        Product_Payments__c prodpay5= new  Product_Payments__c();
        prodpay5.CCS_Account__c = prod.id;
        prodpay5.Payment_Amount__c = 1002;
        prodpay5.Pay_NSF__c = '100';
        prodpay5.Payment_Type__c = '3000';
        prodpay5.Payment_Source__c = '2';
        prodpay5.Ignore_Warning__c = true;
        prodpay5.Interest_Adjustment__c = 5;
        insert prodpay5;
		
		Product_Payments__c prodpay6= new  Product_Payments__c();
        prodpay6.CCS_Account__c = prod.id;
        prodpay6.Payment_Amount__c = 1002;
        prodpay6.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay6.Payment_Type__c = '3000';
        prodpay6.Payment_Source__c = '2';
		prodpay6.Original_Of_Payment_Reversal__c = prodpay5.id;
        prodpay6.Ignore_Warning__c = true;
        prodpay6.Interest_Adjustment__c = 5;
        prodpay6.Pay_NSF__c = '100';
        insert prodpay6; 
        
        Product_payment_staging__c productpaymentstagingcObj = new Product_payment_staging__c(
            CCS_Account__c = 'test value',
            Commission_Amount__c = 1.1,
            Payment_Amount__c = 1.1,
            Payment_Source__c = '1',
            Payment_Type__c = '3000',
            Comment__c = 'Test Value',
            Status__c = 'Pending',
            Interest_Payment_Amount__c = 1.1,
            Principal_Payment_Amount__c = 1.1,
            Product_ID__c = prod.Id,
            Agency_Calculated_Comm__c = '1.0',
            Document_Storage__c = docSto1.Id,
            Tax_Amount__c = 1.1,
            Pay_Posting_Date__c = System.today().addDays(-1),
            Original_Of_Payment_Reversal__c = prodpay5.id
        );
        insert productpaymentstagingcObj;
		
        DisplayProductPaymentStagingController instance = new DisplayProductPaymentStagingController();
        instance.save();
        DisplayProductPaymentStagingController.productPaymentStagingWrapper wrapper = new DisplayProductPaymentStagingController.productPaymentStagingWrapper(productpaymentstagingcObj, true);
        wrapper.selected = true;
        instance.SaveBalanceAdjustment();
        
      
    }
    
    public static testMethod void testData(){
        map<Id, Product_Payments__c> mapNewProductPayment = new map<Id, Product_Payments__c>();
        
        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Balance__c=1200;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Recoverable_Fee__c = 50;
        prod.Collection_Agency__c = 290;
        prod.Interest_Waived_Off__c = true;
        prod.Interest_Waived_Off_Start_Date__c = System.today();
        prod.Interest_Waived_Of_End_Date__c = System.today().addDays(+10);
        insert prod;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c = prod.id;
        prodpay.Payment_Amount__c = 5000;
        prodpay.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay.Payment_Type__c = '1002';
        prodpay.Payment_Source__c = '1';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        insert prodpay;
        mapNewProductPayment.put(prodpay.id,prodpay);
        
        Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Payment Upload File';
        insert workAssignment1;
        
        Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        docStorage1.Uploaded_By__c = 'External User';
        insert docStorage1;
        
        Savepoint sp = Database.setSavepoint();
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment,sp,workAssignment1.Id, docStorage1.Id);
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 5000;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1001';
        prodpay1.Payment_Source__c = '1';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Payment_Posting_Date__c = System.today()-1;
        prodpay1.Interest_Payment_Amount__c = 1.1;
        prodpay1.Principal_Payment_Amount__c = 1.1;
        prodpay1.Pay_Due__c = 1.1;
        prodpay1.Tax_Amount__c = 1.1;
        prodpay1.Tax_type__c = 'HST';
        prodpay1.Commission_Rate_For_payment__c = 12;
        prodpay1.Product_Commission_Rate__C = 12;
        prodpay1.Tax_Province_Rate__c = 12;
        prodpay1.Pay_NSF__c = '200';
        prodpay1.Tax_Province__c = 'ON';
        prodpay1.Interest_Adjustment__c = 120;
        insert prodpay1;
       
        mapNewProductPayment.put(prodpay1.id,prodpay1);
        
        Test.startTest();
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment, sp,workAssignment1.Id,docStorage1.Id);
        Test.stopTest();
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod.id;
        prodpay2.Payment_Amount__c = -1002;
        prodpay2.Pay_Due__c = 100;
        prodpay2.Payment_Posting_Date__c= System.today();
        prodpay2.Payment_Type__c = '1003';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Original_Of_Payment_Reversal__c = prodpay1.id;
        insert prodpay2;
        
        mapNewProductPayment.put(prodpay2.id,prodpay2);
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment,sp,workAssignment1.Id,docStorage1.Id);
    }
    
    public static testMethod void testData1(){
        map<Id, Product_Payments__c> mapNewProductPayment = new map<Id, Product_Payments__c>();

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Balance__c=1200;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Commission_Adjustment__c = 2;
        prod.Recoverable_Fee__c = 50;
        insert prod;

        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 5000;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1001';
        prodpay1.Payment_Source__c = '1';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Interest_Payment_Amount__c = 1.1;
        prodpay1.Pay_NSF__c = '200';
        prodpay1.Interest_Adjustment__c = -120;
        prodpay1.Pay_Recoverable_Fee__c = 50;
        prodpay1.Pay_Non_Recoverable_Fee__c = 20;
        prodpay1.Pay_Due__c = 10;
        prodpay1.Tax_Amount__c = 10;
        prodpay1.Tax_type__c = 'HCL';
        prodpay1.Commission_Rate_For_payment__c = 10;
        prodpay1.Product_Commission_Rate__C = 5;
        prodpay1.Legal_Product_Identifier__c = 'test';
        prodpay1.Tax_Province__c = 'ON';
        prodpay1.Tax_Province_Rate__c = 9;
        prodpay1.Pay_Recoverable_Fee__c = 100;
        prodpay1.Pay_Non_Recoverable_Fee__c = 50;
        prodpay1.Interest_Payment_Amount__c = 8;
        prodpay1.Principal_Payment_Amount__c = 7;
        insert prodpay1;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod.id;
        prodpay2.Payment_Amount__c = -1002;
        prodpay2.Pay_Due__c = 100;
        prodpay2.Payment_Posting_Date__c= System.today();
        prodpay2.Payment_Type__c = '1003';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Original_Of_Payment_Reversal__c = prodpay1.id;
        insert prodpay2;

        mapNewProductPayment.put(prodpay2.id,prodpay2);
         Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Payment Upload File';
        insert workAssignment1;
        
        Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        docStorage1.Uploaded_By__c = 'External User';
        insert docStorage1;
        
        Savepoint sp = Database.setSavepoint();
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment,sp,workAssignment1.Id,docStorage1.Id);
    }
    
    public static testMethod void testData2(){
        map<Id, Product_Payments__c> mapNewProductPayment = new map<Id, Product_Payments__c>();

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Interest_Amount__c = 200;
        prod.Collection_Agency__c = 9999;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Recoverable_Fee__c = 50;
        prod.Last_Payment_Date__c = System.today();
        prod.Last_Payment_Amount__c = 1002;
        insert prod;
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 5000;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1001';
        prodpay1.Payment_Source__c = '1';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Payment_Amount__c = 0;
        prodpay1.Pay_NSF__c = '200';
        prodpay1.Interest_Adjustment__c = 10;
        insert prodpay1;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod.id;
        prodpay2.Payment_Amount__c = -1002;
        prodpay2.Payment_Posting_Date__c= System.today();
        prodpay2.Payment_Type__c = '1003';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Original_Of_Payment_Reversal__c = prodpay1.id;
        insert prodpay2;
        
        Product_Payments__c prodpay3= new  Product_Payments__c();
        prodpay3.CCS_Account__c = prod.id;
        prodpay3.Payment_Amount__c = 10;
        prodpay3.Payment_Posting_Date__c= System.today().addDays(-2);
        prodpay3.Payment_Type__c = '1000';
        prodpay3.Payment_Source__c = '2';
        prodpay3.Ignore_Warning__c = true;
        prodpay3.Original_Of_Payment_Reversal__c = prodpay1.id;
        insert prodpay3;

        mapNewProductPayment.put(prodpay2.id,prodpay2);
         Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Payment Upload File';
        insert workAssignment1;
        
        Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        docStorage1.Uploaded_By__c = 'External User';
        insert docStorage1;
        
        Savepoint sp = Database.setSavepoint();
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment,sp,workAssignment1.Id,docStorage1.Id);
    }
    
    public static testMethod void testData3(){
        map<Id, Product_Payments__c> mapNewProductPayment = new map<Id, Product_Payments__c>();

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Balance__c=1200;
        prod.Current_Interest_Amount__c = 200;
        prod.Current_Principal_Balance__c  = 50000;
        prod.Commission_Adjustment__c = 2;
        prod.Recoverable_Fee__c = 50;
        insert prod;

        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 5000;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1001';
        prodpay1.Payment_Source__c = '1';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Adjustment__c = 5;
        prodpay1.Pay_NSF__c = '200';
        prodpay1.Interest_Adjustment__c = -120;
        prodpay1.Pay_Recoverable_Fee__c = 50;
        prodpay1.Pay_Non_Recoverable_Fee__c = 20;
        prodpay1.Pay_Due__c = 10;
        prodpay1.Tax_Amount__c = 10;
        prodpay1.Tax_type__c = 'HCL';
        prodpay1.Commission_Rate_For_payment__c = 10;
        prodpay1.Product_Commission_Rate__C = 5;
        prodpay1.Legal_Product_Identifier__c = 'test';
        prodpay1.Tax_Province__c = 'ON';
        prodpay1.Tax_Province_Rate__c = 9;
        prodpay1.Pay_Recoverable_Fee__c = 100;
        prodpay1.Pay_Non_Recoverable_Fee__c = 50;
        prodpay1.Interest_Payment_Amount__c = 8;
        prodpay1.Principal_Payment_Amount__c = 7;
        insert prodpay1;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod.id;
        prodpay2.Payment_Amount__c = -1002;
        prodpay2.Pay_Due__c = 100;
        prodpay2.Payment_Posting_Date__c= System.today();
        prodpay2.Payment_Type__c = '1003';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Original_Of_Payment_Reversal__c = prodpay1.id;
        prodpay2.Interest_Payment_Amount__c = 8;
        prodpay2.Principal_Payment_Amount__c = 8;
        insert prodpay2;
            
        mapNewProductPayment.put(prodpay2.id,prodpay2);
        
         Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Payment Upload File';
        insert workAssignment1;
        
        Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        docStorage1.Uploaded_By__c = 'External User';
        insert docStorage1;
        
        Savepoint sp = Database.setSavepoint();
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment,sp,workAssignment1.Id,docStorage1.Id);
    }
    
    public static testMethod void testData4(){
        map<Id, Product_Payments__c> mapNewProductPayment = new map<Id, Product_Payments__c>();

        Product__c prod = new Product__c();
        Id recordid= [SELECT id,RecordType.developerName from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recordid;
        prod.Name = '12345';
        prod.Current_Interest_Amount__c = 200;
        prod.Collection_Agency__c = 9999;
        prod.Commission_Rate__c = 25;
        prod.Settlement_Rate__c = 85;
        prod.Interest_Rate__c = 2;
        prod.Recalled_Date__c = System.today();
        prod.Commission_Adjustment__c = 2;
        prod.Recoverable_Fee__c = 50;
        prod.Last_Payment_Date__c = System.today();
        prod.Last_Payment_Amount__c = 1002;
        insert prod;
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c = prod.id;
        prodpay1.Payment_Amount__c = 5000;
        prodpay1.Payment_Posting_Date__c= System.today().addDays(-1);
        prodpay1.Payment_Type__c = '1001';
        prodpay1.Payment_Source__c = '1';
        prodpay1.Ignore_Warning__c = true;
        prodpay1.Interest_Payment_Amount__c = 0;
        prodpay1.Pay_NSF__c = '200';
        prodpay1.Interest_Adjustment__c = 10;
        insert prodpay1;
        
        Product_Payments__c prodpay2= new  Product_Payments__c();
        prodpay2.CCS_Account__c = prod.id;
        prodpay2.Payment_Amount__c = -1002;
        prodpay2.Payment_Posting_Date__c= System.today();
        prodpay2.Payment_Type__c = '1003';
        prodpay2.Payment_Source__c = '2';
        prodpay2.Ignore_Warning__c = true;
        prodpay2.Original_Of_Payment_Reversal__c = prodpay1.id;
        insert prodpay2;
        
        mapNewProductPayment.put(prodpay2.id,prodpay2);
        
        Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Payment Upload File';
        insert workAssignment1;
        
        Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        docStorage1.Uploaded_By__c = 'External User';
        insert docStorage1;
        
        Savepoint sp = Database.setSavepoint();
        DisplayProductPaymentStagingController.calculateBalanceBackdatedPayments(mapNewProductPayment,sp,workAssignment1.Id,docStorage1.Id);
    }
    
    
}