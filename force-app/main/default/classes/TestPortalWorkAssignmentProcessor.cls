@isTest
public class TestPortalWorkAssignmentProcessor {
    public static testMethod void testPortalWorkAssignment(){        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Name":"Test", "Task_Number": "TC-111",'+
            '"Created_By": "TestABC","Application": "True","Statements": "True","Cardholder_Agreement": "True","Check_Copy": "True","PPSA_Registration": "True","Drivers_License": "True","Repossession_And_Auction_Documents": "True","Note_Lines": "True","Other": "True","Last_Modified_By": "test",'+
            '"Description": "testdescription","Purpose": "testpurpose","Requested_Date": "2022-01-03","Due_Date": "2022-01-03","Placement_Agency_Identifier":null}';      
        
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalWorkAssignmentProcessor.postAssignment();
    }
    
    public static testMethod void testPortalWorkAssignmentProcessorUtil(){  
      // list<Work_Assignment__c> WorkAssign = new  list<Work_Assignment__c>();
             
        Account Acc = new Account();      
        Acc.Name='Testcust';
        Acc.Broker_Name__c='Testbroker'; 
        insert Acc;
        
        /*Judgment__c jud = new  Judgment__c();      
        jud.Company_Name__c='Testcompant';
        insert jud;*/
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='89';
        insert plcgy;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;
        
        Settlement__c stmt = new  Settlement__c();      
        stmt.Product__c= prod.Id;
        stmt.Proposal_Amount__c= 123;
        stmt.Status__c='New';
        stmt.Employment__c='Yes';
        stmt.Homeowner_Status__c='Yes';
        insert stmt;
        
        
        Work_Assignment__c workAgt = new Work_Assignment__c();       
        workAgt.Title__c = 'Test';
        workAgt.Description__c = 'test';
        workAgt.Purpose__c = 'Payment';
        workAgt.Sub_Purpose__c = 'Media';
        workAgt.Priority__c = 'Medium';
        workAgt.Other_Media_Request__c = 'Other';
        workAgt.Comment_Reply__c = 'Comment';    
        workAgt.Status__c = 'Requested';
        workAgt.Product__c= prod.id;
        workAgt.Original_Creditor__c = 'Test Data';
        // workAgt.Settlement__c =stmt.id;
        workAgt.Placement_Agency__c= plcgy.id;
        // workAgt.Judgment__c= jud.id;
        // workAgt.Customer__c = Acc.id;
        
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert workAgt;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
       // WorkAssign.add(workAgt);
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Name', 'Test');
        paramMap.put('Task_Number','TC-111');
        paramMap.put('Created_By','TestABC');
        paramMap.put('Last_Modified_By','test');
        paramMap.put('Description','testdescription');
        paramMap.put('Purpose','testpurpose');
        paramMap.put('Sub_Purpose','Media');
        paramMap.put('Priority','Medium');
        paramMap.put('Other_Media_Request__c','Other');
        paramMap.put('Comment_Reply__c','Comment');
        paramMap.put('Placement_Agency_Identifier', null);
        paramMap.put('Application', 'True');
        paramMap.put('Statements', 'True');
        paramMap.put('Cardholder_Agreement', 'True');
        paramMap.put('Check_Copy', 'True');
        //paramMap.put('PPSA_Registration', 'True');
        paramMap.put('Drivers_License', 'True');
        paramMap.put('Repossession_And_Auction_Documents', 'True');
        paramMap.put('Note_Lines', 'True');
        paramMap.put('Other', 'True');
        paramMap.put('Requested_Date', '2022-01-03');
        paramMap.put('Due_Date', '2022-01-03');
        PortalWorkAssignmentProcessorUtil.processWorkAssignment(paramMap, workAgt);
       // PortalWorkAssignmentProcessorUtil.getWorkAssignRelatedAgencyData(WorkAssign);
    }

}