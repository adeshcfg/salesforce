/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for BatchAlertEmailOnTriggerOFF Batch
 *  @author : A5E Consulting
 *  @date : 07/March/2024
 *  Task 6159 
 *************************************************************************************************/
 public class BatchAlertEmailOnTriggerOFFScheduled implements Schedulable{
    public void execute(SchedulableContext sc) {
         Database.executeBatch(new BatchAlertEmailOnTriggerOFF(),100);
    }
 }