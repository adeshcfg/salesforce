/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for ProductSnapshotJob    
*  @author : A5E Consulting
*  @date : 02/03/2017   

*************************************************************************************************/
@isTest
public class TestProductSnapshotJob{

    public Static testMethod void prodSnapJob(){
        
        ProductSnapshotJob prdSnapJob=new ProductSnapshotJob();
        
        String sch = '0 0 23 * * ?'; 
        ProductSnapshotJob.SchedulerMethod();
        system.schedule('Test', sch, prdSnapJob); 
        
    }
}