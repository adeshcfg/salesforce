/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Schedular class for MerchantAccountUpdatesBatch
 *  @author : A5E Consulting
 *  @date : 12/03/2021
 
 *************************************************************************************************/
public class MerchantAccountUpdatesSchedular implements Schedulable{
    public static void execute(SchedulableContext sc) {
		/*list<AsyncApexJob> listAsyncApexJob = [SELECT Id, CreatedById, CreatedDate, Status, CompletedDate
											   FROM AsyncApexJob
											   WHERE ApexClass.Name = 'MerchantAccountUpdatesSchedular' 
                                               And Status ='Queued'];

        if(!listAsyncApexJob.isEmpty()
        && listAsyncApexJob[0].Status =='Queued' && listAsyncApexJob.size() >= 2){
            //do nothing
        }
        else{
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(5);
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(MerchantAccountUpdatesSchedular.class.getName() + '-' + now.format(), cronString, new MerchantAccountUpdatesSchedular());           
        }*/
          Database.executeBatch(new MerchantAccountUpdatesBatch(), 200);
     }
}