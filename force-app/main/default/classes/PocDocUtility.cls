/**
 * @description       : Class to hold utility/common methods for POC document generation
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-05-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class PocDocUtility {
    public static Map<Integer, String> frenchDates = new Map<Integer, String>{
        1 => 'Janvier',
        2 => 'Février',
        3 => 'Mars',
        4 => 'Avril',
        5 => 'Mai',
        6 => 'Juin',
        7 => 'Juillet',
        8 => 'Août',
        9 => 'Septembre',
        10 => 'Octobre',
        11 => 'Novembre',
        12 => 'Décembre'
    };
    public static Map<Integer, String> frenchWeeks = new Map<Integer, String>{
        1 => 'Lundi', //Monday
        2 => 'Mardi', //Tuesday
        3 => 'Mercredi', //Wednesday
        4 => 'Jeudi', //Thursday
        5 => 'Vendredi', //Friday
        6 => 'Samedi', //Saturday
        7 => 'Dimanche' //Sunday
    };

    /**
     * @description : Method to check field validations before generating POC
     * @author adesh.ikhar@canaccede.com | 08-22-2024
     * @param insolvAcc
     * @return Map<String, String>
     **/
    public static Map<String, String> validateRecord(Insolvency_Account__c insolvAcc) {
        Map<String, String> exceptionErrorMessageMap = new Map<String, String>();
        List<String> eligibleVotingDecisions = new List<String>{ 'Auto Approved', 'Manually Approved', 'Manually Rejected' };
        List<String> mandatoryStatementBanks = new List<String>{ 'Scotia Bank', 'SDA', 'SPL', 'Fairstone' };
        String exceptionMsg = '';
        String errorMsg = '';
        if (!insolvAcc.Proof_of_Claim_Required__c) {
            exceptionMsg = 'Missing Information';
            errorMsg += 'Cannot generate a proof of claim unless "Proof of Claim Required" checkbox is checked on this account';
        }
        if (insolvAcc.Insolvency_Status__c != 'PoC Details Provided') {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Cannot generate a proof of claim unless this account is in "PoC Details Provided" status';
        }
        if (
            insolvAcc.Insolvency_Type__c == 'Consumer Proposal' &&
            (insolvAcc.Voting_Decision__c == 'Needs Manual Review' ||
            insolvAcc.Voting_Decision__c == 'System Error')
        ) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Cannot generate a proof of claim when Voting Decision is ' + insolvAcc.Voting_Decision__c;
        }
        if (insolvAcc.Client_Identifier__c == 'Canaccede' && insolvAcc.Vendor_Orginator__c == null) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Cannot generate a proof of claim unless this account has Vendor value populated on the account';
        }
        /*if (
            insolvAcc.Asset_Status__c != 'Purchased' &&
            insolvAcc.Asset_Status__c != 'Debt Purchase' &&
            insolvAcc.Asset_Status__c != 'Bulk Purchased' &&
            insolvAcc.Asset_Status__c != 'Duplicate Purchased'
        ) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Cannot generate a proof of claim unless this account is in Purchased / Debt Purchase / Bulk Purchased / Duplicate Purchased status';
        }*/
        if (
            insolvAcc.Client_Identifier__c == 'Canaccede' &&
            (insolvAcc.Portfolio_Group_Name__c == null ||
            insolvAcc.Portfolio_Name_Lookup__c == null ||
            insolvAcc.Investment_Group__c == null)
        ) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Cannot generate a proof of claim unless this account has Vendor value, Portfolio Group Name, Portfolio Name and Investment Group Name populated on the account';
        }
        if (
            (insolvAcc.Insolvency_Type__c == 'Division 1 Proposal' || insolvAcc.Insolvency_Type__c == 'Consumer Proposal') &&
            !insolvAcc.Include_Voting_Letter__c
        ) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Voting Letter is not Checked';
        }
        // Only check when POC is being generated from batch
        if (
            System.isBatch() &&
            mandatoryStatementBanks.contains(insolvAcc.Client_Identifier__c) &&
            !checkAttachmentTypePresence('Account Statement', insolvAcc.Attachments)
        ) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; No Account Statements attached';
        }
        // Only check when POC is being generated from batch
        if (System.isBatch() && insolvAcc.Claim_Type__c == 'Secured' && !checkAttachmentTypePresence('Proof of Security', insolvAcc.Attachments)) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; No Security documents attached';
        }
        if (System.isBatch() && (insolvAcc.Insolvency__r.Trustee__r.Is_Active__c == null || insolvAcc.Insolvency__r.Trustee__r.Is_Active__c == false)) {
            exceptionMsg = 'Missing Information';
            errorMsg += '; Trustee missing/inactive';
        }
        if (insolvAcc.Claim_Amount__c < 100) {
            exceptionMsg += '; Claim Amount less than 100';
            errorMsg += '; Claim Amount less than 100';
        }
        if (!System.isBatch() && insolvAcc.Portfolio_Name_Lookup__r.Non_Servicing_Portfolio__c) {
            exceptionMsg = 'Non servicing Portfolio';
            errorMsg += 'Cannot generate a proof of claim for Non servicing Portfolio';
        }
        return new Map<String, String>{
            'Auto_POC_Exception_Reported__c' => exceptionMsg.removeStart(';'),
            'Reason_for_POC_Automation_Failure__c' => errorMsg.removeStart(';')
        };
    }

    /**
     * @description : Check if current date is outside given business date range calculated from the input date
     * @author adesh.ikhar@canaccede.com | 12-09-2024
     * @param inputDate
     * @param noOfBusinessDays
     * @return Datetime
     **/
    public static Boolean isTodayOutsideGivenBusinessDateRange(Datetime inputDate, Integer noOfBusinessDays) {
        Boolean outsideRange = false;
        Integer count = 0;
        Map<Date, Id> mapHolidays = LoRDemandController.mapHoliday();
        DateTime finalDate;
        for (Integer i = 0; count < noOfBusinessDays; i++) {
            finalDate = inputDate + i;
            if (!(finalDate.format('E') == 'sat' || finalDate.format('E') == 'sun' || mapHolidays.get(finalDate.Date()) != null)) {
                count++;
            }
        }
        if (System.today() > finalDate.date()) {
            outsideRange = true;
        }
        return outsideRange;
    }

    /**
     * @description : Check if attachment of specific type is attached to the account
     * @author adesh.ikhar@canaccede.com | 09-30-2024
     * @param type
     * @param attachmentList
     * @return Boolean
     **/
    public static Boolean checkAttachmentTypePresence(String type, List<Attachment> attachmentList) {
        for (Attachment attach : attachmentList) {
            if (attach.Description == type) {
                return true;
            }
        }
        return false;
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
        Boolean copyOfReport = true;
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
        String formattedJudgmentDate = '';
        String formattedAccountOriginalOpenDate = '';
        String formattedFrenchDateToday = '';
        Set<String> fairstoneProductTypes = new Set<String>{ 'Secured', 'PL Unsecured', 'PL Secured', 'PL Auto Secured', 'Retail', 'Auto Loans' };

        String insolAccName = insolvAcc.Name;
        if (
            insolvAcc.Client_Identifier__c == 'Goeasy' &&
            insolvAcc.Account_Type__c == 'Unsecured Installment Loan' &&
            insolvAcc.Excluded_from_Purchase__c == true
        ) {
            pageName = 'GoEasyUnSecured';
        }

        if (insolvAcc.Client_Identifier__c == 'Fairstone' && fairstoneProductTypes.contains(insolvAcc.Account_Type__c)) {
            pageName = 'FairstoneNew';
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

        //Fetch week day of date
        Date dateParam = Date.today();
        //Recover the day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = dateParam.day() - startOfWeek.day();
        formattedFrenchDateToday = String.valueOf(
            ' ' + frenchWeeks.get(dayOfWeek) + ', ' + frenchDates.get(dateNow.month()) + ' ' + dateNow.day() + ', ' + String.valueOf(dateNow.year())
        );

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
                ' ' + frenchDates.get(insolvAcc.Acknowledgement_date__c.month()) + ' ' + String.valueOf(insolvAcc.Acknowledgement_date__c.year())
            );
        }
        if (insolvAcc.Debt_Due_As_Of_Date__c != null) {
            formattedDebtDueOffDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Debt_Due_As_Of_Date__c.month()) + ' ' + String.valueOf(insolvAcc.Debt_Due_As_Of_Date__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date__c != null) {
            formattedLastPayDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Last_Payment_Date__c.month()) + ', ' + String.valueOf(insolvAcc.Last_Payment_Date__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date_2__c != null) {
            formattedSecondLastPayDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Last_Payment_Date_2__c.month()) + ', ' + String.valueOf(insolvAcc.Last_Payment_Date_2__c.year())
            );
        }
        if (insolvAcc.Last_Payment_Date_3__c != null) {
            formattedThridLastPayDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Last_Payment_Date_3__c.month()) + ', ' + String.valueOf(insolvAcc.Last_Payment_Date_3__c.year())
            );
        }
        if (insolvAcc.Account_Open_date__c != null) {
            formattedAccountOpenDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Account_Open_date__c.month()) + ', ' + String.valueOf(insolvAcc.Account_Open_date__c.year())
            );
        }
        if (insolvAcc.Charge_Off_Date__c != null) {
            formattedAccountChargedoffDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Charge_Off_Date__c.month()) + ', ' + String.valueOf(insolvAcc.Charge_Off_Date__c.year())
            );
        }
        if (insolvAcc.Judgement_Date__c != null) {
            formattedJudgmentDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Judgement_Date__c.month()) + ', ' + String.valueOf(insolvAcc.Judgement_Date__c.year())
            );
        }
        if (insolvAcc.Account_Original_Open_Date__c != null) {
            formattedAccountOriginalOpenDate = String.valueOf(
                ' ' + frenchDates.get(insolvAcc.Account_Original_Open_Date__c.month()) + ', ' + String.valueOf(insolvAcc.Account_Original_Open_Date__c.year())
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
            'formattedJudgmentDate' => formattedJudgmentDate,
            'formattedAccountChargedoffDate' => formattedAccountChargedoffDate,
            'formattedAccountOriginalOpenDate' => formattedAccountOriginalOpenDate,
            'copyOfReport' => String.valueOf(copyOfReport),
            'formattedFrenchDateToday' => formattedFrenchDateToday,
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
        List<String> englishNames = new List<String>{ 'en_US', 'English' };
        List<String> frenchNames = new List<String>{ 'fr', 'French' };
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
        } else if (pageName == 'FairstoneNew') {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocDataFairstone';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchFairstone';
            }
        } else if (pageName == 'Money Mart') {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocDataMoneyMartNew';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchMoneyMartNew';
            }
        } else if (pageName == 'Flexiti') {
            if (englishNames.contains(language)) {
                pdfPageName = 'POCDocDataFlexiti';
            }
            if (frenchNames.contains(language)) {
                pdfPageName = 'POCDocDataFrenchFlexiti';
            }
        }else {
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
     * @description : Generate content version record for POC with appropriate data
     * @author pradeep.kumar@canaccede.com | 01-02-2025
     * @param insolAccName
     * @param insolvAcc
     * @return Content Version
     **/
    public static ContentVersion generateContentVersionRecord(String insolAccName, Insolvency_Account__c insolvAcc) {
        ContentVersion conVer = new ContentVersion();
        DateTime d = Date.Today();
        String dateStr = d.formatGMT('yyyy-MM-dd');
        conVer.Title =
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
        
        conVer.PathOnClient = conVer.Title;
        conVer.IsMajorVersion = true;
        conVer.Description = POCDocController.POC_DOC_DESCRIPTION;
        return conVer;
    }
    
    /**
     * @description : Generate content document link record for POC with appropriate data
     * @author pradeep.kumar@canaccede.com | 01-02-2025
     * @param ContentVersion
     * @return Content Document Link
     **/
    public static ContentDocumentLink generateContentDocLinkRecord(ContentVersion conVersion, Insolvency_Account__c insolvAcc) {
        conVersion = [select id, ContentDocumentId from contentversion where Id =: conVersion.Id]; 
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = conVersion.ContentDocumentId;
        conDocLink.LinkedEntityId = insolvAcc.Id;
        conDocLink.ShareType = 'V';
        conDocLink.Visibility = 'AllUsers';
        return conDocLink;
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
        for (Insolvency_Account__c acc : insolvAccList) {
            acc.Reason_for_POC_Automation_Failure__c = errorMessage;
            acc.Auto_POC_Exception_Reported__c = 'System Error';
        }
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        Database.update(insolvAccList);
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
    }
}