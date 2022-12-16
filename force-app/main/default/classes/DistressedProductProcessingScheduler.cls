/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for DistressedInterestCalculatorBatch
 *  @author : A5E Consulting
 *  @date : 18/11/2021
 
 *************************************************************************************************/
public class DistressedProductProcessingScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          Database.executeBatch(new DistressedProductProcessingBatch(), 200);
     }
}