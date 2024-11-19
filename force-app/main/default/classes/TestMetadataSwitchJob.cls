/**************************************************************************************************
*
*  Class:   
*
*  @description : TestMetadataSwitchJob
*  @author : A5E Consulting
*  @date : 04/07/2022  

*************************************************************************************************/
@Istest(SeeAllData=true)
public class TestMetadataSwitchJob {
    /*static {
        Metadata_Object__c metaData = new Metadata_Object__c();
        //metaData.name =
        metaData.Object_Name__c = 'Product';
        metaData.Metadata_Type__c = 'ValidationRule';
        metaData.Metadata_Rule_Name__c = 'Product__c.Putback_Reason';
        insert metaData;
        
         Metadata_Object__c metaData1 = new Metadata_Object__c();
        //metaData.name =
        metaData1.Object_Name__c = 'Product';
        metaData1.Metadata_Type__c = 'WorkflowRule';
        metaData1.Metadata_Rule_Name__c = 'Product__c.Collection DD22 NOPTP';
        insert metaData1;
        
        //API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        
        API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        //API_Call_Details__c  settings = new API_Call_Details__c ();
        //settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        update settings;
        
    }*/
    
    public static testMethod void testschedule() {
        Disable_Metadata_Settings__c disMeta = new Disable_Metadata_Settings__c();
        disMeta.Disable_Product_Validation_WF__c = true;
        insert disMeta;
        
        //Test.setMock(WebServiceMock.class, new MetadataServiceTest());
       Metadata_Object__c metaData = new Metadata_Object__c();
        //metaData.name =
        metaData.Object_Name__c = 'Product';
        metaData.Metadata_Type__c = 'ValidationRule';
        metaData.Metadata_Rule_Name__c = 'Product__c.Putback_Reason';
        insert metaData;
        
         Metadata_Object__c metaData1 = new Metadata_Object__c();
        //metaData.name =
        metaData1.Object_Name__c = 'Product';
        metaData1.Metadata_Type__c = 'WorkflowRule';
        metaData1.Metadata_Rule_Name__c = 'Product__c.Collection DD22 NOPTP';
        insert metaData1;
        
        //API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        //Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        //API_Call_Details__c  settings = new API_Call_Details__c ();
        //settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        update settings;
    
        /*MetadataService.Error error = new MetadataService.Error();
        error.statusCode = '401';
        error.message = 'Not found';
        list<MetadataService.Error> errors = new list<MetadataService.Error>();
        errors.add(error);
        MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
        saveResult.errors = errors;
        saveResult.success = false;*/  
        MetadataSwitchJob job = new MetadataSwitchJob();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, job);
       	//Test.startTest();
        
        MetadataSwitchJob.updateProductMetadata(False);
        MetadataSwitchJob.activateProductMetadata();
        //MetadataSwitchJob.handleSaveResults(saveResult);
        //Test.stopTest();
    }
}