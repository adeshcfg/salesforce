public class PortalJudgmentProcessingAPIBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {
    List<Id> judgmentId = new List<Id>();
	List<Judgment__c> listJudgUpdate = new List<Judgment__c>();
    public List<id> productIds;
    public String documentStorageId;
    public String documentType;
    
    public PortalJudgmentProcessingAPIBatch(List<Judgment__c> listJudgUpdate,String documentStorageId,List<id> productIds, String documentType) {
        this.listJudgUpdate = listJudgUpdate;
        this.productIds = productIds;
        this.documentStorageId = documentStorageId;
        this.documentType = documentType;
        
        for(Judgment__c judg : listJudgUpdate){
            judgmentId.add(judg.id);
        }
    }

    public database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Judgment__c WHERE ID IN: judgmentId';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Judgment__c> listJudgment) {
        ProductTriggerHandler.runProductTrigger = false;
        if (listJudgUpdate.size() > 0) {
            JudgmentTriggerHandler.runJudgmentTrigger = false;
            update listJudgUpdate;
            JudgmentTriggerHandler.runJudgmentTrigger = false;
        }
        ProductTriggerHandler.runProductTrigger = true;
    }

    public void finish(Database.BatchableContext bc) {
        //call snapshot 
        if(!Test.isRunningTest() && documentType == 'Product Allocation File'){
            SnapShotAPIToPortal.parse(documentStorageId,productIds);
        }
    }
}