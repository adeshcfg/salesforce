/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger for Settlement__c object 
*  @author : A5E Consulting
*  @date : 06/09/2020
* 
*************************************************************************************************/
trigger SettlementTrigger on Settlement__c (before insert, before update, after insert, after update) {
    if(SettlementTriggerHandler.runSettlementTrigger){
        if(trigger.isBefore){
            if(trigger.isInsert){
                SettlementTriggerHandler.SetPlacementAgency(trigger.new);
                SettlementTriggerHandler.handleBeforeInsert(trigger.new);
            }
            if(trigger.isUpdate){
               SettlementTriggerHandler.SetPlacementAgencyBeforeUpdate(trigger.new, trigger.oldMap);           
            }
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
                SettlementTriggerHandler.handleAfterInsert(trigger.new);
            }
            if(trigger.isUpdate){
                SettlementTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);
                
            }
        }
    }
}