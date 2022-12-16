/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for DelinquencyTrackerJob
*  @author : A5E Consulting
*  @date : 07/13/2017   

*************************************************************************************************/
@isTest
public class TestDelinquencyTrackerJob{

    public Static testMethod void delnqyTrckrJob(){
        
        DelinquencyTrackerJob dtJob = new DelinquencyTrackerJob();
        
        String sch = '0 0 23 * * ?'; 
        DelinquencyTrackerJob.schedulerMethod();
        system.schedule('Test', sch, dtJob); 
        
    }
}