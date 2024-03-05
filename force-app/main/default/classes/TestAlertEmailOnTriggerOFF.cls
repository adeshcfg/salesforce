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
        Application_Config_Settings__c config = new Application_Config_Settings__c ();
        config.name = 'Test name';
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        
        insert config;
        System.debug('creted record id'+config);
      

        // Create test data for Loan_ReEngineering__c
            Loan_ReEngineering__c loanReengineeringRecords = new Loan_ReEngineering__c ();
            loanReengineeringRecords.Run_Attachment_Trigger__c = true;
            loanReengineeringRecords.Run_Product_Before_Trigger__c = false;
            
            insert loanReengineeringRecords;
            System.debug('creted record id'+loanReengineeringRecords);

        Test.startTest();
        AlertEmailOnTriggerOFF batchInstance = new AlertEmailOnTriggerOFF();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        // Verify emails //
       
         List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id FROM Messaging.SingleEmailMessage];
         System.assertEquals(1, sentEmails.size(), 'One email should be sent');
         Messaging.SingleEmailMessage sentEmail = sentEmails[0];
         System.assertEquals('Notification: Trigger is Off', sentEmail.getSubject(), 'Email subject should match');
         System.assertEquals('Expected email body', sentEmail.getPlainTextBody(), 'Email body should match');
         System.assertEquals(1, sentEmail.getToAddresses().size(), 'Email should be sent to a specific address');
         System.assertEquals('testemail@email.com', sentEmail.getToAddresses()[0], 'Email should be sent to a specific address');
    }
}