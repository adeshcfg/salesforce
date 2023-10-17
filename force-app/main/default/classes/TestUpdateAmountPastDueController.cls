@isTest
public class TestUpdateAmountPastDueController {
    public static testMethod void TestProduct(){ 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Fidem Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        
        insert settings;
        
    	Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'TestName';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.Outbound_API_Request_Body__c = 'Testing';
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prodInstance;
        
        ApexPages.currentPage().getParameters().put('id', prodInstance.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(prodInstance);
        UpdateAmountPastDueController controller1 = new UpdateAmountPastDueController(sc);
    }
}