@isTest
public class TestFidemCustomerNotificationSchedule {
    public static testMethod void FidemCustomerNotificationSchedule(){
            
            FidemCustomerNotificationSchedule fidemCustomerNotificationBatch = new FidemCustomerNotificationSchedule();
            string sch = '24 00 * * * ?'; 
            System.schedule('Test', sch, fidemCustomerNotificationBatch);
    }
}