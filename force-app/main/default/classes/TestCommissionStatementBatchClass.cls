/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of CommissionStatementBatchClass
 *  @author : A5E Consulting
 *  @date : 17/06/2022
 * 
 *************************************************************************************************/
@Istest
public class TestCommissionStatementBatchClass {
    @testsetup
    public static void makeData() {
        
        API_Call_Details__c cs = new API_Call_Details__c();
        cs.Name='Agency Portal API';
        //cs.Other fiels values
        insert cs;
        
    }
       public static testMethod void testMethod1() 
    {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        system.debug('settings:'+settings);
        //API_Call_Details__c  settings = new API_Call_Details__c ();
        //settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        update settings;
        //List<Placement__c> lstPlacement= new List<Placement__c>();        
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        Product__c prod2 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 106;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Collection_Agency__c = Decimal.valueOf(place.Name);  
        prod2.Account_Portfolio_ID__c = '825';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c=prod2.id;
        prodpay.Payment_Type__c ='1001';
        prodpay.Payment_Amount__c=1002;
        //prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Provided_Agency__c=place.id;
        prodpay.Payment_Source__c = '1';
       // prodpay.Commission_Amount__c = prodpay.Payment_Amount__c * (ComissionRate);
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay;
        ProductPaymentsTriggerHandler.runProductTrigger = true;
        //Page.DummyPageApiName = 'CommissionStatementVF';   
        
        Test.startTest();
            
            //CommissionStatementController();
            CommissionStatementBatch obj = new CommissionStatementBatch();
            DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
    
     public static testMethod void testMethod2() 
    {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        system.debug('settings:'+settings);
        //API_Call_Details__c  settings = new API_Call_Details__c ();
        //settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        update settings;
        //List<Placement__c> lstPlacement= new List<Placement__c>();        
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        Product__c prod2 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 106;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Collection_Agency__c = Decimal.valueOf(place.Name);
		prod2.Account_Portfolio_ID__c = '825';        
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c=prod2.id;
        prodpay.Payment_Type__c ='1001';
        prodpay.Payment_Amount__c=1002;
        //prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Provided_Agency__c=place.id;
        prodpay.Payment_Source__c = '1';
       // prodpay.Commission_Amount__c = prodpay.Payment_Amount__c * (ComissionRate);
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay;
        ProductPaymentsTriggerHandler.runProductTrigger = true;
        //Page.DummyPageApiName = 'CommissionStatementVF';   
        
        //Test.startTest();
          CommissionStatementScheduler sh1 = new CommissionStatementScheduler();
          String sch = '0 0 23 * * ?';
          system.schedule('Test Territory Check', sch, sh1);
        //Test.stopTest();
      
    }
}