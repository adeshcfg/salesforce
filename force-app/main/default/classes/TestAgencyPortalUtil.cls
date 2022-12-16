/**************************************************************************************************      
 *  @description : Test class for AgencyPortalUtil class 
 *  @author : A5E Consulting
 *  @date : 07/13/2022
 
 *************************************************************************************************/
@isTest
private class TestAgencyPortalUtil{
    // Test data for testgetUserNamefromEmail test method
    @TestSetup
    static void dataSetup() {
    
        Test.startTest();
        
        Agency_User__c agusr = new Agency_User__c();       
        agusr.Email_Address__c = 'test1@mymail.com';
        agusr.Role__c = 'Regular User'; 
        agusr.First_Name__c='FirstName';
        agusr.Last_Name__c ='LastName';
        
        AgencyUserTriggerHandler.runAgencyUserTrigger = false;
        insert agusr;
        AgencyUserTriggerHandler.runAgencyUserTrigger = true;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetUserNamefromEmail() {
        Test.startTest();
        
        //Agency user exists
        system.assertEquals('FirstName LastName', AgencyPortalUtil.getUserNamefromEmail('test1@mymail.com'));
        
        //Agency user does not exist
        system.assertEquals('test2@mymail.com', AgencyPortalUtil.getUserNamefromEmail('test2@mymail.com'));
        
        Test.stopTest();
    }    
}