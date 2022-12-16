/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a trigger for Document Storage object 
*  @author : A5E Consulting
*  @date : 18/01/2022
* 
*************************************************************************************************/
trigger DocumentStorageTrigger on Document_Storage__c (before insert, before update, After insert, after update) {
    
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Document_Storage_Trigger__c;
    system.debug('runTrigger' +runTrigger);
    if(runTrigger){
        system.debug('run' +DocumentStorageTriggerHandler.runDocumentStorageTrigger);
        if(DocumentStorageTriggerHandler.runDocumentStorageTrigger){
            if(Trigger.isBefore) {
                if(Trigger.isInsert){
                    
                    DocumentStorageTriggerHandler.handleBeforeInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    
                    DocumentStorageTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    
                }
            }
            
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                        DocumentStorageTriggerHandler.handleAfterInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    DocumentStorageTriggerHandler.handleAfterupdate(Trigger.new, Trigger.oldMap );
                }
            
            }
          
        }  
    }
}