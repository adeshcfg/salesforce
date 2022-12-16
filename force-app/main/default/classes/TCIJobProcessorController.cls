/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller to call vfpage and gererate basic infrmation of previous TCI Job 
 *  @author : A5E Consulting
 *  @date : 08/03/2016
 *  
 
 *************************************************************************************************/
 
public class TCIJobProcessorController{

    // Get Set methods for message Flag 
    public Boolean messageFlag{ get;set; }
    
    public Boolean displayInitiateButton{ get;set; }
    
    public string lastManualJobRunBy { get; set; }  
    public string lastManualJobRunDate { get; set; }    
    public string lastScheduledJobRunDate { get; set; }
    
    public String message { get; set; }
    
    public TCIJobProcessorController(){
        messageFlag = false;
        displayInitiateButton = false;
        fetchJobCreatedBy();
    }
    
    public void fetchJobCreatedBy(){
        
        List <TCI_Job__c> tciJobsManual = [Select Last_Job_Run_Date__c, Last_Job_Run_By__r.Name FROM TCI_Job__c where Job_Type__c='Manual' order by createddate desc];
        if(tciJobsManual.size() > 0){
            lastManualJobRunBy = tciJobsManual.get(0).Last_Job_Run_By__r.Name;
            lastManualJobRunDate = tciJobsManual.get(0).Last_Job_Run_Date__c.format('MM/dd/yyyy');
        }
        
        List <TCI_Job__c> tciJobsScheduled = [Select Last_Job_Run_Date__c, Last_Job_Run_By__r.Name FROM TCI_Job__c where Job_Type__c='Scheduled' order by createddate desc];
        if(tciJobsScheduled.size() > 0){
            lastScheduledJobRunDate = tciJobsScheduled.get(0).Last_Job_Run_Date__c.format('MM/dd/yyyy');
        }
       
    }
    
    public void callTCIJob(){
         
         //Call controller function to get Application records based on conditions and delete existing attchment and create new attachment.
         message = new TCIJobUtil().initiateTCIJob('Manual');
         messageFlag = true;
        
     }
}