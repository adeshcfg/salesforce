/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the Trustee Followup Setup Batch
 *  @author : A5E Consulting
 *  @date : 28/02/2020
 * 
 *************************************************************************************************/
public class TrusteeFollowupSetupBatchSchedule implements Schedulable {
    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
        Database.executeBatch(New TrusteeFollowupSetupBatch(), 50);
    }
}