/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Creditor_Account__c object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 * 
 *************************************************************************************************/

trigger CreditorAccountTrigger on Creditor_Account__c (before insert, before delete, after insert) {
	//On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Creditor_Account_Trigger__c;
    
    if(UserInfo.getLastName() == System.label.DataArchiverUser){
        runTrigger = FALSE;        
    }
    
    if(runTrigger){   
        //Before Delete
        if(trigger.isBefore && trigger.isDelete){
            CreditorAccountTriggerHandler.handleBeforeDelete(Trigger.Old);
        }
        //After Insert
                    if(Trigger.isInsert && Trigger.isAfter){                        
            CreditorAccountTriggerHandler.handleAfterInsert(Trigger.New);
                    }             
        }
    }