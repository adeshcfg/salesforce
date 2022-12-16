@isTest
public class TestBuyBackStatusesController {
    public static testMethod void testBuyBackStatusUpdate(){
        list<Product__c> accs=new list<Product__c>();
        list<Product__c> accs1=new list<Product__c>();
        list<Product__c> accs2=new list<Product__c>();
        list<Product__c> accs3=new list<Product__c>();
        list<Product__c> accs4=new list<Product__c>();
      
        Product__c prod1 = new Product__c();
        prod1.Name = '1566P430';
        prod1.Purchase_Status__c = 'Eligible for Buyback';
        prod1.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod1.Putback_Provision_Days__c = 15;
        prod1.collection_agency__c = 29;
        prod1.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 08, 03);
        prod1.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 08, 03);
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        accs.add(prod1);
        system.debug('accs**'+accs);
        Product__c prod2 = new Product__c();
        prod2.Name = '1566P440';
        prod2.Purchase_Status__c = 'Eligible for Putback';
        prod2.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod2.Putback_Provision_Days__c = 15;
        prod2.collection_agency__c = 29;
        prod2.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 07, 13);
        prod2.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 07, 13);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        accs1.add(prod2);
        
        Product__c prod3 = new Product__c();
        prod3.Name = '1566P450';
        prod3.Purchase_Status__c = 'Buyback Requested';
        prod3.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod3.Putback_Provision_Days__c = 15;
        prod3.collection_agency__c = 29;
        prod3.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 07, 13);
        prod3.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 07, 13);
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        accs2.add(prod3);
        
        Product__c prod4 = new Product__c();
        prod4.Name = '1566P450';
        prod4.Purchase_Status__c = 'Putback Requested';
        prod4.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod4.Putback_Provision_Days__c = 15;
        prod4.collection_agency__c = 29;
        prod4.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 07, 13);
        prod4.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 07, 13);
        prod4.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        accs4.add(prod4);
        
        Product__c prod5 = new Product__c();
        prod5.Name = '1566P460';
        prod5.Purchase_Status__c = 'Putback Requested';
        prod5.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod5.Putback_Provision_Days__c = 15;
        prod5.collection_agency__c = 29;
        prod5.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 07, 13);
        prod5.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 07, 13);
        prod5.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod5;
        
        Product__c prod6 = new Product__c();
        prod6.Name = '1566P470';
        prod6.Purchase_Status__c = 'Eligible for Buyback';
        prod6.Purchase_Date__c = Date.newInstance(2022, 07, 19);
        prod6.Putback_Provision_Days__c = 15;
        prod6.collection_agency__c = 29;
        prod6.Buyback_Putback_Status_Change_Date__c = Date.newInstance(2022, 07, 13);
        prod6.Putback_buyback_Completed_Date__c = Date.newInstance(2022, 07, 13);
        prod6.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod6;
        
        Test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accs);
        sc.setselected(accs);
        BuyBackStatusesController list1 = new BuyBackStatusesController(sc);
        
        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(accs1);
        sc1.setselected(accs1);
        BuyBackStatusesController list2 = new BuyBackStatusesController(sc1);
        
        ApexPages.StandardSetController sc2 = new ApexPages.StandardSetController(accs2);
        sc2.setselected(accs2);
        BuyBackStatusesController list3 = new BuyBackStatusesController(sc2);
        
        ApexPages.StandardSetController sc3 = new ApexPages.StandardSetController(accs3);
        sc3.setselected(accs3);
        BuyBackStatusesController list4 = new BuyBackStatusesController(sc3);
        
        ApexPages.StandardSetController sc4 = new ApexPages.StandardSetController(accs4);
        sc4.setselected(accs4);
        BuyBackStatusesController list5 = new BuyBackStatusesController(sc4);
        
        list1.selectedCountry='Buyback Initiated';
        list2.selectedCountry='Putback Initiated';
        list3.selectedCountry='Buyback Approved';
        list4.selectedCountry='Putback Approved';
        list5.selectedCountry='Remove from Buyback/Putback';
        list1.statusUpdate();
        list2.statusUpdate();
        list3.statusUpdate();
        list4.statusUpdate();
        list5.statusUpdate();
        BuyBackStatusesController.judgmentStagingWrapper ccisw = new BuyBackStatusesController.judgmentStagingWrapper(prod5, true);
        BuyBackStatusesController.judgmentStagingWrapper ccisw1 = new BuyBackStatusesController.judgmentStagingWrapper(prod6, true);
        list1.Save();
        list1.back();
        Test.stopTest();
    }
}