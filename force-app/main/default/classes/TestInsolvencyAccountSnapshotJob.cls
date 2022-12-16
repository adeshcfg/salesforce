/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for InsolvencyAccountSnapshotJob   
*  @author : A5E Consulting
*  @date : 23/03/2017   

*************************************************************************************************/
@istest
public class TestInsolvencyAccountSnapshotJob {
    public Static testMethod void InsolvencyAccountSnapshotJob(){
        
        InsolvencyAccountSnapshotJob InAccSnap = new InsolvencyAccountSnapshotJob();
        
         string sch = '24 00 * * * ?';
        InsolvencyAccountSnapshotJob.SchedulerMethod();
         system.schedule('Test', sch, InAccSnap); 
        
    }

}