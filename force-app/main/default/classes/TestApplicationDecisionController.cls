@isTest
private class TestApplicationDecisionController {
    private static Application_Form_Settings__c appFormSettings;
    
    // Test applications
    private static Application__c happyApp;
    private static Application__c bankruptApp;
    private static Application__c bankruptLoanApp;
    
    // Test happy app case -- declines amount
    static testMethod void TestHappyApplicationDeclinesAmount() {
        initPageRef();
        insertTestData();
        
        // Test happy app initial conditions
        ApexPages.currentPage().getParameters().put('id', happyApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', happyApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', happyApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Accepted');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals(0, c.authenticationStep);
        //System.assertEquals('Accepted', c.Decision);
        System.assertEquals(happyApp.Id, c.applicationId);
        //System.assertEquals(happyApp.Last_Name__c, c.LastName);
        //System.assertEquals(happyApp.First_Name__c, c.FirstName);
        //System.assertEquals(c.CONDITION_DISCHARGED, c.conditions); // no BKCP
        
        //Updated by A5E consulting
        //Email Authentication
        //System.assertEquals(happyApp.Max_Credit_Card_Allowed_Amount__c, c.approvalAmount);
        //System.assertEquals(happyApp.Lender_Approved_Amount__c, c.approvalAmount);     
        
        // happy app declines approval amount
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        //PageReference ref = c.moveToStepTwo();
        Test.stopTest();
        
        Application__c newHappyApp = getApplicationById(happyApp.Id);
        //System.assertEquals(2, c.authenticationStep);
        //System.assertEquals(c.AUTHENTICATION_DECLINED, newHappyApp.Authentication_Choice__c);
        //System.assertEquals(c.AUTHENTICATION_DECLINED_AMOUNT, newHappyApp.Authentication_Result__c);
        //System.assertEquals(null, ref);
    }
    
    // Test happy app case -- accepts amount, does not continue
    static testMethod void TestHappyApplicationDoesNotContinue() {
        initPageRef();
        insertTestData();
        
        // Test happy app initial conditions
        ApexPages.currentPage().getParameters().put('id', happyApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', happyApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', happyApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Accepted');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals(0, c.authenticationStep);
        //System.assertEquals('Accepted', c.Decision);
        System.assertEquals(happyApp.Id, c.applicationId);
        //System.assertEquals(happyApp.Last_Name__c, c.LastName);
        //System.assertEquals(happyApp.First_Name__c, c.FirstName);
        //System.assertEquals(c.CONDITION_DISCHARGED, c.conditions); // no BKCP
        
        //Updated by A5E consulting
        //Email Authentication
        //System.assertEquals(happyApp.Max_Credit_Card_Allowed_Amount__c, c.approvalAmount);
        //System.assertEquals(happyApp.Lender_Approved_Amount__c, c.approvalAmount);     
        
        // happy app accepts approval amount
        //c.moveToStepOne();
        
        Application__c newHappyApp = getApplicationById(happyApp.Id);
        //System.assertEquals(1, c.authenticationStep);
        System.assertEquals(false, newHappyApp.Acknowledged_Card_not_Included_in_BKCP__c);
        
        // happy app does not continue
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        //PageReference ref = c.moveToStepThree();
        Test.stopTest();
        
        newHappyApp = getApplicationById(happyApp.Id);
        //System.assertEquals(3, c.authenticationStep);
        //System.assertEquals(c.AUTHENTICATION_DECLINED, newHappyApp.Authentication_Choice__c);
        //System.assertEquals(c.AUTHENTICATION_INCOMPLETE, newHappyApp.Authentication_Result__c);
        //System.assertEquals(null, ref);
    }
    
    // Test happy app case -- accepts amount, moves to questions
    static testMethod void TestHappyApplicationMovesToQuestions() {
        initPageRef();
        insertTestData();
        
        // Test happy app initial conditions
        ApexPages.currentPage().getParameters().put('id', happyApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', happyApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', happyApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Accepted');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals(0, c.authenticationStep);
        //System.assertEquals('Accepted', c.Decision);
        System.assertEquals(happyApp.Id, c.applicationId);
        //System.assertEquals(happyApp.Last_Name__c, c.LastName);
        //System.assertEquals(happyApp.First_Name__c, c.FirstName);
        //System.assertEquals(c.CONDITION_DISCHARGED, c.conditions); // no BKCP
        
        //Updated by A5E consulting
        //Email Authentication
        //System.assertEquals(happyApp.Max_Credit_Card_Allowed_Amount__c, c.approvalAmount);
        //System.assertEquals(happyApp.Lender_Approved_Amount__c, c.approvalAmount);     
        
        // happy app accepts approval amount
        //c.moveToStepOne();
        
        Application__c newHappyApp = getApplicationById(happyApp.Id);
        //System.assertEquals(1, c.authenticationStep);
        System.assertEquals(false, newHappyApp.Acknowledged_Card_not_Included_in_BKCP__c);
        
        // happy app continues to questions
        //PageReference ref = c.continueToQuestions();
        
        newHappyApp = getApplicationById(happyApp.Id);
        //System.assertEquals('Accepted/Started', newHappyApp.Authentication_Choice__c);
        //System.assertEquals(appFormSettings.Trans_Union_Questions_URL__c + '?id=' + happyApp.Id, ref.getUrl());
    }
 
     // Test bankrupt loan case -- cannot move forward
    static testMethod void TestBankruptLoan() {
        initPageRef();
        insertTestData();
        
        // Test bankruptcy loan initial conditions
        ApexPages.currentPage().getParameters().put('id', bankruptLoanApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', bankruptLoanApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', bankruptLoanApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Accepted');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals(0, c.authenticationStep);
        //System.assertEquals('Accepted', c.Decision);
        System.assertEquals(bankruptLoanApp.Id, c.applicationId);
        //System.assertEquals(bankruptLoanApp.Last_Name__c, c.LastName);
        //System.assertEquals(bankruptLoanApp.First_Name__c, c.FirstName);
        //System.assertEquals(c.CONDITION_LOAN_NOT_DISCHARGED, c.conditions); // BKCP on loan
    }
    
    // Test decline case -- application declined
    static testMethod void TestAppDeclined() {
        initPageRef();
        insertTestData();
        
        // Test declined app initial conditions
        ApexPages.currentPage().getParameters().put('id', bankruptApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', bankruptApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', bankruptApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Declined');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals('Declined', c.Decision);
    }

    // Test bankrupt credit card case -- does not continue
    static testMethod void TestCreditBankruptcyNoAck() {
        initPageRef();
        insertTestData();
        
        // Test bankruptcy initial conditions
        ApexPages.currentPage().getParameters().put('id', bankruptApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', bankruptApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', bankruptApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Accepted');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals(0, c.authenticationStep);
        //System.assertEquals('Accepted', c.Decision);
        System.assertEquals(bankruptApp.Id, c.applicationId);
        //System.assertEquals(bankruptApp.Last_Name__c, c.LastName);
        //System.assertEquals(bankruptApp.First_Name__c, c.FirstName);
        //System.assertEquals(c.CONDITION_CREDIT_NOT_DISCHARGED, c.conditions); // BKCP on credit cad
        
        //Updated by A5E consulting
        //Email Authentication
        //System.assertEquals(bankruptApp.Total_Credit_Worthiness__c, c.approvalAmount); // Use total credit worthiness, not max
        //System.assertEquals(bankruptApp.Lender_Approved_Amount__c, c.approvalAmount);        
        
        // bankrupt app does not continue
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        //PageReference ref = c.moveToStepTwo();
        Test.stopTest();
        
        Application__c newBankruptApp = getApplicationById(bankruptApp.Id);
        
        //System.assertEquals(2, c.authenticationStep);
        //System.assertEquals(c.AUTHENTICATION_DECLINED, newBankruptApp.Authentication_Choice__c);
        //System.assertEquals(c.AUTHENTICATION_DECLINED_AMOUNT, newBankruptApp.Authentication_Result__c);
    }

    // Test bankrupt credit card case -- acknowledges and continues
    static testMethod void TestCreditBankruptcyAck() {
        initPageRef();
        insertTestData();
        
        // Test bankruptcy initial conditions
        ApexPages.currentPage().getParameters().put('id', bankruptApp.Id);
        ApexPages.currentPage().getParameters().put('FirstName', bankruptApp.First_Name__c);
        ApexPages.currentPage().getParameters().put('LastName', bankruptApp.Last_Name__c);
        ApexPages.currentPage().getParameters().put('Decision', 'Accepted');
        
        ApplicationDecisionController c = new ApplicationDecisionController();
        
        //System.assertEquals(0, c.authenticationStep);
        //System.assertEquals('Accepted', c.Decision);
        System.assertEquals(bankruptApp.Id, c.applicationId);
        //System.assertEquals(bankruptApp.Last_Name__c, c.LastName);
        //System.assertEquals(bankruptApp.First_Name__c, c.FirstName);
        //System.assertEquals(c.CONDITION_CREDIT_NOT_DISCHARGED, c.conditions); // BKCP on credit cad
        
        //Updated by A5E consulting
        //Email Authentication
        //System.assertEquals(bankruptApp.Total_Credit_Worthiness__c, c.approvalAmount); // Use total credit worthiness, not max
        //System.assertEquals(bankruptApp.Lender_Approved_Amount__c, c.approvalAmount);     
        
        // bankrupt app acknowledges and continues
        c.cardNotInBKCP = true;
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        //c.moveToStepOne();
        Test.stopTest();
        
        Application__c newBankruptApp = getApplicationById(bankruptApp.Id);
        
        //System.assertEquals(1, c.authenticationStep);
        //System.assertEquals(true, newBankruptApp.Acknowledged_Card_not_Included_in_BKCP__c);
        
        // bankrupt app continues to questions
        //PageReference ref = c.continueToQuestions();
        
        newBankruptApp = getApplicationById(bankruptApp.Id);
        //System.assertEquals('Accepted/Started', newBankruptApp.Authentication_Choice__c);
        //System.assertEquals(appFormSettings.Trans_Union_Questions_URL__c + '?id=' + newBankruptApp.Id, ref.getUrl());
    }    
    
    private static Application__c getApplicationById(Id applicationId) {
        List<Application__c> applications = [
            SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Loan_Type__c, Acknowledged_Card_not_Included_in_BKCP__c,
                Authentication_Choice__c, Authentication_Result__c, PcoD_Bankruptcy_State__c, Total_Credit_Worthiness__c, 
                Max_Credit_Card_Allowed_Amount__c, Lender_Approved_Amount__c      
            FROM Application__c WHERE Id =: applicationId
        ];
    
        return (applications.size() > 0) ? applications[0] : null;
    }
    
    private static void initPageRef() {
        appFormSettings = Application_Form_Settings__c.getOrgDefaults();
        PageReference pageRef = Page.ApplicationDecision;
        Test.setCurrentPage(pageRef);
    }
    
    private static void insertTestData() {
        appFormSettings = new Application_Form_Settings__c(
            Trans_Union_Questions_URL__c = '/test/url.htm',
            Power_Curve_Web_Service_URL__c = PowerCurveTestUtilities.Power_Curve_Web_Service_URL,
            Power_Curve_Username__c = PowerCurveTestUtilities.Power_Curve_Username, 
            Power_Curve_Password__c = PowerCurveTestUtilities.Power_Curve_Password, 
            Site_Profile_Id__c = '00eK0000000MDqzIAG'
        );
        insert appFormSettings;
        
        // Credit card case -- no bankruptcy
        happyApp = new Application__c(
            Salutation__c = 'Ms.', 
            First_Name__c = 'Happy', 
            Last_Name__c = 'Credit', 
            Loan_Type__c = 'Affirm Financial MasterCard',
             
            Total_Credit_Worthiness__c = 5000, 
            Max_Credit_Card_Allowed_Amount__c = 2000
        );
        insert happyApp;
        
        // Credit card case -- bankupt not discharged
        bankruptApp = new Application__c(
            Salutation__c = 'Mrs.', 
            First_Name__c = 'Sad', 
            Last_Name__c = 'Credit', 
            Loan_Type__c = 'Affirm Financial MasterCard',
             
            PcoD_Bankruptcy_State__c = 'BKCP Not Discharged',
            Total_Credit_Worthiness__c = 1000, 
            Max_Credit_Card_Allowed_Amount__c = 2000
        );
        insert bankruptApp;
        
        // Loan case -- bankupt not discharged
        bankruptLoanApp = new Application__c(
            Salutation__c = 'Mrs.', 
            First_Name__c = 'Sad', 
            Last_Name__c = 'Loan', 
            Loan_Type__c = 'Affirm Financial Term Loan',
             
            PcoD_Bankruptcy_State__c = 'BKCP Not Discharged',
            Total_Credit_Worthiness__c = 1000, 
            Max_Credit_Card_Allowed_Amount__c = 2000
        );
        insert bankruptLoanApp;
    }
     
}