/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a testclass.
 *  @author : A5E Consulting
 *  @date : 08/03/2016
 *  
 
 *************************************************************************************************/
 
@isTest(SeeAllData=true)
public class TestTCIJobScheduler{

    public Static testMethod void tciJob(){
        
        
        (new TCIJobUtil()).initiateTCIJob('Scheduled');
        
        TCIJobScheduler tciJob=new TCIJobScheduler ();
        
        String sch = '0 0 23 * * ?'; 
        TCIJobScheduler.SchedulerMethod();
        system.schedule('Test', sch, tciJob); 

    }
}