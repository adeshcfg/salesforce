public class CFG_ProcessWorkAssignment implements Queueable, Database.AllowsCallouts {
    
    public String workAssignmentId;

    public CFG_ProcessWorkAssignment(String workAssignmentId) {
        this.workAssignmentId = workAssignmentId;
    }
    public void execute(QueueableContext context) {
        
        CFG_ProcessSuccessRecords.processWorkAssignment(workAssignmentId, 'comment', true);
    }

}