/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of CommissionStatementDownloadController
*  @author : A5E Consulting
*  @date : 08/08/2022
* 
*************************************************************************************************/
@isTest
public class TestCommissionStatementDownloadContr {
    public static API_Call_Details__c testDocumentAPI(){
         
        //API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        API_Call_Details__c  settings = new API_Call_Details__c ();
        //API_Call_Details__c  settings = new API_Call_Details__c ();
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
    public static testMethod void testMethod1(){
       API_Call_Details__c api = testDocumentAPI();
        //Create Placement record
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        //Create Document storage record
        List<Id> docList = new List<Id>();
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Placement'+' '+ place.Name +' '+'Commission Statement.pdf';
        docInfo.Document_Type__c = 'Commission Statement';
        docInfo.Document_URL__c = 'placement@1ea88a5a-da89-42fa-bdab-9350b26753b3_pdf';
        docInfo.Document_Id__c = '1ea88a5a-da89-42fa-bdab-9350b26753b3';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        insert docInfo;
        // Document Storage data
       Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        docList.add(docInfo.Id);
        
        String PlaceRecordID = String.valueOf(place.ID);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        CommissionStatementDownloadController.getFiles(PlaceRecordID);
        CommissionStatementDownloadController.previewDocument(docInfo.Document_Id__c);
        Test.stopTest();
    }
}