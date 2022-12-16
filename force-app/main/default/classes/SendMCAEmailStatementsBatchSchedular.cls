/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for SendMCAEmailStatementsBatch
 *  @author : A5E Consulting
 *  @date : 25/03/2021
 
 *************************************************************************************************/
public class SendMCAEmailStatementsBatchSchedular implements Schedulable{
    public static void execute(SchedulableContext sc) {
          Database.executeBatch(new SendMCAEmailStatementsBatch(), 200);
     }
}