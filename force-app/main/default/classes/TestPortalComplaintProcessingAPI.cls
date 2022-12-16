/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Work Assignment Complaint API (TestPortalComplaintProcessingAPI)
 *  @author : A5E Consulting
 *  @date : 25/02/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalComplaintProcessingAPI {
    public static testMethod void testComplaintApi(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        String escapeProdlistString ;
        
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
        
        Account Acc = new Account();      
        Acc.Name='Testcust';
        Acc.Broker_Name__c='Testbroker'; 
        insert Acc;
        
        Judgment__c jud = new  Judgment__c();      
        jud.Company_Name__c='Testcompant';
        jud.Legal_Agency__c = 'Test Agency';
        insert jud;
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='89';
        insert plcgy;
        
        Product__C prod = new Product__c();
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
        
        Settlement__c stmt = new  Settlement__c();      
        stmt.Product__c= prod.Id;
        stmt.Proposal_Amount__c= 123;
        stmt.Status__c='New';
        stmt.Employment__c='Yes';
        stmt.Homeowner_Status__c='Yes';
        insert stmt;
        
        
        Work_Assignment__c workAgt = new Work_Assignment__c();       
        //workAgt.Title__c = 'Test';
        workAgt.Description__c = 'test';
        workAgt.Products_List__c = 'test';
        workAgt.Status__c = 'Requested';
       // workAgt.Complaint_Type__c = 'Ministry';
       // workAgt.Root_Cause__c = 'Verbal';
        workAgt.Original_Creditor__c = 'Test';
        workAgt.Product__c= prod.id;
        // workAgt.Settlement__c =stmt.id;
        workAgt.Placement_Agency__c= plcgy.id;
        // workAgt.Judgment__c= jud.id;
        //workAgt.Customer__c = Acc.id;
        insert workAgt;
        
        PortalComplaintProcessingAPI.processComplaint(workAgt.Id,'Abc','testing'); 
    }

}