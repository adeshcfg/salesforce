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
            list<Deleted_Records__c> deletedRecords=new list<Deleted_Records__c>();
                user u=[ select id,name from User where name = 'OwnBackUpAdminUser' LIMIT 1];
                for(Creditor_Account__c creditorAccount: trigger.old){
                    if(creditorAccount.LastModifiedByID != u.ID){
                        ID recordID=creditorAccount.ID;
                        Deleted_Records__c deletedRec=new Deleted_Records__c();
                        deletedRec.Object_Name__c= recordId.getSObjectType().getDescribe().getName();
                        deletedRec.Salesforce_Record_Id__c=creditorAccount.External_Correlation_ID__c;
                        deletedRecords.add(deletedRec);
                    }
                }
                if(!deletedRecords.isEmpty()){
                    insert deletedRecords;
                }
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