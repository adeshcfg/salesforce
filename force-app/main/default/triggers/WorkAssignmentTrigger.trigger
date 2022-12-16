/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a trigger for Work Assignment object 
*  @author : A5E Consulting
*  @date : 07/12/2021
* 
*************************************************************************************************/

trigger WorkAssignmentTrigger on Work_Assignment__c (before insert, before update, After insert, after update,after delete) {
    
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Work_Assignment_Trigger__c;
    
    if(runTrigger){
        if(WorkAssignmentTriggerHandler.runWorkAssignmentTrigger){
            if(Trigger.isBefore) {
                if(Trigger.isInsert){
                    
                    WorkAssignmentTriggerHandler.handleBeforeInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    
                    WorkAssignmentTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    
                }
            }
            
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                   
                        WorkAssignmentTriggerHandler.handleAfterInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    WorkAssignmentTriggerHandler.handleAfterupdate(Trigger.new, Trigger.oldMap);
                    
                }
            	if(Trigger.isDelete){
                    WorkAssignmentTriggerHandler.handleAfterDelete(Trigger.Old);
                }
            }
          
        }  
    }
}