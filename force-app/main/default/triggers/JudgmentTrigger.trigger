/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger for Judgment__c object 
*  @author : A5E Consulting
*  @date : 06/09/2020
* 
*************************************************************************************************/
trigger JudgmentTrigger on Judgment__c (before insert, before update, after insert, after update) {
    
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    system.debug('config::'+config);
    Boolean runTrigger = config.Run_JudgmentTrigger__c;
    if(runTrigger){
        if(JudgmentTriggerHandler.runJudgmentTrigger){
            if(Trigger.IsBefore){
                if(Trigger.isInsert){
                    system.debug('after insert');
                    JudgmentTriggerHandler.handleBeforeInsert(trigger.new);
                }
                if(Trigger.isUpdate){
                    system.debug('before update');
                    JudgmentTriggerHandler.handleBeforeUpdate(trigger.new, trigger.oldMap);
                }
                
            }
            
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                    system.debug('after insert');
                    JudgmentTriggerHandler.handleAfterInsert(trigger.new);
                    //Bug:5564 - Added below line
                    JudgmentTriggerHandler.populateJudgmentWithPlacement(Trigger.new);
                }
                if(Trigger.isUpdate){
                    system.debug('after update');
                    JudgmentTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    JudgmentTriggerHandler.setAccountJudgmentInactive(Trigger.new);
                    JudgmentTriggerHandler.updateProductLegalStatus(Trigger.newMap, Trigger.oldMap);
                    //Bug:5564 - Added below line
                    JudgmentTriggerHandler.populateJudgmentWithPlacement(Trigger.new);
                }
            }
        }
    }
}