@isTest
private class TestPortalNotificationsScheduler {
	static testMethod void myTestMethod() {        
         test.starttest();
         PortalNotificationsScheduler myClass = new PortalNotificationsScheduler ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
}