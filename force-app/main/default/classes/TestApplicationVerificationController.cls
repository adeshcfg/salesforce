/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a test class for ApplicationVerificationController
 *  @author : A5E Consulting
 *  @date : 04/14/2020
 
 *************************************************************************************************/
 

@isTest
public class TestApplicationVerificationController {

    //Custom Setting
    //private static Application_Form_Settings__c afSettings;
    
    //Application record
    private static Application__c app;
    
   
    //Dummy Token
    private static String authToken = '7d6349d59afb5fc1172b52bde66bea1c';
    
    //Inserting Application record
    static void insertTestdata(){
        app=new Application__c(
            Salutation__c = 'Ms.', 
            First_Name__c = 'Test', 
            Last_Name__c = 'Email',
            Email_Address__c = 'abc@test.com',
            Application_Status__c = 'System Approved',
            Verification_Status__c = 'Email Sent – Analyst',
            Verification_Auth_Token__c = authToken
            );
        insert app;
        
    }
         
    //Test Method
    static testmethod void testVerify(){
    
        //Success
        insertTestdata();
        ApexPages.currentPage().getParameters().put('vat', authToken);
        ApplicationVerificationController cntrl = new ApplicationVerificationController();
        cntrl.checkVerifyRequest();
        
        //Link Expired
        app.Verification_Expiration_Date__c = Datetime.now().addDays(-1);       
        update app;
        ApexPages.currentPage().getParameters().put('vat', authToken);
        cntrl = new ApplicationVerificationController();
        cntrl.checkVerifyRequest();  
        
        //Already Verified
        app.Verification_Status__c = 'Verified';        
        update app;
        ApexPages.currentPage().getParameters().put('vat', authToken);
        cntrl = new ApplicationVerificationController();
        cntrl.checkVerifyRequest();
                                
        //No vat value
        ApexPages.currentPage().getParameters().put('vat', null);
        cntrl = new ApplicationVerificationController();
        cntrl.checkVerifyRequest();  
                
        //Wrong vat value
        ApexPages.currentPage().getParameters().put('vat', 'abcd1234');
        cntrl = new ApplicationVerificationController();
        cntrl.checkVerifyRequest();  
        
    }
}