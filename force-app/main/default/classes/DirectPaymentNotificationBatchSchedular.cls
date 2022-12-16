/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for DirectPaymentNotificationBatch
 *  @author : A5E Consulting
 *  @date : 18/11/2021
 
 *************************************************************************************************/
public class DirectPaymentNotificationBatchSchedular implements Schedulable{
     public void execute(SchedulableContext sc) {
          //CustomerIdentifierBatch customerBatchInstance = new CustomerIdentifierBatch(); 
          Database.executeBatch(new SendDirectPaymentDocumentToPortalBatch(), 200);
     }
}