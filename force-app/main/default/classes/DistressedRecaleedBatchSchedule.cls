/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the DistressedReacalled batch
 *  @author : A5E Consulting
 *  @date : 20 Feb 2019
 * 
 *************************************************************************************************/
public class DistressedRecaleedBatchSchedule implements Schedulable {

    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New DistressedRecalled(), 100);
    }
      
}