/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for DeleteTasks Batch
 *  @author : A5E Consulting
 *  @date : 06/16/2020
 
 *************************************************************************************************/
public class DeleteBatchScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          DeleteTasks deleteTasksBatchInstance = new DeleteTasks (); 
          database.executebatch(deleteTasksBatchInstance, 200);
     }
}