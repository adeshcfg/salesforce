/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the PTPMetBatch
 *  @author : A5E Consulting
 *  @date : 09/22/2017
 * 
 *************************************************************************************************/
public class PTPMetBatchSchedule implements Schedulable {

    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New PTPMetBatch(), 40);
    }
      
}