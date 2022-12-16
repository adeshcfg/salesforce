@isTest
Private class TestLoanDocumentController{

    static testMethod void validate1(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Loan_ReEngineering__c lrp = new Loan_ReEngineering__c();
        lrp.File_Formats__c = '.pdf.jpeg';
        lrp.File_Size__c = 2000;
        insert lrp;
        
        Test.startTest();
            PageReference pageRef = Page.pdfdocs;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',applicationList[0].id); 
            ClsLoanDocument loanDoc = new ClsLoanDocument();
            loanDoc.applicationId = applicationList[0].id;
            loanDoc.loanDocument.body = Blob.valueOf('This is sample body');
            loanDoc.loanDocument.Name = 'Sample_Test.pdf';
            
            loanDoc.upload();
            loanDoc.checkValueFunction();
            loanDoc.saveData();
            loanDoc.downloadPage();
            loanDoc.goBack();
        Test.stopTest();
    }
    
    static testMethod void validate2(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Loan_ReEngineering__c lrp = new Loan_ReEngineering__c();
        lrp.File_Formats__c = '.pdf.jpeg';
        lrp.File_Size__c = 2000;
        insert lrp;
        
        Test.startTest();
            PageReference pageRef = Page.pdfdocs;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',applicationList[0].id); 
            ClsLoanDocument loanDoc = new ClsLoanDocument();
            loanDoc.applicationId = applicationList[0].id;
            loanDoc.loanDocument.body = Blob.valueOf('This is sample body');
            loanDoc.loanDocument.Name = 'Sample_Test.csv';
            
            loanDoc.upload();
            
        Test.stopTest();
    }
    
    static testMethod void validate3(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Loan_ReEngineering__c lrp = new Loan_ReEngineering__c();
        lrp.File_Formats__c = '.pdf.jpeg';
        lrp.File_Size__c = 2000;
        insert lrp;
        
        Test.startTest();
            PageReference pageRef = Page.pdfdocs;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',applicationList[0].id); 
            ClsLoanDocument loanDoc = new ClsLoanDocument();
            loanDoc.applicationId = applicationList[0].id;
            loanDoc.loanDocument.body = null;
            
            loanDoc.upload();
            
        Test.stopTest();
    }
    
    static testMethod void validate4(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Loan_ReEngineering__c lrp = new Loan_ReEngineering__c();
        lrp.File_Formats__c = '.pdf.jpeg';
        lrp.File_Size__c = 2000;
        insert lrp;
        
        applicationList[0].Decision__c = 'Declined';
        update applicationList[0];
        
        Test.startTest();
            PageReference pageRef = Page.pdfdocs;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',applicationList[0].id); 
            ClsLoanDocument loanDoc = new ClsLoanDocument();
                       
        Test.stopTest();
    }
    
    static testMethod void validate5(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Loan_ReEngineering__c lrp = new Loan_ReEngineering__c();
        lrp.File_Formats__c = '.pdf.jpeg';
        lrp.File_Size__c = 2000;
        insert lrp;
        
        applicationList[0].Loan_Type__c = 'Affirm Financial MasterCard';
        update applicationList[0];
        
        Test.startTest();
            PageReference pageRef = Page.pdfdocs;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',applicationList[0].id); 
            ClsLoanDocument loanDoc = new ClsLoanDocument();
                       
        Test.stopTest();
    }
    
    static testMethod void validate6(){
        Account accObject = createAccount();
        List<Application__c> applicationList = createApplication(accObject);
        Loan_ReEngineering__c lrp = new Loan_ReEngineering__c();
        lrp.File_Formats__c = '.pdf.jpeg';
        lrp.File_Size__c = 2000;
        insert lrp;
        
        applicationList[0].Application_Fullfillment_Status__c = 'Completed';
        update applicationList[0];
        
        Test.startTest();
            PageReference pageRef = Page.pdfdocs;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',applicationList[0].id); 
            ClsLoanDocument loanDoc = new ClsLoanDocument();
                       
        Test.stopTest();
    }
    
    Public static List<Application__c> createApplication(Account objAccount){
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
     
}