/**************************************************************************************************
 *
 *  Class:   
 *  @description : TestPortalNotificationAPI
 *  @author : A5E Consulting
 *  @date : 21/07/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalNotificationAPI {
     @testSetup
     public static void testNotificationApi(){      
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
        plcgy.Name='89';
        insert plcgy; 
             
        Work_Assignment__c workAgt = new Work_Assignment__c();       
        workAgt.Task_Number__c = 'TC-013392';
        workAgt.Description__c = 'test';
        workAgt.Notification_Type__c = 'Direct Payment';
        workAgt.Status__c = 'Requested';
        workAgt.Original_Creditor__c = 'Test';
        workAgt.Placement_Agency_Identifier__c = plcgy.id;
        insert workAgt;
         
       /* Placement__c plcgy = new  Placement__c();      
        plcgy.Name='89';
        insert plcgy; */
         
	}  
	public static testMethod void testNotificationApi1(){
		String placeId ;
        String Type;
        String Title;
        String TaskNumber;
        String Message; 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Work_Assignment__c workAssignment = [SELECT ID, Placement_Agency_Identifier__c, Placement_Agency_Name__c,
                                             Total_Amount_of_Payments__c 
                                             FROM Work_Assignment__c
                                             LIMIT 1][0];
        Title = 'Direct Payment Notification for Placement '+workAssignment.Placement_Agency_Identifier__c 
                	+ ' (' + workAssignment.Placement_Agency_Name__c + ')';
        Message = '$'+workAssignment.Total_Amount_of_Payments__c + ' Amount received in Direct Payment';
       
        PortalNotificationAPI.sendPaymentNotification(placeId,Type,Title,TaskNumber,Message);
     }
}