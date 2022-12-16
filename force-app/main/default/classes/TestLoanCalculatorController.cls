@isTest
Public class TestLoanCalculatorController{
        
    static testMethod void calculateLoanMethod1(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Loan_Type__c = 'Affirm Financial MasterCard';
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod2(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Decision__c = 'Approved';
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod3(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Decision__c = 'Referred';
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod4(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Application_Fullfillment_Status__c = 'Ready For Export';
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod5(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Application_Fullfillment_Status__c = 'Completed';
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod6(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Lender_Approved_Amount__c = 0;
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
        
    static testMethod void calculateLoanMethod7(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Interest_Rate__c = 0;
        update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod8(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        applicationList[0].Interest_Rate__c = 0;
        //  update applicationList[0] ;
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        lCont.showError = false;
        LoanCalculatorController lCon1t = new LoanCalculatorController();
        
        Test.stopTest();
    }
    
    static testMethod void calculateLoanMethod(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.LoanCalculator;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        
        Test.startTest();
        
        LoanCalculatorController lCont = new LoanCalculatorController();
        lCont.applicationId = applicationList[0].id;
        lCont.getLoanAmountList();
        Test.stopTest();
    }
    
    Public static List<Application__c> createApplication(Account objAccount){
        List<Application__c> appList = new List<Application__c>();      
        Application__c  appObject1 = new Application__c();
        appObject1.Loan_Type__c = 'Affirm Financial Term Loan';
        appObject1.Loan_Amount__c = 1500;
        appObject1.Decision__c = 'Approved';
        appObject1.Application_Status__c = 'Test Satus1';
        appObject1.Application_Fullfillment_Status__c = 'Loan Declined';
        appObject1.Authentication_Result__c = 'Passed';
        appObject1.Name = 'Test Name1';
        appObject1.Customer__c =  objAccount.id;
        appList.add(appObject1);
        insert appList;
        
        return appList;
    }
    
    public static Account createAccount(){
        Account objAccount = new Account();
        objAccount.LastName = 'Account';
        
        objAccount.FirstName = 'Test';
        objAccount.Phone = '+619654922845';
        objAccount.Type = 'Bank';
        insert objAccount;
        
        system.assert(objAccount.id != null);
        return objAccount;   
    }
    
    static testMethod void calculateLoan(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 1720.00 ;
        app.Interest_Rate__c = 8 ;
        
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 1720.00);
        
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        
        controller.getLoanAmountList();
        
        controller.loanStartDateString = '10-10-2030';
    }
    
    static testMethod void nevigateNext(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 1720.00 ;
        app.Interest_Rate__c = 8 ;
        
        
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 1720.00);
        
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        
        controller.getLoanAmountList();
        
        controller.loanStartDateString = '10/10/2030';
        
        controller.selectedLoanAmount = String.valueof(1231);
        controller.selectedNumberMonth = '12';
        controller.maturityDateString = '10/10/2016';
        controller.loanStartDateString = '10/11/2015';
        controller.firstPaymString ='11/11/2015';
        controller.navigateNext1();
        controller.navigatePrevious();
        
        controller.firstPaymString = '10/10/2016';
        controller.firstPaymentString = '10/10/2016';
        controller.strdate.add('10/10/2016');
        controller.loanStartDateString = '10/10/2016';
        controller.navigateNext1();
        
        controller.loanStartDateString = 'abc';
        controller.navigateNext1();
    }
    
    static testMethod void updateStartLoneDate(){
        
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 1720.00 ;
        app.Interest_Rate__c = 8 ;
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 1720.00);
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        controller.loanStartDateString = '10/10/2030';
        controller.updateLoanStartDate();
        controller.selectedLoanAmount = '12345432';
        
        controller.getNumberOfMonthsList();
        
        controller.selectedNumberMonth = '10';
        controller.calulateMaturityDate();
    }
    
    static testMethod void validation1(){
        
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 0;
        app.Interest_Rate__c = 8 ;
        
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 0);
        PageReference pRef = Page.LoanCalculator;
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        
    }
    
    static testMethod void validation2(){
        
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 1234;
        app.Interest_Rate__c = 0 ;
        
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 1234.00);
        PageReference pRef = Page.LoanCalculator;
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        
    }
    
    static testMethod void validation3(){
        
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 1234;
        app.Interest_Rate__c = 15;
        app.Application_Fullfillment_Status__c = 'Completed';
        
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 1234.00);
        PageReference pRef = Page.LoanCalculator;
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        
    }
    
    static testMethod void validation4(){
        
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Application__c  app = applicationList[0].clone(false,false,false,false);
        app.Lender_Approved_Amount__c  = 1234;
        app.Interest_Rate__c = 15;
        app.Application_Fullfillment_Status__c = 'Ready For Export';
        
        insert app ;
        System.assertEquals(app.Lender_Approved_Amount__c, 1234.00);
        PageReference pRef = Page.LoanCalculator;
        apexpages.currentpage().getparameters().put('id' , app.id);
        LoanCalculatorController  controller = new LoanCalculatorController() ;
        
    }
}