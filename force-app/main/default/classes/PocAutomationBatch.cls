/**
 * @description       : Batch class for automation POC generation
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 08-22-2024
 * @last modified by  : adesh.ikhar@canaccede.com
**/
public class PocAutomationBatch implements Database.Batchable<SObject> {
    public Application_Config_Settings__c appConfig = Application_Config_Settings__c.getInstance();
    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id,Name,Excluded_from_Purchase__c,Secured_Name__c,Business_Account__c,Insolvency_Type__c,Insolvency__r.Name,Insolvency__r.Debtor_2_Estate_Number__c,Insolvency__r.Eligible_For_Voting_Decision__c,Insolvency__r.Voting_Decision__c,Insolvency__r.Debtor_1_Mailing_City__c,Insolvency__r.Debtor_1_Mailing_State_Province__c,Insolvency__r.Insolvency_Type__c,Insolvency__r.Trustee_Communication_Preference_Formula__c,Portfolio_Group_Name__c,Vendor_Orginator__c,Portfolio_Name_Lookup__c,Investment_Group__c,Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,Insolvency__r.Trustee__r.BillingPostalCode,Insolvency__r.Trustee__r.BillingCountry,Insolvency__r.Debtor_1_Mailing_Street__c,Insolvency__r.Debtor_2_Mailing_Street__c,Insolvency__r.Debtor_2_Mailing_City__c,Insolvency__r.Debtor_1_Mailing_Postal_Code__c,Insolvency__r.Debtor_2_Mailing_Postal_Code__c,Insolvency__r.Debtor_1_Court_Number__c,Insolvency__r.Debtor_2_Court_Number__c,Insolvency__r.Court_District_Name__c,Insolvency__r.Court_Division_Number__c,Insolvency__r.Court_Province__c,Insolvency__r.Insolvency_Date__c,Secured_Asset_Amount__c,Security_Description__c,Vehicle_Identification_Number__c,Voting_Letter_Comments__c,Claim_Type__c,Claim_Amount__c,Amended_Claim_Flag__c,Insolvency__r.Trustee__r.Name,Insolvency__r.Trustee__r.Parent.Name,Client_Identifier__c,Last_Payment_Date__c,Last_Payment_Amount__c,Interest_Rate__c,Insolvency_Status__c,Asset_Status__c,Insolvency__r.Debtor_1_First_Name__c,Insolvency__r.Debtor_1_Last_Name__c,Insolvency__r.Debtor_1_Middle_Name__c,Insolvency__r.Debtor_2_First_Name__c,Insolvency__r.Debtor_2_Last_Name__c,Insolvency__r.Debtor_2_Middle_Name__c,Bank_Name__c,Statements_Required__c,Proof_of_Claim_Required__c,Voting_Options__c,Include_Voting_Letter__c,Amended_PoC_Created_Date__c,PoC_Created_Date__c,Account_Type__c,Charge_Off_Date__c,Account_Original_Open_Date__c,Last_Payment_Date_2__c,Last_Payment_Date_3__c,Last_Payment_Amount_2__c,Last_Payment_Amount_3__c,Acknowledgement_date__c,Debt_Due_as_off_date__c,Account_Open_date__c FROM Insolvency_Account__c Where Insolvency_Status__c = \'PoC Details Provided\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> insolvAccList) {
        try {
            startProcessing(insolvAccList);
        } catch (Exception ex) {
            System.debug('Exception in PocAutomationBatch ' + ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    /**
    * @description : Method to process insolvency accounts for POC generation
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param insolvAccList 
    **/
    public void startProcessing(List<Insolvency_Account__c> insolvAccList) {
        List<String> insolvencyIdListToUpdate = new List<String>();
        List<Insolvency_Account__c> updateAcctList = new List<Insolvency_Account__c>();
        List<Attachment> attachmentInsertList = new List<Attachment>();
        List<Insolvency__c> insolvencyListToUpdate = new List<Insolvency__c>();
        Map<Integer, String> frenchDates = PocDocUtility.frenchDates;
        for(Insolvency_Account__c insolvAcc : insolvAccList) {
            // Check if account is eligible to generate POC
            Map<String, String> pocDocErrorMap = PocDocUtility.validateRecord(insolvAcc);
            // If any error is returned during validation
            if(String.isNotBlank(pocDocErrorMap.get('Reason_for_POC_Automation_Failure__c'))) {
                // Update the account with error message and exception
                updateAcctList.add(new Insolvency_Account__c(
                    Id = insolvAcc.Id, 
                    Reason_for_POC_Automation_Failure__c = pocDocErrorMap.get('Reason_for_POC_Automation_Failure__c'),
                    Auto_POC_Exception_Reported__c = pocDocErrorMap.get('Auto_POC_Exception_Reported__c')
                ));
                continue;
            }
            Map<String, String> variableMap = PocDocUtility.getVariableMap(insolvAcc);
            String vfPageName = PocDocUtility.getPdfVfPageName(variableMap.get('pageName'), insolvAcc.Insolvency__r.Trustee_Communication_Preference_Formula__c);
            Blob pdf = generatePdf(vfPageName, variableMap);
            attachmentInsertList.add(PocDocUtility.generateAttachmentRecord(variableMap.get('insolAccName'), insolvAcc));
            updateAcctList.add(PocDocUtility.updateAccountFields(insolvAcc));
            insolvencyIdListToUpdate.add(insolvAcc.Id);
        }
        if(!insolvencyIdListToUpdate.isEmpty()) {
            insolvencyListToUpdate = getInsolvencyListToUpdate(insolvencyIdListToUpdate);
        }
        updateData(attachmentInsertList, updateAcctList, insolvencyListToUpdate);
    }

    /**
    * @description : Method to update all records after generation of POC
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param attachmentInsertList 
    * @param updateAcctList 
    * @param insolvencyListToUpdate 
    **/
    public void updateData(List<Attachment> attachmentInsertList, List<Insolvency_Account__c> updateAcctList, List<Insolvency__c> insolvencyListToUpdate) {
        Savepoint sp = Database.setSavepoint();
        try {
            if(!attachmentInsertList.isEmpty()) {
                Database.insert(attachmentInsertList);
            }
            if(!updateAcctList.isEmpty()) {
                Database.update(updateAcctList);
            }
            if(!insolvencyListToUpdate.isEmpty()) {
                Database.update(insolvencyListToUpdate);
            }
        }
        catch(DMLException dex) {
            System.debug('Exception in PocAutomationBatch ' + dex.getDMLMessage(0));
            Database.rollback(sp);
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
        // Dynamically generate page reference for PDF
        ApexPage apexPage = [
            SELECT Name, NamespacePrefix
            FROM ApexPage
            WHERE Name = :pdfPageName
        ];

        String templatePageName = apexPage.Name;
        // append namespace if page is packaged
        if (String.isNotEmpty(apexPage.NamespacePrefix)) {
            templatePageName = apexPage.NamespacePrefix + '__' + templatePageName;
        }
        String partialPageUrl = appConfig.Use_new_POC_templates__c ? '/apex/' + templatePageName + 'New' : '/apex/' + templatePageName;
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
        for(Insolvency__c insolvency : [SELECT Id, (SELECT Id FROM Insolvency_Accounts__r WHERE Insolvency_Status__c = 'PoC Details Provided' ) FROM Insolvency__c WHERE Id IN :insolvencyIdListToUpdate]) {
            insolvency.Number_of_POC_Details_Provided_Accounts__c = insolvency.Insolvency_Accounts__r.size();
            insolvencyListToUpdate.add(insolvency);
        }
        return insolvencyListToUpdate;
    }
}