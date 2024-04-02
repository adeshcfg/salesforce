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
public class TestAttachDocumentToOtherRecordsDP   {
        
    @IsTest
    static void testMethodNewCasebankex() {
        API_Call_Details__c docParseApi = new API_Call_Details__c(
                        Name = 'Document Parser API',
                        authorizationtUrl__c = 'https://login.authenticationUrl.com/{{dptenandId}}/oauth2/v2.0/token',
                        Client_ID__c = 'Client_ID',
                        Client_Secret__c = 'Client_Secret',
                        Proxy_Client_ID__c = 'Proxy_Client_ID',
                        Tenand_ID__c = 'Tenand_ID',
                        PDF_API_URL__c = 'https://apiurl.net/canaccede/v1/datapipeline/pdf');
            insert docParseApi;                

        
        //Application config creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
        config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
        config.Eligible_for_Validn_Needed_Calculation__c = 'test';
        config.Bank_Eligible_for_Duplicate_Check__c = 'test';
        config.Eligible_for_Claim_Type_Calculation__c = 'test';
        config.Doc_Parser_API_Key__c = 'docparserapikey';
        config.Target_URL_for_Insolvency__c = 'https://docparserurl.com/v1/document/upload'; 
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
        insolvencyRec.Insolvency_Status__c = 'Staging';
        INSERT insolvencyRec;

         //Insolvency Account record Creation
         Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
         insolvencyAccount.Account_Type__c = 'Mortgage';
         insolvencyAccount.Insolvency__c = insolvencyRec.Id;
         insolvencyAccount.Insolvency_Type__c = 'Consumer Proposal';
         insolvencyAccount.Name = 'test';
         INSERT insolvencyAccount;

        permissionset ps=[select id from permissionset where name='Send_to_Document_Parser_access' limit 1];
        //insert new permissionsetassignment(AssigneeId=UserInfo.getUserId(),permissionsetid=ps.id);
        
        //Case record creation
       id recordtypeID=schema.SObjectType.case.getRecordtypeInfosByName().get('CCS Case').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@bankex.ca';
        caseObj.Subject = '\\"INSOL-90809\\"';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.Status = 'InProgress';
       // caseObj.Insolvency__c = insolvencyRec.Id;
        caseObj.RecordTypeId=recordtypeID;
        INSERT caseObj;
        
        //EmailMessage record creation
        EmailMessage emailMsg =  new EmailMessage();
        emailMsg.relatedToid = caseObj.Id;
        emailMsg.TextBody = 'Test Email';
        emailMsg.FromAddress = 'abc@gmail.com';
        emailMsg.ToAddress = 'xyz@gmail.com';
        INSERT emailMsg;

        PageReference pageRef = Page.AttachDocumenttoOtherRecordsDP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecordsDP attachRec = new AttachDocumenttoOtherRecordsDP(sc);
        attachRec.getAllInsolvencyAccountDocumentOptions();
        attachRec.attachDocument();   

        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = emailMsg.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        INSERT att;

        //Attachment record creation
        Attachment att1 = new Attachment();
        att1.parentId = emailMsg.Id;
        att1.Body = Blob.valueOf('Test Attach');
        att1.Name= 'Test';
        INSERT att1;

        sc = new ApexPages.StandardController(caseObj);

        attachRec = new AttachDocumenttoOtherRecordsDP(sc);
        attachRec.attachDocument();   
        
        attachRec.listAttachWrap[0].check = true;
        //AttachDocumenttoOtherRecords.getAllDocumentOptions();
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, TestDocumentParseMock.getDocumentParserResponse());
        attachRec.sendDocument();

        caseObj.Document_Id__c='tes';
        CaseTriggerHandler.runCaseTrigger = false;
        update caseObj;
        CaseTriggerHandler.runCaseTrigger = true;
        attachRec.listAttachWrap[0].check = false;
        attachRec.listAttachWrap[1].check = true;
        attachRec.sendDocument();
        System.Test.stopTest();
        attachRec.attachDocument();        

    }



    @IsTest
    static void testMethodNewCaseuberbase() {
        API_Call_Details__c docParseApi = new API_Call_Details__c(
                        Name = 'Document Parser API',
                        authorizationtUrl__c = 'https://login.autherizationUrl.com/{{dptenandId}}/oauth2/v2.0/token',
                        Client_ID__c = 'Client_ID',
                        Client_Secret__c = 'Client_Secret',
                        Proxy_Client_ID__c = 'Proxy_Client_ID',
                        Tenand_ID__c = 'Tenand_ID',
                        PDF_API_URL__c = 'https://apiurl.net/canaccede/v1/datapipeline/pdf');
            insert docParseApi;                

        
         //Application config creation
         Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
         config.Run_Insolvency_Account_Trigger__c = true;
         config.Run_Insolvency_Trigger__c = false;
         config.Run_Insolvency_Account_Duplicate_Check__c = true;
         config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
         config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
         config.Eligible_for_Validn_Needed_Calculation__c = 'test';
         config.Bank_Eligible_for_Duplicate_Check__c = 'test';
         config.Eligible_for_Claim_Type_Calculation__c = 'test';
         config.Doc_Parser_API_Key__c = 'docparserapikey';
         config.Target_URL_for_Insolvency__c = 'https://docparserurl.com/v1/document/upload'; 
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
        insolvencyRec.Insolvency_Status__c = 'Staging';
        INSERT insolvencyRec;

         //Insolvency Account record Creation
         Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
         insolvencyAccount.Account_Type__c = 'Mortgage';
         insolvencyAccount.Insolvency__c = insolvencyRec.Id;
         insolvencyAccount.Insolvency_Type__c = 'Consumer Proposal';
         insolvencyAccount.Name = 'test';
         INSERT insolvencyAccount;

        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@uberbase.com';
        caseObj.Subject = 'INSOL-908092';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.Status = 'InProgress';
        caseObj.Insolvency_Account__c = insolvencyAccount.Id;
        caseObj.Document_Id__c = 'ee';
        INSERT caseObj;
        
        //EmailMessage record creation
        EmailMessage emailMsg =  new EmailMessage();
        emailMsg.relatedToid = caseObj.Id;
        emailMsg.TextBody = 'Test Email';
        emailMsg.FromAddress = 'abc@gmail.com';
        emailMsg.ToAddress = 'xyz@gmail.com';
        INSERT emailMsg;

        PageReference pageRef = Page.AttachDocumenttoOtherRecordsDP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecordsDP attachRec = new AttachDocumenttoOtherRecordsDP(sc);
        attachRec.attachDocument();   

        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = emailMsg.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        INSERT att;

        //Attachment record creation
        Attachment att1 = new Attachment();
        att1.parentId = emailMsg.Id;
        att1.Body = Blob.valueOf('Test Attach');
        att1.Name= 'Test';
        INSERT att1;

        sc = new ApexPages.StandardController(caseObj);
        attachRec = new AttachDocumenttoOtherRecordsDP(sc);
        attachRec.attachDocument();   
        
        attachRec.listAttachWrap[0].check = true;

        //AttachDocumenttoOtherRecords.getAllDocumentOptions();
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, TestDocumentParseMock.getDocumentParserResponse());
        try{
        attachRec.sendDocument();
        }catch(Exception ex){

        }
        System.Test.stopTest();        

    }
   
    
    @IsTest
    static void testMethodAttachDoc(){
        System.Test.setMock(HttpCalloutMock.class, TestDocumentParseMock.getDocumentParserResponse());
        System.Test.startTest();

        //Application config creation
        //Application config creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
        config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
        config.Eligible_for_Validn_Needed_Calculation__c = 'test';
        config.Bank_Eligible_for_Duplicate_Check__c = 'test';
        config.Eligible_for_Claim_Type_Calculation__c = 'test';
        config.Doc_Parser_API_Key__c = 'docparserapikey';
        config.Target_URL_for_Insolvency__c = 'https://docparserurl.com/v1/document/upload'; 
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
        insolvencyRec.Insolvency_Status__c = 'Staging';
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


        PageReference pageRef = Page.AttachDocumenttoOtherRecordsDP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecordsDP attachRec = new AttachDocumenttoOtherRecordsDP(sc);
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
        insolvencyAccount.Name = 'test';
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
        
        PageReference pgRef = Page.AttachDocumenttoOtherRecordsDP;
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('Id', String.valueOf(caseRec.Id));
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(caseRec);
        AttachDocumenttoOtherRecordsDP attachDocRec = new AttachDocumenttoOtherRecordsDP(standardCtrl);
        
        attachDocRec.listAttachWrap[0].check = true;
        attachDocRec.listAttachWrap[1].check = true;
        attachDocRec.listAttachWrap[0].attach.Description = 'Other';
        attachDocRec.listAttachWrap[1].attach.Description = 'Other';
        attachDocRec.attachDocument();
        //attachDocRec.createNewAssignment();

        System.Test.stopTest();
    }

     @IsTest
    static void testCaseWithoutInsolvency(){
        System.Test.setMock(HttpCalloutMock.class, TestDocumentParseMock.getDocumentParserResponse());
        System.Test.startTest();

         //Application config creation
         Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
         config.Run_Insolvency_Account_Trigger__c = true;
         config.Run_Insolvency_Trigger__c = false;
         config.Run_Insolvency_Account_Duplicate_Check__c = true;
         config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
         config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
         config.Eligible_for_Validn_Needed_Calculation__c = 'test';
         config.Bank_Eligible_for_Duplicate_Check__c = 'test';
         config.Eligible_for_Claim_Type_Calculation__c = 'test';
         config.Doc_Parser_API_Key__c = 'docparserkey';
         config.Target_URL_for_Insolvency__c = 'https://docparserurl.com/v1/document/upload'; 
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


        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@a5econsulting.net';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.Status = 'InProgress';
        caseObj.Insolvency_Assignment_Type__c = 'Business Insolvency' ;
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


        PageReference pageRef = Page.AttachDocumenttoOtherRecordsDP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecordsDP attachRec = new AttachDocumenttoOtherRecordsDP(sc);
        attachRec.listAttachWrap[0].check = true;
        attachRec.listAttachWrap[0].attach.Description = 'Other';
        attachRec.attachDocument();

        System.Test.stopTest();
    }
}