/***************************************************
* Author         : A5E Consultancy
* Created On     : 10 July 2023
* Description    : Generate Metro File Data from Product__c records for Bureau TransUnion
*
***************************************************/

public class CreditBureauReportingTUBatch implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts{
    
    public static string blankString = '';
    public static final string defLastModifiedBydate = blankString.leftPad(8,'0');
    public static final string defCreateddate = blankString.leftPad(8,'0');
    public static final String defDateOpened = blankString.leftPad(8);
    public static final String defProductName = blankString.leftPad(30);
    public static final String defOrignalCreditAmt = blankString.leftPad(9,'0');
    public static final String defPaymentFrequency = blankString.leftPad(1);
    public static final String defMonthPayPlan = blankString.leftPad(9,'0');
    public static final String defFinalactualpayplan = blankString.leftPad(9,'0');
    public static final String defCurrentPlanval = blankString.leftPad(9,'0');
    public static final String defPastVal = blankString.leftPad(9,'0');
    public static final String defChargeOffAmount = blankString.leftPad(9,'0');
    public static final String defLastDelinquencyDate = blankString.leftPad(8,'0');
    public static final String defDateClosed = blankString.leftPad(8,'0');
    public static final String defLastPaymentDate  = blankString.leftPad(8,'0');
    public static final String defFirstName = blankString.leftPad(20);
    public static final String defLastName = blankString.leftPad(20);
    public static final String defMiddleName  = blankString.leftPad(20);
    public static final String defSinNumber = blankString.leftPad(9,'0');
    public static final String defDateOfbirth = blankString.leftPad(8,'0');
    public static final String defPhoneNumber = blankString.leftPad(10,'0');
    public static final String defNumberOfPayments = 'B'.leftPad(24);
    public static final String defAddressLine = blankString.leftPad(32);
    public static final String defAddressLine2 = blankString.leftPad(32);
    public static final String defCityAddress = blankString.leftPad(20);
    public static final String defStateAddress = blankString.leftPad(2);
    public static final String defZipAddres= blankString.leftPad(9);
    public static final String defAccountStatus = blankString.leftPad(2);
    public static final String defPaymentRating = blankString.leftPad(1);
    public static final String defSpecialComments = blankString.leftPad(2);
    public static final String defCustomerInformationIndicator = blankString.leftPad(2);
    public static final String bureauTypeTransUnion = 'TransUnion';
    public static final String productType = 'Distressed Account';
    public static final String K1Segment = blankString.leftPad(30);
    public static map<ID, ID> mapProductJudgmentClaimIssuedID;
    public static final String defReportAddress = blankString.leftPad(96);
    public static final String defReportTelPhoneNum = blankString.leftPad(10);
    public static final String defCanaFinGrp = blankString.leftPad(40);
    public static final String defIdentificationNumber = blankString.leftPad(20);
    public static final String defBureauIdentifier = blankString.leftPad(10);
    public static map<String, Data_Status_Mapping__c> mapDataStatusMapping = Data_Status_Mapping__c.getAll();
    public static map<String, Data_Status_Mapping__c> mapDataStatus = new map<String, Data_Status_Mapping__c>();
    public static final String INC = 'INC';
    public static final String spaceINC = ' INC';
    public string batchNumber = string.valueOf(DateTime.now());
    public static final String canaccede = 'CANACCEDE';
    public Set<ID> productIds = new Set<ID>();
    public Map<ID,Placement_History__c> placementHistoryMap = new Map<ID,Placement_History__c>();
    public static final String defDateOfAccountInformationDate = '00000000';
    public list<String> includeAgencyList = new list<String>();
    public Map<ID,ID> previousAllocatedAgency = new Map<ID,ID>();
    public Map<ID,ID> previousRecalledAgency = new Map<ID,ID>();
    public Map<ID,ID> preAllocatedAgency = new Map<ID,ID>();
    static String JUDGMENT = 'Judgment';
    static String POST_JUDGMENT = 'Post-Judgment';
    static String PRE_JUDGMENT = 'Pre-Judgment';
    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';
    
    public CreditBureauReportingTUBatch(){
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        //Only ICT and LRT agencies inclued in bureau reporting
        string agencyList = '';
        if(metro2TransUnion.Agency_Included__c <> NULL){
            agencyList = metro2TransUnion.Agency_Included__c;
        }
       
        List<String> splitDoubleValues = agencyList.split(',');
        Decimal strToDec = 0;
        for(String s : splitDoubleValues){
            includeAgencyList.add(s);   
        }
		Integer noOfDaysAfterReport = Integer.valueOf(metro2TransUnion.Number_of_Days_After_Reporting__c);
        Date placementDateBefore45;
        if(noOfDaysAfterReport != 0){
            placementDateBefore45 = System.today().addDays(-noOfDaysAfterReport);
        }
        
        
        List<Placement_History__c> placementHistory = [SELECT ID, Agency_Id__c, Product__c,Placement_Date__c,Placement_Recall_Date__c,
                                                       Current_Total_Bal_at_time_of_Recall__c,Placement__c
                                                         FROM Placement_History__c
                                                         WHERE Placement__r.Name IN :includeAgencyList 
                                                       	 AND Placement_Date__c <: placementDateBefore45
                                                         AND Placement_Recall_Date__c <> NULL
                                                      	 AND Placement_Recall_Date__c = LAST_MONTH];
        for(Placement_History__c placeHistory : placementHistory){
            productIds.add(placeHistory.Product__c);
            placementHistoryMap.put(placeHistory.Product__c,placeHistory);
            previousRecalledAgency.put(placeHistory.Product__c,placeHistory.Placement__c);
        }
        
        List<Placement_History__c> allocatedPlacementHistory = [SELECT ID, Agency_Id__c, Product__c,Placement_Date__c,Placement_Recall_Date__c,
                                                       Current_Total_Bal_at_time_of_Recall__c,Placement__c
                                                         FROM Placement_History__c
                                                         WHERE Placement__r.Name IN :includeAgencyList 
                                                       	 AND Product__c IN :productIds
                                                         AND Placement_Recall_Date__c = NULL
                                                         AND Placement_Date__c <> NULL
                                                      	 AND Placement_Date__c = LAST_MONTH];
        
        for(Placement_History__c allocatedPlaceHistory : allocatedPlacementHistory){
            preAllocatedAgency.put(allocatedPlaceHistory.Product__c,allocatedPlaceHistory.Placement__c);

            if(previousRecalledAgency.get(allocatedPlaceHistory.Product__c) == preAllocatedAgency.get(allocatedPlaceHistory.Product__c)){
                productIds.add(allocatedPlaceHistory.Product__c);
                previousAllocatedAgency.put(allocatedPlaceHistory.Product__c,allocatedPlaceHistory.Placement__c);
                //placementHistoryMap.remove(allocatedPlaceHistory.Product__c);
            }
        }
    }  
    
    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        list<string> excludeProdStatusList = new list<string>();
        string prodStatus = metro2TransUnion.Product_Status_Excluded__c;
        //product status excluded from bureau reporting fetch from Metro2_File__c custom setting
        if(prodStatus != Null){
            excludeProdStatusList = prodStatus.split(',');   
        }
		list<Decimal> includeAgencyList = new list<Decimal>();
        //Only ICT and LRT agencies inclued in bureau reporting
        string agencyList = '';
        if(metro2TransUnion.Agency_Included__c <> NULL){
            agencyList = metro2TransUnion.Agency_Included__c;
        }
        List<String> splitDoubleValues;
        if(agencyList <> NULL){
            splitDoubleValues = agencyList.split(',');
        }
        
        Decimal strToDec = 0;
        for(String s : splitDoubleValues){
            strToDec = decimal.valueOf(s);
            includeAgencyList.add(strToDec);   
        }

        Integer noOfTimesToReport = Integer.valueOf(metro2TransUnion.Number_of_Times_To_Report__c);
        Integer noOfDaysAfterReport = Integer.valueOf(metro2TransUnion.Number_of_Days_After_Reporting__c);
        Date dayBefore45;
        if(noOfDaysAfterReport != 0){
            dayBefore45 = System.today().addDays(-noOfDaysAfterReport);
        }
        
        //Query to fetch all the eligible records with the recordtype as CCS Account
        return Database.getQueryLocator('SELECT Id, Name,RecordType.Name,Collection_Agency__c,Assignment_Date__c,Last_Payment_Amount__c,Portfolio_Name_Lookup__r.CIML_Reporting_Name__c,Purchase_Face_Value__c, Closed_Date__C, Product_Status__c,Createddate,LastModifieddate,Original_Balance__c,Current_Balance__c,Last_Payment_Date__c,Last_Name__c,First_Name__c,Middle_Name__c,SIN__c,Phone_Home__c,Date_of_Birth__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Zip_Code__c,Deceased_Date__c, Charged_Off_Amount__c, TransUnion_Reported_As_Complete_Count__c,Seller__r.name,Charged_Off_Date__c FROM Product__c '+
                                        'WHERE '+ 
                                        '((RecordType.Name =: productType AND '+ 
										'Product_Status__c NOT IN :excludeProdStatusList AND '+
										'Collection_Agency__c IN :includeAgencyList AND '+ 
										'(Number_Of_Open_Complaint__c = 0 OR Number_Of_Open_Complaint__c = NULL) AND '+ 
										'Last_Name__c != null AND '+
                                        'First_Name__c != null AND '+
                                        'Name !=null AND '+ 
                                        'Current_Balance__c != null AND '+ 
										'Assignment_Date__c <: dayBefore45 AND '+
                                        '(NOT First_Name__c LIKE \'_\') AND ' + 
                                        '(NOT Last_Name__c LIKE \'_\') AND ' +
                                        'Charged_Off_Date__c <> null AND ' +
                                        'Difference_Greater_Than_N_Years__c = False AND ' +
                                        'Exclude_for_Reporting__c = False AND ' +
                                        'Portfolio_Name_Lookup__c <> null AND ' +
                                        '(TransUnion_Reported_As_Complete_Count__c = null OR ' +  
                                        'TransUnion_Reported_As_Complete_Count__c <: noOfTimesToReport)) OR (Id IN :productIds AND (TransUnion_Reported_As_Complete_Count__c = null OR TransUnion_Reported_As_Complete_Count__c <: noOfTimesToReport)))' );
                                       	
        
    }
    
    //Execute Method
    public void execute(Database.BatchableContext BC, List<Product__c> scope) {
		system.debug('inside execute method');
        List<Product__c> listOfProductsToUpdate = new List<Product__c>();
        map<Id, Product__c> mapProduct = new map<Id, Product__c>();
        mapProductJudgmentClaimIssuedID = new map<ID, ID>();
        map<id,boolean> mapProductExcluse = new map<id,boolean>();
        map<String, Credit_Bureau_Reporting_Periods__mdt> mapCreditBureauRepPeriods = Credit_Bureau_Reporting_Periods__mdt.getAll();
        map<String, Credit_Bureau_Reporting_Periods__mdt> mapProvinceAcronymCBRepPeriods = new map<String, Credit_Bureau_Reporting_Periods__mdt>();
        List<ID> listOfProductIds = new List<ID>();
        Date minPlacementDate = null;
        Date maxRecallDate = null;
        String finalHeadBody2 = ''; 
        String finalK1HeadBody2 = ''; 
        String maxRowslength = '';
        String canaFinGrp = '';
        String TransUnionIdentifier '';
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
        String extra16Spaces =  blankString.leftPad(16);

        for(Credit_Bureau_Reporting_Periods__mdt metaData : mapCreditBureauRepPeriods.values()){
            mapProvinceAcronymCBRepPeriods.put(metaData.Province_Name__c,metaData);
        }

        AggregateResult[] placeHistory = [SELECT product__c ccsAcc, Min(Placement_Date__c) firstPlacementDate,  Max(Placement_Recall_Date__c) lastRecallDate
                                    FROM Placement_History__c 
                                    WHERE 
                                    Placement__r.Name IN :includeAgencyList 
                                    AND Placement_Recall_Date__c <> NULL
                                    AND Placement_Recall_Date__c = LAST_MONTH
                                         GROUP BY product__c];
        
        for(AggregateResult arrResult : placeHistory){
            minPlacementDate = (Date)arrResult.get('firstPlacementDate');
            maxRecallDate = (Date)arrResult.get('lastRecallDate');
        }
        for(Product__c prodData: scope){
            mapProduct.put(prodRecData.ID, prodRecData);
        }
        //check active judgment present on product
		List<Account_Judgment__c> accountJudgment = [SELECT ID, Name, Product__c, Judgment__c,
                                                   Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
                                                   FROM Account_Judgment__c
                                                   WHERE Product__c IN :mapProduct.keySet() AND Status__c= 'Active'];
        
        for(Account_Judgment__c accountJudgmentData : accountJudgment){
            if(accountJudgmentData.Judgment__r.Legal_Status__c == JUDGMENT 
            || accountJudgmentData.Judgment__r.Legal_Status__c == POST_JUDGMENT || accountJudgmentData.Judgment__r.Legal_Status__c == PRE_JUDGMENT){ 
                mapProductJudgmentClaimIssuedID.put(accountJudgmentData.Product__c, accountJudgmentData.Judgment__c);
            }
        }
		//if product has active judgment then add TU_Judgment_Period__c years in Charged_Off_Date__c else add TU_Collection_Period__c years
        for(Product__c prodRecData: scope){
            listOfProductIds.add(prodRecData.id);
            
            Date chargeOffDate;
            if(mapProductJudgmentClaimIssuedID.containsKey(prodRecData.id)){
                Integer numberOfPeriods;
                if(prodRecData.State__c != NULL && mapProvinceAcronymCBRepPeriods.containskey(prodRecData.State__c) 
                   && mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Judgment_Period__c != NULL){
                     numberOfPeriods = Integer.valueOf(mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Judgment_Period__c);  
                }
                
                if(prodRecData.Charged_Off_Date__c != NULL){
                    if(numberOfPeriods != NULL){
                        chargeOffDate = prodRecData.Charged_Off_Date__c.addYears(numberOfPeriods);
                        if(chargeOffDate < Date.today()){
                            mapProductExcluse.put(prodRecData.id,true);
                        }
                    }
                }
            }
            else{
                Integer numberOfPeriods;
                if(prodRecData.State__c != NULL && mapProvinceAcronymCBRepPeriods.containskey(prodRecData.State__c) 
                   && mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Collection_Period__c != NULL){
                       numberOfPeriods = Integer.valueOf(mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Collection_Period__c); 
                   }
                
                if(prodRecData.Charged_Off_Date__c != NULL){
                    if(numberOfPeriods != NULL){
                        chargeOffDate = prodRecData.Charged_Off_Date__c.addYears(numberOfPeriods);
                        if(chargeOffDate < Date.today()){
                            mapProductExcluse.put(prodRecData.id,true);
                        } 
                    }  
                }
            }
        }
  		//Get sum of product payment amount of product
        Map<String, AggregateResult> productSumTotal = new Map<String, AggregateResult>();
        AggregateResult[] prodPayment = [SELECT CCS_Account__C ccsAcc, sum(Payment_Amount__c) grossPay, Min(Payment_Created__c) firstPaymentDate
                                    FROM Product_Payments__c 
                                    WHERE 
                                    CCS_Account__C IN :listOfProductIds
                                    AND (RecordTYpe.DeveloperName = 'Distressed_Product_Payment') 
                                    AND Payment_Created__c = LAST_MONTH
                                    AND (Payment_Type__c=: PAYTYPE_REGULAR OR Payment_Type__c =: PAYTYPE_PAID_IN_FULL OR Payment_Type__c=: PAYTYPE_SETTLED_IN_FULL) 
                                    AND Is_Payment_Reversed__c = False 
                                    GROUP BY CCS_Account__C];
        
        for(AggregateResult aggr : prodPayment){
            productSumTotal.put((String)aggr.get('ccsAcc'), aggr);
        }
        //Get Last Day or previous month.
        Date LastMonth = date.today().addmonths(-1);
        Date FirstOfLastMonth = date.newInstance(Lastmonth.year(), lastmonth.month(), 1);
        Integer numberOfDays = Date.daysInMonth(FirstOfLastMonth.year(), FirstOfLastMonth.month());
        Date LastDayOfLastMonth = Date.newInstance(FirstOfLastMonth.year(), FirstOfLastMonth.month(), numberOfDays);
        
        List<Product_Payments__c> prodPaymentData = [SELECT CCS_Account__C, Payment_Amount__c,Payment_Created__c
                                    FROM Product_Payments__c 
                                    WHERE 
                                    CCS_Account__C IN :listOfProductIds
                                    AND (RecordTYpe.DeveloperName = 'Distressed_Product_Payment') 
                                    AND (Payment_Type__c=: PAYTYPE_REGULAR OR Payment_Type__c =: PAYTYPE_PAID_IN_FULL OR Payment_Type__c=: PAYTYPE_SETTLED_IN_FULL) 
                                    AND Is_Payment_Reversed__c = False 
                                    AND Payment_Created__c >= :minPlacementDate 
                                    AND Payment_Created__c <= :maxRecallDate                 
                                    order by Payment_Created__c  desc ];
        
        map<Id, Decimal> mapProductPaymentAmount = new Map<ID, Decimal>();
        Map<Id, List<Product_Payments__c>> mapProductPaymentsData = new Map<Id, List<Product_Payments__c>>();
        for(Product_Payments__c prodPay : prodPaymentData){
            
            //calculate Actual Payment Amount : sum of ONLY the payments that came in the reporting period up to (and including) the recall date
            if(prodPay.Payment_Created__c >= FirstOfLastMonth && prodPay.Payment_Created__c <= LastDayOfLastMonth &&
               placementHistoryMap.containsKey(prodPay.CCS_Account__C) && prodPay.Payment_Created__c != NULL &&
               placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c != NULL &&
               prodPay.Payment_Created__c <= placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c){
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

            if(prodPay.Payment_Created__c <= LastDayOfLastMonth && placementHistoryMap.containsKey(prodPay.CCS_Account__C) && 
               prodPay.Payment_Created__c != NULL && placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c != NULL && 
               prodPay.Payment_Created__c <= placementHistoryMap.get(prodPay.CCS_Account__C).Placement_Recall_Date__c && !mapProductPaymentsData.containsKey(prodPay.CCS_Account__c)){
                mapProductPaymentsData.put(prodPay.CCS_Account__c, new List<Product_Payments__c>{ prodPay });   
            }
        }
          
        
        //Fetch custom value records from Metro2_File__c custom setting 
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        if(metro2TransUnion.MaxRowsCount__c <> NULL){
            maxRowslength = metro2TransUnion.MaxRowsCount__c;
        }
        if(metro2TransUnion.Canaccede_Financial_Group__c <> NULL){
            canaFinGrp = metro2TransUnion.Canaccede_Financial_Group__c;
        }
        if(metro2TransUnion.bureauIdentifier__c <> NULL){
            TransUnionIdentifier = metro2TransUnion.bureauIdentifier__c;
        }
        if(metro2TransUnion.HEADER__c <> NULL){
            headerCust = metro2TransUnion.HEADER__c;
        }
        if(metro2TransUnion.CA__c <> NULL){
            CA = metro2TransUnion.CA__c;
        }
        if(metro2TransUnion.ZAP__c <> NULL){
            ZAP = metro2TransUnion.ZAP__c;
        }
        if(metro2TransUnion.Identification_Number__c <> NULL){
            identificationNumber = metro2TransUnion.Identification_Number__c;
        }
        if(metro2TransUnion.Account_Type__c <> NULL){
            accountType = metro2TransUnion.Account_Type__c;
        }
        if(metro2TransUnion.Reporter_Address__c <> NULL){
            reporterAddress = metro2TransUnion.Reporter_Address__c;
        }
        if(metro2TransUnion.Reporter_Phone__c <> NULL){
            reporterPhone = metro2TransUnion.Reporter_Phone__c;
        }
        if(metro2TransUnion.Portfolio_Type__c <> NULL){
            portfolioType = metro2TransUnion.Portfolio_Type__c;
        }
        if(metro2TransUnion.Terms_Duration__c <> NULL){
            termsDuration = metro2TransUnion.Terms_Duration__c;
        }
        if(metro2TransUnion.Days_Diff_for_Delinquency__c <> NULL){
            noOfDaysForDelinquency = Integer.valueOf(metro2TransUnion.Days_Diff_for_Delinquency__c);
        }
        
        // Code for Date of LastmodifiedDate  Right Padding upon dynamic values in less
        String lastModifiedBydate= defLastModifiedBydate;
        lastModifiedBydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY((System.today()).toStartofMonth().addDays(-1));
        
        // Code for Date of CreatedDate  Right Padding upon dynamic values in less
        String createdDate = defCreateddate;
        createdDate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(System.today());
        
        String bureaIdentifier = defBureauIdentifier;
        if(TransUnionIdentifier != null) {
            if(TransUnionIdentifier.length() < 10) {
                bureaIdentifier = TransUnionIdentifier.rightPad(10);
            } 
            else if(TransUnionIdentifier.length() == 10) {
                bureaIdentifier = TransUnionIdentifier;
            }
            else if(TransUnionIdentifier.length() > 10){
                bureaIdentifier = TransUnionIdentifier;
                bureaIdentifier = bureaIdentifier.substring(0, 10);
            }
        }
        
        String idenfificationNum = defIdentificationNumber;
        if(identificationNumber != null) {
            if(identificationNumber.length() < 20) {
                idenfificationNum = identificationNumber.rightPad(20);
            } 
            else if(identificationNumber.length() == 20) {
                idenfificationNum = identificationNumber;
            }
            else if(identificationNumber.length() > 20){
                idenfificationNum = identificationNumber;
                idenfificationNum = idenfificationNum.substring(0, 20);
            }
        }        
        String canaccedeFinGrp = defCanaFinGrp;
        if(canaFinGrp != null) {
            if(canaFinGrp.length() < 40) {
                canaccedeFinGrp = canaFinGrp.rightPad(40);
            } 
            else if(canaFinGrp.length() == 40) {
                canaccedeFinGrp = canaFinGrp;
            }
            else if(canaFinGrp.length() > 40){
                canaccedeFinGrp = canaFinGrp;
                canaccedeFinGrp = canaccedeFinGrp.substring(0, 40);
            }
        }
        
        String repAddress = defReportAddress;
        if(reporterAddress != null) {
            if(reporterAddress.length() < 96) {
                repAddress = reporterAddress.rightPad(96);
            } 
            else if(reporterAddress.length() == 96) {
                repAddress = reporterAddress;
            }
            else if(reporterAddress.length() > 96){
                repAddress = reporterAddress;
                repAddress = repAddress.substring(0, 96);
            }
        }

        String repPhone = defReportTelPhoneNum;
        if(reporterPhone != null) {
            if(reporterPhone.length() < 10) {
                repPhone = reporterPhone.rightPad(10);
            } 
            else if(reporterPhone.length() == 10) {
                repPhone = reporterPhone;
            }
            else if(reporterPhone.length() > 10){
                repPhone = reporterAddress;
                repPhone = repPhone.substring(0, 10);
            }
        }

        // Code to generate Header record
        string headbody = maxRowslength + headerCust + extra27Spaces + bureaIdentifier + lastModifiedBydate + createdDate + extra16Spaces + canaccedeFinGrp + repAddress + repPhone;
        
        Integer countheader = 0;
        if(Integer.valueOf(maxRowslength) <> NULL){
            countheader = Integer.valueOf(maxRowslength) - headbody.length();
        }
        
        Integer countheader2 = countheader + headbody.length();
        
        Metro__c metroheaderrecsetting  = Metro__c.getInstance('Header');

        if(metroheaderrecsetting.HeaderCheck__c == false) {
            MetroFlatFileData__c metroobj24 = new MetroFlatFileData__c();
            metroobj24.RowData1__c = headbody/*  + String.fromCharArray(trimmedArray2) */;
            metroobj24.HeaderCheck__c = true;
            metroobj24.Bureau_Type__c = bureauTypeTransUnion;
            metroobj24.Product_Type__c = productType;
            metroobj24.Sort_Order__c = 1;
            metroobj24.Batch_Number__c = batchNumber;
            insert metroobj24;
            metroheaderrecsetting.HeaderCheck__c = true;
            try{
                Update metroheaderrecsetting;
            }catch(Exception ex){
                system.debug('exception'+ex);
            }
            
        }
        
        //Integer Stringcount = headbody.length();
        String headbodyfinal = headbody.length() + headbody;
        
        // List created to bulk insert the metro2 data. 
        List<MetroFlatFileData__c> metroFileData = new List<MetroFlatFileData__c>();
        List<MetroFlatFileData__c> metroFileDataK1Seg = new List<MetroFlatFileData__c>();
        Boolean nameValidationCheck = false;

        for(Product__c prodct :scope) {
            nameValidationCheck = false;
            if(!mapProductExcluse.containsKey(prodct.id)){
                
            MetroFlatFileData__c metroobj2 = new MetroFlatFileData__c();
            
            // Code for Adding Date Opened Right Padding upon dynamic values in less
            String Dateopened = defDateOpened;
            if((placementHistoryMap.containsKey(prodct.id) && placementHistoryMap.get(prodct.id).Placement_Date__c <> NULL) 
              || previousAllocatedAgency.containsKey(prodct.id)){
                 Dateopened = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(placementHistoryMap.get(prodct.id).Placement_Date__c);
                 metroobj2.Open_Date__c = Dateopened;   
            }else{
                if(prodct.Assignment_Date__c != null) {
                    Dateopened = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Assignment_Date__c);
                    metroobj2.Open_Date__c = Dateopened;
                }
            }
            
            
            // Code for Adding Accname Right Padding upon dynamic values in less
            String productname = defProductName;
            if(prodct.Name.length() < 30) {
                productname = prodct.Name.rightPad(30);
            } 
            else if(prodct.Name.length() == 30) {
                productname = prodct.Name;
            }
            else if(prodct.Name.length() > 30){
                productname = prodct.Name;
                productname = productname.substring(0, 30);
            }
            
            // Code for Adding Purchase_Face_Value__c Left Padding upon dynamic values in less
            String orignalCreditAmt = defOrignalCreditAmt;
            if(prodct.Purchase_Face_Value__c != null) {
                //Code to prevent negative values. if value is negative show 0's
                if(prodct.Purchase_Face_Value__c >= 0){        
                    orignalCreditAmt = String.valueOf(prodct.Purchase_Face_Value__c);
                    orignalCreditAmt = orignalCreditAmt.subString(0,orignalCreditAmt.indexOf('.'));
                    orignalCreditAmt = orignalCreditAmt.leftPad(9, '0');
                }
                else if(prodct.Purchase_Face_Value__c < 0){
                    orignalCreditAmt = defOrignalCreditAmt;
                }        
            }
            
            // Code for Adding Payment Frequency Right Padding upon dynamic values in less
            String paymentfrequency = defPaymentFrequency;
            //Set payment frquency default D(i.e Deferred)
            paymentfrequency = metro2TransUnion.Payment_Frequency__c;

            // Code for Adding Actual Payment Amount  Right Padding upon dynamic values in less
            String Finalactualpayplan  = defFinalactualpayplan;    
            AggregateResult grossPaySum = productSumTotal.get(prodct.id);
            Decimal actualGrossPay = 0.00;
            if(mapProductPaymentAmount.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)){
                Finalactualpayplan = String.valueOf(mapProductPaymentAmount.get(prodct.id).setScale(0));
                Finalactualpayplan = Finalactualpayplan.leftPad(9, '0');  
            }
            else {
                if(null != grossPaySum){
                    actualGrossPay = (Decimal)grossPaySum.get('grossPay'); 
                    //negative amount to be reported as zero
                    if(actualGrossPay!=null && actualGrossPay > 0){
                        Finalactualpayplan = String.valueOf(actualGrossPay.setScale(0));
                        Finalactualpayplan = Finalactualpayplan.leftPad(9, '0');  
                    }else if(actualGrossPay < 0){
                        Finalactualpayplan  = defFinalactualpayplan;
                    }
                }    
            }
                   
            Date firstPaymentDate = null;    
            if(null != grossPaySum){
                firstPaymentDate = (Date)grossPaySum.get('firstPaymentDate');
            }
            
            //Code for populating Payment history profile for last 24 months
            String paymentHistoryProfile = defNumberOfPayments;

            // Code for date closed Right Padding upon dynamic values in less
            String dateclosed = defDateClosed;             
            if(prodct.Closed_Date__C != null){
                dateclosed = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(date.newinstance(prodct.Closed_Date__C.year(), prodct.Closed_Date__C.month(), prodct.Closed_Date__C.day()));
            }
            
            // Code for date of last payment  Right Padding upon dynamic values in less
            String lastpaymentdate  = defLastPaymentDate;
            if(mapProductPaymentsData.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)){
               lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(mapProductPaymentsData.get(prodct.id)[0].Payment_Created__c); 
            }else{
                if(!placementHistoryMap.containsKey(prodct.id)){
                    if(prodct.Last_Payment_Date__c != null) {
                        lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
                    }
                }
                if(previousAllocatedAgency.containsKey(prodct.id)){
                    if(prodct.Last_Payment_Date__c != null) {
                        lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
                    }
                }
            }
       		
           //First Name or Last Name excluded from bureau reporting fetch from Metro2_File__c custom setting
           string nameExluded = metro2TransUnion.Name_Excluded_List__c;
           list<string> nameExcludeList = new list<string>();
           if(nameExluded != Null){
                nameExcludeList = nameExluded.split(',');   
           }

            // Code for Adding First_Name__c Right Padding upon dynamic values in less
            String firstname = defFirstName;
            if(prodct.First_Name__c != null) {
                Boolean checkFirstNameValid = CustomerProcessingBatchHelper.getValidCustomerName(prodct.First_Name__c);
                if(checkFirstNameValid == true){
                    if(nameExcludeList.contains(prodct.First_Name__c.toUpperCase())){
                        firstname = defFirstName;
                        nameValidationCheck = true;
                    }else if(prodct.First_Name__c.toUpperCase() == INC || 
                             prodct.First_Name__c.toUpperCase().contains(spaceINC) ){
                        firstname = defFirstName;
                        nameValidationCheck = true;  
                    }else{
                        if(prodct.First_Name__c.length() <= 20) {
                            String firstNameValue = prodct.First_Name__c;
                            firstname = firstNameValue.rightPad(20);
                            firstname = firstname.toUpperCase();
                        } 
                        else if(prodct.First_Name__c.length() > 20) {
                            firstname = prodct.First_Name__c;
                            firstname = firstname.left(20);
                            firstname = firstname.toUpperCase();
                        }
                    }
                }else{
                    nameValidationCheck = true;
                }
            }

            // Code for Adding Last_Name__c Right Padding upon dynamic values in less
            String lastname = defLastName;
            if(prodct.Last_Name__c != null) {
                Boolean checkLastNameValid = CustomerProcessingBatchHelper.getValidCustomerName(prodct.Last_Name__c);
                if(checkLastNameValid == true){
                    if(nameExcludeList.contains(prodct.Last_Name__c.toUpperCase())){
                        lastname = defLastName;
                        nameValidationCheck = true;      
                    }else if(prodct.Last_Name__c.toUpperCase() == INC || 
                             prodct.Last_Name__c.toUpperCase().contains(spaceINC) ){
                        lastname = defLastName;       
                        nameValidationCheck = true;                  
                    }else{
                        if(prodct.Last_Name__c.length() <= 25) {
                            String lastNameValue = prodct.Last_Name__c;
                            lastname = lastNameValue.rightPad(25);
                            lastname = lastname.toUpperCase();
                        } 
                        else if(prodct.Last_Name__c.length() > 25) {
                            lastname = prodct.Last_Name__c;
                            lastname = lastname.left(25);
                            lastname = lastname.toUpperCase();
                        }     
                    } 
                }else{
                    nameValidationCheck = true;
                }
            }

            // Code for Adding Middle_Name__c Right Padding upon dynamic values in less
            String middlename = defMiddleName;
            if(prodct.Middle_Name__c != null) {
                if(prodct.Middle_Name__c.length() <= 20) {
                    String middleNameValue = prodct.Middle_Name__c;
                    middlename = middleNameValue.rightPad(20);
                    middlename = middlename.toUpperCase();
                } 
                else if(prodct.Middle_Name__c.length() > 20) {
                    middlename = prodct.Middle_Name__c;
                    middlename = middlename.left(20);
                    middlename = middlename.toUpperCase();
                }
            }
            // Code for Adding SIN__c Right Padding upon dynamic values in less
            String SinNumber = defSinNumber;
            if(prodct.SIN__c != null && prodct.SIN__c.length() == 9) {
                metroobj2.SIN__c = prodct.SIN__c;
                SinNumber = prodct.SIN__c;
            }
            // Code for Date of Birth Amount  Right Padding upon dynamic values in less
            String Dateofbirth = defDateOfbirth;
            if(prodct.Date_of_Birth__c != null) {
                Dateofbirth = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Date_of_Birth__c);
                metroobj2.Dateofbirth__c = Dateofbirth;
            }
            // Code for Phone Number  Right Padding upon dynamic values in less
            String PhoneNumber = defphoneNumber;
            if(prodct.Phone_Home__c != null) {
                Boolean checkPhoneValid = CustomerProcessingBatchHelper.getValidPhoneNumber(prodct.Phone_Home__c);
                if(checkPhoneValid == true){
                    String phonenumberNumeric = prodct.Phone_Home__c.replaceAll('[^0-9]', '');
                    if(String.valueOf(phonenumberNumeric).length() < 10) {
                        PhoneNumber = String.valueOf(phonenumberNumeric).rightPad(10);
                        metroobj2.PhoneNumber__c = PhoneNumber ;
                    } 
                    else if(String.valueOf(phonenumberNumeric).length() == 10) {
                        PhoneNumber = String.valueOf(phonenumberNumeric);
                        metroobj2.PhoneNumber__c = PhoneNumber ;
                    }  
                    metroobj2.PhoneNumberProduct__c = prodct.Phone_Home__c ;
                }              
            }
            
            // Code for Address Line 1 Right Padding upon dynamic values in less
            String AddressLine = defAddressLine;
            if(prodct.Address_Line1__c != null) {
                if(String.valueOf(prodct.Address_Line1__c).length() < 32) {
                    AddressLine = String.valueOf(prodct.Address_Line1__c).rightPad(32);
                    AddressLine = AddressLine.toUpperCase();
                } 
                else if(String.valueOf(prodct.Address_Line1__c).length() == 32) {
                    AddressLine = String.valueOf(prodct.Address_Line1__c);
                    AddressLine = AddressLine.toUpperCase();
                }
                else if(String.valueOf(prodct.Address_Line1__c).length() > 32){
                    AddressLine = String.valueOf(prodct.Address_Line1__c);
                    AddressLine = AddressLine.substring(0, 32);
                }
            }
            
            // Code for Address Line 2 Right Padding upon dynamic values in less
            String AddressLine2 = defAddressLine2;
            if(prodct.Address_Line2__c != null) {
                if(String.valueOf(prodct.Address_Line2__c).length() < 32) {
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c).rightPad(32);
                    AddressLine2 = AddressLine2.toUpperCase();
                } 
                else if(String.valueOf(prodct.Address_Line2__c).length() == 32) {
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c);
                    AddressLine2 = AddressLine2.toUpperCase();
                }
                else if(String.valueOf(prodct.Address_Line2__c).length() > 32){
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c);
                    AddressLine2 = AddressLine2.substring(0, 32);
                }
            }
            
            // Code for City Right Padding upon dynamic values in less
            String cityaddress = defCityAddress;
            if(prodct.City__c != null) {
                if(String.valueOf(prodct.City__c).length() < 20) {
                    cityaddress = String.valueOf(prodct.City__c).rightPad(20);
                    cityaddress = cityaddress.toUpperCase();
                } 
                else if(String.valueOf(prodct.City__c).length() == 20) {
                    cityaddress = String.valueOf(prodct.City__c);
                    cityaddress = cityaddress.toUpperCase();
                }
                else if(String.valueOf(prodct.City__c).length() > 20){
                    cityaddress = String.valueOf(prodct.City__c);
                    cityaddress = cityaddress.substring(0, 20);
                }
            }
            
            // Code for state Right Padding upon dynamic values in less
            String stateaddress = defStateAddress;
            String provinceCode = prodct.State__c;
            if(provinceCode != null) {
                if(provinceCode.length() < 2) {
                    stateaddress = provinceCode.rightPad(2);
                }
                else if(provinceCode.length() == 2) {
                    stateaddress = provinceCode;
                }
                else if(provinceCode.length() > 2){
                    stateaddress = provinceCode;
                    stateaddress = stateaddress.substring(0, 2);
                }
            }
            
            String ZipAddres= defZipAddres;
            if(prodct.Zip_Code__c != null) {
                //Code to remove space from Zipcode
                String ZipAddresWithoutSpaces = prodct.Zip_Code__c.replaceAll( '\\s+', '');
                
                if(ZipAddresWithoutSpaces.length() < 9) {
                    ZipAddres = ZipAddresWithoutSpaces.rightPad(9);
                } 
                else if(String.valueOf(prodct.Zip_Code__c).length() == 9) {
                    ZipAddres = ZipAddresWithoutSpaces;
                }
                else if(String.valueOf(prodct.Zip_Code__c).length() > 9){
                    ZipAddres = ZipAddresWithoutSpaces;
                    ZipAddres = ZipAddres.substring(0, 9);
                }
            }
            
            // Set default Account status to 13
            String accountStatus =defAccountStatus;
            if(String.isNotBlank(prodct.Product_Status__c)){
                for(Data_Status_Mapping__c metaData : mapDataStatusMapping.values()){
                    mapDataStatus.put(metaData.name,metaData);
                }
                if(mapDataStatus.containskey(prodct.Product_Status__c))  {
                    if(prodct.Collection_Agency__c == 9999){
                        if(mapDataStatus.get(prodct.Product_Status__c).Bureau_Reporting_Account_Status__c  == 'Closed'){
                            accountStatus = metro2TransUnion.Account_Status_Close__c; // set account status 62
                        }else{
                             accountStatus = metro2TransUnion.Account_Status_Recalled__c;
                        }
                    }else{
                        if(mapDataStatus.get(prodct.Product_Status__c).Bureau_Reporting_Account_Status__c  == 'Open'){
                            accountStatus = metro2TransUnion.Account_Status_Open__c; // set account status 93
                        } 
                    }
                 }
            }
            else{
                //set account status to 93
                accountStatus = metro2TransUnion.Account_Status_Open__c;
            }
            
            metroobj2.Status__c = accountStatus;
            
            // Code for Adding current Amount  Right Padding upon dynamic values in less
            String currentplanval = defCurrentPlanval;
            if(placementHistoryMap.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)){
                if(accountStatus != metro2TransUnion.Account_Status_Close__c){
                    //Code to prevent negative values. if value is negative show 0's
                    if(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c >= 0){        
                        currentplanval = String.valueOf(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c);
                        currentplanval = currentplanval.subString(0,currentplanval.indexOf('.'));
                        currentplanval = currentplanval.leftPad(9, '0');
                    }
                    else if(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c < 0){
                        currentplanval = defCurrentPlanval;
                    } 
                }else{
                    currentplanval = defCurrentPlanval;
                }     
            }
            else{
                if(prodct.Current_Balance__c != null) {
                    if(accountStatus != metro2TransUnion.Account_Status_Close__c){
                        //Code to prevent negative values. if value is negative show 0's
                        if(prodct.Current_Balance__c >= 0){        
                            currentplanval = String.valueOf(prodct.Current_Balance__c);
                            currentplanval = currentplanval.subString(0,currentplanval.indexOf('.'));
                            currentplanval = currentplanval.leftPad(9, '0');
                        }
                        else if(prodct.Current_Balance__c < 0){
                            currentplanval = defCurrentPlanval;
                        } 
                    }else{
                        currentplanval = defCurrentPlanval;
                    }       
                }    
            }
            
            // Code for Adding past Amount  Right Padding upon dynamic values in less
            String pastval = defPastVal;
            if(placementHistoryMap.containsKey(prodct.id) && !previousAllocatedAgency.containsKey(prodct.id)){
                //Code to prevent negative values. if value is negative show 0's
                if(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c >= 0){        
                    pastval = String.valueOf(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c);
                    pastval = pastval.subString(0,pastval.indexOf('.'));
                    pastval = pastval.leftPad(9, '0');
                }
                else if(placementHistoryMap.get(prodct.id).Current_Total_Bal_at_time_of_Recall__c < 0){
                    pastval = defCurrentPlanval;
                } 
            }
            else{
                if(prodct.Current_Balance__c != null) {
                    //Code to prevent negative values. if value is negative show 0's
                    if(prodct.Current_Balance__c >= 0){        
                        pastval = String.valueOf(prodct.Current_Balance__c);
                        pastval = pastval.subString(0,pastval.indexOf('.'));
                        pastval = pastval.leftPad(9, '0');
                    }
                    else if(prodct.Current_Balance__c < 0){
                        pastval = defCurrentPlanval;
                    }      
                }    
            }
            //code for populating Date of Account Information
            String acctInformationDate = defDateOfAccountInformationDate;
            if(placementHistoryMap.containsKey(prodct.id) && placementHistoryMap.get(prodct.id).Placement_Recall_Date__c != NULL){
               acctInformationDate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(placementHistoryMap.get(prodct.id).Placement_Recall_Date__c);      
            }
            
            //Code for populating Payment rating
            String paymentRating = defPaymentRating;
            
            // Code for Last_Delinquency_Date__c Amount  Right Padding upon dynamic values in less
            String lastdelinquencydate = defLastDelinquencyDate;
            //Use Charged_Off_Date__c for Date of First Delinquency
            if(prodct.Charged_Off_Date__c != NULL){
                Date delinquencyDateCalculated = prodct.Charged_Off_Date__c.addDays(-noOfDaysForDelinquency);
            	lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(delinquencyDateCalculated);   
            }
            
            //set special comments value for records Product_Status__c
            String specialComments = defSpecialComments;
            
            // Code for Charged_Off_Amount__c  Amount  Right Padding upon dynamic values in less
            String chargeffamount = defChargeOffAmount;
            if(null != prodct.Charged_Off_Amount__c){
                chargeffamount = String.valueOf((prodct.Charged_Off_Amount__c));
                chargeffamount = chargeffamount.subString(0,chargeffamount.indexOf('.'));
                chargeffamount = chargeffamount.leftPad(9, '0');
            }
            
            // Set Customer Information Indicator to blank for all Distressed account
            String customerInformationIndicator = '';
            customerInformationIndicator = customerInformationIndicator.leftPad(2);

            // Code for Deceased Date
            String deceasedDate  = ' ';
            if(prodct.Deceased_Date__c != null) {
                deceasedDate = 'X';
            }else{
                deceasedDate = '1';
            }
            
            //K1 Segment
            String K1SegmentLine = K1Segment;
            if(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c != null) {
                if(String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c).length() < 30) {
                    string sellerName = String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c);
                    K1SegmentLine = sellerName.rightPad(30);
                    K1SegmentLine = K1SegmentLine.toUpperCase();
                } 
                else if(String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c).length() == 30) {
                    K1SegmentLine = String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c);
                    K1SegmentLine = K1SegmentLine.toUpperCase();
                }
                else if(String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c).length() > 30){
                    K1SegmentLine = String.valueOf(prodct.Portfolio_Name_Lookup__r.CIML_Reporting_Name__c);
                    K1SegmentLine = K1SegmentLine.substring(0, 30);
                }
            }else{
                    K1SegmentLine = K1Segment;
            }
            
            //Body record
            string headbody2 = maxRowslength + '1'+ extra14Spaces +'0'+idenfificationNum+ extra2Spaces + productname + portfolioType + accountType + Dateopened + '000000000' + orignalCreditAmt + termsDuration + paymentfrequency + extra9Spaces + Finalactualpayplan + accountStatus + paymentRating + paymentHistoryProfile + specialComments + extra2Spaces + currentplanval + pastval + chargeffamount + acctInformationDate + lastdelinquencydate + dateclosed + lastpaymentdate + currencyTypeCode + extra1Spaces + lastname + firstname + middlename + extra1Spaces + SInnumber + Dateofbirth + PhoneNumber + deceasedDate + customerInformationIndicator + CA + AddressLine + AddressLine2 + cityaddress + stateaddress + ZipAddres+ extra2Spaces +'K1'+K1SegmentLine;
            
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

            if(nameValidationCheck == false){
               metroFileData.add(metroobj2);     
            }
            
            //increment counter if records to be considered as out of CCS
            if(accountStatus == metro2TransUnion.Account_Status_Close__c){
                if(null == prodct.TransUnion_Reported_As_Complete_Count__c){
                    prodct.TransUnion_Reported_As_Complete_Count__c = 1;
                }
                else{
                    prodct.TransUnion_Reported_As_Complete_Count__c += 1;
                }
                listOfProductsToUpdate.add(prodct);
            }
            
          }// if condition
        }// for loop
        
        insert metroFileData;
        
        if(metro2TransUnion.Do_Not_Increase_Count__c == FALSE){
            ProductTriggerHandler.runProductTrigger = false;
            try{
                update listOfProductsToUpdate;
            }catch(Exception ex){
                system.debug('exception'+ex);
            }
            ProductTriggerHandler.runProductTrigger = true;
        }
        
    }
    
    // Finish Method to generate TAILER record
    public void finish(Database.BatchableContext BC) {
        String FinalSINCOUNT = '000000000';
        String FinalDOBCOunt = '000000000';
        String FinalPhoneocuntNet = '000000000';
        String FinalSTATUS13COUNT = '000000000';
        String FinalSTATUS93COUNT = '000000000';
        String FinalSTATUS97COUNT = '000000000';
        String FinalSTATUSDACOUNT = '000000000';
        String FinalSTATUS62COUNT = '000000000';
        String extra18Spaces = blankString.leftPad(18);
        String extra4Spaces = blankString.leftPad(4);
        String extra27Zeros = blankString.leftPad(27, '0');
        String extra18Zeros = blankString.leftPad(18, '0');
        String extra9Zeros = blankString.leftPad(9, '0');
        String extra99Zeros = blankString.leftPad(99, '0');

        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        String maxRowslength = metro2TransUnion.MaxRowsCount__c;
        
        List<MetroFlatFileData__c> metrolstcount = new List<MetroFlatFileData__c>();
        AggregateResult[] metrolstcountData = [Select count(id) metroFlatFileDatacnt FROM MetroFlatFileData__c where HeaderCheck__c = false and FooterCheck__c = false and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber];
        Integer Rowscount = 0;

        for(AggregateResult aggr : metrolstcountData){
            Rowscount = (Integer)aggr.get('metroFlatFileDatacnt');
        }
 		 
        Integer  RowscountLength = String.valueOf(Rowscount).length();

        Integer FinalPhoneocunt = [select PhoneNumber__c from MetroFlatFileData__c where PhoneNumber__c != null and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber limit 49000].size();
        FinalPhoneocuntNet = CustomerProcessingBatchHelper.getStringWithZeroPadding(FinalPhoneocunt);
        
        //Final SIN Count
        List<MetroFlatFileData__c> metroobj = new List<MetroFlatFileData__c>();
        Integer SINCOUNT = [select SIN__c from MetroFlatFileData__c where SIN__c != null and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber].size();
        FinalSINCOUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(SINCOUNT);
        
        //DOB Count
        List<MetroFlatFileData__c> metroobj2 = new List<MetroFlatFileData__c>();
        Integer DOBCOUNT = [select Dateofbirth__c from MetroFlatFileData__c where Dateofbirth__c != null and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber limit 49000].size();
        FinalDOBCOunt = CustomerProcessingBatchHelper.getStringWithZeroPadding(DOBCOUNT);
        
        //Status 93 Count
        Integer STATUS93COUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = '93' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber limit 49000].size();
        FinalSTATUS93COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS93COUNT);
        
        //Status 97 Count
        Integer STATUS97COUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = '97' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber limit 49000].size();
        FinalSTATUS97COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS97COUNT);
        
        //Status DA Count
        Integer STATUSDACOUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = 'DA' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber limit 49000].size();
        FinalSTATUSDACOUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUSDACOUNT);
        
        //Status 62 Count
        Integer STATUS62COUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = '62' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY and Batch_Number__c =: batchNumber limit 49000].size();
        FinalSTATUS62COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS62COUNT);
        
        String rowscountwithzero;
        if(RowscountLength < 9) {
            rowscountwithzero = String.valueOf(Rowscount).leftPad(9, '0');
        } 
        else if(RowscountLength > 9) {
            rowscountwithzero  = '0000000' + String.valueOf(Rowscount);
        } 
        else if(RowscountLength == 9) {
            rowscountwithzero  = '00000000' + String.valueOf(Rowscount);
        }

        String Trailerrec = maxRowslength+'TRAILER' + rowscountwithzero + extra18Spaces + extra27Zeros +FinalSTATUSDACOUNT+extra18Zeros + FinalSTATUS13COUNT + extra9Zeros + FinalSTATUS62COUNT + extra99Zeros + FinalSTATUS93COUNT + extra27Zeros + FinalSTATUS97COUNT + extra18Zeros + rowscountwithzero + extra27Zeros + extra9Zeros + FinalSINCOUNT + FinalSINCOUNT + extra18Zeros + FinalDOBCOunt + FinalDOBCOunt + extra18Zeros + FinalPhoneocuntNet + extra4Spaces;
        
        Integer Trailcount2 = Integer.valueOf(maxRowslength) - Trailerrec.length();
       
        MetroFlatFileData__c metroobj4 = new MetroFlatFileData__c();
        metroobj4.RowData1__c = Trailerrec;
        metroobj4.FooterCheck__c = true;
        metroobj4.Bureau_Type__c = bureauTypeTransUnion;
        metroobj4.Product_Type__c = productType;
        metroobj4.Sort_Order__c = 3; 
        metroobj4.Batch_Number__c = batchNumber; 
        insert metroobj4;
        
        Metro__c metroheaderrec = Metro__c.getInstance('Header');
        metroheaderrec.HeaderCheck__c = false;
        try{
            update metroheaderrec;
        }catch(Exception ex){
            system.debug('exception'+ex);
        }
        System.enqueueJob(new CreditBureauRepTUTextFileGeneration(batchNumber));
    }
}