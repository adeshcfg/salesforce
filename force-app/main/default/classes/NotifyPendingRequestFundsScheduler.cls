/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for NotifyCustomerForPendingRequestFunds Batch
 *  @author : A5E Consulting
 *  @date : 09/15/2021
 
 *************************************************************************************************/
public class NotifyPendingRequestFundsScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          Database.executeBatch(new NotifyCustomerForPendingRequestFunds(), 200);
     }
}