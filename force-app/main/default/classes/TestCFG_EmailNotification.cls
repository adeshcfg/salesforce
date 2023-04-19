@isTest
public class TestCFG_EmailNotification {
    static testMethod void emailNotify(){
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        workAssignment.Title__c = 'Allocation file';
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
        Work_assignment__c workAssign = [select id,name,title__c from work_assignment__c where id =: workAssignment.id];
        
        CFG_EmailNotification.sendEmailNotification('xyz@gmail.com','https://cfgroup--psb.sandbox.my.salesforce.com/apex/DisplayProductAllocateStaging?id='+docStorage.id,
                                                    workAssignment.Name,workAssignment.Title__c,'Account Status Update File');
        
        CFG_EmailNotification.sendEmailNotificationOnErrorFile('xyz@gmail.com', 'Success records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Account Status Update File');
        CFG_EmailNotification.sendEmailNotificationOnProcessLinkFail('xyz@gmail.com', 'fail records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Account Status Update File');
        
        CFG_EmailNotification.sendEmailNotification('xyz@gmail.com','https://cfgroup--psb.sandbox.my.salesforce.com/apex/DisplayProductAllocateStaging?id='+docStorage.id,
                                                    workAssignment.Name,workAssignment.Title__c,'Product Allocation File');
        
        CFG_EmailNotification.sendEmailNotificationOnErrorFile('xyz@gmail.com', 'Success records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Product Allocation File');
        CFG_EmailNotification.sendEmailNotificationOnProcessLinkFail('xyz@gmail.com', 'fail records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Product Allocation File');
        CFG_EmailNotification.snapshotFailedEmailNotification('xyz@gmail.com', 'fail records', docStorage.id);

    }
}