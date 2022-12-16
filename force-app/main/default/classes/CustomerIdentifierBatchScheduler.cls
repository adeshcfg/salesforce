/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for CustomerIdentifier Batch
 *  @author : A5E Consulting
 *  @date : 06/15/2020
 
 *************************************************************************************************/
public class CustomerIdentifierBatchScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          //CustomerIdentifierBatch customerBatchInstance = new CustomerIdentifierBatch(); 
          Database.executeBatch(new CustomerIdentifierBatch(), 200);
     }
}