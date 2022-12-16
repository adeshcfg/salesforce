@isTest
public class TestProductAllocationExcelFileProcessing {
    public static testMethod void productAllocation(){
        String poolAgency;
        Placement__c place = new Placement__c();
        place.name = '29';
        place.Serviceable_Province__c = 'ON';
        insert place;
        
        Placement__c place1 = new Placement__c();
        place1.name = '39';
        place1.Serviceable_Province__c = 'ON';
        insert place1;
        
        Pool__c poolInstance = new Pool__c();
        poolInstance.Placement_Agency__c = 29;
        poolInstance.Placement_agency_lookup__c = place.id;
        insert poolInstance;

        Pool__c poolList = [select id,name,Placement_Agency__c from Pool__c where id =: poolInstance.id];

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
        product.Pool_Name_Text__c = poolList.name;
        product.Status_Changed_Date__C = Date.newInstance(2022, 09, 03);
        product.Placement_Status__c = '800110';
        product.Assignment_Date__c = Date.newInstance(2022, 08, 03);
        product.State__c = 'ON';
        product.Pool_Name__c = poolList.id;
        product.Data_Status_Description__c ='Closed (9); PIF';
        insert product;
        
        Placement_History__c placeHistory = new Placement_History__c();
        placeHistory.Product__c = product.id;
        placeHistory.CreatedDate = Date.newInstance(2022, 09, 03);
        insert placeHistory;
        
        Product__c product2 = new Product__c();
        product2.name = '656P177';
        product2.Collection_Agency__c = 29;
        product2.Status_Changed_Date__C = Date.newInstance(2022, 07, 03);
        product2.Assignment_Date__c = Date.newInstance(2022, 09, 03);
        product2.Placement_Status__c = '800110';
        product2.State__c = 'ON';
        product2.Pool_Name__c = poolInstance.id;
        insert product2;
        
        product2.Placement_Status__c = '800110';
        update product2;
        
        String prodAgency = String.valueOf(product2.Collection_Agency__c);
        poolAgency =  String.valueOf(Math.floor(poolInstance.Placement_Agency__c));   
        
        Product__c product3 = new Product__c();
        product3.name = '1000P005';
        product3.Collection_Agency__c = 29;
        product3.Pool_Name_Text__c = poolList.name;
        product3.Status_Changed_Date__C = Date.newInstance(2022, 09, 03);
        product3.Placement_Status__c = '800110';
        product3.Assignment_Date__c = Date.newInstance(2022, 08, 03);
        product3.State__c = 'ON';
        product3.Pool_Name__c = poolList.id;
        product3.Data_Status_Description__c = 'Closed-test';
        insert product3;	
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Name__c = product3.Name;
        productStaging.Comment__c = 'Success';
        productStaging.Placement_Agency__c = '1';
        productStaging.Current_Commission_Rate__c = 22;
        productStaging.Placed_Commission_Rate__c = 25;
        productStaging.Current_Settlement_Rate__c = 15;
        productStaging.Placed_Settlement_Rate__c = 20;
        productStaging.Value_Tier_at_Time_of_Placement__c = 'A';
        productStaging.Name__c = product.Name;
        productStaging.Status__c = 'Pending';
        productStaging.Identifier__c = docStorage.id;
        productStaging.Placement_Status_Code__c = '100000';
        productStaging.Data_Status_Code__c = '300000';
        productStaging.Document_Storage__c = productStaging.Identifier__c;
        insert productStaging;

          String data =   '[{"data_id":"1000008.00","place_id":"29.00","Commission_Rate_at_time_of_Placement":"25","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A.0","pool_name":"'+poolList.Name+'","Settlement_Rate_at_time_of_Placement":"20"},'+
                        '{"data_id":"656P177","place_id":"","Commission_Rate_at_time_of_Placement":"25","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"PO-100193","Settlement_Rate_at_time_of_Placement":"20"},'+
              			'{"data_id":"656P177","place_id":"","Commission_Rate_at_time_of_Placement":"25","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"PO-100193","Settlement_Rate_at_time_of_Placement":"20"},'+
              			'{"data_id":"656P177","place_id":"","Commission_Rate_at_time_of_Placement":"25","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"PO-100193","Settlement_Rate_at_time_of_Placement":"20"},'+
                        '{"data_id":"656P17744556","place_id":"29","Commission_Rate_at_time_of_Placement":"22","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"PO-00200","Settlement_Rate_at_time_of_Placement":"20"},'+
                        '{"data_id":"","place_id":"29","Commission_Rate_at_time_of_Placement":"22","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"PO-00100","Settlement_Rate_at_time_of_Placement":"20"},'+
                        '{"data_id":"ABC","place_id":"29","Commission_Rate_at_time_of_Placement":"25","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"PO-00100","Settlement_Rate_at_time_of_Placement":"20"},'+
                        '{"data_id":"1000P005","place_id":"29","Commission_Rate_at_time_of_Placement":"22","Current_Commission_rate":"22","Settlement_Rate":"15","Value_Tier_at_time_of_Placement":"A","pool_name":"'+poolList.Name+'","Settlement_Rate_at_time_of_Placement":"20"}'+
                            ']';
        
        String accountID = '1234567';
        Test.startTest();   
        ProductAllocationExcelFileProcessing abc = new ProductAllocationExcelFileProcessing(data,place.name,docStorage.id);
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
        
    }
}