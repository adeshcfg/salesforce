@isTest
public class TestBuybackSellerExportController {
    public static testMethod void testBuybackSellerExport(){
        list<Product__c> accs=new list<Product__c>();
        
        Product__c prod1 = new Product__c();
        prod1.Name = '1566P430';
        prod1.Purchase_Status__c = 'Buyback Initiated';
        //prod1.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod1.Putback_Provision_Days__c = 15;
        prod1.collection_agency__c = 29;
        prod1.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 08, 03);
        prod1.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 08, 03);
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod1.Originating_Creditor__c = 'Test';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;
        accs.add(prod1);
        
        Document_Storage__c  DocStorage = new Document_Storage__c();
        DocStorage.Document_Name__c = 'Buyback/Putback Initiated Export Document.csv';
        DocStorage.Document_Extension__c = 'csv';
        DocStorage.Document_Type__C = 'Buyback/Putback Initiated File';
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = False;
        insert DocStorage;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = True;
        
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(prod1);
        BuybackSellerExportController list1 = new BuybackSellerExportController(sc);
        list1.createCSV();
        Test.stopTest();
    }
    
    public static String formatString(String str){
        return String.isNotBlank(str) ? str : '';
    }
}