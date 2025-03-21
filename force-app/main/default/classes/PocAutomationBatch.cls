/**
 * @description       : Batch class for automation POC generation
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-05-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class PocAutomationBatch implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    public Application_Config_Settings__c appConfig = Application_Config_Settings__c.getInstance();
    public set<String> setInsolvencyAccountIds = new Set<String>();
    public Database.Querylocator start(Database.BatchableContext bc) {
        List<String> validVotingDecisions = new List<String>{ 'Manually Approved', 'Manually Rejected', 'Auto Approved' };
        return Database.getQueryLocator(
            'SELECT Id,(SELECT Name, Description FROM Attachments),(Select Name From Document_Storages__r),Name,Insolvency__r.Trustee__r.Is_Active__c,CTB_Statements_Received__c,Insolvency_Status_Last_Changed__c,Excluded_from_Purchase__c,Secured_Name__c,Business_Account__c,Insolvency_Type__c,Voting_Decision__c,Insolvency__r.Name,Insolvency__r.Debtor_2_Estate_Number__c,Insolvency__r.Eligible_For_Voting_Decision__c,Insolvency__r.Voting_Decision__c,Insolvency__r.Debtor_1_Mailing_City__c,Insolvency__r.Debtor_1_Mailing_State_Province__c,Insolvency__r.Insolvency_Type__c,Insolvency__r.Trustee_Communication_Preference_Formula__c,Portfolio_Group_Name__c,Vendor_Orginator__c,Portfolio_Name_Lookup__c,Investment_Group__c,Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,Insolvency__r.Trustee__r.BillingPostalCode,Insolvency__r.Trustee__r.BillingCountry,Insolvency__r.Trustee__r.Preferred_Language__c,Insolvency__r.Debtor_1_Mailing_Street__c,Insolvency__r.Debtor_2_Mailing_Street__c,Insolvency__r.Debtor_2_Mailing_City__c,Insolvency__r.Debtor_1_Mailing_Postal_Code__c,Insolvency__r.Debtor_2_Mailing_Postal_Code__c,Insolvency__r.Debtor_1_Court_Number__c,Insolvency__r.Debtor_2_Court_Number__c,Insolvency__r.Court_District_Name__c,Insolvency__r.Court_Division_Number__c,Insolvency__r.Court_Province__c,Insolvency__r.Insolvency_Date__c,Secured_Asset_Amount__c,Security_Description__c,Vehicle_Identification_Number__c,Voting_Letter_Comments__c,Claim_Type__c,Claim_Amount__c,Amended_Claim_Flag__c,Insolvency__r.Trustee__r.Name,Insolvency__r.Trustee__r.Parent.Name,Client_Identifier__c,Last_Payment_Date__c,Last_Payment_Amount__c,Interest_Rate__c,Insolvency_Status__c,Asset_Status__c,Insolvency__r.Debtor_1_First_Name__c,Insolvency__r.Debtor_1_Last_Name__c,Insolvency__r.Debtor_1_Middle_Name__c,Insolvency__r.Debtor_2_First_Name__c,Insolvency__r.Debtor_2_Last_Name__c,Insolvency__r.Debtor_2_Middle_Name__c,Bank_Name__c,Statements_Required__c,Proof_of_Claim_Required__c,Voting_Options__c,Include_Voting_Letter__c,Amended_PoC_Created_Date__c,PoC_Created_Date__c,Account_Type__c,Charge_Off_Date__c,Account_Original_Open_Date__c,Last_Payment_Date_2__c,Last_Payment_Date_3__c,Last_Payment_Amount_2__c,Last_Payment_Amount_3__c,Acknowledgement_date__c,Debt_Due_As_Of_Date__c,Auto_POC_Exception_Reported__c,Account_Open_date__c,Judgement_Date__c FROM Insolvency_Account__c Where Insolvency_Status__c = \'PoC Details Provided\' AND Portfolio_Name_Lookup__r.Non_Servicing_Portfolio__c = FALSE AND Auto_POC_Exception_Reported__c = null AND Insolvency__c != null AND (Insolvency_Type__c != \'Consumer Proposal\' OR (Insolvency_Type__c = \'Consumer Proposal\' AND Voting_Decision__c IN :validVotingDecisions))'
        );
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PocAutomationBatch(), 20);
    }

    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> insolvAccList) {
        try {
            startProcessing(insolvAccList);
        } catch (Exception ex) {
            System.debug('Exception in PocAutomationBatch ' + ex.getStackTraceString());
            PocDocUtility.updateErrorAccounts(insolvAccList, ex.getMessage() + '\n' + ex.getStackTraceString());
            insert PocDocUtility.handleException(ex, insolvAccList[0].Id);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!setInsolvencyAccountIds.isEmpty()) {
            Database.executeBatch(new PocSendEmailBatch(setInsolvencyAccountIds), 2);
        }
    }

    /**
     * @description : Method to process insolvency accounts for POC generation
     * @author adesh.ikhar@canaccede.com | 08-22-2024
     * @param insolvAccList
     **/
    public void startProcessing(List<Insolvency_Account__c> insolvAccList) {
        List<String> insolvencyIdListToUpdate = new List<String>();
        List<Insolvency_Account__c> updateAcctList = new List<Insolvency_Account__c>();
        List<ContentVersion> conVerInsertList = new List<ContentVersion>();
        List<ContentDocumentLink> conDocLinkInsertList = new List<ContentDocumentLink>();
        for (Insolvency_Account__c insolvAcc : insolvAccList) {
            // Ignore CTB accounts whose statement received checkbox is false and today's date is not greater than 5 business days from last status changed date
            if (
                insolvAcc.Client_Identifier__c == 'Canadian Tire' &&
                !insolvAcc.CTB_Statements_Received__c &&
                !PocDocUtility.isTodayOutsideGivenBusinessDateRange(insolvAcc.Insolvency_Status_Last_Changed__c, 4)
            ) {
                continue;
            }
            // Check if account is eligible to generate POC
            Map<String, String> pocDocErrorMap = PocDocUtility.validateRecord(insolvAcc);
            // If any error is returned during validation
            if (String.isNotBlank(pocDocErrorMap.get('Reason_for_POC_Automation_Failure__c'))) {
                // Update the account with error message and exception
                updateAcctList.add(
                    new Insolvency_Account__c(
                        Id = insolvAcc.Id,
                        Reason_for_POC_Automation_Failure__c = pocDocErrorMap.get('Reason_for_POC_Automation_Failure__c'),
                        Auto_POC_Exception_Reported__c = pocDocErrorMap.get('Auto_POC_Exception_Reported__c')
                    )
                );
                continue;
            }
            Map<String, String> variableMap = PocDocUtility.getVariableMap(insolvAcc);
            String language = String.isBlank(insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c)
                ? 'English'
                : insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c;
            String vfPageName = PocDocUtility.getPdfVfPageName(variableMap.get('pageName'), language);
            Blob pdf = generatePdf(vfPageName, variableMap);
            ContentVersion conVer = PocDocUtility.generateContentVersionRecord(variableMap.get('insolAccName'), insolvAcc);
            conVer.VersionData = pdf;
            conVerInsertList.add(conVer);
            updateAcctList.add(PocDocUtility.updateAccountFields(insolvAcc));
            insolvencyIdListToUpdate.add(insolvAcc.Insolvency__c);
        }
        updateData(conVerInsertList, updateAcctList, insolvencyIdListToUpdate);
    }

    /**
     * @description : Method to update all records after generation of POC
     * @author adesh.ikhar@canaccede.com | 08-22-2024
     * @param attachmentInsertList
     * @param updateAcctList
     * @param insolvencyIdListToUpdate
     **/
    public void updateData(List<ContentVersion> conVerInsertList, List<Insolvency_Account__c> updateAcctList, List<String> insolvencyIdListToUpdate) {
        List<Insolvency__c> insolvencyListToUpdate = new List<Insolvency__c>();
        Set<Id> setInsolAccIds = new Set<Id>();
        Savepoint sp = Database.setSavepoint();
        List<ContentDocumentLink> conDocLinkInsertList = new List<ContentDocumentLink>();
        try {
            InsolvencyTriggerHandler.runInsolvencyTrigger = false;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            if (!conVerInsertList.isEmpty()) {
                Database.insert(conVerInsertList);
            }
            Set<Id> setOfConVerIds = new Set<Id>();
            for(ContentVersion conVer : conVerInsertList){
                setOfConVerIds.add(conVer.Id);
            }
            List<ContentVersion> insertedConVersionList = [SELECT Id, ContentDocumentId, EmailMessageId__c, InsolvencyAccountId__c FROM ContentVersion WHERE Id in : setOfConVerIds];
            for(ContentVersion conVer : insertedConVersionList){
                ContentDocumentLink insolvAccConDocLink = new ContentDocumentLink();
                insolvAccConDocLink.ContentDocumentId = conVer.ContentDocumentId;
                insolvAccConDocLink.LinkedEntityId = conVer.InsolvencyAccountId__c;
                insolvAccConDocLink.ShareType = 'V';
                insolvAccConDocLink.Visibility = 'AllUsers';           
                conDocLinkInsertList.add(insolvAccConDocLink);
            }
            if(conDocLinkInsertList.size() > 0){
                insert conDocLinkInsertList;
            }
            if (!updateAcctList.isEmpty()) {
                Database.SaveResult[] srList = Database.update(updateAcctList, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        setInsolAccIds.add(sr.getId());
                    }
                }
                for (Insolvency_Account__c insolvAcc : [SELECT Id, Auto_POC_Exception_Reported__c FROM Insolvency_Account__c WHERE Id = :setInsolAccIds]) {
                    if (insolvAcc.Auto_POC_Exception_Reported__c == null) {
                        setInsolvencyAccountIds.add(insolvAcc.Id);
                    }
                }
            }

            if (!insolvencyIdListToUpdate.isEmpty()) {
                insolvencyListToUpdate = getInsolvencyListToUpdate(insolvencyIdListToUpdate);
                if (!insolvencyListToUpdate.isEmpty()) {
                    Database.update(insolvencyListToUpdate);
                }
            }
            InsolvencyTriggerHandler.runInsolvencyTrigger = true;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        } catch (DMLException dex) {
            System.debug('Exception in PocAutomationBatch ' + dex.getDMLMessage(0));
            Database.rollback(sp);
            insert PocDocUtility.handleException(dex, dex.getDmlId(0));
        }
    }

    /**
     * @description : Method to generate PDF using VF page for POC
     * @author adesh.ikhar@canaccede.com | 08-22-2024
     * @param pdfPageName
     * @param variableMap
     * @return Blob
     **/
    public Blob generatePdf(String pdfPageName, Map<String, String> variableMap) {
        PageReference pdf;
        String partialPageUrl = appConfig.Use_new_POC_templates__c && !(pdfPageName.contains('Fairstone') || pdfPageName.contains('MoneyMart'))
            ? '/apex/' + pdfPageName + 'New'
            : '/apex/' + pdfPageName;
        pdf = new PageReference(partialPageUrl);
        pdf.getParameters().put('id', variableMap.get('accntId'));
        pdf.getParameters().put('statementOfAccount', variableMap.get('statementOfAccount'));
        pdf.getParameters().put('votingLetter', variableMap.get('form37'));
        pdf.getParameters().put('proofOfClaim', variableMap.get('form31'));

        pdf.getParameters().put('unSecClaim', variableMap.get('unSecClaim'));
        pdf.getParameters().put('dontClaim', variableMap.get('dontClaim'));
        pdf.getParameters().put('secureClaim', variableMap.get('secureClaim'));

        pdf.getParameters().put('voteForAcceptance', variableMap.get('voteForAcceptance'));
        pdf.getParameters().put('voteAgainstAcceptance', variableMap.get('voteAgainstAcceptance'));
        pdf.getParameters().put('meetingOfCredits', variableMap.get('meetingOfCredits'));

        Blob body;
        if (!Test.IsRunningTest()) {
            body = pdf.getContent();
        } else {
            body = Blob.valueOf('Test');
        }
        return body;
    }

    /**
     * @description : Method to update count of POC details provided accounts on parent Insolvency
     * @author adesh.ikhar@canaccede.com | 08-22-2024
     * @param insolvencyIdListToUpdate
     * @return List<Insolvency__c>
     **/
    public List<Insolvency__c> getInsolvencyListToUpdate(List<String> insolvencyIdListToUpdate) {
        List<Insolvency__c> insolvencyListToUpdate = new List<Insolvency__c>();
        for (Insolvency__c insolvency : [
            SELECT Id, (SELECT Id FROM Insolvency_Accounts__r WHERE Insolvency_Status__c = 'PoC Details Provided')
            FROM Insolvency__c
            WHERE Id IN :insolvencyIdListToUpdate
        ]) {
            insolvency.Number_of_POC_Details_Provided_Accounts__c = insolvency.Insolvency_Accounts__r.size();
            insolvencyListToUpdate.add(insolvency);
        }
        return insolvencyListToUpdate;
    }
}