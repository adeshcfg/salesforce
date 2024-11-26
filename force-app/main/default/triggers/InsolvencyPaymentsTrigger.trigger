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
    
    list<Insolvency_Payment__c> insolPaymentRecords=new list<Insolvency_Payment__c>();
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Payment_Trigger__c;
    
    if(runTrigger){   
        if(trigger.isBefore){
            //Before Delete
            if(trigger.isDelete){
                user u=[ select id,name from User where name =: System.label.DataArchiverUser LIMIT 1];
                if(userinfo.getUserId() != u.id){
                    InsolvencyPaymentsTriggerHandler.handleBeforeDelete(trigger.old);
                }
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
            for(Insolvency_Payment__c insolPayment:trigger.new){
                if(insolPayment.External_Correlation_ID__c==NULL){
                    insolPaymentRecords.add(insolPayment);
                }
            }
            if(!insolPaymentRecords.isEmpty()){
                InsolvencyPaymentsTriggerHandler.handleAfterInsert(insolPaymentRecords);
            }
        }             
    }
}