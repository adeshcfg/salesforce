public class ProcessRecordsBatchClassStaging implements Database.Batchable<Product__c>,Database.Stateful{
    public List<Product__c> psAllRec  = new List<Product__c>();
    public integer psall=0;
        public List<Product__c> psAllRec1  = new List<Product__c>();
    public ProcessRecordsBatchClassStaging(List<Product__c> psAllRec){
		this.psAllRec = psAllRec;    
	}	

	public Iterable<Product__c> start(Database.BatchableContext BC){
        return psAllRec;
    }
    public void execute(Database.BatchableContext bc,List<Product__c> psAllRec){
        
    }
    public void finish(Database.BatchableContext bc){
        system.debug(' psAllRec Excel'+psAllRec.size());
        DisplayProductAllocateStagingController.getSnapshortRecordsTwo(psAllRec);
	 
    }
    
}