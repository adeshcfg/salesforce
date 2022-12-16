/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the PTPUpdateBatch
 *  @author : A5E Consulting
 *  @date : 01/02/2018
 * 
 *************************************************************************************************/
public class PTPUpdateBatchSchedule implements Schedulable {

    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New PTPUpdateBatch(), 200);
    }
      
}