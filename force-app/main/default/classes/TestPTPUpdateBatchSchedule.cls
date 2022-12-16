/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This  Test class will schedule the PTPUpdateBatch
 *  @author : A5E Consulting
 *  @date : 23/04/2019
 * 
 *************************************************************************************************/
@isTest
public class TestPTPUpdateBatchSchedule {
    public static  testMethod void PTPUpdateBatchSchedule(){
        
        PTPUpdateBatchSchedule ptpupdate = new  PTPUpdateBatchSchedule();
        string sch = '24 00 * * * ?'; 
        system.schedule('Test', sch, ptpupdate);
        
        
        
    }

}