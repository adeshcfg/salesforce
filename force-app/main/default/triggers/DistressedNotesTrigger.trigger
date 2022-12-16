/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a trigger for Distressed Notes object 
*  @author : A5E Consulting
*  @date : 11/02/2022
* 
*************************************************************************************************/
trigger DistressedNotesTrigger on Distressed_notes__c (before insert, before update, After insert, after update) {
    
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Distressed_Notes_Trigger__c;
    system.debug('runTrigger' +runTrigger);
    if(runTrigger){
        system.debug('run' +DistressedNotesTriggerHandler.runDistressedNotesTrigger);
        if(DistressedNotesTriggerHandler.runDistressedNotesTrigger){
            if(Trigger.isBefore) {
                if(Trigger.isInsert){
                    
                    DistressedNotesTriggerHandler.handleBeforeInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    
                    DistressedNotesTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    
                }
            }
            
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                        DistressedNotesTriggerHandler.handleAfterInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    DistressedNotesTriggerHandler.handleAfterupdate(Trigger.new, trigger.oldmap);
                }
            
            }
          
        }  
    }
}