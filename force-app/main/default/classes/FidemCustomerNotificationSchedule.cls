/**************************************************************************************************
 *
 *  Class:    FidemCustomerNotificationSchedule
 *
 *  @description : This will schedule the FidemCustomerNotification Batch
 *  @author : A5E Consulting
 *  @date : 24/05/2021
 *
 *************************************************************************************************/

public class FidemCustomerNotificationSchedule implements Schedulable {
	//Execute Job Scheduled
    public void execute(SchedulableContext sc) {
        Database.executeBatch(New FidemCustomerNotificationBatch(), 50);
    }
}