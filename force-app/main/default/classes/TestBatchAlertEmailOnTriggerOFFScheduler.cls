@isTest
public class TestBatchAlertEmailOnTriggerOFFScheduler {
@isTest
    static void testMethod1(){
       test.startTest();
       BatchAlertEmailOnTriggerOFFScheduler batchRun=new BatchAlertEmailOnTriggerOFFScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test batch run ', sch, batchRun); 
        Test.stopTest(); 
    }
}