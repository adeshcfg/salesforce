/**************************************************************************************************
*
*  Class:   
*
*  @description : ProductExtensionTrigger
*  @author : A5E Consulting
*  @date : 01/07/2022  

*************************************************************************************************/
trigger ProductExtensionTrigger on Product_Extension__c (after insert, after update , before insert) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ProductExtensionTriggerHandler.handleAfterInsert(Trigger.new);
        } 
        if(Trigger.isUpdate){
            ProductExtensionTriggerHandler.handleAfterUpdate(Trigger.new);
        }
        
    }
    if(Trigger.isbefore){
        if(Trigger.isInsert){
            ProductExtensionTriggerHandler.handleBeforeInsert(Trigger.new);
        } 
    }
}