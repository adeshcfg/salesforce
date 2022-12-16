@isTest
public class TestAgencyUserTriggerHandler {
    
    
    public Static testMethod void testAgencyHandler(){
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
        
        Placement__c placemntInst1 = new Placement__c(); 
        placemntInst1.Name = '11';
        placemntInst1.Agency_Name__c = 'ABC';
        insert placemntInst1; 
        
        List<Agency_User__c> agncyUserData = new List<Agency_User__c>();
        Agency_User__c agusr = new Agency_User__c();
        agusr.Email_Address__c = 'Test@gail.com';
        agusr.Role__c = 'Regular User';
        agusr.First_Name__c = 'Test';
        agusr.Last_Name__c = 'User';
        agusr.Placement__c = placemntInst1.Id;
        agusr.Placement_Identifier__c = placemntInst1.Id;
        agncyUserData.add(agusr);
        insert agncyUserData;
 
        Placement__c placemntInst2 = new Placement__c(); 
        placemntInst2.Name = '68';
        placemntInst2.Agency_Name__c = 'XYZ';
        insert placemntInst2; 
        
        agusr.Last_Name__c = 'User1';
        agusr.Placement__c = placemntInst2.Id;
        update agncyUserData;
        
       
       // AgencyUserTriggerHandler.getagencyUserRelatedAgencyData(agncyUserData);
        
        
      
        
    }     
    
}