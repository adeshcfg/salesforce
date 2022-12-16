/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Application__c object 
 *  @author : A5E Consulting
 *  @date : 04/15/2016
 * 
 *************************************************************************************************/
 
trigger ApplicationLoad on Application__c (after insert, before update, after update) {
    
    //On-Off switch for Trigger
    Application_Form_Settings__c formSettings = Application_Form_Settings__c.getOrgDefaults();
    Boolean runTrigger = formSettings.Run_Application_Trigger__c;
    
    if(runTrigger){   
        //if(!Test.isRunningTest()){
            //Run Trigger code if ApplicationTriggerHandler.runApplicationLoadTrigger is true
            if(ApplicationTriggerHandler.runApplicationLoadTrigger){
                if(Trigger.isBefore) {                      
                    if(Trigger.isUpdate) {           
                        //new ApplicationTriggerHandler().handleBeforeUpdate(Trigger.New, Trigger.OldMap);
                    }
                }
            }
            
            //Run Trigger code if ApplicationTriggerHandler.runApplicationLoadTrigger is true
            if(ApplicationTriggerHandler.runApplicationLoadTrigger){
                if(Trigger.isAfter) {
                    if(Trigger.isUpdate) {
                        //new ApplicationTriggerHandler().handleAfterUpdate(Trigger.New, Trigger.OldMap);
                    }
                }
            }   
        //}      
    }   
}