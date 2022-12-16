@isTest
private class TestPoolSummaryScheduleClass {

    static testMethod void myTestMethod() {        
         test.starttest();
         PoolSummaryScheduleClass myClass = new PoolSummaryScheduleClass ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
}