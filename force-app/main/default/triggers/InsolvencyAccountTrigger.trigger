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
	
	//On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Account_Trigger__c;
    
    if(runTrigger){   
        if(!Test.isRunningTest()){
            if(InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger){
            	
            	//Before Trigger
            	if(Trigger.isBefore) {
            		
            		//Before Insert Trigger
                    if(Trigger.isInsert){
                        InsolvencyAccountTriggerHandler.handleBeforeInsert(Trigger.new);
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
                        InsolvencyAccountTriggerHandler.handleAfterInsert(Trigger.new);
                    }
                    
                    //After Update Trigger
                    if(Trigger.isUpdate){
                        InsolvencyAccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    } 
                    
                    //After Delete Trigger
                    if(Trigger.isDelete){
                        InsolvencyAccountTriggerHandler.handleAfterDelete(Trigger.new, Trigger.oldMap);
                    }              
                }            	
            }
        }
    }
}