/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for DocomotionUpdatesOnDocumentBatch Batch
 *  @author : A5E Consulting
 *  @date : 06/08/2020
 
 *************************************************************************************************/
public class DocomotionUpdatesBatchSchedular implements Schedulable{
     public void execute(SchedulableContext sc) {
        Database.executeBatch(new DocomotionUpdatesOnDocumentBatch(), 20);
     }
}