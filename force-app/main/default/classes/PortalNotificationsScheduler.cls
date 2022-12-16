/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for starting the notifications jobs. which are chained together
 *  @author : A5E Consulting
 *  @date : 18/11/2021
 
 *************************************************************************************************/
public class PortalNotificationsScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          //CustomerIdentifierBatch customerBatchInstance = new CustomerIdentifierBatch(); 
          Database.executeBatch(new SendProductStatusUpdatesToPortalBatch(), 200);
     }
}