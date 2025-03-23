/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a trigger for Insolvency_Payment__c object 
*  @author : A5E Consulting
*  @date : 05/21/2024
* 
*************************************************************************************************/

trigger InsolvencyPaymentsTrigger on Insolvency_Payment__c (after insert, before delete, before insert, before update) {
    
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Payment_Trigger__c;
    if(UserInfo.getLastName() == System.label.DataArchiverUser){
        runTrigger = FALSE;        
    }
    if(runTrigger){   
        if(trigger.isBefore){
            //Before Delete
            if(trigger.isDelete){
                InsolvencyPaymentsTriggerHandler.handleBeforeDelete(trigger.old);
            }
            //Before Insert
            if(trigger.isInsert){
                InsolvencyPaymentsTriggerHandler.handleBeforeInsert(trigger.new);
            }
            //Before Update
            if(Trigger.isUpdate){
                InsolvencyPaymentsTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
            
        }
        //After Insert Trigger
        if(Trigger.isInsert){                        
            InsolvencyPaymentsTriggerHandler.handleAfterInsert(Trigger.new);
        }             
    }
}