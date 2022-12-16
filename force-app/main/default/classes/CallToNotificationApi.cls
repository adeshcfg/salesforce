/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to send Notifications for Direct Payments to Portal
 *  @author : A5E Consulting
 *  @date : 08/07/2022
 
 *************************************************************************************************/
public class CallToNotificationApi implements Database.Batchable<sObject>, Database.AllowsCallouts {
	public NotificationSuccessMessages__c notificationMessage;
    public string TRANSACTIONS = 'Transactions';
    public string ACCOUNT_UPDATES = 'Account Update';
    public string ACCOUNT_STATUS_UPDATES = 'Account Status Update';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        //Get work assignments created today with Notifictaion Type = Direct Payment
        return Database.getQueryLocator(
            [SELECT ID, Notification_Message__c, Notification_Type__c, Placement_Agency_Name__c,Task_Number__c,
             		Placement_Agency_Identifier__c, Total_Amount_of_Payments__c
             FROM Work_Assignment__c 
             WHERE CreatedDate = TODAY 
             AND ( Notification_Type__c = :TRANSACTIONS 
                  OR Notification_Type__c = :ACCOUNT_UPDATES
                 OR Notification_Type__c = :ACCOUNT_STATUS_UPDATES)
             ORDER BY Task_Number__c]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Work_Assignment__c> listWorkAssignments){
        //system.debug('listWorkAssignments::'+listWorkAssignments);
        String Title = '';
        String Message = '';
        String Type = '';
        for(Work_Assignment__c workAssignment : listWorkAssignments){
            if(workAssignment.Notification_Type__c == TRANSACTIONS) {
                notificationMessage = NotificationSuccessMessages__c.getInstance('Direct Payment Notification');
                system.debug('notificationMessage::'+notificationMessage);
                system.debug('notificationMessage.Title__c::'+notificationMessage.Title__c);
                system.debug('workAssignment.Placement_Agency_Identifier__c::'+workAssignment.Placement_Agency_Identifier__c);
                system.debug('workAssignment.Placement_Agency_Name__c::'+workAssignment.Placement_Agency_Name__c);
                if(workAssignment.Placement_Agency_Identifier__c != null && workAssignment.Placement_Agency_Name__c != null){
                	//Title = notificationMessage.Title__c.replace('Agency_Number',workAssignment.Placement_Agency_Identifier__c).replace('Agency_Name','(' + workAssignment.Placement_Agency_Name__c +')');
                	Title = notificationMessage.Title__c;
                    //Message = notificationMessage.NotificationMessage__c.replace('Total_Amount',String.valueOf(workAssignment.Total_Amount_of_Payments__c));    
                	Message = notificationMessage.NotificationMessage__c;
                    Type = TRANSACTIONS;
                }
                
            }
            else if(workAssignment.Notification_Type__c == ACCOUNT_UPDATES) {
                if(workAssignment.Placement_Agency_Identifier__c != null && workAssignment.Placement_Agency_Name__c != null){
                    notificationMessage = NotificationSuccessMessages__c.getInstance('Account Updated');
                    //Title = notificationMessage.Title__c.replace('Agency_Number',workAssignment.Placement_Agency_Identifier__c).replace('Agency_Name','(' + workAssignment.Placement_Agency_Name__c +')');
                    Title = notificationMessage.Title__c;
                    Message = notificationMessage.NotificationMessage__c;
                    Type = 'Account';
                }
            } 
            else if(workAssignment.Notification_Type__c == ACCOUNT_STATUS_UPDATES) {
                if(workAssignment.Placement_Agency_Identifier__c != null && workAssignment.Placement_Agency_Name__c != null){
                    notificationMessage = NotificationSuccessMessages__c.getInstance('Account Status Updated');
                    //Title = notificationMessage.Title__c.replace('Agency_Number',workAssignment.Placement_Agency_Identifier__c).replace('Agency_Name','(' + workAssignment.Placement_Agency_Name__c +')');
                    Title = notificationMessage.Title__c;
                    Message = notificationMessage.NotificationMessage__c;
                    Type = 'Account';
                }
            } 
            
            //cal to portal API to send payment notification
            PortalNotificationAPI.sendPaymentNotification(workAssignment.Placement_Agency_Identifier__c, 
                                                                 Type, 
                                                                 Title, workAssignment.Task_Number__c,
                                                                 Message);
		}														 
    }
    
    public void finish(Database.BatchableContext bc){
    	Database.executeBatch(new AgencyPaymentNotificationBatch());
    }    
}