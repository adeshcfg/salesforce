@isTest 
private class TestShowLoanTeleScript{
    
    static testMethod void testMethod1() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Loan_Type__c ='Affirm Financial MasterCard';
        
        update applicationList[0] ;
        
        Test.startTest();
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();
    }
    
    static testMethod void testMethod2() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Decision__c = null;
        
        update applicationList[0] ;
        
        Test.startTest();
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();
    }
    
    static testMethod void testMethod3() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Decision__c = 'Declined';
        
        update applicationList[0] ;
        
        Test.startTest();
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();
    }
    
    static testMethod void testMethod4() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Authentication_Result__c = 'Pa';
        
        update applicationList[0] ;
        
        Test.startTest();
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();        
    }
    
    static testMethod void testMethod5() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        Test.startTest();
        applicationList[0].Loan_Process_Type__c = 'RBO';
        
        update applicationList[0] ;
        
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();
    }
    
    static testMethod void testMethod6() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Application_Fullfillment_Status__c = null;
                
        update applicationList[0] ;
        
        Test.startTest();
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();
    }
    
    static testMethod void testMethod7() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Application_Fullfillment_Status__c = 'Completed';
        
        update applicationList[0] ;
        
        Test.startTest();
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        Test.stopTest();
    }
    
    static testMethod void testMethod8() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Application_Fullfillment_Status__c = 'Completed';
        applicationList[0].Loan_TeleScripting_Accepted__c = true;
        
        Test.startTest();
        
        update applicationList[0] ;
        
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        obj.showAccept = true ;
        obj.saveScript();
        Test.stopTest();
    }
    
    static testMethod void testMethod9() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = Page.ShowLoanTeleScript;
        
        pRef.getParameters().put('applName', applicationList[0].name);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Authentication_Result__c = 'Failed';
        
        Test.startTest();
        
        update applicationList[0] ;
        
        ShowLoanTeleScriptController obj = new ShowLoanTeleScriptController();
        obj.showAccept = true ;
        obj.saveScript();
        Test.stopTest();
    }
    
    Public static List<Application__c> createApplication(Account objAccount){
        List<Application__c> appList = new List<Application__c>();      
        Application__c  appObject1 = new Application__c();
        
        // appObject1.Loan_Amount__c = 1500;
        appObject1.Decision__c = 'Test Result1';
        //appObject1.Application_Status__c = 'Test Satus1';
        //  appObject1.Application_Fullfillment_Status__c = 'Loan Declined';
        appObject1.Name = 'Test Name1';
        appObject1.Customer__c =  objAccount.id;
        
        appList.add(appObject1);
        insert appList;
        return appList;
    }
    
    public static Account createAccount() {
    
        Account objAccount = new Account();
        objAccount.LastName = 'Account';
        
        objAccount.FirstName = 'Test';
        objAccount.Phone = '+619654922845';
        objAccount.Type = 'Bank';
        insert objAccount;
        
        system.assert(objAccount.id != null);
        return objAccount;   
    }
}