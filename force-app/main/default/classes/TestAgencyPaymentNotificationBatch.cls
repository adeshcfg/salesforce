/**************************************************************************************************
*
*  Class:   
*
*  @description : TestAgencyPaymentNotificationBatch
*  @author : A5E Consulting
*  @date : 19/07/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestAgencyPaymentNotificationBatch {
    static testMethod void insertTestData(){
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
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c=100;
        insert settings;
        
        List<Placement__c> ListPlacement = [SELECT ID, Name, Agency_Name__c,Agency_Email__c FROM Placement__c];
        String sobjectname ='Placement__c';
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='101';
        plcgy.Agency_Email__c = 'test@gmail.com';
        plcgy.Agency_Name__c = 'Test agency';
        ListPlacement.add(plcgy);
        insert ListPlacement;
        
        Id ccsRecordTYpeId = CustomerProcessingBatchTest.getsObjectRecordTypeId('Product__c', 'CCS Account');
        Product__c prod2 = new Product__c(
                                        Name='123451234512345123451234512345',
                                        RecordTypeId =  ccsRecordTYpeId,
                                        Last_Name__c = 'last name of length2',
                                        First_Name__c = 'first name of length 25 c',
                                        Disbursement_Date__c = SYSTEM.Today(),
                                        Open_Date_EQ__c = SYSTEM.Today(), 
                                        Payment_Frequency__c = 'Weekly',
                                        Monthly_Payment_Amount__c = 1252.00,
                                        Current_Balance__c = 120.00,
                                        FairShare_Percentage__c = 12,
                                        Last_Payment_Amount__c = 123.00,
                                        CCS_Stage_Last_Changed__c = SYSTEM.Today(),
                                        Last_Payment_Date__c = SYSTEM.Today(),
                                        Middle_Name__c = 'middle name length20',
                                        SIN__c = '123456789',
                                        Phone_Home__c = '1234567890',
                                        Address_Line1__c = 'address1 of length 32 characters',
                                        Address_Line2__c = 'address2 of length 32 characters',
                                        City__c = 'NEWYORK CITY OF USUS',
                                        State__c = 'A',
                                        Provinces__c = 'Nova Scotia',
                                        Zip_Code__c = '123456789',
                                        Investment_Group__c = 'BNS CCS 1',
                                        Purchase_Date__c = SYSTEM.Today()
                                        );
        insert prod2;
        List<Product__c> prodList = [Select id from Product__c ]; 

        Product_Payments__c prod = new Product_Payments__c();
        prod.Payment_Source__c = '1';
        prod.payment_Type__c = '1000';
        prod.Payment_Amount__c = 100;
        prod.CCS_Account__c = prodList[0].Id;
		insert prod;
        
        Test.StartTest();
        AgencyPaymentNotificationBatch instancevar = new AgencyPaymentNotificationBatch();
        Database.executeBatch(instancevar);
       
        Test.StopTest();
        
    }
    static testMethod void insertTestFile(){
        Test.StartTest();
        Test.StopTest();
    }

}