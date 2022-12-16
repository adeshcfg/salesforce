/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a trigger for Pool object 
*  @author : A5E Consulting
*  @date : 028/03/2022
* 
*************************************************************************************************/
trigger PoolTrigger on Pool__c (before insert, before Update) {
    if(PoolTriggerHandler.runPoolTrigger){
    	if(Trigger.isBefore) {
            if(Trigger.isInsert){            
                PoolTriggerHandler.handleBeforeInsert(Trigger.new);
            }
           if(Trigger.isUpdate){            
                PoolTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }    
    }
    
    
}