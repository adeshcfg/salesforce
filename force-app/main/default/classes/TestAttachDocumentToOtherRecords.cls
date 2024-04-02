/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of AttachDocumentToOtherRecords
 *  @author : A5E Consulting
 *  @date : 07/23/2018
 * 
 *************************************************************************************************/
@IsTest
public class TestAttachDocumentToOtherRecords {
        
    @IsTest
    static void testMethodNewCase() {

        System.Test.startTest();

        //Application config creation
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
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
        
        /*Group pGrp = new Group();
        pGrp.Name = 'Insolvency CFG Users';
        pGrp.DeveloperName = 'Insolvency_CFG_Users';
        //pGrp.Type = 'Regular';
        insert pGrp;*/
        
        //English domain name record creation
        Domain_Name_Parser__c domainNameParserObj = new Domain_Name_Parser__c();
        domainNameParserObj.Name = 'a5econsulting.net';
        domainNameParserObj.Domain_Name__c = 'a5econsulting.net'; 
        domainNameParserObj.Parser_Name__c = 'tkvojqfbfkrm'; 
        INSERT domainNameParserObj;

        //French domain name creation
        French_Domain_Name_Parser__c frenchDomainObj = new French_Domain_Name_Parser__c();
        frenchDomainObj.Name = 'a5econsulting.net';
        frenchDomainObj.Domain_Name__c = 'a5econsulting.net'; 
        frenchDomainObj.Parser_Name__c = 'cikdcfvgvhqa';
        INSERT frenchDomainObj;

        //Insolvency record creation
        Insolvency__c insolvencyRec = new Insolvency__c();
        insolvencyRec.Name = 'INSOL-90809';
        //insolvencyRec.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyRec.Insolvency_Status__c = 'For Owner Review';
        INSERT insolvencyRec;

        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@a5econsulting.net';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.Status = 'InProgress';
        caseObj.Insolvency__c = insolvencyRec.Id;
        INSERT caseObj;
        
        //EmailMessage record creation
        EmailMessage emailMsg =  new EmailMessage();
        emailMsg.relatedToid = caseObj.Id;
        emailMsg.TextBody = 'Test Email';
        emailMsg.FromAddress = 'abc@gmail.com';
        emailMsg.ToAddress = 'xyz@gmail.com';
        INSERT emailMsg;

        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = emailMsg.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        INSERT att;


        PageReference pageRef = Page.AttachDocumenttoOtherRecords;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecords attachRec = new AttachDocumenttoOtherRecords(sc);
        attachRec.listAttachWrap[0].check = true;
        //AttachDocumenttoOtherRecords.getAllDocumentOptions();
        attachRec.createNewAssignment();
        attachRec.attachDocument();

        //Insolvency Account record Creation
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.Account_Type__c = 'Mortgage';
        insolvencyAccount.Insolvency__c = insolvencyRec.Id;
        insolvencyAccount.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyAccount.Account_Number_Without_Space__c='123';
        INSERT insolvencyAccount;

        //Case record creation
        Case caseRec = new Case();
        caseRec.SuppliedEmail = 'abc@a5econsulting.net';
        caseRec.Assigned_To__c = UserInfo.getUserId();
        caseRec.Status = 'InProgress';
        caseRec.Insolvency_Account__c = insolvencyAccount.Id;
        INSERT caseRec;
        
        //EmailMessage record creation
        EmailMessage mailMsg =  new EmailMessage();
        mailMsg.relatedToid = caseRec.Id;
        mailMsg.TextBody = 'Test Email';
        mailMsg.FromAddress = 'abc@gmail.com';
        mailMsg.ToAddress = 'xyz@gmail.com';
        INSERT mailMsg;

        //Attachment record creation
        Attachment attRec = new Attachment();
        attRec.parentId = mailMsg.Id;
        attRec.Body = Blob.valueOf('Test Attach');
        attRec.Name= 'Test';
        INSERT attRec;

        Attachment attRecord = new Attachment();
        attRecord.parentId = mailMsg.Id;
        attRecord.Body = Blob.valueOf('Test Attach');
        attRecord.Name= 'Test';
        INSERT attRecord;
        
        PageReference pgRef = Page.AttachDocumenttoOtherRecords;
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('Id', String.valueOf(caseRec.Id));
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(caseRec);
        AttachDocumenttoOtherRecords attachDocRec = new AttachDocumenttoOtherRecords(standardCtrl);
        
        attachDocRec.listAttachWrap[0].check = true;
        attachDocRec.listAttachWrap[1].check = true;
        attachDocRec.attachDocument();
        attachDocRec.createNewAssignment();

        System.Test.stopTest();
    }
    
    @IsTest
    static void testMethodAttachDoc(){

        System.Test.startTest();

        //Application config creation
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c();
        appConfig.Doc_Parser_API_Key__c = '7146d1c4f964579e9faa36c112b2035e3d965a03';
        appConfig.Target_URL_for_Insolvency__c = 'https://api.docparser.com/v1/document/upload'; 
        appConfig.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        appConfig.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        appConfig.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        appConfig.Eligible_for_Claim_Type_Calculation__c='test';
        INSERT appConfig;
        
        /*Group pGrp = new Group();
        pGrp.Name = 'Insolvency CFG Users';
        pGrp.DeveloperName = 'Insolvency_CFG_Users';
        //pGrp.Type = 'Regular';
        insert pGrp;*/
        
        //English domain name record creation
        Domain_Name_Parser__c domainNameParserObj = new Domain_Name_Parser__c();
        domainNameParserObj.Name = 'a5econsulting.net';
        domainNameParserObj.Domain_Name__c = 'a5econsulting.net'; 
        domainNameParserObj.Parser_Name__c = 'tkvojqfbfkrm'; 
        INSERT domainNameParserObj;

        //French domain name creation
        French_Domain_Name_Parser__c frenchDomainObj = new French_Domain_Name_Parser__c();
        frenchDomainObj.Name = 'a5econsulting.net';
        frenchDomainObj.Domain_Name__c = 'a5econsulting.net'; 
        frenchDomainObj.Parser_Name__c = 'cikdcfvgvhqa';
        INSERT frenchDomainObj;

        //Insolvency record creation
        Insolvency__c insolvencyRec = new Insolvency__c();
        insolvencyRec.Name = 'INSOL-90809';
       // insolvencyRec.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyRec.Insolvency_Status__c = 'For Owner Review';
        INSERT insolvencyRec;

        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@a5econsulting.net';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.Status = 'InProgress';
        caseObj.Insolvency__c = insolvencyRec.Id;
        INSERT caseObj;
        
        //EmailMessage record creation
        EmailMessage emailMsg =  new EmailMessage();
        emailMsg.relatedToid = caseObj.Id;
        emailMsg.TextBody = 'Test Email';
        emailMsg.FromAddress = 'abc@gmail.com';
        emailMsg.ToAddress = 'xyz@gmail.com';
        INSERT emailMsg;

        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = emailMsg.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        INSERT att;


        PageReference pageRef = Page.AttachDocumenttoOtherRecords;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecords attachRec = new AttachDocumenttoOtherRecords(sc);
        attachRec.listAttachWrap[0].check = true;
        attachRec.listAttachWrap[0].attach.Description = 'Other';
        //AttachDocumenttoOtherRecords.getAllDocumentOptions();
        //attachRec.createNewAssignment();
        attachRec.attachDocument();

        //Insolvency Account record Creation
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.Account_Type__c = 'Mortgage';
        insolvencyAccount.Insolvency__c = insolvencyRec.Id;
        insolvencyAccount.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyAccount.Account_Number_Without_Space__c='123';
        INSERT insolvencyAccount;

        //Case record creation
        Case caseRec = new Case();
        caseRec.SuppliedEmail = 'abc@a5econsulting.net';
        caseRec.Assigned_To__c = UserInfo.getUserId();
        caseRec.Status = 'InProgress';
        caseRec.Insolvency_Account__c = insolvencyAccount.Id;
        INSERT caseRec;
        
        //EmailMessage record creation
        EmailMessage mailMsg =  new EmailMessage();
        mailMsg.relatedToid = caseRec.Id;
        mailMsg.TextBody = 'Test Email';
        mailMsg.FromAddress = 'abc@gmail.com';
        mailMsg.ToAddress = 'xyz@gmail.com';
        INSERT mailMsg;

        //Attachment record creation
        Attachment attRec = new Attachment();
        attRec.parentId = mailMsg.Id;
        attRec.Body = Blob.valueOf('Test Attach');
        attRec.Name= 'Test';
        INSERT attRec;

        Attachment attRecord = new Attachment();
        attRecord.parentId = mailMsg.Id;
        attRecord.Body = Blob.valueOf('Test Attach');
        attRecord.Name= 'Test';
        INSERT attRecord;
        
        PageReference pgRef = Page.AttachDocumenttoOtherRecords;
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('Id', String.valueOf(caseRec.Id));
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(caseRec);
        AttachDocumenttoOtherRecords attachDocRec = new AttachDocumenttoOtherRecords(standardCtrl);
        
        attachDocRec.listAttachWrap[0].check = true;
        attachDocRec.listAttachWrap[1].check = true;
        attachDocRec.listAttachWrap[0].attach.Description = 'Other';
        attachDocRec.listAttachWrap[1].attach.Description = 'Other';
        attachDocRec.attachDocument();
        //attachDocRec.createNewAssignment();

        System.Test.stopTest();
    }
}