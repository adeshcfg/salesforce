/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of WorkAssignmentTriggerHandler
*  @author : A5E Consulting
*  @date : 08/12/2021
* 
*************************************************************************************************/
@isTest
public class TestWorkAssignmentTriggerHandler {
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Work_Assignment_Trigger__c = True;
        insert config;
        
        Agency_Portal_Settings__c config1 = Agency_Portal_Settings__c.getOrgDefaults();
        config1.Run_WorkAssignment_API_for_Portal__c = True;
        config1.CFGComplaintWorkAssignmentRecordID__c = '0127g000001QgFEAA0';
        insert config1;
    }
    
    //Test Before Insert
    static testMethod void workAssignmentBeforeInsertTest(){
       List<Work_Assignment__c> workAssData = new List<Work_Assignment__c>();
       list<Work_Assignment__c> listInternalNewWorkAssignment = new list<Work_Assignment__c>();
       Map<Id, Work_Assignment__c> mapNewWorkAssignment = New Map<Id, Work_Assignment__c>(); 
       Date dT = System.Today();
        
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
        
        Test.startTest();
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.OwnerId= UserInfo.getUserId();
        prod.Number_Of_Open_Complaint__c = 6;
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prodInfo = new Product__c();
        prodInfo.RecordTypeId=recrdid;
        prodInfo.Name ='123456779';
        prodInfo.Previously_Reviewed_for_Legal_Action__c=True;
        prodInfo.Current_Principal_Balance__c=101;
        prodInfo.Current_Interest_Amount__c=1000;
        //prodInfo.Number_Of_Open_Complaint__c=0;
        prodInfo.Status__c = 'New Allocation - New Allocation';
        prodInfo.Sub_Status__c = 'Ready';
        prodInfo.Product_Status__c = 'Test';
        prodInfo.Funding_Status__c = 'Funded';
        prodInfo.Funding_Type__c = 'Automated';
        prodInfo.Disbursement_Amount__c = 3000.00;
        ProductTriggerHandler.runProductTrigger = False;
        insert prodInfo;
        ProductTriggerHandler.runProductTrigger = True;
        
        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.Number_Of_Open_Complaint__c = 6;
        //accInstance.Legal_Name__c = 'Test';
        //accInstance.Email_Address__pc = 'Test@gmail.com';
        accInstance.Phone_Number__pc = '123' ;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert accInstance;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Account acc = new Account();
        acc.FirstName = 'Anea';
        acc.LastName = 'Starik';
        acc.PersonEmail = 'Test@gmail.com';
        acc.Number_Of_Open_Complaint__c = 5;
        //acc.Legal_Name__c = 'Test';
        //acc.Email_Address__pc = 'Test@gmail.com';
        acc.Phone_Number__pc = '123' ;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert acc;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Judgment__c jud = new  Judgment__c(); 
        jud.Judgment_Number__c = '123';
        jud.Company_Name__c='Testcompant';
        jud.Suit_Amount__c = 100;
        jud.Legal_Agency__c = 'Test';        
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert jud;  
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        Judgment__c jud1 = new  Judgment__c(); 
        jud1.Judgment_Number__c = '122';
        jud1.Company_Name__c='Testcompany';
        jud1.Attorney__c = 'Test'; 
        jud1.Legal_Agency__c = 'Test';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert jud1;  
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        Settlement__c stmt = new  Settlement__c(); 
        stmt.Settlement_Number__c = '12345';
        stmt.Product__c= prod.Id;
        stmt.Proposal_Amount__c= 123;
        stmt.Status__c='New';
        stmt.Employment__c='Yes';
        stmt.Homeowner_Status__c='Yes';
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert stmt;
        SettlementTriggerHandler.runSettlementTrigger = True;
        
        Settlement__c stmt1 = new  Settlement__c(); 
        stmt1.Settlement_Number__c = '12344';
        stmt1.Product__c= Prod.Id;
        stmt1.Proposal_Amount__c= 123;
        stmt1.Status__c='New';
        stmt1.Employment__c='Yes';
        stmt1.Homeowner_Status__c='Yes';
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert stmt1;
        SettlementTriggerHandler.runSettlementTrigger = True;
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='89';
        insert plcgy;
        
        Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Work_Assignment__c workAssData1 = new Work_Assignment__c();
        string recrdid1= [SELECT id from RecordType where sobjecttype='Work_Assignment__c' 
                          AND RecordType.Name='CFG Media'].id;
        workAssData1.Title__c = 'This task for Test class1';
        workAssData1.Description__c = 'This task is for product record';
        workAssData1.Purpose__c = 'Payment';
        workAssData1.Start_Month__c = '08';
        workAssData1.Start_Year__c = '2020';
        workAssData1.End_Month__c = '03';
        workAssData1.End_Year__c = '2021';
        workAssData1.Status__c = 'Requested';
        workAssData1.Assign_To__c = 'CFG';
        workAssData1.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssData1.Product__c = prod.id;
        workAssData1.Placement_Agency__c=plcgy.id;
        workAssData1.Placement_Agency_Identifier__c=plcgy.id;
        workAssData1.Product_Identifier__c = prod.id;
        workAssData1.Customer_Identifier__c = accInstance.id;
        workAssData1.Judgment_Identifier__c = jud.id;
        workAssData1.Settlement_Identifier__c = stmt.id;
        workAssData1.Accept_Assignment__c = True;
        workAssData1.Original_Creditor__c = 'Test data';
        workAssData1.Resolution_By__c = 'Test By User';
        workAssData1.Resolution_Date__c = dT;
        workAssData.add(workAssData1);
        
        //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData1;
        //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        workAssData1.Product__c = Prod.id;
        workAssData1.Placement_Agency__c=plcgy1.id;
        workAssData1.Product_Identifier__c = Prod.id;
        workAssData1.Placement_Agency_Identifier__c=plcgy1.id;
        update workAssData1;
        
        workAssData1.Product__c = Prod.id;
        workAssData1.Placement_Agency__c=plcgy1.id;
        workAssData1.Placement_Agency_Identifier__c = NULL;
        workAssData1.Product_Identifier__c = NULL;
        update workAssData1;
        
        Work_Assignment__c workAssData2 = new Work_Assignment__c();
        workAssData2.Title__c = 'This task for Test class2';
        //workAssData2.Product__c = prodInfo.id;
        workAssData2.Description__c = 'This task is for settlement record';
        workAssData2.Settlement__c = stmt.id;
        workAssData2.Placement_Agency__c=plcgy.id;
        workAssData2.Placement_Agency_Identifier__c=null;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData2;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        workAssData2.Placement_Agency__c=null;
        workAssData2.Settlement__c = stmt1.id;
        update workAssData2;
        
        workAssData2.Settlement__c = stmt1.id;
        workAssData2.Settlement_Identifier__c = NULL;
        update workAssData2;
        
        Work_Assignment__c workAssData3 = new Work_Assignment__c();
        workAssData3.Title__c = 'This task for Test class3';
        //workAssData3.Product__c = prodInfo.id;
        workAssData3.Description__c = 'This task is for Judgment record';
        workAssData3.Judgment__c = jud.id;
        workAssData3.Placement_Agency__c=null;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData3;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        workAssData3.Judgment__c = jud1.id;
        update workAssData3;
        
        workAssData3.Judgment__c = jud1.id;
        workAssData3.Judgment_Identifier__c = NULL;
        update workAssData3;
        
        update workAssData;

        Product__C prod1 = new Product__c();
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod1.Name ='123455555';
        prod1.Previously_Reviewed_for_Legal_Action__c=True;
        prod1.Current_Principal_Balance__c=101;
        prod1.Current_Interest_Amount__c=1000;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Number_Of_Open_Complaint__c = 6;
        prod1.OwnerId= UserInfo.getUserId();
        ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;
        
        Map<ID, Work_Assignment__c> prodMap = new Map<ID, Work_Assignment__c>();
     
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        //accInstance1.Legal_Name__c = 'Test';
        //accInstance1.Email_Address__pc = 'Test@gmail.com';
        accInstance1.Phone_Number__pc = '123' ;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert accInstance1;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Product__C prod2 = new Product__c();
        prod2.Name ='123477777';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Number_Of_Open_Complaint__c = 6;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.OwnerId= UserInfo.getUserId();
        ProductTriggerHandler.runProductTrigger = False;
        insert prod2;
        ProductTriggerHandler.runProductTrigger = True;
        
        Work_Assignment__c workAssData4 = new Work_Assignment__c();
        string recrdid2= [SELECT id from RecordType where sobjecttype='Work_Assignment__c' 
                          AND RecordType.Name='Agency Complaint'].id;
        workAssData4.RecordTypeId=recrdid2;
        workAssData4.Title__c = 'This task for Test class4';
        workAssData4.Description__c = 'This task is description';
        workAssData4.Status__c = 'Request to Reopen';
        workAssData4.Product__c = prod.id;
        //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData4;
        listInternalNewWorkAssignment.add(workAssData4);
        prodMap.put(workAssData4.id, workAssData4);
        //workAssData.add(workAssData4);
      
        Work_Assignment__c workAssData5 = new Work_Assignment__c();
        string recrdid5= [SELECT id from RecordType where sobjecttype='Work_Assignment__c' 
                          AND RecordType.Name='CFG Complaint'].id;
        workAssData5.RecordTypeId=recrdid5;
        workAssData5.Title__c = 'This task for Test class5';
        workAssData5.Description__c = 'This task is description';
        workAssData5.Status__c = 'Request to Reopen';
        workAssData5.Agency_Currently_Has_Account_On_Hold__c = 'Yes';
        workAssData5.Account_Being_CB_Reported_By_Agency__c ='Yes';
        //workAssData5.Customer__c = accInstance1.id;
        //insert workAssData5;
      	//WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True; 
      
        WorkAssignmentTriggerHandler.handleAfterInsert(workAssData);
        WorkAssignmentTriggerHandler.handleAfterUpdate(workAssData,prodMap);
        WorkAssignmentTriggerHandler.handleAfterDelete(workAssData);
       	Test.stopTest();
    }
    
    //Test Before Insert
    static testMethod void workAssignmentAfterInsertTest(){
        List<Work_Assignment__c> workAssData = new List<Work_Assignment__c>();
       list<Work_Assignment__c> listInternalNewWorkAssignment = new list<Work_Assignment__c>();
       Map<Id, Work_Assignment__c> mapNewWorkAssignment = New Map<Id, Work_Assignment__c>(); 
        Date dT = System.Today();
        
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
        
        Test.startTest();
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.OwnerId= UserInfo.getUserId();
        prod.Number_Of_Open_Complaint__c = 6;
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
      
        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.Number_Of_Open_Complaint__c = 6;
        //accInstance.Legal_Name__c = 'Test';
        //accInstance.Email_Address__pc = 'Test@gmail.com';
        accInstance.Phone_Number__pc = '123' ;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert accInstance;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Judgment__c jud = new  Judgment__c(); 
        jud.Judgment_Number__c = '123';
        jud.Company_Name__c='Testcompant';
        jud.Suit_Amount__c = 100;
        jud.Legal_Agency__c = 'Test';        
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert jud;  
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        Judgment__c jud1 = new  Judgment__c(); 
        jud1.Judgment_Number__c = '122';
        jud1.Company_Name__c='Testcompany';
        jud1.Attorney__c = 'Test'; 
        jud1.Legal_Agency__c = 'Test';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert jud1;  
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        Settlement__c stmt = new  Settlement__c(); 
        stmt.Settlement_Number__c = '12345';
        stmt.Product__c= prod.Id;
        stmt.Proposal_Amount__c= 123;
        stmt.Status__c='New';
        stmt.Employment__c='Yes';
        stmt.Homeowner_Status__c='Yes';
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert stmt;
        SettlementTriggerHandler.runSettlementTrigger = True;
        
        Settlement__c stmt1 = new  Settlement__c(); 
        stmt1.Settlement_Number__c = '12344';
        stmt1.Product__c= Prod.Id;
        stmt1.Proposal_Amount__c= 123;
        stmt1.Status__c='New';
        stmt1.Employment__c='Yes';
        stmt1.Homeowner_Status__c='Yes';
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert stmt1;
        SettlementTriggerHandler.runSettlementTrigger = True;
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='89';
        insert plcgy;
        
        Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Work_Assignment__c workAssData1 = new Work_Assignment__c();
        string recrdid1= [SELECT id from RecordType where sobjecttype='Work_Assignment__c' 
                          AND RecordType.Name='CFG Media'].id;
        workAssData1.Title__c = 'This task for Test class1';
        workAssData1.Description__c = 'This task is for product record';
        workAssData1.Purpose__c = 'Payment';
        workAssData1.Start_Month__c = '08';
        workAssData1.Start_Year__c = '2020';
        workAssData1.End_Month__c = '03';
        workAssData1.End_Year__c = '2021';
        workAssData1.Status__c = 'Requested';
        workAssData1.Assign_To__c = 'CFG';
        workAssData1.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssData1.Product__c = prod.id;
        workAssData1.Placement_Agency__c=plcgy.id;
        workAssData1.Placement_Agency_Identifier__c=plcgy.id;
        workAssData1.Product_Identifier__c = prod.id;
        workAssData1.Customer_Identifier__c = accInstance.id;
        workAssData1.Judgment_Identifier__c = jud.id;
        workAssData1.Settlement_Identifier__c = stmt.id;
        workAssData1.Accept_Assignment__c = True;
        workAssData1.Original_Creditor__c = 'Test data';
        workAssData1.Resolution_By__c = 'Test By User';
        workAssData1.Resolution_Date__c = dT;
        workAssData.add(workAssData1);
        
        //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData1;
        //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        workAssData1.Product__c = Prod.id;
        workAssData1.Placement_Agency__c=plcgy1.id;
        workAssData1.Product_Identifier__c = Prod.id;
        workAssData1.Placement_Agency_Identifier__c=plcgy1.id;
        update workAssData1;
        
        workAssData1.Product__c = Prod.id;
        workAssData1.Placement_Agency__c=plcgy1.id;
        workAssData1.Placement_Agency_Identifier__c = NULL;
        workAssData1.Product_Identifier__c = NULL;
        update workAssData1;
            
        Map<ID, Work_Assignment__c> prodMap = new Map<ID, Work_Assignment__c>();
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        //accInstance1.Legal_Name__c = 'Test';
        //accInstance1.Email_Address__pc = 'Test@gmail.com';
        accInstance1.Phone_Number__pc = '123' ;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert accInstance1;
        CustomerTriggerHandler.runCustomerTrigger = True;
      
        Work_Assignment__c workAssData5 = new Work_Assignment__c();
        string recrdid5= [SELECT id from RecordType where sobjecttype='Work_Assignment__c' 
                          AND RecordType.Name='CFG Complaint'].id;
        workAssData5.RecordTypeId=recrdid5;
        workAssData5.Title__c = 'This task for Test class5';
        workAssData5.Description__c = 'This task is description';
        workAssData5.Status__c = 'Request to Reopen';
        workAssData5.Customer__c = accInstance1.id;
        workAssData5.Agency_Currently_Has_Account_On_Hold__c = 'Yes';
        workAssData5.Account_Being_CB_Reported_By_Agency__c = 'Yes';
        insert workAssData5;
        
        workAssData5.Agency_Currently_Has_Account_On_Hold__c = 'No';
        workAssData5.Account_Being_CB_Reported_By_Agency__c = 'No';
        workAssData5.Status__c = 'Request';
        Update workAssData5;
        
        delete workAssData5;
       
   		prodMap.put(workAssData5.id, workAssData5);
        
        WorkAssignmentTriggerHandler.handleAfterInsert(workAssData);
        WorkAssignmentTriggerHandler.handleAfterUpdate(workAssData,prodMap);
        WorkAssignmentTriggerHandler.handleAfterDelete(workAssData);
        
        Test.stopTest();
    }
}