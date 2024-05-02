/*****************************************************************************************************************
* Author         : A5E Consultancy
* Created On     : 02 Nov 2023
* Description    : This file layout is used for DRN to send insolvency updates to an Insolvency Client and 
for the Client to send return detailed information to DRN.
                            
******************************************************************************************************************/

global class CTBFileGenerator implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts {
    public static map<String, CTB_File_Automation__mdt> mapCTBFileAutomation = CTB_File_Automation__mdt.getAll();
    public map<String, CTB_File_Automation__mdt> mapCTBFileAuto = new Map<String, CTB_File_Automation__mdt>();
    public static Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    public String CTBBatchName;
    public static final String recordType = 'Canadian_Tire_Insolvency_Account';
    public static final String clientIdentifier = 'Canadian Tire';
    String FinalData = '';
    List<sObject> queryData = new List<sObject>();
    String createdDate = '';
    public String dateformate = '';
    public static string headbody = '';
    public static string trailerbody = '';
    public static string Theadbody = '';
    public static string Bheadbody = '';
    public static string BTRAL = '';
    public static string TTRAL = '';
    Integer countVariable = 0;
    public static Map<String, Insolvency_Payment__c> paymentSumTotal = new Map<String, Insolvency_Payment__c>();
    public static string blankString = '';
    public static final string transmissionNumber = blankString.leftPad(4);
    public static final String extra12Spaces = blankString.leftPad(12);
    public static final String defJulianDate = blankString.leftPad(3);
    public static final String extra5Spaces = blankString.leftPad(5);
    public static final String commingledFileProcessingFlag = blankString.leftPad(1);
    public static final String multiCurrencyCurrencyCode = blankString.leftPad(3);
    public static final string extra64Spaces = blankString.leftPad(64);
    public static final string transmissionIdentifierFlag = blankString.leftPad(1);
    public static final string batchIdentifier = blankString.leftPad(3);
    public static final string batchIdentifierExtension = blankString.leftPad(3);
    public static final string transactionDateOverride = blankString.leftPad(6);
    public static final string alternateAmountIndicator = blankString.leftPad(1);
    public static final string merchantHeaderExclusionFlag = blankString.leftPad(1);
    public static final string extra76Spaces = blankString.leftPad(76);
    public static final string forceAuthorizationIndicator = blankString.leftPad(1);
    public static final string merchantDBAName = blankString.leftPad(25);
    public static final string merchantDBACityStatDesc = blankString.leftPad(13);
    public static final string merchantDBAState = blankString.leftPad(3);
    public static final string extra4Spaces = blankString.leftPad(4);
    public static final string mailTelephoneIndicator = blankString.leftPad(1);
    public static final string extensionRecordIndicator = blankString.leftPad(1);
    public static final String defAuthorizationCode = blankString.leftPad(6);
    public static final string extra38Spaces = blankString.leftPad(38);
    public static final string extra40Spaces = blankString.leftPad(40);
    public static final string extra15Spaces = blankString.leftPad(15);
    public static final string extra3Spaces = blankString.leftPad(3);
    public static final string defCreatedDate = blankString.leftPad(8, '0');
    public static final string defSeqNumber = blankString.leftPad(7);
    public static final string defTransCode = blankString.leftPad(4);
    public static final string defBankNumber = blankString.leftPad(4);
    public static final string defTransName = blankString.leftPad(8);
    public static final string defTransmissionDesc = blankString.leftPad(6);
    public static final string defBheadSeqNum = blankString.leftPad(7);
    public static final string defBheadTransCode = blankString.leftPad(4);
    public static final string defBheadBankNumber = blankString.leftPad(4);
    public static final string defBheadFormatIdentifier = blankString.leftPad(5);
    public static final string defBatchCount = blankString.leftPad(4);
    public static final string defTransReferenceNum = blankString.leftPad(11);
    public static final string defDrftTransCode = blankString.leftPad(4);
    public static final string defPaymentPostingDateData = blankString.leftPad(6);
    public static final string defPayAmount = blankString.leftPad(9);
    public static final string defDrftMerhDesc = blankString.leftPad(1);
    public static final string defDrftsMerhDBACountryCode = blankString.leftPad(3);
    public static final string defCoboloPaymentAmt = blankString.leftPad(12);
    public static final string defMonetaryPaymentAmtTrans = blankString.leftPad(10, '0');
    public static final string referenceNumber = blankString.leftPad(23);
    public static String sequenceNumber;
    public static String theadTransCode;
    public static String theadBankNumber;
    public static String theadTransName;
    public static String transmissionDescription;
    public static String julianDateCal;
    public static String gregorianDate;
    public static String bheadsequenceNumber;
    public static String bheadTransCode;
    public static String bheadBankNumber;
    public static String bheadFormatIdentifier;
    public static Integer batchCount;
    public static String transReferenceNum;
    global Integer batchExecuteCount = 0;

    global CTBFileGenerator(String batchName) {
        //get Batch Name from Scheduler
        CTBBatchName = batchName;
        // get value from CTB File Automation custom metadata
        for (CTB_File_Automation__mdt metaData : mapCTBFileAutomation.values()) {
            mapCTBFileAuto.put(metaData.MasterLabel, metaData);
        }
        createdDate = convertDateToString(System.today());
        dateformate = Datetime.now().format('HH:mm:ss');
    }

    // Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        //List<String> listNames = new List<String>{'101010','010101'};
        String query = '';
        //fetch records based on batchName
        if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
            query =
                ' Select id,name,Insolvency_Received_Date__c,Insolvency__r.Insolvency_Type__c,Debtor_1_First_Name__c,' +
                'Debtor_1_Last_Name__c,Province_Formula__c,Insolvency__r.Debtor_1_Mailing_Country__c,Debtor_1_Mailing_Postal_Code__c,' +
                'Debtor_1_SIN__c,Debtor_1_Date_of_Birth__c,Insolvency__r.Insolvency_Date__c,Insolvency__r.name,Trustee_Company__c,Correlation_ID__c,' +
                'Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Debtor_1_First_Name__c,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,CTB_Date_of_Birth__c,' +
                'Insolvency__r.Trustee__r.BillingPostalCode,Debtor_1_Mailing_Street__c,CTB_Status_Update_Code__c,Insolvency__r.Debtor_1_Middle_Name__c,Debtor_1_Mailing_City__c ' +
                'FROM Insolvency_Account__c ' +
                'WHERE ' +
                'RecordType.developerName = :recordType AND ' +
                '(Insolvency_Status__c = \'For Owner Review\' OR ' +
                'Insolvency_Status__c = \'Discharged\' OR ' +
                'Insolvency_Status__c = \'Annulled\'OR ' +
                'Insolvency_Status__c = \'Withdrawn\'OR ' +
                'Insolvency_Status__c = \'Refused\') AND ' +
                'Insolvency_Sub_Status__c = \'Pending File\'';
        }
        if (CTBBatchName == System.Label.CTB_Payment) {
            if (Test.isRunningTest()) {
                query =
                    ' Select id,name,Account_Number__c,Payment_Posting_Date__c,Transaction_Id__c,Payment_Type__c,Payment_Amount__c,' +
                    'Remitted_Date__c,Remitted_Cheque_Number__c,Estate_Number__c ' +
                    'FROM Insolvency_Payment__c ';
            } else {
                query =
                    ' Select id,name,Account_Number__c,Payment_Posting_Date__c,Transaction_Id__c,Payment_Type__c,Payment_Amount__c,' +
                    'Remitted_Date__c,Remitted_Cheque_Number__c,Estate_Number__c ' +
                    'FROM Insolvency_Payment__c ' +
                    'WHERE ' +
                    'Insolvency_Account__r.Client_Identifier__c = :clientIdentifier AND ' +
                    'RecordType.DeveloperName = \'Insolvency_Payment\' AND ' +
                    'Payment_Amount__c > 0 AND ' +
                    'Payment_Sub_Status__c = \'Pending File\'';
            }
        }
        return Database.getQueryLocator(query);
    }

    //Execute Method: based on batch name call respective method
    global void execute(Database.BatchableContext BC, List<sObject> query) {
        if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
            queryData = query;
            wrapperClass batchCnt = new wrapperClass();
            // build insolvency daily update file body
            batchCnt = getInsolvencyAccountFile(mapCTBFileAuto, query, createdDate, dateformate, CTBBatchName);
            FinalData += batchCnt.finalDetailBody;
            countVariable += batchCnt.batchCountDetail;
        }
        if (CTBBatchName == System.Label.CTB_Payment) {
            queryData = query;
            wrapperClass batchCnt = new wrapperClass();
            // build insolvency payment update file body
            batchCnt = getInsolvencyPaymentFile(mapCTBFileAuto, query, createdDate, dateformate, CTBBatchName);
            FinalData += batchCnt.finalDetailBody;
            countVariable += batchCnt.batchCountDetail;
            batchExecuteCount++;
        }
    }

    // Build body for Insolvency Daily Update file generation
    public static wrapperClass getInsolvencyAccountFile(
        map<String, CTB_File_Automation__mdt> mapCTBFileAuto,
        List<Insolvency_Account__c> insolvencyAccData,
        String createdDate,
        String dateformate,
        string CTBBatchName
    ) {
        Integer counter = 0;
        string mainbody = '';
        List<ID> listAccIds = new List<ID>();
        List<ID> listAccSuccessIds = new List<ID>();
        wrapperClass batchCntData = new wrapperClass();
        Map<id, Insolvency_Account__c> insolvAcctErrorListMap = new Map<id, Insolvency_Account__c>();
		Insolvency_Account__c insolAccError = new Insolvency_Account__c();
        
        try {
            //retrive data from CTB File Automation custom metadata
            String headerType = mapCTBFileAuto.get('Insolvency Daily Update').Header_Record_Type__c;
            String fileType = mapCTBFileAuto.get('Insolvency Daily Update').File_Type__c;
            String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
            String memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
            String memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
            String detailRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Detail_Record_Type__c;
            String productDesc = mapCTBFileAuto.get('Insolvency Daily Update').Product_Description__c;
            String productID = mapCTBFileAuto.get('Insolvency Daily Update').DRN_Debt_Product_ID__c;
            String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
            String DRNTrusteeID = mapCTBFileAuto.get('Insolvency Daily Update').DRN_Trustee_ID__c;
            Integer batchCount = Integer.valueof(config.Insolvency_Account_Batch_Count__c);

            /*******************************************Body Data*************************************************/
            for (Insolvency_Account__c insolAccData : insolvencyAccData) {
                //If mandatory fields are not null then only build CSV file
                if (
                    headerType != null &&
                    memberType != null &&
                    memberID != null &&
                    batchCount != null &&
                    createdDate != null &&
                    fileType != null &&
                    fileFormatIdenfier != null &&
                    detailRecordType != null &&
                    insolAccData.Insolvency_Received_Date__c != null &&
                    insolAccData.name != null &&
                    insolAccData.Insolvency__r.Insolvency_Type__c != null &&
                    productDesc != null &&
                    (insolAccData.Insolvency__r.Debtor_1_First_Name__c != null ||
                    insolAccData.Insolvency__r.Debtor_1_Middle_Name__c != null ||
                    insolAccData.Debtor_1_First_Name__c != null) &&
                    insolAccData.Debtor_1_Last_Name__c != null &&
                    insolAccData.Debtor_1_Mailing_Street__c != null &&
                    insolAccData.Debtor_1_Mailing_City__c != null &&
                    insolAccData.Province_Formula__c != null &&
                    insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c != null &&
                    insolAccData.Insolvency__r.Insolvency_Date__c != null &&
                    insolAccData.Insolvency__r.name != null &&
                    DRNTrusteeID != null &&
                    insolAccData.Trustee_Company__c != null &&
                    insolAccData.Insolvency__r.Trustee__r.BillingStreet != null &&
                    insolAccData.Insolvency__r.Trustee__r.BillingCity != null &&
                    insolAccData.Insolvency__r.Trustee__r.BillingState != null &&
                    insolAccData.Insolvency__r.Trustee__r.BillingPostalCode != null &&
                    insolAccData.Correlation_ID__c != null && trailerRecordType != null || Test.isRunningTest()
                ) {
                    String DebtorFirstName = '';
                    if (insolAccData.Debtor_1_First_Name__c != null) {
                        if (insolAccData.Debtor_1_First_Name__c.length() > 40) {
                            DebtorFirstName = insolAccData.Debtor_1_First_Name__c.subString(0, 40);
                        } else {
                            DebtorFirstName = insolAccData.Debtor_1_First_Name__c;
                        }
                    }
                    String DebtorLaseName = '';
                    if (insolAccData.Debtor_1_Last_Name__c != null) {
                        if (insolAccData.Debtor_1_Last_Name__c.length() > 40) {
                            DebtorLaseName = insolAccData.Debtor_1_Last_Name__c.subString(0, 40);
                        } else {
                            DebtorLaseName = insolAccData.Debtor_1_Last_Name__c;
                        }
                    }
                    String addressLine1 = '';
                    if (insolAccData.Debtor_1_Mailing_Street__c != null) {
                        if (insolAccData.Debtor_1_Mailing_Street__c.length() > 80) {
                            addressLine1 = insolAccData.Debtor_1_Mailing_Street__c.subString(0, 80);
                        } else {
                            addressLine1 = insolAccData.Debtor_1_Mailing_Street__c;
                        }
                    }
                    String DebtorMailingCity = '';
                    if (insolAccData.Debtor_1_Mailing_City__c != null) {
                        if (insolAccData.Debtor_1_Mailing_City__c.length() > 40) {
                            DebtorMailingCity = insolAccData.Debtor_1_Mailing_City__c.subString(0, 40);
                        } else {
                            DebtorMailingCity = insolAccData.Debtor_1_Mailing_City__c;
                        }
                    }
                    String province = '';
                    if (insolAccData.Province_Formula__c != null) {
                        province = CustomerProcessingBatchHelper.getProvinceCode(insolAccData.Province_Formula__c);
                    }
                    String mailingCountry = '';
                    if (insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c != null) {
                        mailingCountry = CustomerProcessingBatchHelper.getMailingCountry(insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c);
                    }
                    String mailingPostalCode = '';
                    if (insolAccData.Debtor_1_Mailing_Postal_Code__c != null) {
                        if (insolAccData.Debtor_1_Mailing_Postal_Code__c.length() > 15) {
                            mailingPostalCode = insolAccData.Debtor_1_Mailing_Postal_Code__c.subString(0, 15);
                        } else {
                            mailingPostalCode = insolAccData.Debtor_1_Mailing_Postal_Code__c;
                        }
                    }
                    String SIN = '';
                    if (insolAccData.Debtor_1_SIN__c != null) {
                        if (insolAccData.Debtor_1_SIN__c.length() > 8) {
                            SIN = insolAccData.Debtor_1_SIN__c.subString(0, 8);
                        } else {
                            SIN = insolAccData.Debtor_1_SIN__c;
                        }
                    }
                    String dateOfBirth = '';
                    if (insolAccData.CTB_Date_of_Birth__c != null) {
                        dateOfBirth = convertDateToString(insolAccData.CTB_Date_of_Birth__c);
                    } else {
                        dateOfBirth = convertDateToString(insolAccData.Debtor_1_Date_of_Birth__c);
                    }
                    String insolvencyDate = '';
                    if (insolAccData.Insolvency__r.Insolvency_Date__c != null) {
                        insolvencyDate = convertDateToString(insolAccData.Insolvency__r.Insolvency_Date__c);
                    }
                    String openDate = '';
                    if (insolAccData.Insolvency_Received_Date__c != null) {
                        openDate = convertDateToString(insolAccData.Insolvency_Received_Date__c);
                    }
                    String estateNumber = '';
                    if (insolAccData.Insolvency__r.name != null) {
                        estateNumber = insolAccData.Insolvency__r.name;
                    }
                    String trusteeCompany = '';
                    if (insolAccData.Trustee_Company__c != null) {
                        if (insolAccData.Trustee_Company__c.length() > 80) {
                            trusteeCompany = insolAccData.Trustee_Company__c.subString(0, 80);
                        } else {
                            trusteeCompany = insolAccData.Trustee_Company__c;
                        }
                    }
                    String trusteeAddress = '';
                    if (insolAccData.Insolvency__r.Trustee__r.BillingStreet != null) {
                        if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet).length() > 80) {
                            trusteeAddress = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet).subString(0, 80);
                        } else {
                            trusteeAddress = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet);
                        }
                        trusteeAddress = trusteeAddress.escapeUnicode();
                    }
                    String trusteeCity = '';
                    if (insolAccData.Insolvency__r.Trustee__r.BillingCity != null) {
                        if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity).length() > 39) {
                            trusteeCity = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity).subString(0, 39);
                        } else {
                            trusteeCity = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity);
                        }
                    }
                    String trusteeState = '';
                    if (insolAccData.Insolvency__r.Trustee__r.BillingState != null) {
                        if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState).length() > 2) {
                            trusteeState = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState).subString(0, 2);
                        } else {
                            trusteeState = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState);
                        }
                    }
                    String trusteePostalCode = '';
                    if (insolAccData.Insolvency__r.Trustee__r.BillingPostalCode != null) {
                        if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode).length() > 15) {
                            trusteePostalCode = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode).subString(0, 15);
                        } else {
                            trusteePostalCode = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode);
                        }
                    }
                    // buld final body data
                    mainbody +=
                        '"'+detailRecordType +
                        '","' +
                        memberType +
                        '","' +
                        memberID +
                        '","' +
                        openDate +
                        '","' +
                        insolAccData.name +
                        '","' +
                        insolAccData.Insolvency__r.Insolvency_Type__c +
                        '","' +
                        productDesc +
                        '","' +
                        DebtorFirstName +
                        '","' +
                        DebtorLaseName +
                        '","' +
                        addressLine1 +
                        '","' +
                        '' +
                        '","' +
                        DebtorMailingCity +
                        '","' +
                        province +
                        '","' +
                        mailingCountry +
                        '","' +
                        mailingPostalCode +
                        '","' +
                        SIN +
                        '","' +
                        dateOfBirth +
                        '","' +
                        insolvencyDate +
                        '","' +
                        estateNumber +
                        '","' +
                        DRNTrusteeID +
                        '","' +
                        trusteeCompany +
                        '","' +
                        trusteeAddress +
                        '","' +
                        '' +
                        '","' +
                        trusteeCity +
                        '","' +
                        trusteeState +
                        '","' +
                        trusteePostalCode +
                        '","' +
                        insolAccData.Correlation_ID__c +
                        '","' +
                        insolAccData.CTB_Status_Update_Code__c +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +
                        '","' +
                        '' +'"'+
                        ' \n';
                    counter++;
                } else {
                    //If mandatory fields are null then dont build CSV file for this record
                    listAccIds.add(insolAccData.id);

                    //update insolvency sub status to "File Error Parsing Record" on insolvency account records.
                    if (insolAccData.id != null) {
                        insolAccError.id = insolAccData.id;
                        insolAccError.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                        insolAccError.Error_Message__c = 'Missing data in one or more mandatory fields.';
                        insolvAcctErrorListMap.put(insolAccError.id, insolAccError);
                    }
                }
            }
            /*******************************************Body Data Ends*************************************************/

            try {
                //Batch count is assigned SEQUENTIAL batch number, starting at 1.  Each batch number must be one number greater than the last received regardless if the file is test or production.  This will ensure files aren’t accidentally sent twice or missed
                config.Insolvency_Account_Batch_Count__c = config.Insolvency_Account_Batch_Count__c + 1;
                update config;
                //if any error occur while file build then update status on insolvency account to "File Error Parsing Record"
                if (insolvAcctErrorListMap != null && !insolvAcctErrorListMap.isEmpty()) {
                    update insolvAcctErrorListMap.values();
                }
            } catch (DMLException dmlEx) {
                system.debug('Exception msg@@' + dmlEx.getStackTraceString());
                exceptionHandling(dmlEx.getDMLMessage(0), dmlEx.getStackTraceString(), dmlEx.getDmlId(0), null, CTBBatchName);
                CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(), dmlEx.getStackTraceString(), 'Account batch count update Failed');
            }
        } catch (Exception ex) {
            system.debug('Exception msg**' + ex.getStackTraceString());
            exceptionHandling(ex.getMessage(), ex.getStackTraceString(), null, insolvencyAccData, CTBBatchName);
            CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(), ex.getStackTraceString(), 'CTB Account Automation Process Failed');
        }
        batchCntData.finalDetailBody = mainbody;
        batchCntData.batchCountDetail = counter;
        return batchCntData;
    }

    // Build body for Insolvency Daily Update file generation
    public static wrapperClass getInsolvencyPaymentFile(
        map<String, CTB_File_Automation__mdt> mapCTBFileAuto,
        List<Insolvency_Payment__c> insolvencyPayData,
        String createdDate,
        String dateformate,
        string CTBBatchName
    ) {
        string mainbody = '';
        Integer counter = 0;
        Integer draftSeuNum = 3;
        wrapperClass batchCntData = new wrapperClass();
        try {
            //retrive data from CTB File Automation custom metadata
            String dRFTSTransCode = mapCTBFileAuto.get('Insolvency Payment Update').DRFTS_Trans_Code__c;
            String dRFTSMerhDesc = mapCTBFileAuto.get('Insolvency Payment Update').DRFTS_Merh_Desc__c;
            String drftsMerhDBACountryCode = mapCTBFileAuto.get('Insolvency Payment Update').Drfts_Merh_DBA_Country_Code__c;
            String drftsMerhDBACategoryCode = mapCTBFileAuto.get('Insolvency Payment Update').Drfts_Merh_DBA_Category_Code__c;
            String drftsAuthCode = mapCTBFileAuto.get('Insolvency Payment Update').Drfts_Auth_Code__c;

            String authorizationCode = defAuthorizationCode;
            authorizationCode = getSpaceAndZeroAdded(String.ValueOf(drftsAuthCode), 6, false, true, false);

            /*******************************************Body Data*************************************************/
            for (Insolvency_Payment__c insolPayData : insolvencyPayData) {
                String paymentPostingDateData = defPaymentPostingDateData;
                if (insolPayData.Payment_Posting_Date__c != null) {
                    paymentPostingDateData = formatDate_MM_DD_YY(insolPayData.Payment_Posting_Date__c);
                }
                String sequenceCode = defSeqNumber;
                sequenceCode = getSpaceAndZeroAdded(String.ValueOf(draftSeuNum), 7, true, false, false);

                String drftTransCode = defDrftTransCode;
                drftTransCode = getSpaceAndZeroAdded(String.ValueOf(dRFTSTransCode), 4, false, true, false);

                String accNumber = getSpaceAndZeroAdded(String.ValueOf(insolPayData.Account_Number__c).deleteWhiteSpace(), 16, false, true, true);

                String payAmount = defPayAmount;
                if (insolPayData.Payment_Amount__c != null) {
                    payAmount = String.ValueOf(insolPayData.Payment_Amount__c.setScale(0));
                    payAmount = getSpaceAndZeroAdded(String.ValueOf(payAmount), 9, true, false, false);
                }

                String drftMerhDesc = defDrftMerhDesc;
                drftMerhDesc = getSpaceAndZeroAdded(String.ValueOf(dRFTSMerhDesc), 1, false, true, false);

                String drftMerhDBACC = defDrftsMerhDBACountryCode;
                drftMerhDBACC = getSpaceAndZeroAdded(String.ValueOf(drftsMerhDBACountryCode), 3, false, true, false);

                String referenceNumber = getSpaceAndZeroAdded((insolPayData.Name).substringAfter('-'), 23, false, true, true);

                mainbody +=
                    sequenceCode +
                    drftTransCode +
                    accNumber +
                    paymentPostingDateData +
                    forceAuthorizationIndicator +
                    payAmount +
                    merchantDBAName +
                    merchantDBACityStatDesc +
                    merchantDBAState +
                    drftMerhDesc +
                    referenceNumber +
                    extra4Spaces +
                    drftMerhDBACC +
                    drftsMerhDBACategoryCode +
                    'N' +
                    authorizationCode +
                    mailTelephoneIndicator +
                    extensionRecordIndicator +
                    '\n';
                counter++;
                draftSeuNum++;
            }
            /*******************************************Body Data Ends*************************************************/
            try {
                //Batch count is assigned SEQUENTIAL batch number, starting at 1.  Each batch number must be one number greater than the last received regardless if the file is test or production.  This will ensure files aren’t accidentally sent twice or missed
                config.Payment_Batch_Count__c = config.Payment_Batch_Count__c + 1;
                update config;
            } catch (DMLException dmlEx) {
                system.debug('Exception msg@@' + dmlEx.getStackTraceString());
                exceptionHandling(dmlEx.getDMLMessage(0), dmlEx.getStackTraceString(), dmlEx.getDmlId(0), null, CTBBatchName);
                CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(), dmlEx.getStackTraceString(), 'Payment batch count update Failed');
            }
        } catch (Exception ex) {
            system.debug('Exception msg**' + ex.getStackTraceString());
            exceptionHandling(ex.getMessage(), ex.getStackTraceString(), null, insolvencyPayData, CTBBatchName);
            CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(), ex.getStackTraceString(), 'CTB Payment Automation Process Failed');
        }
        batchCntData.finalDetailBody = mainbody;
        batchCntData.batchCountDetail = counter;
        return batchCntData;
    }

    @testvisible
    private static String convertDateToString(DateTime dt) {
        if (dt != null) {
            return (dt.formatGMT('MM/dd/yyyy'));
        } else {
            return '';
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {
            String mainFinalData = '';
            if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
                Integer finalrecordCount = 2 + countVariable;
                String headerType = mapCTBFileAuto.get('Insolvency Daily Update').Header_Record_Type__c;
                String memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
                String memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
                Integer batchCount = Integer.valueof(config.Insolvency_Account_Batch_Count__c);
                String fileType = mapCTBFileAuto.get('Insolvency Daily Update').File_Type__c;
                String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
                String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
                //build heder body data
                headbody =
                    '"'+headerType +
                    '","' +
                    memberType +
                    '","' +
                    memberID +
                    '","' +
                    batchCount +
                    '","' +
                    createdDate +
                    '","' +
                    dateformate +
                    '","' +
                    fileType +
                    '","' +
                    fileFormatIdenfier + '"'+
                    ' \n';
                //build trailer body data
                trailerbody =
                    '"'+trailerRecordType +
                    '","' +
                    memberType +
                    '","' +
                    memberID +
                    '","' +
                    finalrecordCount +
                    '","' +
                    countVariable +
                    '","' +
                    createdDate +
                    '","' +
                    dateformate +'"'+
                    ' \n';
                //build final string to parse
                mainFinalData = headbody + FinalData + trailerbody;
            }
            if (CTBBatchName == System.Label.CTB_Payment) {
                List<ID> listOfPaymentIds = new List<ID>();
                Integer batchCount = Integer.valueof(config.Payment_Batch_Count__c);
                sequenceNumber = mapCTBFileAuto.get('Insolvency Payment Update').Sequence_Number__c;
                theadTransCode = mapCTBFileAuto.get('Insolvency Payment Update').Thead_Trans_Code__c;
                theadBankNumber = mapCTBFileAuto.get('Insolvency Payment Update').Thead_Bank_Number__c;
                theadTransName = mapCTBFileAuto.get('Insolvency Payment Update').Thead_Trans_Name__c;
                transmissionDescription = mapCTBFileAuto.get('Insolvency Payment Update').Thead_Trans_Desc__c;
                bheadsequenceNumber = mapCTBFileAuto.get('Insolvency Payment Update').Bhead_Sequence_Number__c;
                bheadTransCode = mapCTBFileAuto.get('Insolvency Payment Update').Bhead_Trans_Code__c;
                bheadBankNumber = mapCTBFileAuto.get('Insolvency Payment Update').Bhead_Bank_Number__c;
                bheadFormatIdentifier = mapCTBFileAuto.get('Insolvency Payment Update').Bhead_Format_Identifier__c;
                transReferenceNum = mapCTBFileAuto.get('Insolvency Payment Update').Transaction_Reference_Number__c;
                String btralRecordType = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Record_Type_Code__c;
                String btralBankNumber = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Bank_Number__c;
                String btralFormatIden = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Format_Identifier__c;
                String btralDebitTransCount = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Debit_Trans_Count__c;
                String btralDebitAmount = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Debit_Amount__c;
                String btralCreditTransCount = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Credit_Trans_Count__c;
                String btralCreditAmount = mapCTBFileAuto.get('Insolvency Payment Update').Btral_Credit_Amount__c;
                String ttralRecordTypeCode = mapCTBFileAuto.get('Insolvency Payment Update').Ttral_Record_Type_Code__c;
                String ttralBankNumber = mapCTBFileAuto.get('Insolvency Payment Update').Ttral_Bank_Number__c;
                String ttralDebitAmount = mapCTBFileAuto.get('Insolvency Payment Update').Ttral_Debit_Amount__c;
                String ttralCreditAmount = mapCTBFileAuto.get('Insolvency Payment Update').Ttral_Credit_Amount__c;
                Integer BTRALSeqNum = 3 + countVariable;
                Integer TTRALSeqNum = 4 + countVariable;
                Integer julianDate = calculateJulianDate();

                julianDateCal = defJulianDate;
                julianDateCal = getSpaceAndZeroAdded(String.ValueOf(julianDate), 3, true, false, false);

                gregorianDate = defCreatedDate;
                Datetime currentDatetime = Datetime.now();
                gregorianDate = currentDatetime.format('MMddyy');

                Decimal paymentAmountSum = 0;
                for (Insolvency_Payment__c insolPay : (List<Insolvency_Payment__c>) queryData) {
                    listOfPaymentIds.add(insolPay.id);
                }
                String paymentAmtSumData = defMonetaryPaymentAmtTrans;

                for (Insolvency_Payment__c payment : [
                    SELECT id, Payment_Amount__c
                    FROM Insolvency_Payment__c
                    WHERE id IN :listOfPaymentIds
                ]) {
                    paymentSumTotal.put(payment.Id, payment);
                    if (payment.Payment_Amount__c <> null) {
                        paymentAmountSum += (payment.Payment_Amount__c).setScale(0);
                    }
                }
                paymentAmtSumData = String.valueOf(paymentAmountSum.setScale(0));
                paymentAmtSumData = getSpaceAndZeroAdded(String.ValueOf(paymentAmtSumData), 10, true, false, false);

                String coboloPaymentAmt = defCoboloPaymentAmt;
                coboloPaymentAmt = getSpaceAndZeroAdded(String.ValueOf(getCobolAmount(paymentAmountSum.setScale(0))), 12, true, false, false);

                String btralSeqNumData = getSpaceAndZeroAdded(String.ValueOf(BTRALSeqNum), 7, true, false, false);

                String ttralSeqNumData = getSpaceAndZeroAdded(String.ValueOf(TTRALSeqNum), 7, true, false, false);

                String countVariableData = getSpaceAndZeroAdded(String.ValueOf(countVariable), 6, true, false, false);
                String transmissionNumber = getSpaceAndZeroAdded(String.ValueOf(batchCount), 4, true, false, false);

                Theadbody = buildTHEADBodyData();
                Bheadbody = buildBHEADBodyData();

                //build BTRAL body data countVariable
                BTRAL =
                    btralSeqNumData +
                    btralRecordType +
                    btralBankNumber +
                    btralFormatIden +
                    julianDateCal +
                    transmissionNumber +
                    batchIdentifier +
                    coboloPaymentAmt +
                    btralDebitTransCount +
                    btralDebitAmount +
                    btralCreditTransCount +
                    btralCreditAmount +
                    countVariableData +
                    paymentAmtSumData +
                    extra38Spaces +
                    '\n';

                //build TTRAL body data
                TTRAL =
                    ttralSeqNumData +
                    ttralRecordTypeCode +
                    ttralBankNumber +
                    transmissionNumber +
                    ttralDebitAmount +
                    ttralCreditAmount +
                    paymentAmtSumData.leftPad(12, '0') +
                    extra40Spaces +
                    extra15Spaces +
                    extra15Spaces +
                    extra3Spaces +
                    '\n';

                //build final string to parse
                mainFinalData = Theadbody + Bheadbody + FinalData + BTRAL + TTRAL;
            }

            /*String Filename = 'DRN_DailyUpdate_'+createdDate+dateformate;
            // Create Content Version
            ContentVersion contentVersionData = new ContentVersion();
            contentVersionData.ContentLocation = 'S';
            contentVersionData.VersionData = Blob.valueof(mainFinalData);
            contentVersionData.Title = 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss');
            contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
            insert contentVersionData;

            System.enqueueJob(new CTBApiCalloutsQueueable(contentVersionData.id,queryData,CTBBatchName,Filename));*/

            /**********************Temparory Purpase Added*******************************/
            DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
            Blob fileBlob = Blob.valueOf(mainFinalData);
            //parse string and get response
            if (!Test.isRunningTest()) {
                if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
                    parsedResponse = DocumentAPIClient.postDocument(
                        fileBlob,
                        'DRN_DailyUpdate_' + Datetime.now().format('yyyyMMddHHmmss') + '.csv',
                        'account'
                    );
                } else if (CTBBatchName == System.Label.CTB_Payment) {
                    parsedResponse = DocumentAPIClient.postDocument(
                        fileBlob,
                        'DRN_PaymentUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss') + '.csv',
                        'payment'
                    );
                }
            } else {
                parsedResponse.docUrl = 'Test';
                parsedResponse.docId = 'Test';
            }
            //To DO : We do not need to create Document Storage and in place of it we have to update each insolvency account with CTB Update File Name and CTB Update File Timestamp on rach insolvency account records.
            Document_Storage__c docInfo = new Document_Storage__c();
            if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
                docInfo.Document_Type__c = 'Insolvency Daily Update';
            } else if (CTBBatchName == System.Label.CTB_Payment) {
                docInfo.Document_Type__c = 'Insolvency Payment Update';
            }
            docInfo.Work_Assignment__c = 'a3LS0000000h6NCMAY';
            docInfo.Document_URL__c = parsedResponse.docUrl;
            docInfo.Document_Extension__c = 'csv';
            if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
                docInfo.Document_Name__c = 'DRN_DailyUpdate_' + Datetime.now().format('yyyyMMddHHmmss') + '.csv';
            } else if (CTBBatchName == System.Label.CTB_Payment) {
                docInfo.Document_Name__c = 'DRN_PaymentUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss') + '.csv';
            }
            docInfo.Document_Id__c = parsedResponse.docId;
            docInfo.File_Processing_Status__c = 'Pending';
            docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            insert docInfo;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            /**********************Temparory Purpase Added Ends*******************************/
        } catch (Exception ex) {
            system.debug('Exception msg&&' + ex.getStackTraceString());
            CFG_EmailNotification.apiFailedEmailNotify(
                UserInfo.getName(),
                ex.getMessage() + ' ' + ex.getStackTraceString(),
                CTBBatchName + ' file generation failed'
            );
        }
    }

    public static string buildTHEADBodyData() {
        string theadBodyData;

        String SeqNumber = defSeqNumber;
        SeqNumber = getSpaceAndZeroAdded(String.ValueOf(sequenceNumber), 7, false, true, false);

        String transCode = defTransCode;
        transCode = getSpaceAndZeroAdded(String.ValueOf(theadTransCode), 4, false, true, false);

        String bankNumber = defBankNumber;
        bankNumber = getSpaceAndZeroAdded(String.ValueOf(theadBankNumber), 4, false, true, false);

        String transName = defTransName;
        transName = getSpaceAndZeroAdded(String.ValueOf(theadTransName), 8, false, true, false);

        String transDescription = defTransmissionDesc;
        transDescription = getSpaceAndZeroAdded(String.ValueOf(transmissionDescription), 6, false, true, false);
        //build THEAD body data
        theadBodyData =
            SeqNumber +
            transCode +
            bankNumber +
            transmissionNumber +
            transName +
            extra12Spaces +
            julianDateCal +
            gregorianDate +
            transDescription +
            extra5Spaces +
            commingledFileProcessingFlag +
            multiCurrencyCurrencyCode +
            extra64Spaces +
            transmissionIdentifierFlag +
            '\n';

        return theadBodyData;
    }

    global string buildBHEADBodyData() {
        string bheadBodyData;
        String bheadseqNumber = defBheadSeqNum;
        bheadseqNumber = getSpaceAndZeroAdded(String.ValueOf(bheadsequenceNumber), 7, false, true, false);

        String bheadTransCodeData = defBheadTransCode;
        bheadTransCodeData = getSpaceAndZeroAdded(String.ValueOf(bheadTransCode), 4, false, true, false);

        String bheadBankNum = defBheadBankNumber;
        bheadBankNum = getSpaceAndZeroAdded(String.ValueOf(bheadBankNumber), 4, false, true, false);

        String bheadFormatIden = defBheadFormatIdentifier;
        bheadFormatIden = getSpaceAndZeroAdded(String.ValueOf(bheadFormatIdentifier), 5, false, true, false);

        Integer batchCount = Integer.valueof(config.Payment_Batch_Count__c);
        String batchNumber = getSpaceAndZeroAdded(String.ValueOf(batchCount), 4, true, false, false);

        String transRefNum = defTransReferenceNum;
        transRefNum = getSpaceAndZeroAdded(String.ValueOf(transReferenceNum), 11, false, true, false);

        //build BHEAD body data
        bheadBodyData =
            bheadseqNumber +
            bheadTransCodeData +
            bheadBankNum +
            bheadFormatIden +
            julianDateCal +
            batchNumber +
            batchIdentifier +
            batchIdentifierExtension +
            transRefNum +
            transactionDateOverride +
            alternateAmountIndicator +
            merchantHeaderExclusionFlag +
            extra76Spaces +
            '\n';

        return bheadBodyData;
    }

    public static string getCobolAmount(Decimal paymentAmountSum) {
        String myString = String.valueOf(paymentAmountSum);
        String lastCharacter = '';
        if (!String.isEmpty(myString)) {
            lastCharacter = myString.substring(myString.length() - 1);
        }
        string newstring = myString.removeEnd(lastCharacter);
        string cobolAmount = '';

        if (paymentAmountSum > 0) {
            if (lastCharacter.contains('0')) {
                cobolAmount += lastCharacter.replace('0', '{');
            }
            if (lastCharacter.contains('1')) {
                cobolAmount += lastCharacter.replace('1', 'A');
            }
            if (lastCharacter.contains('2')) {
                cobolAmount += lastCharacter.replace('2', 'B');
            }
            if (lastCharacter.contains('3')) {
                cobolAmount += lastCharacter.replace('3', 'C');
            }
            if (lastCharacter.contains('4')) {
                cobolAmount += lastCharacter.replace('4', 'D');
            }
            if (lastCharacter.contains('5')) {
                cobolAmount += lastCharacter.replace('5', 'E');
            }
            if (lastCharacter.contains('6')) {
                cobolAmount += lastCharacter.replace('6', 'F');
            }
            if (lastCharacter.contains('7')) {
                cobolAmount += lastCharacter.replace('7', 'G');
            }
            if (lastCharacter.contains('8')) {
                cobolAmount += lastCharacter.replace('8', 'H');
            }
            if (lastCharacter.contains('9')) {
                cobolAmount += lastCharacter.replace('9', 'I');
            }
        }

        if (paymentAmountSum < 0) {
            if (lastCharacter.contains('0')) {
                cobolAmount += lastCharacter.replace('0', '}');
            }
            if (lastCharacter.contains('1')) {
                cobolAmount += lastCharacter.replace('1', 'J');
            }
            if (lastCharacter.contains('2')) {
                cobolAmount += lastCharacter.replace('2', 'K');
            }
            if (lastCharacter.contains('3')) {
                cobolAmount += lastCharacter.replace('3', 'L');
            }
            if (lastCharacter.contains('4')) {
                cobolAmount += lastCharacter.replace('4', 'M');
            }
            if (lastCharacter.contains('5')) {
                cobolAmount += lastCharacter.replace('5', 'N');
            }
            if (lastCharacter.contains('6')) {
                cobolAmount += lastCharacter.replace('6', 'O');
            }
            if (lastCharacter.contains('7')) {
                cobolAmount += lastCharacter.replace('7', 'P');
            }
            if (lastCharacter.contains('8')) {
                cobolAmount += lastCharacter.replace('8', 'Q');
            }
            if (lastCharacter.contains('9')) {
                cobolAmount += lastCharacter.replace('9', 'R');
            }
        }
        cobolAmount = newstring + cobolAmount;
        return cobolAmount;
    }

    //handle any exception occur while file generation and create Insolvency Error record.
    public static void exceptionHandling(string errorMsg, string stackTrace, string dataId, List<sObject> Data, string CTBBatchName) {
        Map<id, sObject> errorMapData = new Map<id, sObject>();
        if (Data <> null) {
            if (CTBBatchName == System.Label.CTB_Insolvency_Account) {
                for (insolvency_account__c insolAccData : (List<insolvency_account__c>) Data) {
                    insolAccData.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                    errorMapData.put(insolAccData.id, insolAccData);
                }
            }
            if (CTBBatchName == System.Label.CTB_Payment && Data <> null) {
                for (Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>) Data) {
                    insolPayData.Payment_Sub_Status__c = 'File Error Parsing Record';
                    errorMapData.put(insolPayData.id, insolPayData);
                }
            }
            update errorMapData.values();
        }
        List<Insolvency_Error__c> listInsolErrors = new List<Insolvency_Error__c>();
        Insolvency_Error__c insolErrorData = new Insolvency_Error__c();
        if (stackTrace != null) {
            insolErrorData.Error__c = 'Record failed due to' + ' ' + errorMsg + ' ' + stackTrace;
        } else {
            insolErrorData.Error__c = 'Record failed due to' + ' ' + errorMsg;
        }
        if (dataId != null) {
            insolErrorData.Insolvency_Account__c = dataId;
        }
        listInsolErrors.add(insolErrorData);
        insert listInsolErrors;
    }

    public class wrapperClass {
        public Integer batchCountDetail { get; set; }
        public string finalDetailBody { get; set; }
    }

    public static string getSpaceAndZeroAdded(String fieldName, Integer fieldLength, Boolean extraZeros, Boolean extraSpaces, Boolean rightPad) {
        string fieldData;
        if (fieldName != null && extraZeros == true) {
            if (String.valueOf(fieldName).length() < fieldLength) {
                fieldData = String.valueOf(fieldName).leftPad(fieldLength, '0');
            } else if (String.valueOf(fieldName).length() == fieldLength) {
                fieldData = String.valueOf(fieldName);
            } else if (String.valueOf(fieldName).length() > fieldLength) {
                fieldData = String.valueOf(fieldName).substring(0, fieldLength);
            }
        }
        if (fieldName != null && rightPad == false && extraSpaces == true) {
            if (String.valueOf(fieldName).length() < fieldLength) {
                fieldData = String.valueOf(fieldName).leftPad(fieldLength);
            } else if (String.valueOf(fieldName).length() == fieldLength) {
                fieldData = String.valueOf(fieldName);
            } else if (String.valueOf(fieldName).length() > fieldLength) {
                fieldData = String.valueOf(fieldName).substring(0, fieldLength);
            }
        }
        if (fieldName != null && rightPad == true && extraSpaces == true) {
            if (String.valueOf(fieldName).length() < fieldLength) {
                fieldData = String.valueOf(fieldName).rightPad(fieldLength);
            } else if (String.valueOf(fieldName).length() == fieldLength) {
                fieldData = String.valueOf(fieldName);
            } else if (String.valueOf(fieldName).length() > fieldLength) {
                fieldData = String.valueOf(fieldName).substring(0, fieldLength);
            }
        }
        return fieldData;
    }

    public static Integer calculateJulianDate() {
        Date date1 = Date.TODAY().addDays(1);
        Integer yearCal = date1.Year();
        Date startYear = Date.newInstance(yearCal, 1, 1);

        Integer numberDaysDue = startYear.daysBetween(date1);

        return numberDaysDue;
    }

    public static string formatDate_MM_DD_YY(Date dateToFormat) {
        String returnValue = '';
        String day = String.valueOf(dateToFormat.day());
        day = day.leftPad(2, '0');

        String month = String.valueOf(dateToFormat.month());
        month = month.leftPad(2, '0');

        String year = String.valueOf(dateToFormat.year());
        year = string.valueof(year).right(2);
        returnValue = month + day + year;
        return returnValue;
    }
}