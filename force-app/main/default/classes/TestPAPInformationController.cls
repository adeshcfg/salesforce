/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of PAPInformationController 
*  @author : A5E Consulting
*  @date : 08/02/2016
*
*************************************************************************************************/

@isTest
private class TestPAPInformationController{
    
    
    //Loan_ReEngineering__c Custom Settings
    static {
        
        Loan_ReEngineering__c loanSettings = new Loan_ReEngineering__c();
        loanSettings.File_Formats__c = '.pdf,.jpeg,.jpg';
        loanSettings.File_Size__c = 2097152;
        insert loanSettings;         
    }
    
    //Test Various Scenarios   
    static testMethod void paymentTest(){
        //Dummy Attachment
        Attachment attInvalid = new Attachment();
        attInvalid.body = Blob.valueof('Invalid File');
        attInvalid.name = 'invalid.xyz';
        
        //Dummy Attachment
        Attachment attValid = new Attachment();
        attValid.body = Blob.valueof('Valid File');
        attValid.name = 'valid.pdf';
        
        //Test Application
        Application__c app = new Application__c();
        app.loan_type__c  = 'Affirm Financial MasterCard';
        insert app;
        
        ApexPages.currentPage().getParameters().put('id', app.id);
        ApexPages.currentPage().getParameters().put('loanType', 'Affirm Financial MasterCard');
        
        //Credit Card App
        PAPInformationController papInfoCtrl = new PAPInformationController();
        
        //Loan App
        ApexPages.currentPage().getParameters().put('loanType', 'Affirm Financial Term Loan');
        
        //Declined Loan App
        app.Decision__c = 'Declined';
        app.loan_type__c  = 'Affirm Financial Term Loan';
        update app;
        papInfoCtrl = new PAPInformationController();
        
        //Wrong Authentication
        app.Decision__c = 'Approved';
        app.Authentication_Result__c = 'Failed';
        app.Authentication_Choice__c = 'Declined';
        update app;
        papInfoCtrl = new PAPInformationController();
        
        //Wrong Fullfillment Status
        app.Authentication_Result__c = 'Passed';
        app.Authentication_Choice__c = 'Completed';
        app.Application_Fullfillment_Status__c = 'Completed';
        update app;
        papInfoCtrl = new PAPInformationController();
        
        //Wrong PAP Information
        app.Application_Fullfillment_Status__c = 'Loan Calculator Completed';
        update app;
        papInfoCtrl = new PAPInformationController();
        papInfoCtrl.acceptTermsCondition = true;
        papInfoCtrl.application.PAP_Transit_Code__c = 'abc';
        papInfoCtrl.application.PAP_Account_Number__c = 'xyz';
        papInfoCtrl.application.PAP_Bank_Code__c = 'pqr';
        papInfoCtrl.updatePaymentMethod();
        
        //No File Attachment
        app.Application_Fullfillment_Status__c = 'Loan Calculator Completed';
        update app;
        papInfoCtrl = new PAPInformationController();
        papInfoCtrl.acceptTermsCondition = true;
        papInfoCtrl.application.PAP_Transit_Code__c = '123';
        papInfoCtrl.application.PAP_Account_Number__c = '456';
        papInfoCtrl.application.PAP_Bank_Code__c = '789';
        papInfoCtrl.updatePaymentMethod();
        
        //Invalid File Attachment 
        papInfoCtrl = new PAPInformationController();
        papInfoCtrl.papSupportDocument = attInvalid;
        papInfoCtrl.acceptTermsCondition = true;
        papInfoCtrl.application.PAP_Transit_Code__c = '123';
        papInfoCtrl.application.PAP_Bank_Code__c = '456';
        papInfoCtrl.application.PAP_Account_Number__c = '789';        
        papInfoCtrl.updatePaymentMethod();
        
        //Terms Conditionas not accepted
        papInfoCtrl = new PAPInformationController();
        papInfoCtrl.papSupportDocument = attValid;
        papInfoCtrl.acceptTermsCondition = false;
        papInfoCtrl.application.PAP_Transit_Code__c = '123';
        papInfoCtrl.application.PAP_Bank_Code__c = '456';
        papInfoCtrl.application.PAP_Account_Number__c = '789';        
        papInfoCtrl.updatePaymentMethod();
        
        //All OK
        papInfoCtrl = new PAPInformationController();
        papInfoCtrl.papSupportDocument = attValid;
        papInfoCtrl.acceptTermsCondition = true;
        papInfoCtrl.application.PAP_Transit_Code__c = '123';
        papInfoCtrl.application.PAP_Bank_Code__c = '456';
        papInfoCtrl.application.PAP_Account_Number__c = '789';        
        papInfoCtrl.updatePaymentMethod();
        papInfoCtrl.navigatePrevious();
        papInfoCtrl.upload();
        papInfoCtrl.closePopup();
        papInfoCtrl.showPopup();    
    }    
}