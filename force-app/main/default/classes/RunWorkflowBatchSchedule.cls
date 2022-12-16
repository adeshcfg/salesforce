/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the Workflow run batch
 *  @author : A5E Consulting
 *  @date : 04/20/2018
 * 
 *************************************************************************************************/
public class RunWorkflowBatchSchedule implements Schedulable {

    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New RunWorkflowBatch(), 20);
    }
      
}