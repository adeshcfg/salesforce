/**************************************************************************************************
*
*  Class:   
*
*  @description : This class can be call start of the every month and creats the commission statement pdf for every agency.
*  @author : A5E Consulting
*  @date : 15/06/2021

*************************************************************************************************/
public class CommissionStatementScheduler implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        
        //Call the batch class for creating monthly commission statement for every agency.
        Database.executeBatch(new CommissionStatementBatch(), 1);
    }
}