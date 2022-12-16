/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of AttachmentTriggerHandler
 *  @author : A5E Consulting
 *  @date : 10/14/2016
 * 
 *************************************************************************************************/
@isTest
private class TestAttachmentTriggerHandler {
    
    static {
        System.Test.startTest();
        Loan_ReEngineering__c loanSettings = new Loan_ReEngineering__c();
        loanSettings.Run_Product_Validation_Trigger__c = true;
        loanSettings.Run_Product_Trigger__c = true;
        //loanSettings.Run_Attachment_Trigger__c = true;
        insert loanSettings;        
        
        Application_Config_Settings__c csSettings = new  Application_Config_Settings__c();
    	csSettings.Run_Attachment_Trigger__c = true;
    	insert csSettings;  
    }
    
    static testMethod void attachmentTest(){
        
        //Run As CSR User
        User csrUser = TestRecordsFactory.getCSRUser();
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Pending';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        insert prod;
        
        //Delete Attachment
        Attachment attchDelete = new Attachment();
        attchDelete.body = Blob.valueof('Test Body Delete');
        attchDelete.name = 'AttchDelete.pdf';
        attchDelete.parentId = prod.Id;
        insert attchDelete;
        List<Attachment> deleteList = new List<Attachment>();
        deleteList.add(attchDelete);
        System.runAs(csrUser) {
            AttachmentTriggerHandler.handleBeforeDelete(deleteList);
        }
            
        //Edit Attachment
        Attachment attchEdit = new Attachment();
        attchEdit.body = Blob.valueof('Test Body Edit');
        attchEdit.name = 'AttchEdit.pdf';
        attchEdit.parentId = prod.Id;
        insert attchEdit;
        List<Attachment> editList = new List<Attachment>();
        editList.add(attchEdit);        
        System.runAs(csrUser) {
            AttachmentTriggerHandler.handleBeforeEdit(editList);
        }
        
        delete attchDelete;
 //After Attachment is Deleted 
        if(attchDelete==Null){
List<Attachment> attachm = new list<Attachment>();
List<Task> activities = new List<Task>();
for(Attachment attach : attachm){
Task activity = new Task();
activity.Subject = 'Deleted-'+attach.Name;
activity.WhatId = attach.ParentId;
activity.Status = 'Completed';
activities.add(activity);
}
if(activities.size() > 0){
 insert activities;
        }
        
System.runAs(csrUser) {
AttachmentTriggerHandler.handleAfterDelete(attachm);
}
}
}    
    
    static testMethod void attachmentCoomunityUser(){
        
        //Run As CSR User
        User commUser= TestRecordsFactory.getCommunityUser();
        Insolvency_Account__c inAcc = new Insolvency_Account__c(Name='werty');
        insert inAcc;
        
        //Delete Attachment
        Attachment attchDelete = new Attachment();
        attchDelete.body = Blob.valueof('Test Body Delete');
        attchDelete.name = 'AttchDelete.pdf';
        attchDelete.parentId = inAcc.Id;
        insert attchDelete;
        List<Attachment> deleteList = new List<Attachment>();
        deleteList.add(attchDelete);
        System.runAs(commUser) {
            AttachmentTriggerHandler.handleBeforeDelete(deleteList);
        }
  //After Attachment is Deleted 

List<Attachment> attachm = new list<Attachment>();
List<Task> activities = new List<Task>();
for(Attachment attach : attachm){
Task activity = new Task();
activity.Subject = 'Deleted-'+attach.Name;
activity.WhatId = attach.ParentId;
activity.Status = 'Completed';
activities.add(activity);
}
if(activities.size() > 0){
            insert activities;
        }
System.runAs(commUser) {
AttachmentTriggerHandler.handleAfterDelete(attachm);
} 
System.Test.stopTest();        
}
}