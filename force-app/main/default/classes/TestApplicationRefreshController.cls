/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of ApplicationRefreshController
 *  @author : A5E Consulting
 *  @date : 08/05/2016 *
 *  
 
 *************************************************************************************************/
@isTest
public class TestApplicationRefreshController{
    
    static testmethod void testApplicationRefreshController(){
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = 'Refresh App';
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';
        applnWrapper.sin = 'dummysin';  
        Application__c refreshApp = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
        //Refresh The Page
        PageReference pageRef = Page.ApplicationRefresh;
        Test.setCurrentPage(pageRef);  
        ApexPages.currentPage().getParameters().put('id', refreshApp.Id);
        ApplicationRefreshController cntr = new ApplicationRefreshController(new ApexPages.StandardController(refreshApp)); 
        cntr.checkRefreshFlag(); 
        
        //Don't refresh The Page
        refreshApp.Call_Status__c = 'In Progress';  
        update refreshApp;  
        pageRef = Page.ApplicationRefresh;
        Test.setCurrentPage(pageRef);  
        ApexPages.currentPage().getParameters().put('id', refreshApp.Id);
        cntr = new ApplicationRefreshController(new ApexPages.StandardController(refreshApp)); 
        cntr.checkRefreshFlag();
    }        
}