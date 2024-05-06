/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Insolvency object 
 *  @author : A5E Consulting
 *  @date : 09/26/2016
 * 
 *************************************************************************************************/


trigger InsolvencyTrigger on Insolvency__c(before insert, before update, before delete, after insert, after update, after delete) {
    list<Insolvency__c> insolvRecords=new list<Insolvency__c>();
    list<Insolvency__c> insolvRecordsBeforeInsert=new list<Insolvency__c>();
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Trigger__c;
    
    if(runTrigger || test.isRunningTest()){   
            if(InsolvencyTriggerHandler.runInsolvencyTrigger || test.isRunningTest()){
                
                //Before Trigger
                if(Trigger.isBefore) {
                    
                    //Before Insert Trigger
                    if(Trigger.isInsert){
                        for(Insolvency__c insolv:trigger.new){
                            if(insolv.CreatedDate == NULL){
                                insolvRecordsBeforeInsert.add(insolv);
                            }

                        }
                        if(!insolvRecordsBeforeInsert.isEmpty()){
                            InsolvencyTriggerHandler.handleBeforeInsert(insolvRecordsBeforeInsert);
                        }
                    }
                    
                    //Before Update Trigger
                    if(Trigger.isUpdate){
                        InsolvencyTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    } 
                    
                    /*
                    //Before Delete Trigger
                    if(Trigger.isDelete){
                        InsolvencyTriggerHandler.handleBeforeDelete(Trigger.new, Trigger.oldMap);
                    }   
                    */                
                }   
                
                //After Trigger
                
                if(Trigger.isAfter) {
                    
                    //After Insert Trigger
                    if(Trigger.isInsert){
                        for(Insolvency__c insolv:trigger.new){
                            if(insolv.External_Correlation_ID__c==NULL){

                                insolvRecords.add(insolv);
                            }
                        }
                         InsolvencyTriggerHandler.handleAfterInsert(insolvRecords);
                    }
                    
                    //After Update Trigger
                    if(Trigger.isUpdate){
                        InsolvencyTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
                    } 
                    
                    /*
                    //After Delete Trigger
                    if(Trigger.isDelete){
                        InsolvencyTriggerHandler.handleAfterDelete(Trigger.new, Trigger.oldMap);
                    }    
                     */                
                }             
                }             

    }    
}
