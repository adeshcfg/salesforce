public class JudgmentAPIBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	List<Judgment__c> judgmentUpdateList;    
    public List<id> productIds;
    public String documentStorageId;
    public List<Judgment__c> judgData;
    public List<Judgment__c> judgDataUpdate = new List<Judgment__c>();
    
    public JudgmentAPIBatch(List<Judgment__c> judgmentUpdateList,String documentStorageId,List<id> productIds){
        this.judgmentUpdateList = judgmentUpdateList;
        this.productIds = productIds;
        this.documentStorageId = documentStorageId;
    }
    
     public List<Judgment__c> start(Database.BatchableContext BC){
         return judgmentUpdateList;
     }
    
    public void execute(Database.BatchableContext BC, List<Judgment__c> scope){
        for(Judgment__c judgment : scope){
            judgData = PortalJudgmentProcessingAPI.processJudgmentHelper(judgment.id);
            judgDataUpdate.addAll(judgData);
        }        
    }
    
    public void finish(Database.BatchableContext BC) {
		// batch to update outbound request body and outbound response fields on judgment 
        Database.executeBatch(new PortalJudgmentProcessingAPIBatch(judgDataUpdate,documentStorageId,productIds), 40);
        
        
    }
}