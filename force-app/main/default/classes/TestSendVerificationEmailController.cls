@isTest
public class TestSendVerificationEmailController {
    
    //Variables
    private static Application_Form_Settings__c afSettings;
    private static Application__c noEmailApp;
    private static Application__c elgibleApp;
    
    // App has no email
    static testMethod void testNoEmail() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', noEmailApp.Id);        
        SendVerificationEmailController cntrl = new SendVerificationEmailController();        
        System.assertEquals(false, cntrl.elgibleForEmail);
        System.assertNotEquals(cntrl.NO_EMAIL, cntrl.inelgibleReason);        
        cntrl.invokeEmail();
        
        Application__c newApp = getApplicationById(noEmailApp.Id);        
        System.assertEquals(null, newApp.Verification_Status__c);
        System.assertEquals(null, newApp.Verification_Auth_Token__c);
        System.assertEquals(null, newApp.Verification_Sent_Date__c);
    }
    
    // App elgible for email
    static testMethod void testElgible() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', elgibleApp.Id);        
        SendVerificationEmailController cntrl = new SendVerificationEmailController();  
        cntrl.invokeEmail();        
        System.assertEquals(true, cntrl.elgibleForEmail);       
        
        Application__c newApp = getApplicationById(elgibleApp.Id);        
        System.assertEquals('Email Sent – Analyst', newApp.Verification_Status__c);
        System.assertNotEquals(null, newApp.Verification_Auth_Token__c);
        System.assertNotEquals(null, newApp.Verification_Sent_Date__c);
        System.assertNotEquals(null, newApp.Verification_Expiration_Date__c);
    }
    
   //Custom setting insertion 
   static void init() { 
        afSettings = new Application_Form_Settings__c(
           Site_Profile_Id__c = '00eK0000000MDqzIAG',
           Verification_Expiration_Days__c = '20'
           );
        insert afSettings;
        
        insertTestData();
        initPageRef();
        }
    
    // Application records Insertions
    static void insertTestData(){
        noEmailApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'No', 
            Last_Name__c = 'Email' 
        );
        insert noEmailApp;
        
        elgibleApp = new Application__c(
            Salutation__c = 'Ms.', 
            First_Name__c = 'Elgible', 
            Last_Name__c = 'Email',
            Email_Address__c = 'ee@test.com',
            Application_Status__c='Analyst Approved',
            Lender_Approved_amount__c = 1234,
            interest_rate__C = 24.99,
            interest_rate_code__c = 'OTB123'
            //Verification_Status__c='Email Sent – Analyst'
            //Verification_Auth_Token__c='7d6349d59afb5fc1172b52bde66bea1c'
    
            );
        insert elgibleApp;
    }
    
    //Update Application record
    static void UpdateTestData(){
       elgibleApp.Verification_Auth_Token__c='7d6349d59afb5fc1172b52bde66bea1c';
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update elgibleApp;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true; 
    }
    
    // Page refering to VF
    static void initPageRef(){ 
        PageReference pageRef = Page.SendVerificationEmail;
        Test.setCurrentPage(pageRef);
    }
    
    //Fetching Application Verification fields
    static Application__c getApplicationById(Id applicationId) {
        List<Application__c> applications = [
            SELECT Id, Verification_Sent_Date__c, Verification_Status__c, Verification_Auth_Token__c, Verification_Expiration_Date__c, Verification_Completion_Date__c 
            FROM Application__c WHERE Id =: applicationId
        ];
    
        return (applications.size() > 0) ? applications[0] : null;
    }
}