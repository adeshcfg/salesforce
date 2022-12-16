@isTest
private class TestSendAuthEmailController {
    private static Application_Form_Settings__c afSettings;
    private static Application__c noEmailApp;
    private static Application__c alreadyCompletedApp;
    private static Application__c alreadyPassedApp;
    private static Application__c missingLenderApprovedAmountApp;
    private static Application__c elgibleApp;
    private static Application__c passedNoFraudApp;
    
    //Customer Matching Updates
    //private static Application__c manualReviewApp;    
    
    // App has no email
    static testMethod void testNoEmail() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', noEmailApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(false, c.elgibleForEmail);
        System.assertEquals(c.NO_EMAIL, c.inelgibleReason);
        
        c.invokeEmail();
        
        Application__c newApp = getApplicationById(noEmailApp.Id);
        
        System.assertEquals(null, newApp.Email_Authentication_Status__c);
        System.assertEquals(null, newApp.Email_Auth_Token__c);
        System.assertEquals(null, newApp.Email_Authentication_Sent_Date__c);
    }

    // App already completed auth
    static testMethod void testAlreadyCompleted() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', alreadyCompletedApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(false, c.elgibleForEmail);
        System.assertEquals(c.AUTH_ALREADY_COMPLETED, c.inelgibleReason);
        
        c.invokeEmail();
        
        Application__c newApp = getApplicationById(alreadyCompletedApp.Id);
        
        System.assertEquals(null, newApp.Email_Authentication_Status__c);
        System.assertEquals(null, newApp.Email_Auth_Token__c);
        System.assertEquals(null, newApp.Email_Authentication_Sent_Date__c);
    }

    // App already passed auth
    static testMethod void testAlreadyPassed() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', alreadyPassedApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(false, c.elgibleForEmail);
        System.assertEquals(c.AUTH_ALREADY_COMPLETED, c.inelgibleReason);
        
        c.invokeEmail();
        
        Application__c newApp = getApplicationById(alreadyPassedApp.Id);
        
        System.assertEquals(null, newApp.Email_Authentication_Status__c);
        System.assertEquals(null, newApp.Email_Auth_Token__c);
        System.assertEquals(null, newApp.Email_Authentication_Sent_Date__c);
    }
    
    
    //PassedNoFraudApp
    static testMethod void testPassedNoFraudApp() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', passedNoFraudApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(false, c.elgibleForEmail);
        System.assertEquals(c.AUTH_ALREADY_COMPLETED, c.inelgibleReason);
        
        c.invokeEmail();
        
        Application__c newApp = getApplicationById(alreadyPassedApp.Id);
        
        System.assertEquals(null, newApp.Email_Authentication_Status__c);
        System.assertEquals(null, newApp.Email_Auth_Token__c);
        System.assertEquals(null, newApp.Email_Authentication_Sent_Date__c);
    }
    
    //Manual review Application
    //Added by A5E Consulting 
    //Customer Matching Updates
    /*    
    static testMethod void testManualReview() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', manualReviewApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(false, c.elgibleForEmail);
        System.assertEquals(c.MARKED_MANUAL_REVIEW, c.inelgibleReason);
        
        c.invokeEmail();
        
        Application__c newApp = getApplicationById(alreadyPassedApp.Id);
        
        System.assertEquals(null, newApp.Email_Authentication_Status__c);
        System.assertEquals(null, newApp.Email_Auth_Token__c);
        System.assertEquals(null, newApp.Email_Authentication_Sent_Date__c);
    }
    */
    
    //Lender Approved Amount Missing Application
    //Added by A5E Consulting     
    static testMethod void testMissingLenderApprovedAmount() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', missingLenderApprovedAmountApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(false, c.elgibleForEmail);
        System.assertEquals(c.MISSING_LENDER_APPROVED_AMOUNT, c.inelgibleReason);
        
        c.invokeEmail();
        
        Application__c newApp = getApplicationById(missingLenderApprovedAmountApp.Id);
        
        System.assertEquals(null, newApp.Email_Authentication_Status__c);
        System.assertEquals(null, newApp.Email_Auth_Token__c);
        System.assertEquals(null, newApp.Email_Authentication_Sent_Date__c);
    }

    // App elgible for email
    static testMethod void testElgible() {
        init();
        
        ApexPages.currentPage().getParameters().put('id', elgibleApp.Id);
        
        SendAuthEmailController c = new SendAuthEmailController();
        
        System.assertEquals(true, c.elgibleForEmail);
        
        //c.invokeEmail();
        
        //TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        c.invokeEmail(); 
        Test.stopTest();
        
        Application__c newApp = getApplicationById(elgibleApp.Id);
        
        System.assertEquals('Sent to Applicant', newApp.Email_Authentication_Status__c);
        System.assertNotEquals(null, newApp.Email_Auth_Token__c);
        System.assertNotEquals(null, newApp.Email_Authentication_Sent_Date__c);
        System.assertNotEquals(null, newApp.Email_Authentication_Expiration_Date__c);
    }
    
    static void init() {
        afSettings = new Application_Form_Settings__c(
            Site_Profile_Id__c = '00eK0000000MDqzIAG',
            Email_Authentication_Expiry_Days__c = 10,
            Power_Curve_Web_Service_URL__c = PowerCurveTestUtilities.Power_Curve_Web_Service_URL,
            Power_Curve_Username__c = PowerCurveTestUtilities.Power_Curve_Username, 
            Power_Curve_Password__c = PowerCurveTestUtilities.Power_Curve_Password
        );
        insert afSettings;
        
        insertTestData();
        initPageRef();
    }
    
    static void insertTestData() {
        noEmailApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'No', 
            Last_Name__c = 'Email',
            Lender_Approved_Amount__c = 1000 
        );
        insert noEmailApp;
        
        alreadyCompletedApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'Already', 
            Last_Name__c = 'Completed',
            Email_Address__c = 'ac@test.com',
            Authentication_Choice__c = 'Completed',
            Lender_Approved_Amount__c = 1000 
        );
        insert alreadyCompletedApp;
 
        alreadyPassedApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'Already', 
            Last_Name__c = 'Passed',
            Email_Address__c = 'ap@test.com',
            Authentication_Choice__c = 'Completed',
            Authentication_Result__c = 'Passed',
            Lender_Approved_Amount__c = 1000 
        );
        insert alreadyPassedApp;
        
        passedNoFraudApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'Already', 
            Last_Name__c = 'PassedNoFraud',
            Email_Address__c = 'ap@test.com',
            Authentication_Choice__c = 'Completed',
            Authentication_Result__c = 'PassedNoFraud',
            Lender_Approved_Amount__c = 1000 
        );
        insert passedNoFraudApp;
        
        //Customer Matching Updates
        /*
        manualReviewApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'Manual', 
            Last_Name__c = 'Reviewp',
            Email_Address__c = 'mr@test.com',
            Needs_Manual_Review__c = true,
            Lender_Approved_Amount__c = 1000
        );
        insert manualReviewApp;
        */
        
        missingLenderApprovedAmountApp = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'Missing', 
            Last_Name__c = 'LenderApprovedAmoun',
            Email_Address__c = 'mr@test.com'
        );
        insert missingLenderApprovedAmountApp;
        
        elgibleApp = new Application__c(
            Salutation__c = 'Ms.', 
            First_Name__c = 'Elgible', 
            Last_Name__c = 'Email',
            Email_Address__c = 'ee@test.com',
            Lender_Approved_Amount__c = 1000 
        );
        insert elgibleApp;
    }
    
    static void initPageRef() {
        PageReference pageRef = Page.SendAuthEmail;
        Test.setCurrentPage(pageRef);
    }
    
    static Application__c getApplicationById(Id applicationId) {
        List<Application__c> applications = [
            SELECT Id, Email_Authentication_Sent_Date__c, Email_Authentication_Status__c, Email_Auth_Token__c, Application__c.Email_Authentication_Expiration_Date__c, Requested_Credit_Limit__c 
            FROM Application__c WHERE Id =: applicationId
        ];
    
        return (applications.size() > 0) ? applications[0] : null;
    }   
}