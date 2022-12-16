@isTest
public class TestAgencyUserProcessingAPI {
        public static testMethod void testAgencyPortalAPI(){
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
        
     //Placement Record Creation
        Placement__c plcmnt= new Placement__c();       
        plcmnt.Name='89';       
        insert plcmnt;
        
        //agency user Record Creation
        Agency_User__c agusr = new Agency_User__c();       
        agusr.Placement__c = plcmnt.id;
        agusr.Email_Address__c = 'test@gmail.com';
        agusr.Role__c = 'Regular User';       
        insert agusr;
        
        PortalAgencyUserProcessingAPI.processAgencyUser(agusr.Id); 
    }

}