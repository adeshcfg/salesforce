/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PortalCustomerUpdateAPI
 *  @author : A5E Consulting
 *  @date : 30/07/2021
 
 *************************************************************************************************/
@isTest
public class TestPortalCustomerUpdateAPI {
    public static testMethod void oneTimeRequestFundCreationTest(){
        Set<id> customerId = new Set<id>();
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
        Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        customerInstance.FirstName = 'TestAnna';
        update customerInstance;
        customerId.add(customerInstance.Id);
        PortalCustomerUpdateAPI.updateCustomerDetails(customerId);
    }
    

}