/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a trigger for Email Message object 
*  @author : A5E Consulting
*  @date : 06/19/2018
* 
*************************************************************************************************/

trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete) {
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_EmailMessage_Trigger__c;
    
    if(runTrigger){   
        if(!Test.isRunningTest()){
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                    EmailMessageTriggerHandler.handleBeforeInsert(Trigger.new);
                }
            }
            if(CaseTriggerHandler.runCaseTrigger){
                
                //Before Trigger
                if(Trigger.isBefore) {
                    
                    //Before Insert Trigger
                    if(Trigger.isInsert){
                        //CaseTriggerHandler.handleBeforeInsert(Trigger.new);
                    }
                    
                    //Before Update Trigger
                    if(Trigger.isUpdate){
                        //CaseTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    }           
                }  
                
                //After Trigger
                if(Trigger.isAfter) {
                    
                    //After Insert Trigger
                    if(Trigger.isInsert){
                        EmailMessageTriggerHandler.handleAfterInsert(Trigger.new);
                    }
                    
                    //After Update Trigger
                    if(Trigger.isUpdate){
                        EmailMessageTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    } 
                    
                    //After Delete Trigger
                    if(Trigger.isDelete){
                        //CaseTriggerHandler.handleAfterDelete(Trigger.new, Trigger.oldMap);
                    }               
                }             
            }
        }
    }
}