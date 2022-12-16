/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of DocumentStorageTriggerHandler
 *  @author : A5E Consulting
 *  @date : 28/01/2022
 * 
 *************************************************************************************************/
@isTest
public class TestDocumentStorageTriggerHandler {
    
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Document_Storage_Trigger__c = True;
        insert config;
    }
    
    //Test Before update
    static testMethod void documentStorageApiTest(){
        String documentID;
        String placement;
        ID documentStorageID;
        String documentType;
        String documentURL;
        
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        config.Run_Doc_Storage_Update_API_for_Portal__c = True;
        insert config;
        

        
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
        
        List<Document_Storage__c> docSto = new List<Document_Storage__c>();
         
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        Product__c prod = new Product__c();
        prod.Collection_Sub_Status__c = 'Legal';
        prod.Originating_Creditor__c = 'MBNA';
        prod.Name = '1566P430';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        Judgment__c judgmetInstance= new Judgment__c();
        string recrdid=[SELECT id from RecordType where sobjecttype='Judgment__c' AND RecordType.Name='Judgment'].id;
        judgmetInstance.RecordTypeId=recrdid;
        judgmetInstance.Legal_Status__c='Post-Judgment';
        judgmetInstance.Legal_Sub_Status__c='Dormant';
        judgmetInstance.Legal_Agency__c ='6';
        judgmetInstance.Agency_Initiated_Legal_Action__c ='68';
        judgmetInstance.Collection_Agency_Identifier__c = '68';
        judgmetInstance.Judgment_Number__c = '4567';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert judgmetInstance;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        Settlement__c settlementInst = new Settlement__c();
        settlementInst.Judgment__c = judgmetInstance.Id;
        settlementInst.Settlement_Number__c = '12345';
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert settlementInst;
        SettlementTriggerHandler.runSettlementTrigger = True;
        
        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        insert place;
        
        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        //accInstance.SF_ID__c = 'SFID0379201';
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert accInstance;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        
      //  list<Document_Storage__c> docList = new list<Document_Storage__c>();
        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Product__c = prod.Id;
        docSto1.Product_Identifier__c = prod.Name;
        docSto1.Judgment__c = judgmetInstance.Id;
        docSto1.Judgment_Identifier__c = judgmetInstance.Judgment_Number__c;
        docSto1.Customer__c = accInstance.Id;
        //docSto1.Customer_Identifier__c = SF_ID__c;
        docSto1.Placement_Agency__c = place.Id;
        docSto1.Placement_Identifier__c = place.Name;
        docSto1.Settlement__c = settlementInst.Id;
        docSto1.Settlement_Identifier__c = settlementInst.Settlement_Number__c;
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        docSto.add(docSto1);
        insert docSto;
        
        
        Document_Storage__c docSto2 = new Document_Storage__c();
        docSto2.Document_Related_To__c = 'Task';
        docSto2.Uploaded_By__c = 'Internal User';
        docSto2.Visibility__c = 'Authoring agencies + CFG';
        docSto2.Document_Extension__c = 'Pdf';
        insert docSto2;


        //DocumentStorageTriggerHandler.getDocStrorageRelatedAgencyData(docSto);
         DocumentStorageTriggerHandler.exceltoJSONService( documentID,  placement,  documentStorageID,  documentType,  documentURL);
        DocumentStorageTriggerHandler.handleBeforeInsert(docSto);
        
     }
    
    //Test for Allocation 
    static testMethod void documnetStorageAllocationTest(){
        List<Document_Storage__c> docSto = new List<Document_Storage__c>();
         
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Product Allocation';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        Product__c prod = new Product__c();
        prod.Collection_Sub_Status__c = '';
        prod.Originating_Creditor__c = 'MBNA';
        prod.Name = '1566P430';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;

        Product__c prod1 = new Product__c();
        prod1.Collection_Sub_Status__c = '';
        prod1.Originating_Creditor__c = 'MBNA';
        prod1.Name = '1566P431';
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;

        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        insert place;
        
        //  list<Document_Storage__c> docList = new list<Document_Storage__c>();
        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
         
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'CFG Only';
        docSto1.Document_Extension__c = 'csv';
        docSto.add(docSto1);
        insert docSto;
        
        Pool__c pool = new Pool__c();
        insert pool;
       String poolName = pool.Name;     
        
        String csvFile='Data_Id__c,Placement_Agency__c,Pool_Name__c,Current_Commission_Rate__c,Placed_Commission_Rate__c,Current_Settlement_Rate__c,Placed_Settlement_Rate__c,Value_Tier_at_Time_of_Placement__c\n';
    csvFile += '1566P430,68,PO-00510,67,67,99,99,D\n';
    csvFile += '1566P431,68,PO-00510,67,67,99,99,C\n';

        Attachment attacAlloc = new Attachment();
        attacAlloc.parentid = docSto1.Id;
        attacAlloc.name = 'Allocation file.csv';
        attacAlloc.Body = Blob.valueOf('Data_Id__c,Placement_Agency__c,Pool_Name__c,Current_Commission_Rate__c,Placed_Commission_Rate__c,Current_Settlement_Rate__c,Placed_Settlement_Rate__c,Value_Tier_at_Time_of_Placement__c');
        insert attacAlloc;
        attacAlloc = [select id, name, body from attachment where parentId = :docSto1.Id];
        String allocatedData = (attacAlloc.body).toString();
        allocatedData += '\n';
        allocatedData += '1566P430,68,'+ poolName +',67,67,99,99,D\n';
        allocatedData += '1566P431,68,'+ poolName +',67,67,99,99,C\n';
        attacAlloc.body = Blob.valueof(allocatedData);
        update attacAlloc;
        
        //Create Content Version
        ContentVersion Conver = new ContentVersion();
        Conver.ContentLocation = 'S';
        Conver.VersionData = Blob.valueof(allocatedData);
        Conver.Title = 'Allocation';
        Conver.PathOnClient= 'Allocation file.csv';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
        
        //ContentDocumentLink record Creation
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = docSto1.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;

        String documentID =docSto1.Document_Id__c;
        String placement ='';
        ID documentStorageID=docSto1.Id;
        String documentType='';
        String documentURL='';
        
        Test.setMock(HttpCalloutMock.class, new BulkAPIMockResponse());
        
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
        
        Test.startTest();
        DocumentStorageTriggerHandler.processProductAllocation(documentID, placement, documentStorageID, documentType, documentURL);
        Test.stopTest();
    }
    
}