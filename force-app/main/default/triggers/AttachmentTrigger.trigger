/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Attachment object 
 *  @author : A5E Consulting
 *  @date : 10/06/2016
 * 
 *************************************************************************************************/

trigger AttachmentTrigger on Attachment (before delete, before update, after delete) {
    //On-Off switch for trigger
    Application_Config_Settings__c csSettings = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = csSettings.Run_Attachment_Trigger__c;
    
    if(runTrigger){   
        if(!Test.isRunningTest()){
            if(Trigger.isBefore) {                      
                if(Trigger.isDelete){
                    AttachmentTriggerHandler.handleBeforeDelete(Trigger.Old);
                }
                if(Trigger.isUpdate){
                    AttachmentTriggerHandler.handleBeforeEdit(Trigger.New);
                }
            }
            if(Trigger.isAfter) {                      
                if(Trigger.isDelete){
                    AttachmentTriggerHandler.handleAfterDelete(Trigger.Old);
                }
            }
        }
    }
}