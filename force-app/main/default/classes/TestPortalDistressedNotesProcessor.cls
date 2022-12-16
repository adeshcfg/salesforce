/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PortalDistressedNotesProcessor and PortalDistressedNotesProcessorUtil
 *  @author : A5E Consulting
 *  @date : 14/02/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalDistressedNotesProcessor {
    public static testMethod void testDistressedNotes(){        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Name":"DN-0869265", "Title": "11",'+
            '"Created_By": "TestABC","Notes_Date__c": "2022-01-03","Hist_Completed__c": "2022-01-03","Hist_Due__c": "2022-01-03","Last_Modified_By": "test",'+
            '"Notes_History": "testhistory","Customer_Identifier": "null","Product_Identifier":null}';      
        
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalDistressedNotesProcessor.postAssignment();
    }
    
    public static testMethod void testPortalDistressedNotesUtil(){  
        
        Account Acc = new Account();      
        Acc.Name='Testcust';
        Acc.Broker_Name__c='Testbroker'; 
        insert Acc;
        
        Judgment__c jud = new  Judgment__c();      
        jud.Company_Name__c='Testcompant';
        jud.Legal_Agency__c = 'Test Agency';
        insert jud;
        
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
        
        Settlement__c settle = new  Settlement__c();      
        settle.Product__c= prod.Id;
        settle.Proposal_Amount__c= 123;
        settle.Status__c='New';
        settle.Employment__c='Yes';
        settle.Homeowner_Status__c='Yes';
        insert settle;
        
        
        Distressed_notes__c distressedNotes = new Distressed_notes__c();       
        distressedNotes.Title__c = 'Test';
        
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = false;
        insert distressedNotes;
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = true;
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Name', 'DN-0869265');
        paramMap.put('Title','11');
        paramMap.put('Created_By','TestABC');
        paramMap.put('Last_Modified_By','test');
        paramMap.put('Notes_History','testhistory');
        paramMap.put('Customer_Identifier',null);
        paramMap.put('Product_Identifier', null);
        paramMap.put('Notes_Date', '2022-01-03');
        paramMap.put('Hist_Completed', '2022-01-03');
        paramMap.put('Hist_Due', '2022-01-03');
        
        PortalDistressedNotesProcessorUtil.processDistressedNotes(paramMap, distressedNotes);
    }

}