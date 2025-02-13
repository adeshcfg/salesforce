/**
 * @description       : Test class for StagingRecordsDeleteScheduler
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-13-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class StagingRecordsDeleteSchedulerTest {
    @TestSetup
    static void makeData() {
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE;
        docInfo.Document_Name__c = 'Test1';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Distressed').getRecordTypeId();
        Document_Storage__c docInfo1 = docInfo.clone();
        docInfo1.Document_Name__c = 'Test2';
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Database.insert(new List<Document_Storage__c>{ docInfo, docInfo1 });
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;

        Product_Staging__c ps = new Product_Staging__c(Identifier__c = docInfo.Id);
        Product_Staging__c ps1 = new Product_Staging__c(Identifier__c = docInfo.Id);
        Product_Staging__c ps2 = new Product_Staging__c(Identifier__c = docInfo1.Id);
        List<Product_Staging__c> psRecords = new List<Product_Staging__c>{ ps, ps1, ps2 };
        Database.insert(psRecords);

        DateTime testCreatedDate = DateTime.now().addDays(-4);
        for (Product_Staging__c prodStaging : psRecords) {
            Test.setCreatedDate(prodStaging.Id, testCreatedDate);
        }
    }

    @isTest
    static void testScheduledJob() {
        Test.startTest();
        StagingRecordsDeleteScheduler scheduler = new StagingRecordsDeleteScheduler();
        scheduler.execute(null);
        Test.stopTest();
    }
}
