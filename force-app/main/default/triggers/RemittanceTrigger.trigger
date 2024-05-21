/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Remittance object 
 *  @author : A5E Consulting
 *  @date : 09/26/2018
 * 
 *************************************************************************************************/

trigger RemittanceTrigger on Remittance__c (before insert, before update, before delete, after insert, after update, after delete) {
    list<Remittance__c> remitRecords=new list<Remittance__c>();
	//On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Remittance_Trigger__c;
    
    if(runTrigger){   
            if(RemittanceTriggerHandler.runRemittanceTrigger){
                //Before Delete
                if(trigger.isBefore && trigger.isDelete){
                    list<Deleted_Records__c> deletedRecords=new list<Deleted_Records__c>();
                        user u=[ select id,name from User where name = 'OwnBackUpAdminUser' LIMIT 1];
                        for(Remittance__c remittance: trigger.old){
                            if(remittance.LastModifiedByID != u.ID){
                                ID recordID=remittance.ID;
                                Deleted_Records__c deletedRec=new Deleted_Records__c();
                                deletedRec.Object_Name__c= recordId.getSObjectType().getDescribe().getName();
                                deletedRec.Salesforce_Record_Id__c=remittance.External_Correlation_ID__c;
                                deletedRecords.add(deletedRec);
                            }
                        }
                        if(!deletedRecords.isEmpty()){
                            insert deletedRecords;
                        }
                }
                //After Trigger
                if(Trigger.isAfter) {
                    //After Update Trigger
                    if(Trigger.isUpdate){
                        RemittanceTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    }  
                    //After Insert Trigger
                    if(Trigger.isInsert){                        
                        for(Remittance__c remit:trigger.new){
                            if(remit.External_Correlation_ID__c==NULL){
                                remitRecords.add(remit);
                            }
                        }
                        if(!remitRecords.isEmpty()){
                            RemittanceTriggerHandler.handleAfterInsert(remitRecords);
                        }
                    }             
                }               
            }
    }
}