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
    list<Product_Payments__c> prodPayRecordsBeforeInsert=new list<Product_Payments__c>();
    //On-Off switch for trigger
    Loan_ReEngineering__c lrpSettings = Loan_ReEngineering__c.getOrgDefaults();
    Boolean runTrigger = lrpSettings.Run_Product_Payment_Trigger__c;
    if(runTrigger || test.isRunningTest()){ 
        	if(ProductPaymentsTriggerHandler.runProductTrigger){
                if(Trigger.isBefore) {
                    if(Trigger.isInsert){
                        for(Product_Payments__c prodPay:trigger.new){
                            if(prodPay.CreatedDate == NULL){
                                prodPayRecordsBeforeInsert.add(prodPay);
                            }
                        }
                        //ProductTriggerHandler.handleBeforeInsert(Trigger.new);
                        if (!prodPayRecordsBeforeInsert.isEmpty()) {
                            ProductPaymentsTriggerHandler.handleBeforeInsert(prodPayRecordsBeforeInsert);                            
                        }
                    }
                    //Before delete
                    if(trigger.isDelete){
                        list<Deleted_Records__c> deletedRecords=new list<Deleted_Records__c>();
                        user u=[ select id,name from User where name = 'OwnBackUpAdminUser' LIMIT 1];
                        for(product_Payments__c prodPayment: trigger.old){
                            if(prodPayment.LastModifiedByID != u.ID){
                                ID recordID=prodPayment.ID;
                                Deleted_Records__c deletedRec=new Deleted_Records__c();
                                deletedRec.Object_Name__c= recordId.getSObjectType().getDescribe().getName();
                                deletedRec.Salesforce_Record_Id__c=prodPayment.External_Correlation_ID__c;
                                deletedRecords.add(deletedRec);
                            }
                        }
                        if(!deletedRecords.isEmpty()){
                            insert deletedRecords;
                        }
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
                            if(prodPay.External_Correlation_ID__c==NULL){

                                prodPayRecords.add(prodPay);
                            }
                        }
                        if(!prodPayRecords.isEmpty()){
                            ProductPaymentsTriggerHandler.handleAfterInsert(prodPayRecords, trigger.newMap, trigger.oldMap);
                        }
                    }                          
                }
            }
        }
}
