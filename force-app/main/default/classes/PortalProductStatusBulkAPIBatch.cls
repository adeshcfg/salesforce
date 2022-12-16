global class PortalProductStatusBulkAPIBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful{

    public id documentID;
    public Set<Product_Staging__c> accountStagingSet = new Set<Product_Staging__c>();
    public id workAssignmentID;
    public decimal successRecords;
    public decimal failedRecords;
    public string failed;
    public string success;
    public set<string> failedStringSet = new Set<string>();
    public set<string> successStringSet = new Set<string>();
  	boolean AccountStatusUpdate;
    public list<Product_Staging__c> listproductstaging;
    public PortalProductStatusBulkAPIBatch(id documentID,Set<Product_Staging__c> accountStagingSet, 
                                            id workAssignmentID,
                                            decimal successRecords,decimal failedRecords,set<string> failedStringSet,
                                            set<string> successStringSet,boolean AccountStatusUpdate,
                                       list<Product_Staging__c> listproductstaging,string failed, string success) {
        this.documentID=documentID;
                                           this.failed=failed;
                                           this.success=success;
                               this.accountStagingSet= accountStagingSet;
                               this.successRecords=successRecords;
                               this.workAssignmentID=workAssignmentID;
                               this.failedRecords=failedRecords;
                               this.failedStringSet=failedStringSet;
                               this.successStringSet=successStringSet;
                               this.AccountStatusUpdate=AccountStatusUpdate;
                                                this.listproductstaging=listproductstaging;
    }
    string queryStr;
 global database.QueryLocator start(Database.BatchableContext BC) { 
     queryStr=' select id from Product_Staging__c limit 1';
         return database.getQueryLocator(queryStr);
    }
 global void execute(Database.BatchableContext BC, List<Product_Staging__c> listProduct) {
     if(AccountStatusUpdate){
   	//	DisplayAccStatusUpdateStagingController.postDocumentAPIBatch(documentID,accountStagingSet,workAssignmentID, successRecords,failedRecords,failedStringSet,successStringSet);
     }/*else{
          DisplayProductAllocateStagingController.postDocumentAPI(documentID, workAssignmentID, successRecords,
                                                                failedRecords,failedStringSet,
                                            successStringSet,failed, success,listproductstaging);
     }*/
     }
 global void finish(Database.BatchableContext BC){
        
}
                                                              
}