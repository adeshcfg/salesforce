/***************************************************
 * Author         : A5E Consultancy
 * Created On     : 1 March 2020
 * Description    : Send email to trustee if they are unsecured and doesnt do payment for 18 months
 *
 ***************************************************/
public class TrusteeFollowupBatch implements Database.Batchable<sobject>, Database.Stateful {
    public EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Trustee_Followup_Email_Template'];

    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        // List values to be used as filters in SOQL query
        List<String> assetStatus = new List<String>{ '', 'Purchased', 'Debt Purchase', 'Bulk Purchased' };
        List<String> insolvencyTypes = new List<String>{ 'Consumer Proposal', 'Division 1 Proposal' };
        List<String> insolvencyAccntRecordTypes = System.Label.Trustee_Follow_Up_Record_Types.split(',');

        Trustee_Payment_Followup_Setting__c tpfs = Trustee_Payment_Followup_Setting__c.getValues('Trustee Payment Followup');
        Integer additionalFollowupXMonths = Integer.ValueOf(tpfs.Additional_Follow_up_After_X_Months__c);
        Date monthsPriorFromToday = System.today().addmonths(-additionalFollowupXMonths);
        Integer followUpMaxLimit = Integer.ValueOf(tpfs.Follow_up_Max_Limit__c);

        // Fetch all active unsecured accounts
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Trustee__c,
                    Name,
                    Missing_Payment_Follow_up_Sent_Date__c,
                    Trustee_Email_Address_Formula__c,
                    Trustee_Communication_Preference_Formula__c,
                    Trustee_Fax_Formula__c,
                    Client_Identifiers__c,
                    Debtor_1_First_Name__c,
                    Debtor_1_Last_Name__c,
                    Follow_Up_Counter__c,
                    (
                        SELECT Id, Name, Debtor_1_Estate_Number__c, Creditor_Name__c
                        FROM Insolvency_Accounts__r
                        WHERE
                            Asset_Status__c IN :assetStatus
                            AND Excluded_from_Purchase__c = FALSE
                            AND Insolvency_Status__c = 'Claim Filed'
                            AND RecordType.DeveloperName IN :insolvencyAccntRecordTypes
                            AND Claim_Type__c = 'Unsecured'
                            AND Claim_Amount__c >= 250
                            AND Date_NOD_received__c = NULL
                            AND Disallowance_Reasons__c = NULL
                            AND ((Send_Follow_up_Email__c = TRUE
                            AND Missing_Payment_Follow_up_Sent_Date__c = NULL)
                            OR (Missing_Payment_Follow_up_Sent_Date__c != NULL
                            AND Missing_Payment_Follow_up_Sent_Date__c <= :monthsPriorFromToday))
                    )
                FROM Insolvency__c
                WHERE
                    Insolvency_Status__c = 'Active'
                    AND Insolvency_Type__c IN :insolvencyTypes
                    AND ((Send_Follow_up_Email__c = TRUE
                    AND Missing_Payment_Follow_up_Sent_Date__c = NULL)
                    OR (Follow_Up_Counter__c <= :followUpMaxLimit
                    AND Missing_Payment_Follow_up_Sent_Date__c != NULL
                    AND Missing_Payment_Follow_up_Sent_Date__c <= :monthsPriorFromToday))
                    AND Trustee__c != NULL
                    AND Trustee__r.Is_Active__c = TRUE
                    AND Trustee__r.Exclude_From_Missing_Payment_Mail_List__c = FALSE
            ]
        );
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
        for (Insolvency__c insolvency : insolvencies) {
            if (insolvency.Trustee__c != null) {
                trusteeIds.add(insolvency.Trustee__c);
            }
        }

        Map<Id, Account> trusteeMap = new Map<Id, Account>(
            [
                SELECT
                    Id,
                    Number_Of_Emails_Sent_Today__c,
                    Communication_Preference__c,
                    Business_Email__c,
                    Fax,
                    Last_Trustee_Followup_Sent_Date__c,
                    Follow_up_Email__c
                FROM Account
                WHERE Id IN :trusteeIds
            ]
        );

        for (Insolvency__c insolvency : insolvencies) {
            Account trustee = trusteeMap.get(insolvency.Trustee__c);
            // Get Insolvency Account related to Account
            List<Insolvency_Account__c> insolvencyAccounts = insolvency.Insolvency_Accounts__r;
            if (!insolvencyAccounts.isEmpty()) {
                // Use custom setting to read maximum emails to be sent
                if (trustee.Number_Of_Emails_Sent_Today__c < maxEmailsSentPerDay && insolvencyAccounts != null && insolvencyAccounts.size() > 0) {
                    //Create Email
                    Messaging.SingleEmailMessage email = TrusteeFollowUpBatchHelper.generateSingleEmailMessage(
                        trustee,
                        insolvency,
                        insolvencyAccounts,
                        emailTemplate
                    );
                    if (email != null) {
                        singleEmailMessages.add(email);
                        trustee.Number_Of_Emails_Sent_Today__c = trustee.Number_Of_Emails_Sent_Today__c + 1; // Increment number of emails Sent
                        trusteeMap.put(insolvency.Trustee__c, trustee);

                        // Increment follow up counter
                        if (insolvency.Follow_Up_Counter__c == null) {
                            insolvency.Follow_Up_Counter__c = 0;
                        }
                        insolvency.Follow_Up_Counter__c = insolvency.Follow_Up_Counter__c + 1;

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
        if (!singleEmailMessages.isEmpty()) {
            if (!Test.isRunningTest()) {
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(singleEmailMessages);
            }
            if (!trusteeMap.isEmpty()) {
                update trusteeMap.values();
            }

            if (!insolvenciesToUpdate.isEmpty()) {
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
