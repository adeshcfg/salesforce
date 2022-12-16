/**************************************************************************************************
 *
 *  Class:   
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 15/10/2020
 
 *************************************************************************************************/
public class DeleteEFTAttachmentsBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        
        return Database.getQueryLocator(
            [select id, createdDAte from Attachment where Name = 'Allocated Payments.csv' OR Name = 'Un-allocated Payments.csv']
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Attachment> listAttahments){
        
        delete listAttahments;
    }
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}