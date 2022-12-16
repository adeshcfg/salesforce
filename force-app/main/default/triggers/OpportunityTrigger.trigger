/**************************************************************************************************
 *
 *  Trigger:    OpportunityTriggerHandler
 *
 *  @description : This is a Trigger for Opportunity Object
 *  @author : A5E Consulting
 *  @date : 07/01/2020
 *************************************************************************************************/
trigger OpportunityTrigger on Opportunity (after insert, after update){
	//On-Off switch for trigger
    Sales_Processing__c	 config = Sales_Processing__c.getOrgDefaults();
    system.debug('config: '+config);
    if(config.Run_Opportunity_Trigger__c) {
        if(trigger.isAfter){
            if(trigger.isInsert){
                OpportunityTriggerHandler.handleOnAfterInsert(trigger.new);       
            }
            if(trigger.isUpdate){
                OpportunityTriggerHandler.handleOnAfterUpdate(trigger.new, trigger.oldMap);
            }
        }
    }
}