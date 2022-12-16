/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Portal Product Status Bulk API
 *  @author : A5E Consulting
 *  @date : 07/08/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalProductStatusBulkAPI {
    public static testMethod void testProductStatusBulkApi(){
    Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
        insert settings;
        
        String escapeProdlistString;
        String productNames;
        String PlacementStatus; 
        String dataStatus; 
        String datevalue;
        String bulkUpdateType; 
        String placementIdentifier; 
        String poolName;
        set<String> productNamesSet = new set<String>();
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Product_Status__c = 'Test Status';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;
        
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        insert plcmnt;
        
        Data_Status_Mapping__c dataStatusMapping = new Data_Status_Mapping__c();
        dataStatusMapping.Name ='123233';
        dataStatusMapping.Description__c ='Warehouse';
        dataStatusMapping.Description1__c ='Description1 Allocation';
        dataStatusMapping.Description2__c ='Description2 Allocation';
        insert dataStatusMapping;
        
        PortalProductStatusBulkAPI.processBulkProducts(productNames,PlacementStatus,dataStatus,datevalue,bulkUpdateType,placementIdentifier,poolName);
        PortalProductStatusBulkAPI.processBulkProductsForPagination(productNamesSet,PlacementStatus,dataStatus,datevalue,bulkUpdateType,placementIdentifier,poolName);
    }
}