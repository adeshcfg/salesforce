@isTest
public class TestMediaRequestWrkAssExportController {
    public static testMethod void testMediaRequestExport(){
        list<Product__c> accs=new list<Product__c>();
        List<Work_Assignment__c> workAssData = new List<Work_Assignment__c>();
        
        Product__c prod1 = new Product__c();
        prod1.Name = '1566P430';
        prod1.Purchase_Status__c = 'Buyback/Putback Initiated';
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
        DocStorage.Document_Name__c = 'Media Request Export Document.csv';
        DocStorage.Document_Extension__c = 'csv';
        DocStorage.Document_Type__C = 'Media Request File';
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = False;
        insert DocStorage;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = True;
        
        Work_Assignment__c workAssData1 = new Work_Assignment__c();
        workAssData1.Title__c = 'This task for Test class1';
        workAssData1.Description__c = 'This task is for product record';
        workAssData1.Purpose__c = 'Media Request';
        workAssData1.Start_Month__c = '08';
        workAssData1.Start_Year__c = '2020';
        workAssData1.End_Month__c = '03';
        workAssData1.End_Year__c = '2021';
        workAssData1.Status__c = 'Requested';
        workAssData1.Assign_To__c = 'CFG';
        workAssData1.Application__c = true;
        workAssData1.Statements__c=true;
        workAssData1.Note_Lines__c=true;
        workAssData1.Cardholder_Agreement__c=true;
        workAssData1.Check_Copy__c=true;
        workAssData1.Drivers_License__c=true;
        workAssData1.PPSA_Registration__c=true;
        workAssData1.Repossession_And_Auction_Documents__c=true;
        workAssData1.Charge_Off_Statement__c=true;
        workAssData1.Last_Payment_Statement__c=true;
        workAssData1.Other__c=true;
        workAssData1.Other_Media_Request__c='test';
        workAssData1.RecordTypeId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Media').getRecordTypeId();
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData1;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        workAssData.add(workAssData1);
        
        Work_Assignment__c workAssData2 = new Work_Assignment__c();
        workAssData2.Title__c = 'This task for Test class1';
        workAssData2.Description__c = 'This task is for product record';
        workAssData2.Purpose__c = 'Media Request';
        workAssData2.Start_Month__c = '08';
        workAssData2.Start_Year__c = '2020';
        workAssData2.End_Month__c = '03';
        workAssData2.End_Year__c = '2021';
        workAssData2.Status__c = 'Requested';
        workAssData2.Assign_To__c = 'CFG';
        workAssData2.Original_Creditor__c = 'test';
        workAssData2.Product__c = prod1.id;
        //workAssData2.Last_Name__c='test';
        workAssData2.RecordTypeId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Media').getRecordTypeId();
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData2;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        workAssData.add(workAssData2);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(prod1);
        MediaRequestExportController list1 = new MediaRequestExportController(sc);
        list1.createCSV();
        Test.stopTest();
    }
    
    public static String formatString(String str){
        return String.isNotBlank(str) ? str : '';
    }
}