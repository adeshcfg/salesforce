/**************************************************************************************************
*
*  Class:   
*
*  @description : Utility test class for MegaSys
*  @author : A5E Consulting
*  @date : 09/20/2016   

*************************************************************************************************/
@isTest
public class TestMegaSysUtilities {
    
    static testMethod void megaSysUtilitiesData(){
        
        //create Loan Re engineering Custom setting records
        Loan_ReEngineering__c ln = loanReCS();
        
        //create application record
        Application__c app = createApplicationRecords();
        
        //execute MegaSysUtilities methods
        MegaSysUtilities.getApplicationById(app.Id);
        //MegaSysUtilities.createProdRecord(app, '123321');
        MegaSysUtilities.createProdRecord(app);
        MegaSysUtilities.updateApplication(app);
        MegaSysUtilities.updateMSNumberOnApplication(app, '123321');
        MegaSysUtilities.getClassNumber();
        MegaSysUtilities.getAddressLine1('unitNumber', 'streetNumber', 'streetName');
        MegaSysUtilities.getAddressLine1('unit Number', 'streetNumber', 'streetName');
        MegaSysUtilities.getAddressLine1(null,'streetNumber', 'streetName');
        MegaSysUtilities.getAddressLine1('1',null, null);
        MegaSysUtilities.getAddressLine2('1');
        MegaSysUtilities.getAddressLine2(null);
    }
    
    //create Loan Re engineering Custom setting records
    private static Loan_ReEngineering__c loanReCS(){
        
        Loan_ReEngineering__c loanReCS = New  Loan_ReEngineering__c();  
        loanReCS.Megasys_Account_Import_Code__c = 'Affirm Term Loan Import';
        loanReCS.Megasys_Client_Number__c = '420';
        loanReCS.Megasys_End_Point__c = 'https://omegasandbox.megasys.net/Client/WebServices/CustomerPortal.asmx';
        loanReCS.Megasys_Password__c = 'testPass';
        loanReCS.Megasys_User_Name__c = 'testUserName';
        loanReCS.NSF_Fee_Amount__c = '0';
        insert loanReCS;
        return loanReCS;
    }
    
    //Create Application Records
    private static Application__c createApplicationRecords(){
        
        Date testBirthDate = System.today().addYears(-30);
        //create account records
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'firstName';
        accntWrapper.lastName = 'lastName';
        accntWrapper.email = 'testuser@testOrg.com';
        accntWrapper.sin = 'dummysin'; 
        accntWrapper.birthDate = testBirthDate;     
        Account accnt = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);
        
        //create application record
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = 'RedecideApp';
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';
        applnWrapper.sin = 'dummysin';  
        applnWrapper.birthDate = testBirthDate;
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        appln.Customer__c = accnt.Id;
        appln.Application_Fullfillment_Status__c = 'Ready To Export';
        appln.Loan_Type__c = 'Affirm Financial Term Loan';
        appln.Gender__c = 'Male';
        appln.Marital_Status__c = 'Single';
        appln.Number_of_Dependants__c = '0';
        appln.work_Phone__c = '1233211233';
        appln.Cell_Phone__c = '1233211233';
        appln.Home_Phone__c = '1233211233';
        appln.Permanent_Address_Type__c = 'Physical';
        appln.Permanent_Address_Province__c = 'null';
        appln.Months_At_Permanent_Address__c = 0;
        appln.Years_At_Permanent_Address__c = 0;
        appln.Employer_Province__c = '12';
        appln.Employer_Address_Type__c = 'Physical';
        appln.Employment_Years__c = 10;
        appln.Employment_Months__c = 10;
        appln.Gross_Monthly_Income__c = 10;
        appln.Monthly_Expenses__c = 10;
        appln.Payment__c = 'Monthly';
        appln.Loan_Start_Date__c = System.today();
        appln.First_Payment_Date__c = System.today();
        appln.Number_of_Payments__c = 10;
        appln.First_Payment_Amount__c = 10;
        appln.Regular_Payment_Amount__c = 10;
        appln.Total_of_Payment__c = 0;
        appln.Loan_Amount__c = 0;
        appln.Birth_Date__c = System.today() - 30000;
        appln.PAP_Transit_Code__c = '123';
        appln.PAP_Bank_Code__c = '123';
        appln.PAP_Account_Number__c = '123';
        appln.Interest_Rate__c = 1;
        appln.Application_Number__c = 'AFI123321';
        appln.PAP_Information_I_Accept_DateTime__c = System.now();
        appln.Disbursement__c = 123;
        appln.Loan_Process_Type__c = 'Traditional';
        update appln;
        
        return appln;
    }
}