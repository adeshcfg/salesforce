/**************************************************************************************************
*
*  Class:   
*  @description : This testclass will test validation of is the trigger is off from custom settings
*  @author : A5E Consulting
*  @date : 04th March 2024
*  task  :  6159
*************************************************************************************************/
@isTest
public class TestAlertEmailOnTriggerOFF{
 @isTest
  Public static void TestbachClass(){
        //Custom setting record creation
        Application_Config_Settings__c config = new Application_Config_Settings__c ();
        config.name = 'Test name';
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        insert config;
        System.debug('creted record id'+config);

        Loan_ReEngineering__c loanReEng = new Loan_ReEngineering__c ();
        loanReEng.name = 'Test name';
        loanReEng.Run_Product_Trigger__c = true;
        loanReEng.Run_Product_Payment_Trigger__c = false;
        insert loanReEng;
        System.debug('creted record id'+loanReEng);

        Test.startTest();
        AlertEmailOnTriggerOFF batchRun = new AlertEmailOnTriggerOFF ();
        Id batchId = Database.executeBatch(batchRun);
        system.debug('Batch id'+ batchId);
        Test.stopTest();
    }
  }