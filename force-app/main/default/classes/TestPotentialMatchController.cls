/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of PotentialMatchController
 *  @author : A5E Consulting
 *  @date : 03/30/2016
 *
 *  Change History:
 *
 *  Developer       Date          Description
 *  ------------------------------------------------------------------------------------------------
 *
 *  A5E Consulting 03/30/2016     Class created
 *  A5E Consulting 04/07/2016     Test Code for multiple exact matches
 *  A5E Consulting 04/07/2016     Test Code for multiple incertain matches
 *  A5E Consulting 04/07/2016     Test Code for multiple incertain matches
 *  A5E Consulting 04/07/2016     Test Code for no selection
 *  A5E Consulting 04/07/2016     Test Code for multiple selection
 *  A5E Consulting 04/07/2016     Test Code for one selection 
 *  A5E Consulting 04/07/2016     Test Code for new Account for application selection 
 *  A5E Consulting 04/08/2016     Use Factory class for records creation 
 *  A5E Consulting 05/04/2016     Test Method Updates
 
 *************************************************************************************************/
@isTest
public class TestPotentialMatchController{
    
    //Multiple Exact Matches
    static testmethod void testMultipleExactMatches(){
        
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
        
        PageReference pageRef = Page.PotentialMatch;
        Test.setCurrentPage(pageRef);  
        ApexPages.currentPage().getParameters().put('id', appln.Id);  
        
        PotentialMatchController pmc = new PotentialMatchController(new ApexPages.StandardController(appln)); 
        
        TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        pmc.createNewNAssign();
        /*
        Application__c applnDB = getApplicationById(appln.Id);
        System.assertEquals(null, applnDB.Manual_Review_Reason__c);
        System.assertEquals(false, applnDB.Needs_Manual_Review__c);  
        System.assertNotEquals(null, applnDB.Customer__c); 
        */
        Test.stopTest();   
    }
    
    //Multiple Uncertain Matches
    static testmethod void testMultipleUncertainMatches(){
        
        //Create Uncertain Match Accounts
        TestRecordsFactory.TestAccountWrapper accntWrapper1 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper1.firstName = 'first1';
        accntWrapper1.lastName = 'lastName';
        accntWrapper1.email = 'testuser@testOrg.com';
        Account exactMatch1 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper1, true);
                
        TestRecordsFactory.TestAccountWrapper accntWrapper2 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper2.firstName = 'first2';
        accntWrapper2.lastName = 'lastName';
        accntWrapper2.email = 'testuser@testOrg.com';
        Account exactMatch2 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper2, true);
        
        TestRecordsFactory.TestAccountWrapper accntWrapper3 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper3.firstName = 'first3';
        accntWrapper3.lastName = 'lastName';
        accntWrapper3.email = 'testuser@testOrg.com';
        Account exactMatch3 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper3, true);
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        appln.customer__c = exactMatch1.Id;
        update appln;
        
        PageReference pageRef = Page.PotentialMatch;
        Test.setCurrentPage(pageRef);  
        ApexPages.currentPage().getParameters().put('id', appln.Id);  
        
        //None Selected
        PotentialMatchController pmc = new PotentialMatchController(new ApexPages.StandardController(appln)); 
        pmc.assignSelected(); 
        
        //More than one selected 
        pmc = new PotentialMatchController(new ApexPages.StandardController(appln));        
        List<PotentialMatchAccountWrapper> existingWrappedAccounts = pmc.existingWrappedAccounts;
        for(PotentialMatchAccountWrapper existingWrappedAccount : existingWrappedAccounts){
            existingWrappedAccount.selected = true; 
        }
        pmc.assignSelected(); 
        
        //Only one selected 
        pmc = new PotentialMatchController(new ApexPages.StandardController(appln)); 
        System.debug('pmc.existingWrappedAccounts :'+pmc.existingWrappedAccounts.size());       
        existingWrappedAccounts = pmc.existingWrappedAccounts;
        System.debug('existingWrappedAccounts :'+existingWrappedAccounts.size()); 
        PotentialMatchAccountWrapper oneSelected = existingWrappedAccounts.get(0);
        oneSelected.selected = true;
        
        //Initialize PowerCurve mock settings
        TestRecordsFactory.initializePowerCurveMock();
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockAcceptResponse());
        pmc.assignSelected(); 
        
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
        
        //Create Account
        TestRecordsFactory.TestAccountWrapper accntWrapper1 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper1.firstName = 'firstName';
        accntWrapper1.lastName = 'lastName';
        accntWrapper1.email = 'testuser@testOrg.com';
        Account exactMatch1 = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper1, true);
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = PotentialMatchUtil.APP_NAME_MANUAL_REVIEW;
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';        
        applnWrapper.manualReviewReason = PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES; 
        applnWrapper.needsManualReview = true;        
        Application__c appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        appln.customer__c = exactMatch1.Id;
        update appln;
        
        PageReference pageRef = Page.PotentialMatch;
        Test.setCurrentPage(pageRef);  
        ApexPages.currentPage().getParameters().put('id', appln.Id);  
        
        //Keep Same Customer
        PotentialMatchController pmc = new PotentialMatchController(new ApexPages.StandardController(appln)); 
        pmc.keepSameCustomer(); 
                
        Application__c applnDB = getApplicationById(appln.Id);
        System.assertEquals(null, applnDB.Manual_Review_Reason__c);
        System.assertEquals(false, applnDB.Needs_Manual_Review__c);
    }
    
    //Customer Matching updates
    private static Application__c getApplicationById(Id applicationId) {
        
        Application__c applnDB = [SELECT Id, Customer__c, Needs_Manual_Review__c, Manual_Review_Reason__c     
                                  FROM Application__c WHERE Id =: applicationId
                                 ];    
        return applnDB;
    }   
    
}