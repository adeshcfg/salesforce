trigger AgencyUserTrigger on Agency_User__c (before insert, before Update, after Insert, after Update) {
    
    
        if(AgencyUserTriggerHandler.runAgencyUserTrigger){
            if(Trigger.isBefore) {
                if(Trigger.isInsert){
                    
                    AgencyUserTriggerHandler.handleBeforeInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    
                    AgencyUserTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    
                }
            }
            
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                        AgencyUserTriggerHandler.handleAfterInsert(Trigger.new);
                }
                if(Trigger.isUpdate){
                    AgencyUserTriggerHandler.handleAfterUpdate(Trigger.new);
                }
            
            }
          
        } 
    }