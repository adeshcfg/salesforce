/**************************************************************************************************
*
*  Class:  savePortalAccStatusUpdateFileBatch
*
*  @description : This class create product staging records when agency user upload file for account status update.
*  @author : A5E Consulting
*  @date : 29/03/2023

*************************************************************************************************/

public class savePortalAccStatusUpdateFileBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    List<Product_staging__c> prodStagList;
    document_storage__c docStorage;
    
    //Constructor to get staging record and its document storage record.
    public savePortalAccStatusUpdateFileBatch(List<Product_staging__c> listProdStaging, document_storage__c docStorage){
        system.debug('listProdStaging::'+listProdStaging);
        this.prodStagList = listProdStaging;
        this.docStorage = docStorage;
    }
    
     public List<Product_Staging__c> start(Database.BatchableContext BC){
         return prodStagList;
     }
    
    //Insert Product Staging records.
    public void execute(Database.BatchableContext BC, List<Product_Staging__c> scope){
    //public void execute(QueueableContext context) {
      try{
        system.debug('scope::'+prodStagList);
        List<Product_Staging__c> listProdStag = new List<Product_Staging__c>();
        for(Product_Staging__c scp : scope){
            
            listProdStag.add(scp);
        }
        insert listProdStag;
      }catch(exception e){
          system.debug('exception::'+e);
      }
          //Database.SaveResult[] sr = database.insert(prodStagList);
     }
    
     public void finish(Database.BatchableContext BC) {
       
        //Call the processes generation batch/validation check batch.
    	Database.executeBatch(new CFG_ProcessBulkAPIResult('',docStorage.ID,docStorage.Placement_Identifier__c,docStorage.Document_Type__c,docStorage),200);

    }
}