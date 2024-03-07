@isTest
public class TestBatchAlertEmailOnTriggerOFFScheduler {
@isTest
    static void testbatch(){
       test.startTest();
       BatchAlertEmailOnTriggerOFFScheduler batchRun=new BatchAlertEmailOnTriggerOFFScheduler();
        String sch = '0 0 48 * * ?'; 
       // system.schedule('Test batch run ', sch, batchRun); 
        Test.stopTest(); 
    }
}