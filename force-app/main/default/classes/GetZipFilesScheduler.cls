/**
 * @description       : Scheduler to schedule zip file processing
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 06-03-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class GetZipFilesScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new GetZipFilesListQueueable());
    }
}
