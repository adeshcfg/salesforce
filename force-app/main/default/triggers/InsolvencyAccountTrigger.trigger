/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Insolvency_Account object 
 *  @author : A5E Consulting
 *  @date : 09/18/2016
 * 
 *************************************************************************************************/


trigger InsolvencyAccountTrigger on Insolvency_Account__c(before insert, before update, before delete, after insert, after update, after delete) {
    list<Insolvency_Account__c> insolAccntRecords=new list<Insolvency_Account__c>();
    list<Insolvency_Account__c> insolAccntRecordsBeforeInsert=new list<Insolvency_Account__c>();
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Account_Trigger__c;
    
    if(runTrigger){   
            if(InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger){
                
                //Before Trigger
                if(Trigger.isBefore) {
                    
                    //Before Insert Trigger
                    if(Trigger.isInsert){
                        for(Insolvency_Account__c insolAccnt:trigger.new){
                            if(insolAccnt.CreatedDate == NULL){
                                insolAccntRecordsBeforeInsert.add(insolAccnt);
                            }
                        }
                        if(!insolAccntRecordsBeforeInsert.isEmpty()){
                            InsolvencyAccountTriggerHandler.handleBeforeInsert(insolAccntRecordsBeforeInsert);
                        }
                    }
                    
                    //Before Update Trigger
                    if(Trigger.isUpdate){
                        InsolvencyAccountTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    } 
                    
                    //Before Delete Trigger
                    /*
                    if(Trigger.isDelete){
                        InsolvencyAccountTriggerHandler.handleBeforeDelete(Trigger.new, Trigger.oldMap);
                    }  
                    */                 
                }   
                
                //After Trigger
                if(Trigger.isAfter) {
                    
                    //After Insert Trigger
                    if(Trigger.isInsert){                        
                        for(Insolvency_Account__c insolAccnt:trigger.new){
                            if(insolAccnt.External_Correlation_ID__c==NULL){
                                insolAccntRecords.add(insolAccnt);
                            }
                        }
                        if(!insolAccntRecords.isEmpty()){
                            InsolvencyAccountTriggerHandler.handleAfterInsert(insolAccntRecords);
                        }
                    }
                    
                    //After Update Trigger
                    if(Trigger.isUpdate){
                        InsolvencyAccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    } 
                    
                    //After Delete Trigger
                    if(Trigger.isDelete){
list<Insolvency_Account__C> insolvencyAccounts=new list<Insolvency_Account__C>();
user u=[ select id,name from User where name = 'OwnBackUpAdminUser' LIMIT 1];
for(Insolvency_Account__C insolAcc: trigger.new){
if(insolAcc.LastModifiedByName != u.name){
insolvencyAccounts.add(insolAcc);
}
}
if(!insolvencyAccounts.isEmpty()){
                        InsolvencyAccountTriggerHandler.handleAfterDelete(insolvencyAccounts, Trigger.oldMap);
}
                    }
                }              
            }               
        }
    }
