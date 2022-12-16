/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a controller class to update customer email preferences
*  @author : A5E Consulting
*  @date : 10/01/2019

*************************************************************************************************/

public class UnsubscribeEmailsController {
    public static string ERROR = 'Due to some error, we were unable to update your email preferences. Someone from CFG will contact you.';
    
    public string strEmail {get;set;}
    public string strFirstName {get;set;}
    public string strLastName {get;set;}
    public string errorMessage{get;set;}
    
    public Boolean identiferPresent {get;set;}
    public Boolean marketingEmailNotification {get;set;}
    public Boolean paymentStatusNotification {get;set;}
    public Boolean futurePaymentReminder{get;set;}
    public Boolean optOutOfAllNotification {get;set;}
    
    public UnsubscribeEmailsController(){
        String identifer = apexpages.currentpage().getparameters().get('id');
        identiferpresent = false;
        if(String.isNotBlank(identifer)){
            List<Account> listAccounts = [SELECT ID, FirstName, LastName, PersonEmail,User_Marketing_Consent__c,
                                          Payment_Success_Failure_Notifications__c, Future_Payment_Reminder__c
                                          FROM Account 
                                          WHERE ID = :identifer];
            
            system.debug('listAccounts: '+listAccounts);
            if(!listAccounts.isEmpty()){
                strEmail = listAccounts[0].PersonEmail;
                strFirstName = listAccounts[0].FirstName;
                strLastName = listAccounts[0].LastName;
                identiferpresent = true;
                marketingEmailNotification = listAccounts[0].User_Marketing_Consent__c;
                paymentStatusNotification = listAccounts[0].Payment_Success_Failure_Notifications__c;
                futurePaymentReminder = listAccounts[0].Future_Payment_Reminder__c;
            }    
        }
    }
  
    public void updateConsent(){
        system.debug('check');
        errorMessage = '';
        Boolean bValidateEmail = Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}', strEmail.trim());
		System.debug('bValidateEmail ===> '+bValidateEmail);

        if(string.isNotBlank(strEmail)
        && bValidateEmail == true){
            errorMessage = errorMessage+''+unsubscribeEmailConsent(strEmail, marketingEmailNotification,
            paymentStatusNotification, futurePaymentReminder, optOutOfAllNotification);
        }
        else{
            errorMessage = 'Due to some error, we were unable to update your email preferences.';
        }
        system.debug('errorMessage'+errorMessage);
        system.debug('Completed Email consent' +errorMessage);        
    }

    private string unsubscribeEmailConsent(String strEmail, Boolean marketingEmailsConsent, Boolean paymentStatusConsent, 
                                           Boolean reminderEmailConsent, Boolean optOutOfAllConsent){
		List<Account> listAccounts = new List<Account>();
		if(string.isNotBlank(strEmail) && string.isNotBlank(strFirstName) && string.isNotBlank(strLastName)){
            listAccounts = [SELECT Id
                            FROM Account 
                            WHERE PersonEmail=: strEmail.trim()
                            AND FirstName= :strFirstName.trim()
                            AND LastName= :strLastName.trim()
                            AND RecordType.DeveloperName= :'Canaccede_Customer'];
        }
		
        if(!listAccounts.isEmpty()){
            listAccounts.addAll([SELECT Id
                                FROM Account 
                                WHERE PersonEmail=: strEmail.trim()
                                AND RecordType.DeveloperName= :'Canaccede_Customer'
                                AND ID NOT IN :listAccounts]);
            
            for(Account account : listAccounts){
                account.User_Marketing_Consent__c = marketingEmailsConsent;
                account.Payment_Success_Failure_Notifications__c = paymentStatusConsent;
                account.Future_Payment_Reminder__c = reminderEmailConsent;
                account.Email_Preferences_Update_Date__c = Date.today();
                account.Email_Preferences_Updated_By__c = UserInfo.getUserId();
                //account.Opt_out_of_all_Notifications__c = !optOutOfAllConsent;
            }
            try{
                update listAccounts;     
                return 'Success';
            }
            catch(Exception ex){
                system.debug('ex: '+ex);
            }
        }
		else{
            if(string.isNotBlank(strEmail)){
                Notification_Preference_Log__c	notificationPrefLog = new Notification_Preference_Log__c();
                notificationPrefLog.First_Name__c = strFirstName;
                notificationPrefLog.Last_Name__c = strLastName;
                notificationPrefLog.Email__c = strEmail;
                notificationPrefLog.Marketing_Email_Notifications__c = marketingEmailsConsent;
                notificationPrefLog.Payment_Success_Failure_Notifications__c = paymentStatusConsent;
                notificationPrefLog.Future_Payment_Reminder__c = reminderEmailConsent;
                insert notificationPrefLog;
            }
        }
        return ERROR;
    }
}