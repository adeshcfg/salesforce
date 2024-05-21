/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Creditor_Account__c object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 * 
 *************************************************************************************************/

 trigger CreditorAccountTrigger on Creditor_Account__c (before delete, after insert) {

    list<Creditor_Account__c> creditorAccountRecords=new list<Creditor_Account__c>();
	//On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Creditor_Account_Trigger__c;
    
    if(runTrigger){   
        //Before Delete
        if(trigger.isBefore && trigger.isDelete){
        CreditorAccountTriggerHandler.handleBeforeDelete(trigger.old);   
        }
                    //After Insert Trigger
                    if(Trigger.isInsert && Trigger.isAfter){                        
                        for(Creditor_Account__c creditorAccount:trigger.new){
                            if(creditorAccount.External_Correlation_ID__c==NULL){
                                creditorAccountRecords.add(creditorAccount);
                            }
                        }
                        if(!creditorAccountRecords.isEmpty()){
                            CreditorAccountTriggerHandler.handleAfterInsert(creditorAccountRecords);
                        }
                    }             
        }
    }