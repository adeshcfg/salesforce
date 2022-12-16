/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of DistressedNotesTriggerHandler
*  @author : A5E Consulting
*  @date : 14/02/2022
* 
*************************************************************************************************/
@isTest
public class TestDistressedNotesTriggerHandler {
    
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Distressed_Notes_Trigger__c = true;
        insert config;
        system.debug('config...>'+config);
     
    }
    
    static testMethod void distressedNotesApiTest(){
        
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
        
        List<Distressed_notes__c> distNotes = new List<Distressed_notes__c>();
        List<Distressed_notes__c> distNotes1 = new List<Distressed_notes__c>();
        List<Distressed_notes__c> distNotes2 = new List<Distressed_notes__c>();
        List<Distressed_notes__c> distNotes3 = new List<Distressed_notes__c>();
        Map<Id, Distressed_notes__c> mapOldDistressed = New Map<Id, Distressed_notes__c>();
        Map<Id, Distressed_notes__c> mapOldDistressed1 = New Map<Id, Distressed_notes__c>();
        
        
        
        Account Acc = new Account();      
        Acc.Name='Testcust';
        Acc.Broker_Name__c='Testbroker';
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert Acc;
        CustomerTriggerHandler.runCustomerTrigger = True;
       
        
        Product__C prod = new Product__c();
        prod.Collection_Sub_Status__c = 'Legal';
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        Judgment__c jud= new Judgment__c();
        string recrdid=[SELECT id from RecordType where sobjecttype='Judgment__c' AND RecordType.Name='Judgment'].id;
        jud.RecordTypeId=recrdid;
        jud.Legal_Status__c='Post-Judgment';
        jud.Legal_Sub_Status__c='Dormant';
        jud.Product_1__c = prod.Id;
        jud.Legal_Agency__c ='6';
        jud.Agency_Initiated_Legal_Action__c ='68';
        jud.Collection_Agency_Identifier__c = '68';
        jud.Judgment_Number__c = '4567';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert jud;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
       
 
        Settlement__c settlementInst = new Settlement__c();
        settlementInst.Settlement_Number__c = '12345';
        settlementInst.Product__c= prod.Id;
        settlementInst.Proposal_Amount__c= 123;
        settlementInst.Status__c='New';
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert settlementInst;
        SettlementTriggerHandler.runSettlementTrigger = True;
        
        Distressed_notes__c distressedNotes = new Distressed_notes__c();
        distressedNotes.Title__c = 'Test';
        distressedNotes.Product__c = prod.Id;
        distressedNotes.Product_Identifier__c = prod.Name;
        distressedNotes.Judgment__c = jud.Id;
        distressedNotes.Judgment_Identifier__c = jud.Judgment_Number__c;
        distressedNotes.Customer__c = Acc.Id;
       // distressedNotes.Customer_Identifier__c = SF_ID__c; 
        distressedNotes.Settlement__c = settlementInst.Id;
        distressedNotes.Settlement_Identifier__c = settlementInst.Settlement_Number__c;
        distressedNotes.Body__c = 'Test Body';
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = False;
        insert distressedNotes;
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = True;
          
        distNotes.add(distressedNotes);
        distNotes3.add(distressedNotes);
        mapOldDistressed.put(distressedNotes.id, distressedNotes);
        
        distressedNotes.Title__c = 'Test';
        distressedNotes.Body__c = 'Test Body';
        update distressedNotes;
        
        Distressed_notes__c distressedNotes1 = new Distressed_notes__c();
        distressedNotes1.Title__c = 'Test';
        distressedNotes1.Body__c = 'Test Body';
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = False;
        insert distressedNotes1;
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = True;
        distNotes1.add(distressedNotes1);
       
        mapOldDistressed1.put(distressedNotes1.id, distressedNotes1);
        
        DistressedNotesTriggerHandler.handleBeforeInsert(distNotes1);
        DistressedNotesTriggerHandler.handleBeforeUpdate(distNotes1,mapOldDistressed1);
        DistressedNotesTriggerHandler.getDistressedNotesRelatedData(distNotes3);

    }
     public static void TestAfterInsertUpdate(){ 
       // List<Distressed_notes__c> distNotes = new List<Distressed_notes__c>();
        List<Distressed_notes__c> distNotes1 = new List<Distressed_notes__c>();
       // Map<Id, Distressed_notes__c> mapOldDistressed = New Map<Id, Distressed_notes__c>();
        Map<Id, Distressed_notes__c> mapOldDistressed1 = New Map<Id, Distressed_notes__c>();
         
         
        Distressed_notes__c distressedNotes1 = new Distressed_notes__c();
        distressedNotes1.Title__c = 'Test';
        distressedNotes1.Body__c = 'Test Body';
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = False;
        insert distressedNotes1;
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = True;
        distNotes1.add(distressedNotes1);
        
        mapOldDistressed1.put(distressedNotes1.id, distressedNotes1); 
         
        DistressedNotesTriggerHandler.handleAfterInsert(distNotes1);
         
      
     }
    
}