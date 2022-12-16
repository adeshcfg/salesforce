public class PoolSummaryScheduleClass implements Schedulable{
	public void execute(SchedulableContext sc) {
    	//if(!Test.isRunningTest()) {
        	Database.executeBatch(new PoolSummaryBatchClass(), 200);
        //}
    }
}