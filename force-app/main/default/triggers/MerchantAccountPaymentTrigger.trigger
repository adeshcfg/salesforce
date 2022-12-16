/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger for Merchant Account payment object 
 *  @author : A5E Consulting
 *  @date : 03/18/2021
 
 *************************************************************************************************/
trigger MerchantAccountPaymentTrigger on Merchant_Account_Payment__c (after insert) {
	//On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Merchant_Account_Payment_Trigger__c;
    system.debug('runTrigger: '+runTrigger);
    if(runTrigger){
        if(Trigger.isInsert) {
            if(Trigger.isAfter){
                MerchantAccountPaymentTriggerHandler.handleAfterInsert(trigger.new);
            }
        }
    }
}