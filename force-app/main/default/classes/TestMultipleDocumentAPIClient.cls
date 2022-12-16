@isTest
public class TestMultipleDocumentAPIClient {
    public static API_Call_Details__c testDocumentAPI(){
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000; 
        insert settings;
        return settings;
        
    }
    public static testMethod void testDocAPIcall(){
        API_Call_Details__c api = testDocumentAPI();
        //insert placement
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        //Insert product
        Product__c prod2 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 106;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Collection_Agency__c = Decimal.valueOf(place.Name);        
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;
        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        
        //insert content version
        String yourFiles = 'Lets assume this is your binary string of the files';
        ContentVersion Conver = new ContentVersion();
        Conver.ContentLocation = 'S';
        Conver.VersionData = EncodingUtil.base64Decode(yourFiles);
        Conver.Title = 'Proposal@FileUpload';
        Conver.PathOnClient= 'ionicLogo.png';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];         
        //ContentDocumentLink record Creation
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = prod2.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        test.startTest();
        String failed;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        failed =  'data_1id,pri_email1,pri_add1,pri_add2,pri_municipality';//,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';
        Blob bl = Blob.valueOf(failed);
        MultipleDocumentAPIClient.AttachWrapper attach = new MultipleDocumentAPIClient.AttachWrapper();
        attach = MultipleDocumentAPIClient.postDocument1(cDe.ContentDocumentId);
        MultipleDocumentAPIClient.getDocument(docAzur.Document_ID__c);
        MultipleDocumentAPIClient.getDocumentInfo(docAzur.Document_ID__c);
        MultipleDocumentAPIClient.getDocumentJSON(docAzur.Document_URL__c);
        test.stopTest();
    }
}