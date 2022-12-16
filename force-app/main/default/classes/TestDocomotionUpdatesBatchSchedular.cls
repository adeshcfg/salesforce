/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for DocomotionUpdates Batch Schedular
 *  @author : A5E Consulting
 *  @date : 01/09/2020
 
 *************************************************************************************************/
@isTest
public class TestDocomotionUpdatesBatchSchedular {
    public static testMethod void testschedule() {
        Test.StartTest();
        DocomotionUpdatesBatchSchedular testsche = new DocomotionUpdatesBatchSchedular();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}