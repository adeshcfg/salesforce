@isTest
private class TestPortalNotiDocCreationScheduler {

    static testMethod void myTestMethod() {        
         test.starttest();
         PortalNotificationDocCreationScheduler myClass = new PortalNotificationDocCreationScheduler ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
}