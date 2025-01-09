/**
 * @description       : Test class for CTBProcessedFilesChecker
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 01-09-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class CTBProcessedFilesCheckerTest {
    @TestSetup
    static void makeData() {
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/api/accessToken';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/api/getFileList';
        settings.Scope_Prefix__c = 'scope.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        insert settings;
    }

    @isTest
    static void noFilesTest() {
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(null));
        Test.startTest();
        CTBProcessedFilesChecker scheduler = new CTBProcessedFilesChecker();
        scheduler.execute(null);
        Test.stopTest();
    }

    @isTest
    static void allFilesTest() {
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(null));
        Document_storage__c docStorage = new Document_storage__c(Document_Name__c = 'ptd.drn.drnbkruptupd.date.time');
        insert docStorage;
        Test.startTest();
        CTBProcessedFilesChecker scheduler = new CTBProcessedFilesChecker();
        scheduler.execute(null);
        Test.stopTest();
    }
}
