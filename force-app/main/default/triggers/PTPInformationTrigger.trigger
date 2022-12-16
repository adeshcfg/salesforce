/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for PTP Information object 
 *  @author : A5E Consulting
 *  @date : 02/13/2017
 * 
 *************************************************************************************************/
 
trigger PTPInformationTrigger on PTP_Information__c(after insert, after update, before delete) {
    
    //On-Off switch for Trigger
    Loan_ReEngineering__c formSettings = Loan_ReEngineering__c.getOrgDefaults();
    Boolean runTrigger = formSettings.Run_PTP_Trigger__c;
    
    if(runTrigger){   
        if(!Test.isRunningTest()){
            if(PTPInformationTriggerHandler.runPTPTrigger){
                if(Trigger.isAfter) {                      
                    if(Trigger.isInsert) {           
                        new PTPInformationTriggerHandler().handleAfterInsert(Trigger.New);
                    }
                }
            }
            
            if(PTPInformationTriggerHandler.runPTPTrigger){
                if(Trigger.isAfter) {                      
                    if(Trigger.isUpdate) {           
                        new PTPInformationTriggerHandler().handleAfterUpdate(Trigger.New, Trigger.OldMap);
                    }
                }
            }
        }      
    }
}