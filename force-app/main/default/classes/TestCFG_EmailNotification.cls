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
        
        User userData = new User();
        userData.Email = 'test@gmail.com';
        userData.FirstName = 'Janet';
        userData.LastName = 'Vidhate';
        userData.Username = 'xyzi@gmail.com';
        userData.Alias = 'testals';
        userData.TimeZoneSidKey = 'America/Los_Angeles';
        userData.LocaleSidKey = 'en_US';
        userData.EmailEncodingKey = 'UTF-8';
        userData.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CFG - Insolvency User'].Id;
        userData.LanguageLocaleKey = 'en_US';
        insert userData;
        
        User userData1 = new User();
        userData1.Email = 'test@gmail.com';
        userData1.FirstName = 'Janet';
        userData1.LastName = 'Vidhate1';
        userData1.Username = 'xyzu@gmail.com';
        userData1.Alias = 'testals';
        userData1.TimeZoneSidKey = 'America/Los_Angeles';
        userData1.LocaleSidKey = 'en_US';
        userData1.EmailEncodingKey = 'UTF-8';
        userData1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CFG - Insolvency User'].Id;
        userData1.LanguageLocaleKey = 'en_US';
        insert userData1;
        
        Work_assignment__c workAssign = [select id,name,title__c from work_assignment__c where id =: workAssignment.id];
        
        CFG_EmailNotification.sendEmailNotification('xyz@gmail.com','https://cfgroup--psb.sandbox.my.salesforce.com/apex/DisplayProductAllocateStaging?id='+docStorage.id,
                                                    workAssignment.Name,workAssignment.Title__c,'Account Status Update File');
        
        CFG_EmailNotification.sendEmailNotificationOnErrorFile('Janet Vidhate', 'Success records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Account Status Update File');
        CFG_EmailNotification.sendEmailNotificationOnProcessLinkFail('xyz@gmail.com', 'fail records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Account Status Update File');
        
        CFG_EmailNotification.sendEmailNotification('xyz@gmail.com','https://cfgroup--psb.sandbox.my.salesforce.com/apex/DisplayProductAllocateStaging?id='+docStorage.id,
                                                    workAssignment.Name,workAssignment.Title__c,'Product Allocation File');
        
        CFG_EmailNotification.sendEmailNotificationOnErrorFile('Janet Vidhate', 'Success records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Product Allocation File');
        CFG_EmailNotification.sendEmailNotificationOnProcessLinkFail('xyz@gmail.com', 'fail records', workAssignment.Name, workAssignment.Title__c, workAssignment.id,'Product Allocation File');
        CFG_EmailNotification.snapshotFailedEmailNotification('xyz@gmail.com', 'fail records', docStorage.id);
        CFG_EmailNotification.snapshotFailedEmailNotifyTOCFGSupport('Tejal Vidhate1','success record','Access token');
        CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport('Tejal Vidhate1','success record','Access token');
    }
}