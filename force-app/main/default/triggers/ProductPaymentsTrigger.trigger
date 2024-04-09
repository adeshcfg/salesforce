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
    list<Product_Payments__c> prodPayRecords=new list<Product_Payments__c>();
    map<ID,Product_Payments__c> prodPayNewMap=new map<ID,Product_Payments__c>();
    map<ID,Product_Payments__c> prodPayOldMap=new map<ID,Product_Payments__c>;
    //On-Off switch for trigger
    Loan_ReEngineering__c lrpSettings = Loan_ReEngineering__c.getOrgDefaults();
    Boolean runTrigger = lrpSettings.Run_Product_Payment_Trigger__c;
    if(runTrigger || test.isRunningTest()){ 
        	if(ProductPaymentsTriggerHandler.runProductTrigger){
                if(Trigger.isBefore) {
                    if(Trigger.isInsert){
                        for(Product_Payments__c prodPay:trigger.new){
                            if(prodPay.CreatedDate == NULL){
                                prodPay.IsUnArchived__c=FALSE;
                            }
                            else{
                                prodPay.IsUnArchived__c=TRUE;
                            }
                        }
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
                        for(product_Payments__c prodPay:trigger.new){
                            if(prodPay.IsUnArchived__c==FALSE){
                                prodPayRecords.add(prodPay);
                                prodPayNewMap.put(prodPay.ID,trigger.newMap.get(prodPay.ID));
                                prodPayOldMap.put(prodPay.ID,trigger.oldMap.get(prodPay.ID));
                            }
                        }
                        if(!prodPayRecords.isEmpty()){
                            ProductPaymentsTriggerHandler.handleAfterInsert(prodPayRecords, prodPayNewMap, prodPayOldMap);
                        }
                    }                          
                }
            }
        }
}