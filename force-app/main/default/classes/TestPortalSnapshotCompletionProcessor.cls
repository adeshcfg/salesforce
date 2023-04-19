/*========================================================================
*
* Class: TestPortalSnapshotCompletionProcessor
*
* @description : It covers PortalSnapshotCompletionProcessor class code coverage
* @author : A5E Consulting
* @date : 21/02/2023
* @Developer Name: Satyajit Patil
========================================================================*/

@isTest
public class TestPortalSnapshotCompletionProcessor {
    public static testMethod void testPortalSnapshot(){ 
        
       Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
       
       API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurlTask';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
       
       Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
       
        Product__c product = new Product__c();
        product.name = '1178P04090';
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = '1178P04093';
        product.name = 'Test Product';
        insert product2;
        
        Placement__c placement1 = new Placement__c();
        placement1.name = '11';
        insert placement1;
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        insert poolData;
       
       Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Data_Id__c = product.name;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'SUCCESS';
        productStaging.Status__c = 'Processed';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Current_Principal_Balance__c = 5000;
        productStaging.Current_Interest_Balance__c = 400;
        productStaging.Fees__c = 300;
        insert productStaging;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Data_Id__c = product.name;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = '<b>ERROR</b>- Not found;SUCCESS';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.Pool_Name_ID__c = poolData.id;
        productStaging2.status__c='Processed';
        productStaging2.Current_Principal_Balance__c = 5000;
        productStaging2.Current_Interest_Balance__c = 400;
        productStaging2.Fees__c = 300;
        insert productStaging2;
        
	 RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"DocumentStorageId":"'+docStorage.ID+'","Allocations":[{"Agency":23,"Errors":[{"DataId":"Test Product","Detail":"Test Product is placed 14, expecting 23"},{"DataId":"Test Product2","Detail":"Test Product2 is placed 14, expecting 23"},{"DataId":"1178P04101","Detail":"1178P04101 is placed 14, expecting 23"},{"DataId":"1178P04132","Detail":"1178P04132 is placed 14, expecting 23"},{"DataId":"1178P04136","Detail":"1178P04136 is placed 14, expecting 23"},{"DataId":"1178P04103","Detail":"1178P04103 is placed 14, expecting 23"},{"DataId":"1178P04154","Detail":"1178P04154 is placed 14, expecting 23"},{"DataId":"1178P04096","Detail":"1178P04096 is placed 14, expecting 23"},{"DataId":"1178P04152","Detail":"1178P04152 is placed 14, expecting 23"},{"DataId":"1178P04105","Detail":"1178P04105 is placed 14, expecting 23"},{"DataId":"1178P04090","Detail":"1178P04090 is placed 14, expecting 23"},{"DataId":"1178P04122","Detail":"1178P04122 is placed 14, expecting 23"},{"DataId":"1178P04141","Detail":"1178P04141 is placed 14, expecting 23"},{"DataId":"1178P04099","Detail":"1178P04099 is placed 14, expecting 23"},{"DataId":"1178P04106","Detail":"1178P04106 is placed 14, expecting 23"},{"DataId":"1178P04100","Detail":"1178P04100 is placed 14, expecting 23"},{"DataId":"1178P04112","Detail":"1178P04112 is placed 14, expecting 23"},{"DataId":"1178P04150","Detail":"1178P04150 is placed 14, expecting 23"},{"DataId":"1178P04093","Detail":"1178P04093 is placed 14, expecting 23"},{"DataId":"1178P04117","Detail":"1178P04117 is placed 14, expecting 23"},{"DataId":"1178P04129","Detail":"1178P04129 is placed 14, expecting 23"}]},{"Agency":25,"Errors":[{"DataId":"1215P030","Detail":"1215P030 is placed 14, expecting 25"},{"DataId":"1215P018","Detail":"1215P018 is placed 14, expecting 25"},{"DataId":"1234P1738","Detail":"1234P1738 is placed 14, expecting 25"},{"DataId":"1234P1736","Detail":"1234P1736 is placed 14, expecting 25"},{"DataId":"1215P009","Detail":"1215P009 is placed 14, expecting 25"},{"DataId":"1234P1766","Detail":"1234P1766 is placed 14, expecting 25"},{"DataId":"1234P1770","Detail":"1234P1770 is placed 14, expecting 25"},{"DataId":"1234P1820","Detail":"1234P1820 is placed 14, expecting 25"},{"DataId":"1234P1782","Detail":"1234P1782 is placed 14, expecting 25"},{"DataId":"1234P1751","Detail":"1234P1751 is placed 14, expecting 25"},{"DataId":"1234P1718","Detail":"1234P1718 is placed 14, expecting 25"},{"DataId":"1215P013","Detail":"1215P013 is placed 14, expecting 25"},{"DataId":"1234P1794","Detail":"1234P1794 is placed 14, expecting 25"},{"DataId":"1234P1752","Detail":"1234P1752 is placed 14, expecting 25"},{"DataId":"1234P1659","Detail":"1234P1659 is placed 14, expecting 25"},{"DataId":"1234P1800","Detail":"1234P1800 is placed 14, expecting 25"},{"DataId":"1234P1755","Detail":"1234P1755 is placed 14, expecting 25"},{"DataId":"1234P1648","Detail":"1234P1648 is placed 14, expecting 25"},{"DataId":"1234P1774","Detail":"1234P1774 is placed 14, expecting 25"},{"DataId":"1234P1787","Detail":"1234P1787 is placed 14, expecting 25"},{"DataId":"1234P1764","Detail":"1234P1764 is placed 14, expecting 25"},{"DataId":"1234P1818","Detail":"1234P1818 is placed 14, expecting 25"},{"DataId":"1234P1776","Detail":"1234P1776 is placed 14, expecting 25"},{"DataId":"1234P1716","Detail":"1234P1716 is placed 14, expecting 25"},{"DataId":"1234P1732","Detail":"1234P1732 is placed 14, expecting 25"},{"DataId":"1215P040","Detail":"1215P040 is placed 14, expecting 25"},{"DataId":"1215P004","Detail":"1215P004 is placed 14, expecting 25"},{"DataId":"1234P1746","Detail":"1234P1746 is placed 14, expecting 25"},{"DataId":"1234P1828","Detail":"1234P1828 is placed 14, expecting 25"}]},{"Agency":22,"Errors":[]}]}';      

        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PortalSnapshotCompletionProcessor.doPost();
        Test.stopTest();
    }
    
    public static testMethod void testPortalErrorSnapshot(){ 
        
       Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
       
       API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurlTask';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
       
       Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
       
        Product__c product = new Product__c();
        product.name = '1178P04090';
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = '1178P04093';
        product.name = 'Test Product';
        insert product2;
        
        Placement__c placement1 = new Placement__c();
        placement1.name = '11';
        insert placement1;
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        insert poolData;
       
       Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Data_Id__c = product.name;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'SUCCESS';
        productStaging.Status__c = 'Processed';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Current_Principal_Balance__c = 5000;
        productStaging.Current_Interest_Balance__c = 400;
        productStaging.Fees__c = 300;
        insert productStaging;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Data_Id__c = product.name;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = '<b>ERROR</b>- Not found;SUCCESS';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.Pool_Name_ID__c = poolData.id;
        productStaging2.status__c='Processed';
        productStaging2.Current_Principal_Balance__c = 5000;
        productStaging2.Current_Interest_Balance__c = 400;
        productStaging2.Fees__c = 300;
        insert productStaging2;
        
	 RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonError = '{"DocumentStorageId":"'+docStorage.ID+'","Error":"Timeout expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.\n   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)\n   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)\n   at System.Data.SqlClient.SqlCommand.InternalEndExecuteReader(IAsyncResult asyncResult, String endMethod)\n   at System.Data.SqlClient.SqlCommand.EndExecuteReaderInternal(IAsyncResult asyncResult)\n   at System.Data.SqlClient.SqlCommand.EndExecuteReader(IAsyncResult asyncResult)\n   at System.Threading.Tasks.TaskFactory`1.FromAsyncCoreLogic(IAsyncResult iar, Func`2 endFunction, Action`1 endAction, Task`1 promise, Boolean requiresSynchronization)\n--- End of stack trace from previous location ---\n   at AgencyPortal.Blazor.Server.Services.BackgroundCsvExtractEngine.GenerateAgencySnapshotsCsvs(UnitOfWork uow, AgencyCsvDocument rq) in /home/runner/work/cnccd-agency-portal/cnccd-agency-portal/AgencyPortal.Blazor.Server/Services/BackgroundCsvExtractEngine.cs:line 846\n   at AgencyPortal.Blazor.Server.Services.BackgroundCsvExtractEngine.GenerateAgencySnapshotsCsvs(UnitOfWork uow, AgencyCsvDocument rq) in /home/runner/work/cnccd-agency-portal/cnccd-agency-portal/AgencyPortal.Blazor.Server/Services/BackgroundCsvExtractEngine.cs:line 959"}';

        system.debug('JSONPaymentTransaction: '+jsonError);
        req.requestBody  = Blob.valueof(jsonError);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PortalSnapshotCompletionProcessor.doPost();
        PortalSnapshotCompletionProcessor.doPost();
        Test.stopTest();
    }
}