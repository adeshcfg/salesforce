/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the Insolvency Status Update Batch 
 *  @author : A5E Consulting
 *  @date : 10/11/2018
 * 
 *************************************************************************************************/
public class InsolvencyStatusUpdateSchedule implements Schedulable {
    
    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New InsolvencyStatusUpdateBatch(), 1);
    }
    
    //Run from test class
  /*  Public static void schedulerMethod() {

          string timeinterval = '00 00 23 * * ?';    
          System.schedule('Apex-EveryDay',timeinterval, new InsolvencyStatusUpdateSchedule());    
    }    */
}