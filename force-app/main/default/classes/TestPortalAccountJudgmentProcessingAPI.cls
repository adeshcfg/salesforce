/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Account Judgment API (PortalAccountJudgmentProcessingAPI)
 *  @author : A5E Consulting
 *  @date : 24/01/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalAccountJudgmentProcessingAPI {
    public static testMethod void testAccountJudgmentAPI(){
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
        
        //Product Record Creation
        Product__c prod=new Product__C();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        INSERT prod;
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        String recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        INSERT accjudg;
        Utilities.runAccountJudgmentTrigger = True;
        accjudg.Status__c='InActive';
        update accjudg; 
        
        PortalAccountJudgmentProcessingAPI.processAccountJudgment(accjudg.Id); 
    }
    

}