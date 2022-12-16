@isTest
public class TestProductRecallExcelFileProcessing {
  public static testMethod void productRecall(){
       
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
        docStorage.Uploaded_By__c = 'External User';
        insert docStorage;
        
        ProductTriggerHandler.runProductTrigger = false;
        //ProductTriggerHandler.runProductAPI = false;
        Product__c product = new Product__c();
        product.name = '1000008';
        product.Collection_Agency__c = 29;
        product.Pool_Name_Text__c = 'PO-00141';
        product.Status_Changed_Date__C = Date.newInstance(2022, 09, 03);
        product.Placement_Status__c = '800110';
        product.Assignment_Date__c = Date.newInstance(2022, 08, 03);
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = '656P177';
        product2.Collection_Agency__c = 2;
        product2.Status_Changed_Date__C = Date.newInstance(2022, 07, 03);
        product2.Assignment_Date__c = Date.newInstance(2022, 09, 03);
        product2.Placement_Status__c = '900110';
        insert product2;
        
        product2.Placement_Status__c = '800110';
        update product2;
        
        String prodAgency = String.valueOf(product2.Collection_Agency__c);
        
        Product_Staging__c productStaging = new Product_Staging__c();
       
        productStaging.Product_ID__c = product2.ID;
        productStaging.Comment__c = 'Success';
        productStaging.Placement_Agency__c = '1';
        productStaging.Putback_Buyback_Amount__c = 100;
        insert productStaging;

          String data =   '[{"data_id":"1000008","place_id":"900300"},'+
                        '{"data_id":"656P177","place_id":"900100"},'+
                        '{"data_id":"656P17744556","place_id":"900200"},'+
                        '{"data_id":"1000P008","place_id":"900100"},'+
                        '{"data_id":"656P178","place_id":"900300"},'+
                        '{"data_id":"1000P005","place_id":"900200"}'+
                            ']';
        
        String accountID = '1234567';
        Test.startTest();   
        ProductRecallExcelFileProcessing abc = new ProductRecallExcelFileProcessing(data,place.name,docStorage.id);
        //abc.accountID = '1234567';
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
    }
}