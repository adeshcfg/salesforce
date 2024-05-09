/**
 * @description       : Scheduler class for CTB file processing, will call portal API to check for file and process
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 05-07-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class CTBFileProcessingScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new CTBGetFileApiQueueable());
    }
}
