/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Payment_Transaction__c object 
 *  @author : A5E Consulting
 *  @date : 05/07/2022
 * 
 *************************************************************************************************/
 
trigger PaymentTransactionTrigger on Payment_Transaction__c (before insert, after update) {
    system.debug('inside trigger');
    if(trigger.isBefore){
        if(trigger.isInsert){
			PaymentTransactionTriggerHandler.handleBeforeInsert(trigger.new);            
        }
    }
    
    if(trigger.isAfter){
        if(trigger.isAfter){
            PaymentTransactionTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);            
        }
    }
}