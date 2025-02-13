/**
 * @description       : Test class for ZipFileStatusChecker
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-13-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class ZipFileStatusCheckerTest {
    @TestSetup
    static void makeData() {
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Document_Name__c = Datetime.now().format('yyyyMMdd') + '_Test1';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Distressed').getRecordTypeId();
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Database.insert(docInfo);
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }

    @isTest
    static void fileStatusCheckTest() {
        Test.startTest();
        Database.executeBatch(new ZipFileStatusChecker('Test1'));
        Test.stopTest();
    }
}
