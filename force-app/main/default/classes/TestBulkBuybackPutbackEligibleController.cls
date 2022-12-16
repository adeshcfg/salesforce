@isTest
public class TestBulkBuybackPutbackEligibleController {
    public static testMethod void testBuybackSellerExport(){
        list<Product__c> accs=new list<Product__c>();
        list<Product__c> accs1=new list<Product__c>();
        
		Product__c prod1 = new Product__c();
        prod1.Name = '1566P430';
        prod1.Purchase_Status__c = 'Buyback Initiated';
        prod1.Purchase_Date__c = Date.newInstance(2022, 07, 19);
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
        
        
        Test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accs);
        BulkBuybackPutbackEligibleController obj = new BulkBuybackPutbackEligibleController(sc);
        BulkBuybackPutbackEligibleController.Wrapper ccisw = new BulkBuybackPutbackEligibleController.Wrapper();
        obj.insolvencyAccNumbers = '1566';
        obj.searchInsolvencyAccounts();
        obj.getwrapListWithAmountNotEmpty();
        obj.getwrapIsNotEmpty();
       	obj.checkAndAddToWrapperList(ccisw);
        obj.back();
        obj.selectedCountry ='Eligible for Buyback';
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.key = prod1.id;
        ccisw.productAcc = prod1;
        ccisw.setProdAcc();
        ccisw.getproductAcc();
        obj.checkAndAddToWrapperList(ccisw);
        obj.insolvencyAccNumbers = '456';
        obj.searchInsolvencyAccounts();
        obj.save();
        Test.stopTest();
    }
}