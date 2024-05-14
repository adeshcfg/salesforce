/***************************************************
 * Author         : A5E Consultancy
 * Created On     : 10 July 2023
 * Description    : Generate Metro File Data from Product__c records for Bureau TransUnion
 *
 ***************************************************/

 public class CreditBureauReportingTUBatch implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts {
    public static string blankString = '';
    public static final string defLastModifiedByDate = blankString.leftPad(8, '0');
    public static final string defCreatedDate = blankString.leftPad(8, '0');
    public static final String defDateOpened = blankString.leftPad(8);
    public static final String defProductName = blankString.leftPad(30);
    public static final String defOrignalCreditAmt = blankString.leftPad(9, '0');
    public static final String defPaymentFrequency = blankString.leftPad(1);
    public static final String defMonthPayPlan = blankString.leftPad(9, '0');
    public static final String defFinalActualPayPlan = blankString.leftPad(9, '0');
    public static final String defCurrentPlanVal = blankString.leftPad(9, '0');
    public static final String defPastVal = blankString.leftPad(9, '0');
    public static final String defChargeOffAmount = blankString.leftPad(9, '0');
    public static final String defLastDelinquencyDate = blankString.leftPad(8, '0');
    public static final String defDateClosed = blankString.leftPad(8, '0');
    public static final String defLastPaymentDate = blankString.leftPad(8, '0');
    public static final String defFirstName = blankString.leftPad(20);
    public static final String defLastName = blankString.leftPad(20);
    public static final String defMiddleName = blankString.leftPad(20);
    public static final String defSinNumber = blankString.leftPad(9, '0');
    public static final String defDateOfBirth = blankString.leftPad(8, '0');
    public static final String defPhoneNumber = blankString.leftPad(10, '0');
    public static final String defNumberOfPayments = 'B'.leftPad(24);
    public static final String defAddressLine = blankString.leftPad(32);
    public static final String defAddressLine2 = blankString.leftPad(32);
    public static final String defCityAddress = blankString.leftPad(20);
    public static final String defStateAddress = blankString.leftPad(2);
    public static final String defZipAddres = blankString.leftPad(9);
    public static final String defAccountStatus = blankString.leftPad(2);
    public static final String defPaymentRating = blankString.leftPad(1);
    public static final String defSpecialComments = blankString.leftPad(2);
    public static final String defCustomerInformationIndicator = blankString.leftPad(2);
    public static final String bureauTypeTransUnion = 'TransUnion';
    public static final String productType = 'Distressed Account';
    public static final String k1Segment = blankString.leftPad(30);
    public static map<ID, ID> mapProductJudgmentClaimIssuedID;
    public static final String defReportAddress = blankString.leftPad(96);
    public static final String defReportTelPhoneNum = blankString.leftPad(10);
    public static final String defCanaFinGrp = blankString.leftPad(40);
    public static final String defIdentificationNumber = blankString.leftPad(20);
    public static final String defBureauIdentifier = blankString.leftPad(10);
    public static map<String, Data_Status_Mapping__c> mapDataStatusMapping = Data_Status_Mapping__c.getAll();
    public static map<String, Data_Status_Mapping__c> mapDataStatus = new Map<String, Data_Status_Mapping__c>();
    public static final String INC = 'INC';
    public static final String spaceINC = ' INC';
    public string batchNumber = string.valueOf(DateTime.now());
    public static final String canaccede = 'CANACCEDE';
    public Set<ID> productIds = new Set<ID>();
    public Map<ID, Placement_History__c> placementHistoryMap = new Map<ID, Placement_History__c>();
    public static final String defDateOfAccountInformationDate = '00000000';
    public list<String> includeAgencyList = new List<String>();
    public Map<ID, ID> previousAllocatedAgency = new Map<ID, ID>();
    public Map<ID, ID> previousRecalledAgency = new Map<ID, ID>();
    public Map<ID, ID> preAllocatedAgency = new Map<ID, ID>();
    static String JUDGMENT = 'Judgment';
    static String POST_JUDGMENT = 'Post-Judgment';
    static String PRE_JUDGMENT = 'Pre-Judgment';
    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';
    static Integer STATIC_INTEGER_2 = 2;
    static Integer STATIC_INTEGER_9 = 9;
    static Integer STATIC_INTEGER_10 = 10;
    static Integer STATIC_INTEGER_20 = 20;
    static Integer STATIC_INTEGER_25 = 25;
    static Integer STATIC_INTEGER_30 = 30;
    static Integer STATIC_INTEGER_32 = 32;
    static Integer STATIC_INTEGER_40 = 40;
    static Integer STATIC_INTEGER_96 = 96;

    public CreditBureauReportingTUBatch() {
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        //Only ICT and LRT agencies inclued in bureau reporting
        string agencyList = '';
        if (metro2TransUnion.Agency_Included__c <> null) {
            agencyList = metro2TransUnion.Agency_Included__c;
        }

        List<String> splitDoubleValues = agencyList.split(',');
        Decimal strToDec = 0;
        for (String s : splitDoubleValues) {
            includeAgencyList.add(s);
        }

        String province = '';
        List<String> splitProvinceValues = new List<string>();
        if (metro2TransUnion.Province__c <> null) {
            province = metro2TransUnion.Province__c;
            splitProvinceValues = province.split(',');
        }

        Integer noOfDaysAfterReport = Integer.valueOf(metro2TransUnion.Number_of_Days_After_Reporting__c);
        Date placementDateBefore45;
        if (noOfDaysAfterReport != 0) {
            placementDateBefore45 = System.today().addDays(-noOfDaysAfterReport);
        }

        List<Placement_History__c> placementHistory = [
            SELECT ID, Agency_Id__c, Product__c, Placement_Date__c, Placement_Recall_Date__c, Current_Total_Bal_at_time_of_Recall__c, Placement__c
            FROM Placement_History__c
            WHERE
                Placement__r.Name IN :includeAgencyList
                AND Placement_Date__c < :placementDateBefore45
                AND Placement_Recall_Date__c != NULL
                AND Product__r.State__c IN :splitProvinceValues
                AND Placement_Recall_Date__c = LAST_MONTH
                /*AND (Product__r.Number_Of_Open_Complaint__c = 0
                OR Product__r.Number_Of_Open_Complaint__c = NULL)*/
                AND Product__r.Last_Name__c != NULL
                AND Product__r.First_Name__c != NULL
                AND (NOT Product__r.First_Name__c LIKE '_')
                AND (NOT Product__r.Last_Name__c LIKE '_')
                AND Product__r.Name != NULL
                AND Product__r.Charged_Off_Date__c != NULL
                AND Product__r.Difference_Greater_Than_N_Years__c = FALSE
                AND Product__r.Exclude_for_Reporting__c = FALSE
                AND Product__r.Portfolio_Name_Lookup__c != NULL
        ];
        for (Placement_History__c placeHistory : placementHistory) {
            productIds.add(placeHistory.Product__c);
            placementHistoryMap.put(placeHistory.Product__c, placeHistory);
            previousRecalledAgency.put(placeHistory.Product__c, placeHistory.Placement__c);
        }

        List<Placement_History__c> allocatedPlacementHistory = [
            SELECT ID, Agency_Id__c, Product__c, Placement_Date__c, Placement_Recall_Date__c, Current_Total_Bal_at_time_of_Recall__c, Placement__c
            FROM Placement_History__c
            WHERE
                Placement__r.Name IN :includeAgencyList
                AND Product__c IN :productIds
                AND Placement_Recall_Date__c = NULL
                AND Placement_Date__c != NULL
                AND Product__r.State__c IN :splitProvinceValues
                AND Placement_Date__c = LAST_MONTH
                /*AND (Product__r.Number_Of_Open_Complaint__c = 0
                OR Product__r.Number_Of_Open_Complaint__c = NULL)*/
                AND Product__r.Last_Name__c != NULL
                AND Product__r.First_Name__c != NULL
                AND (NOT Product__r.First_Name__c LIKE '_')
                AND (NOT Product__r.Last_Name__c LIKE '_')
                AND Product__r.Name != NULL
                AND Product__r.Charged_Off_Date__c != NULL
                AND Product__r.Difference_Greater_Than_N_Years__c = FALSE
                AND Product__r.Exclude_for_Reporting__c = FALSE
                AND Product__r.Portfolio_Name_Lookup__c != NULL
        ];

        for (Placement_History__c allocatedPlaceHistory : allocatedPlacementHistory) {
            preAllocatedAgency.put(allocatedPlaceHistory.Product__c, allocatedPlaceHistory.Placement__c);

            if (previousRecalledAgency.get(allocatedPlaceHistory.Product__c) == preAllocatedAgency.get(allocatedPlaceHistory.Product__c)) {
                productIds.add(allocatedPlaceHistory.Product__c);
                previousAllocatedAgency.put(allocatedPlaceHistory.Product__c, allocatedPlaceHistory.Placement__c);
            }
        }
    }

    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        list<string> excludeProdStatusList = new List<string>();
        string prodStatus = metro2TransUnion.Product_Status_Excluded__c;
        //product status excluded from bureau reporting fetch from Metro2_File__c custom setting
        if (prodStatus != null) {
            excludeProdStatusList = prodStatus.split(',');
        }
        list<Decimal> includeAgencyList = new List<Decimal>();
        //Only ICT and LRT agencies inclued in bureau reporting
        string agencyList = '';
        if (metro2TransUnion.Agency_Included__c <> null) {
            agencyList = metro2TransUnion.Agency_Included__c;
        }
        List<String> splitDoubleValues;
        if (agencyList <> null) {
            splitDoubleValues = agencyList.split(',');
        }

        Decimal strToDec = 0;
        for (String s : splitDoubleValues) {
            strToDec = decimal.valueOf(s);
            includeAgencyList.add(strToDec);
        }
        String province = '';
        List<String> splitProvinceValues = new List<string>();
        if (metro2TransUnion.Province__c <> null) {
            province = metro2TransUnion.Province__c;
            splitProvinceValues = province.split(',');
        }

        Integer noOfTimesToReport = Integer.valueOf(metro2TransUnion.Number_of_Times_To_Report__c);
        Integer noOfDaysAfterReport = Integer.valueOf(metro2TransUnion.Number_of_Days_After_Reporting__c);
        Date dayBefore45;
        if (noOfDaysAfterReport != 0) {
            dayBefore45 = System.today().addDays(-noOfDaysAfterReport);
        }

        //Query to fetch all the eligible records with the recordtype as CCS Account
        return Database.getQueryLocator(
            'SELECT Id, Name,RecordType.Name,Collection_Agency__c,Assignment_Date__c,Last_Payment_Amount__c,Portfolio_Name_Lookup__r.CIML_Reporting_Name__c,Purchase_Face_Value__c, Closed_Date__C, Product_Status__c,Createddate,LastModifieddate,Original_Balance__c,Current_Balance__c,Last_Payment_Date__c,Last_Name__c,First_Name__c,Middle_Name__c,SIN__c,Phone_Home__c,Date_of_Birth__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Zip_Code__c,Deceased_Date__c, Charged_Off_Amount__c, TransUnion_Reported_As_Complete_Count__c,Seller__r.name,Charged_Off_Date__c FROM Product__c ' +
                'WHERE ' +
                '((RecordType.Name =: productType AND ' +
                'Product_Status__c NOT IN :excludeProdStatusList AND ' +
                'Collection_Agency__c IN :includeAgencyList AND ' +
               // '(Number_Of_Open_Complaint__c = 0 OR Number_Of_Open_Complaint__c = NULL) AND ' +
                'Last_Name__c != null AND ' +
                'First_Name__c != null AND ' +
                'Name !=null AND ' +
                'Current_Balance__c != null AND ' +
                'Assignment_Date__c <: dayBefore45 AND ' +
                '(NOT First_Name__c LIKE \'_\') AND ' +
                '(NOT Last_Name__c LIKE \'_\') AND ' +
                'Charged_Off_Date__c <> null AND ' +
                'Difference_Greater_Than_N_Years__c = False AND ' +
                'Exclude_for_Reporting__c = False AND ' +
                'Portfolio_Name_Lookup__c <> null AND ' +
                'State__c IN :splitProvinceValues AND ' +
                '(TransUnion_Reported_As_Complete_Count__c = null OR ' +
                'TransUnion_Reported_As_Complete_Count__c <: noOfTimesToReport)) OR (Id IN :productIds AND (TransUnion_Reported_As_Complete_Count__c = null OR TransUnion_Reported_As_Complete_Count__c <: noOfTimesToReport)))'
        );
    }

    //Execute Method
    public void execute(Database.BatchableContext BC, List<Product__c> scope) {
        List<Product__c> listOfProductsToUpdate = new List<Product__c>();
        map<Id, Product__c> mapProduct = new Map<Id, Product__c>();
        mapProductJudgmentClaimIssuedID = new Map<ID, ID>();
        map<id, boolean> mapProductExcluse = new Map<id, boolean>();
        map<String, Credit_Bureau_Reporting_Periods__mdt> mapCreditBureauRepPeriods = Credit_Bureau_Reporting_Periods__mdt.getAll();
        map<String, Credit_Bureau_Reporting_Periods__mdt> mapProvinceAcronymCBRepPeriods = new Map<String, Credit_Bureau_Reporting_Periods__mdt>();
        List<ID> listOfProductIds = new List<ID>();
        Map<id, decimal> mapProductCompCount = new Map<id, decimal>();
        Date minPlacementDate = null;
        Date maxRecallDate = null;
        String finalHeadBody2 = '';
        String finalK1HeadBody2 = '';
        String maxRowslength = '';
        String canaFinGrp = '';
        String TransUnionIdentifier = '';
        String headerCust = '';
        String CA = '';
        String ZAP = '';
        String accountType = '';
        String reporterAddress = '';
        String identificationNumber = '';
        String reporterPhone = '';
        String portfolioType = '';
        String termsDuration = '';
        Integer noOfDaysForDelinquency = 0;
        String currencyTypeCode = blankString.leftPad(17);
        String extra2Spaces = blankString.leftPad(2);
        String extra1Spaces = blankString.leftPad(1);
        String extra9Spaces = blankString.leftPad(9);
        String extra14Spaces = blankString.leftPad(14);
        String extra27Spaces = blankString.leftPad(27);
        String extra16Spaces = blankString.leftPad(16);

        for (Credit_Bureau_Reporting_Periods__mdt metaData : mapCreditBureauRepPeriods.values()) {
            mapProvinceAcronymCBRepPeriods.put(metaData.Province_Name__c, metaData);
        }
        map<ID, Placement_History__c> previouslyPlaced = new Map<ID, Placement_History__c>();
        //get account where previously allocated to agency 6 or 68 then got recalled and again reallocated to same agency
        //again got recalled and then allocated to any other agency after that account gets again recalled or placed with other agency.
        List<Placement_History__c> recalledProducts = [
            SELECT
                id,
                name,
                Placement__c,
                Product__c,
                Product__r.name,
                Placement__r.name,
                Placement_Status_Description__c,
                Placement_Recall_Date__c,
                Placement_Status__c,
                Product__r.Collection_Agency__c
            FROM Placement_History__c
            WHERE
                Product__c IN :productIds
                AND Placement_Recall_Date__c != NULL
                AND Product__r.Collection_Agency__c != NULL
                AND (Product__r.Collection_Agency__c = 9999
                OR Product__r.Collection_Agency__c != 9999)
            ORDER BY CreatedDate DESC
        ];
        for (Placement_History__c placeHistory : recalledProducts) {
            if (!previouslyPlaced.containsKey(placeHistory.Product__c)) {
                previouslyPlaced.put(placeHistory.Product__c, placeHistory);
            }
        }

        AggregateResult[] placeHistory = [
            SELECT Min(Placement_Date__c) firstPlacementDate, Max(Placement_Recall_Date__c) lastRecallDate
            FROM Placement_History__c
            WHERE Placement__r.Name IN :includeAgencyList AND Placement_Recall_Date__c != NULL AND Placement_Recall_Date__c = LAST_MONTH
        ];

        for (AggregateResult arrResult : placeHistory) {
            minPlacementDate = (Date) arrResult.get('firstPlacementDate');
            maxRecallDate = (Date) arrResult.get('lastRecallDate');
        }
        for (Product__c prodData : scope) {
            mapProduct.put(prodData.ID, prodData);
        }
        
        //Get all complaint based on product
        AggregateResult[] prodGroupedResults = [select Product__c prodId, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                            WHERE Product__c IN :mapProduct.keySet() 
                                            AND Product__c != NULL
                                            //AND CreatedDate = LAST_MONTH 
                                            AND Requested_Date__c = LAST_MONTH     
                                            AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                            GROUP BY Product__c];
        if(prodGroupedResults != NULL && !prodGroupedResults.isEmpty()) { 
            for (AggregateResult ar : prodGroupedResults)  {
                //create map with product and complaint count
                mapProductCompCount.put((String)ar.get('prodId'),(decimal)ar.get('comptProductcnt'));
            }
        }
        
        //check active judgment present on product
        List<Account_Judgment__c> accountJudgment = [
            SELECT ID, Name, Product__c, Judgment__c, Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
            FROM Account_Judgment__c
            WHERE Product__c IN :mapProduct.keySet() AND Status__c = 'Active'
        ];

        for (Account_Judgment__c accountJudgmentData : accountJudgment) {
            if (
                accountJudgmentData.Judgment__r.Legal_Status__c == JUDGMENT ||
                accountJudgmentData.Judgment__r.Legal_Status__c == POST_JUDGMENT ||
                accountJudgmentData.Judgment__r.Legal_Status__c == PRE_JUDGMENT
            ) {
                mapProductJudgmentClaimIssuedID.put(accountJudgmentData.Product__c, accountJudgmentData.Judgment__c);
            }
        }
        //if product has active judgment then add TU_Judgment_Period__c years in Charged_Off_Date__c else add TU_Collection_Period__c years
        for (Product__c prodRecData : scope) {
            listOfProductIds.add(prodRecData.id);

            Date chargeOffDate;
            if (mapProductJudgmentClaimIssuedID.containsKey(prodRecData.id)) {
                Integer numberOfPeriods;
                if (
                    prodRecData.State__c != null &&
                    mapProvinceAcronymCBRepPeriods.containskey(prodRecData.State__c) &&
                    mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Judgment_Period__c != null
                ) {
                    numberOfPeriods = Integer.valueOf(mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Judgment_Period__c);
                }

                if (prodRecData.Charged_Off_Date__c != null) {
                    if (numberOfPeriods != null) {
                        chargeOffDate = prodRecData.Charged_Off_Date__c.addYears(numberOfPeriods);
                        if (chargeOffDate < Date.today()) {
                            mapProductExcluse.put(prodRecData.id, true);
                        }
                    }
                }
            } else {
                Integer numberOfPeriods;
                if (
                    prodRecData.State__c != null &&
                    mapProvinceAcronymCBRepPeriods.containskey(prodRecData.State__c) &&
                    mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Collection_Period__c != null
                ) {
                    numberOfPeriods = Integer.valueOf(mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Collection_Period__c);
                }

                if (prodRecData.Charged_Off_Date__c != null) {
                    if (numberOfPeriods != null) {
                        chargeOffDate = prodRecData.Charged_Off_Date__c.addYears(numberOfPeriods);
                        if (chargeOffDate < Date.today()) {
                            mapProductExcluse.put(prodRecData.id, true);
                        }
                    }
                }
            }
        }
        //Get sum of product payment amount of product
        Map<String, AggregateResult> productSumTotal = new Map<String, AggregateResult>();
        AggregateResult[] prodPayment = [
            SELECT CCS_Account__C ccsAcc, sum(Payment_Amount__c) grossPay, Min(Payment_Created__c) firstPaymentDate
            FROM Product_Payments__c
            WHERE
                CCS_Account__C IN :listOfProductIds
                AND RecordTYpe.DeveloperName = 'Distressed_Product_Payment'
                AND Payment_Created__c = LAST_MONTH
                AND (Payment_Type__c = :PAYTYPE_REGULAR
                OR Payment_Type__c = :PAYTYPE_PAID_IN_FULL
                OR Payment_Type__c = :PAYTYPE_SETTLED_IN_FULL)
                AND Is_Payment_Reversed__c = FALSE
            GROUP BY CCS_Account__C
        ];

        for (AggregateResult aggr : prodPayment) {
            productSumTotal.put((String) aggr.get('ccsAcc'), aggr);
        }
        //Get Last Day or previous month.
        Date LastMonth = date.today().addmonths(-1);
        Date FirstOfLastMonth = date.newInstance(Lastmonth.year(), lastmonth.month(), 1);
        Integer numberOfDays = Date.daysInMonth(FirstOfLastMonth.year(), FirstOfLastMonth.month());
        Date LastDayOfLastMonth = Date.newInstance(FirstOfLastMonth.year(), FirstOfLastMonth.month(), numberOfDays);

        List<Product_Payments__c> prodPaymentData = [
            SELECT CCS_Account__C, Payment_Amount__c, Payment_Created__c
            FROM Product_Payments__c
            WHERE
                CCS_Account__C IN :listOfProductIds
                AND RecordTYpe.DeveloperName = 'Distressed_Product_Payment'
                AND (Payment_Type__c = :PAYTYPE_REGULAR
                OR Payment_Type__c = :PAYTYPE_PAID_IN_FULL
                OR Payment_Type__c = :PAYTYPE_SETTLED_IN_FULL)
                AND Is_Payment_Reversed__c = FALSE
                AND Payment_Created__c >= :minPlacementDate
                AND Payment_Created__c <= :maxRecallDate
            ORDER BY Payment_Created__c DESC
        ];

        map<Id, Decimal> mapProductPaymentAmount = new Map<ID, Decimal>();
        Map<Id, List<Product_Payments__c>> mapProductPaymentsData = new Map<Id, List<Product_Payments__c>>();
        for (Product_Payments__c prodPay : prodPaymentData) {
            //if account got recalled and reallocated to same agecncy and again recalled from this agency
            //e.g allocated to agency 6 got recalled and reallocated to agency 6 and got recalled and currently in warehouse
            if (
                placementHistoryMap.containsKey(prodPay.CCS_Account__C) &&
                previouslyPlaced.containsKey(prodPay.CCS_Account__C) &&
                placementHistoryMap.get(prodPay.CCS_Account__C).Placement__c == previouslyPlaced.get(prodPay.CCS_Account__C).Placement__c
            ) {
                placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c = previouslyPlaced.get(prodPay.CCS_Account__C)
                    .Placement_Recall_Date__c;
            }
            //calculate Actual Payment Amount : sum of ONLY the payments that came in the reporting period up to (and including) the recall date
            if (
                prodPay.Payment_Created__c >= FirstOfLastMonth &&
                prodPay.Payment_Created__c <= LastDayOfLastMonth &&
                placementHistoryMap.containsKey(prodPay.CCS_Account__C) &&
                prodPay.Payment_Created__c != null &&
                placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c != null &&
                prodPay.Payment_Created__c <= placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c
            ) {
                if (mapProductPaymentAmount.containsKey(prodPay.CCS_Account__c)) {
                    Decimal payAmount = mapProductPaymentAmount.get(prodPay.CCS_Account__c);
                    if (payAmount != null && prodPay.Payment_Amount__c != null) {
                        mapProductPaymentAmount.put(prodPay.CCS_Account__c, payAmount + prodPay.Payment_Amount__c);
                    }
                } else {
                    if (prodPay.Payment_Amount__c != null) {
                        mapProductPaymentAmount.put(prodPay.CCS_Account__c, prodPay.Payment_Amount__c);
                    }
                }
            }

            if (
                prodPay.Payment_Created__c <= LastDayOfLastMonth &&
                placementHistoryMap.containsKey(prodPay.CCS_Account__C) &&
                prodPay.Payment_Created__c != null &&
                placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c != null &&
                prodPay.Payment_Created__c <= placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c &&
                !mapProductPaymentsData.containsKey(prodPay.CCS_Account__c)
            ) {
                mapProductPaymentsData.put(prodPay.CCS_Account__c, new List<Product_Payments__c>{ prodPay });
            }
        }

        //Fetch custom value records from Metro2_File__c custom setting
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        if (metro2TransUnion.MaxRowsCount__c <> null) {
            maxRowslength = metro2TransUnion.MaxRowsCount__c;
        }
        if (metro2TransUnion.Canaccede_Financial_Group__c <> null) {
            canaFinGrp = metro2TransUnion.Canaccede_Financial_Group__c;
        }
        if (metro2TransUnion.bureauIdentifier__c <> null) {
            TransUnionIdentifier = metro2TransUnion.bureauIdentifier__c;
        }
        if (metro2TransUnion.HEADER__c <> null) {
            headerCust = metro2TransUnion.HEADER__c;
        }
        if (metro2TransUnion.CA__c <> null) {
            CA = metro2TransUnion.CA__c;
        }
        if (metro2TransUnion.ZAP__c <> null) {
            ZAP = metro2TransUnion.ZAP__c;
        }
        if (metro2TransUnion.Identification_Number__c <> null) {
            identificationNumber = metro2TransUnion.Identification_Number__c;
        }
        if (metro2TransUnion.Account_Type__c <> null) {
            accountType = metro2TransUnion.Account_Type__c;
        }
        if (metro2TransUnion.Reporter_Address__c <> null) {
            reporterAddress = metro2TransUnion.Reporter_Address__c;
        }
        if (metro2TransUnion.Reporter_Phone__c <> null) {
            reporterPhone = metro2TransUnion.Reporter_Phone__c;
        }
        if (metro2TransUnion.Portfolio_Type__c <> null) {
            portfolioType = metro2TransUnion.Portfolio_Type__c;
        }
        if (metro2TransUnion.Terms_Duration__c <> null) {
            termsDuration = metro2TransUnion.Terms_Duration__c;
        }
        if (metro2TransUnion.Days_Diff_for_Delinquency__c <> null) {
            noOfDaysForDelinquency = Integer.valueOf(metro2TransUnion.Days_Diff_for_Delinquency__c);
        }

        // Code for Date of LastmodifiedDate  Right Padding upon dynamic values in less
        String lastModifiedBydate = defLastModifiedByDate;
        lastModifiedBydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY((System.today()).toStartofMonth().addDays(-1));

        // Code for Date of CreatedDate  Right Padding upon dynamic values in less
        String createdDate = defCreatedDate;
        createdDate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(System.today());

        String bureaIdentifier = defBureauIdentifier;
        if (TransUnionIdentifier != null) {
            if (TransUnionIdentifier.length() < STATIC_INTEGER_10) {
                bureaIdentifier = TransUnionIdentifier.rightPad(STATIC_INTEGER_10);
            } else if (TransUnionIdentifier.length() == STATIC_INTEGER_10) {
                bureaIdentifier = TransUnionIdentifier;
            } else if (TransUnionIdentifier.length() > STATIC_INTEGER_10) {
                bureaIdentifier = TransUnionIdentifier;
                bureaIdentifier = bureaIdentifier.substring(0, STATIC_INTEGER_10);
            }
        }

        String idenfificationNum = defIdentificationNumber;
        if (identificationNumber != null) {
            if (identificationNumber.length() < STATIC_INTEGER_20) {
                idenfificationNum = identificationNumber.rightPad(STATIC_INTEGER_20);
            } else if (identificationNumber.length() == STATIC_INTEGER_20) {
                idenfificationNum = identificationNumber;
            } else if (identificationNumber.length() > STATIC_INTEGER_20) {
                idenfificationNum = identificationNumber;
                idenfificationNum = idenfificationNum.substring(0, STATIC_INTEGER_20);
            }
        }
        String canaccedeFinGrp = defCanaFinGrp;
        if (canaFinGrp != null) {
            if (canaFinGrp.length() < STATIC_INTEGER_40) {
                canaccedeFinGrp = canaFinGrp.rightPad(STATIC_INTEGER_40);
            } else if (canaFinGrp.length() == STATIC_INTEGER_40) {
                canaccedeFinGrp = canaFinGrp;
            } else if (canaFinGrp.length() > STATIC_INTEGER_40) {
                canaccedeFinGrp = canaFinGrp;
                canaccedeFinGrp = canaccedeFinGrp.substring(0, STATIC_INTEGER_40);
            }
        }

        String repAddress = defReportAddress;
        if (reporterAddress != null) {
            if (reporterAddress.length() < STATIC_INTEGER_96) {
                repAddress = reporterAddress.rightPad(STATIC_INTEGER_96);
            } else if (reporterAddress.length() == STATIC_INTEGER_96) {
                repAddress = reporterAddress;
            } else if (reporterAddress.length() > STATIC_INTEGER_96) {
                repAddress = reporterAddress;
                repAddress = repAddress.substring(0, STATIC_INTEGER_96);
            }
        }

        String repPhone = defReportTelPhoneNum;
        if (reporterPhone != null) {
            if (reporterPhone.length() < STATIC_INTEGER_10) {
                repPhone = reporterPhone.rightPad(STATIC_INTEGER_10);
            } else if (reporterPhone.length() == STATIC_INTEGER_10) {
                repPhone = reporterPhone;
            } else if (reporterPhone.length() > STATIC_INTEGER_10) {
                repPhone = reporterAddress;
                repPhone = repPhone.substring(0, STATIC_INTEGER_10);
            }
        }

        // Code to generate Header record
        string headbody =
            maxRowslength +
            headerCust +
            extra27Spaces +
            bureaIdentifier +
            lastModifiedBydate +
            createdDate +
            extra16Spaces +
            canaccedeFinGrp +
            repAddress +
            repPhone;

        Integer countheader = 0;
        if (Integer.valueOf(maxRowslength) <> null) {
            countheader = Integer.valueOf(maxRowslength) - headbody.length();
        }

        Integer countheader2 = countheader + headbody.length();

        Metro__c metroheaderrecsetting = Metro__c.getInstance('Header');

        if (metroheaderrecsetting.HeaderCheck__c == false) {
            MetroFlatFileData__c metroobj24 = new MetroFlatFileData__c();
            metroobj24.RowData1__c = headbody /*  + String.fromCharArray(trimmedArray2) */;
            metroobj24.HeaderCheck__c = true;
            metroobj24.Bureau_Type__c = bureauTypeTransUnion;
            metroobj24.Product_Type__c = productType;
            metroobj24.Sort_Order__c = 1;
            metroobj24.Batch_Number__c = batchNumber;
            insert metroobj24;
            metroheaderrecsetting.HeaderCheck__c = true;
            try {
                update metroheaderrecsetting;
            } catch (Exception ex) {
                system.debug('exception' + ex);
            }
        }

        //Integer Stringcount = headbody.length();
        String headbodyfinal = headbody.length() + headbody;

        // List created to bulk insert the metro2 data.
        List<MetroFlatFileData__c> metroFileData = new List<MetroFlatFileData__c>();
        List<MetroFlatFileData__c> metroFileDataK1Seg = new List<MetroFlatFileData__c>();
        Boolean nameValidationCheck = false;

        for (Product__c prodct : scope) {
            nameValidationCheck = false;
            if (!mapProductExcluse.containsKey(prodct.id)) {
                MetroFlatFileData__c metroobj2 = new MetroFlatFileData__c();

                // Code for Adding Date Opened Right Padding upon dynamic values in less
                String Dateopened = defDateOpened;
                if (
                    (placementHistoryMap.containsKey(prodct.id) && placementHistoryMap.get(prodct.id).Placement_Date__c <> null) ||
                    previousAllocatedAgency.containsKey(prodct.id)
                ) {
                    Dateopened = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(placementHistoryMap.get(prodct.id).Placement_Date__c);
                    metroobj2.Open_Date__c = Dateopened;
                } else {
                    if (prodct.Assignment_Date__c != null) {
                        Dateopened = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Assignment_Date__c);
                        metroobj2.Open_Date__c = Dateopened;
                    }
                }

                // Code for Adding Accname Right Padding upon dynamic values in less
                String productname = defProductName;
                if (prodct.Name.length() < STATIC_INTEGER_30) {
                    productname = prodct.Name.rightPad(STATIC_INTEGER_30);
                    productname = productname.toUpperCase();
                } else if (prodct.Name.length() == STATIC_INTEGER_30) {
                    productname = prodct.Name;
                    productname = productname.toUpperCase();
                } else if (prodct.Name.length() > STATIC_INTEGER_30) {
                    productname = prodct.Name;
                    productname = productname.substring(0, STATIC_INTEGER_30);
                    productname = productname.toUpperCase();
                }

                // Code for Adding Purchase_Face_Value__c Left Padding upon dynamic values in less
                String orignalCreditAmt = defOrignalCreditAmt;
                if (prodct.Purchase_Face_Value__c != null) {
                    //Code to prevent negative values. if value is negative show 0's
                    if (prodct.Purchase_Face_Value__c >= 0) {
                        orignalCreditAmt = String.valueOf(prodct.Purchase_Face_Value__c);
                        orignalCreditAmt = orignalCreditAmt.subString(0, orignalCreditAmt.indexOf('.'));
                        orignalCreditAmt = orignalCreditAmt.leftPad(STATIC_INTEGER_9, '0');
                    } else if (prodct.Purchase_Face_Value__c < 0) {
                        orignalCreditAmt = defOrignalCreditAmt;
                    }
                }

                // Code for Adding Payment Frequency Right Padding upon dynamic values in less
                String paymentfrequency = defPaymentFrequency;
                //Set payment frquency default D(i.e Deferred)
                paymentfrequency = metro2TransUnion.Payment_Frequency__c;

                // Code for Adding Actual Payment Amount  Right Padding upon dynamic values in less
                String Finalactualpayplan = defFinalActualPayPlan;
                AggregateResult grossPaySum = productSumTotal.get(prodct.id);
                Decimal actualGrossPay = 0.00;
                if (mapProductPaymentAmount.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)) {
                    Finalactualpayplan = String.valueOf(mapProductPaymentAmount.get(prodct.id).setScale(0));
                    Finalactualpayplan = Finalactualpayplan.leftPad(STATIC_INTEGER_9, '0');
                } else if (placementHistoryMap.containsKey(prodct.id) && !mapProductPaymentAmount.containsKey(prodct.id)) {
                    Finalactualpayplan = defFinalActualPayPlan;
                } else {
                    if (null != grossPaySum) {
                        actualGrossPay = (Decimal) grossPaySum.get('grossPay');
                        //negative amount to be reported as zero
                        if (actualGrossPay != null && actualGrossPay > 0) {
                            Finalactualpayplan = String.valueOf(actualGrossPay.setScale(0));
                            Finalactualpayplan = Finalactualpayplan.leftPad(STATIC_INTEGER_9, '0');
                        } else if (actualGrossPay < 0) {
                            Finalactualpayplan = defFinalActualPayPlan;
                        }
                    }
                }

                Date firstPaymentDate = null;
                if (null != grossPaySum) {
                    firstPaymentDate = (Date) grossPaySum.get('firstPaymentDate');
                }

                //Code for populating Payment history profile for last 24 months
                String paymentHistoryProfile = defNumberOfPayments;

                // Code for date of last payment  Right Padding upon dynamic values in less
                String lastpaymentdate = defLastPaymentDate;
                if (mapProductPaymentsData.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)) {
                    lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(mapProductPaymentsData.get(prodct.id)[0].Payment_Created__c);
                } else {
                    if (prodct.Last_Payment_Date__c != null) {
                        if (!placementHistoryMap.containsKey(prodct.id)) {
                            lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
                        }
                        if (previousAllocatedAgency.containsKey(prodct.id)) {
                            lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
                        }
                        if (previouslyPlaced.containsKey(prodct.id)) {
                            if (
                                previouslyPlaced.get(prodct.id).Placement__r.name ==
                                string.valueOf(previouslyPlaced.get(prodct.id).Product__r.Collection_Agency__c)
                            ) {
                                lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
                            } else {
                                if (previouslyPlaced.get(prodct.id).Placement_Recall_Date__c > prodct.Last_Payment_Date__c) {
                                    boolean found = includeAgencyList.contains(previouslyPlaced.get(prodct.id).Placement__r.name);
                                    if(found){
                                        lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
                                    }else{
                                        lastpaymentdate = defLastPaymentDate;
                                    }
                                } else {
                                    lastpaymentdate = defLastPaymentDate;
                                }
                            }
                        }
                    }
                }

                //First Name or Last Name excluded from bureau reporting fetch from Metro2_File__c custom setting
                string nameExluded = metro2TransUnion.Name_Excluded_List__c;
                list<string> nameExcludeList = new List<string>();
                if (nameExluded != null) {
                    nameExcludeList = nameExluded.split(',');
                }

                // Code for Adding First_Name__c Right Padding upon dynamic values in less
                String firstname = defFirstName;
                if (prodct.First_Name__c != null) {
                    Boolean checkFirstNameValid = CustomerProcessingBatchHelper.getValidCustomerName(prodct.First_Name__c);
                    if (checkFirstNameValid == true) {
                        //if first name includes apostrophes
                        firstname = prodct.First_Name__c;
                        firstname = firstname.replaceAll('\'', '');

                        for (string checkFirstName : nameExcludeList) {
                            if (prodct.First_Name__c.toUpperCase().contains(checkFirstName)) {
                                firstname = defFirstName;
                                nameValidationCheck = true;
                            }
                        }
                        if (prodct.First_Name__c.toUpperCase() == INC || prodct.First_Name__c.toUpperCase().contains(spaceINC)) {
                            firstname = defFirstName;
                            nameValidationCheck = true;
                        } else {
                            if (prodct.First_Name__c.length() <= STATIC_INTEGER_20) {
                                firstname = firstname.rightPad(STATIC_INTEGER_20);
                                firstname = firstname.toUpperCase();
                            } else if (prodct.First_Name__c.length() > STATIC_INTEGER_20) {
                                firstname = firstname.left(STATIC_INTEGER_20);
                                firstname = firstname.toUpperCase();
                            }
                        }
                    } else {
                        nameValidationCheck = true;
                    }
                }

                // Code for Adding Last_Name__c Right Padding upon dynamic values in less
                String lastname = defLastName;
                if (prodct.Last_Name__c != null) {
                    Boolean checkLastNameValid = CustomerProcessingBatchHelper.getValidCustomerName(prodct.Last_Name__c);
                    if (checkLastNameValid == true) {
                        //if last name includes apostrophes
                        lastname = prodct.Last_Name__c;
                        lastname = lastname.replaceAll('\'', '');

                        for (string checkLastName : nameExcludeList) {
                            if (prodct.Last_Name__c.toUpperCase().contains(checkLastName)) {
                                lastname = defLastName;
                                nameValidationCheck = true;
                            }
                        }
                        if (prodct.Last_Name__c.toUpperCase() == INC || prodct.Last_Name__c.toUpperCase().contains(spaceINC)) {
                            lastname = defLastName;
                            nameValidationCheck = true;
                        } else {
                            if (prodct.Last_Name__c.length() <= STATIC_INTEGER_25) {
                                lastname = lastname.rightPad(STATIC_INTEGER_25);
                                lastname = lastname.toUpperCase();
                            } else if (prodct.Last_Name__c.length() > STATIC_INTEGER_25) {
                                lastname = lastname.left(STATIC_INTEGER_25);
                                lastname = lastname.toUpperCase();
                            }
                        }
                    } else {
                        nameValidationCheck = true;
                    }
                }

                // Code for Adding Middle_Name__c Right Padding upon dynamic values in less
                String middlename = defMiddleName;
                if (prodct.Middle_Name__c != null) {
                    //if last name includes apostrophes
                    middlename = prodct.Middle_Name__c;
                    middlename = middlename.replaceAll('\'', '');

                    if (prodct.Middle_Name__c.length() <= STATIC_INTEGER_20) {
                        middlename = middlename.rightPad(STATIC_INTEGER_20);
                        middlename = middlename.toUpperCase();
                    } else if (prodct.Middle_Name__c.length() > STATIC_INTEGER_20) {
                        middlename = middlename.left(STATIC_INTEGER_20);
                        middlename = middlename.toUpperCase();
                    }
                }
                // Code for Adding SIN__c Right Padding upon dynamic values in less
                String SinNumber = defSinNumber;
                if (prodct.SIN__c != null && !prodct.SIN__c.startsWith('0') && prodct.SIN__c.length() == STATIC_INTEGER_9) {
                    metroobj2.SIN__c = prodct.SIN__c;
                    SinNumber = prodct.SIN__c;
                }
                // Code for Date of Birth Amount  Right Padding upon dynamic values in less
                String Dateofbirth = defDateOfBirth;
                if (prodct.Date_of_Birth__c != null) {
                    Dateofbirth = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Date_of_Birth__c);
                    metroobj2.Dateofbirth__c = Dateofbirth;
                }
                // Code for Phone Number  Right Padding upon dynamic values in less
                String PhoneNumber = defphoneNumber;
                if (prodct.Phone_Home__c != null) {
                    Boolean checkPhoneValid = CustomerProcessingBatchHelper.getValidPhoneNumber(prodct.Phone_Home__c);
                    if (checkPhoneValid == true) {
                        String phonenumberNumeric = prodct.Phone_Home__c.replaceAll('[^0-9]', '');
                        if (String.valueOf(phonenumberNumeric).length() < STATIC_INTEGER_10) {
                            PhoneNumber = String.valueOf(phonenumberNumeric).rightPad(STATIC_INTEGER_10);
                            metroobj2.PhoneNumber__c = PhoneNumber;
                        } else if (String.valueOf(phonenumberNumeric).length() == STATIC_INTEGER_10) {
                            PhoneNumber = String.valueOf(phonenumberNumeric);
                            metroobj2.PhoneNumber__c = PhoneNumber;
                        }
                        metroobj2.PhoneNumberProduct__c = prodct.Phone_Home__c;
                    }
                }

                // Code for Address Line 1 Right Padding upon dynamic values in less
                String AddressLine = defAddressLine;
                if (prodct.Address_Line1__c != null) {
                    if (String.valueOf(prodct.Address_Line1__c).length() < STATIC_INTEGER_32) {
                        AddressLine = String.valueOf(prodct.Address_Line1__c).rightPad(STATIC_INTEGER_32);
                        AddressLine = AddressLine.toUpperCase();
                    } else if (String.valueOf(prodct.Address_Line1__c).length() == STATIC_INTEGER_32) {
                        AddressLine = String.valueOf(prodct.Address_Line1__c);
                        AddressLine = AddressLine.toUpperCase();
                    } else if (String.valueOf(prodct.Address_Line1__c).length() > STATIC_INTEGER_32) {
                        AddressLine = String.valueOf(prodct.Address_Line1__c);
                        AddressLine = AddressLine.substring(0, STATIC_INTEGER_32);
                    }
                }

                // Code for Address Line 2 Right Padding upon dynamic values in less
                String AddressLine2 = defAddressLine2;
                if (prodct.Address_Line2__c != null) {
                    if (String.valueOf(prodct.Address_Line2__c).length() < STATIC_INTEGER_32) {
                        AddressLine2 = String.valueOf(prodct.Address_Line2__c).rightPad(STATIC_INTEGER_32);
                        AddressLine2 = AddressLine2.toUpperCase();
                    } else if (String.valueOf(prodct.Address_Line2__c).length() == STATIC_INTEGER_32) {
                        AddressLine2 = String.valueOf(prodct.Address_Line2__c);
                        AddressLine2 = AddressLine2.toUpperCase();
                    } else if (String.valueOf(prodct.Address_Line2__c).length() > STATIC_INTEGER_32) {
                        AddressLine2 = String.valueOf(prodct.Address_Line2__c);
                        AddressLine2 = AddressLine2.substring(0, STATIC_INTEGER_32);
                    }
                }

                // Code for City Right Padding upon dynamic values in less
                String cityaddress = defCityAddress;
                if (prodct.City__c != null) {
                    if (String.valueOf(prodct.City__c).length() < STATIC_INTEGER_20) {
                        cityaddress = String.valueOf(prodct.City__c).rightPad(STATIC_INTEGER_20);
                        cityaddress = cityaddress.toUpperCase();
                    } else if (String.valueOf(prodct.City__c).length() == STATIC_INTEGER_20) {
                        cityaddress = String.valueOf(prodct.City__c);
                        cityaddress = cityaddress.toUpperCase();
                    } else if (String.valueOf(prodct.City__c).length() > STATIC_INTEGER_20) {
                        cityaddress = String.valueOf(prodct.City__c);
                        cityaddress = cityaddress.substring(0, STATIC_INTEGER_20);
                    }
                }

                // Code for state Right Padding upon dynamic values in less
                String stateaddress = defStateAddress;
                String provinceCode = prodct.State__c;
                if (provinceCode != null) {
                    if (provinceCode.length() < STATIC_INTEGER_2) {
                        stateaddress = provinceCode.rightPad(STATIC_INTEGER_2);
                    } else if (provinceCode.length() == STATIC_INTEGER_2) {
                        stateaddress = provinceCode;
                    } else if (provinceCode.length() > STATIC_INTEGER_2) {
                        stateaddress = provinceCode;
                        stateaddress = stateaddress.substring(0, STATIC_INTEGER_2);
                    }
                }

                String ZipAddres = defZipAddres;
                if (prodct.Zip_Code__c != null) {
                    //Code to remove space from Zipcode
                    String ZipAddresWithoutSpaces = prodct.Zip_Code__c.replaceAll('\\s+', '');

                    if (ZipAddresWithoutSpaces.length() < STATIC_INTEGER_9) {
                        ZipAddres = ZipAddresWithoutSpaces.rightPad(STATIC_INTEGER_9);
                    } else if (String.valueOf(prodct.Zip_Code__c).length() == STATIC_INTEGER_9) {
                        ZipAddres = ZipAddresWithoutSpaces;
                    } else if (String.valueOf(prodct.Zip_Code__c).length() > STATIC_INTEGER_9) {
                        ZipAddres = ZipAddresWithoutSpaces;
                        ZipAddres = ZipAddres.substring(0, STATIC_INTEGER_9);
                    }
                }
                // Set default Account status to 13
                String accountStatus = defAccountStatus;
                if (String.isNotBlank(prodct.Product_Status__c)) {
                    for (Data_Status_Mapping__c metaData : mapDataStatusMapping.values()) {
                        mapDataStatus.put(metaData.name, metaData);
                    }

                    if (prodct.Collection_Agency__c == 9999) {
                        //set default as DA
                        accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                        if (previouslyPlaced.containskey(prodct.id)) {
                            boolean found = includeAgencyList.contains(previouslyPlaced.get(prodct.id).Placement__r.name);
                            //if account recalled from PIF or SIF then set account as closed
                            if (
                                found &&
                                mapDataStatus.containskey(previouslyPlaced.get(prodct.id).Placement_Status__c) &&
                                mapDataStatus.get(previouslyPlaced.get(prodct.id).Placement_Status__c).Bureau_Reporting_Account_Status__c == 'Closed'
                            ) {
                                accountStatus = metro2TransUnion.Account_Status_Close__c; // set account status 62
                            } else {
                                //if account not recalled from PIF or SIF then set account as DA
                                accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                            }
                        }
                    } else {
                        accountStatus = metro2TransUnion.Account_Status_Open__c; // set account status 93
                        //if account placed with agency 68 or 6 and curretnly mapped with any other agency
                        if (placementHistoryMap.containskey(prodct.id) && !preAllocatedAgency.containskey(prodct.id)) {
                            accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                        }
                        //account allocated to 6 or 68 then got recalled and reallocated to 32 agency
                        //and again got recalled and then again reallocated to 6 or 68 agency
                        else if (preAllocatedAgency.containskey(prodct.id) && previouslyPlaced.containskey(prodct.id)) {
                            if (previouslyPlaced.get(prodct.id).Placement__c == preAllocatedAgency.get(prodct.id)) {
                                accountStatus = metro2TransUnion.Account_Status_Open__c; // set account status 93
                            } else {
                                accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                            }
                        }
                        //if account placed with agency 68 or 6 and got recalled and reallocated to same agency
                        else if (preAllocatedAgency.containskey(prodct.id) && !previousAllocatedAgency.containskey(prodct.id)) {
                            accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                        }
                        //if account placed with agency 68 or 6 and got recalled and again reallocated to same agency i.e 68 or 6
                        else if (preAllocatedAgency.containskey(prodct.id) && previousAllocatedAgency.containskey(prodct.id)) {
                            accountStatus = metro2TransUnion.Account_Status_Open__c; // set account status 93
                        }
                        //based on product status set account status
                        else if (
                            mapDataStatus.containskey(prodct.Product_Status__c) &&
                            mapDataStatus.get(prodct.Product_Status__c).Bureau_Reporting_Account_Status__c == 'Open'
                        ) {
                            accountStatus = metro2TransUnion.Account_Status_Open__c; // set account status 93
                        }
                    }
                } else {
                    if (prodct.Collection_Agency__c == 9999) {
                        accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                    } else {
                        accountStatus = metro2TransUnion.Account_Status_Open__c; //set account status to 93
                    }
                }
                if(mapProductCompCount.containskey(prodct.id)){
                    //if product has complaint present in reporting month then reported account as DA
                    accountStatus = metro2TransUnion.Account_Status_Recalled__c; // set account status DA
                }
                metroobj2.Status__c = accountStatus;

                // Code for date closed Right Padding upon dynamic values in less
                String dateclosed = defDateClosed;
                if (prodct.Closed_Date__C != null && accountStatus == metro2TransUnion.Account_Status_Close__c) {
                    dateclosed = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(
                        date.newinstance(prodct.Closed_Date__C.year(), prodct.Closed_Date__C.month(), prodct.Closed_Date__C.day())
                    );
                }

                // Code for Adding current Amount  Right Padding upon dynamic values in less
                String currentplanval = defCurrentPlanVal;
                if (placementHistoryMap.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)) {
                    if (accountStatus != metro2TransUnion.Account_Status_Close__c) {
                        //Code to prevent negative values. if value is negative show 0's
                        if (placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c >= 0) {
                            currentplanval = String.valueOf(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c);
                            currentplanval = currentplanval.subString(0, currentplanval.indexOf('.'));
                            currentplanval = currentplanval.leftPad(STATIC_INTEGER_9, '0');
                        } else if (placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c < 0) {
                            currentplanval = defCurrentPlanVal;
                        }
                    } else {
                        currentplanval = defCurrentPlanVal;
                    }
                } else {
                    if (prodct.Current_Balance__c != null) {
                        if (accountStatus != metro2TransUnion.Account_Status_Close__c) {
                            //Code to prevent negative values. if value is negative show 0's
                            if (prodct.Current_Balance__c >= 0) {
                                currentplanval = String.valueOf(prodct.Current_Balance__c);
                                currentplanval = currentplanval.subString(0, currentplanval.indexOf('.'));
                                currentplanval = currentplanval.leftPad(STATIC_INTEGER_9, '0');
                            } else if (prodct.Current_Balance__c < 0) {
                                currentplanval = defCurrentPlanVal;
                            }
                        } else {
                            currentplanval = defCurrentPlanVal;
                        }
                    }
                }

                // Code for Adding past Amount  Right Padding upon dynamic values in less
                String pastval = defPastVal;
                if (placementHistoryMap.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)) {
                    if (accountStatus != metro2TransUnion.Account_Status_Close__c) {
                        //Code to prevent negative values. if value is negative show 0's
                        if (placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c >= 0) {
                            pastval = String.valueOf(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c);
                            pastval = pastval.subString(0, pastval.indexOf('.'));
                            pastval = pastval.leftPad(STATIC_INTEGER_9, '0');
                        } else if (placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c < 0) {
                            pastval = defPastVal;
                        }
                    } else {
                        pastval = defPastVal;
                    }
                } else {
                    if (prodct.Current_Balance__c != null) {
                        if (accountStatus != metro2TransUnion.Account_Status_Close__c) {
                            //Code to prevent negative values. if value is negative show 0's
                            if (prodct.Current_Balance__c >= 0) {
                                pastval = String.valueOf(prodct.Current_Balance__c);
                                pastval = pastval.subString(0, pastval.indexOf('.'));
                                pastval = pastval.leftPad(STATIC_INTEGER_9, '0');
                            } else if (prodct.Current_Balance__c < 0) {
                                pastval = defPastVal;
                            }
                        } else {
                            pastval = defPastVal;
                        }
                    }
                }
                //code for populating Date of Account Information
                String acctInformationDate = defDateOfAccountInformationDate;
                if (placementHistoryMap.containsKey(prodct.id) && placementHistoryMap.get(prodct.id).Placement_Recall_Date__c != null) {
                    acctInformationDate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(placementHistoryMap.get(prodct.id).Placement_Recall_Date__c);
                }

                //Code for populating Payment rating
                String paymentRating = defPaymentRating;

                // Code for Last_Delinquency_Date__c Amount  Right Padding upon dynamic values in less
                String lastdelinquencydate = defLastDelinquencyDate;
                //Use Charged_Off_Date__c for Date of First Delinquency
                if (prodct.Charged_Off_Date__c != null) {
                    Date delinquencyDateCalculated = prodct.Charged_Off_Date__c.addDays(-noOfDaysForDelinquency);
                    lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(delinquencyDateCalculated);
                }

                //set special comments value for records Product_Status__c
                String specialComments = defSpecialComments;

                // Code for Charged_Off_Amount__c  Amount  Right Padding upon dynamic values in less
                String chargeffamount = defChargeOffAmount;
                if (null != prodct.Charged_Off_Amount__c) {
                    chargeffamount = String.valueOf((prodct.Charged_Off_Amount__c));
                    chargeffamount = chargeffamount.subString(0, chargeffamount.indexOf('.'));
                    chargeffamount = chargeffamount.leftPad(STATIC_INTEGER_9, '0');
                }

                // Set Customer Information Indicator to blank for all Distressed account
                String customerInformationIndicator = '';
                customerInformationIndicator = customerInformationIndicator.leftPad(STATIC_INTEGER_2);

                // Code for Deceased Date
                String deceasedDate = ' ';
                if (prodct.Deceased_Date__c != null) {
                    deceasedDate = 'X';
                } else {
                    deceasedDate = '1';
                }

                //K1 Segment
                String k1SegmentLine = k1Segment;
                if (prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c != null) {
                    if (String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c).length() < STATIC_INTEGER_30) {
                        string sellerName = String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c);
                        k1SegmentLine = sellerName.rightPad(STATIC_INTEGER_30);
                        k1SegmentLine = k1SegmentLine.toUpperCase();
                    } else if (String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c).length() == STATIC_INTEGER_30) {
                        k1SegmentLine = String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c);
                        k1SegmentLine = k1SegmentLine.toUpperCase();
                    } else if (String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c).length() > STATIC_INTEGER_30) {
                        k1SegmentLine = String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c);
                        k1SegmentLine = k1SegmentLine.substring(0, STATIC_INTEGER_30);
                    }
                } else {
                    k1SegmentLine = k1Segment;
                }

                //Body record
                string headbody2 =
                    maxRowslength +
                    '1' +
                    extra14Spaces +
                    '0' +
                    idenfificationNum +
                    extra2Spaces +
                    productname +
                    portfolioType +
                    accountType +
                    Dateopened +
                    '000000000' +
                    orignalCreditAmt +
                    termsDuration +
                    paymentfrequency +
                    extra9Spaces +
                    Finalactualpayplan +
                    accountStatus +
                    paymentRating +
                    paymentHistoryProfile +
                    specialComments +
                    extra2Spaces +
                    currentplanval +
                    pastval +
                    chargeffamount +
                    acctInformationDate +
                    lastdelinquencydate +
                    dateclosed +
                    lastpaymentdate +
                    currencyTypeCode +
                    extra1Spaces +
                    lastname +
                    firstname +
                    middlename +
                    extra1Spaces +
                    SInnumber +
                    Dateofbirth +
                    PhoneNumber +
                    deceasedDate +
                    customerInformationIndicator +
                    CA +
                    AddressLine +
                    AddressLine2 +
                    cityaddress +
                    stateaddress +
                    ZipAddres +
                    extra2Spaces +
                    'K1' +
                    k1SegmentLine;

                Integer Stringcount2 = Integer.valueOf(maxRowslength) - headbody2.length();
                Integer Stringcountheadercount = Stringcount2 + headbody2.length();

                finalheadbody2 = finalheadbody2 + headbody2.rightPad(Stringcountheadercount) + '\r\n';

                metroobj2.RowData1__c = headbody2;
                metroobj2.ProductId__c = prodct.Id;
                metroobj2.Product__c = prodct.id;
                metroobj2.Bureau_Type__c = bureauTypeTransUnion;
                metroobj2.Product_Type__c = productType;
                metroobj2.Sort_Order__c = 2;
                metroobj2.Batch_Number__c = batchNumber;

                if (nameValidationCheck == false) {
                    metroFileData.add(metroobj2);
                }

                //increment counter if records to be considered as out of CCS
                if (accountStatus == metro2TransUnion.Account_Status_Close__c) {
                    if (null == prodct.TransUnion_Reported_As_Complete_Count__c) {
                        prodct.TransUnion_Reported_As_Complete_Count__c = 1;
                    } 
                    listOfProductsToUpdate.add(prodct);
                }
                //if product has complaint then reported that account only once.
                if(mapProductCompCount.containskey(prodct.id)){
                    prodct.TransUnion_Reported_As_Complete_Count__c = 1;
                    listOfProductsToUpdate.add(prodct);
                }
            } // if condition
        } // for loop

        insert metroFileData;

        if (metro2TransUnion.Do_Not_Increase_Count__c == false) {
            ProductTriggerHandler.runProductTrigger = false;
            try {
                update listOfProductsToUpdate;
            } catch (Exception ex) {
                system.debug('exception' + ex);
            }
            ProductTriggerHandler.runProductTrigger = true;
        }
    }

    // Finish Method to generate TAILER record
    public void finish(Database.BatchableContext BC) {
        String finalSINCount = blankString.leftPad(9, '0');
        String finalDOBCount = blankString.leftPad(9, '0');
        String finalPhoneCountNet = blankString.leftPad(9, '0');
        String finalStatus13Count = blankString.leftPad(9, '0');
        String finalStatus93Count = blankString.leftPad(9, '0');
        String finalStatus97Count = blankString.leftPad(9, '0');
        String finalStatusDACount = blankString.leftPad(9, '0');
        String finalStatus62Count = blankString.leftPad(9, '0');
        String extra18Spaces = blankString.leftPad(18);
        String extra4Spaces = blankString.leftPad(4);
        String extra27Zeros = blankString.leftPad(27, '0');
        String extra18Zeros = blankString.leftPad(18, '0');
        String extra9Zeros = blankString.leftPad(9, '0');
        String extra99Zeros = blankString.leftPad(99, '0');
        String extra7Zeros = blankString.leftPad(7, '0');
        String extra8Zeros = blankString.leftPad(8, '0');

        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        String maxRowsLength = metro2TransUnion.MaxRowsCount__c;

        AggregateResult[] metrolstCountData = [
            SELECT count(id) metroFlatFileDatacnt
            FROM MetroFlatFileData__c
            WHERE
                HeaderCheck__c = FALSE
                AND FooterCheck__c = FALSE
                AND Bureau_Type__c = :bureauTypeTransUnion
                AND Product_Type__c = :productType
                AND createddate = TODAY
                AND Batch_Number__c = :batchNumber
        ];
        Integer RowsCount = 0;

        for (AggregateResult aggr : metrolstCountData) {
            RowsCount = (Integer) aggr.get('metroFlatFileDatacnt');
        }

        Integer RowsCountLength = String.valueOf(RowsCount).length();

        //Phone Count
        Integer FinalPhoneCount = [
                SELECT PhoneNumber__c
                FROM MetroFlatFileData__c
                WHERE
                    PhoneNumber__c != NULL
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
                LIMIT 49000
            ]
            .size();
        finalPhoneCountNet = CustomerProcessingBatchHelper.getStringWithZeroPadding(FinalPhoneCount);

        //SIN Count
        Integer SINCOUNT = [
                SELECT SIN__c
                FROM MetroFlatFileData__c
                WHERE
                    SIN__c != NULL
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
            ]
            .size();
        finalSINCount = CustomerProcessingBatchHelper.getStringWithZeroPadding(SINCOUNT);

        //DOB Count
        Integer DOBCOUNT = [
                SELECT Dateofbirth__c
                FROM MetroFlatFileData__c
                WHERE
                    Dateofbirth__c != NULL
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
                LIMIT 49000
            ]
            .size();
        finalDOBCount = CustomerProcessingBatchHelper.getStringWithZeroPadding(DOBCOUNT);

        //Status 93 Count
        Integer STATUS93COUNT = [
                SELECT Status__c
                FROM MetroFlatFileData__c
                WHERE
                    Status__c != NULL
                    AND Status__c = '93'
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
                LIMIT 49000
            ]
            .size();
        finalStatus93Count = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS93COUNT);

        //Status 97 Count
        Integer STATUS97COUNT = [
                SELECT Status__c
                FROM MetroFlatFileData__c
                WHERE
                    Status__c != NULL
                    AND Status__c = '97'
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
                LIMIT 49000
            ]
            .size();
        finalStatus97Count = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS97COUNT);

        //Status DA Count
        Integer STATUSDACOUNT = [
                SELECT Status__c
                FROM MetroFlatFileData__c
                WHERE
                    Status__c != NULL
                    AND Status__c = 'DA'
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
                LIMIT 49000
            ]
            .size();
        finalStatusDACount = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUSDACOUNT);

        //Status 62 Count
        Integer STATUS62COUNT = [
                SELECT Status__c
                FROM MetroFlatFileData__c
                WHERE
                    Status__c != NULL
                    AND Status__c = '62'
                    AND Bureau_Type__c = :bureauTypeTransUnion
                    AND Product_Type__c = :productType
                    AND createddate = TODAY
                    AND Batch_Number__c = :batchNumber
                LIMIT 49000
            ]
            .size();
        finalStatus62Count = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS62COUNT);

        String rowsCountWithZero;
        if (RowsCountLength < STATIC_INTEGER_9) {
            rowsCountWithZero = String.valueOf(RowsCount).leftPad(STATIC_INTEGER_9, '0');
        } else if (RowsCountLength > STATIC_INTEGER_9) {
            rowsCountWithZero = extra7Zeros + String.valueOf(RowsCount);
        } else if (RowsCountLength == STATIC_INTEGER_9) {
            rowsCountWithZero = extra8Zeros + String.valueOf(RowsCount);
        }

        String TrailerRec =
            maxRowsLength +
            'TRAILER' +
            rowsCountWithZero +
            extra18Spaces +
            extra27Zeros +
            finalStatusDACount +
            extra18Zeros +
            finalStatus13Count +
            extra9Zeros +
            finalStatus62Count +
            extra99Zeros +
            finalStatus93Count +
            extra27Zeros +
            finalStatus97Count +
            extra18Zeros +
            rowscountwithzero +
            extra27Zeros +
            extra9Zeros +
            finalSINCount +
            finalSINCount +
            extra18Zeros +
            finalDOBCount +
            finalDOBCount +
            extra18Zeros +
            finalPhoneCountNet +
            extra4Spaces;

        MetroFlatFileData__c metroObj4 = new MetroFlatFileData__c();
        metroObj4.RowData1__c = TrailerRec;
        metroObj4.FooterCheck__c = true;
        metroObj4.Bureau_Type__c = bureauTypeTransUnion;
        metroObj4.Product_Type__c = productType;
        metroObj4.Sort_Order__c = 3;
        metroObj4.Batch_Number__c = batchNumber;
        insert metroObj4;

        Metro__c metroHeaderRec = Metro__c.getInstance('Header');
        metroHeaderRec.HeaderCheck__c = false;
        try {
            update metroHeaderRec;
        } catch (Exception ex) {
            system.debug('exception' + ex);
        }
        // Create and upload csv of the file
        String contentVersionId = CreditBureauRepTUTextFileGeneration.getContentVersion(batchNumber, bureauTypeTransUnion, productType);
        if (String.isNotBlank(contentVersionId)) {
            System.enqueueJob(new CreditBureauRepTUTextFileGeneration(contentVersionId));
        }
    }
}