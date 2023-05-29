/**************************************************************************************************
*
*  Class:   TestEmailTrusteeController
*
*  @description : This class contains unit tests for send email trustee regarding insolvancy account and attachments
*  @author : A5E Consulting
*  @date : 10/08/2017
* 
*************************************************************************************************/

@isTest(seeAllData = false)
public class TestEmailTrusteeController{    
    @testSetup 
    static void testData() {
        User u = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(u){  
            EmailTemplate defaultTemplate = new EmailTemplate(Name = 'Creditor Package Request',TemplateType  = 'custom', DeveloperName='Insolvency_Template2', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = '{!Insolvency_Account__c.Secured_Name__c}', FolderId = UserInfo.getUserId());
            insert defaultTemplate;
            
            PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', CFG_Trustee_Email_Default_content__c = 'test', 
                                                                      CFG_Trustee_Email_Default_Subject__c ='test',
                                                                      Insolvency_Template_Header__c = defaultTemplate.id,
                                                                      Insolvency_Template_WoHeader__c = defaultTemplate.id,
                                                                      Attachment_Required_Email_Templates__c = defaultTemplate.id,
                                                                      Account_Statement_Not_Allowed__c  = defaultTemplate.id,
                                                                      Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                                                                      Insolvency_Template_Header_French__c = defaultTemplate.id,
                                                                      Insolvency_Template_WoHeader_French__c =defaultTemplate.id,
                                                                      CFG_Office_Address_1__c = 'PO Box 758 STN B',
                                                                      CFG_Office_Fax_Number__c = '844-827-9220',
                                                                      CFG_Office_Phone_Number__c = '844-827-9222',
                                                                      CFG_Office_City__c= 'London',
                                                                      CFG_Office_Province_Short_Code__c = 'ON',
                                                                      CFG_Office_Postal_Code__c = 'N6A 4Y8',
                                                                      CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                                                                      CFG_Office_Email_Address__c = 'test@canaccede.com'
                                                                     );
            insert poc;
            PoC_Package_Settings__c poc1 = new PoC_Package_Settings__c(Name = 'Canaccede', CFG_Trustee_Email_Default_content__c = 'test', 
                                                                       CFG_Trustee_Email_Default_Subject__c ='test',
                                                                       Insolvency_Template_Header__c = defaultTemplate.id,
                                                                       Insolvency_Template_WoHeader_French__c =defaultTemplate.id,
                                                                       Insolvency_Template_WoHeader__c = defaultTemplate.id,
                                                                       Attachment_Required_Email_Templates__c = defaultTemplate.id,
                                                                       CFG_Office_Address_1__c = 'PO Box 758 STN B',
                                                                       CFG_Office_City__c= 'London',
                                                                       CFG_Office_Province_Short_Code__c = 'ON',
                                                                       CFG_Office_Postal_Code__c = 'N6A 4Y8',
                                                                       CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                                                                       CFG_Office_Fax_Number__c = '844-827-9220',
                                                                       CFG_Office_Phone_Number__c = '844-827-9222',
                                                                       Account_Statement_Not_Allowed__c  = defaultTemplate.id,
                                                                       Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                                                                       Insolvency_Template_Header_French__c = defaultTemplate.id,
                                                                       CFG_Office_Email_Address__c = 'test@canaccede.com'
                                                                      );
            insert poc1;
        }
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = True,
                                                                                      Maximum_Email_Attachments_Size__c = 18874368,
                                                                                      Maximum_Email_Attachments_Size_Text__c = 'You can send attachments only upto 18 MB',
                                                                                      Run_Insolvency_Account_Trigger__c = true,
                                                                                      Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
                                                                                      Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
                                                                                      Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
                                                                                      Bank_Eligible_for_Duplicate_Check__c = 'SPL',
                                                                                      Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
                                                                                      Run_Insolvency_Trigger__c = false,
                                                                                      Run_Insolvency_Account_Duplicate_Check__c = True,
                                                                                      Eligible_for_Voting_Decision__c = 'Scotia Bank,SDA,SPL,Canaccede,Fidem,Fairstone'                                      );
        insert appConfig;
    }
    
    // Testing send email with attachments
    static testMethod void sendEmailTest(){
        //Account Record Insertion
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Communication_Preference__c = 'Fax';
        acct.fax= '651426256';
        insert acct;
        
        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010';
        inslv.Debtor_1_First_Name__c  = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;
        
        //Insolvency Account Record Insertion   
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = inslv.Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c= 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Insolvency__c = inslv.Id;
        acc.Account_Number_Without_Space__c='Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        insert acc;
        
        //Attachment Insertion to related Insolvency Account
        Attachment att = new Attachment(Name = 'testAtt', Description = 'PoC Document', Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'), parentId = acc.Id);
        insert att; 
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        set<Id> attIdSet = new set<Id>();
        
        if(obj.toEmail == Null){
            Insolvency_Error__c inslErr= new Insolvency_Error__c();
            inslErr.Action__c = 'Email Trustee';
            inslErr.Insolvency_Account__c = acc.Id;
            insert inslErr;
        }
        
        for(EmailTrusteeController.InsolvAttachments  attch : obj.insolvAttachList){
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();         
        }
        
        EmailTemplate  emailTempl = new EmailTemplate(Name = 'Notice Received to Prove Claim',TemplateType  = 'custom', DeveloperName='Insolvency_Template2', HtmlValue = '{!TODAY()}', body = 'testbody',Subject = '{!Insolvency_Account__c.Secured_Name__c}', FolderId = UserInfo.getUserId());
        EmailTemplate defaultTemplate1 = new EmailTemplate(Name = 'Insolvency Default - Template',TemplateType  = 'custom', DeveloperName='Insolvency_Template', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = '{!Insolvency_Account__c.Name}', FolderId = UserInfo.getUserId());
        
        set<Id> templateSet = new set<Id>();
        templateSet.add(emailTempl.Id);
        templateSet.add(defaultTemplate1.Id);
        obj.attachmentSelected = att.Id;
        attIdSet.add(att.Id);
        obj.selectedTemplate = emailTempl.Id;
        obj.mySelectedAtt = attIdSet;
        obj.emailTemplatechanged();
        
        obj.attachmentRemoved();
        obj.emailBody = emailTempl.Body;
        obj.sendEmail();
        obj.checkAttachment();
        obj.checkEligibleTrustee();
        obj.checkAttachmentForAccState();
        obj.isAnyException = false;
    }
    
    static testMethod void sendEmailTestCheck(){
        Set<id> mySelectedAtt = new Set<id>();
        //Account Record Insertion
        Account acct = new Account();
        acct.Name = 'Tests Account';
        acct.Communication_Preference__c = 'Fax';
        acct.fax= '651426256';
        insert acct;
        
        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email001';
        inslv.Debtor_1_First_Name__c  = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;
        
        //Insolvency Account Record Insertion  
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = inslv.Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c= 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Insolvency__c = inslv.Id;
        acc.Account_Number_Without_Space__c='Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        insert acc;
        
        //Attachment creation to related Insolvency Account
        Attachment att = new Attachment(Name = 'testAtt', Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),Description = 'Account Statement', parentId = acc.Id);
        insert att; 
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        obj.toEmail = 'test@test.com';
        set<Id> attIdSet = new set<Id>();
        
        for(EmailTrusteeController.InsolvAttachments  attch : obj.insolvAttachList){
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();         
        }
        
        EmailTemplate  emailTempl = new EmailTemplate(Name = 'Notice Received to Prove Claim',Subject = '{!Insolvency_Account__c.Borrower_Primary__c}');
        attIdSet.add(att.Id);
        obj.isSelectedAtt = true;
        obj.emailTemplatechanged();
        obj.attachmentRemoved();
        obj.loadEmailTemplates();
        obj.sendEmail();
        obj.checkAttachment();
        obj.checkEligibleTrustee();
        obj.getBankName();
    }
    
    static testMethod void sendEmailTestCheck1(){
        Set<id> mySelectedAtt = new Set<id>();
        //Account Record Insertion
        Account acct = new Account();
        acct.Name = 'Tests Account';
        acct.Communication_Preference__c = 'Email';
        acct.fax= '651426256';
        acct.Preferred_Language__c = 'English';
        insert acct;
        
        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email001';
        inslv.Debtor_1_First_Name__c  = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;
        
        //Insolvency Account Record Insertion  
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = inslv.Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Canaccede';
        acc.Balance_Owed__c= 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Insolvency__c = inslv.Id;
        acc.Account_Number_Without_Space__c='Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        insert acc;
        
        //Attachment creation to related Insolvency Account
        Attachment att = new Attachment(Name = 'testAtt', Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),Description = 'Account Statement', parentId = acc.Id);
        insert att; 
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        obj.toEmail = 'test@test.com';
        set<Id> attIdSet = new set<Id>();
        
        for(EmailTrusteeController.InsolvAttachments  attch : obj.insolvAttachList){
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();         
        }
        
        EmailTemplate  emailTempl = new EmailTemplate(Name = 'Notice Received to Prove Claim',Subject = '{!Insolvency_Account__c.Borrower_Primary__c}');
        attIdSet.add(att.Id);
        obj.isSelectedAtt = true;
        obj.emailTemplatechanged();
        obj.attachmentRemoved();
        obj.loadEmailTemplates();
        obj.sendEmail();
        obj.checkAttachment();
        obj.checkEligibleTrustee();
        obj.getBankName();
    }
}