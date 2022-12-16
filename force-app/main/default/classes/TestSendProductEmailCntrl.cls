/***************************************************
* Author         : A5E Consultancy
* Last Modified  : 28 Apr 2017
* Description    : Test class for SendProductEmailCntrl
* Methods        :
                   loadData() - Used to create necessary Object records in this test class
                   previewEmailtest() - Used to test preview Email template to Customer
***************************************************/

@isTest (seeAllData = false)
public class TestSendProductEmailCntrl{

    // Setup Test Data for all test methods inside this class   
    @testsetup
    public static void loadData(){
        
        Collection_Custom_Setting__c collCustSett = new Collection_Custom_Setting__c(
            Credit_Card_Email_Templates__c = 'D1 Payment Reminder,D10 Let Us Help,D36 Let Us Help,D55 Potential Legal',
            Term_Loan_Email_Templates__c = 'D1 Term Loan Payment Reminder,D10 Term Loan Let Us Help,D36 Term Loan Let Us Help,D55 Potential Legal Term Loan,Day 75 Demand - Notice Before Suit (Non confirm Employment)',
            Auto_Print_Email_Template__c = 'D1 Term Loan Payment Reminder,D10 Term Loan Let Us Help,D36 Term Loan Let Us Help,D55 Potential Legal Term Loan,Day 75 Demand - Notice Before Suit (Non confirm Employment)',
            Resticted_Credit_Card_Email_Templates__c = 'D1 Term Loan Payment Reminder,D10 Term Loan Let Us Help,D36 Term Loan Let Us Help,D55 Potential Legal Term Loan,Day 75 Demand - Notice Before Suit (Non confirm Employment)',
            Resticted_Term_Loan_Email_Templates__c = 'D1 Term Loan Payment Reminder,D10 Term Loan Let Us Help,D36 Term Loan Let Us Help,D55 Potential Legal Term Loan,Day 75 Demand - Notice Before Suit (Non confirm Employment)'
        );
        insert collCustSett;   
        
        // Get Person Account Record Type Id
        String RecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId();
        
        // Create Person Account
        Account personAcc = new Account(
            RecordTypeID=RecTypeId,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678' 
        );
        insert personAcc;
        
         // Create Person Account
        Account personAcc2 = new Account(
            RecordTypeID=RecTypeId,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678' 
        );
        insert personAcc2;
        
        // Create test user to avoid DML on setup, non-setup objects
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        // Create test user to avoid DML on setup, non-setup objects
        User u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'user2',
            Email = 'puser000@amamama.com',
            Username = 'puser0001@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u2;

        // Create sample test email template
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Bill Plan Email Template';
        validEmailTemplate.DeveloperName = 'Bill_Plan_Email_Template';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.Body = '[$0.00]';
        validEmailTemplate.subject = 'test email';
        validEmailTemplate.HtmlValue = '[$0.00]';
        validEmailTemplate.FolderId = UserInfo.getUserId();

        // Run as other user context
        system.runAs(u){
            insert validEmailTemplate;
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Restricted_User_Permissions' LIMIT 1];
            //insert new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = ps.Id );
        }
        
        // Create Product record
        Product__c prod = new Product__c(Name = '12345', Customer__c = personAcc.Id, Payment_Amount__c = 10.00);
        insert prod;
     }
    
    // Method used to test preview email functionality
    public static testmethod void previewEmailtest(){
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('Id', prod.Id);
        
        // Create instance for Send Product Plan Bill class
        SendProductEmailCntrl obj = new SendProductEmailCntrl();
        obj.selectedTemplate = 'Bill Plan Email Template';    // Email template to preview
        obj.getEmailTemplates();
        obj.send();
        obj.previewEmail();
        obj.selectedTemplate ='D1 Term Loan Payment Reminder';
        obj.previewEmail();
        Account personAcc2 = [SELECT Id FROM Account WHERE PersonEmail = null];
        prod.Customer__c = personAcc2.Id;
        update prod;
        try{
            obj = new SendProductEmailCntrl();
            obj.selectedTemplate = null;        // Making email template as null
            obj.previewEmail();
            obj.send();
        }catch(exception ex){
            // Validation if user dont select any template
            System.AssertEquals(ex.getMessage(), 'Email address is missing on Customer record');
        }
        prod.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Product__c' AND Name ='Credit Card Account'].Id;
        update prod;
        
        obj = new SendProductEmailCntrl();
        obj.getEmailTemplates();
    }
    
    // Method used to test preview email functionality
    public static testmethod void restrictedUser(){
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('Id', prod.Id);
        User u = [SELECT Id FROM User WHERE LAstName ='user2' LIMIT 1];
        
        // Run as other user context
        system.runAs(u){
            // Create instance for Send Product Plan Bill class
            SendProductEmailCntrl obj = new SendProductEmailCntrl();
            obj.selectedTemplate = 'Bill Plan Email Template';    // Email template to preview
            obj.getEmailTemplates();
            obj.send();
            obj.previewEmail();
            obj.selectedTemplate ='D1 Term Loan Payment Reminder';
            obj.previewEmail();
            Account personAcc2 = [SELECT Id FROM Account WHERE PersonEmail = null];
            prod.Customer__c = personAcc2.Id;
            update prod;
            try{
                obj = new SendProductEmailCntrl();
                obj.selectedTemplate = null;        // Making email template as null
                obj.previewEmail();
                obj.send();
            }catch(exception ex){
                // Validation if user dont select any template
                System.AssertEquals(ex.getMessage(), 'Email address is missing on Customer record');
            }
            prod.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Product__c' AND Name ='Credit Card Account'].Id;
            update prod;

            obj = new SendProductEmailCntrl();
            obj.getEmailTemplates();
         }
    }
}