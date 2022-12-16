/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the VersaPay Payment Setup Batch 
 *  @author : A5E Consulting
 *  @date : 11/24/2016
 * 
 *************************************************************************************************/
public class VersaPayPaymentSetupSchedule implements Schedulable {
    
    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
          Database.executeBatch(New VersaPayPaymentSetupBatch(), 1);
    }
    
    //Run from test class
    Public static void schedulerMethod() {

          string timeinterval = '24 00 * * * ?';    
          System.schedule('Apex-EveryDay',timeinterval, new VersaPayPaymentSetupSchedule());    
    }   
}