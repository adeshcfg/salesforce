/**
 * @description       : Scheduler class for MM file processing, will call portal API to check for file and process
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 01-07-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class MMFileProcessingScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new MMGetFileApiQueueable());
    }
}
