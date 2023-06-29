/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Product__c object 
 *  @author : A5E Consulting
 *  @date : 10/06/2016
 * 
 *************************************************************************************************/
 
trigger ProductTrigger on Product__C(before insert, before update, after insert, after update) {
    
    //On-Off switch for trigger
  
    Loan_ReEngineering__c lrpSettings = Loan_ReEngineering__c.getOrgDefaults();
    Boolean runTrigger = lrpSettings.Run_Product_Trigger__c;
      system.debug('product runTrigger::'+runTrigger);
    //system.debug('CPU Time Inside Trigger**' + Limits.getCpuTime());    
    if(runTrigger && RecursiveTriggerHandler.isFirstTime){   
        //if(!Test.isRunningTest()){
            //system.debug('runProductTrigger::::'+ProductTriggerHandler.runProductTrigger);
            //system.debug('CPU Time Inside Trigger2**' + Limits.getCpuTime());    
            if(ProductTriggerHandler.runProductTrigger){
                //system.debug('CPU Time Inside Trigger3**' + Limits.getCpuTime());    
                if(Trigger.isBefore) {
                    if(Trigger.isInsert){
                        ProductTriggerHandler.handleBeforeInsert(Trigger.new);
                    }
                    if(Trigger.isUpdate){
                        ProductTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    }
                }
                                
                //Customer Data Load
                if(Trigger.isAfter) {
                
                    if(Trigger.isInsert){
                     system.debug('calling handleAferInsert');
                     
                        //ProductTriggerHandler.handleafterinsertdate(Trigger.new);
                         //system.debug('calling insertdatemethod');
                        ProductTriggerHandler.handleAferInsertUpdate(Trigger.new, Trigger.oldMap, true);                   
                        
                    }                          
                    if(Trigger.isUpdate){
                        //system.debug('calling handleAferInsertUpdate');
                       // ProductTriggerHandler.handleAferInsertUpdate(Trigger.new, Trigger.oldMap, false);
                        system.debug('trigger update check');
                        ProductTriggerHandler.handleAfterUpdate(Trigger.new, trigger.oldmap);
                        //ProductTriggerHandler.handleAfterUpdateUpdatedate(Trigger.new,trigger.oldmap);
                    }
                     
                }
            }
        //}
    }
    
}