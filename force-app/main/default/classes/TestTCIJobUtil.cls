/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is test class
 *  @author : A5E Consulting
 *  @date : 08/18/2016 
 
 *************************************************************************************************/
@isTest
public class TestTCIJobUtil{

    static testMethod void testTCIJobUtil() {
        //Create TCI Job Custom Setting
        TestRecordsFactory.createTciCSRecords();
        
        RecordType fidRecType = [ Select Id, Name from RecordType where SObjectType = 'Application__c' and Name = 'Fidem Finance MasterCard'];
                
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
        
        appln.Application_Status__c = 'Completed - Credit Card';
        appln.Decision__c = 'Completed';
        appln.Loan_Type__c='Affirm Financial MasterCard';
        //appln.Completed_CreditCard_DateTime__c=System.now() - 1;
        appln.Decision_Timestamp__c=System.now() - 1;
        appln.RecordTypeId = fidRecType.Id;
        update appln;
        
        New TCIJobUtil().initiateTCIJob('Manual');
        New TCIJobUtil().initiateTCIJob('Scheduled');
        
        Application__c appln1 = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        appln1.Application_Status__c = 'Completed - Credit Card';
        appln1.Decision__c = 'Completed';
        appln1.Loan_Type__c='Affirm Financial MasterCard';
        //appln1.Completed_CreditCard_DateTime__c=System.now() - 1;
        appln1.Decision_Timestamp__c=System.now() - 2;
        appln1.First_Name__c = 'Julli A@#$';
        appln1.Last_Name__c = '';
        appln1.Interest_Rate_Code__c = 'OTB2';
        appln1.Birth_Date__c = null;
        appln1.Lender_Approved_Amount__c = null;
        appln1.DSR_Score__c = null;
        appln1.Permanent_Address_PO_Box__c = '90';
        appln1.Application_Number__c = 'AFI90987';
        appln1.Years_At_Permanent_Address__c = null;
        appln1.RecordTypeId = fidRecType.Id;
        update appln1;
        
        Application__c appln2 = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        appln2.Application_Status__c = 'Completed - Credit Card';
        appln2.Decision__c = 'Completed';
        appln2.Loan_Type__c='Affirm Financial MasterCard';
        //appln2.Completed_CreditCard_DateTime__c=System.now() - 1;
        appln2.Decision_Timestamp__c=System.now() - 3;
        appln2.First_Name__c = 'Julli A@#$';
        appln2.Last_Name__c = '';
        appln2.Interest_Rate_Code__c = 'OTB6';
        appln2.Lender_Approved_Amount__c = 99;
        appln2.RecordTypeId = fidRecType.Id;
        update appln2;
        
        New TCIJobUtil().initiateTCIJob('Manual');
        New TCIJobUtil().initiateTCIJob('Scheduled');
    }        
}