/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for NotifyFuturePaymentToCustomersBatch Batch
 *  @author : A5E Consulting
 *  @date : 09/15/2021
 
 *************************************************************************************************/
public class NotifyFuturePaymentToCustomersScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          Database.executeBatch(new NotifyFuturePaymentToCustomersBatch(), 200);
     }
}