/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for CustomerIdentifierBatch
 *  @author : A5E Consulting
 *  @date : 06/12/2020
 
 *************************************************************************************************/

 @isTest
 public class TestCustomerIdentifierBatch {
 
     static testmethod void TestBatch() {
         list<Account> listAccounts = new list<Account>();
         for(integer i=0; i < 10; i++){
             system.debug('i: '+i);
             Account accInstance = new Account();
             accInstance.LastName = 'TestName'+i;
             accInstance.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
             listAccounts.add(accInstance);
         }
         insert listAccounts;
         system.debug('listAccounts: '+listAccounts);
         list<Product__c> listProduct = new list<Product__c>();
         for(Account acc : listAccounts){
             Product__c productInstance = new Product__c();
             productInstance.Customer__c = acc.Id;
             productInstance.Run_Identifier_Check_On__c = Date.today();
             productInstance.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
             listProduct.add(productInstance);
             
             Product__c productWithAgency = new Product__c();
             productWithAgency.Customer__c = acc.Id;
             productWithAgency.Run_Identifier_Check_On__c = Date.today();
             productWithAgency.Collection_Agency__c = 68;
             productWithAgency.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
             listProduct.add(productWithAgency);
             
             Product__c productWithAgency2 = new Product__c();
             productWithAgency2.Customer__c = acc.Id;
             productWithAgency2.Run_Identifier_Check_On__c = Date.today();
             productWithAgency2.Collection_Agency__c = 6;
             productWithAgency2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
             listProduct.add(productWithAgency2);
             
             Product__c distressedProdInstance = new Product__c();
             distressedProdInstance.Customer__c = acc.Id;
             productInstance.Run_Identifier_Check_On__c = Date.today();
             distressedProdInstance.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
             listProduct.add(distressedProdInstance);
         }
         insert listProduct;
         system.debug('listproduct'+listProduct);
         system.debug([select Id, recordtype.developername, Run_Identifier_Check_On__c from Product__c][0]);
         Test.startTest();
         CustomerIdentifierBatch c = new CustomerIdentifierBatch();
         Database.executeBatch(c);
         CorrectCustomerIdentifierBatch batch = new CorrectCustomerIdentifierBatch();
         Database.executeBatch(batch);
         Test.stopTest();
     }
 }