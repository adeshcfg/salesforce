trigger PlacementHistoryTrigger on Placement_History__c (before insert,before update) { 
    
    //On-Off switch for trigger
    Distress_Setting__c  drsetting = Distress_Setting__c.getOrgDefaults();
    Boolean runTrigger = drsetting.Run_Placement_History_Trigger__c;
    
    if(runTrigger){
       // if(!Test.isRunningTest()){
            if(PlacementHistoryTriggerHandler.runPlacementHistoryTrigger == true){
                if(Trigger.isBefore){
                    if(Trigger.isInsert){
                        PlacementHistoryTriggerHandler.handleBeforeInsert(Trigger.new);
                    }
                    if(Trigger.isUpdate){
                        PlacementHistoryTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    }
                }
            }
        }
    //}

}