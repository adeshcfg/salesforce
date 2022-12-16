/**************************************************************************************************
*
*  Class:   
*
*  @description : TestDirectPaymentNotificationBatch
*  @author : A5E Consulting
*  @date : 19/07/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestDirectPaymentNotificationBatch {
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
        plcgy.Name='68';
        plcgy.Agency_Name__c = 'CFG';
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
        workAssignment.Placement_Agency_Identifier__c=plcgy.Name;
        workAssignment.Placement_Agency__c=plcgy.id;
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
        workAssignment2.Placement_Agency_Identifier__c=plcgy.Name;
        workAssignment2.Placement_Agency__c=plcgy.id;
        workAssignment2.Notification_Type__c = 'Recalled Account';
        workAssignment2.Total_Amount_of_Payments__c =100;
        
        Work_Assignment__c workAssignment3 =  new Work_Assignment__c ();
        workAssignment3.Title__c = 'This task for Test class1';
        workAssignment3.Description__c = 'This task is for product record1';
        workAssignment3.Purpose__c = 'Payment';
        workAssignment3.Start_Month__c = '08';
        workAssignment3.Start_Year__c = '2020';
        workAssignment3.End_Month__c = '03';
        workAssignment3.End_Year__c = '2021';
        workAssignment3.Status__c = 'Requested';
        workAssignment3.Assign_To__c = 'CFG';
        workAssignment3.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssignment3.Placement_Agency_Identifier__c=plcgy.Name;
        workAssignment3.Placement_Agency__c=plcgy.id;
        workAssignment3.Notification_Type__c = 'Transactions';
        workAssignment3.Total_Amount_of_Payments__c =100;
        
        Work_Assignment__c workAssignment4 =  new Work_Assignment__c ();
        workAssignment4.Title__c = 'This task for Test class1';
        workAssignment4.Description__c = 'This task is for product record1';
        workAssignment4.Purpose__c = 'Payment';
        workAssignment4.Start_Month__c = '08';
        workAssignment4.Start_Year__c = '2020';
        workAssignment4.End_Month__c = '03';
        workAssignment4.End_Year__c = '2021';
        workAssignment4.Status__c = 'Requested';
        workAssignment4.Assign_To__c = 'CFG';
        workAssignment4.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssignment4.Placement_Agency_Identifier__c=plcgy.Name;
        workAssignment4.Placement_Agency__c=plcgy.id;
        workAssignment4.Notification_Type__c = 'Account Update';
        workAssignment4.Total_Amount_of_Payments__c =100;
		
        Work_Assignment__c workAssignment5 =  new Work_Assignment__c ();
        workAssignment5.Title__c = 'This task for Test class1';
        workAssignment5.Description__c = 'This task is for product record1';
        workAssignment5.Purpose__c = 'Payment';
        workAssignment5.Start_Month__c = '08';
        workAssignment5.Start_Year__c = '2020';
        workAssignment5.End_Month__c = '03';
        workAssignment5.End_Year__c = '2021';
        workAssignment5.Status__c = 'Requested';
        workAssignment5.Assign_To__c = 'CFG';
        workAssignment5.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssignment5.Placement_Agency_Identifier__c=plcgy.Name;
        workAssignment5.Placement_Agency__c=plcgy.id;
        workAssignment5.Notification_Type__c = 'Account Status Update';
        workAssignment5.Total_Amount_of_Payments__c =100;
        
        ListworkAssignment.add(workAssignment);
        ListworkAssignment.add(workAssignment2);
        ListworkAssignment.add(workAssignment3);
        ListworkAssignment.add(workAssignment4);
        ListworkAssignment.add(workAssignment5);
        Insert ListworkAssignment;
        
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
		NotificationSuccessMessages__c setting4 = new NotificationSuccessMessages__c();
        setting4.Name = 'Account Status Updated';
        setting4.Title__c = 'Agency_name Agency_number';
        setting4.NotificationMessage__c = 'Test'; 
        insert setting4;

        Test.StartTest();
		CallToNotificationApi instancevar = new CallToNotificationApi();
		Database.executeBatch(instancevar);
		Test.StopTest();
        
       
    }

}