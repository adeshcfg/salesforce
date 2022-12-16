/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the CollectionContactAccountBatch
 *  @author : A5E Consulting
 *  @date : 09/05/2017
 * 
 *************************************************************************************************/
public class CollectionContactAccountSchedule implements Schedulable {

    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New CollectionContactAccountBatch(), 40);
    }
    
    //Run from test class
    /*Public static void schedulerMethod() {

          string timeinterval = '24 00 * * * ?';    
          System.schedule('Apex-EveryDay',timeinterval, New CollectionContactAccountBatch());    
    }*/  
}