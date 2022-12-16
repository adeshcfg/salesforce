/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a controller class for account Registration
 *  @author : A5E Consulting
 *  @date : 27/11/2020
 
 *************************************************************************************************/

public without sharing class AccountRegistrationController {
    public Account account{get;set;}
    public Id accountId;
    public String userEmail {get;set;}
    public String userPhone {get;set;}
    public String errorMessage {get;set;}
    
    public boolean userMarketingConsent {get;set;}
    public boolean terms {get;set;}
    public boolean showRegistration {get;set;}
    public boolean showError {get;set;}
    
    
    //Constructor
    public AccountRegistrationController() {
		account = new Account();
        accountId = ApexPages.currentPage().getParameters().get('uniqueID');
        account.Id = accountId;
        showRegistration = true;
        showError = false;
    }
    
    //Register method to register customer
    public pageReference registerAccount(){
   		Datetime current = Datetime.now();
        String hashString = account.Id + current.formatGmt('yyyyMMddHHmmssSSS');
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString)); 
        account.Id = accountId;
        system.debug('account:: '+account);
        //Update account fields on registration
        account.Verification_Auth_Token__c = EncodingUtil.convertToHex(hash);
        account.Verification_Sent_Date__c = system.now();
        account.Verification_Status__c = 'Email Sent';
        account.Verification_Expiration_Date__c = system.now().addDays(2);
        account.User_Registration_Date__c = system.now();
        /*account.Secret_Code_Expiration_Date__c = system.now().addDays(30);
        account.Secret_Code_Sent_Date__c = system.now();*/
        account.User_Provided_Contact_Number__c = userPhone;
        account.User_Provided_Email__c = userEmail;
        system.debug('userMarketingConsent: '+userMarketingConsent);
        account.User_Marketing_Consent__c = userMarketingConsent;
        account.User_Agreement_To_Terms_and_Conditions__c = true;
        try{
        	update account;
        	showRegistration = false;    
        }
        catch(Exception ex){
            system.debug('exception: '+ex);
        }
        return null;
    }
}