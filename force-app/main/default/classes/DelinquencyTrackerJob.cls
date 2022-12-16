/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Schedule Class that will execute Delinquency Tracker Jobs    
*  @author : A5E Consulting
*  @date : 07/12/2017   

*************************************************************************************************/
public class DelinquencyTrackerJob implements Schedulable{
	
	public void execute(SchedulableContext sc) {        
        Database.executeBatch(new DeleteDelinquencyTrackerBatch());
    }
    
    //Run from test class
    Public static void schedulerMethod() {

          string timeinterval = '24 00 * * * ?';
    
          System.schedule('Apex-EveryDay',timeinterval, new DelinquencyTrackerJob ());    
    } 
}