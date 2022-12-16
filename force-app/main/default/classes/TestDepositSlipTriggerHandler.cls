/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a trigger handler class for Deposit Slip object. The code is not bulkified. 
*  @author : A5E Consulting
*  @date : 10/01/2019

*************************************************************************************************/


@isTest
private class TestDepositSlipTriggerHandler {
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Deposit_Slip_Trigger__c = true;
        INSERT config;  
    }
    
    static testMethod void DepositSlipTriggerHandlerTest(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'User',
                            FirstName='Test',
                            Alias = 'utest',
                            Email = 'test.user@asdf.com',
                            Username = 'test.user@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        
        System.runAs(usr){ 
            List<Deposit_Slip__c> depSlipList = new List<Deposit_Slip__c>();
            Deposit_Slip__c depSlip = new Deposit_Slip__c();
            /*depSlip.Total_Accounts__c = 2;
            depSlip.Total_CIHI_Accounts__c = 1;
            depSlip.Total_Equitable_Accounts__c = 1;
            */
            Deposit_Slip__c depSlip1 = new Deposit_Slip__c();
            /*depSlip1.Total_Accounts__c = 4;
            depSlip1.Total_CIHI_Accounts__c = 1;
            depSlip1.Total_Equitable_Accounts__c = 1;
            depSlip1.Total_Fortress_Accounts__c = 1;
            depSlip1.Total_Equitable_Accounts__c = 1;
            */
            depSlipList.add(depSlip);
            depSlipList.add(depSlip1);
            INSERT depSlipList;
            
            Map<ID, Deposit_Slip__c> depSlipMap = new Map<ID, Deposit_Slip__c>();
            depSlipMap.put(depSlipList[1].id, depSlipList[0]);
            Test.startTest();    
            DELETE depSlipList;
            DepositSlipTriggerHandler.handleBeforeDelete(depSlipList, depSlipMap);
            Test.stopTest();    
        } 
    }   
}