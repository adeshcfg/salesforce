@isTest
public class TestBatchAlertEmailOnTriggerOFFScheduled {
    @isTest
    static void testBatchExecution() {
        test.startTest();
        BatchAlertEmailOnTriggerOFFScheduled testsche = new BatchAlertEmailOnTriggerOFFScheduled();
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to update Account Name', sch,testsche);
        test.stopTest();
    }
}