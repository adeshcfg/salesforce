/**
 * @description       : Batch class to check for pending zip files in Document Storage for putback/buyback
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-26-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class ZipFileStatusChecker implements Database.Batchable<sObject> {
    String sellerName = '';
    public ZipFileStatusChecker(String sellerName) {
        this.sellerName = sellerName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String docStorageName = Datetime.now().format('yyyyMMdd') + '_' + sellerName + '.zip';
        return Database.getQueryLocator(
            'SELECT Id FROM Document_Storage__c WHERE Document_Name__c = :docStorageName AND File_Processing_Status__c = \'Pending\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Document_Storage__c> listDocStorage) {
        if (listDocStorage.size() > 0) {
            Document_Storage__c docStorage = listDocStorage.get(0);
            docStorage.File_Processing_Status__c = 'Failed';
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            Database.update(docStorage);
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            CTBFileValidationUtility.sendEmail('Putback/Buyback Zip generation failed', 'No response from portal', System.Label.Putback_Buyback_Email_Ids);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
