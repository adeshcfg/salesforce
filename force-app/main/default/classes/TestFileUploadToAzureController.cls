/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a testclass.
 *  @author : A5E Consulting
 *  @date : 11/03/2020
 *  
 
 *************************************************************************************************/
@isTest
public class TestFileUploadToAzureController {
    @TestSetup
    static void dataSetup() {
        
        Test.startTest();
        Product__C prod2 = new Product__c();
        string recrdid1= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.RecordTypeId=recrdid1;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        INSERT prod2;
        
         API_Call_Details__c  settings1 = new API_Call_Details__c ();
        settings1.Name = 'Agency Portal API';
        settings1.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings1.Tenand_ID__c = '123';
        settings1.Proxy_Client_ID__c = '123';
        settings1.Client_ID__c = '1234';
        settings1.Client_Secret__c = '1234';
        settings1.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings1.Scope_Prefix__c = 'scopep.com';
        settings1.Scope_Suffix__c = '/.default';
        settings1.API_Request_Timeout__c = 10;
        insert settings1;
        
       Attachment_Document_Type__c AttachDocType = new Attachment_Document_Type__c(); 
        AttachDocType.Name = '01';
        AttachDocType.Media_Request_Document_Type__c = 'Application';
        // AttachDocType.Media_Request_Document_Visibility__c = 'CFG + All Agencies';
        insert AttachDocType;
        
        Attachment_Document_Type__c AttachDocType1 = new Attachment_Document_Type__c(); 
        //AttachDocType1.Media_Request_Document_Type__c = 'Application';
        AttachDocType1.Name = '02';
        AttachDocType1.Media_Request_Document_Visibility__c = 'CFG + All Agencies';
        insert AttachDocType1;
        
        Test.stopTest();
        
    }


    @isTest public static void TestFileUpload(){
        
        /*API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 10;
        insert settings;*/

        Product__C prod = new Product__c();
        string recrdid1= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid1;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Product_Status__c = 'Test Status';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;

        //Judgment record creation
        Judgment__c judg=new Judgment__c();
        Id RecrdId = Schema.SObjectType.Judgment__c.getRecordTypeInfosByName().get('Judgment').getRecordTypeId();
        judg.Legal_Agency__c = '29';
        judg.RecordTypeId=RecrdId;
        insert judg;
        //Settlement record creation
        settlement__c se = new settlement__c();
        se.status__C='New';
        se.Judgment__c=judg.id;
        //se.Product__c = prod.Id;
        insert se;
        settlement__c se2=new settlement__c();
        se2.status__C='New';
        se2.Product__c = prod.Id;
        insert se2;
        
        
        //contenVersion record creation
        String yourFiles = 'Lets assume this is your binary string of the files';
        ContentVersion Conver = new ContentVersion();
        Conver.ContentLocation = 'S';
        Conver.VersionData = EncodingUtil.base64Decode(yourFiles);
        Conver.Title = 'Proposal';
        Conver.PathOnClient= 'ionicLogo.png';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
        
        //ContentDocumentLink record Creation
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = se.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        String str = 'StringToBlob';
        Blob blobVal = Blob.valueof(str);
        
        Document_storage__c documentstoragecObj = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Product Payment Upload File', 
            Uploaded_By__c ='Internal User',
            Document_Id__c = conDoc//'12345'
            //Placement_Agency__c = 'Here is reference id', 
            //Work_Assignment__c = 'Here is reference id'
        );
        
        insert documentstoragecObj;
        
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Purpose__c = 'Media Request';
        insert wrkAss;
        
        Work_Assignment__c wrkAss1 = new Work_Assignment__c();
        wrkAss1.Assign_To__c = 'CFG';
        wrkAss1.Status__c = 'Requested';
        wrkAss1.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss1.Purpose__c = 'Media Request';
        wrkAss1.product__c = prod.id;
        insert wrkAss1;
        
        Account_Judgment__c accJudgment = new Account_Judgment__c();        
        accJudgment.Product__c = prod.Id;
        accJudgment.Status__c = 'Active';
        insert accJudgment;
        
        //Calling Apex method
        Attachment_Document_Type__c attDocRec = new Attachment_Document_Type__c();
        attDocRec.Name= 'Test';
        attDocRec.Document_type__c = 'Test Doc';
        insert attDocRec;
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.documentTypeList();
        FileUploadToAzureController.saveTheFile(se.id,'Proposal',yourFiles,'ionicLogo.png','--None--');       
        FileUploadToAzureController.saveChunk(se.id, 'Proposal', yourFiles, 'ionicLogo.png','' , '--None--', 'Jan', '2012');
        FileUploadToAzureController.documentTypeList();
        FileUploadToAzureController.getPickListValuesIntoList();
        FileUploadToAzureController.getFiles(se.Id);
        FileUploadToAzureController.saveTheFile(se2.id,'Proposal',yourFiles,'ionicLogo.png','--None--');       
        FileUploadToAzureController.saveChunk(se2.id, 'Proposal', yourFiles, 'ionicLogo.png','' , '--None--', 'Jan', '2012');
        FileUploadToAzureController.getFiles(se2.Id);
        FileUploadToAzureController.getFiles(prod.Id);
        FileUploadToAzureController.getFiles(wrkAss1.Id);
        FileUploadToAzureController.getFiles(accJudgment.Id);
        FileUploadToAzureController.getPurpose(prod.Id);
        FileUploadToAzureController.getPurpose(wrkAss.Id);
        FileUploadToAzureController.save('ionicLogo.png',blobVal); 
        String yourFiles2 = 'Lets assume this is your binary string of the files';
        ContentVersion Conver1 = new ContentVersion();
        Conver1.ContentLocation = 'S';
        Conver1.VersionData = EncodingUtil.base64Decode(yourFiles2);
        Conver1.Title = 'Proposal@FileUpload';
        Conver1.PathOnClient= 'ionicLogo.png';
        insert conVer1;
        Id conDoc1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];         
        //ContentDocumentLink record Creation
        ContentDocumentLink cDe1 = new ContentDocumentLink();
        cDe1.ContentDocumentId = conDoc1;
        cDe1.LinkedEntityId = prod.id; // This will link inserted file to above inserted settlement record
        cDe1.ShareType = 'I'; 
        cDe1.Visibility = 'InternalUsers';
        insert cDe1;

        //FileUploadToAzureController.previewDocument(null);
        String yourFiles1 = 'Lets assume this is your binary string of the files';
        FileUploadToAzureController.appendToFile(conDoc1,'Test');
        //FileUploadToAzureController.getDocument(documentstoragecObj.Document_ID__c);
        //FileUploadToAzureController.contentSize(conDoc1);
        //FileUploadToAzureController.previewDocument(conDoc1);
        Id docId = conDoc1;
        string recordId = prod.id;
        string prodId = prod.id;
        FileUploadToAzureController.uploadFileToAzure(docId,recordId,'Product Payment Upload File','Product__c','CFG Only',true,prodId);
        FileUploadToAzureController.contentSize(docId);
        FileUploadToAzureController.deleteFile(conDoc1);
        //FileUploadToAzureController.uploadDocumentProxy(docId);
        Test.stopTest();
      }

    @isTest public static void TestFileUpload2(){
        Product__c prod2 = [Select id from Product__c where name ='123456789'];
        settlement__c settlement =new settlement__c();
        settlement.status__C='New';
        settlement.Product__c = prod2.Id;
        insert settlement;
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.uploadFile(settlement.id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Settlement__c', 'CFG only',true,settlement.Id);
        Test.stopTest();
    }
    
    @isTest public static void TestFileUpload3(){
        Product__c prod3 = [Select id from Product__c where name ='123456789'];
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.uploadFile(prod3.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Product__c', 'CFG only',true,prod3.Id);
        //FileUploadToAzureController.uploadFile(prod3.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Account', 'CFG only',true,prod3.Id);
        /*FileUploadToAzureController.uploadFile(prod2.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Judgment__c', 'CFG only',true,prod2.Id);
        FileUploadToAzureController.uploadFile(prod2.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Settlement__c', 'CFG only',true,prod2.Id);
        FileUploadToAzureController.uploadFile(prod2.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Work_Assignment__c', 'CFG only',true,prod2.Id);
        FileUploadToAzureController.uploadFile(prod2.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','PortFolio_Name__c', 'CFG only',true,prod2.Id);
        FileUploadToAzureController.uploadFile(prod2.Id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Work_Assignment__c', 'CFG only',false,prod2.Id);
        */
        Test.stopTest();
    }
    
    @isTest public static void TestFileUpload4(){
        Judgment__c judg=new Judgment__c();
        Id RecrdId = Schema.SObjectType.Judgment__c.getRecordTypeInfosByName().get('Judgment').getRecordTypeId();
        judg.Legal_Agency__c = '29';
        judg.RecordTypeId=RecrdId;
        insert judg;
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.uploadFile(judg.id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Judgment__c', 'CFG only',true,judg.Id);
        Test.stopTest();
    }
    
    @isTest public static void TestFileUpload5(){
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        insert wrkAss;
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.uploadFile(wrkAss.id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Task', 'CFG only',true,wrkAss.Id);
        Test.stopTest();
    }
    
    @isTest public static void TestFileUpload6(){
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
       portfolioName.Account_Purchasing_Entity_ID__c = 'text';
       portfolioName.Name = 'AFSCCO101';
        insert portfolioName;
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.uploadFile(portfolioName.id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','portfolio', 'CFG only',true,portfolioName.Id);
        Test.stopTest();
    }
    
    @isTest public static void TestFileUpload7(){
        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert accInstance;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        FileUploadToAzureController.uploadFile(accInstance.id,'Recalled Accounts for 29.csv','YWdlbmN5X2lkLGFjY291bnRfbmFtZSxwbGFjZW1lbnRfZGF0ZSxyZWNhbGxlZF9kYXRlLHByb2R1Y3Rfc3RhdHVzLGRlc2NyaXB0aW9uCjI5LDEwMDFQMTUwLG51bGwsMjAyMi0wOC0xNyAwMDowMDowMCwyMDEyMDAsV2FyZWhvdXNlOiBCYW5rcnVwdGN5IC0gUHJvcG9zYWw%3D','text/csv','Cease and Desist','Customer', 'CFG only',true,accInstance.Id);
        Test.stopTest();
    }
    

}