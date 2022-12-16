/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a scheduler class to generate TCI CSV file
 *  @author : A5E Consulting
 *  @date : 08/03/2016
 *  
 
 *************************************************************************************************/
 
public class TCIJobScheduler implements Schedulable {

    //Execute TCI Job Scheduled
    public void execute(SchedulableContext sc) {

          (new TCIJobUtil()).initiateTCIJob('Scheduled');

    }
    
    //Run from test class
    Public static void schedulerMethod() {

          string timeinterval = '24 00 * * * ?';
    
          System.schedule('Apex-EveryDay',timeinterval, new TCIJobScheduler ());
    
    }      
}