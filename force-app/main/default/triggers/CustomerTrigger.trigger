/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Customer object 
 *  @author : A5E Consulting
 *  @date : 03/08/2021
 * 
 *************************************************************************************************/
trigger CustomerTrigger on Account (before update, after update) {
    //On-Off switch for trigger
    Application_Config_Settings__c settings = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = settings.Run_Account_Trigger__c;
    system.debug('runTrigger: '+runTrigger);
    if(runTrigger){
        if(CustomerTriggerHandler.runCustomerTrigger){
            system.debug('trigger running');
            if(trigger.isUpdate){
                if(trigger.isBefore){
                    CustomerTriggerHandler.onBeforeUpdate(trigger.oldMap, trigger.new);
                }
                if(trigger.isAfter){
                    CustomerTriggerHandler.onAfterUpdate(trigger.oldMap, trigger.new);
                }
            }
        }
    }
    
}