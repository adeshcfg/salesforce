/***************************************************
 * Author         : A5E Consultancy
 * Created On     : 20 March 2020
 * Description    : Generate Metro File Data from Product__c records for TransUnion
 *
 ***************************************************/

public class CustomerProcessingBatchTU implements Database.Batchable<sobject> {
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
    public static final String defLastPaymentDate = '00000000';
    public static final String defFirstName = '                         ';
    public static final String defLastName = '                    ';
    public static final String defMiddleName = '                    ';
    public static final String defSinNumber = '000000000';
    public static final String defDateOfbirth = '00000000';
    public static final String defPhoneNumber = '0000000000';
    public static final String defNumberOfPayments = 'BBBBBBBBBBBBBBBBBBBBBBBB';
    public static final String defAddressLine = '                                ';
    public static final String defAddressLine2 = '                                ';
    public static final String defCityAddress = '                    ';
    public static final String defStateAddress = '  ';
    public static final String defZipAddres = '         ';
    public static final String defAccountStatus = '';
    public static final String defPaymentRating = ' ';
    public static final String defSpecialComments = ' ';
    public static final String defCustomerInformationIndicator = '  ';
    public static final String bureauTypeTransUnion = 'TransUnion';
    public static final String productType = 'CCS Account';
    public string batchNumber = string.valueOf(DateTime.now());

    //To-do - in future to add constructor and change accordingly in the strart method SOQL Query
    /*
    String transURecordType;
    public CustomerProcessingBatchTU(String fileRecordType){
        This.transURecordType = fileRecordType;
    }
    */

    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        //List<String> recNames = new List<String>();
        //recNames.add('CCS Account');
        //recNames.add('Distressed Account');

        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('TransUnion');
        Integer noOfTimesToReport = Integer.valueOf(metro2TransUnion.Number_of_Times_To_Report__c);

        //Query to fetch all the eligible records with the recordtype as CCS Account
        return Database.getQueryLocator(
            'SELECT Id, Name,RecordType.Name,Open_Date_TU__c, Closed_Date__C, Createddate,LastModifieddate,Original_Balance__c, Original_Credit_Amount__c,Payment_Frequency__c,Monthly_Payment_Amount__c,FairShare_Percentage__c,Last_Payment_Amount__c,Current_Balance__c,Past_Due_Amount__c,Last_Delinquency_Date__c,CCS_Stage_Last_Changed__c,Last_Payment_Date__c,Last_Name__c,First_Name__c,Middle_Name__c,SIN__c,Phone_Home__c,Date_of_Birth__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Provinces__c,Zip_Code__c, CCS_Stage__c, Purchase_Date__c, Charged_Off_Amount__c, Original_Date_of_Delinquency__c, TransUnion_Reported_As_Complete_Count__c FROM Product__c ' +
                'WHERE ' +
                'RecordType.Name =: productType AND ' +
                'CCS_Stage__c != \'Putback\' AND CCS_Stage__c != \'Buyback\' AND ' +
                'CCS_Stage__c != \'Putback / Buyback Pending\' AND ' +
                'Last_Name__c != null AND ' +
                'First_Name__c != null AND ' +
                'Name !=null AND ' +
                'Open_Date_TU__c != null AND ' +
                'Payment_Frequency__c != null AND ' +
                'Monthly_Payment_Amount__c != null AND ' +
                'Current_Balance__c != null AND ' +
                'Difference_Greater_Than_N_Years__c = False AND ' +
                'Last_Payment_Date__c <> null AND ' +
                'Suppressed_in_TU__c = False AND ' + //added on 21 Dec 2021
                'Original_Date_of_Delinquency__c <> null AND ' + //added on 21 Dec 2021
                'Investment_Group__c IN (\'BNS CCS 1\', \'BNS CCS 2\') AND ' +
                '(TransUnion_Reported_As_Complete_Count__c = null OR ' +
                'TransUnion_Reported_As_Complete_Count__c <: noOfTimesToReport)'
        );
    }

    //Execute Method
    public void execute(Database.BatchableContext BC, List<Product__c> scope) {
        List<Product__c> updateProduct = new List<Product__c>();

        Datetime prodPaymentDate; // LAST ACTIVITY DATE
        prodPaymentDate = [
            SELECT Id, Payment_Created__c
            FROM Product_Payments__c
            WHERE (RecordTYpe.Name = 'CCS Product Payment' OR RecordTYpe.Name = 'CCS Dividend Payment') AND Payment_Created__c != NULL
            ORDER BY Payment_Created__c DESC
            LIMIT 1
        ]
        .Payment_Created__c;

        List<ID> productID = new List<ID>();
        for (Product__c prodRec : scope) {
            productID.add(prodRec.id);
        }

        Map<String, AggregateResult> productSumTotal = new Map<String, AggregateResult>();

        for (AggregateResult aggr : [
            SELECT CCS_Account__C ccsAcc, sum(gross_Payment_Amount__c) grossPay
            FROM Product_Payments__c
            WHERE
                CCS_Account__C IN :productID
                AND Payment_Created__c = LAST_MONTH
                AND (RecordTYpe.Name = 'CCS Product Payment'
                OR RecordTYpe.Name = 'CCS Dividend Payment')
            GROUP BY CCS_Account__C
        ]) {
            productSumTotal.put((String) aggr.get('ccsAcc'), aggr);
        }
        Map<String, AggregateResult> productTotal = new Map<String, AggregateResult>();

        for (AggregateResult aggr : [
            SELECT
                CCS_Account__c ccsAcc,
                Min(Payment_Created__c) firstPaymentDate,
                Max(Payment_Created__c) lastPaymentDate,
                sum(Gross_Payment_Amount__c) paymentAmount
            FROM product_payments__C
            WHERE CCS_Account__c IN :productID AND (RecordTYpe.Name = 'CCS Product Payment' OR RecordTYpe.Name = 'CCS Dividend Payment')
            GROUP BY CCS_Account__c
        ]) {
            productTotal.put((String) aggr.get('ccsAcc'), aggr);
        }

        //String currencyTypeCode = '                 ';
        String currencyTypeCode = '              124';
        String finalHeadBody2 = '';

        //Metro2 File Custom Setting
        //Metro2_TransUnion__c obj = [select MaxRowsCount__c, Canaccede_Financial_Group__c, TransUnionIdentifier__c, HEADER__c, CA__c, ZAP__c from Metro2_TransUnion__c limit 1];
        Metro2_File__c metro2TransUnion = Metro2_File__c.getValues('TransUnion');
        String maxRowslength = metro2TransUnion.MaxRowsCount__c;
        String canaFinGrp = metro2TransUnion.Canaccede_Financial_Group__c;
        String TransUnionIdentifier = metro2TransUnion.bureauIdentifier__c;
        String headerCust = metro2TransUnion.HEADER__c;
        String CA = metro2TransUnion.CA__c;
        String ZAP = metro2TransUnion.ZAP__c;
        String identificationNumber = metro2TransUnion.Identification_Number__c;
        String accountType = metro2TransUnion.Account_Type__c;

        // Code for Date of LastmodifiedDate  Right Padding upon dynamic values in less
        //String LastModifiedBydate= '00000000';
        String lastModifiedBydate = defLastModifiedBydate;
        if (prodpaymentdate != null) {
            //LastModifiedBydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(date.newinstance(prodpaymentdate.year(), prodpaymentdate.month(), prodpaymentdate.day()));

            LastModifiedBydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY((System.today()).toStartofMonth().addDays(-1));
        }

        // Code for Date of CreatedDate  Right Padding upon dynamic values in less
        //String Createddate = '00000000';
        String createdDate = defCreateddate;
        if (System.today() != null) {
            createdDate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(System.today());
        }

        // Code to generate Header record
        string headbody =
            '0426' +
            headercust +
            '                           ' +
            TransUnionIdentifier +
            '   ' +
            lastModifiedBydate +
            createdDate +
            '       ' +
            '         ' +
            canaFinGrp +
            '              ';

        Integer countheader = 426 - headbody.length();
        Integer countheader2 = countheader + headbody.length();
        integer[] trimmedArray2 = new List<integer>(countheader);

        Metro__c metroheaderrecsetiing = Metro__c.getInstance('Header');

        if (metroheaderrecsetiing.HeaderCheck__c == false) {
            MetroFlatFileData__c metroobj24 = new MetroFlatFileData__c();
            metroobj24.RowData1__c = headbody;
            metroobj24.HeaderCheck__c = true;
            metroobj24.Bureau_Type__c = bureauTypeTransUnion;
            metroobj24.Product_Type__c = productType;
            metroobj24.Batch_Number__c = batchNumber;
            insert metroobj24;
            metroheaderrecsetiing.HeaderCheck__c = true;
            update metroheaderrecsetiing;
        }

        Integer Stringcount = headbody.length();
        String headbodyfinal = Stringcount + headbody;

        // List created to bulk insert the metro2 data.
        List<MetroFlatFileData__c> metroFileData = new List<MetroFlatFileData__c>();

        for (Product__c prodct : scope) {
            MetroFlatFileData__c metroobj2 = new MetroFlatFileData__c();

            // Code for Adding Date Opened Right Padding upon dynamic values in less
            String Dateopened = defDateOpened;
            if (prodct.Open_Date_TU__c != null) {
                Dateopened = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Open_Date_TU__c);
                metroobj2.Open_Date__c = Dateopened;
            }

            // Code for Adding Accname Right Padding upon dynamic values in less
            String productname = defProductName;
            if (prodct.name.length() < 30) {
                integer num = 30 - prodct.name.length();
                Integer num2 = num + prodct.name.length();
                productname = prodct.name.rightPad(num2);
                //productname = productname.toUpperCase();
            } else if (prodct.name.length() == 30) {
                productname = prodct.name;
            }

            // Code for Adding Original_Balance__c Left Padding upon dynamic values in less
            String orignalCreditAmt = defOrignalCreditAmt;
            if (String.valueOf(prodct.Original_Balance__c) != null) {
                //Code to prevent negative values. if value is negative show 0's
                if (prodct.Original_Balance__c >= 0) {
                    orignalCreditAmt = String.valueOf(prodct.Original_Balance__c.setScale(0)).leftPad(9, '0');
                } else if (prodct.Original_Balance__c < 0) {
                    orignalCreditAmt = defOrignalCreditAmt;
                }
            }

            // Code for Adding Payment_Frequency__c Right Padding upon dynamic values in less
            String paymentfrequency = defPaymentFrequency;
            if (String.valueOf(prodct.Payment_Frequency__c) != null) {
                paymentfrequency = CustomerProcessingBatchHelper.getPaymentFrequency(prodct.Payment_Frequency__c.toUpperCase());
            }

            // Code for Adding Actual Payment Amount  Right Padding upon dynamic values in less
            //String Finalactualpayplan  = '         ';
            String Finalactualpayplan = defFinalactualpayplan;
            Decimal fairsharepercentage;
            Decimal actualAmt;
            Decimal lastpayamt;

            if (prodct.Last_Payment_Amount__c != null) {
                lastpayamt = prodct.Last_Payment_Amount__c.setScale(0);
            }

            if (prodct.FairShare_Percentage__c != null) {
                fairsharepercentage = prodct.FairShare_Percentage__c.setScale(0);
            }

            Integer LastMonthValue = ((System.today()).toStartofMonth().addDays(-1)).month();

            //Populate Finalactualpayplan only if last payment date is in month same as Activity date
            Finalactualpayplan = defFinalactualpayplan;
            if (null != prodct.Last_Payment_Date__c) {
                /*Integer lastPaymentMonth = (prodct.Last_Payment_Date__c).month();
                
                if(LastMonthValue == lastPaymentMonth){
                    if(fairsharepercentage != null && lastpayamt != null) {
                        actualAmt = lastpayamt + lastpayamt * fairsharepercentage / 100;
                        
                        if(actualAmt >= 0){
                            Finalactualpayplan = String.valueOf(actualAmt.setScale(0));
                            Finalactualpayplan = Finalactualpayplan.leftPad(9, '0'); 
                        }else if(actualAmt < 0){
                            Finalactualpayplan = defFinalactualpayplan;
                        }
                    }
                }*/

                AggregateResult grossPaySum = productSumTotal.get(prodct.id);
                Decimal actualGrossPay = 0.00;
                if (null != grossPaySum) {
                    actualGrossPay = (Decimal) grossPaySum.get('grossPay');

                    //negative amount to be reported as zero
                    if (actualGrossPay != null && actualGrossPay > 0) {
                        Finalactualpayplan = String.valueOf(actualGrossPay.setScale(0));
                        Finalactualpayplan = Finalactualpayplan.leftPad(9, '0');
                    }
                }
            }

            // Code for Adding current Amount  Right Padding upon dynamic values in less
            String currentplanval = defCurrentPlanval;
            if (prodct.Current_Balance__c != null) {
                //Code to prevent negative values. if value is negative show 0's
                if (prodct.Current_Balance__c >= 0) {
                    currentplanval = String.valueOf(prodct.Current_Balance__c.setScale(0));
                    currentplanval = currentplanval.leftPad(9, '0'); //changed 25-03-2020
                } else if (prodct.Current_Balance__c < 0) {
                    currentplanval = defCurrentPlanval;
                }
            }

            // Code for Adding past Amount  Right Padding upon dynamic values in less
            String pastval = defPastVal;

            AggregateResult paymentValues = productTotal.get(prodct.id);
            Date firstPaymentDate = null;
            Date lastPaymentDateValue = null;
            Decimal paymentAmount = 0.0;
            //for(AggregateResult listAggr : paymentValues){
            if (null != paymentValues) {
                firstPaymentDate = (Date) paymentValues.get('firstPaymentDate');
                lastPaymentDateValue = (Date) paymentValues.get('lastPaymentDate');
                paymentAmount = (Decimal) paymentValues.get('paymentAmount');
            }
            //}

            if (null != paymentValues) {
                Integer noOfMonths = firstPaymentDate.monthsBetween(lastPaymentDateValue);
                Decimal totalPaymentPaid = prodct.Monthly_Payment_Amount__c * noOfMonths;

                if ((totalPaymentPaid - paymentAmount) > 0) {
                    pastval = String.valueOf((totalPaymentPaid - paymentAmount).setScale(0));
                    pastval = pastval.leftPad(9, '0');
                }
            } else {
                // if no payment is made
                if (null != prodct.Purchase_Date__c) {
                    Integer noOfMonths = (prodct.Purchase_Date__c).monthsBetween(system.today()) - 1;
                    Decimal totalPaymentPaid = prodct.Monthly_Payment_Amount__c * noOfMonths;

                    pastval = String.valueOf(totalPaymentPaid.setScale(0));
                    pastval = pastval.leftPad(9, '0');
                }
            }

            /*
            if(prodct.Past_Due_Amount__c != null) {
                if(prodct.Past_Due_Amount__c >= 0){
                    pastval = String.valueOf(prodct.Past_Due_Amount__c.setScale(0));
                    pastval = pastval.leftPad(9, '0');
                }
                else if(prodct.Past_Due_Amount__c < 0){
                    pastval = defPastVal;
                }   
            } 
            */
            /*
            if(prodct.Last_Delinquency_Date__c != null) {
                lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Delinquency_Date__c);
            }
            */

            // Code for date closed Right Padding upon dynamic values in less
            String dateclosed = defDateClosed;
            if (prodct.CCS_Stage__C == 'Completed / Paid in Full' || prodct.CCS_Stage__C == 'Settled') {
                /*if(prodct.CCS_Stage_Last_Changed__c != null) {
                    dateclosed = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(date.newinstance(prodct.CCS_Stage_Last_Changed__c.year(), prodct.CCS_Stage_Last_Changed__c.month(), prodct.CCS_Stage_Last_Changed__c.day()));
                }else if(prodct.Last_Payment_Date__c != null){
                    dateclosed = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(date.newinstance(prodct.Last_Payment_Date__c.year(), prodct.Last_Payment_Date__c.month(), prodct.Last_Payment_Date__c.day()));
                }*/

                if (prodct.Closed_Date__C != null) {
                    dateclosed = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(
                        date.newinstance(prodct.Closed_Date__C.year(), prodct.Closed_Date__C.month(), prodct.Closed_Date__C.day())
                    );
                }
            }

            // Code for date of last payment  Right Padding upon dynamic values in less
            String lastpaymentdate = defLastPaymentDate;
            if (prodct.Last_Payment_Date__c != null) {
                lastpaymentdate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Last_Payment_Date__c);
            }

            // Code for Adding First_Name__c Right Padding upon dynamic values in less
            String firstname = defFirstName;
            if (prodct.First_Name__c != null) {
                if (prodct.First_Name__c.length() <= 20) {
                    String firstNameValue = prodct.First_Name__c; //.replace(' ','-');
                    firstname = firstNameValue.rightPad(20);
                    firstname = firstname.toUpperCase();
                } else if (prodct.First_Name__c.length() > 20) {
                    firstname = prodct.First_Name__c; //.replace(' ','-');
                    firstname = firstname.left(20);
                    firstname = firstname.toUpperCase();
                }
            }

            // Code for Adding Last_Name__c Right Padding upon dynamic values in less
            String lastname = defLastName;
            if (prodct.Last_Name__c != null) {
                if (prodct.Last_Name__c.length() <= 25) {
                    String lastNameValue = prodct.Last_Name__c; //.replace(' ','-');
                    lastname = lastNameValue.rightPad(25);
                    lastname = lastname.toUpperCase();
                } else if (prodct.Last_Name__c.length() > 25) {
                    lastname = prodct.Last_Name__c; //.replace(' ','-');
                    lastname = lastname.left(25);
                    lastname = lastname.toUpperCase();
                }
            }

            // Code for Adding Middle_Name__c Right Padding upon dynamic values in less
            String middlename = defMiddleName;
            if (prodct.Middle_Name__c != null) {
                if (prodct.Middle_Name__c.length() <= 20) {
                    String middleNameValue = prodct.Middle_Name__c; //.replace(' ','-');
                    middlename = middleNameValue.rightPad(20);
                    middlename = middlename.toUpperCase();
                } else if (prodct.Middle_Name__c.length() > 20) {
                    middlename = prodct.Middle_Name__c; //.replace(' ','-');
                    middlename = middlename.left(20);
                    middlename = middlename.toUpperCase();
                }
            }

            // Code for Adding SIN__c Right Padding upon dynamic values in less
            String SinNumber = defSinNumber;
            if (prodct.SIN__c != null && prodct.SIN__c.length() == 9) {
                metroobj2.SIN__c = prodct.SIN__c;
                SinNumber = prodct.SIN__c;
            }

            // Code for Date of Birth Amount  Right Padding upon dynamic values in less
            String Dateofbirth = defDateOfbirth;
            if (prodct.Date_of_Birth__c != null) {
                Dateofbirth = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Date_of_Birth__c);
                metroobj2.Dateofbirth__c = Dateofbirth;
            }

            // Code for Phone Number  Right Padding upon dynamic values in less
            String Phonenumber = defphoneNumber;
            if (prodct.Phone_Home__c != null) {
                String phonenumberNumeric = prodct.Phone_Home__c.replaceAll('[^0-9]', '');

                if (String.valueOf(phonenumberNumeric).length() < 10) {
                    integer num = 10 - String.valueOf(phonenumberNumeric).length();
                    Integer num2 = num + String.valueOf(phonenumberNumeric).length();
                    Phonenumber = String.valueOf(phonenumberNumeric).rightPad(num2);
                    //totalphonelst.add(phonenumberNumeric);
                    metroobj2.PhoneNumber__c = Phonenumber;
                } else if (String.valueOf(phonenumberNumeric).length() == 10) {
                    Phonenumber = String.valueOf(phonenumberNumeric);
                    //totalphonelst.add(phonenumberNumeric);
                    metroobj2.PhoneNumber__c = Phonenumber;
                }
                metroobj2.PhoneNumberProduct__c = prodct.Phone_Home__c;
            }

            // Code for Address Line 1 Right Padding upon dynamic values in less
            String AddressLine = defAddressLine;
            if (prodct.Address_Line1__c != null) {
                if (String.valueOf(prodct.Address_Line1__c).length() < 32) {
                    integer num = 32 - String.valueOf(prodct.Address_Line1__c).length();
                    Integer num2 = num + String.valueOf(prodct.Address_Line1__c).length();
                    AddressLine = String.valueOf(prodct.Address_Line1__c).rightPad(num2);
                    AddressLine = AddressLine.toUpperCase();
                } else if (String.valueOf(prodct.Address_Line1__c).length() == 32) {
                    AddressLine = String.valueOf(prodct.Address_Line1__c);
                    AddressLine = AddressLine.toUpperCase();
                }
            }

            // Code for Address Line 2 Right Padding upon dynamic values in less
            String AddressLine2 = defAddressLine2;
            if (prodct.Address_Line2__c != null) {
                if (String.valueOf(prodct.Address_Line2__c).length() < 32) {
                    integer num = 32 - String.valueOf(prodct.Address_Line2__c).length();
                    Integer num2 = num + String.valueOf(prodct.Address_Line2__c).length();
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c).rightPad(num2);
                    AddressLine2 = AddressLine2.toUpperCase();
                } else if (String.valueOf(prodct.Address_Line2__c).length() == 32) {
                    AddressLine2 = String.valueOf(prodct.Address_Line2__c);
                    AddressLine2 = AddressLine2.toUpperCase();
                }
            }

            // Code for City Right Padding upon dynamic values in less
            String cityaddress = defCityAddress;
            if (prodct.City__c != null) {
                if (String.valueOf(prodct.City__c).length() < 20) {
                    integer num = 20 - String.valueOf(prodct.City__c).length();
                    Integer num2 = num + String.valueOf(prodct.City__c).length();
                    cityaddress = String.valueOf(prodct.City__c).rightPad(num2);
                    cityaddress = cityaddress.toUpperCase();
                } else if (String.valueOf(prodct.City__c).length() == 20) {
                    cityaddress = String.valueOf(prodct.City__c);
                    cityaddress = cityaddress.toUpperCase();
                }
            }

            // Code for state Right Padding upon dynamic values in less
            String stateaddress = defStateAddress;
            String provinceCode = CustomerProcessingBatchHelper.getProvinceCode(prodct.Provinces__c);
            if (provinceCode != null) {
                if (String.valueOf(provinceCode).length() < 2) {
                    integer num = 2 - provinceCode.length();
                    Integer num2 = num + provinceCode.length();
                    stateaddress = provinceCode.rightPad(num2);
                    //stateaddress = stateaddress.toUpperCase();
                } else if (provinceCode.length() == 2) {
                    stateaddress = provinceCode;
                    //stateaddress = stateaddress.toUpperCase();
                }
            }

            // Code for Zip Right Padding upon dynamic values in less
            /*String ZipAddres= defZipAddres;
            if(prodct.Zip_Code__c != null) {
                if(String.valueOf(prodct.Zip_Code__c).length() < 9) {
                    integer num = 9 - String.valueOf(prodct.Zip_Code__c).length();
                    Integer num2 = num + String.valueOf(prodct.Zip_Code__c).length();
                    ZipAddres = String.valueOf(prodct.Zip_Code__c).rightPad(num2);//chnaged25-03-2020
                } 
                else if(String.valueOf(prodct.Zip_Code__c).length() == 9) {
                    ZipAddres = String.valueOf(prodct.Zip_Code__c);
                }
            }*/

            String ZipAddres = defZipAddres;
            if (prodct.Zip_Code__c != null) {
                //Code to remove space from Zipcode
                String ZipAddresWithoutSpaces = prodct.Zip_Code__c.replaceAll('\\s+', '');

                if (String.valueOf(ZipAddresWithoutSpaces).length() < 9) {
                    integer num = 9 - String.valueOf(ZipAddresWithoutSpaces).length();
                    Integer num2 = num + String.valueOf(ZipAddresWithoutSpaces).length();
                    ZipAddres = String.valueOf(ZipAddresWithoutSpaces); //.rightPad(num2);//chnaged25-03-2020
                } else if (String.valueOf(prodct.Zip_Code__c).length() == 9) {
                    ZipAddres = String.valueOf(ZipAddresWithoutSpaces);
                }
            }

            // Set default Account status to ZA
            String accountStatus = defAccountStatus;
            if (String.isNotBlank(prodct.CCS_Stage__c)) {
                accountStatus = CustomerProcessingBatchHelper.getAccountStatus(prodct.CCS_Stage__c.toUpperCase());
                //metro2reco.Staus = accountStatus; //Need to update this
                if (String.isBlank(accountStatus)) {
                    accountStatus = 'ZA';
                }
                metroobj2.Status__c = accountStatus;
            } else {
                accountStatus = 'ZA';
            }

            ////Code for populating Payment history profile for last 24 months
            String paymentHistoryProfile = defNumberOfPayments;
            if (null != firstPaymentDate) {
                paymentHistoryProfile = CustomerProcessingBatchHelper.getNumberOfPayments(firstPaymentDate);
            }

            //Code for populating Payment rating field-21/10/2020
            String paymentRating = defPaymentRating;
            if (accountStatus == '13') {
                paymentRating = 'Y';
                currentplanval = defCurrentPlanval;
            }

            // Code for Last_Delinquency_Date__c Amount  Right Padding upon dynamic values in less
            String lastdelinquencydate = defLastDelinquencyDate;
            //if(accountStatus != '13'){ //populate the delinquency date on the all records
            //Only populate the deliquency date when record is not with status 13 and when original delinquency date is populated - 21st Dec 2021
            lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Original_Date_of_Delinquency__c);

            /*if(null != prodct.Original_Date_of_Delinquency__c){
                    lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY(prodct.Original_Date_of_Delinquency__c);
                }else if(null != prodct.Last_Payment_Date__c){
                    if((prodct.Last_Payment_Date__c).addDays(120) < system.today()){
                        lastdelinquencydate = CustomerProcessingBatchHelper.formatDate_MM_DD_YYYY((prodct.Last_Payment_Date__c).addDays(30));
                    }
                }*/
            //}

            //set special comments value for records
            String specialComments = defSpecialComments;
            if (String.isNotBlank(prodct.CCS_Stage__c)) {
                specialComments = CustomerProcessingBatchHelper.getSpecialComments(prodct.CCS_Stage__c.toUpperCase());
                if (String.isBlank(accountStatus)) {
                    specialComments = 'B ';
                }
            } else {
                specialComments = 'B ';
            }

            // Code for Original_Credit_Amount__c  Amount  Right Padding upon dynamic values in less
            String chargeffamount = defChargeOffAmount;
            if (accountStatus == '97' && null != prodct.Charged_Off_Amount__c) {
                chargeffamount = String.valueOf((prodct.Charged_Off_Amount__c).setScale(0));
                chargeffamount = chargeffamount.leftPad(9, '0');
            }

            // Set Customer Information Indicator to 'D' for all CCS account
            String customerInformationIndicator = 'D ';
            /*
            if(String.isNotBlank(prodct.CCS_Stage__c)){
                //customerInformationIndicator = CustomerProcessingBatchHelper.getcustomerInformationIndicator(prodct.CCS_Stage__c.toUpperCase());
                
            }
            */

            //Past Due Amount
            if (accountStatus == '13') {
                pastval = defPastVal;
            }

            // Code for Adding Monthly_Payment_Amount__c Right Padding upon dynamic values in less
            String monthpayplan = defMonthPayPlan;
            if (accountStatus == '13') {
                //Scheduled Payment Amount to be set to default when status is 13.- 21st Dec 2021
                monthpayplan = defMonthPayPlan;
            } else if (prodct.Monthly_Payment_Amount__c != null) {
                decimal monthlyplandec = prodct.Monthly_Payment_Amount__c.setScale(0);

                if (monthlyplandec >= 0) {
                    monthpayplan = CustomerProcessingBatchHelper.getCalculatedPaymentAmount(paymentfrequency, monthlyplandec);
                    monthpayplan = monthpayplan.leftPad(9, '0');
                } else if (monthlyplandec < 0) {
                    monthpayplan = defMonthPayPlan;
                }
            }

            //Past Due Amount when Account Status is 97
            if (accountStatus == '97') {
                if (prodct.Current_Balance__c == null || prodct.Current_Balance__c <= 0) {
                    pastval = defPastVal;
                } else {
                    pastval = String.valueOf(prodct.Current_Balance__c.setScale(0));
                    pastval = pastval.leftPad(9, '0');
                }
            }

            //Body record
            string headbody2 =
                '0426' +
                '1              0' +
                identificationNumber +
                '          ' +
                '  ' +
                productname +
                'I' +
                accountType +
                Dateopened +
                '         ' +
                orignalCreditAmt +
                '   ' +
                paymentfrequency +
                monthpayplan +
                Finalactualpayplan +
                accountStatus +
                paymentRating +
                paymentHistoryProfile +
                specialComments +
                '  ' +
                currentplanval +
                pastval +
                chargeffamount +
                '        ' +
                lastdelinquencydate +
                dateclosed +
                lastpaymentdate +
                CurrencyTypeCode +
                ' ' +
                lastname +
                firstname +
                middlename +
                ' ' +
                SInnumber +
                Dateofbirth +
                Phonenumber +
                '1' +
                customerInformationIndicator +
                CA +
                AddressLine +
                AddressLine2 +
                cityaddress +
                stateaddress +
                ZipAddres;
            Integer Stringcount2 = 426 - headbody2.length();
            Integer Stringcountheadercount = Stringcount2 + headbody2.length();

            finalheadbody2 = finalheadbody2 + headbody2.rightPad(Stringcountheadercount) + '\r\n';

            integer[] trimmedArray = new List<integer>(Stringcount2);

            metroobj2.RowData1__c = headbody2;

            //ProductID
            metroobj2.ProductId__c = prodct.Id;
            metroobj2.Product__c = prodct.id;
            metroobj2.Bureau_Type__c = bureauTypeTransUnion;
            metroobj2.Product_Type__c = productType;
            metroobj2.Batch_Number__c = batchNumber;

            //insert metroobj2;
            metroFileData.add(metroobj2);

            //increment counter if records to be considered as out of CCS
            if (accountStatus <> 'ZA') {
                if (null == prodct.TransUnion_Reported_As_Complete_Count__c) {
                    prodct.TransUnion_Reported_As_Complete_Count__c = 1;
                } else {
                    prodct.TransUnion_Reported_As_Complete_Count__c += 1;
                }

                updateProduct.add(prodct);
            }
        }
        insert metroFileData;

        if (metro2TransUnion.Do_Not_Increase_Count__c == false) {
            update updateProduct; //to be uncommented before final file generation
        }
    }

    // Finish Method to generate TAILER record
    public void finish(Database.BatchableContext BC) {
        List<MetroFlatFileData__c> metrolstcount = new List<MetroFlatFileData__c>();
        metrolstcount = [
            SELECT id
            FROM MetroFlatFileData__c
            WHERE
                HeaderCheck__c = FALSE
                AND FooterCheck__c = FALSE
                AND Bureau_Type__c = :bureauTypeTransUnion
                AND Product_Type__c = :productType
                AND createddate = TODAY
                AND Batch_Number__c = :batchNumber
        ];

        Integer Rowscount = metrolstcount.size();
        Integer RowscountLength = String.valueOf(metrolstcount.size()).length();
        //Integer TooalphoneCount;
        String FinalSINCOUNT = '000000000';
        String FinalDOBCOunt = '000000000';
        String FinalPhoneocuntNet = '000000000';
        String FinalSTATUS13COUNT = '000000000';
        String FinalSTATUS93COUNT = '000000000';
        String FinalSTATUS97COUNT = '000000000';
        String FinalSTATUSZACOUNT = '000000000';

        //Final Phone count
        //FinalPhoneocunt = totalphonelst.size();
        Integer FinalPhoneocunt = [
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
        FinalPhoneocuntNet = CustomerProcessingBatchHelper.getStringWithZeroPadding(FinalPhoneocunt);

        //Final SIN Count
        List<MetroFlatFileData__c> metroobj = new List<MetroFlatFileData__c>();
        metroObj = [
            SELECT SIN__c
            FROM MetroFlatFileData__c
            WHERE
                SIN__c != NULL
                AND Bureau_Type__c = :bureauTypeTransUnion
                AND Product_Type__c = :productType
                AND createddate = TODAY
                AND Batch_Number__c = :batchNumber
        ];

        Integer SINCOUNT = metroObj.size();
        FinalSINCOUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(SINCOUNT);

        //DOB Count
        List<MetroFlatFileData__c> metroobj2 = new List<MetroFlatFileData__c>();
        metroObj2 = [
            SELECT Dateofbirth__c
            FROM MetroFlatFileData__c
            WHERE
                Dateofbirth__c != NULL
                AND Bureau_Type__c = :bureauTypeTransUnion
                AND Product_Type__c = :productType
                AND createddate = TODAY
                AND Batch_Number__c = :batchNumber
            LIMIT 49000
        ];

        Integer DOBCOUNT = metroObj2.size();
        FinalDOBCOunt = CustomerProcessingBatchHelper.getStringWithZeroPadding(DOBCOUNT);

        //Status 13 Count
        List<MetroFlatFileData__c> metroobjStatus13 = new List<MetroFlatFileData__c>();
        metroObjStatus13 = [
            SELECT Status__c
            FROM MetroFlatFileData__c
            WHERE
                Status__c != NULL
                AND Status__c = '13'
                AND Bureau_Type__c = :bureauTypeTransUnion
                AND Product_Type__c = :productType
                AND createddate = TODAY
                AND Batch_Number__c = :batchNumber
            LIMIT 49000
        ];

        Integer STATUS13COUNT = metroObjStatus13.size();
        FinalSTATUS13COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS13COUNT);

        //Status 93 Count
        List<MetroFlatFileData__c> metroobjStatus93 = new List<MetroFlatFileData__c>();
        metroObjStatus93 = [
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
        ];

        Integer STATUS93COUNT = metroObjStatus93.size();
        FinalSTATUS93COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS93COUNT);

        //Status 97 Count
        List<MetroFlatFileData__c> metroobjStatus97 = new List<MetroFlatFileData__c>();
        metroObjStatus97 = [
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
        ];

        Integer STATUS97COUNT = metroObjStatus97.size();
        FinalSTATUS97COUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUS97COUNT);

        //Status ZA Count
        List<MetroFlatFileData__c> metroobjStatusZA = new List<MetroFlatFileData__c>();
        metroObjStatusZA = [
            SELECT Status__c
            FROM MetroFlatFileData__c
            WHERE
                Status__c != NULL
                AND Status__c = 'ZA'
                AND Bureau_Type__c = :bureauTypeTransUnion
                AND Product_Type__c = :productType
                AND createddate = TODAY
                AND Batch_Number__c = :batchNumber
            LIMIT 49000
        ];

        Integer STATUSZACOUNT = metroObjStatusZA.size();
        FinalSTATUSZACOUNT = CustomerProcessingBatchHelper.getStringWithZeroPadding(STATUSZACOUNT);

        String rowscountwithzero;
        if (RowscountLength < 9) {
            rowscountwithzero = String.valueOf(Rowscount).leftPad(9, '0');
        } else if (RowscountLength > 9) {
            rowscountwithzero = '0000000' + String.valueOf(Rowscount);
        } else if (RowscountLength == 9) {
            rowscountwithzero = '00000000' + String.valueOf(Rowscount);
        }

        String Trailerrec =
            '0426TRAILER' +
            rowscountwithzero +
            '                  000000000000000000000000000000000000000000000000000000' +
            FinalSTATUS13COUNT +
            '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000' +
            FinalSTATUS93COUNT +
            '000000000' +
            '000000000' +
            '000000000' +
            FinalSTATUS97COUNT +
            '000000000000000000000000000000000000000000000000000000000000000' +
            FinalSINCOUNT +
            FinalSINCOUNT +
            '000000000000000000' +
            FinalDOBCOunt +
            FinalDOBCOunt +
            '000000000000000000' +
            FinalPhoneocuntNet +
            '    ';

        Integer Stringcount4 = 426 - Trailerrec.length();
        integer Trailheadcoutfinal = Stringcount4 + Trailerrec.length();
        String finaltrairec = Trailerrec.rightPad(Trailheadcoutfinal);
        Integer Trailcount2 = 426 - Trailerrec.length();
        integer[] trimmedArray = new List<integer>(Trailcount2);
        MetroFlatFileData__c metroobj4 = new MetroFlatFileData__c();
        metroobj4.RowData1__c = Trailerrec;
        metroobj4.FooterCheck__c = true;
        metroobj4.Bureau_Type__c = bureauTypeTransUnion;
        metroobj4.Product_Type__c = productType;
        metroObj4.Batch_Number__c = batchNumber;
        insert metroobj4;

        Metro__c metroheaderrec = Metro__c.getInstance('Header');
        metroheaderrec.HeaderCheck__c = false;
        update metroheaderrec;
        // Create and upload csv of the file
        String contentVersionId = CreditBureauRepTUTextFileGeneration.getContentVersion(batchNumber, bureauTypeTransUnion, productType);
        if (String.isNotBlank(contentVersionId)) {
            System.enqueueJob(new CreditBureauRepTUTextFileGeneration(contentVersionId));
        }
    }
}
