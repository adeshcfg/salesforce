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
  
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Trigger__c;
    
    if(runTrigger || test.isRunningTest()){   
            if(InsolvencyTriggerHandler.runInsolvencyTrigger || test.isRunningTest()){
                
                //Before Trigger
                if(Trigger.isBefore) {
                    
                    //Before Insert Trigger
                    if(Trigger.isInsert  && Trigger.new[0].CreatedDate == NULL){
                        InsolvencyTriggerHandler.handleBeforeInsert(Trigger.new);
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
                        String createdDate = String.valueOf(Trigger.new[0].createddate);
                        String systemDate = String.valueOf(System.now());
                        if(Trigger.isInsert && createddate == systemDate){
                         InsolvencyTriggerHandler.handleAfterInsert(Trigger.new);
                        }
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