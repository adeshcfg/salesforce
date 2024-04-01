@isTest(seeAllData = false)
public class TestDocumentParser {
    
    @TestSetup
    static void makeData(){

         //Custom setting record creation
         Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
         config.Run_Insolvency_Account_Trigger__c = true;
         config.Run_Insolvency_Status_Validations__c = true;
         config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
         config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
         config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
         config.Display_Duplicate_Accounts_List_View__c=10;
         config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
         config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
         config.Run_Insolvency_Trigger__c = false;
         config.Run_Insolvency_Account_Duplicate_Check__c = true;
         insert config;

        API_Call_Details__c docParseApi = new API_Call_Details__c(
                                                Name = 'Document Parser API',
                                                authorizationtUrl__c = 'https://autherizationUrl.com/{{dptenandId}}/oauth2/v2.0/token',
                                                Client_ID__c = 'Client_ID',
                                                Client_Secret__c = 'Client_Secret',
                                                Proxy_Client_ID__c = 'Proxy_Client_ID',
                                                Tenand_ID__c = 'Tenand_ID',
                                                PDF_API_URL__c = 'https://apiurl/canaccede/v1/datapipeline/pdf');
        insert docParseApi;                


        //Insolvency record creation
        Insolvency__c insolvencyRec = new Insolvency__c();
        insolvencyRec.Name = 'INSOL-90809';
       // insolvencyRec.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyRec.Client_Identifiers__c = 'Scotia Bank';
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

    }

    static @IsTest
    public void testsuccessResponse(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        Attachment att = [select id from Attachment LIMIT 1];
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, TestDocumentParseMock.getDocumentParserResponse());
        DocumentParser.sendDoc(new Map<Id, Id>{cs.Id=> att.id});
        Test.stopTest();
    }

    static @IsTest
    public void testUpdateParseResponse(){
        DocumentParser.updateParsedResponse(new Parsed_Response_Holder__c(), new HttpResponse(), 'errorDetails');
        DocumentParser.replaceSpecialString('Test String Bankrupt Failli(e)');
    }
}