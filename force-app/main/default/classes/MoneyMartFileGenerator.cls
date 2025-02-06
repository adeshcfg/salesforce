/*****************************************************************************************************************
* Author         : A5E Consultancy
* Created On     : 06 Jan 2025
* Description    : This file layout is used for DRN to send insolvency updates to an Insolvency Client and 
for the Client to send return detailed information to DRN.
                            
******************************************************************************************************************/

global class MoneyMartFileGenerator implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts {
    public static map<String, CTB_File_Automation__mdt> mapCTBFileAutomation = CTB_File_Automation__mdt.getAll();
    public map<String, CTB_File_Automation__mdt> mapCTBFileAuto = new Map<String, CTB_File_Automation__mdt>();
    public static Map<String, Insolvency_type_mapping__mdt> insolTypeMap = Insolvency_type_mapping__mdt.getAll();
    public Map<String, Insolvency_type_mapping__mdt> insolTypeMappingData = new Map<String, Insolvency_type_mapping__mdt>();
    public static Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    public String ctbBatchName;
    public static final String recordType = 'Money_Mart_Insolvency_Account';
    public static final String clientIdentifier = 'Money Mart';
    public static final String coDebtor = 'coDebtor';  
    public static final String borrower = 'borrower';
    String finalData = '';
    public List<sObject> queryData = new List<sObject>();
    String createdDate = '';
    public String dateFormate = '';
    public static string headBody = '';
    public static string trailerBody = '';
    Integer countVariable = 0;
    public Integer sequenceCountNumberCnt = 0;

    global MoneyMartFileGenerator(String batchName) {
        //get Batch Name from Scheduler
        ctbBatchName = batchName;
        // get value from CTB File Automation custom metadata
        for (CTB_File_Automation__mdt metaData : mapCTBFileAutomation.values()) {
            mapCTBFileAuto.put(metaData.MasterLabel, metaData);
        }
        createdDate = convertDateToString(System.today());
        dateFormate = Datetime.now().format('HH:mm:ss');
        
        for(Insolvency_type_mapping__mdt insolTypeMapping : insolTypeMap.values()){
            insolTypeMappingData.put(insolTypeMapping.MasterLabel, insolTypeMapping);
        }
    }

    // Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        sequenceCountNumberCnt = 3;
        //List<String> listNames = new List<String>{'101010','010101'};
        String query = '';
        //fetch records based on batchName
        if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
            query =
                ' Select id,name,Insolvency_Received_Date__c,Insolvency__r.Insolvency_Type__c,Debtor_1_First_Name__c,Last_Payment_Date__c,Last_Payment_Amount__c,Last_Payment_Date_2__c,Last_Payment_Amount_2__c,Additional_Info__c,Charge_Off_Date__c,Judgement_Date__c,' +
                'Debtor_1_Last_Name__c,Province_Formula__c,Insolvency__r.Debtor_1_Mailing_Country__c,Debtor_1_Mailing_Postal_Code__c,Interest_Rate__c,Last_Payment_Date_3__c,Last_Payment_Amount_3__c,Last_Statement_Date__c,Last_Statement_Amount__c,Last_Statement_Date_2__c,Acknowledgement_date__c,' +
                'Debtor_1_SIN__c,Debtor_1_Date_of_Birth__c,Insolvency__r.Insolvency_Date__c,Insolvency__r.name,Insolvency__r.Debtor_2_Estate_Number__c,Trustee_Company__c,Correlation_ID__c,Balance_Owed__c,Last_Statement_Amount_2__c,Last_Statement_Date_3__c,Last_Statement_Amount_3__c,' +
                'Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Debtor_1_First_Name__c,Insolvency__r.Debtor_1_Last_Name__c,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,CTB_Date_of_Birth__c,Claim_Amount__c,Previous_Account_Reference__c,' +
                'Insolvency__r.Trustee__r.BillingPostalCode,Debtor_1_Mailing_Street__c,CTB_Status_Update_Code__c,Insolvency__r.Debtor_1_Middle_Name__c,Debtor_1_Mailing_City__c,No_Match_Debtor__c,No_Match_Co_Debtor__c,Account_Original_Open_Date__c,Accounts_Validation_Date__c,' +
                'Debtor_2_First_Name__c,Insolvency__r.Debtor_2_First_Name__c,Insolvency__r.Debtor_2_Middle_Name__c,Debtor_2_Last_Name__c,Insolvency__r.Debtor_2_Last_Name__c, Street_Name_Number__c, City__c,Province__c,Insolvency__r.Debtor_2_Mailing_Country__c,Postal_Code__c,Insolvency__r.Debtor_2_SIN__c,Debtor_2_Date_of_Birth__c ' +
                'FROM Insolvency_Account__c ' +
                'WHERE ' +
                'RecordType.developerName = :recordType AND Correlation_Id__c != null AND ' +
                'Insolvency_Sub_Status__c = \'Pending File\'';
            if (Test.isRunningTest()) {
                query =
                    ' Select id,name,Insolvency_Received_Date__c,Insolvency__r.Insolvency_Type__c,Debtor_1_First_Name__c,Last_Payment_Date__c,Last_Payment_Amount__c,Last_Payment_Date_2__c,Last_Payment_Amount_2__c,Additional_Info__c,Charge_Off_Date__c,Judgement_Date__c,' +
                'Debtor_1_Last_Name__c,Province_Formula__c,Insolvency__r.Debtor_1_Mailing_Country__c,Debtor_1_Mailing_Postal_Code__c,Interest_Rate__c,Last_Payment_Date_3__c,Last_Payment_Amount_3__c,Last_Statement_Date__c,Last_Statement_Amount__c,Last_Statement_Date_2__c,Acknowledgement_date__c,' +
                'Debtor_1_SIN__c,Debtor_1_Date_of_Birth__c,Insolvency__r.Insolvency_Date__c,Insolvency__r.name,Insolvency__r.Debtor_2_Estate_Number__c,Trustee_Company__c,Correlation_ID__c,Balance_Owed__c,Last_Statement_Amount_2__c,Last_Statement_Date_3__c,Last_Statement_Amount_3__c,' +
                'Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Debtor_1_First_Name__c,Insolvency__r.Debtor_1_Last_Name__c,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,CTB_Date_of_Birth__c,Claim_Amount__c,Previous_Account_Reference__c,' +
                'Insolvency__r.Trustee__r.BillingPostalCode,Debtor_1_Mailing_Street__c,CTB_Status_Update_Code__c,Insolvency__r.Debtor_1_Middle_Name__c,Debtor_1_Mailing_City__c,No_Match_Debtor__c,No_Match_Co_Debtor__c,Account_Original_Open_Date__c,Accounts_Validation_Date__c,' +
                'Debtor_2_First_Name__c,Insolvency__r.Debtor_2_First_Name__c,Insolvency__r.Debtor_2_Middle_Name__c,Debtor_2_Last_Name__c,Insolvency__r.Debtor_2_Last_Name__c, Street_Name_Number__c, City__c,Province__c,Insolvency__r.Debtor_2_Mailing_Country__c,Postal_Code__c,Insolvency__r.Debtor_2_SIN__c,Debtor_2_Date_of_Birth__c ' +
                'FROM Insolvency_Account__c ';
            }
        }
        return Database.getQueryLocator(query);
    }

    //Execute Method: based on batch name call respective method
    global void execute(Database.BatchableContext BC, List<sObject> query) {
        List<Insolvency_Account__c> coDebtorList = new List<Insolvency_Account__c>();
        if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
            for(Insolvency_Account__c insolAcctsData :(List<Insolvency_Account__c>) query){
                if(insolAcctsData.Insolvency__r.Debtor_2_First_Name__c <> NULL && insolAcctsData.Insolvency__r.Debtor_2_Last_Name__c <> NULL){
                    coDebtorList.add(insolAcctsData);
                }
            }
           
            // build insolvency daily update file coDebtor body
             wrapperClass coDebtorBatchCnt = new wrapperClass();
            coDebtorBatchCnt = getInsolvencyAccountFile(mapCTBFileAuto, insolTypeMappingData, coDebtorList, createdDate, dateFormate, ctbBatchName,coDebtor);  
            
            // build insolvency daily update file Borrower body
            wrapperClass batchCnt = new wrapperClass();
            batchCnt = getInsolvencyAccountFile(mapCTBFileAuto, insolTypeMappingData, query, createdDate, dateFormate, ctbBatchName,borrower);

            finalData += batchCnt.finalDetailBody;
            finalData += coDebtorBatchCnt.finalDetailBody;

            countVariable += batchCnt.batchCountDetail;
            countVariable += coDebtorBatchCnt.batchCountDetail;
        }
    }

    // Build body for Insolvency Daily Update file generation
    public wrapperClass getInsolvencyAccountFile(
        map<String, CTB_File_Automation__mdt> mapCTBFileAuto,
        map<String, Insolvency_type_mapping__mdt> insolTypeMappingData,
        List<Insolvency_Account__c> insolvencyAccData,
        String createdDate,
        String dateFormate,
        string ctbBatchName,
        string borrowerName
    ) {
        Integer counter = 0;
        string mainBody = '';
        wrapperClass batchCntData = new wrapperClass();
        Map<id, Insolvency_Account__c> insolvAcctErrorListMap = new Map<id, Insolvency_Account__c>();
		Insolvency_Account__c insolAccError = new Insolvency_Account__c();
        Map<String,String>  getCommonBodyMapData = getCommonBodyData(insolvencyAccData,insolTypeMappingData);
        try {
            //retrive data from CTB File Automation custom metadata
            String memberType = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Member_Type__c;
            String memberID = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Member_ID__c;
            String detailRecordType = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Detail_Record_Type__c;
            String productDesc = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Product_Description__c;
            String productID = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').DRN_Debt_Product_ID__c;
            String DRNTrusteeID = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').DRN_Trustee_ID__c;
            Integer batchCount = Integer.valueof(config.Insolvency_Account_Batch_Count__c);

            /*******************************************Body Data*************************************************/
            for (Insolvency_Account__c insolAccData : insolvencyAccData) {
                    String debtorFirstName = '';
                	String debtorLastName = '';
                	String addressLine1 = '';
                	String debtorMailingCity = '';
                	String province = '';
                	String mailingCountry = '';
                	String mailingPostalCode = '';
                	String SIN = '';
                	String dateOfBirth = '';
                	String estateNumber = '';
                	String insolvencyDate = '';
                	String openDate = '';
                    String trusteeCompany = '';
                	String trusteeAddress = '';
                	String trusteeCity = '';
                	String trusteeState = '';
                	String trusteePostalCode = '';
                	string ctbStatusUpdateCode = '';
                	string correlationID = '';
                	string insolvencyType = '';
                	string accountOriginalOpenDate = '';
                	string balanceOwned = '';
                	string currentInterestRate = '';
                	string currentLastPaymentDate = '';
                    string currentLastPaymentAmt = '';
                    string secondLastPaymentDate = '';
                    string secondLastPaymentAmt = '';
                    string thirdLastPaymentDate = '';
                    string thirdLastPaymentAmt = '';
                	string currentLastStatementDate = '';
                    string currentLastStatementAmt = '';
                    string secondLastStatementDate = '';
                    string secondLastStatementAmt = '';
                    string thirdLastStatementDate = '';
                    string thirdLastStatementAmt = '';
                	string claimAmount = '';
                	string altAccountNumber = '';
                	string additionalInfo = '';
                	string chargeOffDate = '';
                	string judgmentDate = '';
                	string acknowledgementDate = '';
                	string currentBalanceOwingDate = '';
                	
                if(insolAccData.No_Match_Debtor__c != TRUE){
                    if(borrowerName == borrower){
                        if (insolAccData.Debtor_1_First_Name__c != null) {
                            if (insolAccData.Debtor_1_First_Name__c.length() > 40) {
                                debtorFirstName = insolAccData.Debtor_1_First_Name__c.subString(0, 40);
                            } else {
                                debtorFirstName = insolAccData.Debtor_1_First_Name__c;
                            }
                        }else{
                            if (insolAccData.Insolvency__r.Debtor_1_First_Name__c != null 
                                && insolAccData.Insolvency__r.Debtor_1_Middle_Name__c != null) {
                                    string inslodebtorFirstName = '';
                                    string debtorMiddleName = '';
                                    if (insolAccData.Insolvency__r.Debtor_1_First_Name__c.length() > 40) {
                                        inslodebtorFirstName = insolAccData.Insolvency__r.Debtor_1_First_Name__c.subString(0, 40);
                                    } else {
                                        inslodebtorFirstName = insolAccData.Insolvency__r.Debtor_1_First_Name__c;
                                    }
                                    if (insolAccData.Insolvency__r.Debtor_1_Middle_Name__c.length() > 40) {
                                        debtorMiddleName = insolAccData.Insolvency__r.Debtor_1_Middle_Name__c.subString(0, 40);
                                    } else {
                                        debtorMiddleName = insolAccData.Insolvency__r.Debtor_1_Middle_Name__c;
                                    }
                                    debtorFirstName = inslodebtorFirstName + debtorMiddleName;
                                }else{
                                    if (insolAccData.Insolvency__r.Debtor_1_First_Name__c != null){
                                        if (insolAccData.Insolvency__r.Debtor_1_First_Name__c.length() > 40) {
                                            debtorFirstName = insolAccData.Insolvency__r.Debtor_1_First_Name__c.subString(0, 40);
                                        } else {
                                            debtorFirstName = insolAccData.Insolvency__r.Debtor_1_First_Name__c;
                                        }
                                    }
                                }
                        }
                        if (insolAccData.Debtor_1_Last_Name__c != null) {
                            if (insolAccData.Debtor_1_Last_Name__c.length() > 40) {
                                debtorLastName = insolAccData.Debtor_1_Last_Name__c.subString(0, 40);
                            } else {
                                debtorLastName = insolAccData.Debtor_1_Last_Name__c;
                            }
                        }else{
                            if(insolAccData.Insolvency__r.Debtor_1_Last_Name__c != null){
                                if (insolAccData.Insolvency__r.Debtor_1_Last_Name__c.length() > 40) {
                                    debtorLastName = insolAccData.Insolvency__r.Debtor_1_Last_Name__c.subString(0, 40);
                                } else {
                                    debtorLastName = insolAccData.Insolvency__r.Debtor_1_Last_Name__c;
                                }    
                            }
                        }
                        if (insolAccData.Debtor_1_Mailing_Street__c != null) {
                            if (insolAccData.Debtor_1_Mailing_Street__c.length() > 80) {
                                addressLine1 = insolAccData.Debtor_1_Mailing_Street__c.subString(0, 80);
                            } else {
                                addressLine1 = insolAccData.Debtor_1_Mailing_Street__c;
                            }
                        }
                        if (insolAccData.Debtor_1_Mailing_City__c != null) {
                            if (insolAccData.Debtor_1_Mailing_City__c.length() > 40) {
                                debtorMailingCity = insolAccData.Debtor_1_Mailing_City__c.subString(0, 40);
                            } else {
                                debtorMailingCity = insolAccData.Debtor_1_Mailing_City__c;
                            }
                        }
                        if (insolAccData.Province_Formula__c != null) {
                            province = CustomerProcessingBatchHelper.getProvinceCode(insolAccData.Province_Formula__c);
                        }
                        if (insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c != null) {
                            mailingCountry = CustomerProcessingBatchHelper.getMailingCountry(insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c);
                        }
                        if (insolAccData.Debtor_1_Mailing_Postal_Code__c != null) {
                            if (insolAccData.Debtor_1_Mailing_Postal_Code__c.length() > 15) {
                                mailingPostalCode = insolAccData.Debtor_1_Mailing_Postal_Code__c.subString(0, 15);
                            } else {
                                mailingPostalCode = insolAccData.Debtor_1_Mailing_Postal_Code__c;
                            }
                        }
                        if (insolAccData.Debtor_1_SIN__c != null) {
                            if (insolAccData.Debtor_1_SIN__c.length() > 8) {
                                SIN = insolAccData.Debtor_1_SIN__c.subString(0, 8);
                            } else {
                                SIN = insolAccData.Debtor_1_SIN__c;
                            }
                        } 
                        if (insolAccData.CTB_Date_of_Birth__c != null) {
                            dateOfBirth = convertDateToString(insolAccData.CTB_Date_of_Birth__c);
                        } else {
                            dateOfBirth = convertDateToString(insolAccData.Debtor_1_Date_of_Birth__c);
                        }
                        if (insolAccData.Insolvency__r.name != null) {
                            estateNumber = insolAccData.Insolvency__r.name;
                        }
                    }
                    insolvencyDate = getCommonBodyMapData.get(insolAccData.id+'insolvencyDate');	
                	openDate = getCommonBodyMapData.get(insolAccData.id+'openDate');
                	trusteeCompany = getCommonBodyMapData.get(insolAccData.id+'trusteeCompany');
                	trusteeAddress = getCommonBodyMapData.get(insolAccData.id+'trusteeAddress');
                	trusteeCity = getCommonBodyMapData.get(insolAccData.id+'trusteeCity');
                	trusteeState = getCommonBodyMapData.get(insolAccData.id+'trusteeState');
                	trusteePostalCode = getCommonBodyMapData.get(insolAccData.id+'trusteePostalCode');
                	ctbStatusUpdateCode = getCommonBodyMapData.get(insolAccData.id+'ctbStatusUpdateCode');
                	insolvencyType = getCommonBodyMapData.get(insolAccData.id+'insolvencyType');
					correlationID = getCommonBodyMapData.get(insolAccData.id+'correlationID');
                    accountOriginalOpenDate = getCommonBodyMapData.get(insolAccData.id+'accountOriginalOpenDate');
                    balanceOwned = getCommonBodyMapData.get(insolAccData.id+'balanceOwned');
                    currentInterestRate = getCommonBodyMapData.get(insolAccData.id+'currentInterestRate');
                    currentLastPaymentDate = getCommonBodyMapData.get(insolAccData.id+'currentLastPaymentDate');
                    currentLastPaymentAmt = getCommonBodyMapData.get(insolAccData.id+'currentLastPaymentAmt');
                    secondLastPaymentDate = getCommonBodyMapData.get(insolAccData.id+'secondLastPaymentDate');
                    secondLastPaymentAmt = getCommonBodyMapData.get(insolAccData.id+'secondLastPaymentAmt');
                    thirdLastPaymentDate = getCommonBodyMapData.get(insolAccData.id+'thirdLastPaymentDate');
                    thirdLastPaymentAmt = getCommonBodyMapData.get(insolAccData.id+'thirdLastPaymentAmt');
                    currentLastStatementDate = getCommonBodyMapData.get(insolAccData.id+'currentLastStatementDate');
                    currentLastStatementAmt = getCommonBodyMapData.get(insolAccData.id+'currentLastStatementAmt');
                    secondLastStatementDate = getCommonBodyMapData.get(insolAccData.id+'secondLastStatementDate');
                    secondLastStatementAmt = getCommonBodyMapData.get(insolAccData.id+'secondLastStatementAmt');
                    thirdLastStatementDate = getCommonBodyMapData.get(insolAccData.id+'thirdLastStatementDate');
                    thirdLastStatementAmt = getCommonBodyMapData.get(insolAccData.id+'thirdLastStatementAmt');
                    claimAmount = getCommonBodyMapData.get(insolAccData.id+'claimAmount');
                    altAccountNumber = getCommonBodyMapData.get(insolAccData.id+'altAccountNumber');
                    additionalInfo = getCommonBodyMapData.get(insolAccData.id+'additionalInfo');
                    chargeOffDate = getCommonBodyMapData.get(insolAccData.id+'chargeOffDate');
                    judgmentDate = getCommonBodyMapData.get(insolAccData.id+'judgmentDate');
                    acknowledgementDate = getCommonBodyMapData.get(insolAccData.id+'acknowledgementDate');
                    currentBalanceOwingDate = getCommonBodyMapData.get(insolAccData.id+'currentBalanceOwingDate');
                }
                    
                if(insolAccData.No_Match_Co_Debtor__c != TRUE){
                    if(borrowerName == coDebtor){
                        if (insolAccData.Debtor_2_First_Name__c != null) {
                            if (insolAccData.Debtor_2_First_Name__c.length() > 40) {
                                debtorFirstName = insolAccData.Debtor_2_First_Name__c.subString(0, 40);
                            } else {
                                debtorFirstName = insolAccData.Debtor_2_First_Name__c;
                            }
                        }else{
                            if (insolAccData.Insolvency__r.Debtor_2_First_Name__c != null 
                                && insolAccData.Insolvency__r.Debtor_2_Middle_Name__c != null) {
                                    string inslodebtorFirstName = '';
                                    string debtorMiddleName = '';
                                    if (insolAccData.Insolvency__r.Debtor_2_First_Name__c.length() > 40) {
                                        inslodebtorFirstName = insolAccData.Insolvency__r.Debtor_2_First_Name__c.subString(0, 40);
                                    } else {
                                        inslodebtorFirstName = insolAccData.Insolvency__r.Debtor_2_First_Name__c;
                                    }
                                    if (insolAccData.Insolvency__r.Debtor_2_Middle_Name__c.length() > 40) {
                                        debtorMiddleName = insolAccData.Insolvency__r.Debtor_2_Middle_Name__c.subString(0, 40);
                                    } else {
                                        debtorMiddleName = insolAccData.Insolvency__r.Debtor_2_Middle_Name__c;
                                    }
                                    debtorFirstName = inslodebtorFirstName + debtorMiddleName;
                                }else{
                                    if (insolAccData.Insolvency__r.Debtor_2_First_Name__c != null){
                                        if (insolAccData.Insolvency__r.Debtor_2_First_Name__c.length() > 40) {
                                            debtorFirstName = insolAccData.Insolvency__r.Debtor_2_First_Name__c.subString(0, 40);
                                        } else {
                                            debtorFirstName = insolAccData.Insolvency__r.Debtor_2_First_Name__c;
                                        }
                                    }
                                }
                        }
                        if (insolAccData.Debtor_2_Last_Name__c != null) {
                            if (insolAccData.Debtor_2_Last_Name__c.length() > 40) {
                                debtorLastName = insolAccData.Debtor_2_Last_Name__c.subString(0, 40);
                            } else {
                                debtorLastName = insolAccData.Debtor_2_Last_Name__c;
                            }
                        }else{
                            if(insolAccData.Insolvency__r.Debtor_2_Last_Name__c != null){
                                if (insolAccData.Insolvency__r.Debtor_2_Last_Name__c.length() > 40) {
                                    debtorLastName = insolAccData.Insolvency__r.Debtor_2_Last_Name__c.subString(0, 40);
                                } else {
                                    debtorLastName = insolAccData.Insolvency__r.Debtor_2_Last_Name__c;
                                }    
                            }
                        }
                        if (insolAccData.Street_Name_Number__c != null) {
                            if (insolAccData.Street_Name_Number__c.length() > 80) {
                                addressLine1 = insolAccData.Street_Name_Number__c.subString(0, 80);
                            } else {
                                addressLine1 = insolAccData.Street_Name_Number__c;
                            }
                        }
                        if (insolAccData.City__c != null) {
                            if (insolAccData.City__c.length() > 40) {
                                debtorMailingCity = insolAccData.City__c.subString(0, 40);
                            } else {
                                debtorMailingCity = insolAccData.City__c;
                            }
                        }
                        if (insolAccData.Province__c != null) {
                            province = CustomerProcessingBatchHelper.getProvinceCode(insolAccData.Province__c);
                        } 
                        if (insolAccData.Insolvency__r.Debtor_2_Mailing_Country__c != null) {
                            mailingCountry = CustomerProcessingBatchHelper.getMailingCountry(insolAccData.Insolvency__r.Debtor_2_Mailing_Country__c);
                        }
                       if (insolAccData.Postal_Code__c != null) {
                            if (insolAccData.Postal_Code__c.length() > 15) {
                                mailingPostalCode = insolAccData.Postal_Code__c.subString(0, 15);
                            } else {
                                mailingPostalCode = insolAccData.Postal_Code__c;
                            }
                        } 
                       if (insolAccData.Insolvency__r.Debtor_2_SIN__c != null) {
                            if (insolAccData.Insolvency__r.Debtor_2_SIN__c.length() > 8) {
                                SIN = insolAccData.Insolvency__r.Debtor_2_SIN__c.subString(0, 8);
                            } else {
                                SIN = insolAccData.Insolvency__r.Debtor_2_SIN__c;
                            }
                        } 
                        if (insolAccData.CTB_Date_of_Birth__c != null) {
                            dateOfBirth = convertDateToString(insolAccData.CTB_Date_of_Birth__c);
                        } else {
                            dateOfBirth = convertDateToString(insolAccData.Debtor_2_Date_of_Birth__c);
                        }
                        if (insolAccData.Insolvency__r.Debtor_2_Estate_Number__c != null) {
                            estateNumber = insolAccData.Insolvency__r.Debtor_2_Estate_Number__c;
                        }
                    }
                	insolvencyDate = getCommonBodyMapData.get(insolAccData.id+'insolvencyDate');	
                	openDate = getCommonBodyMapData.get(insolAccData.id+'openDate');
                	trusteeCompany = getCommonBodyMapData.get(insolAccData.id+'trusteeCompany');
                	trusteeAddress = getCommonBodyMapData.get(insolAccData.id+'trusteeAddress');
                	trusteeCity = getCommonBodyMapData.get(insolAccData.id+'trusteeCity');
                	trusteeState = getCommonBodyMapData.get(insolAccData.id+'trusteeState');
                	trusteePostalCode = getCommonBodyMapData.get(insolAccData.id+'trusteePostalCode');
                	ctbStatusUpdateCode = getCommonBodyMapData.get(insolAccData.id+'ctbStatusUpdateCode');
                	insolvencyType = getCommonBodyMapData.get(insolAccData.id+'insolvencyType');
                    correlationID = getCommonBodyMapData.get(insolAccData.id+'correlationID');
                    accountOriginalOpenDate = getCommonBodyMapData.get(insolAccData.id+'accountOriginalOpenDate');
                    balanceOwned = getCommonBodyMapData.get(insolAccData.id+'balanceOwned');
                    currentInterestRate = getCommonBodyMapData.get(insolAccData.id+'currentInterestRate');
                    currentLastPaymentDate = getCommonBodyMapData.get(insolAccData.id+'currentLastPaymentDate');
                    currentLastPaymentAmt = getCommonBodyMapData.get(insolAccData.id+'currentLastPaymentAmt');
                    secondLastPaymentDate = getCommonBodyMapData.get(insolAccData.id+'secondLastPaymentDate');
                    secondLastPaymentAmt = getCommonBodyMapData.get(insolAccData.id+'secondLastPaymentAmt');
                    thirdLastPaymentDate = getCommonBodyMapData.get(insolAccData.id+'thirdLastPaymentDate');
                    thirdLastPaymentAmt = getCommonBodyMapData.get(insolAccData.id+'thirdLastPaymentAmt');
                    currentLastStatementDate = getCommonBodyMapData.get(insolAccData.id+'currentLastStatementDate');
                    currentLastStatementAmt = getCommonBodyMapData.get(insolAccData.id+'currentLastStatementAmt');
                    secondLastStatementDate = getCommonBodyMapData.get(insolAccData.id+'secondLastStatementDate');
                    secondLastStatementAmt = getCommonBodyMapData.get(insolAccData.id+'secondLastStatementAmt');
                    thirdLastStatementDate = getCommonBodyMapData.get(insolAccData.id+'thirdLastStatementDate');
                    thirdLastStatementAmt = getCommonBodyMapData.get(insolAccData.id+'thirdLastStatementAmt');
                    claimAmount = getCommonBodyMapData.get(insolAccData.id+'claimAmount');
                    altAccountNumber = getCommonBodyMapData.get(insolAccData.id+'altAccountNumber');
                    additionalInfo = getCommonBodyMapData.get(insolAccData.id+'additionalInfo');
                    chargeOffDate = getCommonBodyMapData.get(insolAccData.id+'chargeOffDate');
                    judgmentDate = getCommonBodyMapData.get(insolAccData.id+'judgmentDate');
                    acknowledgementDate = getCommonBodyMapData.get(insolAccData.id+'acknowledgementDate');
                    currentBalanceOwingDate = getCommonBodyMapData.get(insolAccData.id+'currentBalanceOwingDate');
                }
                
                if(!string.isBlank(debtorFirstName)){
                    // buld final body data insolAccData.No_Match_Debtor__c != TRUE
                    mainBody +=
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
                        insolvencyType +
                        '","' +
                        productDesc +
                        '","' +
                        debtorFirstName +
                        '","' +
                        debtorLastName +
                        '","' +
                        addressLine1 +
                        '","' +
                        '' +
                        '","' +
                        debtorMailingCity +
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
                        correlationID +
                        '","' +
                        '' + //canaccede status update
                        '","' +
                        ctbStatusUpdateCode +
                        '","' +
                        accountOriginalOpenDate +
                        '","' +
                        balanceOwned +
                        '","' +
                        currentBalanceOwingDate + 
                        '","' +
                        currentInterestRate +
                        '","' +
                        currentLastPaymentDate +
                        '","' +
                        currentLastPaymentAmt +
                        '","' +
                        secondLastPaymentDate +
                        '","' +
                        secondLastPaymentAmt +
                        '","' +
                        thirdLastPaymentDate +
                        '","' +
                        thirdLastPaymentAmt +
                        '","' +
                        currentLastStatementDate +
                        '","' +
                        currentLastStatementAmt +
                        '","' +
                        secondLastStatementDate +
                        '","' +
                        secondLastStatementAmt +
                        '","' +
                        thirdLastStatementDate +
                        '","' +
                        thirdLastStatementAmt +
                        '","' +
                        claimAmount +
                        '","' +
                        altAccountNumber +
                        '","' +
                        additionalInfo +
                        '","' +
                        chargeOffDate +
                        '","' +
                        judgmentDate +
                        '","' +
                        acknowledgementDate +'"'+
                        '\r\n';
                    counter++;
                    queryData.add(insolAccData);
                }
            }
            /*******************************************Body Data Ends*************************************************/

            try {
                //if any error occur while file build then update status on insolvency account to "File Error Parsing Record"
                if (insolvAcctErrorListMap != null && !insolvAcctErrorListMap.isEmpty()) {
                    update insolvAcctErrorListMap.values();
                }
            } catch (DMLException dmlEx) {
                system.debug('Exception msg@@' + dmlEx.getStackTraceString());
                insolAccError.id = dmlEx.getDmlId(0);
                insolAccError.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                insolAccError.Error_Message__c = dmlEx.getStackTraceString();
                insolvAcctErrorListMap.put(insolAccError.id, insolAccError);
                if(insolvAcctErrorListMap != null && !insolvAcctErrorListMap.isEmpty()) {
                    update insolvAcctErrorListMap.values();
                }
                exceptionHandling(dmlEx.getDMLMessage(0), dmlEx.getStackTraceString(), dmlEx.getDmlId(0), null, ctbBatchName);
                CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), dmlEx.getStackTraceString(), 'Account batch count update Failed');
            }
        } catch (Exception ex) {
            system.debug('Exception msg**' + ex.getStackTraceString());
            exceptionHandling(ex.getMessage(), ex.getStackTraceString(), null, insolvencyAccData, ctbBatchName);
            CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), ex.getStackTraceString(), 'CTB Account Automation Process Failed');
        }
        mainBody = mainBody.replaceAll('null', '');
        batchCntData.finalDetailBody = mainBody;
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
            String dailyUpdateFileName = '';
            String paymentFileName = '';
            String fileName;
            if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
                try {
                    //Batch count is assigned SEQUENTIAL batch number, starting at 1.  Each batch number must be one number greater than the last received regardless if the file is test or production.  This will ensure files aren’t accidentally sent twice or missed
                    Decimal accountBatchCount = config.MM_Insolvency_Account_Batch_Count__c == null ? 0 : config.MM_Insolvency_Account_Batch_Count__c;
                    config.MM_Insolvency_Account_Batch_Count__c = accountBatchCount + 1;
                    update config;
                }
                catch (DMLException dmlEx) {
                    system.debug('Exception msg@@' + dmlEx.getDmlMessage(0));
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), dmlEx.getDmlMessage(0), 'Money Mart Account batch count update Failed');
                    exceptionHandling(dmlEx.getDMLMessage(0), dmlEx.getStackTraceString(), dmlEx.getDmlId(0), null, ctbBatchName);
                    return;
                }
                Integer finalRecordCount = 2 + countVariable;
                String headerType = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Header_Record_Type__c;
                String memberType = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Member_Type__c;
                String memberID = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Member_ID__c;
                Integer batchCount = Integer.valueof(config.MM_Insolvency_Account_Batch_Count__c);
                String fileType = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').File_Type__c;
                String fileFormatIdenfier = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').File_Format_Identifier__c;
                String trailerRecordType = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').Trailer_Record_Type__c;
                dailyUpdateFileName = mapCTBFileAuto.get('Money Mart Insolvency Daily Update').File_Name__c;
                //build heder body data
                headBody =
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
                    dateFormate +
                    '","' +
                    fileType +
                    '","' +
                    fileFormatIdenfier + '"'+
                    '\r\n';
                //build trailer body data
                trailerBody =
                    '"'+trailerRecordType +
                    '","' +
                    memberType +
                    '","' +
                    memberID +
                    '","' +
                    finalRecordCount +
                    '","' +
                    countVariable +
                    '","' +
                    createdDate +
                    '","' +
                    dateFormate +'"'+
                    '\r\n';
                //build final string to parse
                mainFinalData = headBody + finalData + trailerBody;
            }
            

            // Create Content Version
            ContentVersion contentVersionData = new ContentVersion();
            contentVersionData.ContentLocation = 'S';
            contentVersionData.VersionData = Blob.valueof(mainFinalData);
            
            if(ctbBatchName == System.Label.Money_Mart_Insolvency_Account){
                fileName = dailyUpdateFileName + Datetime.now().format('yyyyMMddHHmmss') + '.csv';
                contentVersionData.Title = dailyUpdateFileName + Datetime.now().format('yyyyMMddHHmmss');
                contentVersionData.PathOnClient = 'MoneyMart_DailyUpdate_.csv';
            }
            insert contentVersionData;
            System.enqueueJob(new CTBApiCalloutsQueueable(contentVersionData.id,queryData,ctbBatchName,fileName));

            /**********************Temparory Purpase Added*******************************
            DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
            Blob fileBlob = Blob.valueOf(mainFinalData);
            //parse string and get response
            if (!Test.isRunningTest()) {
                if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
                    parsedResponse = DocumentAPIClient.postDocument(
                        fileBlob,
                        'DRN_DailyUpdate_' + Datetime.now().format('yyyyMMddHHmmss') + '.csv',
                        'account'
                    );
                } else if (ctbBatchName == System.Label.CTB_Payment) {
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
            if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
                docInfo.Document_Type__c = 'Insolvency Daily Update';
            } else if (ctbBatchName == System.Label.CTB_Payment) {
                docInfo.Document_Type__c = 'Insolvency Payment Update';
            }
            docInfo.Work_Assignment__c = 'a3LS0000000h6NCMAY';
            docInfo.Document_URL__c = parsedResponse.docUrl;
            docInfo.Document_Extension__c = 'csv';
            if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
                docInfo.Document_Name__c = 'DRN_DailyUpdate_' + Datetime.now().format('yyyyMMddHHmmss') + '.csv';
            } else if (ctbBatchName == System.Label.CTB_Payment) {
                docInfo.Document_Name__c = 'DRN_PaymentUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss') + '.csv';
            }
            docInfo.Document_Id__c = parsedResponse.docId;
            docInfo.File_Processing_Status__c = 'Pending';
            docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            insert docInfo;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            **********************Temparory Purpase Added Ends*******************************/
        } catch (Exception ex) {
            system.debug('Exception msg&&' + ex.getStackTraceString());
            CFG_EmailNotification.apiFailedEmailNotify(
                UserInfo.getUserId(),
                ex.getMessage() + ' ' + ex.getStackTraceString(),
                ctbBatchName + ' file generation failed'
            );
        }
    }


    //handle any exception occur while file generation and create Insolvency Error record.
    public static void exceptionHandling(string errorMsg, string stackTrace, string dataId, List<sObject> Data, string ctbBatchName) {
        Map<id, sObject> errorMapData = new Map<id, sObject>();
        if (Data <> null) {
            if (ctbBatchName == System.Label.Money_Mart_Insolvency_Account) {
                for (insolvency_account__c insolAccData : (List<insolvency_account__c>) Data) {
                    insolAccData.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                    if(stackTrace == NULL || stackTrace == ''){
                        insolAccData.Error_Message__c = errorMsg;
                    }else{
                        insolAccData.Error_Message__c = stackTrace;
                    }
                    errorMapData.put(insolAccData.id, insolAccData);
                }
            }
            
            try {
                update errorMapData.values();
            }
            catch (DmlException dmlEx) {
                CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), dmlEx.getDmlMessage(0), 'Money Mart Account update Failed after failure');
            }
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
    
    public static Map<String,String> getCommonBodyData(List<Insolvency_Account__c> insolvencyAccData,map<String, 
                                                       Insolvency_type_mapping__mdt> insolTypeMappingData)
    {
        Map<String,String> commonBodyMap = new Map<String,String>();
        String insolvencyDate = '';
        String openDate = '';
        String trusteeCompany = '';
        String trusteeAddress = '';
        String trusteeCity = '';
        String trusteeState = '';
        String trusteePostalCode = '';
        string ctbStatusUpdateCode = '';
        string correlationID = '';
        string insolvencyType = '';
        string accountOriginalOpenDate = '';
        string balanceOwned = '';
        string currentInterestRate = '';
        string currentLastPaymentDate = '';
        string currentLastPaymentAmt = '';
        string secondLastPaymentDate = '';
        string secondLastPaymentAmt = '';
        string thirdLastPaymentDate = '';
        string thirdLastPaymentAmt = '';
        string currentLastStatementDate = '';
        string currentLastStatementAmt = '';
        string secondLastStatementDate = '';
        string secondLastStatementAmt = '';
        string thirdLastStatementDate = '';
        string thirdLastStatementAmt = '';
        string claimAmount = '';
        string altAccountNumber = '';
        string additionalInfo = '';
        string chargeOffDate = '';
        string judgmentDate = '';
        string acknowledgementDate = '';
        string currentBalanceOwingDate = '';
        
        for(Insolvency_Account__c insolAccData : insolvencyAccData){
            if (insolAccData.Insolvency__r.Insolvency_Date__c != null) {
                insolvencyDate = convertDateToString(insolAccData.Insolvency__r.Insolvency_Date__c);
                commonBodyMap.put(insolAccData.id+'insolvencyDate',insolvencyDate);
            }
            if (insolAccData.Insolvency_Received_Date__c != null) {
                openDate = convertDateToString(insolAccData.Insolvency_Received_Date__c);
                commonBodyMap.put(insolAccData.id+'openDate',openDate);
            }
            if (insolAccData.Trustee_Company__c != null) {
                if (insolAccData.Trustee_Company__c.length() > 80) {
                    trusteeCompany = insolAccData.Trustee_Company__c.subString(0, 80);
                } else {
                    trusteeCompany = insolAccData.Trustee_Company__c;
                }
                commonBodyMap.put(insolAccData.id+'trusteeCompany',trusteeCompany);
            }
            if (insolAccData.Insolvency__r.Trustee__r.BillingStreet != null) {
                if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet).length() > 80) {
                    trusteeAddress = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet).subString(0, 80);
                } else {
                    trusteeAddress = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet);
                }
                trusteeAddress = trusteeAddress.escapeUnicode();
                commonBodyMap.put(insolAccData.id+'trusteeAddress',trusteeAddress);
            }
            if (insolAccData.Insolvency__r.Trustee__r.BillingCity != null) {
                if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity).length() > 39) {
                    trusteeCity = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity).subString(0, 39);
                } else {
                    trusteeCity = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity);
                }
                commonBodyMap.put(insolAccData.id+'trusteeCity',trusteeCity);
            }
            if (insolAccData.Insolvency__r.Trustee__r.BillingState != null) {
                if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState).length() > 2) {
                    trusteeState = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState).subString(0, 2);
                } else {
                    trusteeState = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState);
                }
                commonBodyMap.put(insolAccData.id+'trusteeState',trusteeState);
            }
            if (insolAccData.Insolvency__r.Trustee__r.BillingPostalCode != null) {
                if (String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode).length() > 15) {
                    trusteePostalCode = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode).subString(0, 15);
                } else {
                    trusteePostalCode = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode);
                }
                commonBodyMap.put(insolAccData.id+'trusteePostalCode',trusteePostalCode);
            }
            if(insolAccData.CTB_Status_Update_Code__c != null) {
                if (insolAccData.CTB_Status_Update_Code__c.length() > 20) {
                    ctbStatusUpdateCode = insolAccData.CTB_Status_Update_Code__c.subString(0, 20);
                } else {
                    ctbStatusUpdateCode = insolAccData.CTB_Status_Update_Code__c;
                }
                commonBodyMap.put(insolAccData.id+'ctbStatusUpdateCode',ctbStatusUpdateCode);
            }    
            if(insolAccData.Correlation_ID__c != null) {
                if (insolAccData.Correlation_ID__c.length() > 15) {
                    correlationID = insolAccData.Correlation_ID__c.subString(0, 15);
                } else {
                    correlationID = insolAccData.Correlation_ID__c;
                }
                commonBodyMap.put(insolAccData.id+'correlationID',correlationID);
            }
            if(insolTypeMappingData.containsKey(insolAccData.Insolvency__r.Insolvency_Type__c)){
                insolvencyType = insolTypeMappingData.get(insolAccData.Insolvency__r.Insolvency_Type__c).Insolvency_Type__c;
                commonBodyMap.put(insolAccData.id+'insolvencyType',insolvencyType);
            }
            if (insolAccData.Account_Original_Open_Date__c != null) {
                accountOriginalOpenDate = convertDateToString(insolAccData.Account_Original_Open_Date__c);
                commonBodyMap.put(insolAccData.id+'accountOriginalOpenDate',accountOriginalOpenDate);
            }
            if (insolAccData.Balance_Owed__c != null) {
                balanceOwned = String.valueOf(insolAccData.Balance_Owed__c);
                commonBodyMap.put(insolAccData.id+'balanceOwned',balanceOwned);
            }
            if (insolAccData.Interest_Rate__c != null) {
                currentInterestRate = String.valueOf(insolAccData.Interest_Rate__c);
                commonBodyMap.put(insolAccData.id+'currentInterestRate',currentInterestRate);
            }
            if (insolAccData.Last_Payment_Date__c != null) {
                currentLastPaymentDate = convertDateToString(insolAccData.Last_Payment_Date__c);
                commonBodyMap.put(insolAccData.id+'currentLastPaymentDate',currentLastPaymentDate);
            }
            if (insolAccData.Last_Payment_Amount__c != null) {
                currentLastPaymentAmt = String.valueOf(insolAccData.Last_Payment_Amount__c);
                commonBodyMap.put(insolAccData.id+'currentLastPaymentAmt',currentLastPaymentAmt);
            }
            if (insolAccData.Last_Payment_Date_2__c != null) {
                secondLastPaymentDate = convertDateToString(insolAccData.Last_Payment_Date_2__c);
                commonBodyMap.put(insolAccData.id+'secondLastPaymentDate',secondLastPaymentDate);
            }
            if (insolAccData.Last_Payment_Amount_2__c != null) {
                secondLastPaymentAmt = String.valueOf(insolAccData.Last_Payment_Amount_2__c);
                commonBodyMap.put(insolAccData.id+'secondLastPaymentAmt',secondLastPaymentAmt);
            }
            if (insolAccData.Last_Payment_Date_3__c != null) {
                thirdLastPaymentDate = convertDateToString(insolAccData.Last_Payment_Date_3__c);
                commonBodyMap.put(insolAccData.id+'thirdLastPaymentDate',thirdLastPaymentDate);
            }
            if (insolAccData.Last_Payment_Amount_3__c != null) {
                thirdLastPaymentAmt = String.valueOf(insolAccData.Last_Payment_Amount_3__c);
                commonBodyMap.put(insolAccData.id+'thirdLastPaymentAmt',thirdLastPaymentAmt);
            }
            if (insolAccData.Last_Statement_Date__c != null) {
                currentLastStatementDate = convertDateToString(insolAccData.Last_Statement_Date__c);
                commonBodyMap.put(insolAccData.id+'currentLastStatementDate',currentLastStatementDate);
            }
            if (insolAccData.Last_Statement_Amount__c != null) {
                currentLastStatementAmt = String.valueOf(insolAccData.Last_Statement_Amount__c);
                commonBodyMap.put(insolAccData.id+'currentLastStatementAmt',currentLastStatementAmt);
            }
            if (insolAccData.Last_Statement_Date_2__c != null) {
                secondLastStatementDate = convertDateToString(insolAccData.Last_Statement_Date_2__c);
                commonBodyMap.put(insolAccData.id+'secondLastStatementDate',secondLastStatementDate);
            }
            if (insolAccData.Last_Statement_Amount_2__c != null) {
                secondLastStatementAmt = String.valueOf(insolAccData.Last_Statement_Amount_2__c);
                commonBodyMap.put(insolAccData.id+'secondLastStatementAmt',secondLastStatementAmt);
            }
            if (insolAccData.Last_Statement_Date_3__c != null) {
                thirdLastStatementDate = convertDateToString(insolAccData.Last_Statement_Date_3__c);
                commonBodyMap.put(insolAccData.id+'thirdLastStatementDate',thirdLastStatementDate);
            }
            if (insolAccData.Last_Statement_Amount_3__c != null) {
                thirdLastStatementAmt = String.valueOf(insolAccData.Last_Statement_Amount_3__c);
                commonBodyMap.put(insolAccData.id+'thirdLastStatementAmt',thirdLastStatementAmt);
            }
            if (insolAccData.Claim_Amount__c != null) {
                claimAmount = String.valueOf(insolAccData.Claim_Amount__c);
                commonBodyMap.put(insolAccData.id+'claimAmount',claimAmount);
            }
            if (insolAccData.Previous_Account_Reference__c != null) {
                if (String.valueOf(insolAccData.Previous_Account_Reference__c).length() > 50) {
                    altAccountNumber = insolAccData.Previous_Account_Reference__c.subString(0, 50);
                } else {
                    altAccountNumber = insolAccData.Previous_Account_Reference__c;
                }
                
                commonBodyMap.put(insolAccData.id+'altAccountNumber',altAccountNumber);
            }
            if (insolAccData.Additional_Info__c != null) {
                if (String.valueOf(insolAccData.Additional_Info__c).length() > 200) {
                    additionalInfo = String.valueOf(insolAccData.Additional_Info__c).subString(0, 200);
                } else {
                    additionalInfo = String.valueOf(insolAccData.Additional_Info__c);
                }
                additionalInfo = additionalInfo.escapeUnicode();
                commonBodyMap.put(insolAccData.id+'additionalInfo',additionalInfo);
            }
            if (insolAccData.Charge_Off_Date__c != null) {
                chargeOffDate = convertDateToString(insolAccData.Charge_Off_Date__c);
                commonBodyMap.put(insolAccData.id+'chargeOffDate',chargeOffDate);
            }
            if (insolAccData.Judgement_Date__c != null) {
                judgmentDate = convertDateToString(insolAccData.Judgement_Date__c);
                commonBodyMap.put(insolAccData.id+'judgmentDate',judgmentDate);
            }
            if (insolAccData.Acknowledgement_date__c != null) {
                acknowledgementDate = convertDateToString(insolAccData.Acknowledgement_date__c);
                commonBodyMap.put(insolAccData.id+'acknowledgementDate',acknowledgementDate);
            }
            if (insolAccData.Accounts_Validation_Date__c != null) {
                currentBalanceOwingDate = convertDateToString(insolAccData.Accounts_Validation_Date__c);
                commonBodyMap.put(insolAccData.id+'currentBalanceOwingDate',currentBalanceOwingDate);
            }
            
        }
        
        return commonBodyMap;
    }
}