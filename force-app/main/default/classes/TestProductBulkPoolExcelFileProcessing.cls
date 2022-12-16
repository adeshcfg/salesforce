@isTest
public class TestProductBulkPoolExcelFileProcessing {
	public static testMethod void testBuybackPutbackAmountUpdate(){        
        Placement__c place = new Placement__c();
        place.name = '29';
        insert place;
        
        Pool__c poolInstance = new Pool__c();
        //poolInstance.name = 'PO-00141';
        poolInstance.Placement_Agency__c = 29;
        poolInstance.Placement_agency_lookup__c = place.id;
        insert poolInstance;
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Buyback/Putback File';
        workAssignment.Placement_Agency__c = place.id;
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
        
        ProductTriggerHandler.runProductTrigger = false;
        //ProductTriggerHandler.runProductAPI = false;
        Product__c product = new Product__c();
        product.name = '1000008';
        product.Collection_Agency__c = 29;
        product.Pool_Name_Text__c = 'PO-00141';
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = '656P177';
        product2.Collection_Agency__c = 2;
        insert product2;
        
        
        String prodAgency = String.valueOf(product.Collection_Agency__c);
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Comment__c = 'Success';
        productStaging.Placement_Agency__c = '1';
        productStaging.Putback_Buyback_Amount__c = 100;
        insert productStaging;
       
        String data =   '[{"data_id":"1000008","pool_name":"PO-00141"},'+
                        '{"data_id":"656P177","pool_name":"PO-00142"},'+
                        '{"data_id":"656P178","pool_name":"PO-00143"},'+
                        '{"data_id":"","pool_name":""}'+
                            ']';
        
        Test.startTest();   
        ProductBulkPoolExcelFileProcessing abc = new ProductBulkPoolExcelFileProcessing(data,place.name,docStorage.id);
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
    }
}