/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of AttachDocumentToOtherRecordsCU
 *  @author : A5E Consulting
 *  @date : 30/07/2018
 * 
 *************************************************************************************************/
@isTest
public class TestAttachDocumenttoOtherRecordsCU {
    public static testMethod void testAttachments(){
        API_Call_Details__c docParseApi = new API_Call_Details__c(
                        Name = 'Document Parser API',
                        authorizationtUrl__c = 'https://login.microsoftonline.com/{{dptenandId}}/oauth2/v2.0/token',
                        Client_ID__c = '0065e940-176c-41bc-a4a3-fc17e4679cd5',
                        Client_Secret__c = 'NGU@y:vcr?R4:6Gb7Q2vl7W3kpND4?UF',
                        Proxy_Client_ID__c = 'eee6f4ef-6907-47ff-a8bc-cb80ede4e3e0',
                        Tenand_ID__c = '9d30e665-3bf0-4712-9ac6-b1d0b2812aa4',
                        PDF_API_URL__c = 'https://paschidev.azure-api.net/canaccede/v1/datapipeline/pdf');
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
        config.Doc_Parser_API_Key__c = '7146d1c4f964579e9faa36c112b2035e3d965a03';
        config.Target_URL_for_Insolvency__c = 'https://api.docparser.com/v1/document/upload'; 
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
        caseObj.SuppliedEmail = 'abc@bankex.ca';
        caseObj.Subject = '\\"INSOL-90809\\"';
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

        PageReference pageRef = Page.AttachDocumenttoOtherRecordsCU;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AttachDocumenttoOtherRecordsCU attachRec = new AttachDocumenttoOtherRecordsCU(sc);       
    }

}