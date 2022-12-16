/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for CustomerIdentifier Batch Schedular
 *  @author : A5E Consulting
 *  @date : 06/15/2020
 
 *************************************************************************************************/
@isTest
public class TestCustomerIdentifierBatchSchelduler {
    public static testMethod void testschedule() {
        Test.StartTest();
        CustomerIdentifierBatchScheduler testsche = new CustomerIdentifierBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}