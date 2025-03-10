/**************************************************************************************************
 *
 *  Class:   POCDocController
 *
 *  @description : This class implemets functionality to provide user in generating Poc Pacage data of an insolvancy account
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 
 *************************************************************************************************/
public class POCDocController {
    //Collection
    //map to store french translation of POCPackageSettings in english
    public map<String, String> mapPOCPackageSettingTranslation { get; set; }

    public Insolvency_Account__c insolvAcc { get; set; }
    public PoC_Package_Settings__c pocPackage { get; set; }
    public Application_Config_Settings__c appConfig = Application_Config_Settings__c.getInstance();
    public Remittance_Group_Mapping_For_PoC__c remGroupMap { get; set; }
    public Boolean isAnyException { get; set; }
    public String insolAccName { get; set; }
    public String pocDocError { get; set; }

    // Boolean check for paragraphs
    public Boolean unSecClaim { get; set; }
    public Boolean dontClaim { get; set; }
    public Boolean claimAmount { get; set; }
    public Boolean claimOfLess { get; set; }
    public Boolean secureClaim { get; set; }
    public Boolean copyOfReport { get; set; }
    public Boolean claimRight { get; set; }
    public Boolean claimByFarmers { get; set; }
    public Boolean claimByWage { get; set; }
    public Boolean claimForCustomer { get; set; }

    public Boolean claimBySubSec813 { get; set; }
    public Boolean claimBySubSec814 { get; set; }
    public Boolean claimAgnstDirector { get; set; }

    public Boolean voteForAcceptance { get; set; }
    public Boolean voteAgainstAcceptance { get; set; }
    public Boolean meetingOfCredits { get; set; }

    // Boolean checks for sections
    public Boolean form31 { get; set; }
    public Boolean form37 { get; set; }
    public Boolean statementOfAccount { get; set; }
    public Boolean amendedPOCcheck { get; set; }
    //Constants
    public static final String POC_DOC_DESCRIPTION = 'PoC Document';
    public String formattedDate { get; set; }
    public String formattedDateToday { get; set; }
    public String formattedLastpaymentDate { get; set; }
    public String formattedDateTodayHeader { get; set; }
    public String formattedFrenchTodayDate { get; set; }
    public String formattedLastPayDate { get; set; }
    public String formattedSecondLastPayDate { get; set; }
    public String formattedThridLastPayDate { get; set; }
    public String formattedAcknowledgementDate { get; set; }
    public String formattedDebtDueOffDate { get; set; }
    public String formattedAccountOpenDate { get; set; }
    public String formattedAccountChargedoffDate { get; set; }
    public String formattedJudgmentDate { get; set; }
    public String formattedAccountOriginalOpenDate { get; set; }

    //Language options French Translation
    public string language { get; set; }
    public string pageName { get; set; }

    public POCDocController() {
        isAnyException = false;
        amendedPOCcheck = false;
        mapPOCPackageSettingTranslation = new Map<String, String>();
        mapPOCPackageSettingTranslation.put('The Bank of Nova Scoatia', 'LA BANQUE DE NOUVELLE-ÉCOSSE');
        mapPOCPackageSettingTranslation.put('Bankruptcy', 'la faillite');
        mapPOCPackageSettingTranslation.put('Consumer Proposal', 'Proposition de Consomateur');
        mapPOCPackageSettingTranslation.put('Division 1 Proposal', 'Proposition de la division 1');

        try {
            // Add those two properties in your Apex controller
            Map<Integer, String> frenchDates = PocDocUtility.frenchDates;
            insolvAcc = [
                SELECT
                    Id,
                    Name,
                    Excluded_from_Purchase__c,
                    Secured_Name__c,
                    Business_Account__c,
                    Insolvency_Type__c,
                    Voting_Decision__c,
                    Insolvency__c,
                    Insolvency__r.Name,
                    Insolvency__r.Debtor_2_Estate_Number__c,
                    Insolvency__r.Eligible_For_Voting_Decision__c,
                    Insolvency__r.Voting_Decision__c,
                    Insolvency__r.Debtor_1_Mailing_City__c,
                    Insolvency__r.Debtor_1_Mailing_State_Province__c,
                    Insolvency__r.Insolvency_Type__c,
                    Portfolio_Group_Name__c,
                    Vendor_Orginator__c,
                    Portfolio_Name_Lookup__c,
                    Investment_Group__c,
                    Insolvency__r.Trustee__r.BillingStreet,
                    Insolvency__r.Trustee__r.BillingCity,
                    Insolvency__r.Trustee__r.BillingState,
                    Insolvency__r.Trustee__r.BillingPostalCode,
                    Insolvency__r.Trustee__r.BillingCountry,
                    Insolvency__r.Debtor_1_Mailing_Street__c,
                    Insolvency__r.Debtor_2_Mailing_Street__c,
                    Insolvency__r.Debtor_2_Mailing_City__c,
                    Insolvency__r.Debtor_1_Mailing_Postal_Code__c,
                    Insolvency__r.Debtor_2_Mailing_Postal_Code__c,
                    Insolvency__r.Debtor_1_Court_Number__c,
                    Insolvency__r.Debtor_2_Court_Number__c,
                    Insolvency__r.Court_District_Name__c,
                    Insolvency__r.Court_Division_Number__c,
                    Insolvency__r.Court_Province__c,
                    Insolvency__r.Insolvency_Date__c,
                    Secured_Asset_Amount__c,
                    Security_Description__c,
                    Vehicle_Identification_Number__c,
                    Voting_Letter_Comments__c,
                    Claim_Type__c,
                    Claim_Amount__c,
                    Amended_Claim_Flag__c,
                    Insolvency__r.Trustee__r.Name,
                    Insolvency__r.Trustee__r.Parent.Name,
                    Client_Identifier__c,
                    Last_Payment_Date__c,
                    Last_Payment_Amount__c,
                    Interest_Rate__c,
                    Insolvency_Status__c,
                    Asset_Status__c,
                    Insolvency__r.Debtor_1_First_Name__c,
                    Insolvency__r.Debtor_1_Last_Name__c,
                    Insolvency__r.Debtor_1_Middle_Name__c,
                    Insolvency__r.Debtor_2_First_Name__c,
                    Insolvency__r.Debtor_2_Last_Name__c,
                    Insolvency__r.Debtor_2_Middle_Name__c,
                    Bank_Name__c,
                    Statements_Required__c,
                    Proof_of_Claim_Required__c,
                    Voting_Options__c,
                    Include_Voting_Letter__c,
                    Amended_PoC_Created_Date__c,
                    PoC_Created_Date__c,
                    Account_Type__c,
                    Charge_Off_Date__c,
                    Account_Original_Open_Date__c,
                    Last_Payment_Date_2__c,
                    Last_Payment_Date_3__c,
                    Last_Payment_Amount_2__c,
                    Last_Payment_Amount_3__c,
                    Acknowledgement_date__c,
                    Debt_Due_As_Of_Date__c,
                    Account_Open_date__c,
                    Judgement_Date__c,
                    Portfolio_Name_Lookup__r.Non_Servicing_Portfolio__c
                FROM Insolvency_Account__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
            ];
            // Check if account is eligible to generate POC
            Map<String, String> pocDocErrorMap = PocDocUtility.validateRecord(insolvAcc);
            pocDocError = pocDocErrorMap.get('Reason_for_POC_Automation_Failure__c').replace(';', ' &');
            Map<String, String> variableMap = PocDocUtility.getVariableMap(insolvAcc);
            // Read poc Package custom setting to fetch related data
            pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
            pageName = variableMap.get('pageName');
            formattedDate = variableMap.get('formattedDate');
            formattedDateToday = variableMap.get('formattedDateToday');
            formattedLastpaymentDate = variableMap.get('formattedLastpaymentDate');
            formattedDateTodayHeader = variableMap.get('formattedDateTodayHeader');
            formattedLastPayDate = variableMap.get('formattedLastPayDate');
            formattedSecondLastPayDate = variableMap.get('formattedSecondLastPayDate');
            formattedThridLastPayDate = variableMap.get('formattedThridLastPayDate');
            formattedAcknowledgementDate = variableMap.get('formattedAcknowledgementDate');
            formattedDebtDueOffDate = variableMap.get('formattedDebtDueOffDate');
            formattedAccountOpenDate = variableMap.get('formattedAccountOpenDate');
            formattedAccountChargedoffDate = variableMap.get('formattedAccountChargedoffDate');
            formattedJudgmentDate = variableMap.get('formattedJudgmentDate');
            formattedAccountOriginalOpenDate = variableMap.get('formattedAccountOriginalOpenDate');
            statementOfAccount = Boolean.valueOf(variableMap.get('statementOfAccount'));
            form31 = Boolean.valueOf(variableMap.get('form31'));
            form37 = Boolean.valueOf(variableMap.get('form37'));
            voteForAcceptance = Boolean.valueOf(variableMap.get('voteForAcceptance'));
            voteAgainstAcceptance = Boolean.valueOf(variableMap.get('voteAgainstAcceptance'));
            meetingOfCredits = Boolean.valueOf(variableMap.get('meetingOfCredits'));
            secureClaim = Boolean.valueOf(variableMap.get('secureClaim'));
            unSecClaim = Boolean.valueOf(variableMap.get('unSecClaim'));
            dontClaim = Boolean.valueOf(variableMap.get('dontClaim'));
            amendedPOCcheck = Boolean.valueOf(variableMap.get('amendedPOCcheck'));
            copyOfReport = Boolean.valueOf(variableMap.get('copyOfReport'));
            insolAccName = variableMap.get('insolAccName');
            formattedFrenchTodayDate = variableMap.get('formattedFrenchDateToday');

            if (insolvAcc.Portfolio_Group_Name__c != null) {
                String portGroupMapShort = insolvAcc.Portfolio_Group_Name__c.LEFT(3);
                // Read Remittance group mapping custom setting to fetch related data
                remGroupMap = (Remittance_Group_Mapping_For_PoC__c) Remittance_Group_Mapping_For_PoC__c.getValues(portGroupMapShort);
            }
        } catch (Exception ex) {
            system.debug('exception' + ex.getStackTraceString());
            isAnyException = true;
        }
    }

    /* Method used to save poc package as pdf to insolvancy account */
    public PageReference savePOCDoc() {
        String pdfPageName = PocDocUtility.getPdfVfPageName(pageName, language);
        // Read pdf and pass all necessary parameters to pocdoc page
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
        String partialPageUrl = appConfig.Use_new_POC_templates__c &&
            pageName != 'FairstoneNew' &&
            pageName != 'Money Mart'
            ? '/apex/' + templatePageName + 'New'
            : '/apex/' + templatePageName;
        pdf = new PageReference(partialPageUrl);
        pdf.getParameters().put('id', ApexPages.currentPage().getParameters().get('Id'));
        pdf.getParameters().put('statementOfAccount', String.valueOf(statementOfAccount));
        pdf.getParameters().put('votingLetter', String.valueOf(form37));
        pdf.getParameters().put('proofOfClaim', String.valueOf(form31));

        pdf.getParameters().put('unSecClaim', String.valueOf(unSecClaim));
        pdf.getParameters().put('dontClaim', String.valueOf(dontClaim));
        pdf.getParameters().put('claimAmount', String.valueOf(claimAmount));
        pdf.getParameters().put('claimOfLess', String.valueOf(claimOfLess));
        pdf.getParameters().put('secureClaim', String.valueOf(secureClaim));
        pdf.getParameters().put('claimRight', String.valueOf(claimRight));

        pdf.getParameters().put('claimByFarmers', String.valueOf(claimByFarmers));
        pdf.getParameters().put('claimByWage', String.valueOf(claimByWage));
        pdf.getParameters().put('claimForCustomer', String.valueOf(claimForCustomer));
        pdf.getParameters().put('claimBySubSec813', String.valueOf(claimBySubSec813));
        pdf.getParameters().put('claimBySubSec814', String.valueOf(claimBySubSec814));
        pdf.getParameters().put('claimAgnstDirector', String.valueOf(claimAgnstDirector));
        pdf.getParameters().put('copyOfReport', String.valueOf(copyOfReport));
        pdf.getParameters().put('voteForAcceptance', String.valueOf(voteForAcceptance));
        pdf.getParameters().put('voteAgainstAcceptance', String.valueOf(voteAgainstAcceptance));
        pdf.getParameters().put('meetingOfCredits', String.valueOf(meetingOfCredits));

        // Create attachment
        //Attachment attach = PocDocUtility.generateAttachmentRecord(insolAccName, insolvAcc);
        ContentVersion conVersion = PocDocUtility.generateContentVersionRecord(insolAccName, insolvAcc);
        Blob body;
        try {
            if (!Test.IsRunningTest()) {
                body = pdf.getContent();
            } else {
                body = Blob.valueOf('Test');
            }
        } catch (Exception ex) {
            body = Blob.valueOf('Error : ' + ex);
            isAnyException = true;
            handleException(ex);
            return null;
        }
        conVersion.VersionData = body;
        insert conVersion;
        
        ContentDocumentLink conDocLink = PocDocUtility.generateContentDocLinkRecord(conVersion, insolvAcc);        
        Insert conDocLink;

        //Don't run InsolvencyAccountTrigger
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;

        try {
            // Update status value of Insolvancy account
            PocDocUtility.updateAccountFields(insolvAcc);
            update insolvAcc;

            //update the No of POC Details Provided on Insolvency for Scotia
            String insolvencyId = insolvAcc.Insolvency__c;
            Insolvency__c insolvencyObj = new Insolvency__c(Id = insolvencyId);
            insolvencyObj.Number_of_POC_Details_Provided_Accounts__c = database.countQuery(
                'select count() from insolvency_account__c where insolvency_status__C = \'PoC Details provided\'' +
                +'and Insolvency__c = :insolvencyId and (RecordType.DeveloperName = \'Scotia_Bank_Insolvency_Account\' OR RecordType.DeveloperName = \'SDA_Insolvency_Account\' OR RecordType.DeveloperName = \'SPL_Insolvency_Account\' OR RecordType.DeveloperName = \'Fairstone_Insolvency_Account\' OR RecordType.DeveloperName = \'Canadian_Tire_Insolvency_Account\')'
            );
            InsolvencyTriggerHandler.runInsolvencyTrigger = false;
            update insolvencyObj;
            InsolvencyTriggerHandler.runInsolvencyTrigger = true;

            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            */

            // Revert back custom setting value with previous value
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        } catch (Exception ex) {
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            */
            isAnyException = true;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            handleException(ex);
        }
        amendedPOCcheck = false;
        return null;
    }

    public void handleException(Exception ex) {
        Insolvency_Error__c inslErr = PocDocUtility.handleException(ex, insolvAcc.Id);
        try {
            insert inslErr;
        } catch (DMLException inslErrEx) {
            system.debug('inslErr Message :' + inslErrEx.getDmlMessage(0));
        }
    }

    //change the language logic from POCDoc page
    public PageReference changeLanguage() {
        String redirectPageName = '';
        PageReference pageRef;
        if (language == 'fr') {
            if (pageName == 'Canaccede') {
                redirectPageName = '/apex/POCDocFrenchCanaccedePreview';
            } else if (pageName == 'Canadian Tire' || pageName == 'CanadianTire') {
                redirectPageName = '/apex/POCDocFrenchCanadianTirePreview';
            } else if (pageName == 'GoEasyUnSecured') {
                redirectPageName = '/apex/POCDocFrenchEasyFinancialPreview';
            } else if (pageName == 'FairstoneNew') {
                redirectPageName = '/apex/POCDocFrenchFairstonePreview';
            } else if (pageName == 'Money Mart') {
                redirectPageName = '/apex/POCDocFrenchMoneyMartPreview';
            } else if (pageName == 'Flexiti') {
                redirectPageName = '/apex/POCDocFrenchFlexitiPreviewNew';
            }else {
                redirectPageName = '/apex/POCDocFrenchStreamPreview';
            }
        } else {
            if (pageName == 'Canaccede') {
                redirectPageName = '/apex/POCDocCanaccede';
            } else if (pageName == 'Canadian Tire' || pageName == 'CanadianTire') {
                redirectPageName = '/apex/POCDocCanadianTire';
            } else if (pageName == 'GoEasyUnSecured') {
                redirectPageName = '/apex/POCDocEasyFiEnglish';
            } else if (pageName == 'Fidem') {
                redirectPageName = '/apex/POCDocAffirm';
            } else if (pageName == 'FairstoneNew') {
                redirectPageName = '/apex/POCDocFairstonePreview';
            } else if (pageName == 'Money Mart') {
                redirectPageName = '/apex/POCDocMoneyMartPreview';
            } else if (pageName == 'Flexiti') {
                redirectPageName = '/apex/POCDocFlexitiPreviewNew';
            } else {
                redirectPageName = '/apex/POCDocPage';
            }
        }
        redirectPageName = appConfig.Use_new_POC_templates__c && pageName != 'FairstoneNew' ? redirectPageName + 'New' : redirectPageName;
        pageRef = new PageReference(redirectPageName + '?Id=' + insolvAcc.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}