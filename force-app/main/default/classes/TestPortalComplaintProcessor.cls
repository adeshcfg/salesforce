/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Complaint Work Assignment Processor & Util
                   (TestPortalComplaintProcessingAPI & PortalComplaintProcessorUtil)
 *  @author : A5E Consulting
 *  @date : 25/02/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalComplaintProcessor {
    public static testMethod void testComplaint(){
        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Name":"Test", "Task_Number": "TC-111",'+
            '"Created_By": "TestABC","Resolution_Date": "2022-01-03","Date_Complaint_Received_By_Agency": "2022-01-03","Is_Multiple_Products__c": "True","Last_Modified_By": "test",'+ 
            '"Description": "testdescription","Comment_Reply": "testcomment","Comments_History__c": "testhistorycomment","Root_Cause": "Alleging Contacting Wrong Consumer","Requested_Date": "2022-01-03","Next_follow_up_date": "2022-01-03","Due_Date": "2022-01-03","Original_Creditor":"testdescription","Placement_Agency_Identifier":null,"Settlement_Identifier__c":null}';      
       
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalComplaintProcessor.postComplaint();
    }
    
    public static testMethod void testPortalComplaintProcessorUtil(){  
        
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
        workAgt.Purpose__c = 'Payment';
        workAgt.Status__c = 'Requested';
       // workAgt.Complaint_Type__c = 'Ministry';
        //workAgt.Root_Cause__c = 'Verbal';
        workAgt.Original_Creditor__c = 'Test';
        workAgt.Product__c= prod.id;
        // workAgt.Settlement__c =stmt.id;
        workAgt.Placement_Agency__c= plcgy.id;
        // workAgt.Judgment__c= jud.id;
        // workAgt.Customer__c = Acc.id;
       
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert workAgt;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
        
      List<Work_Assignment__c> Workassign = new list <Work_Assignment__c>();
      Workassign.add(workAgt);
        
     
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Name', 'Test');
        paramMap.put('Task_Number','TC-111');
        paramMap.put('Created_By','TestABC');
        paramMap.put('Last_Modified_By','test');
        paramMap.put('Description','testdescription');
        paramMap.put('Comment_Reply','testcomment');
        paramMap.put('Complaint_Type','testdescription');
        paramMap.put('Root_Cause','Alleging Contacting Wrong Consumer');
        paramMap.put('Original_Creditor','testdescription');
        paramMap.put('Is_Multiple_Products','True');
        paramMap.put('Placement_Agency_Identifier', null);
        paramMap.put('Requested_Date','2022-01-03');
        paramMap.put('Next_follow_up_date','2022-01-03');
        paramMap.put('Due_Date','2022-01-03');
        paramMap.put('Resolution_Date','2022-01-03');
        paramMap.put('Date_Complaint_Received_By_Agency','2022-01-03');
        paramMap.put('Assign_To_Agency_User','XYZ');
        
       
        PortalComplaintProcessorUtil.processComplaint(paramMap, workAgt);
        PortalComplaintProcessorUtil.getComplaintCountAgency( Workassign);
    }

}