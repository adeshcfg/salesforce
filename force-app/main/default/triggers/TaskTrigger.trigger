/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Task and Activities object 
 *  @author : A5E Consulting
 *  @date : 29/08/2016
 * 
 *************************************************************************************************/
trigger TaskTrigger on Task (before insert, before update, after insert, after update) {
    
    //On-Off switch for trigger
    Collection_Custom_Setting__c custSettings = Collection_Custom_Setting__c.getOrgDefaults();
    Boolean runTrigger = custSettings.Run_Task_Trigger__c;
    
    if(runTrigger){   
        if(!Test.isRunningTest()){
            //if(ProductTriggerHandler.runProductTrigger){
                if(Trigger.isBefore) {
                    if(Trigger.isInsert){
                        
                        TaskTriggerHandler.handleBeforeInsert(Trigger.new);
                    }
                    if(Trigger.isUpdate){
                        
                    }                    
                }
                                
                //Customer Data Load
                if(Trigger.isAfter) {
                    if(Trigger.isUpdate){
                        
                    }
                    else if(Trigger.isInsert){
                        TaskTriggerHandler.handleAfterInsert(Trigger.new);
                    }                          
                }
            //}
        }
    }
}