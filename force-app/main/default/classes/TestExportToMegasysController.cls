/**************************************************************************************************
*
*  Class:   
*
*  @description : ExportToMegasysController for Validate Application.
*  @author : A5E Consulting
*  @date : 08/25/2016   

*************************************************************************************************/
@isTest
public class TestExportToMegasysController{
    
    static testMethod void testMegaSys(){
        
        Date testBirthDate = System.today().addYears(-30);
        
        //Create Account
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'firstName';
        accntWrapper.lastName = 'lastName';
        accntWrapper.email = 'testuser@testOrg.com';
        accntWrapper.sin = 'dummysin'; 
        accntWrapper.birthDate = testBirthDate;     
        Account accnt = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = 'RedecideApp';
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';
        applnWrapper.sin = 'dummysin';  
        applnWrapper.birthDate = testBirthDate;
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        appln.Application_Fullfillment_Status__c = 'Completed';
        appln.Loan_Type__c = 'Affirm Financial MasterCard';  
        appln.Megasys_Loan_Number__c = null;
        update appln;
        
        //Application with credit card
        testCrediCardApp(appln);
        
        //Application with Term Loan 
        testTermLoanApp(appln);
        
        //Fulfillment status is Blank
        testFulfillmentBlank(appln);
        
        //application with incomplete information
        testIncompleteApplication(appln);
        
        //Execute Error Messages
        testDataApplication(appln);
        
        //calling Megasys with complete application
        testFullApplication(appln);
        
    }
    
    //Application Fulfillment Status is balnk
    private static void testFulfillmentBlank(Application__c appln){
        appln.Application_Fullfillment_Status__c = '';
        update appln;
        
        PageReference pageRef1 = Page.ExportToMegasys;
        Test.setCurrentPage(pageRef1);  
        System.currentPageReference().getParameters().put('id', appln.Id);
        
        ExportToMegasysController ctrl1 = New ExportToMegasysController();
        ctrl1.callMegasys();
    }
    
    //Application with credit card
    private static void testCrediCardApp(Application__c appln){
        
        PageReference pageRef = Page.ExportToMegasys;
        Test.setCurrentPage(pageRef);  
        System.currentPageReference().getParameters().put('id', appln.Id);
        System.currentPageReference().getParameters().put('appFulfill', appln.Application_Fullfillment_Status__c);  
        
        ExportToMegasysController ctrl = New ExportToMegasysController();
        ctrl.callMegasys();       
    }
    
    //Application with Term Loan
    private static void testTermLoanApp(Application__c appln){
        
        appln.Loan_Type__c = 'Affirm Financial Term Loan';
        appln.Application_Fullfillment_Status__c = null;
        appln.Megasys_Loan_Number__c = '';
        update appln;
        PageReference pageRef = Page.ExportToMegasys;
        Test.setCurrentPage(pageRef);  
        System.currentPageReference().getParameters().put('id', appln.Id);
        
        ExportToMegasysController ctrl = New ExportToMegasysController();
        ctrl.callMegasys();       
    }
    
    //application with incomplete information
    private static void testIncompleteApplication(Application__c appln){
        appln.Application_Fullfillment_Status__c = 'Completed';
        appln.Loan_Type__c = 'Affirm Financial Term Loan';
        appln.Birth_Date__c = system.today() - 30;
        appln.Gender__c = null;
        appln.Marital_Status__c = null;
        appln.Number_of_Dependants__c = null;
        appln.work_Phone__c = null;
        appln.Cell_Phone__c = null;
        appln.Home_Phone__c = null;
        appln.Permanent_Address_Type__c = null;
        appln.Permanent_Address_Province__c = null;
        appln.Months_At_Permanent_Address__c = null;
        appln.Years_At_Permanent_Address__c = null;
        appln.Employer_Province__c = null;
        appln.Employer_Address_Type__c = null;
        appln.Employment_Years__c = null;
        appln.Employment_Months__c = null;
        appln.Gross_Monthly_Income__c = null;
        appln.Monthly_Expenses__c = null;
        appln.Payment__c = null;
        appln.Loan_Start_Date__c = null;
        appln.First_Payment_Date__c = null;
        appln.Number_of_Payments__c = null;
        appln.First_Payment_Amount__c = null;
        appln.Regular_Payment_Amount__c = null;
        appln.Total_of_Payment__c = null;
        appln.Loan_Amount__c = null;
        appln.Birth_Date__c = null;
        appln.First_Name__c = null;
        appln.Last_Name__c = null;
        update appln;
        
        PageReference pageRef1 = Page.ExportToMegasys;
        Test.setCurrentPage(pageRef1);  
        System.currentPageReference().getParameters().put('id', appln.Id);
        System.currentPageReference().getParameters().put('appFulfill', appln.Application_Fullfillment_Status__c);  
        
        ExportToMegasysController ctrl1 = New ExportToMegasysController();
        ctrl1.callMegasys();
    }
    
    //calling Megasys with complete application
    private static void testFullApplication(Application__c appln){
        
        appln.Application_Fullfillment_Status__c = 'Ready For Export';
        appln.Loan_Type__c = 'Affirm Financial Term Loan';
        appln.Gender__c = 'Male';
        appln.Marital_Status__c = 'Single';
        appln.Number_of_Dependants__c = '0';
        appln.work_Phone__c = '1233211233';
        appln.Cell_Phone__c = '1233211233';
        appln.Home_Phone__c = '1233211233';
        appln.SIN__c='123';
        appln.Permanent_Address_PO_Box__c = '1';
        appln.Permanent_Address_City__c = 'StreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCity';
        appln.Permanent_Address_Unit_Number__c = '11222222';
        appln.Permanent_Address_Street_Number__c = '1StreetNumber';
        appln.Permanent_Address_Street_Name__c = '121 StreetName StreetName StreetNameStreetName';
        appln.Permanent_Address_Unit_Number__c = '11222222';
        appln.Employer_Street_Number__c = '1StreetNumber';
        appln.Employer_Unit_Number__c = '1';
        appln.Employer_Street_Name__c = '121 StreetName StreetName StreetNameStreetName';
        appln.Employer_City__c = 'StreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCityStreetCity ';
        appln.Permanent_Address_Type__c = 'Physical';
        appln.Permanent_Address_Province__c = 'null';
        appln.Months_At_Permanent_Address__c = 0;
        appln.Years_At_Permanent_Address__c = 0;
        appln.Employer_Province__c = '12';
        appln.Employer_Address_Type__c = 'Physical';
        appln.Employment_Years__c = 0;
        appln.Employment_Months__c = 0;
        appln.Gross_Monthly_Income__c = 0;
        appln.Monthly_Expenses__c = 0;
        appln.Payment__c = 'Monthly';
        appln.Loan_Start_Date__c = System.today();
        appln.First_Payment_Date__c = System.today();
        appln.Number_of_Payments__c = 0;
        appln.First_Payment_Amount__c = 0;
        appln.Regular_Payment_Amount__c = 0;
        appln.Total_of_Payment__c = 0;
        appln.Loan_Amount__c = 0;
        appln.Birth_Date__c = System.today() - 30000;
        update appln;
        
        PageReference pageRef2 = Page.ExportToMegasys;
        Test.setCurrentPage(pageRef2);  
        System.currentPageReference().getParameters().put('id', appln.Id);
        System.currentPageReference().getParameters().put('appFulfill', appln.Application_Fullfillment_Status__c);  
        
        ExportToMegasysController ctrl2 = New ExportToMegasysController();
        ctrl2.callMegasys();
    }
    
    //calling Megasys with Incomplete Data
    private static void testDataApplication(Application__c appln){
        
        appln.Application_Fullfillment_Status__c = 'Ready For Export';
        appln.Loan_Type__c = 'Affirm Financial Term Loan';
        appln.Gender__c = null;
        appln.Marital_Status__c = null;
        appln.Number_of_Dependants__c = null;
        appln.work_Phone__c = null;
        appln.Cell_Phone__c = null;
        appln.Home_Phone__c = null;
        appln.Permanent_Address_Type__c = null;
        appln.Permanent_Address_Province__c = null;
        appln.Months_At_Permanent_Address__c = null;
        appln.Years_At_Permanent_Address__c = null;
        appln.Employer_Province__c = null;
        appln.Employer_Address_Type__c = null;
        appln.Employment_Years__c = null;
        appln.Employment_Months__c = null;
        appln.Gross_Monthly_Income__c = null;
        appln.Monthly_Expenses__c = null;
        appln.Payment__c = null;
        appln.Loan_Start_Date__c = null;
        appln.First_Payment_Date__c = null;
        appln.Number_of_Payments__c = null;
        appln.First_Payment_Amount__c = null;
        appln.Regular_Payment_Amount__c = null;
        appln.Total_of_Payment__c = null;
        appln.Loan_Amount__c = null;
        update appln;
        
        PageReference pageRef2 = Page.ExportToMegasys;
        Test.setCurrentPage(pageRef2);  
        System.currentPageReference().getParameters().put('id', appln.Id);
        System.currentPageReference().getParameters().put('appFulfill', appln.Application_Fullfillment_Status__c);  
        
        ExportToMegasysController ctrl2 = New ExportToMegasysController();
        ctrl2.callMegasys();
    }
}