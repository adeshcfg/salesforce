/***************************************************
* Author         : A5E Consultancy
* Created On     : 1 March 2020
* Description    : Send email to trustee if they are unsecured and doesnt do payment for 18 months
*
***************************************************/
public class TrusteeFollowupBatch implements Database.Batchable<sobject>, Database.Stateful{
        
    public EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Trustee_Followup_Email_Template'];

    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {

        // List values to be used as filters in SOQL query
        List<String> assetStatus = new List<String>{'', 'Purchased', 'Debt Purchase', 'Bulk Purchased'};
        List<String> insolvencyTypes = new List<String>{'Consumer Proposal', 'Division 1 Proposal'};
        List<String> insolvencyAccntRecordTypes = new List<String>{'Canaccede Insolvency Account', 'SDA Insolvency Account', 'SPL Insolvency Account', 'Scotia Bank Insolvency Account', 'Fairstone Insolvency Account'};
            
        Date months18ProiorDate = System.today().addmonths(-18);

        // Fetch all active unsecured accounts
        return Database.getQueryLocator ([SELECT Id, 
                                            Trustee__c,
                                            Name,
                                            Missing_Payment_Follow_up_Sent_Date__c,
                                            Trustee_Email_Address_Formula__c,
                                            Trustee_Communication_Preference_Formula__c,
                                            Trustee_Fax_Formula__c,
                                            Client_Identifiers__c,
                                            Debtor_1_First_Name__c,
                                            Debtor_1_Last_Name__c,
                                            (SELECT Id, Name, Debtor_1_Estate_Number__c
                                            FROM    Insolvency_Accounts__r
                                            
                                            WHERE   Asset_Status__c IN: assetStatus AND 
                                                    Excluded_from_Purchase__c = FALSE AND 
                                                    Insolvency_Status__c = 'Claim Filed' AND 
                                                    recordtype.name IN: insolvencyAccntRecordTypes AND
                                                    Claim_Type__c = 'Unsecured' AND 
                                                    Claim_Amount__c >= 250 AND
                                                    (Latest_Payment_Date__c = NULL OR Latest_Payment_Date__c <: months18ProiorDate)                                            
                                            )
                                            
                    
                                    FROM    Insolvency__c
                                    WHERE 
                                        Insolvency_Status__c = 'Active' AND 
                                        Insolvency_Date__c <: months18ProiorDate AND
                                        Insolvency_Type__c IN: insolvencyTypes AND                                       
                                        Missing_Payment_Follow_up_Sent_Date__c = null AND
                                        Trustee__c != null AND Trustee__r.Is_Active__c = true AND Trustee__r.Exclude_From_Missing_Payment_Mail_List__c = FALSE                                         
                                    ]);
        
        //Trustee__c != Null is addded because there are few Insolvencies without associated Trustee records 
                                         
    }

    // Execute method
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Trustee_Payment_Followup_Setting__c tpfs = Trustee_Payment_Followup_Setting__c.getValues('Trustee Payment Followup');
        Integer maxEmailsSentPerDay = Integer.ValueOf(tpfs.Maximum_Emails_Per_Day__c);
        List<Insolvency__c> insolvencies = (List<Insolvency__c>) scope;
        List<Messaging.SingleEmailMessage> singleEmailMessages = new List<Messaging.SingleEmailMessage>();
        
        //Eligible Insolvencies to update
        List<Insolvency__c> insolvenciesToUpdate = new List<Insolvency__c>();
        
        Set<Id> trusteeIds = new Set<Id>();
        for(Insolvency__c insolvency: insolvencies){
            if(insolvency.Trustee__c != null){
                trusteeIds.add(insolvency.Trustee__c);
            }
        }
        
        Map<Id, Account> trusteeMap = new Map<Id, Account>([ SELECT  Id,
                                                        Number_Of_Emails_Sent_Today__c,
                                                        Communication_Preference__c,
                                                        Business_Email__c,
                                                        Fax,
                                                        Last_Trustee_Followup_Sent_Date__c,Follow_up_Email__c 
                                                        FROM    Account 
                                                        WHERE 
                                                        Id IN: trusteeIds]);
        
        
        for(Insolvency__c insolvency: insolvencies){
            
            Account trustee = trusteeMap.get(insolvency.Trustee__c);

            // Get Insolvency Account related to Account
            List<Insolvency_Account__c> insolvencyAccounts = insolvency.Insolvency_Accounts__r;
            system.debug('insolvencyAccounts===>'+insolvencyAccounts);
            if(!insolvencyAccounts.isEmpty()){
                
                system.debug(' === '+trustee.Number_Of_Emails_Sent_Today__c);
                system.debug(' ===  insolvencyAccounts '+insolvencyAccounts);
                system.debug(' === '+insolvencyAccounts.size());
                
                // Use custom setting to read maximum emails to be sent 
                if(trustee.Number_Of_Emails_Sent_Today__c < maxEmailsSentPerDay && insolvencyAccounts != null && insolvencyAccounts.size()>0){
                            
                    
                    
                    //Create Email
                    Messaging.SingleEmailMessage email = TrusteeFollowUpBatchHelper.generateSingleEmailMessage(trustee, insolvency, insolvencyAccounts, emailTemplate);
                    if(email != null){
                        singleEmailMessages.add(email);
                        trustee.Number_Of_Emails_Sent_Today__c = trustee.Number_Of_Emails_Sent_Today__c +1; // Increment number of emails Sent
                        trusteeMap.put(insolvency.Trustee__c, trustee);
                        
                        //Set Missing Follow up Date
                        insolvency.Missing_payment_Follow_Up_Sent_Date__c = System.now();
                        
                        //Set Last Trustee Followup Sent Date
                        trustee.Last_Trustee_Followup_Sent_Date__c = System.now();
                        
                        //Insolvency is eligible for update
                        insolvenciesToUpdate.add(insolvency);

                    }                    
                }
            }
        }

        // Send emails and update Trustee, and Accounts
        if(!singleEmailMessages.isEmpty()){
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail( singleEmailMessages );
            
            if(!trusteeMap.isEmpty()){
                update trusteeMap.values();
            }
            
            if(!insolvenciesToUpdate.isEmpty()){
                InsolvencyTriggerHandler.runInsolvencyTrigger = false;
                update insolvenciesToUpdate;
                InsolvencyTriggerHandler.runInsolvencyTrigger = true;
            }           
        }
    }

    // Finish Method
    public void finish(Database.BatchableContext BC) {
        //Do Nothing
    }
}