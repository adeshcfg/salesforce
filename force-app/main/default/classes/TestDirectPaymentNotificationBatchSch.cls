/**************************************************************************************************
*
*  Class:   
*
*  @description : TestDirectPaymentNotificationBatchSch
*  @author : A5E Consulting
*  @date : 19/07/2022  

*************************************************************************************************/
@istest
public class TestDirectPaymentNotificationBatchSch {
     public static testMethod void testschedule() {
		Database.executeBatch(new CallToNotificationApi(), 200);
		
        DirectPaymentNotificationBatchSchedular job = new DirectPaymentNotificationBatchSchedular();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, job);
		
	}


}