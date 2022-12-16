/**************************************************************************************************
*
*  Class: SendDirectPaymentDocumentToPortalBatch   
*  @description : TestSendPmntDocPortalBatch
*  @author : A5E Consulting
*  @date : 07/08/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestSendPmntDocPortalBatch {
    static testMethod void insertTestData(){
        
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
        
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='101'; 
        plcgy.Agency_Email__c = 'test@gmail.com';
        insert plcgy;        
        
         List<Work_Assignment__c> ListworkAssignment = new List<Work_Assignment__c>();
        Work_Assignment__c workAssignment =  new Work_Assignment__c ();
        workAssignment.Title__c = 'This task for Test class';
        workAssignment.Description__c = 'This task is for product record';
        workAssignment.Purpose__c = 'Payment';
        workAssignment.Start_Month__c = '08';
        workAssignment.Start_Year__c = '2020';
        workAssignment.End_Month__c = '03';
        workAssignment.End_Year__c = '2021';
        workAssignment.Status__c = 'Requested';
        workAssignment.Assign_To__c = 'CFG';
        workAssignment.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssignment.Placement_Agency_Identifier__c=plcgy.id;
        workAssignment.Notification_Type__c = 'Direct Payment';
        workAssignment.Total_Amount_of_Payments__c =100;
        
        Work_Assignment__c workAssignment2 =  new Work_Assignment__c ();
        workAssignment2.Title__c = 'This task for Test class1';
        workAssignment2.Description__c = 'This task is for product record1';
        workAssignment2.Purpose__c = 'Payment';
        workAssignment2.Start_Month__c = '08';
        workAssignment2.Start_Year__c = '2020';
        workAssignment2.End_Month__c = '03';
        workAssignment2.End_Year__c = '2021';
        workAssignment2.Status__c = 'Requested';
        workAssignment2.Assign_To__c = 'CFG';
        workAssignment2.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssignment2.Placement_Agency_Identifier__c=plcgy.id;
        workAssignment2.Notification_Type__c = 'Recalled Account';
        workAssignment2.Total_Amount_of_Payments__c =100;

        ListworkAssignment.add(workAssignment);
        ListworkAssignment.add(workAssignment2);
        Insert ListworkAssignment;
        
        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        //docSto1.Work_Assignment__c = wrkAss.Id;
        //docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        //docSto1.Product__c = prod.Id;
        //docSto1.Product_Identifier__c = prod.Name;
        //docSto1.Judgment__c = judgmetInstance.Id;
        //docSto1.Judgment_Identifier__c = judgmetInstance.Judgment_Number__c;
       //docSto1.Customer__c = accInstance.Id;
        //docSto1.Customer_Identifier__c = SF_ID__c;
        //docSto1.Placement_Agency__c = place.Id;
        //docSto1.Placement_Identifier__c = place.Name;
        //docSto1.Settlement__c = settlementInst.Id;
        //docSto1.Settlement_Identifier__c = settlementInst.Settlement_Number__c;
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        docSto1.payment_type__c = 'Direct Payment';
        insert docSto1;

        NotificationSuccessMessages__c setting = new NotificationSuccessMessages__c();
        setting.Name = 'Account Updated';
        setting.Title__c = 'Agency_name Agency_number';
        setting.NotificationMessage__c = 'Test'; 
        insert setting;
        NotificationSuccessMessages__c setting2 = new NotificationSuccessMessages__c();
        setting2.Name = 'Direct Payment Notification';
        setting2.Title__c = 'Agency_name Agency_number';
        setting2.NotificationMessage__c = 'Test'; 
        insert setting2;
        NotificationSuccessMessages__c setting3 = new NotificationSuccessMessages__c();
        setting3.Name = 'Recalled Account';
        setting3.Title__c = 'Agency_name Agency_number';
        setting3.NotificationMessage__c = 'Test'; 
        insert setting3;


        Test.StartTest();
		SendDirectPaymentDocumentToPortalBatch instancevar = new SendDirectPaymentDocumentToPortalBatch();
		Database.executeBatch(instancevar);
		Test.StopTest();
        
       
    }
}