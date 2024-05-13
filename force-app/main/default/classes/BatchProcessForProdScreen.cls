/**************************************************************************************************
*
* Class: BatchProcessForProdScreen
*
* @description : Call Recall/Account status update portal API.
@developer name : satyajit patil
* @author : A5E Consulting
* @date : 23/03/2023

*************************************************************************************************/

public class BatchProcessForProdScreen implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    List<Id> prodList;
    Map<Id, String> placementStatus;
    String docType;
    public static List<String> allocate = new List<String>{ 'Product Allocation File', 'Product Allocation Individual' };
    public static List<String> recall = new List<String>{ 'Account Status Update File', 'Account Status Update Pool' };

    //Call Recall/Account status update portal API.
    public BatchProcessForProdScreen(List<ID> productId, Map<Id, String> placementStatus, String docType) {
        this.prodList = productId;
        this.placementStatus = placementStatus;
        this.docType = docType;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT id FROM product__c WHERE id IN :prodList]);
    }
    public void execute(Database.BatchableContext BC, List<Product__c> scope) {
        if (allocate.contains(docType) || Test.isRunningTest()) {
            //Call the portal Allocation API. developer: Satyajit Patil
            ProcessProductBulkBatchAllocation.processProductBulkBatchone(prodList, placementStatus, docType);
        } else if (recall.contains(docType)) {
            //Call the portal Recall API. developer: Satyajit Patil
            ProcessProductStatusUpdateBatchRecall.processProductRecallBulk(prodList, placementStatus, docType);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}
