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
  @testSetup
  static testMethod void TestbachClass(){
        //Custom setting record creation
        Application_Config_Settings__c config = new Application_Config_Settings__c ();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        insert config;
        System.debug('creted record id'+config);

        Test.startTest();
        AlertEmailOnTriggerOFF batchRun = new AlertEmailOnTriggerOFF ();
        Id batchId = Database.executeBatch(batchRun);
        system.debug('Batch id'+ batchId);
        Test.stopTest();
    }
  }