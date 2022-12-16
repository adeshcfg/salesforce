/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : Utility class that generates TCI CSV file
 *  @author : A5E Consulting
 *  @date : 08/02/2016   
 
 *************************************************************************************************/
 
Public Class TCIJobUtil{
    
    //public static final String eligibleDecision = 'Completed';
    public static final String eligibleApplicationStatus = 'Completed - Credit Card';
    public static final String eligibleApplnRecordType = 'Fidem Finance MasterCard';
    //public static final String eligibleLoanType = 'Affirm Financial MasterCard';

    public static final string productCCLoanType = 'Fidem Finance MasterCard';
    public static final String applicationArchived = 'Archived';
    
    public static final String noApplicationMessage = 'No Eligible Applications for TCI.';
    public static final String applicationMessageSucess = 'TCI CSV generation job is initiated.';

    //Interest rate Code
    public static final String FIDEM_INTEREST_CODE_HOME_OWNER = '1029'; 
    public static final String FIDEM_INTEREST_CODE_HOME_RENTAL = '1239';
    
    //Third Party Trustee Product Interest rate Code
    public static final String TP_FIDEM_INTEREST_CODE_HOME_OWNER = '2910'; 
    public static final String TP_FIDEM_INTEREST_CODE_HOME_RENTAL = '3410';
    
    //Paperless Statement Values
    public static final String PaperlessStatementYes = 'Y';
    public static final String PaperlessStatementNo = 'N';
    
    public static final String csvHeader = 'ApplicationSourceReceiptDate,OriginalCreditorName,OriginalAccountNumber,PrincipalAmount,InterestAmount,TotalDue,BTAmount,FirstName,LastName,NameSuffix,Address1,Address2,City,State,Zip,HomePhone,SSN,DateOfBirth,MothersMaidenName,EmployerName,EmployerPhone,NearestLivingRelativePhoneNumber,EmailAddress,PrivacyPolicy,AccountID,PricingStrategy,AgencyName,AgencyPhone,CreditLimit,Misc2,Misc5,Misc6,Misc7,Misc8,Misc9,Misc11,Misc12,Estatements\n';
    
    //TCI Job Custom Setting
    public static TCI_Job_Setting__c tciJobCS = TCI_Job_Setting__c.getOrgDefaults();
    
    public List<Application__c> listProceedAppls ;
    public List<Application__c> applicationsList ;
    
    
    //Generate TCI CSV
    public String initiateTCIJob(String jobType){
        
        //Fetch Application records based on Decision and Application Status
        applicationsList = getApplications();
        
        System.debug('applicationsList size :'+applicationsList.size());

        if(applicationsList.size() == 0){        
            return noApplicationMessage;        
        }
        else{
            
            //Delete all existing attchement and create new attchment
            deleteOldTCIRecords();
            
            //Create Product records
            Map<String, Id> prodNameIdMap = createProductRecords(applicationsList);
            
            //Generate TCI CSV File
            String tciCSV = generateTCI(applicationsList, prodNameIdMap);
            
            if(String.isNotBlank(tciCSV)){
                //update Application records with Application status to be Archived
                updateApplications(listProceedAppls);
                createTCIRecord(tciCSV, jobType);
            }
        
            return applicationMessageSucess;
        }
    }
    
    //Utility Method to delete old TCI Records
    public static void deleteOldTCIRecords(){
        
        System.debug('tciJobCS :'+tciJobCS);
        Integer skipDeleteDays = (Integer)tciJobCS.Skip_Delete_Days__c;
        Date skipDate = System.today().addDays(-1*skipDeleteDays );
        System.debug('skipDate :'+skipDate);
        
        delete [Select id from TCI_Job__c where createdDate < :skipDate] ;    
    }
    
    //Fetch Application records based on Decision and Application Status
    public static List<Application__c> getApplications(){
                        
        return [SELECT Id, Name, LastModifiedDate, Application_Date__c, TCI_Creation_Date__c, Customer__c, Customer__r.SF_ID__c, Fidem_Application_Number__c,  
                First_Name__c, Last_Name__c, Salutation__c, Email_Address__c, Birth_Date__c, SIN__c, Mothers_Maiden_Name__c, 
                Permanent_Address_Street_Number__c, Permanent_Address_Street_Name__c, Permanent_Address_Unit_Number__c, 
                Permanent_Address_City__c, Permanent_Address_Province__c,Permanent_Address_PostalCode__c, 
                Permanent_Address_PO_Box__c, Years_At_Permanent_Address__c, Months_At_Permanent_Address__c,                 
                Employer_Name__c, Employer_Phone__c, Employment_Years__c, Employment_Months__c, Gross_Monthly_Income__c, 
                Home_Phone__c, Work_Phone__c, Cell_Phone__c, 
                Loan_Type__c, Credit_Score__c, Max_Credit_Card_Allowed_Amount__c, Lender_Approved_Amount__c, Requested_Credit_Limit__c, DSR_Score__c, 
                Interest_Rate__c, Interest_Rate_Code__c,  Decision_Timestamp__c, Paperless_Statement__c //Completed_CreditCard_DateTime__c  
                From Application__c  
                WHERE Application_Status__c=:eligibleApplicationStatus 
                //AND Decision__c=:eligibleDecision 
                AND RecordType.name=:eligibleApplnRecordType 
                AND TCI_Creation_Date__c = null
                //AND Loan_Type__c=:eligibleLoanType
                //AND Completed_CreditCard_DateTime__c=YESTERDAY
                ];                    
    }
    
    //Create new Product records
    public Map<String, Id> createProductRecords(List<Application__c> applications){
        
        //Static Values
        String ccSourceSystem = 'FDR';
        Id ccRecordTypeId = Utilities.getProductRecordType(ccSourceSystem);
        Date tomorrowDt = System.Today().addDays(1);
        Integer prinNumber = 200;
        String cardActivatedValue = 'Not Activated: New Issue';
        
        Map<String, Id> prodNameIdMap = new Map<String, Id>();
        
        List<Product__c> ccProducts = new List<Product__c>();
        for (Application__c app : applications){
            Product__c ccProduct = new Product__c();
            
            //Name and Record Type
            ccProduct.name = app.name;
            ccProduct.recordTypeId = ccRecordTypeId;
            
            //Application reference
            //ccProduct.Application_ID__c = app.Fidem_Application_Number__c;
            ccProduct.Application_ID__c = app.Name;
            ccProduct.Application__c = app.Id;  
            
            //Applicant Information
            ccProduct.Customer__c = app.Customer__c;
            ccProduct.First_Name__c = app.First_Name__c;
            ccProduct.Last_Name__c = app.Last_Name__c;
            ccProduct.Date_of_Birth__c = app.Birth_Date__c;
            
            //Applicant Address Information
            ccProduct.Address_Line1__c = addressLineOne(app);
            ccProduct.Address_Line2__c = addressLineTwo(app);
            
            ccProduct.City__c = app.Permanent_Address_City__c;
            ccProduct.Zip_Code__c = app.Permanent_Address_PostalCode__c;
            //ccProduct.State__c = app.Permanent_Address_Province__c;
            
            //Applicant Contact Information
            ccProduct.Phone_Home__c = app.Home_Phone__c;
            ccProduct.Phone_Work__c = app.Work_Phone__c;
            ccProduct.Phone_Other__c = app.Cell_Phone__c;
            
            ccProduct.Source_System__c = ccSourceSystem;
            ccProduct.Loan_Type__c = productCCLoanType; 
            
            //Interest 
            ccProduct.Interest_Rate_Code__c = app.Interest_Rate_Code__c;
            ccProduct.Interest_Rate__c = app.Interest_Rate__c;
            ccProduct.Credit_Limit__c = app.Lender_Approved_Amount__c;
            ccProduct.Original_Credit_Amount__c = app.Lender_Approved_Amount__c;
            
            ccProduct.Mother_Maiden_Name__c = app.Mothers_Maiden_Name__c;
            
            //Misc Values
            ccProduct.PRIN_Number__c = prinNumber;
            ccProduct.Open_Date__c = tomorrowDt;
            ccProduct.Card_Activated__c = cardActivatedValue;
            ccProduct.Current_Balance__c = 0;
            ccProduct.Times_30_Days_Late__c = 0;
            ccProduct.Times_60_Days_Late__c = 0;
            ccProduct.Times_90_Days_Late__c = 0;
            ccProduct.Times_NSF__c = 0;     
            
            //Paperless Statement Information
            ccProduct.Paperless_Statement__c = app.Paperless_Statement__c;
            
            //Fees
            ccProduct.Monthly_Fee_Amount__c = calculateMonthlyFee(app);
            ccProduct.Annual_Fee_Additional_Cardholder__c = calculateAnnualAdditionalFee(app);
            
            ccProducts.add(ccProduct);
        }
        
        if(ccProducts.size() > 0){ 
            ProductTriggerHandler.runProductTrigger = false;
            insert ccProducts;
            ProductTriggerHandler.runProductTrigger = true;
        }
        
        for (Product__c ccProduct : ccProducts){
            System.debug('ccProduct id is :'+ccProduct.Id);
            prodNameIdMap.put(ccProduct.Name, ccProduct.Id);
        }
        
        return prodNameIdMap;
    }
    
    //Create CSV file with header
    public String generateTCI(List<Application__c> applications, Map<String, Id> prodNameIdMap){
        
        String finalStr = '' ;
        
        listProceedAppls = New List<Application__c>();
        
        for(Application__c application : applications){
            
            String recordStr;
            
            System.debug('application.Name  :'+application.Name);
            String prodRecordId = prodNameIdMap.get(application.Name);
            System.debug('generateTCI prodRecordId  :'+prodRecordId);
            
            //First 9 characters of Product record Id
            String prodRecordIdP1 = prodRecordId.substring(0,9);
            
            //Last 9 characters of Product record Id
            String prodRecordIdP2 = prodRecordId.substring(9);
            
            System.debug('prodRecordIdP1    :'+prodRecordIdP1);
            System.debug('prodRecordIdP2    :'+prodRecordIdP2);
             
            try{
                //recordStr = dateTimeToString(application.Completed_CreditCard_DateTime__c) + ',' 
                recordStr = dateTimeToString(application.Decision_Timestamp__c) + ','
                + replaceComma(tciJobCS.Original_Creditor_Name__c) + ',' 
                //Fidem Updates
                //+ OriginalAccountNumberCreate(application.Fidem_Application_Number__c) + ','
                //+ application.Fidem_Application_Number__c + ','
                + application.Name + ','                
                + numberToString((double)tciJobCS.Principal_Amount__c) + ','
                + numberToString((double)tciJobCS.Interest_Amount__c) + ','
                + tciJobCS.Total_Due__c + ','
                + tciJobCS.BT_Amount__c + ','
                + replaceComma(application.First_Name__c) + ','
                + replaceComma(application.Last_Name__c) + ','
                + '' + ',' 
                + replaceComma(addressOne(application)) +','
                + replaceComma(addressTwo(application)) +','
                + replaceComma(application.Permanent_Address_City__c) + ',' 
                + replaceComma(application.Permanent_Address_Province__c) + ','
                + replaceComma(application.Permanent_Address_PostalCode__c) + ','
                + removeAllSpecialChar(application.Home_Phone__c) + ','
                + replaceComma(application.SIN__c) + ','
                + dateToString(application.Birth_Date__c) + ','
                + replaceComma(application.Mothers_Maiden_Name__c) + ','
                + replaceComma(application.Employer_Name__c) + ','
                + removeAllSpecialChar(application.Employer_Phone__c) + ','
                + '' + ','
                + replaceComma(application.Email_Address__c) + ','
                + tciJobCS.Privacy_Policy__c + ','
                //+ accountIDPrefix(application.Fidem_Application_Number__c) + ','
                + accountIDPrefix(application.Name) + ','               
                + pricingStrategyDecide(application.Interest_Rate_Code__c) + ','
                + replaceComma(tciJobCS.Agency_Name__c)+ ','
                + removeAllSpecialChar(tciJobCS.Agency_Phone__c)+ ',' 
                + (nullTozero((Integer)application.Lender_Approved_Amount__c)) + ','
                
                //Misc2
                + replaceComma(application.Credit_Score__c) +','
                
                //Misc5
                + '' + ','
                
                //Misc6
                +application.Customer__r.SF_ID__c + ','
                
                
                //+ (nullTozero((Integer)application.Years_At_Permanent_Address__c)*12 + nullTozero((Integer)application.Months_At_Permanent_Address__c)) + ','
                //Misc7
                + prodRecordIdP1 +','
                
                
                //+ (nullTozero((Integer)application.Employment_Years__c) * 12 + nullTozero((Integer)application.Employment_Months__c)) + ','
                //Misc8
                + prodRecordIdP2 +','
                
                //Misc9
                + nullTozero((Integer)application.Gross_Monthly_Income__c) + ','
                
                //Misc11
                //+ replaceComma(application.Fidem_Application_Number__c) + ','
                + replaceComma(application.Name) + ','
                
                //Misc12
                + nullToDouble((Double)application.DSR_Score__c) + ','
                
                //Paperless Statement Information
                + getPaperlessStatement(application.Paperless_Statement__c)
                + '\n';
                 
                listProceedAppls.add(application);             
             }
             catch(Exception e){
                  recordStr = '';
                  System.debug('Exception caught :'+e);
             }
             
             if(!String.isBlank(recordStr)){
                 finalStr = finalStr + recordStr;
             }
        }
        
        if(!String.isBlank(finalStr)){
            finalStr = csvHeader + finalStr;            
        }
        
        return finalStr;
    }
    
    //Create TCI JOb Record
    public void createTCIRecord(String tciCSV, String jobType){
        
        //TCI Record
        TCI_Job__c tciJobRecord = new TCI_Job__c();
        tciJobRecord.Last_Job_Run_Date__c = system.now();
        tciJobRecord.Last_Job_Run_By__c = UserInfo.getUserId(); 
        tciJobRecord.Email_Address_to_Notify__c = UserInfo.getUserEmail();
        tciJobRecord.Application_Archived__c = listProceedAppls.size();
        tciJobRecord.Total_Applications__c = applicationsList.size();
        tciJobRecord.Job_Type__c = jobType;
        insert tciJobRecord;
        
        //TCI Attachment
        Attachment tciAttch = new Attachment();
        tciAttch.Body = Blob.valueOf(tciCSV);
        tciAttch.Name = jobType + '-TCI-CSV-' + convertDateToString(system.today()) + '.csv';
        tciAttch.ParentId = tciJobRecord.ID ;
        insert tciAttch;
        
        /*
        //ContentVersion Creation
        ContentVersion tcicnvr = new ContentVersion(); 
        tcicnvr.VersionData = Blob.valueOf(tciCSV);
        tcicnvr.Title = jobType + '-TCI-CSV-' + convertDateToString(system.today()) + '.csv';
        tcicnvr.PathOnClient = 'Test';
        tcicnvr.ContentLocation = 'S'; 
        insert tcicnvr;
        
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:tcicnvr.Id].ContentDocumentId;
        
        //ContentDocumentLink Creation
        ContentDocumentLink tciAttch = new ContentDocumentLink();
        tciAttch.ContentDocumentId = conDoc;
        tciAttch.LinkedEntityId = tciJobRecord.ID;
        tciAttch.ShareType = 'I'; 
        tciAttch.Visibility = 'AllUsers';
        insert tciAttch;
        */

        tciJobRecord.TCI_CSV_Attachment_ID__c = tciAttch.ID;
        update tciJobRecord;        
    }
        
    //update Application records with Application status to be Archived
    public void updateApplications(List<Application__c> applications){
        
        for(Application__c app :applications ){
            app.TCI_Creation_Date__c = system.now();
            app.Application_Status__c = applicationArchived;
            app.Application_Status_Last_Changed_Date__c = system.now();
        }
        
        if(applications.size()>0){
            ApplicationTriggerHandler.runApplicationLoadTrigger = false;
            update applications;
            ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        }
    }
       
    //Return address 1 
    private static string addressOne(Application__c application){
        
        if(String.isNotBlank(application.Permanent_Address_PO_Box__c)){
        
            return replaceComma(application.Permanent_Address_PO_Box__c);
            //return (application.Permanent_Address_PO_Box__c);
        }
        else{
        
            return (replaceComma(application.Permanent_Address_Street_Number__c) + ' '+ replaceComma(application.Permanent_Address_Street_Name__c));
            //return (application.Permanent_Address_Street_Number__c+'') + ' '+ replaceComma(application.Permanent_Address_Street_Name__c);
        }
    }
    
    //Return address 2 
    private static string addressTwo(Application__c application){
    
        if(String.isNotBlank(application.Permanent_Address_PO_Box__c)){
        
            return (replaceComma(application.Permanent_Address_Street_Number__c) + ' '+ replaceComma(application.Permanent_Address_Street_Name__c) +' '+ (replaceComma(application.Permanent_Address_Unit_Number__c)));
            //return (application.Permanent_Address_Street_Number__c+'') + ' '+ replaceComma(application.Permanent_Address_Street_Name__c) +' '+ (replaceComma(application.Permanent_Address_Unit_Number__c));
        }
        else{
        
            return (application.Permanent_Address_Unit_Number__c);
        }
    }
    
    //Return address line 1 
    private static string addressLineOne(Application__c application){
        
        String unitNumber  = replaceNullWithBlank(application.Permanent_Address_Unit_Number__c);
        String streetNumber  = replaceNullWithBlank(application.Permanent_Address_Street_Number__c);
        String streetName  = replaceNullWithBlank(application.Permanent_Address_Street_Name__c);
        
        if(String.isNotBlank(unitNumber)){        
            return (unitNumber+'-'+streetNumber+' '+streetName);
        }
        else{        
            return (streetNumber+' '+streetName);
        }
        
    }
    
    //Return address line 2 
    private static string addressLineTwo(Application__c application){
    
        if(String.isNotBlank(application.Permanent_Address_PO_Box__c)){
            return (application.Permanent_Address_PO_Box__c);
        }
        else{        
            return '';
        }
    }
    
    //Calculate Monthly Fee
    private static Decimal calculateMonthlyFee(Application__c application){
        
        String interestRateCode = application.Interest_Rate_Code__c;
        
        if(String.isNotBlank(interestRateCode)){
            if(interestRateCode.equalsIgnoreCase('OTB7') || interestRateCode.equalsIgnoreCase('OTB8')){
                return 144.00;
            }           
            else if(interestRateCode.equalsIgnoreCase('OTB5') 
                    || interestRateCode.equalsIgnoreCase('OTB6')
                    || interestRateCode.equalsIgnoreCase(TP_FIDEM_INTEREST_CODE_HOME_OWNER) 
                    || interestRateCode.equalsIgnoreCase(TP_FIDEM_INTEREST_CODE_HOME_RENTAL)){
                return 120.00;
            }
            else if(interestRateCode.equalsIgnoreCase('OTB1') 
                || interestRateCode.equalsIgnoreCase('OTB2') 
                || interestRateCode.equalsIgnoreCase('OTB3') 
                || interestRateCode.equalsIgnoreCase('OTB4') 
                || interestRateCode.equalsIgnoreCase(FIDEM_INTEREST_CODE_HOME_OWNER)
                || interestRateCode.equalsIgnoreCase(FIDEM_INTEREST_CODE_HOME_RENTAL) 
                || interestRateCode.equalsIgnoreCase('A1B2') 
                || interestRateCode.equalsIgnoreCase('AFB2') 
                || interestRateCode.equalsIgnoreCase('CCCS')
                ){
                return 108.00;
            }
        }
        
        return null;
    }
    
    //Calculate Annual Additional Fee
    private static Decimal calculateAnnualAdditionalFee(Application__c application){
        
        String interestRateCode = application.Interest_Rate_Code__c;
        
        if(String.isNotBlank(interestRateCode)){
            if(interestRateCode.equalsIgnoreCase('OTB1') 
                || interestRateCode.equalsIgnoreCase('OTB2') 
                || interestRateCode.equalsIgnoreCase('OTB3') 
                || interestRateCode.equalsIgnoreCase('OTB4') 
                || interestRateCode.equalsIgnoreCase('OTB5') 
                || interestRateCode.equalsIgnoreCase('OTB6')
                || interestRateCode.equalsIgnoreCase('OTB7')
                || interestRateCode.equalsIgnoreCase('OTB8')
                || interestRateCode.equalsIgnoreCase('A1B2')
                || interestRateCode.equalsIgnoreCase('AFB2') 
                || interestRateCode.equalsIgnoreCase('CCCS')
                || interestRateCode.equalsIgnoreCase(FIDEM_INTEREST_CODE_HOME_OWNER) 
                || interestRateCode.equalsIgnoreCase(FIDEM_INTEREST_CODE_HOME_RENTAL)
                || interestRateCode.equalsIgnoreCase(TP_FIDEM_INTEREST_CODE_HOME_OWNER)
                || interestRateCode.equalsIgnoreCase(TP_FIDEM_INTEREST_CODE_HOME_RENTAL)
                ){
                return 20.00;
            }
        }
        
        return null;
    }
    
    //Remove All Special Character from String
    private static String removeAllSpecialChar(String str){
        
        if(String.isBlank(str)){
            return '';    
        }
        else{
            
            Pattern pt = Pattern.compile('[^a-zA-Z0-9]');
            Matcher match = pt.matcher(str);
            while(match.find()){
                String s = match.group();
                str = str.replaceAll('\\'+s, '');
            }
            return str;
        }
    }
    
    //Remove Special Character except Space from String 
    private static String removeSpecialCharExceptSpace(String str){
        
        if(String.isBlank(str)){
            return '';    
        }
        else{
            
            Pattern pt = Pattern.compile('[^a-zA-Z0-9\\s]');
            Matcher match = pt.matcher(str);
            while(match.find()){
                String s = match.group();
                str = str.replaceAll('\\'+s, '');
            }
            return str;
        }
    }

    /*
    private static String formatPhone(String phn){
        
        if(String.isBlank(phn)){
            return '';
        }else{
            phn = phn.replace('(','').replace(')','').replace('+','').replace('-','').replaceAll(' ','');
            return phn;
        }
    }
    */
    
    /*
    private static String originalAccountNumberCreate(String applnNo){
    
        //Fidem_Application_Number__c
        if(String.isBlank(applnNo)){
            return '';
        }
        else{
            String[] arrTest = applnNo.split('FDM');
            return tciJobCS.Original_Account_Number_Prefix__c+' FDM '+arrTest[1];
        }
    }
    */
    
    //This method return Fidem_Application_Number__c with prefix 'PeoplesCA' that is AccountID
    private static String accountIDPrefix(String accID){
    
        if(String.isBlank(accID)){
            return '';
        }
        else{
            return tciJobCS.Account_ID_Prefix__c + accID;
        }
    }
    
    //String return based on Interest_Rate_Code__c (OTB1 ,OTB2 ,OTB3)
    private static String pricingStrategyDecide(String ps){
        
        if(String.isBlank(ps)){
            return tciJobCS.Pricing_Strategy_Default__c;
        }
        else if(ps.EqualsIgnoreCase(FIDEM_INTEREST_CODE_HOME_OWNER)
                || ps.EqualsIgnoreCase(FIDEM_INTEREST_CODE_HOME_RENTAL) 
                || ps.EqualsIgnoreCase(TP_FIDEM_INTEREST_CODE_HOME_OWNER)  
                || ps.EqualsIgnoreCase(TP_FIDEM_INTEREST_CODE_HOME_RENTAL) 
                || ps.EqualsIgnoreCase('OTB1')  
                || ps.EqualsIgnoreCase('OTB2') 
                || ps.EqualsIgnoreCase('OTB3')  
                || ps.EqualsIgnoreCase('OTB4')  
                || ps.EqualsIgnoreCase('OTB5')   
                || ps.EqualsIgnoreCase('OTB7')             
                ){
            return ps;
        }
        else{
            return tciJobCS.Pricing_Strategy_Default__c;
        }
    }
    
    //Convert Null to Zero
    private static Integer nullTozero(Integer intg){
        
        if(intg == null ){
            return 0;
        }
        else{
            return intg;
        }
    }
    
    //Convert Null to Double
    private static Double nullToDouble(Double db)
    {
        if(db==null){
            return 0;
        }
        else{
            return db;
        }
    }
    
    //Convert Number to String
    private static String numberToString(Double db){
        
        if(db==null){
            return '';
        }
        else{
            return String.valueof(db);
        }
    }
    
    //Convert date into mm/dd/yyyy
    private static String dateTimeToString(DateTime dt){

        if(dt !=null){
            System.debug('Date: '+dt.format('MM/dd/yyyy'));
            return dt.format('MM/dd/yyyy');
        }
        else{
            return '';
        }    
    }
    
    //Convert date into mm/dd/yyyy
    private static String dateToString(Date dt){

        if(dt !=null){
            return (dt.month()+'/'+dt.day()+'/'+dt.year());
        }
        else{
            return '';
        }    
    }
    
    //replace comma from the String
    private static String replaceComma(String str){
    
        if(str != null){
            return (str.replaceAll(',',' '));
        }
        else{
            return '';
        }
    } 
    
    //Replace null with blank
    private static String replaceNullWithBlank(String str){
    
        if(str != null){
            return str;
        }
        else{
            return '';
        }
    }
    
    //Convert Date to String
    private static String convertDateToString(Date dt){
        return String.valueof(date.newinstance(dt.year(), dT.month(), dT.day()));
    }
    
    //To Capture paperless statement  value as Y or N
    private static String getPaperlessStatement(boolean statementvalue){
        if(statementvalue){
            return PaperlessStatementYes;
        }
        else{
            return PaperlessStatementNo;
        }
    }
}