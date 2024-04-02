/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for SettlementIdentifierBatch
 *  @author : A5E Consulting
 *  @date : 06/12/2020
 
 *************************************************************************************************/

@isTest
public class TestSettlementIdentifierBatch {
    @TestSetup
    static void makeData(){
        list<Account> listAccounts = new List<Account>();
        for (integer i = 0; i < 2; i++) {
            Account accInstance = new Account();
            accInstance.LastName = 'TestName' + i;
            accInstance.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
            listAccounts.add(accInstance);
        }
        insert listAccounts;
        list<Product__c> listProduct = new List<Product__c>();
        for (Account acc : listAccounts) {
            Product__c productWithAgency2 = new Product__c();
            productWithAgency2.Customer__c = acc.Id;
            productWithAgency2.Run_Identifier_Check_On__c = Date.today();
            productWithAgency2.Collection_Agency__c = 6;
            productWithAgency2.Status__c = 'New Allocation - New Allocation';
            productWithAgency2.Sub_Status__c = 'Ready';
            productWithAgency2.Product_Status__c = 'Test';
            productWithAgency2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
            listProduct.add(productWithAgency2);

            Product__c distressedProdInstance = new Product__c();
            distressedProdInstance.Customer__c = acc.Id;
            distressedProdInstance.Run_Identifier_Check_On__c = Date.today();
            distressedProdInstance.Status__c = 'New Allocation - New Allocation';
            distressedProdInstance.Sub_Status__c = 'Ready';
            distressedProdInstance.Product_Status__c = 'Test';
            distressedProdInstance.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
            listProduct.add(distressedProdInstance);
        }
        insert listProduct;

        Judgment__c judgmentInst = new Judgment__c();
        judgmentInst.Run_Identifier_Check_On__c = Date.today();
        judgmentInst.Collection_Agency_Identifier__c = 'A68A';
        judgmentInst.Legal_Agency__c = '29';
        insert judgmentInst;

        Settlement__c settlementInst = new Settlement__c();
        settlementInst.Judgment__c = judgmentInst.Id;
        insert settlementInst;

        Judgment__c judgmentInst2 = new Judgment__c();
        judgmentInst2.Run_Identifier_Check_On__c = Date.today();
        judgmentInst2.Legal_Agency__c = '2';
        insert judgmentInst2;

        Settlement__c settlementInst2 = new Settlement__c();
        settlementInst2.Judgment__c = judgmentInst2.Id;
        insert settlementInst2;

        list<Settlement__c> listSettlement = new List<Settlement__c>();
        for (Product__c prod : listProduct) {
            Settlement__c settlementProdInst = new Settlement__c();
            settlementProdInst.Product__c = prod.Id;
            listSettlement.add(settlementProdInst);
        }
        insert listSettlement;
    }

    @isTest
    static void testSettlementBatch() {
        Test.startTest();
        SettlementIdentifierBatch c = new SettlementIdentifierBatch();
        Database.executeBatch(c);
        Test.stopTest();
    }

    @isTest
    static void testCorrectSettlementBatch() {
        Test.startTest();
        CorrectSettlementIdentifierBatch c = new CorrectSettlementIdentifierBatch();
        Database.executeBatch(c);
        Test.stopTest();
    }
}
