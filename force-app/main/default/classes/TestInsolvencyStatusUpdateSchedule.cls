/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a testclass for InsolvencyStatusUpdateBatchSchedule
 *  @author : A5E Consulting
 *  @date : 10/11/2018
 *  
 
 *************************************************************************************************/

@isTest
public class TestInsolvencyStatusUpdateSchedule{
    
    public Static testMethod void testInsolvencyStatusUpdate(){
        
        Database.executeBatch(New InsolvencyStatusUpdateBatch(), 1);        
        InsolvencyStatusUpdateSchedule job = new InsolvencyStatusUpdateSchedule();        
        String sch = '0 0 00 * * ?'; 
       // InsolvencyStatusUpdateSchedule.SchedulerMethod();
        system.schedule('Test', sch, job); 
    }   
    
 }