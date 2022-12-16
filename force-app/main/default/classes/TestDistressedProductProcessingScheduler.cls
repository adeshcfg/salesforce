/**************************************************************************************************
*
*  Class:   
*
*  @description : TestDistressedProductProcessingScheduler
*  @author : A5E Consulting
*  @date : 04/07/2022  

*************************************************************************************************/


@istest
public class TestDistressedProductProcessingScheduler {
    public static testMethod void testschedule() {
		Database.executeBatch(new DistressedProductProcessingBatch(), 200);
		
        DistressedProductProcessingScheduler job = new DistressedProductProcessingScheduler();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, job);
		
	}

}