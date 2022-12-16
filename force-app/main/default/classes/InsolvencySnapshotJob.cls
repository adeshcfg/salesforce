/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Schedule Class that will execute InsolvencySnapshotBatch.     
*  @author : A5E Consulting
*  @date : 05/08/2018   

*************************************************************************************************/
Public Class InsolvencySnapshotJob implements Schedulable {
    
    public void execute(SchedulableContext sc) {        
        Database.executeBatch(New InsolvencySnapshotBatch(), 200);
    }
    
    //Run from test class
    Public static void schedulerMethod() {

          string timeinterval = '24 00 * * * ?';
    
          System.schedule('Apex-EveryDay',timeinterval, new InsolvencySnapshotJob());
    }      
}