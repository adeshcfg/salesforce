/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will Test The schedule DistressedReacalled batch
 *  @author : A5E Consulting
 *  @date : 22 April 2019
 * 
 *************************************************************************************************/
@isTest
public class TestDistressedRecaleedBatchSchedule {
  public Static testMethod void DistressedRecaleedBatch(){
      Database.executeBatch(New DistressedRecalled(), 100);
      
      DistressedRecaleedBatchSchedule job =new DistressedRecaleedBatchSchedule();
       String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, job); 
    
  
  }
    }