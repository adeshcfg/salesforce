/**
 * @description       : Test class for PutbackBuybackQueueable and PutbackBuybackUtility
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-25-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class PutbackBuybackQueueableTest {
    @TestSetup
    static void makeData() {
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/api/accessToken';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/api/Document';
        settings.Scope_Prefix__c = 'scope.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        insert settings;

        Account acc = new Account();
        acc.Name = 'Anea';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seller').getRecordTypeId();

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert new List<Account>{ acc, customer };

        Portfolio_Name__c portfolio = new Portfolio_Name__c();
        portfolio.Name = 'MBNA24';
        portfolio.Account_Purchasing_Entity_ID__c = 'test';
        portfolio.Seller__c = acc.Id;
        insert portfolio;

        Product__c prod = new Product__c();
        prod.Name = '12345';
        prod.Seller__c = acc.Id;
        prod.Internal_Status__c = 'Active';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Funded';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 3000.00;
        prod.Collection_Agency__c = 30;
        prod.Current_Balance__c = 7730;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2730;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = '297000';
        prod.Last_Name__c = 'xyz';
        prod.Placement_Status__c = '100010';
        prod.Credit_Counselling_Date__c = null;
        prod.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod.Charged_Off_Date__c = Date.newInstance(2020, 12, 5);
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod.Purchase_Province__c = 'PE';
        prod.Customer__c = customer.id;

        Product__c prod1 = prod.clone();
        prod1.Name = '54321';
        prod1.Product_Status__c = '298000';
        insert new List<Product__c>{ prod, prod1 };

        Document_Storage__c docStore = new Document_Storage__c();
        docStore.Document_Name__c = '12345 Evidenece';
        docStore.Product__c = prod.Id;
        docStore.Buyback_Putback_Evidence__c = true;

        Document_Storage__c docStoreZip = new Document_Storage__c(Document_Name__c = 'Test_Anea.zip');
        insert new List<Document_Storage__c>{ docStore, docStoreZip };

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('Test');
        cv.Title = 'Test_Anea';
        cv.PathOnClient = 'Test_Anea' + '.csv';
        insert cv;
    }

    @IsTest
    static void testPutbackProcessCsvGeneration() {
        PutbackBuybackUtility.getSellerList();
        PutbackBuybackUtility.canGenerateFile('Anea');
        PutbackBuybackUtility.newMessageException('Error Message');
        PutbackBuybackUtility.createApiError('Test', 'Test', 'Test', 'test@xyz.com');
        PutbackBuybackUtility.createInsolvencyError('Test', 'Test', 'Test');
        Test.startTest();
        PutbackBuybackUtility.initiateFormGeneration('Anea');
        Test.stopTest();
    }

    @IsTest
    static void testPutbackProcessZipGeneration() {
        Document_Storage__c zipDoc = [SELECT Id FROM Document_Storage__c WHERE Document_Name__c = 'Test_Anea.zip'];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Test_Anea'];
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(cv.Id));
        Map<String, Product__c> productIdListMap = new Map<String, Product__c>([SELECT Id FROM Product__c]);
        Test.startTest();
        System.enqueueJob(new PutbackBuybackQueueable(new List<String>(productIdListMap.keySet()), zipDoc.Id, 'Anea', cv.Id));
        Test.stopTest();
    }

    @IsTest
    static void testPutbackProcessZipGenerationWithoutEvidence() {
        Document_Storage__c zipDoc = [SELECT Id FROM Document_Storage__c WHERE Document_Name__c = 'Test_Anea.zip'];
        Document_Storage__c evidenceDoc = [SELECT Id FROM Document_Storage__c WHERE Document_Name__c = '12345 Evidenece'];
        evidenceDoc.Buyback_Putback_Evidence__c = false;
        update evidenceDoc;
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Test_Anea'];
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(cv.Id));
        Map<String, Product__c> productIdListMap = new Map<String, Product__c>([SELECT Id FROM Product__c]);
        Test.startTest();
        System.enqueueJob(new PutbackBuybackQueueable(new List<String>(productIdListMap.keySet()), zipDoc.Id, 'Anea', cv.Id));
        Test.stopTest();
    }
}
