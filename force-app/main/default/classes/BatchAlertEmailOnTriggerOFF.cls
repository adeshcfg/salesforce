/**************************************************************************************************
*
*  Class:   
*  @description : This class will sending the email to the admin user if the trigger is off from custom settings
*  @author : A5E Consulting
*  @date : 04th March 2024
*  task  :  6159
*************************************************************************************************/
global class BatchAlertEmailOnTriggerOFF implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       // fatch the records of Costum setting //
        return Database.getQueryLocator([Select ID,name, Run_JudgmentTrigger__c,Run_Account_Judgment_Trigger__c,Run_Account_Trigger__c ,
                                         Run_Attachment_Trigger__c,Run_Case_Trigger__c,Run_Customer_Update_API_for_Portal__c,Run_Deposit_Slip_Trigger__c,
                                         Run_Distressed_Notes_Trigger__c,Run_Document_Storage_Trigger__c,Run_EmailMessage_Trigger__c,
                                         Run_Insolvency_Account_Duplicate_Check__c,Run_Insolvency_Trigger__c,Run_Insolvency_Account_Trigger__c,
                                         Run_Insolvency_Payment_Trigger__c,Run_Insolvency_Status_Validations__c,Run_Merchant_Account_Payment_Trigger__c,
                                         Run_Product_Coll_Sub_Status_Validation__c,Run_Record_Ownership__c,Run_Remittance_Trigger__c,
                                         Run_Remittance_Validation__c ,Run_Work_Assignment_Trigger__c from Application_Config_Settings__c]);
        
    }
    global void execute(Database.BatchableContext bc, List<Application_Config_Settings__c> listOfTriggers){
    
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    string triggerName = '';

    map<string,string> mapOfTriggers = new map<string,string>{
        'Run_JudgmentTrigger__c' => 'Run_JudgmentTrigger',
        'Run_Account_Judgment_Trigger__c' => 'Run Account Judgment Trigger',
        'Run_Case_Trigger__c' => 'Run Case Trigger',
        'Run_Attachment_Trigger__c' => 'Run Attachment Trigger',
        'Run_Customer_Update_API_for_Portal__c' => 'Run Customer Update API for Portal',
        'Run_Deposit_Slip_Trigger__c' => 'Run Deposit Slip Trigger',
        'Run_Distressed_Notes_Trigger__c' => 'Run Distressed Notes Trigger',
        'Run_Document_Storage_Trigger__c' => 'Run Document Storage Trigger',
        'Run_EmailMessage_Trigger__c' => 'Run EmailMessage Trigger',
        'Run_Document_Storage_Trigger__c' => 'Run Document Storage Trigger',
        'Run_Insolvency_Account_Trigger__c' => 'Run Insolvency Account Trigger',
        'Run_Insolvency_Payment_Trigger__c' => 'Run Insolvency Payment Trigger',
        'Run_Insolvency_Status_Validations__c' => 'Run Insolvency Status Validations',
        'Run_Insolvency_Account_Duplicate_Check__c' => 'Run Insolvency Account Duplicate Check',
        'Run_Insolvency_Trigger__c' => 'Run Insolvency Trigger',
        'Run_Merchant_Account_Payment_Trigger__c' => 'Run Merchant Account Payment Trigger',
        'Run_Product_Coll_Sub_Status_Validation__c' => 'Run Product Coll Sub Status Validation',
        'Run_Record_Ownership__c' => 'Run Record Ownership',
        'Run_Remittance_Trigger__c' => 'Run Remittance Trigger',
        'Run_Remittance_Validation__c' => 'Run Remittance Validation',
        'Run_Work_Assignment_Trigger__c' => 'Run Work Assignment Trigger'
    };

    for(Application_Config_Settings__c config : listOfTriggers){
         for(string mapingTriggerValue : mapOfTriggers.keySet()){ 
            if (config.get(mapingTriggerValue) == false){
                triggerName += mapOfTriggers.get(mapingTriggerValue) + ' is Off\n';
                 system.debug('product trigger value = '+ mapingTriggerValue);
                } 
            }
        }
       
        // product triggers //
        List<Loan_ReEngineering__c> productTriggerList = [Select id,name,	Run_Attachment_Trigger__c,Run_Product_Before_Trigger__c,Run_Product_Trigger__c,
                                                          Run_Product_Validation_Trigger__c,Run_Settlement_Trigger__c,Run_PTP_Trigger__c,
                                                          Run_Product_Payment_Trigger__c from Loan_ReEngineering__c];
        
        map<string,string> mapOfProductTriggers = new map<string,string>{
            'Run_Attachment_Trigger__c' => 'Run Attachment Trigger',
            'Run_Product_Before_Trigger__c' => 'Run Product Before Trigger',
            'Run_Product_Trigger__c' => 'Run Product Trigger',
            'Run_Product_Payment_Trigger__c' =>'Run Product Payment Trigger',
            'Run_Product_Validation_Trigger__c' => 'Run Product Validation Trigger',
            'Run_Settlement_Trigger__c' => 'Run Settlement Trigger',
            'Run_PTP_Trigger__c' => 'Run PTP Trigger',
            'Run_Product_Payment_Trigger__c' => 'Run Product Payment Trigger'
        };   
        for(Loan_ReEngineering__c productTrigger : productTriggerList){
            for(string productTriggerValue : mapOfProductTriggers.keySet()){ 
               if (productTrigger.get(productTriggerValue) == false){
                triggerName += mapOfProductTriggers.get(productTriggerValue) + ' is Off\n';
                    system.debug('product trigger value = '+ productTriggerValue);
                   } 
               }
           }
           List<Distress_Setting__c> distressTriggers = [select id,name,	Attachment_Size__c,Distressed_Task_Eligible_Objects__c,Run_Placement_History_Trigger__c from Distress_Setting__c ];
           
           map<string,string> distressTriggerMap = new map<string,string>{ 'Run_Placement_History_Trigger__c' => 'Run Placement History Trigger'
           };
           for(Distress_Setting__c distr : distressTriggers){
            for(string distresstTriggerValue : distressTriggerMap.keySet()){ 
               if (distr.get(distresstTriggerValue) == false){
                triggerName += distressTriggerMap.get(distresstTriggerValue) + ' is Off\n';
                    system.debug('product trigger value = '+ distresstTriggerValue);
                   } 
               }
           } 
                     
           // check the blanck //
            if( triggerName !=''){
                String userEmail =System.Label.API_Failed_Email;
                String[] toAddresses = new String[] {userEmail};    
                if(toAddresses.size() > 0){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(toAddresses);
                    email.setSubject('Notification: Trigger is Off');
                    email.setPlainTextBody('The below mentioned Trigger is off, check the "Application_Application Configuration" & "Loan Re-Engineering" custom setting \n\n'+ triggerName);
                    emails.add(email);
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: '
                                     + results[0].errors[0].message);
                }
            }
        }
    } 
     global void finish(Database.BatchableContext bc){
    }
}