/**************************************************************************************************
*
*  Class:   TestEmailTrusteeController
*
*  @description : This class contains unit tests for send email trustee regarding insolvancy account and attachments
*  @author : A5E Consulting
*  @date : 10/08/2017
*
*************************************************************************************************/

@isTest(seeAllData=false)
public class TestEmailTrusteeController {
    @testSetup
    static void testData() {
        User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];
        System.runAs(u) {
            EmailTemplate defaultTemplate = new EmailTemplate(
                Name = 'Creditor Package Request',
                TemplateType = 'custom',
                DeveloperName = 'Insolvency_Template2',
                HtmlValue = '{!TODAY()}',
                Body = '{!TODAY()}',
                Subject = '{!Insolvency_Account__c.Secured_Name__c}',
                FolderId = UserInfo.getUserId()
            );
            insert defaultTemplate;
            
            PoC_Package_Settings__c poc = new PoC_Package_Settings__c(
                Name = 'Scotia Bank',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert poc;
            PoC_Package_Settings__c poc1 = new PoC_Package_Settings__c(
                Name = 'Canaccede',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert poc1;
            PoC_Package_Settings__c ctb = new PoC_Package_Settings__c(
                Name = 'Canadian Tire',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert ctb;
        }
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(
            Run_Insolvency_Status_Validations__c = true,
            Maximum_Email_Attachments_Size__c = 18874368,
            Maximum_Email_Attachments_Size_Text__c = 'You can send attachments only upto 18 MB',
            Run_Insolvency_Account_Trigger__c = true,
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
            Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Eligible_for_Voting_Decision__c = 'Scotia Bank,SDA,SPL,Canaccede,Fidem,Fairstone'
        );
        insert appConfig;
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Communication_Preference__c = 'Fax';
        acct.fax = '651426256';
        insert acct;
        
        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;
        
        String csvString = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001"\n"D","2","999","9/19/2023","41414","Consumer Proposal","Canadian Tire Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","0000000008PCOM","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123"\n"T","2","999","3","1","08/15/2008","12:32:06"';
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf(csvString);
        documentObj.ContentType = 'text/csv';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;
        insert documentObj;
        
        TestDocumentAPIClient.testDocumentAPI();
    }
    
    public static User prepareUser( String profId, String firstName, String lastName, String contactId) {
        String orgId = UserInfo.getOrganizationId();
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalRole = 'PersonAccount' Limit 1];
        String dateString =
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tempUser = new User(
            FirstName = firstName,
            LastName = lastName,
            UserRoleId = contactId != null ? userrole.Id : null,
            email = uniqueName + '@sfdc' + orgId + '.org',
            Username = uniqueName + '@sfdc' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profId,
            ContactId = contactId 
        );
        return tempUser;
    } 
    static testMethod void getInsAccntRecorTypeIdNameMapTest(){
        InsolvencyUtil.getInsAccntRecorTypeIdNameMap();
    }
    
    static testMethod void getInsAccntRecorTypeNameIdMapTest(){
        InsolvencyUtil.getInsAccntRecorTypeNameIdMap();
    } 
    
    static testMethod void updateInsolvencyAccountOwnerIdsTest(){
        List<Insolvency_Account__c> insolvansyList = new List<Insolvency_Account__c>();
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Canadian Tire';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insolvansyList.add(acc);
        insert insolvansyList;
        InsolvencyUtil.updateInsolvencyAccountOwnerIds(insolvansyList);
        InsolvencyUtil.saveAttachment(insolvansyList[0].Id, 'Test','Start','pdf');
        InsolvencyUtil.saveAttachment(insolvansyList[0].Id, Blob.valueof('myString'),'Start1','pdf');
        InsolvencyUtil.saveContentDocument(insolvansyList[0].Id, Blob.valueof('myString'),'BlobTest','pdf');
        InsolvencyUtil.formatFaxAsEmail('120(23) 908 - 876');
        InsolvencyUtil.calculateNextBusinesDate(System.Today());
        InsolvencyUtil.getRecordTypeToWorkOn();
        InsolvencyUtil.createFullName('Test', 'User');
    }
    
    static testMethod void fileSizeToStringTest(){
        InsolvencyUtil.fileSizeToString(1000);
        InsolvencyUtil.fileSizeToString(1024);
        InsolvencyUtil.fileSizeToString(1000*1000*1000);
        InsolvencyUtil.fileSizeToString(1024*1024*1024);
    }
    
    static testMethod void updateOwnerShipTest(){
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010000';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        insert inslv;
        InsolvencyUtil.updateOwnerShip(inslv);
    }
    
    static testMethod void isCommunityUserTest(){  
        Profile userProfile = [Select Id,Name from Profile where name Like '%Community User%' LIMIT 1];
        InsolvencyUtil.isCommunityUser();
        InsolvencyUtil.isCommunityReadOnlyUser();
    }
    
    static testMethod void isCommunityReadOnlyUserTest(){
        Profile userProfile = [Select Id,Name from Profile where name Like '%Community User Readonly%' LIMIT 1];
        InsolvencyUtil.isCommunityReadOnlyUser();
        InsolvencyUtil.isCommunityUser();
    }
    
    static testMethod void isScotiaBankCommunityUserTest(){
        Profile userProfile = [Select Id,Name from Profile where name Like '%Scotia Bank%' LIMIT 1];
        InsolvencyUtil.isScotiaBankCommunityUser(userProfile.Id);
        InsolvencyUtil.isChaseBankCommunityUser(userProfile.Id);
    }
    
    static testMethod void isChaseBankCommunityUserTest(){ 
        Profile userProfile = [Select Id,Name from Profile where name Like '%SPL%' LIMIT 1];
        InsolvencyUtil.isChaseBankCommunityUser(userProfile.Id);
        InsolvencyUtil.isScotiaBankCommunityUser(userProfile.Id);
    }
    
    static testMethod void isSDABankCommunityUserTest(){ 
        Profile userProfile = [Select Id,Name from Profile where name Like '%SDA%' LIMIT 1];
        InsolvencyUtil.isSDABankCommunityUser(userProfile.Id);
        InsolvencyUtil.isFairstoneBankCommunityUser(userProfile.Id);
    }
    
    static testMethod void isFairstoneBankCommunityUserTest(){
        Profile userProfile = [Select Id,Name from Profile where name Like '%Fairstone%' LIMIT 1];
        InsolvencyUtil.isSDABankCommunityUser(userProfile.Id);
        InsolvencyUtil.isFairstoneBankCommunityUser(userProfile.Id);
    }
    
    static testMethod void isGoeasyBankCommunityUserTest(){
        Profile userProfile = [Select Id,Name from Profile where name Like '%Goeasy%' LIMIT 1];
        InsolvencyUtil.isGoeasyBankCommunityUser(userProfile.Id);
        InsolvencyUtil.isCanadianTireCommunityUser(userProfile.Id);
    }
    
    static testMethod void isCanadianTireCommunityUserTest(){
        Profile userProfile = [Select Id,Name from Profile where name Like '%Canadian Tire%' LIMIT 1];
        InsolvencyUtil.isGoeasyBankCommunityUser(userProfile.Id);
        InsolvencyUtil.isCanadianTireCommunityUser(userProfile.Id);
    }
    
    static testMethod void isMoneyMartCommunityUserTest(){  
        Profile userProfile = [Select Id,Name from Profile where name Like '%Money Mart%' LIMIT 1];
        InsolvencyUtil.isMoneyMartCommunityUser(userProfile.Id);
        InsolvencyUtil.isFlexitiCommunityUser(userProfile.Id);
    }
    
    static testMethod void isFlexitiCommunityUserTest(){  
        Profile userProfile = [Select Id,Name from Profile where name Like '%Flexiti%' LIMIT 1];
        InsolvencyUtil.isMoneyMartCommunityUser(userProfile.Id);
        InsolvencyUtil.isFlexitiCommunityUser(userProfile.Id);
    }
    
    
    
    // Testing send email with attachments
    static testMethod void sendEmailTest1() {
        
        Account acct = [Select Name, Communication_Preference__c,fax, Business_Email__c,  Is_Active__c From Account Where Communication_Preference__c = 'Fax' and fax = '651426256'];
        acct.Is_Active__c = false;
        acct.Business_Email__c = 'abc@gmail.com';
        acct.Communication_Preference__c = 'Email';
        
        update acct;
        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email00100';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;
        
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Canadian Tire';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;
        
        //Attachment Insertion to related Insolvency Account
        Attachment att = new Attachment(
            Name = 'testAtt',
            Description = 'PoC Document',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            parentId = acc.Id
        );
        insert att;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.PathOnClient = 'test.txt';
        contentVersion.Title = 'Test file';
        contentVersion.Description = 'Account Statement';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        
        insert contentVersion;
        ContentVersion conVer = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conVer.ContentDocumentId; // ID of the uploaded ContentDocument
        contentDocumentLink.LinkedEntityId = acc.id; // ID of the EmailMessage record
        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
        
        insert contentDocumentLink;
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        set<String> attIdSet = new Set<String>();
        
        if (obj.toEmail == null) {
            Insolvency_Error__c inslErr = new Insolvency_Error__c();
            inslErr.Action__c = 'Email Trustee';
            inslErr.Insolvency_Account__c = acc.Id;
            insert inslErr;
        }
        
        for (EmailTrusteeController.InsolvAttachments attch : obj.insolvAttachList) {
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();
        }
        
        EmailTemplate emailTempl = new EmailTemplate(
            Name = 'Notice Received to Prove Claim',
            TemplateType = 'custom',
            DeveloperName = 'Insolvency_Template2',
            HtmlValue = '{!TODAY()}',
            body = 'testbody',
            Subject = '{!Insolvency_Account__c.Secured_Name__c}',
            FolderId = UserInfo.getUserId()
        );
        EmailTemplate defaultTemplate1 = new EmailTemplate(
            Name = 'Insolvency Default - Template',
            TemplateType = 'custom',
            DeveloperName = 'Insolvency_Template',
            HtmlValue = '{!TODAY()}',
            Body = '{!TODAY()}',
            Subject = '{!Insolvency_Account__c.Name}',
            FolderId = UserInfo.getUserId()
        );
        
        set<Id> templateSet = new Set<Id>();
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
        attIdSet.add(conVer.ContentDocumentId);
        obj.sendEmail();
        obj.checkAttachment();
        obj.checkEligibleTrustee();
        obj.checkAttachmentForAccState();
        obj.isAnyException = false;
    }
    
    
    // Testing send email with attachments
    static testMethod void sendEmailTest() {
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;
        
        //Attachment Insertion to related Insolvency Account
        Attachment att = new Attachment(
            Name = 'testAtt',
            Description = 'PoC Document',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            parentId = acc.Id
        );
        insert att;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.PathOnClient = 'test.txt';
        contentVersion.Title = 'Test file';
        contentVersion.Description = 'Account Statement';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        
        insert contentVersion;
        ContentVersion conVer = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conVer.ContentDocumentId; // ID of the uploaded ContentDocument
        contentDocumentLink.LinkedEntityId = acc.id; // ID of the EmailMessage record
        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
        
        insert contentDocumentLink;
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        set<String> attIdSet = new Set<String>();
        
        if (obj.toEmail == null) {
            Insolvency_Error__c inslErr = new Insolvency_Error__c();
            inslErr.Action__c = 'Email Trustee';
            inslErr.Insolvency_Account__c = acc.Id;
            insert inslErr;
        }
        
        for (EmailTrusteeController.InsolvAttachments attch : obj.insolvAttachList) {
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();
        }
        
        EmailTemplate emailTempl = new EmailTemplate(
            Name = 'Notice Received to Prove Claim',
            TemplateType = 'custom',
            DeveloperName = 'Insolvency_Template2',
            HtmlValue = '{!TODAY()}',
            body = 'testbody',
            Subject = '{!Insolvency_Account__c.Secured_Name__c}',
            FolderId = UserInfo.getUserId()
        );
        EmailTemplate defaultTemplate1 = new EmailTemplate(
            Name = 'Insolvency Default - Template',
            TemplateType = 'custom',
            DeveloperName = 'Insolvency_Template',
            HtmlValue = '{!TODAY()}',
            Body = '{!TODAY()}',
            Subject = '{!Insolvency_Account__c.Name}',
            FolderId = UserInfo.getUserId()
        );
        
        set<Id> templateSet = new Set<Id>();
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
        attIdSet.add(conVer.ContentDocumentId);
        obj.sendEmail();
        obj.checkAttachment();
        obj.checkEligibleTrustee();
        obj.checkAttachmentForAccState();
        obj.isAnyException = false;
    }
    static testMethod void sendEmailTestCheck() {
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;
        
        //Attachment creation to related Insolvency Account
        Attachment att = new Attachment(
            Name = 'testAtt',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            Description = 'Account Statement',
            parentId = acc.Id
        );
        insert att;
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        obj.toEmail = 'test@test.com';
        set<String> attIdSet = new Set<String>();
        
        for (EmailTrusteeController.InsolvAttachments attch : obj.insolvAttachList) {
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();
        }
        
        EmailTemplate emailTempl = new EmailTemplate(Name = 'Notice Received to Prove Claim', Subject = '{!Insolvency_Account__c.Borrower_Primary__c}');
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
    
    static testMethod void sendEmailTestCheck1() {
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Canaccede';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;
        
        //Attachment creation to related Insolvency Account
        Attachment att = new Attachment(
            Name = 'testAtt',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            Description = 'Account Statement',
            parentId = acc.Id
        );
        insert att;
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        obj.toEmail = 'test@test.com';
        set<String> attIdSet = new Set<String>();
        
        for (EmailTrusteeController.InsolvAttachments attch : obj.insolvAttachList) {
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();
        }
        
        EmailTemplate emailTempl = new EmailTemplate(Name = 'Notice Received to Prove Claim', Subject = '{!Insolvency_Account__c.Borrower_Primary__c}');
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
    
    @isTest
    static void sendEmailTestCTB() {
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = '123456789';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        acc.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Canadian_Tire_Insolvency_Account')
            .getRecordTypeId();
        insert acc;
        
        //Attachment creation to related Insolvency Account
        Attachment att = new Attachment(
            Name = 'testAtt',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            Description = 'PoC Document',
            parentId = acc.Id
        );
        insert att;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.PathOnClient = 'test.txt';
        contentVersion.Title = 'Test file';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        
        insert contentVersion;
        ContentVersion conVer = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conVer.ContentDocumentId; // ID of the uploaded ContentDocument
        contentDocumentLink.LinkedEntityId = acc.id; // ID of the EmailMessage record
        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
        
        insert contentDocumentLink;
        
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Test_Document.pdf';
        docInfo.Document_URL__c = 'statement/Test_Document.pdf';
        docInfo.Document_Type__c = 'ctb_statement_output';
        docInfo.Document_Extension__c = 'pdf';
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.Insolvency_Account__c = acc.Id;
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        insert docInfo;
        
        ApexPages.currentPage().getParameters().put('Id', acc.Id);
        
        EmailTrusteeController obj = new EmailTrusteeController();
        obj.toEmail = 'test@test.com';
        set<String> attIdSet = new Set<String>{ att.Id, docInfo.Document_URL__c};
            for (EmailTrusteeController.InsolvAttachments attch : obj.insolvAttachList) {
                attch.selected = true;
                obj.attachmentSelected = attch.attId;
                obj.attachmentSelected();
            }
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        EmailTemplate emailTempl = new EmailTemplate(Name = 'Creditor Package Request', Subject = '{!Insolvency_Account__c.Borrower_Primary__c}');
        obj.isSelectedAtt = true;
        obj.mySelectedAtt = attIdSet;
        Test.startTest();
        obj.emailTemplatechanged();
        obj.attachmentRemoved();
        obj.loadEmailTemplates();
        obj.checkEligibleTrustee();
        obj.getBankName();
        attIdSet = new Set<String>{conVer.ContentDocumentId };
            obj.mySelectedAtt = attIdSet;
        obj.sendEmail();
        obj.checkAttachment();
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateInsolvencyAccount() {
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = '123456789';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Package Generated';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        acc.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Canadian_Tire_Insolvency_Account')
            .getRecordTypeId();
        insert acc;
        
        Test.startTest();
        EmailTrusteeController.updateInsolvencyAccount(acc.Id, new Set<String>());
        Test.stopTest();
    }
    
    private void changeLanguageFrenchTest(){
        EmailTrusteeController etc = new EmailTrusteeController();
        etc.language = 'fr';
        etc.changeLanguage();
    }
    
    private void changeLanguageEnTest(){
        EmailTrusteeController etc = new EmailTrusteeController();
        etc.language = 'en_US';
        etc.changeLanguage();
    }
}