/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Schedule Class that will execute DeleteProductSnapshotBatch.     
*  @author : A5E Consulting
*  @date : 01/30/2017   

*************************************************************************************************/
Public Class ProductSnapshotJob implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        
        Database.executeBatch(New DeleteProductSnapshotBatch(), 200);
    }
    
    //Run from test class
    Public static void schedulerMethod() {

          string timeinterval = '24 00 * * * ?';
    
          System.schedule('Apex-EveryDay',timeinterval, new TCIJobScheduler ());
    
    }      
}