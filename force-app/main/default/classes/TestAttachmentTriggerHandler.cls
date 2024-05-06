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
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Run_Attachment_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;  
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
        AttachmentTriggerHandler.handleBeforeDelete(deleteList);
        
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
        AttachmentTriggerHandler.handleAfterDelete(deleteList);
        System.Test.stopTest();        
    }
}