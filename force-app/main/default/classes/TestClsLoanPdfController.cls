@isTest 
private class TestClsLoanPdfController {

    static testMethod void testMethod1() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = page.loanpdf;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Permanent_Address_Province__c = 'MB';
        applicationList[0].First_Name__c = NULL;
        applicationList[0].Middle_Name__c = NULL;
        applicationList[0].Last_Name__c = NULL;
        applicationList[0].Permanent_Address_Street_Number__c = NULL;
        applicationList[0].Permanent_Address_Street_Name__c = NULL;
        applicationList[0].Permanent_Address_Unit_Number__c = NULL;
        
        applicationList[0].Home_Phone__c = NULL;
        applicationList[0].Birth_Date__c = NULL;
        applicationList[0].Email_Address__c = NULL;
        applicationList[0].Loan_Amount__c = null;
        applicationList[0].Interest_Rate__c = null;
        applicationList[0].Number_of_Payments__c = null;
        applicationList[0].Loan_Start_Date__c = null;
        applicationList[0].Regular_Payment_Amount__c = null;
        applicationList[0].First_Payment_Amount__c = null;
        applicationList[0].Pay_Day__c = null;
        applicationList[0].First_Payment_Date__c =NULL;
        applicationList[0].Total_of_Payment__c =null;
        
        
        
        update applicationList[0] ;
        
        Test.startTest();
        ClsLoanPdfController obj = new ClsLoanPdfController();
        Test.stopTest();
        
    }
        
    static testMethod void testMethod2() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = page.loanpdf;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Permanent_Address_Province__c = 'MB';
        applicationList[0].First_Name__c = 'MB';
        applicationList[0].Middle_Name__c = 'MB';
        applicationList[0].Last_Name__c = 'MB';
        applicationList[0].Permanent_Address_Street_Number__c = 'MB';
        applicationList[0].Permanent_Address_Street_Name__c = 'MB';
        applicationList[0].Permanent_Address_Unit_Number__c = 'MB';
        
        applicationList[0].Home_Phone__c = 'MB';
        applicationList[0].Birth_Date__c = startDate;
        applicationList[0].Email_Address__c = 'MB@mb.com';
        applicationList[0].Loan_Amount__c = 100;
        applicationList[0].Interest_Rate__c = 0;
        applicationList[0].Number_of_Payments__c = 0;
        applicationList[0].Loan_Start_Date__c = startDate;
        applicationList[0].Regular_Payment_Amount__c = 1;
        applicationList[0].First_Payment_Amount__c = 1;
        applicationList[0].Pay_Day__c = 1;
        applicationList[0].First_Payment_Date__c =startDate;
        applicationList[0].Total_of_Payment__c =11;
        
        update applicationList[0] ;
        
        Test.startTest();
        ClsLoanPdfController obj = new ClsLoanPdfController();
        Test.stopTest();
        
    }
    
    static testMethod void testMethod3() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = page.loanpdf;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Permanent_Address_Province__c = 'MB';
        applicationList[0].First_Name__c = NULL;
        applicationList[0].Middle_Name__c = NULL;
        applicationList[0].Last_Name__c = NULL;
        applicationList[0].Permanent_Address_Street_Number__c = NULL;
        applicationList[0].Permanent_Address_Street_Name__c = NULL;
        applicationList[0].Permanent_Address_Unit_Number__c = NULL;
        
        applicationList[0].Home_Phone__c = NULL;
        applicationList[0].Birth_Date__c = NULL;
        applicationList[0].Email_Address__c = NULL;
        applicationList[0].Loan_Amount__c = null;
        applicationList[0].Interest_Rate__c = null;
        applicationList[0].Number_of_Payments__c = null;
        applicationList[0].Loan_Start_Date__c = null;
        applicationList[0].Regular_Payment_Amount__c = null;
        applicationList[0].First_Payment_Amount__c = null;
        applicationList[0].Pay_Day__c = null;
        applicationList[0].First_Payment_Date__c =NULL;
        applicationList[0].Total_of_Payment__c =null;
        
        update applicationList[0] ;
        
        Test.startTest();
        ClsLoanPdfController obj = new ClsLoanPdfController();
        Test.stopTest();        
    }
    
    static testMethod void testMethod4() {
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        PageReference pRef = page.loanpdf;
        
        pRef.getParameters().put('id', applicationList[0].Id);
        
        Test.setCurrentPage(pRef);
        Date startDate = Date.newInstance(2008, 1, 1);
        
        applicationList[0].Permanent_Address_Province__c = 'MB';
        applicationList[0].First_Name__c = 'MB';
        applicationList[0].Middle_Name__c = 'MB';
        applicationList[0].Last_Name__c = 'MB';
        applicationList[0].Permanent_Address_Street_Number__c = 'MB';
        applicationList[0].Permanent_Address_Street_Name__c = 'MB';
        applicationList[0].Permanent_Address_Unit_Number__c = 'MB';
        
        applicationList[0].Home_Phone__c = 'MB';
        applicationList[0].Birth_Date__c = startDate;
        applicationList[0].Email_Address__c = 'MB@mb.com';
        applicationList[0].Loan_Amount__c = 100;
        applicationList[0].Interest_Rate__c = 0;
        applicationList[0].Number_of_Payments__c = 0;
        applicationList[0].Loan_Start_Date__c = startDate;
        applicationList[0].Regular_Payment_Amount__c = 1;
        applicationList[0].First_Payment_Amount__c = 1;
        applicationList[0].Pay_Day__c = 1;
        applicationList[0].First_Payment_Date__c =startDate;
        applicationList[0].Total_of_Payment__c =11;
        
        update applicationList[0] ;
        
        Test.startTest();
        ClsLoanPdfController obj = new ClsLoanPdfController();
        Test.stopTest();
    }
    
    Public static List<Application__c> createApplication(Account objAccount) {
        List<Application__c> appList = new List<Application__c>();      
        Application__c  appObject1 = new Application__c();
        appObject1.Loan_Type__c = 'Affirm Financial Term Loan';
        appObject1.Loan_Amount__c = 1500;
        appObject1.Decision__c = 'Test Result1';
        appObject1.Application_Status__c = 'Test Satus1';
        appObject1.Application_Fullfillment_Status__c = 'Loan Declined';
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