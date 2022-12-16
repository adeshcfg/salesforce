/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Batch Class that updates PTP those satisfy criteria for Process builder and workflow
*  @author : A5E Consulting
*  @date : 09/14/2017   

*************************************************************************************************/
public Class PTPUpdateBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id, Name, createdDate, Payment_Date__c, PTP_Method__c, PTP_Amount__c, PTP_Date__c, PTP_mate__c
                                         From PTP_Information__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<PTP_Information__c> ptpList){
        
        List<PTP_Information__C> ptpListToUpdate = new List<PTP_Information__c>();
        
        For(PTP_Information__c ptp : ptpList){
            
            if(system.Today() == (ptp.Payment_Date__c + 5)){
                ptpListToUpdate.add(ptp);
            }
            if(system.Today() == (ptp.Payment_Date__c - 3)){
                ptpListToUpdate.add(ptp);
            }
            
        }
        
        PTPInformationTriggerHandler.runPTPTrigger = false;
        update ptpListToUpdate;
        PTPInformationTriggerHandler.runPTPTrigger = true;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}