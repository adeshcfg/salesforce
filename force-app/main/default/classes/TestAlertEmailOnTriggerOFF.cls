/**************************************************************************************************
*
*  Class:   
*  @description : This testclass will test validation of is the trigger is off from custom settings
*  @author : A5E Consulting
*  @date : 04th March 2024
*  task  :  6159
*************************************************************************************************/
@isTest
public class TestAlertEmailOnTriggerOFF {

    @isTest
    static void testBatchExecution() {
        // Create test data for Application_Config_Settings__c
        List<Application_Config_Settings__c> configListrecordList = new List<Application_Config_Settings__c>();

        configList = [Select ID,name, Run_JudgmentTrigger__c,Run_Account_Judgment_Trigger__c,Run_Account_Trigger__c ,
        Run_Attachment_Trigger__c,Run_Case_Trigger__c,Run_Customer_Update_API_for_Portal__c,Run_Deposit_Slip_Trigger__c,
        Run_Distressed_Notes_Trigger__c,Run_Document_Storage_Trigger__c,Run_EmailMessage_Trigger__c,
        Run_Insolvency_Account_Duplicate_Check__c,Run_Insolvency_Trigger__c,Run_Insolvency_Account_Trigger__c,
        Run_Insolvency_Payment_Trigger__c,Run_Insolvency_Status_Validations__c,Run_Merchant_Account_Payment_Trigger__c,
        Run_Product_Coll_Sub_Status_Validation__c,Run_Record_Ownership__c,Run_Remittance_Trigger__c,
        Run_Remittance_Validation__c ,Run_Work_Assignment_Trigger__c from Application_Config_Settings__c];
      
        for(Application_Config_Settings__c config : configList ){
        config.name = 'Test name';
        config.Run_JudgmentTrigger__c = false;
        config.Run_Deposit_Slip_Trigger__c = false;
        config.Run_Account_Judgment_Trigger__c=false;
        config.Run_Case_Trigger__c = false;
        config.Run_Attachment_Trigger__c = false;
        config.Run_Customer_Update_API_for_Portal__c = false;
        config.Run_Deposit_Slip_Trigger__c = false;
        config.Run_Distressed_Notes_Trigger__c = false;
        config.Run_Document_Storage_Trigger__c = false;
        config.Run_EmailMessage_Trigger__c = false;
        config.Run_Document_Storage_Trigger__c = false;
        config.Run_Insolvency_Account_Trigger__c = false;
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Status_Validations__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = false;
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Merchant_Account_Payment_Trigger__c = false;
        config.Run_Product_Coll_Sub_Status_Validation__c = false;
        config.Run_Record_Ownership__c = false;
        config.Run_Remittance_Trigger__c = false;
        config.Run_Remittance_Validation__c = false;
        config.Run_Work_Assignment_Trigger__c = false;
        configList.add(config);
       }        
        insert configList;
        System.debug('creted record id'+config);
      

        // Create test data for Loan_ReEngineering__c
            list<Loan_ReEngineering__c> loanList = new List <Loan_ReEngineering__c> ();

            loanRecordsList = [Select id,name,	Run_Attachment_Trigger__c,Run_Product_Before_Trigger__c,Run_Product_Trigger__c,
            Run_Product_Validation_Trigger__c,Run_Settlement_Trigger__c,Run_PTP_Trigger__c,
            Run_Product_Payment_Trigger__c from Loan_ReEngineering__c];

            for(Loan_ReEngineering__c loanRecords : loanRecordsList ){
            loanRecords.name = 'test name';
            loanRecords.Run_Attachment_Trigger__c = false;
            loanRecords.Run_Product_Before_Trigger__c = false;
            loanRecords.Run_Product_Trigger__c = false;
            loanRecords.Run_Product_Payment_Trigger__c = false;
            loanRecords.Run_Product_Validation_Trigger__c = false;
            loanRecords.Run_Settlement_Trigger__c = false;
            loanRecords.Run_PTP_Trigger__c = false;
            loanRecords.Run_Product_Payment_Trigger__c = false;
            loanList.add(loanRecords);
            } 
            insert loanList;
            System.debug('creted record id'+loanRecords);

        Test.startTest();
        AlertEmailOnTriggerOFF batchInstance = new AlertEmailOnTriggerOFF();
        Database.executeBatch(batchInstance);
        Test.stopTest();

    }
}