/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This  Test class will schedule the PTPMetBatchSchedule
 *  @author : A5E Consulting
 *  @date : 24/04/2019
 * 
 *************************************************************************************************/
@isTest
public class TestPTPMetBatchSchedule {
    public static testMethod void PTPMetBatchSchedule(){
        PTPMetBatchSchedule ptpmet = new PTPMetBatchSchedule();
         string sch = '24 00 * * * ?'; 
         system.schedule('Test', sch, ptpmet);
         
        
        
    }
}