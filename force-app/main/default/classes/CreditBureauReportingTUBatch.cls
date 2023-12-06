/***************************************************
* Author         : A5E Consultancy
* Created On     : 10 July 2023
* Description    : Generate Metro File Data from Product__c records for Bureau TransUnion
*
***************************************************/

public class CreditBureauReportingTUBatch implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts{
    
    public static final string defLastModifiedBydate = '00000000';
    public static final string defCreateddate = '00000000';
    public static final String defDateOpened = '        ';
    public static final String defProductName = '                              ';
    public static final String defOrignalCreditAmt = '000000000';
    public static final String defPaymentFrequency = ' ';
    public static final String defMonthPayPlan = '000000000';
    public static final String defFinalactualpayplan = '000000000';
    public static final String defCurrentPlanval = '000000000';
    public static final String defPastVal = '000000000';
    public static final String defChargeOffAmount = '000000000';
    public static final String defLastDelinquencyDate = '00000000';
    public static final String defDateClosed = '00000000';
    public static final String defLastPaymentDate  = '00000000';
    public static final String defFirstName = '                    ';
    public static final String defLastName = '                    ';
    public static final String defMiddleName  = '                    ';
    public static final String defSinNumber = '000000000';
    public static final String defDateOfbirth = '00000000';
    public static final String defPhoneNumber = '0000000000';
    public static final String defNumberOfPayments = 'BBBBBBBBBBBBBBBBBBBBBBBB';
    public static final String defAddressLine = '                                ';
    public static final String defAddressLine2 = '                                ';
    public static final String defCityAddress = '                    ';
    public static final String defStateAddress = '  ';
    public static final String defZipAddres= '         ';
    public static final String defAccountStatus = '';
    public static final String defPaymentRating = ' ';
    public static final String defSpecialComments = ' ';
    public static final String defCustomerInformationIndicator = '  ';
    public static final String bureauTypeTransUnion = 'TransUnion';
    public static final String productType = 'Distressed Account';
    public static final String K1Segment = '                              ';
    public static map<ID, ID> mapProductJudgmentClaimIssuedID;
    public static final String defReportAddress = '                                                                                                ';
    public static final String defReportTelPhoneNum = '          ';
    public static final String defCanaFinGrp = '                                        ';
    public static final String defIdentificationNumber = '                    ';
    public static final String defBureauIdentifier = '          ';
    public static map<String, Data_Status_Mapping__c> mapDataStatusMapping = Data_Status_Mapping__c.getAll();
    public static map<String, Data_Status_Mapping__c> mapDataStatus = new map<String, Data_Status_Mapping__c>();
        
    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        list<string> excludeProdStatusList = new list<string>();
        string prodStatus = metro2TransUnion.Product_Status_Excluded__c;
        if(prodStatus != Null){
            excludeProdStatusList = prodStatus.split(',');   
        }
        list<Decimal> includeAgencyList = new list<Decimal>();
        string agencyList = metro2TransUnion.Agency_Included__c;
        List<String> splitDoubleValues = agencyList.split(',');
        Decimal strToDec = 0;
        for(String s : splitDoubleValues){
            if(agencyList != Null){
                strToDec = decimal.valueOf(s);
                includeAgencyList.add(strToDec);   
            }
        }


        Integer noOfTimesToReport = Integer.valueOf(metro2TransUnion.Number_of_Times_To_Report__c);
        Integer noOfDaysAfterReport = Integer.valueOf(metro2TransUnion.Number_of_Days_After_Reporting__c);
        Date dayBefore45 = System.today().addDays(-noOfDaysAfterReport);
		//String listname = ['833P1016','833P1080'];
        //List<String> productNames = new List<String>{'833P1016','833P1080'};
        //Query to fetch all the eligible records with the recordtype as CCS Account
        return Database.getQueryLocator('SELECT Id, Name,RecordType.Name,Open_Date__c,Previous_Primary_Account_Number__c, Closed_Date__C, Product_Status__c,Createddate,LastModifieddate,Original_Balance__c,Monthly_Payment_Amount__c,Current_Balance__c,Last_Delinquency_Date__c,Last_Payment_Date__c,Last_Name__c,First_Name__c,Middle_Name__c,SIN__c,Phone_Home__c,Date_of_Birth__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Provinces__c,Zip_Code__c,Deceased_Date__c, Purchase_Date__c, Charged_Off_Amount__c,Last_Payment_Date_Prior_to_CO__c, TransUnion_Reported_As_Complete_Count__c,Seller__r.name,Charged_Off_Date__c FROM Product__c '+
                                        'WHERE '+ 
                                        'RecordType.Name =: productType AND '+ 
										'Product_Status__c NOT IN :excludeProdStatusList AND '+
										'Collection_Agency__c IN :includeAgencyList AND '+ 
										'(Number_Of_Open_Complaint__c = 0 OR Number_Of_Open_Complaint__c = NULL) AND '+ 
										'Last_Name__c != null AND '+
                                        'First_Name__c != null AND '+
                                        'Name !=null AND '+ 
                                        'Purchase_Date__c != null AND '+ 
                                        'Current_Balance__c != null AND '+ 
                                        'Previous_Primary_Account_Number__c != null AND '+ 
										'Assignment_Date__c <: dayBefore45 AND '+
                                        '(NOT First_Name__c LIKE \'_\') AND ' + 
                                        '(NOT Last_Name__c LIKE \'_\') AND ' +
                                        'Charged_Off_Date__c <> null AND ' +
                                        'Last_Payment_Date_Prior_to_CO__c <> null AND ' +
                                        'Difference_Greater_Than_N_Years__c = False AND ' + 
                                        '(TransUnion_Reported_As_Complete_Count__c = null OR ' +  
                                        'TransUnion_Reported_As_Complete_Count__c <: noOfTimesToReport)');
        
    }
    
    //Execute Method
    public void execute(Database.BatchableContext BC, List<Product__c> scope) {
		system.debug('inside execute method');
        List<Product__c> updateProduct = new List<Product__c>();
        map<Id, Product__c> mapProduct = new map<Id, Product__c>();
        mapProductJudgmentClaimIssuedID = new map<ID, ID>();
        map<id,boolean> mapProductExcluse = new map<id,boolean>();
        map<String, Credit_Bureau_Reporting_Periods__mdt> mapCreditBureauRepPeriods = Credit_Bureau_Reporting_Periods__mdt.getAll();
        map<String, Credit_Bureau_Reporting_Periods__mdt> mapProvinceAcronymCBRepPeriods = new map<String, Credit_Bureau_Reporting_Periods__mdt>();
        
        for(Credit_Bureau_Reporting_Periods__mdt metaData : mapCreditBureauRepPeriods.values()){
            mapProvinceAcronymCBRepPeriods.put(metaData.Province_Name__c,metaData);
        }
        
        List<ID> productID = new List<ID>();
        for(Product__c prodRec: scope){
            productID.add(prodRec.id);
            mapProduct.put(prodRec.ID, prodRec);
        }
		List<Account_Judgment__c> accountJudgment = [SELECT ID, Name, Product__c, Judgment__c,
                                                   Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
                                                   FROM Account_Judgment__c
                                                   WHERE Product__c IN :mapProduct.keySet() AND Status__c= 'Active'];
        
        for(Account_Judgment__c accountJudgmentData : accountJudgment){
            if(accountJudgmentData.Judgment__r.Legal_Status__c == 'Judgment' 
            || accountJudgmentData.Judgment__r.Legal_Status__c == 'Post-Judgment' || accountJudgmentData.Judgment__r.Legal_Status__c == 'Pre-Judgment'){ 
                mapProductJudgmentClaimIssuedID.put(accountJudgmentData.Product__c, accountJudgmentData.Judgment__c);
            }
        }

        for(Product__c prodRecData: scope){
            if(mapProductJudgmentClaimIssuedID.containsKey(prodRecData.id)){
                Integer numberOfPeriods;
                if(prodRecData.State__c != NULL && mapProvinceAcronymCBRepPeriods.containskey(prodRecData.State__c) 
                   && mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Collection_Period__c != NULL){
                     numberOfPeriods = Integer.valueOf(mapProvinceAcronymCBRepPeriods.get(prodRecData.State__c).TU_Judgment_Period__c);  
                }
                
                if(prodRecData.Charged_Off_Date__c != NULL){
                    if(numberOfPeriods != NULL){
                        prodRecData.Charged_Off_Date__c = prodRecData.Charged_Off_Date__c.addYears(numberOfPeriods);
                    }
                    if(prodRecData.Charged_Off_Date__c < Date.today()){
                        mapProductExcluse.put(prodRecData.id,true);
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
                        prodRecData.Charged_Off_Date__c = prodRecData.Charged_Off_Date__c.addYears(numberOfPeriods); 
                    }
                    if(prodRecData.Charged_Off_Date__c < Date.today()){
                        mapProductExcluse.put(prodRecData.id,true);
                    }  
                }
            }
        }
  
        Map<String, AggregateResult> productSumTotal = new Map<String, AggregateResult>();
        AggregateResult[] prodPayment = [SELECT CCS_Account__C ccsAcc, sum(Payment_Amount__c) grossPay
                                    FROM Product_Payments__c 
                                    WHERE 
                                    CCS_Account__C IN :productID
                                    AND (RecordTYpe.Name = 'Distressed Product Payment') 
                                    AND (Payment_Type__c= '1000' OR Payment_Type__c ='1001' OR Payment_Type__c='1002') 
                                    AND Is_Payment_Reversed__c = False 
                                    GROUP BY CCS_Account__C];
        
        for(AggregateResult aggr : prodPayment){
            productSumTotal.put((String)aggr.get('ccsAcc'), aggr);
        }
        Map<String, AggregateResult> productTotal = new Map<String, AggregateResult>();
        
        AggregateResult[] prodPayData = [SELECT CCS_Account__c ccsAcc, Min(Payment_Created__c) firstPaymentDate, 
                                    Max(Payment_Created__c) lastPaymentDate 
                                    from product_payments__C 
                                    where CCS_Account__c IN :productID 
                                    AND (RecordTYpe.Name = 'Distressed Product Payment') 
                                    AND (Payment_Type__c= '1000' OR Payment_Type__c ='1001' OR Payment_Type__c='1002') 
                                    AND Is_Payment_Reversed__c = False
                                    group by CCS_Account__c];
        
        for(AggregateResult aggr : prodPayData){
            productTotal.put((String)aggr.get('ccsAcc'), aggr);
        }
        
        String currencyTypeCode = '                 ';
        String finalHeadBody2 = ''; 
        String finalK1HeadBody2 = ''; 
        
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        String maxRowslength = metro2TransUnion.MaxRowsCount__c;
        String canaFinGrp = metro2TransUnion.Canaccede_Financial_Group__c;
        String TransUnionIdentifier = metro2TransUnion.bureauIdentifier__c;
        String headerCust = metro2TransUnion.HEADER__c;
        String CA = metro2TransUnion.CA__c;
        String ZAP = metro2TransUnion.ZAP__c;
        String identificationNumber = metro2TransUnion.Identification_Number__c;
        String accountType = metro2TransUnion.Account_Type__c;
        String reporterAddress = metro2TransUnion.Reporter_Address__c;
        String reporterPhone = metro2TransUnion.Reporter_Phone__c;
        String portfolioType = metro2TransUnion.Portfolio_Type__c;
        String termsDuration = metro2TransUnion.Terms_Duration__c;
        
        // Code for Date of LastmodifiedDate  Right Padding upon dynamic values in less
        String lastModifiedBydate= defLastModifiedBydate;
        lastModifiedBydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY((System.today()).toStartofMonth().addDays(-1));
        
        // Code for Date of CreatedDate  Right Padding upon dynamic values in less
        String createdDate = defCreateddate;
        if(System.today() != null) {
            createdDate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(System.today());
        }
        String bureaIdentifier = defBureauIdentifier;
        if(TransUnionIdentifier != null) {
            if(TransUnionIdentifier.length() < 10) {
                integer num = 10 - TransUnionIdentifier.length();
                Integer num2 = num + TransUnionIdentifier.length();
                bureaIdentifier = TransUnionIdentifier.rightPad(num2);
            } 
            else if(TransUnionIdentifier.length() == 10) {
                bureaIdentifier = TransUnionIdentifier;
            }
        }
        
        String idenfificationNum = defIdentificationNumber;
        if(identificationNumber != null) {
            if(identificationNumber.length() < 20) {
                integer num = 20 - identificationNumber.length();
                Integer num2 = num + identificationNumber.length();
                idenfificationNum = identificationNumber.rightPad(num2);
            } 
            else if(identificationNumber.length() == 20) {
                idenfificationNum = identificationNumber;
            }
        }        
        String canaccedeFinGrp = defCanaFinGrp;
        if(canaFinGrp != null) {
            if(canaFinGrp.length() < 40) {
                integer num = 40 - canaFinGrp.length();
                Integer num2 = num + canaFinGrp.length();
                canaccedeFinGrp = canaFinGrp.rightPad(num2);
            } 
            else if(canaFinGrp.length() == 40) {
                canaccedeFinGrp = canaFinGrp;
            }
        }
        
        String repAddress = defReportAddress;
        if(reporterAddress != null) {
            if(reporterAddress.length() < 96) {
                integer num = 96 - reporterAddress.length();
                Integer num2 = num + reporterAddress.length();
                repAddress = reporterAddress.rightPad(num2);
            } 
            else if(reporterAddress.length() == 96) {
                repAddress = reporterAddress;
            }
        }

        String repPhone = defReportTelPhoneNum;
        if(reporterPhone != null) {
            if(reporterPhone.length() < 10) {
                integer num = 10 - reporterPhone.length();
                Integer num2 = num + reporterPhone.length();
                repPhone = reporterPhone.rightPad(num2);
            } 
            else if(reporterPhone.length() == 10) {
                repPhone = reporterPhone;
            }
        }

        // Code to generate Header record
        string headbody = maxRowslength + headerCust + '                           ' + bureaIdentifier + lastModifiedBydate + createdDate + '       ' + '         ' + canaccedeFinGrp + repAddress + repPhone;
        
        Integer countheader = 460 - headbody.length();
        Integer countheader2 = countheader + headbody.length();
        integer [] trimmedArray2 = new integer [countheader];
        
        for (integer i = 0; i < countheader; i ++)
            trimmedArray2[i] = 160;
        
        Metro__c metroheaderrecsetiing  = Metro__c.getInstance('Header');

        if(metroheaderrecsetiing.HeaderCheck__c == false) {
            MetroFlatFileData__c metroobj24 = new MetroFlatFileData__c();
            metroobj24.RowData1__c = headbody + String.fromCharArray(trimmedArray2);
            metroobj24.HeaderCheck__c = true;
            metroobj24.Bureau_Type__c = bureauTypeTransUnion;
            metroobj24.Product_Type__c = productType;
            metroobj24.Sort_Order__c = 1;
            insert metroobj24;
            metroheaderrecsetiing.HeaderCheck__c = true;
            Update metroheaderrecsetiing;
        }
        
        Integer Stringcount = headbody.length();
        String headbodyfinal = Stringcount + headbody;
        
        // List created to bulk insert the metro2 data. 
        List<MetroFlatFileData__c> metroFileData = new List<MetroFlatFileData__c>();
        List<MetroFlatFileData__c> metroFileDataK1Seg = new List<MetroFlatFileData__c>();
        
        for(Product__c prodct :scope) {
            if(!mapProductExcluse.containsKey(prodct.id)){
                
            MetroFlatFileData__c metroobj2 = new MetroFlatFileData__c();
            
            // Code for Adding Date Opened Right Padding upon dynamic values in less
            String Dateopened = defDateOpened;
            if(prodct.Purchase_Date__c != null) {
                Dateopened = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Purchase_Date__c);
                metroobj2.Open_Date__c = Dateopened;
            }
            
            // Code for Adding Accname Right Padding upon dynamic values in less
            String productname = defProductName;
            if(prodct.Previous_Primary_Account_Number__c.length() < 30) {
                integer num = 30 - prodct.Previous_Primary_Account_Number__c.length();
                Integer num2 = num + prodct.Previous_Primary_Account_Number__c.length();
                productname = prodct.Previous_Primary_Account_Number__c.rightPad(num2);
            } 
            else if(prodct.Previous_Primary_Account_Number__c.length() == 30) {
                productname = prodct.Previous_Primary_Account_Number__c;
            }
            
            // Code for Adding Original_Balance__c Left Padding upon dynamic values in less
            String orignalCreditAmt = defOrignalCreditAmt;
            /*if(String.valueOf(prodct.Original_Balance__c) != null) {
                //Code to prevent negative values. if value is negative show 0's
                if(prodct.Original_Balance__c >= 0){
                    orignalCreditAmt  =  String.valueOf(prodct.Original_Balance__c.setScale(0)).leftPad(9, '0');
    
                }else if(prodct.Original_Balance__c < 0){
                    orignalCreditAmt = defOrignalCreditAmt;
                }
            }*/
            
            // Code for Adding Payment Frequency Right Padding upon dynamic values in less
            String paymentfrequency = defPaymentFrequency;
            //Set payment frquency default D(i.e Deferred)
            paymentfrequency = metro2TransUnion.Payment_Frequency__c;

            // Code for Adding Actual Payment Amount  Right Padding upon dynamic values in less
            String Finalactualpayplan  = defFinalactualpayplan;                       
            //Populate Finalactualpayplan only if last payment date is in month same as Activity date
            if(null != prodct.Last_Payment_Date__c){
                AggregateResult grossPaySum = productSumTotal.get(prodct.id);
                Decimal actualGrossPay = 0.00;
                if(null != grossPaySum){
                    actualGrossPay = (Decimal)grossPaySum.get('grossPay');                 
                    //negative amount to be reported as zero
                    if(actualGrossPay!=null && actualGrossPay > 0){
                        Finalactualpayplan = String.valueOf(actualGrossPay.setScale(0));
                        Finalactualpayplan = Finalactualpayplan.leftPad(9, '0');  
                    }
                }
            }
            
            // Code for Adding current Amount  Right Padding upon dynamic values in less
            String currentplanval = defCurrentPlanval;
            if(prodct.Current_Balance__c != null) {
                //Code to prevent negative values. if value is negative show 0's
                if(prodct.Current_Balance__c >= 0){        
                    currentplanval = String.valueOf(prodct.Current_Balance__c.setScale(0));
                    currentplanval = currentplanval.leftPad(9, '0');
                }
                else if(prodct.Current_Balance__c < 0){
                    currentplanval = defCurrentPlanval;
                }        
            }
            
            // Code for Adding past Amount  Right Padding upon dynamic values in less
            String pastval = defPastVal;
            if(prodct.Current_Balance__c != null) {
                //Code to prevent negative values. if value is negative show 0's
                if(prodct.Current_Balance__c >= 0){        
                    pastval = String.valueOf(prodct.Current_Balance__c.setScale(0));
                    pastval = pastval.leftPad(9, '0');
                }
                else if(prodct.Current_Balance__c < 0){
                    pastval = defPastVal;
                }        
            }
                
            AggregateResult paymentValues = productTotal.get(prodct.id);    
            Date firstPaymentDate = null;    
            if(null != paymentValues){
                firstPaymentDate = (Date)paymentValues.get('firstPaymentDate');
            }
            
            // Code for date closed Right Padding upon dynamic values in less
            /******Need To discuss*****/
            String dateclosed = defDateClosed;             
            if(prodct.Closed_Date__C != null){
                dateclosed = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(date.newinstance(prodct.Closed_Date__C.year(), prodct.Closed_Date__C.month(), prodct.Closed_Date__C.day()));
            }
            
            // Code for date of last payment  Right Padding upon dynamic values in less
            String lastpaymentdate  = defLastPaymentDate;
            if(prodct.Last_Payment_Date__c != null) {
                lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
            }
       
            
            // Code for Adding First_Name__c Right Padding upon dynamic values in less
            String firstname = defFirstName;
            if(prodct.First_Name__c != null) {
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
            // Code for Adding Last_Name__c Right Padding upon dynamic values in less
            String lastname = defLastName;
            if(prodct.Last_Name__c != null) {
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
            String Phonenumber = defphoneNumber;
            if(prodct.Phone_Home__c != null) {
                Boolean checkPhoneValid = CustomerProcessingBatchHelper.getValidPhoneNumber(prodct.Phone_Home__c);
                if(checkPhoneValid == true){
                    String phonenumberNumeric = prodct.Phone_Home__c.replaceAll('[^0-9]', '');
                    if(String.valueOf(phonenumberNumeric).length() < 10) {
                        integer num = 10 - String.valueOf(phonenumberNumeric).length();
                        Integer num2 = num + String.valueOf(phonenumberNumeric).length();
                        Phonenumber = String.valueOf(phonenumberNumeric).rightPad(num2);
                        metroobj2.PhoneNumber__c = Phonenumber ;
                    } 
                    else if(String.valueOf(phonenumberNumeric).length() == 10) {
                        Phonenumber = String.valueOf(phonenumberNumeric);
                        metroobj2.PhoneNumber__c = Phonenumber ;
                    }  
                    metroobj2.PhoneNumberProduct__c = prodct.Phone_Home__c ;
                }              
            }
            
            // Code for Address Line 1 Right Padding upon dynamic values in less
            String AddressLine = defAddressLine;
            if(prodct.Address_Line1__c != null) {
                if(String.valueOf(prodct.Address_Line1__c).length() < 32) {
                    integer num = 32 - String.valueOf(prodct.Address_Line1__c).length();
                    Integer num2 = num + String.valueOf(prodct.Address_Line1__c).length();
                    AddressLine = String.valueOf(prodct.Address_Line1__c).rightPad(num2);
                    AddressLine = AddressLine.toUpperCase();
                } 
                else if(String.valueOf(prodct.Address_Line1__c).length() == 32) {
                    AddressLine = String.valueOf(prodct.Address_Line1__c);
                    AddressLine = AddressLine.toUpperCase();
                }
            }
            
            // Code for Address Line 2 Right Padding upon dynamic values in less
            String AddressLine2 = defAddressLine2;
            if(prodct.Address_Line2__c != null) {
                if(String.valueOf(prodct.Address_Line2__c).length() < 32) {
                    integer num = 32 - String.valueOf(prodct.Address_Line2__c).length();
                    Integer num2 = num + String.valueOf(prodct.Address_Line2__c).length();
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c).rightPad(num2);
                    AddressLine2 = AddressLine2.toUpperCase();
                } 
                else if(String.valueOf(prodct.Address_Line2__c).length() == 32) {
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c);
                    AddressLine2 = AddressLine2.toUpperCase();
                }
            }
            
            // Code for City Right Padding upon dynamic values in less
            String cityaddress = defCityAddress;
            if(prodct.City__c != null) {
                if(String.valueOf(prodct.City__c).length() < 20) {
                    integer num = 20 - String.valueOf(prodct.City__c).length();
                    Integer num2 = num + String.valueOf(prodct.City__c).length();
                    cityaddress = String.valueOf(prodct.City__c).rightPad(num2);
                    cityaddress = cityaddress.toUpperCase();
                } 
                else if(String.valueOf(prodct.City__c).length() == 20) {
                    cityaddress = String.valueOf(prodct.City__c);
                    cityaddress = cityaddress.toUpperCase();
                }
            }
            
            // Code for state Right Padding upon dynamic values in less
            String stateaddress = defStateAddress;
            String provinceCode = prodct.State__c;
            if(provinceCode != null) {
                if(String.valueOf(provinceCode).length() < 2) {
                    integer num = 2 - provinceCode.length();
                    Integer num2 = num + provinceCode.length();
                    stateaddress = provinceCode.rightPad(num2);
                }
                else if(provinceCode.length() == 2) {
                    stateaddress = provinceCode;
                }
            }
            
            String ZipAddres= defZipAddres;
            if(prodct.Zip_Code__c != null) {
                //Code to remove space from Zipcode
                String ZipAddresWithoutSpaces = prodct.Zip_Code__c.replaceAll( '\\s+', '');
                
                if(String.valueOf(ZipAddresWithoutSpaces).length() < 9) {
                    integer num = 9 - String.valueOf(ZipAddresWithoutSpaces).length();
                    Integer num2 = num + String.valueOf(ZipAddresWithoutSpaces).length();
                    ZipAddres = String.valueOf(ZipAddresWithoutSpaces).rightPad(num2); //.rightPad(num2);//chnaged25-03-2020
                } 
                else if(String.valueOf(prodct.Zip_Code__c).length() == 9) {
                    ZipAddres = String.valueOf(ZipAddresWithoutSpaces);
                }
            }
            
            // Set default Account status to 13
            String accountStatus =defAccountStatus;
            if(String.isNotBlank(prodct.Product_Status__c)){
                for(Data_Status_Mapping__c metaData : mapDataStatusMapping.values()){
                    mapDataStatus.put(metaData.name,metaData);
                }
                if(mapDataStatus.containskey(prodct.Product_Status__c))  {
                   if(mapDataStatus.get(prodct.Product_Status__c).Bureau_Reporting_Account_Status__c  == 'Closed'){
                       accountStatus = metro2TransUnion.Account_Status_Close__c; // set account status 13
                   }
                   if(mapDataStatus.get(prodct.Product_Status__c).Bureau_Reporting_Account_Status__c  == 'Open'){
                       accountStatus = metro2TransUnion.Account_Status_Open__c; // set account status 93
                   } 
                   if(mapDataStatus.get(prodct.Product_Status__c).Bureau_Reporting_Account_Status__c  == 'Open Unpaied'){
                       accountStatus = metro2TransUnion.Account_Status_Open_Unpaid__c; // set account status 97
                   }
                 }
            }
            else{
                //set account status to 13
                accountStatus = metro2TransUnion.Account_Status_Close__c;
            }
            
            metroobj2.Status__c = accountStatus;
            
            ////Code for populating Payment history profile for last 24 months
            /*******Need To Discuss***********/
            String paymentHistoryProfile = defNumberOfPayments;
            if(null != firstPaymentDate){
                paymentHistoryProfile = CustomerProcessingBatchHelper.getNumberOfPayments(firstPaymentDate);
            }
            
            //Code for populating Payment rating
            String paymentRating = defPaymentRating;
            //if account status is 13 then set payment rating to G
            if(accountStatus == metro2TransUnion.Account_Status_Close__c){
                paymentRating = 'G';
            }
            
            // Code for Last_Delinquency_Date__c Amount  Right Padding upon dynamic values in less
            String lastdelinquencydate = defLastDelinquencyDate;
            if(prodct.Charged_Off_Date__c != NULL){
            	lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Charged_Off_Date__c);   
            }else{
                lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date_Prior_to_CO__c);   
            }
            
            //set special comments value for records Product_Status__c
            String specialComments = defSpecialComments;
            if(String.isNotBlank(prodct.Product_Status__c)){
                specialComments = CustomerProcessingBatchHelper.getDistressedSpecialComments(prodct.Product_Status__c);
            }
            
            // Code for Charged_Off_Amount__c  Amount  Right Padding upon dynamic values in less
            String chargeffamount = defChargeOffAmount;
            if(null != prodct.Charged_Off_Amount__c){
                chargeffamount = String.valueOf((prodct.Charged_Off_Amount__c).setScale(0));
                chargeffamount = chargeffamount.leftPad(9, '0');
            }
            
            // Set Customer Information Indicator to blank for all Distressed account
            String customerInformationIndicator = '  ';
            
            // Code for Deceased Date
            String deceasedDate  = ' ';
            if(prodct.Deceased_Date__c != null) {
                deceasedDate = 'D';
            }else{
                deceasedDate = '1';
            }
            
            system.debug('K1Segment'+K1Segment);
            //K1 Segment
            String K1SegmentLine = K1Segment;
            String canaccede = '/Canaccede';
            system.debug('K1SegmentLine length'+K1SegmentLine.length());
            if(prodct.Seller__r.name != null) {
                if(String.valueOf(prodct.Seller__r.name).length() < 30) {
                    string sellerName = String.valueOf(prodct.Seller__r.name) + canaccede;
                    system.debug('sellerName length'+sellerName.length());
                    integer number1 = 30 - sellerName.length();
                    Integer number2 = number1 + String.valueOf(prodct.Seller__r.name).length();
                    K1SegmentLine = String.valueOf(prodct.Seller__r.name).rightPad(number2);
                    K1SegmentLine = K1SegmentLine.toUpperCase();
                    //K1SegmentLine = K1SegmentLine + canaccede;
                } 
                else if(String.valueOf(prodct.Seller__r.name).length() == 30) {
                    K1SegmentLine = String.valueOf(prodct.Seller__r.name);
                    K1SegmentLine = K1SegmentLine.toUpperCase();
                }
            }
            system.debug('K1SegmentLine'+K1SegmentLine);
            system.debug('K1SegmentLine length'+K1SegmentLine.length());
            //Body record
            string headbody2 = maxRowslength + '1              0'+idenfificationNum+ '  ' + productname + portfolioType + accountType + Dateopened + '000000000' + orignalCreditAmt + termsDuration + paymentfrequency + '         ' + Finalactualpayplan + accountStatus + paymentRating + paymentHistoryProfile + specialComments + '  ' + currentplanval + pastval + chargeffamount + '        ' + lastdelinquencydate + dateclosed + lastpaymentdate + currencyTypeCode + ' ' + lastname + firstname + middlename + ' ' + SInnumber + Dateofbirth + Phonenumber + deceasedDate + customerInformationIndicator + CA + AddressLine + AddressLine2 + cityaddress + stateaddress + ZipAddres+'  '+'K1'+K1SegmentLine;
            system.debug('heaser@@@'+headbody2);
            system.debug('heaser length'+headbody2.length());
            Integer Stringcount2 = 460 - headbody2.length();
            system.debug('Stringcount2'+Stringcount2);
            Integer Stringcountheadercount = Stringcount2 + headbody2.length();

            finalheadbody2 = finalheadbody2 + headbody2.rightPad(Stringcountheadercount) + '\r\n';

            integer [] trimmedArray = new integer [Stringcount2];
            for (integer i = 0; i < Stringcount2; i ++){
                trimmedArray[i] = 160;
            }
       
            metroobj2.RowData1__c = headbody2 + String.fromCharArray(trimmedArray);
            metroobj2.ProductId__c = prodct.Id;
            metroobj2.Product__c = prodct.id;
            metroobj2.Bureau_Type__c = bureauTypeTransUnion;
            metroobj2.Product_Type__c = productType;
            metroobj2.Sort_Order__c = 2;    
            metroFileData.add(metroobj2);
            
            //increment counter if records to be considered as out of CCS
            if(accountStatus == metro2TransUnion.Account_Status_Close__c){
                if(null == prodct.TransUnion_Reported_As_Complete_Count__c){
                    prodct.TransUnion_Reported_As_Complete_Count__c = 1;
                }
                else{
                    prodct.TransUnion_Reported_As_Complete_Count__c += 1;
                }
                updateProduct.add(prodct);
            }
            
            
            
            /*String K1Segment = 'K1'+K1SegmentLine;
            Integer StringK1count = 34 - K1Segment.length();
            Integer StringK1countheadercount = StringK1count + K1Segment.length();
            
            finalK1HeadBody2 = finalK1HeadBody2 + K1Segment.rightPad(StringK1countheadercount) + '\r\n';
            
            integer [] K1trimmedArray = new integer [StringK1count];
            for (integer i = 0; i < StringK1count; i ++){
                K1trimmedArray[i] = 160;
            }
            
            MetroFlatFileData__c metroFlatData = new MetroFlatFileData__c();
            metroFlatData.RowData1__c = K1Segment + String.fromCharArray(K1trimmedArray);
            metroFlatData.ProductId__c = prodct.Id;
            metroFlatData.Product__c = prodct.id;
            metroFlatData.Bureau_Type__c = bureauTypeTransUnion;
            metroFlatData.Product_Type__c = productType;
            metroFileDataK1Seg.add(metroFlatData);*/
          }// if condition
        }// for loop
        
        insert metroFileData;
        //insert metroFileDataK1Seg;
        
        if(metro2TransUnion.Do_Not_Increase_Count__c == FALSE){
            ProductTriggerHandler.runProductTrigger = false;
            update updateProduct;//to be uncommented before final file generation
            ProductTriggerHandler.runProductTrigger = true;
        }
        
        
    }
    
    // Finish Method to generate TAILER record
    public void finish(Database.BatchableContext BC) {
        
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('CreditBureauTU');
        String maxRowslength = metro2TransUnion.MaxRowsCount__c;
        
        List<MetroFlatFileData__c> metrolstcount = new List<MetroFlatFileData__c>();
        AggregateResult[] metrolstcountData = [Select count(id) metroFlatFileDatacnt FROM MetroFlatFileData__c where HeaderCheck__c = false and FooterCheck__c = false and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY];
        Integer Rowscount = 0;
        system.debug('Rowscount before'+Rowscount);
        for(AggregateResult aggr : metrolstcountData){
            Rowscount = (Integer)aggr.get('metroFlatFileDatacnt');
        }
        system.debug('Rowscount after'+Rowscount);
 		 
        Integer  RowscountLength = String.valueOf(Rowscount).length();
		system.debug('RowscountLength'+RowscountLength);

        String FinalSINCOUNT = '000000000';
        String FinalDOBCOunt = '000000000';
        String FinalPhoneocuntNet = '000000000';
        String FinalSTATUS13COUNT = '000000000';
        String FinalSTATUS93COUNT = '000000000';
        String FinalSTATUS97COUNT = '000000000';
        

        Integer FinalPhoneocunt = [select PhoneNumber__c from MetroFlatFileData__c where PhoneNumber__c != null and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY limit 49000].size();
        FinalPhoneocuntNet = CustomerProcessingBatchHelper.getStringWithZeroPadding(FinalPhoneocunt);
        
        //Final SIN Count
        List<MetroFlatFileData__c> metroobj = new List<MetroFlatFileData__c>();
        Integer SINCOUNT = [select SIN__c from MetroFlatFileData__c where SIN__c != null and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY].size();
        FinalSINCOUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(SINCOUNT);
        
        //DOB Count
        List<MetroFlatFileData__c> metroobj2 = new List<MetroFlatFileData__c>();
        Integer DOBCOUNT = [select Dateofbirth__c from MetroFlatFileData__c where Dateofbirth__c != null and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY limit 49000].size();
        FinalDOBCOunt = CustomerProcessingBatchHelper.getStringWithZeroPadding(DOBCOUNT);
        
        //Status 13 Count
        List<MetroFlatFileData__c> metroobjStatus13 = new List<MetroFlatFileData__c>();
        Integer STATUS13COUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = '13' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY limit 49000].size();
        FinalSTATUS13COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS13COUNT);
        
        //Status 93 Count
        List<MetroFlatFileData__c> metroobjStatus93 = new List<MetroFlatFileData__c>();
        Integer STATUS93COUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = '93' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY limit 49000].size();
        FinalSTATUS93COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS93COUNT);
        
        //Status 97 Count
        List<MetroFlatFileData__c> metroobjStatus97 = new List<MetroFlatFileData__c>();
        Integer STATUS97COUNT = [select Status__c from MetroFlatFileData__c where Status__c != null and Status__c = '97' and Bureau_Type__c =: bureauTypeTransUnion and Product_Type__c =: productType and createddate = TODAY limit 49000].size();
        FinalSTATUS97COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS97COUNT);
        
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
        
  
        String Trailerrec = maxRowslength+'TRAILER' + rowscountwithzero + '                  000000000000000000000000000000000000000000000000000000' + FinalSTATUS13COUNT + '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000' + FinalSTATUS93COUNT + '000000000' + '000000000' + '000000000' + FinalSTATUS97COUNT + '000000000000000000'+ rowscountwithzero +'000000000000000000000000000000000000' + FinalSINCOUNT + FinalSINCOUNT + '000000000000000000' + FinalDOBCOunt + FinalDOBCOunt + '000000000000000000' + FinalPhoneocuntNet + '    ';
        
  
        Integer Stringcount4 = 426 - Trailerrec.length();
        integer Trailheadcoutfinal = Stringcount4 + Trailerrec.length();
    
        String finaltrairec = Trailerrec.rightPad(Trailheadcoutfinal);
  
        Integer Trailcount2 = 460 - Trailerrec.length();
        integer [] trimmedArray = new integer [Trailcount2];
        for (integer i = 0; i < Trailcount2; i ++){
            trimmedArray[i] = 160;   
        }
        MetroFlatFileData__c metroobj4 = new MetroFlatFileData__c();
        metroobj4.RowData1__c = Trailerrec + String.fromCharArray(trimmedArray);
        metroobj4.FooterCheck__c = true;
        metroobj4.Bureau_Type__c = bureauTypeTransUnion;
        metroobj4.Product_Type__c = productType;
        metroobj4.Sort_Order__c = 3;  
        insert metroobj4;
        
        Metro__c metroheaderrec = Metro__c.getInstance('Header');
        metroheaderrec.HeaderCheck__c = false;
        update metroheaderrec;
        System.enqueueJob(new CreditBureauRepTUTextFileGeneration());
    }
}