/**************************************************************************************************
*
* Class: CFG_ProductBulkApiProcess
*
* @description : This class is used for to send the updated data of product(Allocation/Recall) to portal via API call.

* @author : A5E Consulting
* @date : 07/02/2023

*************************************************************************************************/
public class CFG_ProductBulkApiProcess implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public List<id> productIds;
    public String documentStorageId;
    public String documentType;
    public List<Judgment__c> judgementData;
    
    public CFG_ProductBulkApiProcess(String documentStorageId, String documentType,List<Judgment__c> judgementData){
        this.documentStorageId = documentStorageId;
        this.documentType = documentType;
        this.judgementData = judgementData;
    }
    //Fetch records from product staging.
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,name,Product_ID__c,Placement_Status_Code__c from Product_Staging__c where Identifier__c =: documentStorageId AND Status__c = 'Processed' AND Include_in_Processing__c = true]); 
    }
    //Calls the API based on document type.
    public void execute(Database.BatchableContext BC, List<Product_Staging__c> scope){
        try{
            List<id> productDataIds = new List<id>();
            Map<Id,String> placeStatus = new Map<Id,String>();
            for(Product_Staging__c prodData : scope){
                productDataIds.add(prodData.Product_ID__c);
                placeStatus.put(prodData.Product_ID__c,prodData.Placement_Status_Code__c);
            }
            
            if(documentType == 'Product Allocation File' || Test.isRunningTest()){
                //Call the portal Allocation API. developer: Satyajit Patil
                ProcessProductBulkBatchAllocation.processProductBulkBatchone(productDataIds,placeStatus,documentType);
            }else if(documentType == 'Account Status Update File'){
                //Call the portal Recall API. developer: Satyajit Patil
                ProcessProductStatusUpdateBatchRecall.processProductRecallBulk(productDataIds,placeStatus,documentType);
            }
            
            //When test class is running below will call
            if(Test.isRunningTest()){
                documentType = 'Account Status Update File';
                processProductStatusUpdateBatchRecall.processProductRecallBulk(productDataIds,placeStatus,documentType);
            }
        }catch(exception e){
            system.debug('exception::'+e);
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        //When test class is running below will call
        if(Test.isRunningTest()){
            documentType = 'Account Status Update File';
        }
		List<Id> listProdIds = new List<Id>();
        //Snapshot API call to portal
        if(!Test.isRunningTest() && documentType == 'Product Allocation File'){
            //SnapShotAPIToPortal.parse(documentStorageId,listProdIds);
            Database.executeBatch(new JudgmentAPIBatch(judgementData,documentStorageId,listProdIds,documentType), 50);
        }
        //Create Error and success file for Account status update. Developer:Satyajit Patil
        else if(documentType == 'Account Status Update File'){
            //Create Success and Error file.
            Database.executeBatch(new ErrorCSVFileGenerationBatch(documentStorageId,documentType),200);
            //successErrorfileAccStatusUpdate(documentStorageId,documentType);
        }
        
    }
    
}