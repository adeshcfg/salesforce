/**
 * @description       : Batch class to delete staging records created for putback/buyback and product status update after 3 days
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-12-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class StagingRecordsDeleteScheduler implements Schedulable, Database.Batchable<sObject> {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new StagingRecordsDeleteScheduler());
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Identifier__c FROM Product_Staging__c WHERE CreatedDate < LAST_N_DAYS:3');
    }

    public void execute(Database.BatchableContext bc, List<Product_Staging__c> listProductStaging) {
        List<String> eligibleDocumentTypes = new List<String>{
            DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE,
            DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE
        };
        Map<String, List<Product_Staging__c>> docStorageIdProductStagingMap = new Map<String, List<Product_Staging__c>>();
        List<Product_Staging__c> productStagingToDelete = new List<Product_Staging__c>();
        // Map document storage Id against related product staging records
        for (Product_Staging__c productStaging : listProductStaging) {
            if (docStorageIdProductStagingMap.containsKey(productStaging.Identifier__c)) {
                docStorageIdProductStagingMap.get(productStaging.Identifier__c).add(productStaging);
            } else {
                docStorageIdProductStagingMap.put(productStaging.Identifier__c, new List<Product_Staging__c>{ productStaging });
            }
        }
        // Only delete staging records which have related document storage record of type putback/buyback update or product status update
        for (Document_Storage__c docStorage : [
            SELECT Id
            FROM Document_Storage__c
            WHERE Id IN :docStorageIdProductStagingMap.keySet() AND Document_Type__c IN :eligibleDocumentTypes
        ]) {
            productStagingToDelete.addAll(docStorageIdProductStagingMap.get(docStorage.Id));
        }
        if (!productStagingToDelete.isEmpty()) {
            Database.delete(productStagingToDelete);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
