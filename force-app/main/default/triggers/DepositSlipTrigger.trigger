/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Insolvency object 
 *  @author : A5E Consulting
 *  @date : 09/26/2016
 * 
 *************************************************************************************************/

trigger DepositSlipTrigger on Deposit_Slip__c (before delete) {
  
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Deposit_Slip_Trigger__c;
    
    if(runTrigger){   
        if(!Test.isRunningTest()){
            if(DepositSlipTriggerHandler.runDepsoitSlipTrigger){
                
                //Before Trigger
                if(Trigger.isBefore) {
                    /*
                    //Before Insert Trigger
                    if(Trigger.isInsert){
                        
                    }
                    
                    //Before Update Trigger
                    if(Trigger.isUpdate){
                        
                    } 
                    */
                    
                    //Before Delete Trigger
                    if(Trigger.isDelete){
                        DepositSlipTriggerHandler.handleBeforeDelete(Trigger.new, Trigger.oldMap);
                    }   
                                    
                }   
                
                //After Trigger
                
                if(Trigger.isAfter) {
                    /*
                    //After Insert Trigger
                    if(Trigger.isInsert){
                        
                    }
                    
                    //After Update Trigger
                    if(Trigger.isUpdate){
                        
                    } 
                    
                    
                    //After Delete Trigger
                    if(Trigger.isDelete){
                        
                    }    
                     */                
                }             
            }
        }
    }    
}