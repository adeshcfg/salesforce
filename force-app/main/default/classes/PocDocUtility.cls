/**
 * @description       : Class to hold utility/common methods for POC document generation
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 08-27-2024
 * @last modified by  : adesh.ikhar@canaccede.com
**/
public class PocDocUtility {
    public static Map<Integer, String> frenchDates = new Map<Integer, String>{1 => 'Janvier', 2 => 'Février', 3 => 'Mars', 4 => 'Avril', 5 => 'Mai', 6 => 'Juin', 7 => 'Juillet', 8 => 'Août', 9 => 'Septembre', 10 => 'Octobre', 11 => 'Novembre', 12 => 'Décembre'};
    /**
    * @description : Method to check field validations before generating POC
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param insolvAcc 
    * @return Map<String, String> 
    **/
    public static Map<String, String> validateRecord(Insolvency_Account__c insolvAcc) {
        Map<String, String> exceptionErrorMessageMap = new Map<String, String>();
        List<String> eligibleVotingDecisions = new List<String>{'Auto Approved', 'Manually Approved', 'Manually Rejected'};
        String exceptionMsg = '';
        String errorMsg = '';
        if (insolvAcc.Proof_of_Claim_Required__c == false) {
            errorMsg += 'Cannot generate a proof of claim unless "Proof of Claim Required" checkbox is checked on this account';
        }
        if (insolvAcc.Insolvency_Status__c != 'PoC Details Provided') {
            errorMsg += '; Cannot generate a proof of claim unless this account is in "PoC Details Provided" status';
        }
        if (insolvAcc.Insolvency__r.Voting_Decision__c == 'Needs Manual Review') {
            errorMsg += '; Cannot generate a proof of claim when Voting Decision is Needs Manual Review';
        }
        if (insolvAcc.Client_Identifier__c == 'Canaccede' && insolvAcc.Vendor_Orginator__c == null) {
            errorMsg += '; Cannot generate a proof of claim unless this account has Vendor value populated on the account';
        }
        if (
            insolvAcc.Asset_Status__c != 'Purchased' &&
            insolvAcc.Asset_Status__c != 'Debt Purchase' &&
            insolvAcc.Asset_Status__c != 'Bulk Purchased' &&
            insolvAcc.Asset_Status__c != 'Duplicate Purchased'
        ) {
            errorMsg += '; Cannot generate a proof of claim unless this account is in Purchased / Debt Purchase / Bulk Purchased / Duplicate Purchased status';
        }
        if (
            insolvAcc.Client_Identifier__c == 'Canaccede' &&
            (insolvAcc.Portfolio_Group_Name__c == null ||
            insolvAcc.Portfolio_Name_Lookup__c == null ||
            insolvAcc.Investment_Group__c == null)
        ) {
            errorMsg += '; Cannot generate a proof of claim unless this account has Vendor value, Portfolio Group Name, Portfolio Name and Investment Group Name populated on the account';
        }
        if((insolvAcc.Insolvency_Type__c == 'Bankruptcy' || insolvAcc.Insolvency_Type__c == 'Division 1 Proposal') &&
            !eligibleVotingDecisions.contains(insolvAcc.Voting_Decision__c)
        ) {
            exceptionMsg += 'Missing Information';
            errorMsg += '; Voting Decision is not set correctly';
        }
        if((insolvAcc.Insolvency_Type__c == 'Bankruptcy' || insolvAcc.Insolvency_Type__c == 'Consumer Proposal') &&
            !insolvAcc.Include_Voting_Letter__c
        ) {
            exceptionMsg += 'Missing Information';
            errorMsg += '; Voting Letter is not Checked';
        }
        if(insolvAcc.Claim_Amount__c < 100) {
            exceptionMsg += '; Claim Amount less than 100';
            errorMsg += '; Claim Amount less than 100';
        }
        return new Map<String, String>{'Auto_POC_Exception_Reported__c' => exceptionMsg.removeStart(';'), 'Reason_for_POC_Automation_Failure__c' => errorMsg.removeStart(';')};
    }

    /**
    * @description : Method to generate and map appropriate variables for POC generation
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param insolvAcc 
    * @return Map<String, String> 
    **/
    public static Map<String, String> getVariableMap(Insolvency_Account__c insolvAcc) {
        String pageName = insolvAcc.Client_Identifier__c;
        PoC_Package_Settings__c pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        Remittance_Group_Mapping_For_PoC__c remGroupMap = new Remittance_Group_Mapping_For_PoC__c();
        Boolean form31 = false;
        Boolean form37 = false;
        Boolean statementOfAccount = false;
        Boolean amendedPOCcheck = false;
        Boolean unSecClaim = false;
        Boolean dontClaim = false;
        Boolean secureClaim = false;
        Boolean voteForAcceptance = false;
        Boolean voteAgainstAcceptance = false;
        Boolean meetingOfCredits = false;
        String formattedDate = '';
        String formattedDateToday = '';
        String formattedLastpaymentDate = '';
        String formattedDateTodayHeader = '';
        String formattedLastPayDate = '';
        String formattedSecondLastPayDate = '';
        String formattedThridLastPayDate = '';
        String formattedAcknowledgementDate = '';
        String formattedDebtDueOffDate = '';
        String formattedAccountOpenDate = '';
        String formattedAccountChargedoffDate = '';
        String formattedAccountOriginalOpenDate = '';

        String insolAccName = insolvAcc.Name;
        if (
            insolvAcc.Client_Identifier__c == 'Goeasy' &&
            insolvAcc.Account_Type__c == 'Unsecured Installment Loan' &&
            insolvAcc.Excluded_from_Purchase__c == true
        ) {
            pageName = 'GoEasyUnSecured';
        }

        Datetime dateNow = Datetime.now();
        if (insolvAcc.Insolvency__r.Insolvency_Date__c != null) {
            formattedDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Insolvency__r.Insolvency_Date__c.month()) +
                ' ' +
                String.valueOf(insolvAcc.Insolvency__r.Insolvency_Date__c.year())
            );
        }

        formattedDateToday = String.valueOf(' ' + frenchDates.get(dateNow.month()) + ' ' + String.valueOf(dateNow.year()));
        if (insolvAcc.Last_Payment_Date__c != null) {
            formattedLastpaymentDate = String.valueOf(
                String.valueOf(insolvAcc.Last_Payment_Date__c.month()) +
                ' ' +
                frenchDates.get(insolvAcc.Last_Payment_Date__c.month()) +
                ' ' +
                String.valueOf(insolvAcc.Last_Payment_Date__c.year())
            );
        }
        formattedDateTodayHeader = String.valueOf(' ' + frenchDates.get(dateNow.month()) + ' ' + dateNow.day() + ' ' + String.valueOf(dateNow.year()));

        if (insolvAcc.Last_Payment_Date__c != null) {
            formattedLastpaymentDate = String.valueOf(
                String.valueOf(insolvAcc.Last_Payment_Date__c.month()) +
                ' ' +
                frenchDates.get(insolvAcc.Last_Payment_Date__c.month()) +
                ' ' +
                String.valueOf(insolvAcc.Last_Payment_Date__c.year())
            );
        }
        if (insolvAcc.Acknowledgement_date__c != null) {
            formattedAcknowledgementDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Acknowledgement_date__c.month()) +
                ' ' +
                String.valueOf(insolvAcc.Acknowledgement_date__c.year())
            );
        }
        if (insolvAcc.Debt_Due_as_off_date__c != null) {
            formattedDebtDueOffDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Debt_Due_as_off_date__c.month()) +
                ' ' +
                String.valueOf(insolvAcc.Debt_Due_as_off_date__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date__c != null) {
            formattedLastPayDate = String.valueOf(
            ' ' +
                frenchDates.get(insolvAcc.Last_Payment_Date__c.month()) +
                ', ' +
                String.valueOf(insolvAcc.Last_Payment_Date__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date_2__c != null) {
            formattedSecondLastPayDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Last_Payment_Date_2__c.month()) +
                ', ' +
                String.valueOf(insolvAcc.Last_Payment_Date_2__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date_3__c != null) {
            formattedThridLastPayDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Last_Payment_Date_3__c.month()) +
                ', ' +
                String.valueOf(insolvAcc.Last_Payment_Date_3__c.year())
            );
        }
        if (insolvAcc.Account_Open_date__c != null) {
                formattedAccountOpenDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Account_Open_date__c.month()) +
                ', ' +
                String.valueOf(insolvAcc.Account_Open_date__c.year())
            );
        }
        if (insolvAcc.Charge_Off_Date__c != null) {
            formattedAccountChargedoffDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Charge_Off_Date__c.month()) +
                ', ' +
                String.valueOf(insolvAcc.Charge_Off_Date__c.year())
            );
        }
        if (insolvAcc.Account_Original_Open_Date__c != null) {
            formattedAccountOriginalOpenDate = String.valueOf(
                ' ' +
                frenchDates.get(insolvAcc.Account_Original_Open_Date__c.month()) +
                ', ' +
                String.valueOf(insolvAcc.Account_Original_Open_Date__c.year())
            );
        }

        statementOfAccount = insolvAcc.Proof_of_Claim_Required__c;
        form31 = insolvAcc.Proof_of_Claim_Required__c;

        if (insolvAcc.Client_Identifier__c == 'Canaccede' && insolvAcc.Insolvency__r.Insolvency_Type__c == 'Bankruptcy') {
            form37 = false;
        } else {
            form37 = insolvAcc.Include_Voting_Letter__c;
        }

        if (insolvAcc.Voting_Options__c == 'Vote Accept') {
            voteForAcceptance = true;
        } else if (insolvAcc.Voting_Options__c == 'Vote: Decline - No Meeting Requested') {
            voteAgainstAcceptance = true;
        } else if (insolvAcc.Voting_Options__c == 'Vote: Decline - With Creditor Meeting Request') {
            meetingOfCredits = true;
        }
        if (insolvAcc.Claim_Type__c == 'Secured') {
            secureClaim = true;
        } else if (insolvAcc.Claim_Type__c == 'Unsecured') {
            unSecClaim = true;
            dontClaim = true;
        }
        if (insolvAcc.PoC_Created_Date__c <> null && insolvAcc.Amended_Claim_Flag__c == false) {
            amendedPOCcheck = true;
        }

        List<String> trusteeCheckList = new List<String>();
        String idWithAccountStatement = pocPackage.Account_Statement_Not_Allowed__c;
        trusteeCheckList = idWithAccountStatement.split(',');
        for (String trusteeCheck : trusteeCheckList) {
            if (insolvAcc.Insolvency__r.Trustee__r.ParentId == trusteeCheck) {
                insolAccName = insolvAcc.Secured_Name__c;
                break;
            }
        }
        return new Map<String, String>{
            'pageName' => pageName,
            'formattedDate' => formattedDate,
            'formattedDateToday' => formattedDateToday,
            'formattedLastpaymentDate' => formattedLastpaymentDate,
            'formattedDateTodayHeader' => formattedDateTodayHeader,
            'formattedLastPayDate' => formattedLastPayDate,
            'formattedSecondLastPayDate' => formattedSecondLastPayDate,
            'formattedThridLastPayDate' => formattedThridLastPayDate,
            'formattedAcknowledgementDate' => formattedAcknowledgementDate,
            'formattedDebtDueOffDate' => formattedDebtDueOffDate,
            'formattedAccountOpenDate' => formattedAccountOpenDate,
            'statementOfAccount' => String.valueOf(statementOfAccount),
            'form31' => String.valueOf(form31),
            'form37' => String.valueOf(form37),
            'voteForAcceptance' => String.valueOf(voteForAcceptance),
            'voteAgainstAcceptance' => String.valueOf(voteAgainstAcceptance),
            'meetingOfCredits' => String.valueOf(meetingOfCredits),
            'secureClaim' => String.valueOf(secureClaim),
            'unSecClaim' => String.valueOf(unSecClaim),
            'dontClaim' => String.valueOf(dontClaim),
            'amendedPOCcheck' => String.valueOf(amendedPOCcheck),
            'insolAccName' => insolAccName,
            'accntId' => insolvAcc.Id
        };
    }

    /**
    * @description : Method to generate VF page name dynamically based on client identifier and language
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param pageName 
    * @param language 
    * @return String 
    **/
    public static String getPdfVfPageName(String pageName, String language) {
        String pdfPageName = 'POCDocData';
        List<String> englishNames = new List<String>{'en_US', 'English'};
        List<String> frenchNames = new List<String>{'fr', 'French'};
        if (pageName == 'Canaccede') {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocDataCanaccede';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchCanaccede';
            }
        } else if (pageName == 'Fidem') {
            pdfPageName = 'POCDocDataAffirm';
        } else if (pageName == 'Canadian Tire' || pageName == 'CanadianTire') {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocDataCanadianTire';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchCanadianTire';
            }
        } else if (pageName == 'GoEasyUnSecured') {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocDataEasyFinancial';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchEasyFinancial';
            }
        } else {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocData';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchStream';
            }
        }
        return pdfPageName;
    }

    /**
    * @description : Generate attachment record for POC with appropriate data
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param insolAccName 
    * @param insolvAcc 
    * @return Attachment 
    **/
    public static Attachment generateAttachmentRecord(String insolAccName, Insolvency_Account__c insolvAcc) {
        Attachment attach = new Attachment();
        DateTime d = Date.Today();
        String dateStr = d.formatGMT('yyyy-MM-dd');
        attach.Name =
            (insolvAcc.Amended_Claim_Flag__c ? 'Amended PoC - ' : 'PoC - ') +
            dateStr +
            ' - ' +
            insolvAcc.Insolvency__r.Name +
            ' - ' +
            insolAccName +
            ' - ' +
            (insolvAcc.Insolvency__r.Debtor_1_First_Name__c != null ? insolvAcc.Insolvency__r.Debtor_1_First_Name__c : '') +
            ' ' +
            (insolvAcc.Insolvency__r.Debtor_1_Last_Name__c != null ? insolvAcc.Insolvency__r.Debtor_1_Last_Name__c : '') +
            '.pdf';
        attach.IsPrivate = false;
        attach.Description = POCDocController.POC_DOC_DESCRIPTION;
        attach.ParentId = insolvAcc.Id;
        return attach;
    }

    /**
    * @description : Method to update POC fields on Insolvency account
    * @author adesh.ikhar@canaccede.com | 08-22-2024 
    * @param insolvAcc 
    * @return Insolvency_Account__c 
    **/
    public static Insolvency_Account__c updateAccountFields(Insolvency_Account__c insolvAcc) {
        insolvAcc.Insolvency_Status__c = 'PoC Package Generated';
        insolvAcc.Insolvency_Status_Last_Changed__c = System.now();
        insolvAcc.Reason_for_POC_Automation_Failure__c = null;
        insolvAcc.Auto_POC_Exception_Reported__c = null;
        if (insolvAcc.PoC_Created_Date__c == null) {
            insolvAcc.PoC_Created_Date__c = system.now();
        } else {
            insolvAcc.Amended_PoC_Created_Date__c = system.now();
        }
        return insolvAcc;
    }

    /**
    * @description : Method to create error record in case of exception
    * @author adesh.ikhar@canaccede.com | 08-26-2024 
    * @param ex 
    **/
    public static Insolvency_Error__c handleException(Exception ex, String recordId) {
        Insolvency_Error__c inslErr = new Insolvency_Error__c();
        inslErr.Insolvency_Account__c = recordId;
        inslErr.Action__c = 'PoC Generation';
        inslErr.Error__c = 'Exception: ' + ex.getTypeName();
        inslErr.Error__c += '\nMessage: ' + ex.getMessage();
        inslErr.Error__c += '\nStack trace:\n' + ex.getStackTraceString();
        return inslErr;
    }

    /**
    * @description : Method to update accounts with System Error exception
    * @author adesh.ikhar@canaccede.com | 08-27-2024 
    * @param insolvAccList 
    * @param errorMessage 
    **/
    public static void updateErrorAccounts(List<Insolvency_Account__c> insolvAccList, String errorMessage) {
        for(Insolvency_Account__c acc : insolvAccList) {
            acc.Reason_for_POC_Automation_Failure__c = errorMessage;
            acc.Auto_POC_Exception_Reported__c = 'System Error';
        }
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        Database.update(insolvAccList);
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
    }
}