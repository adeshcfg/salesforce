/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for DeleteTasks Batch Schedular
 *  @author : A5E Consulting
 *  @date : 06/16/2020
 
 *************************************************************************************************/
@isTest
public class TestDeleteTasksBatchSchelduler {
  public static testMethod void testschedule() {
    Test.StartTest();
    DeleteBatchScheduler testsche = new DeleteBatchScheduler();
    String sch = '0 0 23 * * ?';
    system.schedule('Test status Check', sch, testsche );
    Test.stopTest();
  }
}