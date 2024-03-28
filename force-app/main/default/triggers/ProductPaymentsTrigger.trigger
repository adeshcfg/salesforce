/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger for Product_Payments__C object 
 *  @author : A5E Consulting
 *  @date : 23/10/2019
 * 
 *************************************************************************************************/
 
trigger ProductPaymentsTrigger on Product_Payments__c(before insert, before update, after insert, after update) {
    
    //On-Off switch for trigger
    Loan_ReEngineering__c lrpSettings = Loan_ReEngineering__c.getOrgDefaults();
    Boolean runTrigger = lrpSettings.Run_Product_Payment_Trigger__c;
    if(runTrigger || test.isRunningTest()){ 
        	if(ProductPaymentsTriggerHandler.runProductTrigger){
                if(Trigger.isBefore) {
                    if(Trigger.isInsert && Trigger.new[0].CreatedDate == NULL){
                        //ProductTriggerHandler.handleBeforeInsert(Trigger.new);
                        ProductPaymentsTriggerHandler.handleBeforeInsert(Trigger.new);
                    }
                    //Ticket 4546: changes done by tejal for update payment posting month as per payment posting date
                    if(Trigger.isUpdate){
                        ProductPaymentsTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                    }                    
                }
                                
                //Customer Data Load 
                if(Trigger.isAfter) {
                    if(Trigger.isUpdate){
                        ProductPaymentsTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
                    }
                   
                    if(Trigger.isInsert){
                        ProductPaymentsTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap, Trigger.oldMap);
                    }                          
                }
            }
        }
}