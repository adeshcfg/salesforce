/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of PotentialMatchUtil
 *  @author : A5E Consulting
 *  @date : 04/08/2016
 *
 *  Change History:
 *
 *  Developer       Date          Description
 *  ------------------------------------------------------------------------------------------------
 *
 *  A5E Consulting 04/08/2016     Class created
 *  A5E Consulting 04/08/2016     Test Code to test Exact Match utility method
 *  A5E Consulting 04/08/2016     Test Code to test Uncertain Match utility method
 *  A5E Consulting 04/08/2016     Test Code to test populateAccountFieldsBasedOnApplication 
 *  A5E Consulting 04/08/2016     Use Factory class for records creation
 *  A5E Consulting 04/08/2016     Test Method for  Factory class for records creation
  
 *************************************************************************************************/
@isTest
public class TestPotentialMatchUtil{
    
    //Test for Exact Match utility method
    static testmethod void testGetExactMatchList(){ 
        
        Date testBirthDate = System.today().addYears(-30);
        
        //Create Exact Match Accounts
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'firstName';
        accntWrapper.lastName = 'lastName';
        accntWrapper.email = 'testuser@testOrg.com';
        accntWrapper.sin = 'dummysin'; 
        accntWrapper.birthDate = testBirthDate;     
        Account exactMatch1 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);
        Account exactMatch2 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';
        applnWrapper.sin = 'dummysin';  
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_EXACT_MATCHES; 
        applnWrapper.needsManualReview = true;
        applnWrapper.birthDate = testBirthDate;
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        //System.assertEquals(2, PotentialMatchUtil.getExactMatchList(appln).size());    
    }
    
    //Test for Uncertain Match utility method
    static testmethod void testGetUncertainMatchList(){ 
        
        //Create Uncertain Match Accounts
        TestRecordsFactory.TestAccountWrapper accntWrapper1 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper1.firstName = 'first';
        accntWrapper1.lastName = 'lastName';
        accntWrapper1.email = 'testuser@testOrg.com';
        Account exactMatch1 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper1, true);
                
        TestRecordsFactory.TestAccountWrapper accntWrapper2 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper2.firstName = 'fi';
        accntWrapper2.lastName = 'lastName';
        accntWrapper2.email = 'testuser@testOrg.com';
        Account exactMatch2 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper2, true);
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        //System.assertEquals(2, PotentialMatchUtil.getUncertainMatchList(appln).size());    
    }
    
    //Test for passignSelectedAccountToApplication method
    static testmethod void testAssignSelected(){ 
        
        //Create Account 
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'first';
        accntWrapper.lastName = 'lastName';
        accntWrapper.email = 'testuser@testOrg.com';
        Account accnt = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);           
               
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());        
        PotentialMatchUtil.assignSelectedAccountToApplication(accnt.Id, appln.Id);
        
        /*
        Application__c applnDB = getApplicationById(appln.Id);
        System.assertEquals(null, applnDB.Manual_Review_Reason__c);
        System.assertEquals(false, applnDB.Needs_Manual_Review__c);  
        System.assertNotEquals(null, applnDB.Customer__c);
        */
        Test.stopTest();
    }
    
    //Test for createNewAccountAndAssignToApplication method
    static testmethod void testCreateNewAccountAndAssignToApplication(){ 
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        PotentialMatchUtil.createNewAccountAndAssignToApplication(appln.Id);
        
        /*
        Application__c applnDB = getApplicationById(appln.Id);
        System.assertEquals(null, applnDB.Manual_Review_Reason__c);
        System.assertEquals(false, applnDB.Needs_Manual_Review__c);  
        System.assertNotEquals(null, applnDB.Customer__c);
        */
        Test.stopTest();
    }
    
    //Test for keepSameCustomer method
    static testmethod void testKeepSameCustomer(){ 
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        PotentialMatchUtil.keepSameCustomer(appln.Id);
                
        Application__c applnDB = getApplicationById(appln.Id);
        System.assertEquals(null, applnDB.Manual_Review_Reason__c);
        System.assertEquals(false, applnDB.Needs_Manual_Review__c);
    }
    
    //Customer Matching updates
    //Test Uncertain Match utility method
    /*
    static testmethod void testResubmitToPCOD(){ 
        //Create Account 
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'first';
        accntWrapper.lastName = 'lastName';
        accntWrapper.email = 'testuser@testOrg.com';
        Account accnt = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);           
               
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        PotentialMatchUtil.resubmitToPCOD(accnt, appln); 
        Test.stopTest();
                
        Application__c dbAppln = getApplicationById(appln.Id);
        System.assertEquals(false, dbAppln.Needs_Manual_Review__c); 
        System.assertEquals(null, dbAppln.Manual_Review_Reason__c); 
        System.assertEquals(accnt.Id, dbAppln.Customer__c);            
    }
    */
    
    //Test Uncertain Match utility method
    static testmethod void testPopulateAccountFieldsBasedOnApplication(){       
        //Create Account 
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'AccntFirst';
        accntWrapper.lastName = 'AccntLast';
        accntWrapper.email = 'accnt@testorg.com';
        accntWrapper.sin = 'acctSIN';          
        Date accntBirthDate = System.today().addYears(-20);
        accntWrapper.birthDate = accntBirthDate;
        Account accnt = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);           
               
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = 'Test Application';
        applnWrapper.firstName = 'ApplnFirst';
        applnWrapper.lastName = 'ApplnLast';
        applnWrapper.email = 'appln@testorg.com';  
        applnWrapper.sin = 'appSIN';  
        Date applnBirthDate = System.today().addYears(-30);
        applnWrapper.birthDate = applnBirthDate;
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        PotentialMatchUtil.populateAccountFieldsBasedOnApplication(accnt, appln);  
        Account accntDB = getAccountById(accnt.Id);
        System.assertEquals('ApplnFirst', accntDB.FirstName); 
        System.assertEquals('ApplnLast', accntDB.LastName); 
        System.assertEquals('appln@testorg.com', accntDB.PersonEmail); 
        System.assertEquals(applnBirthDate, accntDB.PersonBirthdate); 
        System.assertEquals('appSIN', accntDB.SIN__pc);         
    }
  
    //Get Application record based on Id
    private static Application__c getApplicationById(Id applicationId) {
        
        Application__c applnDB = [SELECT Id, Customer__c, Needs_Manual_Review__c, Manual_Review_Reason__c     
                                  FROM Application__c WHERE Id =: applicationId
                                 ];    
        return applnDB;
    } 
    
    //Get Account record based on Id
    private static Account getAccountById(Id accntId) {
        
        Account accntDB = [SELECT Id, FirstName, LastName, PersonEmail, PersonBirthdate, SIN__pc      
                           FROM Account WHERE Id =: accntId 
                          ];    
        return accntDB;        
    } 
}