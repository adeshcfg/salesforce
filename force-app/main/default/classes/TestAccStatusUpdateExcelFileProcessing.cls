@isTest
public class TestAccStatusUpdateExcelFileProcessing {
    public static testMethod void testAccountStatusUpdate(){    
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
        product.Data_Status_Description__c ='Closed (9); PIF';
        product.Assignment_Date__c = Date.newInstance(2022, 08, 03);
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = '656P177';
        product2.Collection_Agency__c = 2;
        product2.Status_Changed_Date__C = Date.newInstance(2022, 07, 03);
        product2.Assignment_Date__c = Date.newInstance(2022, 09, 03);
        product2.Placement_Status__c = '900110';
        product2.Status__c ='New Allocation - New Allocation';
        product2.Sub_Status__c ='Ready';
        product2.Placement_Status__c='100000';
        insert product2;
        
        product2.Placement_Status__c = '800110';
        
        update product2;
        
        Product__c product3 = new Product__c();
        product3.name = '1000P008';
        product3.Collection_Agency__c = 2;
        product3.Pool_Name_Text__c = 'PO-00141';
        product3.Status_Changed_Date__C = Date.newInstance(2022, 09, 03);
        product3.Placement_Status__c = '800110';
        product3.Assignment_Date__c = Date.newInstance(2022, 08, 03);
        insert product3;
        
        product3.Collection_Agency__c = 9999;
        update product3;
        
        Judgment__c judgmetInstance= new Judgment__c();
        judgmetInstance.Legal_Status__c='Judgment';
        judgmetInstance.Legal_Sub_Status__c='Vacated';
        judgmetInstance.Legal_Agency__c='2';
        JudgmentTriggerHandler.runJudgmentTrigger=false;
        insert judgmetInstance;
        JudgmentTriggerHandler.runJudgmentTrigger=true;
        
        Account_Judgment__c accJudgment = new Account_Judgment__c();
        accJudgment.Product__c = product2.id;
        accJudgment.Judgment__c = judgmetInstance.id;
        accJudgment.Status__c = 'Active';
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
        insert accJudgment;
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;
        
        String prodAgency = String.valueOf(product.Collection_Agency__c);
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Comment__c = 'Success';
        productStaging.Placement_Agency__c = '1';
        productStaging.Putback_Buyback_Amount__c = 100;
        productStaging.Placement_Main_Status__c = product2.Status__c;
        productStaging.Placement_Sub_Status__c = product2.Sub_Status__c;
        insert productStaging;
       
        String data =   '[{"data_id":"1000008","status_date":"06/13/2022","status_code":"800300"},'+
                        '{"data_id":"656P177","status_date":"07/13/2022","status_code":"800100"},'+
            			'{"data_id":"656P177","status_date":"07/13/2022","status_code":"800100"},'+
                        '{"data_id":"656P17744556","status_date":"2022-02-20","status_code":"800200"},'+
                        '{"data_id":"1000P008","status_date":"10/13/2022","status_code":"800100"},'+
                        '{"data_id":"656P178","status_date":"06/13/2022","status_code":"900300"},'+
                        '{"data_id":"1000P005","status_date":"","status_code":"800200"}'+
                            ']';
        String accountID = '1234567';
        Test.startTest();   
        AccountStatusUpdateExcelFileProcessing abc = new AccountStatusUpdateExcelFileProcessing(data,place.name,docStorage.id);
        
        SavePortalAccStatusUpdateFile abc1 = new SavePortalAccStatusUpdateFile(data,place.name,docStorage.id,docStorage);
        //abc.accountID = '1234567';
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
    }
}