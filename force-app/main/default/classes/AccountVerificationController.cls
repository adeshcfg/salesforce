/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a controller class for account Verification
 *  @author : A5E Consulting
 *  @date : 27/11/2020
 
 *************************************************************************************************/
 
public without sharing class AccountVerificationController {
    
    //Variables
    public Boolean emailVerificationError {get;set;}
    public Boolean alreadyVerified {get;set;}
    public Boolean nullVerificationID {get;set;}
    
    //Application record
    public Account account {get;set;}
    
    //Constants
    public static final String VERIFICATION_STATUS_VERIFIED = 'Verified';
    public static final String VERIFICATION_ALREADY_COMPLETED = 'Verification already completed';
    
    //Constructor    
    public AccountVerificationController(){
        
        nullVerificationID = true;
        emailVerificationError = false;
        alreadyVerified = false;
               
    }  
    
    //Veirfying Application
    public void checkVerifyRequest() {
    
        String emailToken = ApexPages.currentPage().getParameters().get('vat');
        system.debug('emailToken: '+emailToken);
        if (emailToken != null && emailToken != '') {
        
            nullVerificationID = false;
            
            account = getApplicationByVerificationToken(emailToken);
            
            if (account != null) { 
                // Verification process already complete    
                if(account.Verification_Status__c == VERIFICATION_STATUS_VERIFIED){
                    alreadyVerified = True; 
                }
                
                // Check if email expired
                else if (Datetime.now() > account.Verification_Expiration_Date__c) {
                    // Expired (handle error case)
                    emailVerificationError = true;
                }                    
                
            } 
            else {
                // Email token not recognized
                emailVerificationError = true;
            }
            
        } else {
            // Email token missing
            emailVerificationError = true;                        
        }
        //Display correct message
        if (emailVerificationError == false && alreadyVerified == false) {
        
            //Update application
            account.Verification_Status__c = VERIFICATION_STATUS_VERIFIED;
            account.Verification_Completion_Date__c = Datetime.now();
            update account;
        }
             
        //return null; 
        
    }  
    
    // Fetching Application with Verification Token
    public Account getApplicationByVerificationToken(String vat) { 
        List<Account> applications = [SELECT ID, Verification_Status__c, Verification_Expiration_Date__c, 
                       		  Verification_Auth_Token__c 
                       FROM Account 
                       WHERE Verification_Auth_Token__c= :vat LIMIT 1];
        system.debug('applications : '+applications);
        return (applications.size() > 0) ? applications[0] : null;
    }
}