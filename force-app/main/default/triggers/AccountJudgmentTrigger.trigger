trigger AccountJudgmentTrigger on Account_Judgment__c (after insert, after update) {
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Account_Judgment_Trigger__c;
    
    if(runTrigger){
        if(AccountJudgmentTriggerHandler.runAccountJudgmentTrigger){
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                    AccountJudgmentTriggerHandler.updateProductRecord(Trigger.new);
                    system.debug('After insert Acc Judg');
                    Utilities.runAccountJudgmentTrigger = FALSE;
                    AccountJudgmentTriggerHandler.updateActiveAccountJudgmentRecord(Trigger.new);
                    AccountJudgmentTriggerHandler.updateAmountsOnJudgment(Trigger.new);
                   //Bug:5564- Commented below line
                    // AccountJudgmentTriggerHandler.populateJudgmentWithPlacement(Trigger.new);
                }
                
                if(Trigger.isUpdate && Utilities.runAccountJudgmentTrigger){
                    Utilities.runAccountJudgmentTrigger = FALSE;
                    AccountJudgmentTriggerHandler.handleAfterUpdate(Trigger.new);
                    AccountJudgmentTriggerHandler.updateActiveAccountJudgmentRecord(Trigger.newMap, Trigger.oldMap);
                    AccountJudgmentTriggerHandler.updateAmountsOnJudgment(Trigger.new);
                    //AccountJudgmentTriggerHandler.updateActiveAccountJudgmentRecord(Trigger.new);
                    //Bug:5564- Commented below line
                    //AccountJudgmentTriggerHandler.populateJudgmentWithPlacement(Trigger.new);
                }
            }    
        }
    }
}