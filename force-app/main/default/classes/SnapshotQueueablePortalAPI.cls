public class SnapshotQueueablePortalAPI implements Queueable, Database.AllowsCallouts {
	public List<Document_Storage__c> listOfDocumentStorage;
    public String workAssignmentId;
    
    public SnapshotQueueablePortalAPI(List<Document_Storage__c> listOfDocumentStorage,String workAssignmentId) {
        this.listOfDocumentStorage = new List<Document_Storage__c>();
        this.listOfDocumentStorage.addAll(listOfDocumentStorage);
        this.workAssignmentId = workAssignmentId;
    }
    public void execute(QueueableContext context) {
        system.debug('inside SnapshotQueueablePortalAPI');
        for(Document_Storage__c documentStorage : this.listOfDocumentStorage){
            PortalDocumentStorageProcessingAPI.processDocumentStorage2(documentStorage.Id);
        }
        
       system.enqueueJob(new CFG_ProcessWorkAssignment(workAssignmentId));
    }
}