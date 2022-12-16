@isTest
public class TestPaymentTransactionTriggerHandler {
     static testMethod void testPaymentTransaction(){
        
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
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Charged_Off_Date__c';
        FieldMap2.Field_JSON_Tag__c ='Charged_Off_Date';
        FieldMap2.Object_Name__c = 'Product';
        FieldMap2.Name = 'Charged Off Date';        
        insert FieldMap2;
         
         //Product Record Creation
         Product__C prod = new Product__c();
         string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                          AND RecordType.Name='Distressed Account'].id;
         prod.RecordTypeId=recrdid;
         prod.Name ='123456789';
         prod.Previously_Reviewed_for_Legal_Action__c=True;
         prod.Current_Principal_Balance__c=101;
         prod.Current_Interest_Amount__c=1000;
         prod.Status__c = 'New Allocation - New Allocation';
         prod.Sub_Status__c = 'Ready';
         prod.Product_Status__c = 'Test';
         prod.OwnerId= UserInfo.getUserId();
         ProductTriggerHandler.runProductTrigger = False;
         insert prod;
         ProductTriggerHandler.runProductTrigger = True;
         
         list<Payment_Transaction__c> listPaymentTransactionToProcess = new list<Payment_Transaction__c>();
		 map<ID, Payment_Transaction__c> mapPaymentTransactions = new Map<ID, Payment_Transaction__c>();
         
         
           Payment_Transaction__c prductTran = new Payment_Transaction__c();
            prductTran.Amount__c = 100;
            prductTran.Collection_Agency__c= 29;
            prductTran.Error_Message__c = 'Hello Msg';
         
          insert prductTran;
          listPaymentTransactionToProcess.add(prductTran);
          mapPaymentTransactions.put(prductTran.id , prductTran);
         
         PaymentTransactionTriggerHandler.handleAFterUpdate(listPaymentTransactionToProcess,mapPaymentTransactions);

         
     }
}