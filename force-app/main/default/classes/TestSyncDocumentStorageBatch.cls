/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of SyncDocumentStorageBatch
*  @author : A5E Consulting
*  @date : 22/07/2022
* 
*************************************************************************************************/
@Istest
public class TestSyncDocumentStorageBatch {
    @testsetup
    public static void makeData(){
        API_Call_Details__c newApiCS=new API_Call_Details__c();
        newApiCS.Name='Agency Portal API';
        newApiCS.Tenand_ID__c='84f3381f-1ccd-422b-87f5-4f742b0f564e	';
        newApiCS.AuthorizationtUrl__c='https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        insert newApiCS;
    }
    public static testMethod void testMethod1(){
        
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        system.debug('settings:'+settings);
        //API_Call_Details__c  settings = new API_Call_Details__c ();
        //settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        update settings;
        //List<Placement__c> lstPlacement= new List<Placement__c>();        
        Placement__c place = new Placement__c();
        place.Name = '106'+System.now();
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        List<Id> docList = new List<Id>();
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Placement'+' '+ place.Name +' '+'Commission Statement.pdf';
        docInfo.Document_Type__c = 'Commission Statement';
        //docInfo.Document_URL__c = 'Test';//parsedResponse.DocUrl
        //docInfo.Document_Id__c = '122312312';//parsedResponse.docId
        docInfo.Document_URL__c = 'placement@1ea88a5a-da89-42fa-bdab-9350b26753b3_pdf';
        docInfo.Document_Id__c = '1ea88a5a-da89-42fa-bdab-9350b26753b3';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        insert docInfo;
        docList.add(docInfo.Id);
        
        Test.startTest();
        
        //CommissionStatementController();
        SyncDocumentStorageBatch obj = new SyncDocumentStorageBatch(docList);
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
}