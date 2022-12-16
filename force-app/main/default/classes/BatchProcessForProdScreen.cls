/**************************************************************************************************
*
* Class: BatchProcessForProdScreen
*
* @description : Call Recall/Account status update portal API.
@developer name : satyajit patil
* @author : A5E Consulting
* @date : 23/03/2023

*************************************************************************************************/

public class BatchProcessForProdScreen implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
	
    List<Id> prodList;
    Map<Id,String> placementStatus;
    String docType;
    public static String allocate = 'Product Allocation File';
    public static String recall = 'Account Status Update File';
    
    //Call Recall/Account status update portal API.
     public BatchProcessForProdScreen(List<ID> productId, Map<Id,String> placementStatus,String docType){
         system.debug('run inside batch');
       this.prodList = productId;
       this.placementStatus = placementStatus;
       this.docType = docType;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id from product__c where id IN: prodList]);
    }
     public void execute(Database.BatchableContext BC, List<Product__c> scope){
         
          if(docType == allocate || Test.isRunningTest()){
                //Call the portal Allocation API. developer: Satyajit Patil
                ProcessProductBulkBatchAllocation.processProductBulkBatchone(prodList,placementStatus,allocate);
            }else if(docType == recall){
                //Call the portal Recall API. developer: Satyajit Patil
                ProcessProductStatusUpdateBatchRecall.processProductRecallBulk(prodList,placementStatus,recall);
            }
        
     }
    
     public void finish(Database.BatchableContext BC) {
         
     }
}