public class ProcessRecordsBatchClass implements Database.Batchable<Product__c>,Database.Stateful{
    public List<Product__c> psAllRec = new List<Product__c>();
    public List<Product__c> psAllRec1  = new List<Product__c>();
    public List<id> prodIdList = new List<id>();
    public boolean flag;
    public integer psall=0;
	public ProcessRecordsBatchClass(List<Product__c> psAllRec,List<id> prodIdList,boolean flag ){
		this.psAllRec = psAllRec;
          system.debug(' constr psAllRec txt file'+psAllRec.size());
       		 RecursiveTriggerHandler.isFirstTime = false;
            this.prodIdList=prodIdList;
        this.flag=flag;
}	

	public Iterable<Product__c> start(Database.BatchableContext BC){
        system.debug(' start psAllRec txt file'+psAllRec.size());
        return psAllRec;
    }
    public void execute(Database.BatchableContext bc,List<Product__c> psAllRec){
        RecursiveTriggerHandler.isFirstTime = false;


        ProductTriggerHandler.runProductTrigger = false;
		update psAllRec;
        ProductTriggerHandler.runProductTrigger = true;
    
    }
    public void finish(Database.BatchableContext bc){
     system.debug(psAllRec+' end of execute psAllRec txt file'+psAllRec.size());
        if(flag==true){
       DisplayProductAllocateStagingController.getSnapshortRecords(psAllRec);
       Database.executeBatch(new ProcessRecordsBatchClassStaging(psAllRec));
        }
       PortalProductProcessingAPI.processProductBulkBatch(prodIdList, new List<Product__c>());  
    }
    
}