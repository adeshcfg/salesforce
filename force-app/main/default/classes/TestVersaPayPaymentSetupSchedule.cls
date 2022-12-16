/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a testclass for VersaPayPaymentSetupSchedule 
 *  @author : A5E Consulting
 *  @date : 02/12/2016
 *  
 
 *************************************************************************************************/
 
@isTest
public class TestVersaPayPaymentSetupSchedule{
    
    public Static testMethod void testVersPayPaymentSetupJob(){
        
        Database.executeBatch(New VersaPayPaymentSetupBatch(), 1);        
        VersaPayPaymentSetupSchedule job = new VersaPayPaymentSetupSchedule();        
        String sch = '0 0 23 * * ?'; 
        VersaPayPaymentSetupSchedule.SchedulerMethod();
        system.schedule('Test', sch, job); 
    }   
    
}