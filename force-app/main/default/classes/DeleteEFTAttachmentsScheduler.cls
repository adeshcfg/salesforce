/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for DeleteEFTAttachmentsBatch Batch
 *  @author : A5E Consulting
 *  @date : 06/16/2020
 
 *************************************************************************************************/
public class DeleteEFTAttachmentsScheduler implements Schedulable{
     public void execute(SchedulableContext sc) {
          DeleteEFTAttachmentsBatch deleteEFTBatchInstance = new DeleteEFTAttachmentsBatch (); 
          database.executebatch(deleteEFTBatchInstance, 200);
     }
}