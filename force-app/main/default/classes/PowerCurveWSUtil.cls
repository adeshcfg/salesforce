public with sharing class PowerCurveWSUtil {
    
    
    private static Map<String, string> decisionResultDecisionMap = new Map<String, string>();
    private static Map<String, string> decisionApplicationStatusMap = new Map<String, string>();
    
    static{
        createDecisionResultDecisionMap();
        createDecisionApplicationStatusMap();
    }

    // Default error message
    private static final String UNEXP_ERROR_MESSAGE = 'An unexpected error has occurred';
    
    // Authentication-related constants
    private static final String INCOMPLETE = 'Incomplete';
    private static final String PASSED = 'Passed';
    private static final String FAILED = 'Failed';
    private static final String DECLINED = 'Declined';
    private static final String DECLINED_AMOUNT = 'DeclinedAmount';
    private static final String ACCEPTED = 'Accepted/Started';
    private static final String COMPLETED = 'Completed';
    private static final String ERROR = 'Error';
    private static final String EMAIL_EXPIRED_AUTH_STATUS = 'Expired';
    private static final String EMAIL_SENT_AUTH_STATUS = 'EmailSent';
    
    //Email Authentication updates - PassedNoFraud
    private static final String PASSED_NO_FRAUD = 'PassedNoFraud';
    
    
    // HTTP constants
    private static final Integer MAX_TIMEOUT = 120000;
    private static final Integer MIN_TIMEOUT = 1;
    
    // Constants indicating SalesForce internal flow, or external
    public enum Channel { SFInternal, SFExternal }
        
    // Encapsulates PowerCurve decision response
    public class DecisionResponse {
        public String errorMessage {get;set;}
        public String customerRequestId {get;set;}
        public String decision {get;set;}
        public String applicationStatus {get;set;}
        public DateTime decisionTimestamp {get;set;}
        public Decimal maxCreditCardAllowedAmount {get;set;}
        public Decimal totalCreditWorthiness {get;set;}
        public String fraudAlert {get;set;}
        public String applicantType {get;set;}
        
        //PCOD Decision
        public String decisionResult {get;set;}
        public String decisionStatus {get;set;}
        
        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        //public Decimal monthlyHousingExpense {get;set;}
        public Decimal monthlyHousingCost {get;set;}
        public Decimal monthlyExpenses {get;set;}
        public Decimal grossMonthlyIncome {get;set;}
        public String creditScore {get;set;}
        public Decimal dsrScore {get;set;}
        public String scorecardProgram {get;set;}   
        
        //Notes
        public String decisionSummary {get;set;}  
        
        //Added more fields for Redecide
        public String firstName {get;set;}
        public String middleName {get;set;}
        public String lastName {get;set;}
        public String preferredLanguage {get;set;}
        public String sin {get;set;}
        public String email {get;set;}
        public Date dateOfBirth {get;set;}
        public Boolean declaredBKCP {get;set;}
        public Decimal requestedCreditLimit {get;set;}
        public String gender {get;set;}
        public String preferredMethod {get;set;}
        public String maritalStatus {get;set;}
        //public String civicNumber {get;set;}
        public String poBox {get;set;}
        public String streetNumber {get;set;}
        public String streetName {get;set;}
        public String suiteNumber {get;set;}
        public String city {get;set;}
        public String provinceCode {get;set;}
        public String postalCode {get;set;}
        public Integer lengthOfResidenceYears {get;set;}
        public Integer lengthOfResidenceMonths {get;set;}
        public String residentialStatus {get;set;}
        public String addressStatus {get;set;}
        public String employerName {get;set;}
        public String employerPhone {get;set;}
        //public String employerAddressLine1 {get;set;}
        //public String employerAddressLine2 {get;set;}
        public String employerPOBox {get;set;}
        public String employerStreetName {get;set;}
        public String employerStreetNumber {get;set;}
        public String employerUnitNumber {get;set;}
        public String employerCity {get;set;}
        public String employerProvinceCode {get;set;}
        public String employerPostalCode {get;set;}
        public Integer employmentYears {get;set;}
        public Integer employmentMonths {get;set;}
        public String incomeInterval {get;set;}
        public String employmentStatus {get;set;}
        public String countryCode {get;set;}
        
        //Credit Bureau Summary
        public Integer accountsOnFile {get;set;}
        public Decimal revolvingDebtUtilization {get;set;}
        public Integer bankruptcies {get;set;}
        public Integer monthSinceBKDischarge {get;set;}
        public Decimal badDebtWriteOff {get;set;}
        public Decimal monthsSinceBadDebtWriteOff {get;set;}
        
        //public Integer lenderApprovedAmount {get;set;}
        public Decimal maxLoanAmount {get;set;}
        
        //Underwriting Rules for 4 Pillars - Updates for Tier Type
        public String appStrategyTier {get;set;}
    }
    
    /**
     *  @description Makes "submit"/"create" requests to PowerCurve; returns
     *  PowerCurve decision
     */
    public static DecisionResponse submit(String personAccSFID, Application__c app, Channel ch) {
        
        Application_Form_Settings__c afSettings = Application_Form_Settings__c.getOrgDefaults();
        String uDecideRequestXML = getUDecideRequestXML(personAccSFID, app, ch, afSettings, false, false);
        String soapEnvelopeXML = getSoapEnvelope(uDecideRequestXML, afSettings);

        // Create the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(afSettings.Power_Curve_Web_Service_URL__c);
        if (afSettings.Request_Timeout__c != null) {
            Integer timeout = Integer.valueOf(afSettings.Request_Timeout__c);
            if (timeout >= MIN_TIMEOUT && timeout <= MAX_TIMEOUT) {
                req.setTimeout(timeout);
            }
        }
        
        // If adding additional headers, update writeErrorRequest method
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction', '');
        
        req.setBody(soapEnvelopeXML);
                
        DecisionResponse decResp = new DecisionResponse();
        HttpResponse resp = null;
        try {
            // Send request
            Http http = new Http();
            resp = http.send(req);
            system.debug('DecisionResponse submit is :'+resp.getBody());
            
            if (resp.getStatusCode() == 200) {
                parseResponse(resp.getBodyDocument(), decResp, true);
            } else {
                decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            }
            
            if (String.isNotBlank(decResp.errorMessage)) {
                API_Error__c apiError = new API_Error__c(
                    Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Create Application'
                );
                apiError.Error__c = decResp.errorMessage;
                writeErrorRequest(apiError, req);
                writeErrorResponse(apiError, resp);
                
                insert apiError;
            }
        } catch (Exception e) {
            decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            
            API_Error__c apiError = new API_Error__c(
                Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Create Application'
            );
            writeErrorRequest(apiError, req);
            if (resp != null) {
                writeErrorResponse(apiError, resp);
            }
            
            apiError.Error__c = 'Exception: ' + e.getTypeName();
            apiError.Error__c += '\nMessage: ' + e.getMessage();
            apiError.Error__c += '\nStack trace:\n' + e.getStackTraceString();
            insert apiError;
        }
        
        return decResp;
    }
    
    
    /**
     *  @description PowerCurve re-submit
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-01-04
     */
    public static DecisionResponse changeQueue(String personAccSFID, Application__c app, Channel ch) {      
        return changeQueue(personAccSFID, app, ch, false);
    }
    
    /**
     *  @description PowerCurve re-submit      
     */
    public static DecisionResponse changeQueue(String personAccSFID, Application__c app, Channel ch, Boolean isRedecideCall) {
        
        System.debug('changeQueue isRedecideCall    :'+isRedecideCall);
        Application_Form_Settings__c afSettings = Application_Form_Settings__c.getOrgDefaults();
        //String uDecideRequestXML = getUDecideQueueRequestXML(personAccSFID, app, ch, afSettings);
        String uDecideRequestXML = getUDecideRequestXML(personAccSFID, app, ch, afSettings, true, isRedecideCall);
        System.debug('uDecideRequestXML :'+uDecideRequestXML);
        
        String soapEnvelopeXML = getSoapEnvelope(uDecideRequestXML, afSettings);
        
        // Create the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(afSettings.Power_Curve_Web_Service_URL__c);
        if (afSettings.Request_Timeout__c != null) {
            Integer timeout = Integer.valueOf(afSettings.Request_Timeout__c);
            if (timeout >= MIN_TIMEOUT && timeout <= MAX_TIMEOUT) {
                req.setTimeout(timeout);
            }
        }
        
        // If adding additional headers, update writeErrorRequest method
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('SOAPAction', '');

        req.setBody(soapEnvelopeXML);
        //System.debug('soapEnvelopeXML  :'+soapEnvelopeXML);
        
        DecisionResponse decResp = new DecisionResponse();
        HttpResponse resp = null;
        try {
            // Send request
            Http http = new Http();
            resp = http.send(req);
            
            system.debug('DecisionResponse changeQueue is :'+resp.getBody());
            
            //System.debug('resp :'+resp);
            
            if (resp.getStatusCode() == 200) {
                if(isRedecideCall == true){
                    System.debug('DecisionResponse changeQueue parseResponseRedecide');
                    //System.debug('resp.getBodyDocument()  :'+resp.getBodyDocument());
                    //System.debug('resp.getBody()  :'+resp.getBody());
                    parseResponseRedecide(resp.getBodyDocument(), decResp, app);
                }
                else{
                    System.debug('DecisionResponse changeQueue parseResponse');
                    parseResponse(resp.getBodyDocument(), decResp, false);                    
                }
                
            } else {
                decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            }
            
            if (String.isNotBlank(decResp.errorMessage)) {
                /*
                API_Error__c apiError = new API_Error__c(
                    Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Resubmit Application'
                );
                */
                API_Error__c apiError;
                if(isRedecideCall == true){
                    apiError = new API_Error__c(
                        Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Redecide Application'
                    );                  
                }
                else{
                    apiError = new API_Error__c(
                        Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Resubmit Application'
                    );                  
                }
                
                apiError.Error__c = decResp.errorMessage;
                writeErrorRequest(apiError, req);
                writeErrorResponse(apiError, resp);
                
                insert apiError;
            }
        } catch (Exception e) {
            decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            /*
            API_Error__c apiError = new API_Error__c(
                Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Resubmit Application'
            );
            */
            API_Error__c apiError;
            if(isRedecideCall == true){
              apiError = new API_Error__c(
                    Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Redecide Application'
                );               
            }
            else{
              apiError = new API_Error__c(
                    Application__c = app.Id, End_Point__c = 'PCoD', Action__c = 'Resubmit Application'
                );              
            }
            
            writeErrorRequest(apiError, req);
            if (resp != null) {
                writeErrorResponse(apiError, resp);
            }
            
            apiError.Error__c = 'Exception: ' + e.getTypeName();
            apiError.Error__c += '\nMessage: ' + e.getMessage();
            apiError.Error__c += '\nStack trace:\n' + e.getStackTraceString();
            insert apiError;
        }
        
        return decResp;
    }
    
    /**
    *   @description Constructs and returns XML for submit or re-submit requests 
    */
    private static String getUDecideRequestXML(String personAccSFID, Application__c app, Channel ch, Application_Form_Settings__c afSettings, Boolean isResubmitRequest, Boolean isRedecideCall) {
        
        System.debug('getUDecideRequestXML isResubmitRequest :'+isResubmitRequest);
        System.debug('getUDecideRequestXML isRedecideCall :'+isRedecideCall);
        
        PowerCurveWS.UDecideRequest_element uDecideRequest = new PowerCurveWS.UDecideRequest_element();
        if (isResubmitRequest == false) {
            uDecideRequest.fieldValues.put('CustomerRequestID', null);
            uDecideRequest.fieldValues.put('RequestType', 'CREATE');
        } else {
            uDecideRequest.fieldValues.put('CustomerRequestID', app.Name);
            
            if(isRedecideCall == true){
                uDecideRequest.fieldValues.put('RequestType', 'REDECIDE');
            }
            else{
                uDecideRequest.fieldValues.put('RequestType', 'RESUBMIT');
            }
        }
        
        uDecideRequest.fieldValues.put('CaseType', '1');
        uDecideRequest.fieldValues.put('Portal', 'STS');
        uDecideRequest.fieldValues.put('UserId', 'sts_user');
        uDecideRequest.fieldValues.put('ApplicationType', '1');
        uDecideRequest.fieldValues.put('SecLenderName', null);
        
        PowerCurveWS.ApplicationHeader appHeader = new PowerCurveWS.ApplicationHeader();
        uDecideRequest.fieldValues.put('ApplicationHeader', appHeader);

        appHeader.fieldValues.put('SourceLenderID', 'AFI');        
        appHeader.fieldValues.put('SourceAppID', personAccSFID);
        
        appHeader.fieldValues.put('LenderDealerID', String.isNotBlank(app.Offer_Code_Origination_System_Id__c) ? app.Offer_Code_Origination_System_Id__c : afSettings.No_Offer_Code__c);
        appHeader.fieldValues.put('RequestDate', formatDate(Date.today()));
        
        if (isResubmitRequest == false) {
            appHeader.fieldValues.put('AppStateType', 'newapplication');
        } else {
            appHeader.fieldValues.put('AppStateType', 'oldapplication');
        }

        appHeader.fieldValues.put('DealerId', '8072');
        appHeader.fieldValues.put('DealerName', 'Affirm Financial');

        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        appHeader.fieldValues.put('ProgramId', app.Program_Id__c);
        appHeader.fieldValues.put('ProgramName',app.Program_Name__c);
        appHeader.fieldValues.put('ProgramTierId', app.Program_Tier_Id__c);
        appHeader.fieldValues.put('ProgramTierName',app.Program_Product_Tier_Name__c);
        appHeader.fieldValues.put('ProgramProductId', app.Program_Product_Id__c);
        appHeader.fieldValues.put('ProgramProductName',app.Program_Product_Name__c);
        
        if (ch != null && ch == Channel.SFInternal) {
            appHeader.fieldValues.put('SalesChannelId', app.Sales_Channel_Id__c);
            appHeader.fieldValues.put('SalesChannelName', app.Sales_Channel_Name__c);
        } else {
            appHeader.fieldValues.put('SalesChannelId', app.Sales_Channel_Id__c);
            appHeader.fieldValues.put('SalesChannelName', app.Sales_Channel_Name__c);
        }      
        
        appHeader.fieldValues.put('SalesChannelEnforceRelationship', 'false');
        
        if (isResubmitRequest == true) {
            
            //Updated by A5E Consulting
            //Email Authentication
            if(isRedecideCall == true){
                appHeader.fieldValues.put('Note', 'SF status update.');
            }
            else{
                if (app.Authentication_Result__c == PASSED || app.Authentication_Result__c == PASSED_NO_FRAUD) {
                    if (app.Fraud_Alert__c == 'TRUE') {
                        appHeader.fieldValues.put('Note', 'Authentication passed, but fraud alert(s) found.');
                    } else {
                        appHeader.fieldValues.put('Note', 'Authentication passed.');
                    }
                } 
                else if (app.Authentication_Result__c == FAILED) {
                    appHeader.fieldValues.put('Note', 'Authentication failed.');
                } 
                else if (app.Authentication_Result__c == INCOMPLETE) {
                  
                    if (app.Authentication_Choice__c == DECLINED) {
                        appHeader.fieldValues.put('Note', 'Customer has chosen not to self-authenticate.');
                    } 
                    else if (app.Authentication_Choice__c == ERROR) {
                        appHeader.fieldValues.put('Note', 'Unable to connect to TU.');
                    } 
                    //Error message changes
                    //Added by A5E Consulting
                    //Start
                    else if (app.Authentication_Choice__c == TransUnionWSUtil.AUTH_CHOICE_NO_BUREAU_HIT) {
                        appHeader.fieldValues.put('Note', 'Authentication Incomplete - No bureau hit');
                    }
                    else if (app.Authentication_Choice__c == TransUnionWSUtil.AUTH_CHOICE_THIN_BUREAU_HIT) {
                        appHeader.fieldValues.put('Note', 'Authentication Incomplete - Not enough data on bureau');
                    }
                    else if (app.Authentication_Choice__c == TransUnionWSUtil.AUTH_CHOICE_TOO_MANY_ATTEMPTS) {
                        appHeader.fieldValues.put('Note', 'Authentication Incomplete - Too many attempts within time range');
                    }
                    //else if (app.Authentication_Choice__c == TransUnionWSUtil.AUTH_CHOICE_SUBMITTED_EXAM_AGAIN) {
                    //    appHeader.fieldValues.put('Note', 'Unable to connect to TU.');
                    //}
                    else if (app.Authentication_Choice__c == TransUnionWSUtil.AUTH_CHOICE_TECHNICAL_ISSUE) {
                        appHeader.fieldValues.put('Note', 'Authentication Incomplete - A system error occurred');
                    }
                    //End
                    
                    
                    else {
                        appHeader.fieldValues.put('Note', 'Authentication is incomplete.');
                    }
                    
                    
                }
                else if (app.Authentication_Result__c == DECLINED_AMOUNT) {
                    appHeader.fieldValues.put('Note', 'Customer did not accept proposed amount on credit card.');
                }  
                
                //Added by A5E Consulting
                //Email Authentication changes            
                else if (app.Authentication_Result__c == EMAIL_EXPIRED_AUTH_STATUS) {
                    appHeader.fieldValues.put('Note', 'Application expired due to no activity for '+afSettings.Application_Expiry_Days__c+' days.');
                }
                else if (app.Authentication_Result__c == EMAIL_SENT_AUTH_STATUS) {
                    appHeader.fieldValues.put('Note', 'Email Authentication sent');
                }               
            }        
        }

        PowerCurveWS.CreditBureauData cbData = new PowerCurveWS.CreditBureauData();
        uDecideRequest.fieldValues.put('CreditBureauData', cbData);

        PowerCurveWS.Common common = new PowerCurveWS.Common();
        cbData.fieldValues.put('Common', common);

        PowerCurveWS.Consumer consumer = new PowerCurveWS.Consumer();
        common.fieldValues.put('Consumer', consumer);

        PowerCurveWS.Subjects_element subjects = new PowerCurveWS.Subjects_element();
        consumer.fieldValues.put('Subjects', subjects);

        PowerCurveWS.ConsumerSubject subject = new PowerCurveWS.ConsumerSubject();
        subjects.fieldValues.put('Subject', subject);

        subject.fieldValues.put('Id', '0');
        subject.fieldValues.put('Type', 'Primary Applicant');
        
        if (String.isNotBlank(app.SIN__c)) {
            subject.fieldValues.put('PrimaryIdType', 'SIN');
            subject.fieldValues.put('PrimaryIdValue', formatSIN(app));
        }
        subject.fieldValues.put('Gender', getGender(app));
        subject.fieldValues.put('Salutation', app.Salutation__c);
        subject.fieldValues.put('FirstName', app.First_Name__c);
        subject.fieldValues.put('MiddleName', app.Middle_Name__c);
        subject.fieldValues.put('LastName', app.Last_Name__c);
        subject.fieldValues.put('Age', getAge(app));
        subject.fieldValues.put('BirthDate', formatDate(app.Birth_Date__c));
        subject.fieldValues.put('MaritalStatus', app.Marital_Status__c);
        subject.fieldValues.put('EducationLevel', getCurrentBKCP(app));
        
        String appStrtTierStr = getTierTypeForRefCode(app.Referral_Id__c);
        
        if (isResubmitRequest == true) {
            
            // Populate maiden name and authentication status
            subject.fieldValues.put('MotherFullname', app.Mothers_Maiden_Name__c);

			/*
            PowerCurveWS.DynamicFields_element dynamicFields = new PowerCurveWS.DynamicFields_element();
            subject.fieldValues.put('DynamicFields', dynamicFields);
    
            PowerCurveWS.Field field = new PowerCurveWS.Field();
            dynamicFields.fieldValues.put('Field', field);
    
            //Updated by A5E Consulting
            //Email Authentication
            if(isRedecideCall == true){
                //DO Nothing
                field.fieldValues.put('Name', 'FinalStatus');
                if(String.isNotBlank(app.Final_Status__c)){
                    field.fieldValues.put('Value', app.Final_Status__c);
                }
                else{
                    field.fieldValues.put('Value', null);   
                }
            }
            else{
                field.fieldValues.put('Name', 'AuthenticationStatus');
                field.fieldValues.put('Value', app.Authentication_Result__c);
            }
            
            //Underwriting Rules for 4 Pillars - Updates for Tier Type
            PowerCurveWS.Field fieldST = new PowerCurveWS.Field();
            dynamicFields.fieldValues.put('Field', fieldST);
            fieldST.fieldValues.put('Name', 'AppStrategyTier');
            fieldST.fieldValues.put('Value', appStrtTierStr);
            */
            
            PowerCurveWS.DynamicFields_element dynamicFields = new PowerCurveWS.DynamicFields_element();
            subject.fieldValues.put('DynamicFields', dynamicFields);
            
            List<PowerCurveWS.Field> fieldList = new List<PowerCurveWS.Field>();
            dynamicFields.fieldValues.put('Field', fieldList);
            PowerCurveWS.Field field;
            
            if(isRedecideCall == true){
            	field = new PowerCurveWS.Field();
            	fieldList.add(field);
                field.fieldValues.put('Name', 'FinalStatus');
                if(String.isNotBlank(app.Final_Status__c)){
                    field.fieldValues.put('Value', app.Final_Status__c);
                }
                else{
                    field.fieldValues.put('Value', null);   
                }
            }
            else{
            	field = new PowerCurveWS.Field();
            	fieldList.add(field);
                field.fieldValues.put('Name', 'AuthenticationStatus');
                field.fieldValues.put('Value', app.Authentication_Result__c);
            }
            
            //Underwriting Rules for 4 Pillars - Updates for Tier Type
            field = new PowerCurveWS.Field();
            fieldList.add(field);
            field.fieldValues.put('Name', 'AppStrategyTier');
            field.fieldValues.put('Value', appStrtTierStr);
            
        }
        
        //Underwriting Rules for 4 Pillars - Updates for Tier Type
        if(isResubmitRequest == false && isRedecideCall == false){
            
            PowerCurveWS.DynamicFields_element dynamicFields = new PowerCurveWS.DynamicFields_element();
            subject.fieldValues.put('DynamicFields', dynamicFields);
    
            PowerCurveWS.Field field = new PowerCurveWS.Field();
            dynamicFields.fieldValues.put('Field', field);
            
            field.fieldValues.put('Name', 'AppStrategyTier');
            field.fieldValues.put('Value', appStrtTierStr);
        }
        
        
        //Address
        PowerCurveWS.Addresses_element addresses = new PowerCurveWS.Addresses_element();
        subject.fieldValues.put('Addresses', addresses);

        List<PowerCurveWS.XMLComplexType> addressList = new List<PowerCurveWS.XMLComplexType>();
        addresses.fieldValues.put('Address', addressList);

        PowerCurveWS.Address permanentAddress = new PowerCurveWS.Address();
        addressList.add(permanentAddress);

        permanentAddress.fieldValues.put('CaseCreditApplicantAddressId', '0');
        
        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        permanentAddress.fieldValues.put('AddressType', app.Permanent_Address_Type__c);        
        
        permanentAddress.fieldValues.put('SuiteNumber', app.Permanent_Address_Unit_Number__c);
        
        permanentAddress.fieldValues.put('CivicNumber', app.Permanent_Address_Street_Number__c);
        //permanentAddress.fieldValues.put('CivicNumber', getCivicNumber(app.Permanent_Address_PO_Box__c, app.Permanent_Address_Street_Number__c));
        
        //permanentAddress.fieldValues.put('StreetName', app.Permanent_Address_Street_Name__c);
        permanentAddress.fieldValues.put('StreetName', getStreetName(app.Permanent_Address_PO_Box__c, app.Permanent_Address_Street_Name__c));
        
        permanentAddress.fieldValues.put('City', app.Permanent_Address_City__c);
        permanentAddress.fieldValues.put('ProvinceCode', app.Permanent_Address_Province__c);
        permanentAddress.fieldValues.put('PostalCode', formatPostalCode(app.Permanent_Address_PostalCode__c));
        permanentAddress.fieldValues.put('CountryCode', 'CA');
        
        //Fix for batch error
        if(app.Years_At_Permanent_Address__c != null){
          permanentAddress.fieldValues.put('LengthOfResidenceYears', app.Years_At_Permanent_Address__c.intValue());
        }        
        if(app.Months_At_Permanent_Address__c != null){
          permanentAddress.fieldValues.put('LengthOfResidenceMonths', app.Months_At_Permanent_Address__c.intValue());
        }        
        
        permanentAddress.fieldValues.put('ResidentialStatus', app.Home_Owner__c);
        permanentAddress.fieldValues.put('MonthlyPayment', app.Housing_Costs__c);
        permanentAddress.fieldValues.put('Status', 'Current');
        
        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        permanentAddress.fieldValues.put('Type', app.Permanent_Address_Type__c);

        if (String.isNotBlank(app.Previous_Address_City__c)) {
            PowerCurveWS.Address previousAddress = new PowerCurveWS.Address();
            addressList.add(previousAddress);
    
            previousAddress.fieldValues.put('CaseCreditApplicantAddressId', '1');
            
            //Updated By A5E Consulting 
            //Appilcation Workflow and Data Sync
            previousAddress.fieldValues.put('AddressType', app.Previous_Address_Type__c);
            
            previousAddress.fieldValues.put('SuiteNumber', app.Previous_Address_Unit_Number__c);
            
            previousAddress.fieldValues.put('CivicNumber', app.Previous_Address_Street_Number__c);
            //previousAddress.fieldValues.put('CivicNumber', getCivicNumber(app.Previous_Address_PO_Box__c, app.Previous_Address_Street_Number__c));
            
            //previousAddress.fieldValues.put('StreetName', app.Previous_Address_Street_Name__c);
            previousAddress.fieldValues.put('StreetName', getStreetName(app.Previous_Address_PO_Box__c, app.Previous_Address_Street_Name__c));
            
            
            previousAddress.fieldValues.put('City', app.Previous_Address_City__c);
            previousAddress.fieldValues.put('ProvinceCode', app.Previous_Address_Province__c);
            previousAddress.fieldValues.put('PostalCode', formatPostalCode(app.Previous_Address_PostalCode__c));
            previousAddress.fieldValues.put('CountryCode', 'CA');
            
            //Fix for batch error
            if(app.Years_At_Previous_Address__c != null){
              previousAddress.fieldValues.put('LengthOfResidenceYears', app.Years_At_Previous_Address__c.intValue());
            }
            if(app.Months_At_Previous_Address__c != null){
              previousAddress.fieldValues.put('LengthOfResidenceMonths', app.Months_At_Previous_Address__c.intValue());
            }
            
            previousAddress.fieldValues.put('Status', 'Previous');
            
            //Updated By A5E Consulting 
            //Appilcation Workflow and Data Sync
            previousAddress.fieldValues.put('Type', app.Previous_Address_Type__c);            
        }
        
        // ContactInfo
        PowerCurveWS.ContactInfo contactInfo = new PowerCurveWS.ContactInfo();
        subject.fieldValues.put('ContactInfo', contactInfo);
        
        contactInfo.fieldValues.put('HomePhone', formatPhone(app.Home_Phone__c));
        contactInfo.fieldValues.put('CellPhone', formatPhone(app.Cell_Phone__c));
        contactInfo.fieldValues.put('WorkPhone', formatPhone(app.Work_Phone__c));
        contactInfo.fieldValues.put('Email', app.Email_Address__c);
        contactInfo.fieldValues.put('PreferredMethod', app.Communications_Preference__c);

        // Employment
        PowerCurveWS.Employments_element employments = new PowerCurveWS.Employments_element();
        subject.fieldValues.put('Employments', employments);

        List<PowerCurveWS.XMLComplexType> employmentList = new List<PowerCurveWS.XMLComplexType>();
        employments.fieldValues.put('Employment', employmentList);

        PowerCurveWS.Employment employment = new PowerCurveWS.Employment();
        employmentList.add(employment);
        
        employment.fieldValues.put('CaseCreditApplicantEmploymentId', '0');
        employment.fieldValues.put('Emp_Status', app.Employment_Status__c);
        employment.fieldValues.put('Emp_Type', null);
        employment.fieldValues.put('Emp_EmployerName', app.Employer_Name__c);
        employment.fieldValues.put('Emp_JobTitle', app.Occupation__c);
        
        //Fix for Batch Error 
        if(app.Employment_Months__c != null){
          employment.fieldValues.put('Emp_Duration_months', app.Employment_Months__c.intValue());
        }
        
        if(app.Employment_Years__c != null){
          employment.fieldValues.put('Emp_Duration_years', app.Employment_Years__c.intValue());
        }
        
        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        employment.fieldValues.put('Emp_IncomeInterval', app.Current_Income_Interval__c);
        
        employment.fieldValues.put('Emp_GrossIncome', app.Gross_Monthly_Income__c);
        
        PowerCurveWS.Address employerAddress = new PowerCurveWS.Address();
        employment.fieldValues.put('Address', employerAddress);

        employerAddress.fieldValues.put('CaseCreditApplicantAddressId', '0');
        employerAddress.fieldValues.put('AddressType', app.Employer_Address_Type__c);
        employerAddress.fieldValues.put('SuiteNumber', app.Employer_Unit_Number__c);
        
        employerAddress.fieldValues.put('CivicNumber', app.Employer_Street_Number__c);
        //employerAddress.fieldValues.put('CivicNumber', getCivicNumber(app.Employer_PO_Box__c, app.Employer_Street_Number__c));
        
        //employerAddress.fieldValues.put('StreetName', app.Employer_Street_Name__c);
        employerAddress.fieldValues.put('StreetName', getStreetName(app.Employer_PO_Box__c, app.Employer_Street_Name__c));
          
        employerAddress.fieldValues.put('City', app.Employer_City__c);
        employerAddress.fieldValues.put('ProvinceCode', app.Employer_Province__c);
        employerAddress.fieldValues.put('PostalCode', formatPostalCode(app.Employer_PostalCode__c));
        employerAddress.fieldValues.put('CountryCode', 'CA');
        employerAddress.fieldValues.put('Status', 'Current');
        employerAddress.fieldValues.put('Type', app.Employer_Address_Type__c);

        employment.fieldValues.put('Emp_PhoneNumber', formatPhone(app.Employer_Phone__c));
        employment.fieldValues.put('Emp_current', 0);
        employment.fieldValues.put('Emp_applicant', 'Primary Applicant');
        
        if (String.isNotBlank(app.Previous_Employer_Name__c)) {
            PowerCurveWS.Employment previousEmployment = new PowerCurveWS.Employment();
            employmentList.add(previousEmployment);
            
            previousEmployment.fieldValues.put('CaseCreditApplicantEmploymentId', '1');
            previousEmployment.fieldValues.put('Emp_Status', null);
            previousEmployment.fieldValues.put('Emp_Type', null);
            previousEmployment.fieldValues.put('Emp_EmployerName', app.Previous_Employer_Name__c);
            
            //Fix for Batch Error
            if(app.Previous_Employment_Months__c != null){
              previousEmployment.fieldValues.put('Emp_Duration_months', app.Previous_Employment_Months__c.intValue());
            }
            
            if(app.Previous_Employment_Years__c != null){
              previousEmployment.fieldValues.put('Emp_Duration_years', app.Previous_Employment_Years__c.intValue());
            }            
            
            //Updated By A5E Consulting 
            //Appilcation Workflow and Data Sync
            previousEmployment.fieldValues.put('Emp_IncomeInterval', app.Previous_Income_Interval__c);
            
            previousEmployment.fieldValues.put('Emp_GrossIncome', app.Previous_Gross_Monthly_Income__c);
            
            PowerCurveWS.Address previousEmployerAddress = new PowerCurveWS.Address();
            previousEmployment.fieldValues.put('Address', previousEmployerAddress);
    
            previousEmployerAddress.fieldValues.put('CaseCreditApplicantAddressId', '0');
            previousEmployerAddress.fieldValues.put('AddressType', app.Previous_Employer_Address_Type__c);
            previousEmployerAddress.fieldValues.put('SuiteNumber', app.Previous_Employer_Unit_Number__c);
            previousEmployerAddress.fieldValues.put('CivicNumber', app.Previous_Employer_Street_Number__c);
            //previousEmployerAddress.fieldValues.put('CivicNumber', getCivicNumber(app.Previous_Employer_PO_Box__c, app.Previous_Employer_Street_Number__c));
            
            //previousEmployerAddress.fieldValues.put('StreetName', app.Previous_Employer_Street_Name__c);
            previousEmployerAddress.fieldValues.put('StreetName', getStreetName(app.Previous_Employer_PO_Box__c, app.Previous_Employer_Street_Name__c));
            
            
            previousEmployerAddress.fieldValues.put('City', app.Previous_Employer_City__c);
            previousEmployerAddress.fieldValues.put('ProvinceCode', app.Previous_Employer_Province__c);
            previousEmployerAddress.fieldValues.put('PostalCode', formatPostalCode(app.Previous_Employer_PostalCode__c));
            previousEmployerAddress.fieldValues.put('CountryCode', 'CA');
            previousEmployerAddress.fieldValues.put('Status', 'Previous');
            previousEmployerAddress.fieldValues.put('Type', app.Previous_Employer_Address_Type__c);
        }

        PowerCurveWS.FinanceData financeData = new PowerCurveWS.FinanceData();
        uDecideRequest.fieldValues.put('FinanceData', financeData);

        //financeData.fieldValues.put('Frequency', 'Monthly');
        
        //Updated by A5E Consulting
        //Email Authentication        
        //financeData.fieldValues.put('RequestedAmount', app.Requested_Credit_Limit__c);  
        /*      
        if(isResubmitRequest){            
            if(isRedecideCall == true){
                financeData.fieldValues.put('RequestedAmount', app.Lender_Approved_Amount__c);  
            } 
            else{
                financeData.fieldValues.put('RequestedAmount', app.Requested_Credit_Limit__c);  
            }       
        }
        else{
            //Whenever the application is submitted to PCOD first time, 
            //Salesforce will send 0 (zero) as RequestedAmount (Requested Credit Limit) in request XML.
            financeData.fieldValues.put('RequestedAmount', 0);
        }
        */
        //As per Anzira, Salesforce need to pass 0 for the requested amount in all cases(Submit, resubmit and redecide).
        //financeData.fieldValues.put('RequestedAmount', 0);
        
        //Do not set it to 0 when there is a value in Final Status field (Completed or Completed- CLI or Declined)
        if(isRedecideCall == true && String.isNotBlank(app.Final_Status__c) && (app.Final_Status__c.equalsIgnoreCase('Completed') || app.Final_Status__c.equalsIgnoreCase('Completed-CLI') || app.Final_Status__c.equalsIgnoreCase('Declined'))){
            
            //set Lender Approved Amount zero if Final Status is Declined and Lender Approved Amount is null
            if(app.Final_Status__c.equalsIgnoreCase('Declined') && app.Lender_Approved_Amount__c == null){
                financeData.fieldValues.put('RequestedAmount', 0);
            }
            else{
                financeData.fieldValues.put('RequestedAmount', app.Lender_Approved_Amount__c);
            }
        }
        else{
            financeData.fieldValues.put('RequestedAmount', 0);
        }
        /*
        //Underwriting Rules for 4 Pillars - Updates for Tier Type
        if(isResubmitRequest == false){
            if(String.isNotBlank(app.Strategy_Tier__c) && (!app.Strategy_Tier__c.equalsIgnoreCase('Default'))){
                financeData.fieldValues.put('AppStrategyTier',app.Strategy_Tier__c);
            }
            else{
                financeData.fieldValues.put('AppStrategyTier','');
            }
        }
        */
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument('UTF-8', '1.0');
        uDecideRequest.getXMLString(w);
        w.writeEndDocument();

        String uDecideRequestXML = w.getXmlString();
        w.close();
        System.debug('uDecideRequestXML :');
        System.debug(uDecideRequestXML);
        
        return uDecideRequestXML;
    }
    
    /**
    *   @description Returns soap envelope for requests to PowerCurve 
    */
    private static String getSoapEnvelope(String arg0, Application_Form_Settings__c afSettings) {
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String serviceNS = 'http://service.integration.ds.com/';

        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument('UTF-8', '1.0');
        w.writeStartElement('soapenv', 'Envelope', soapNS);
        w.writeNamespace('soapenv', soapNS);
        w.writeNamespace('xsd', 'http://www.w3.org/2001/XMLSchema');
        w.writeNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');

        w.writeStartElement(null, 'Header', soapNS);
        w.writeStartElement('ns1', 'Authentication', serviceNS);
        w.writeNamespace('ns1', serviceNS);
        w.writeAttribute('soapenv', soapNS, 'actor', 'http://schemas.xmlsoap.org/soap/actor/next');
        w.writeAttribute('soapenv', soapNS, 'mustUnderstand', '0');
        w.writeCharacters(EncodingUtil.base64Encode(Blob.valueOf(afSettings.Power_Curve_Username__c + ':' + afSettings.Power_Curve_Password__c)));
        w.writeEndElement(); //end Authentication
        w.writeEndElement(); //end Header

        w.writeStartElement(null, 'Body', soapNS);
        w.writeStartElement('', 'invokeIntegrationServiceFromSTS', serviceNS);
        w.writeNamespace('', serviceNS);
        
        w.writeStartElement('', 'arg0', '');
        w.writeNamespace('', '');
        w.writeCData(arg0);
        w.writeEndElement(); //end arg0
        
        w.writeEndElement(); //end invokeIntegrationServiceFromSTS
        w.writeEndElement(); //end Body

        w.writeEndElement(); //end Envelope
        w.writeEndDocument();

        String soapEnvelopeXML = w.getXmlString();
        w.close();
        System.debug('soapEnvelopeXML getSoapEnvelope :');
        System.debug(soapEnvelopeXML);
        
        return soapEnvelopeXML;
    }
    
    /**
    *   @description Parse PowerCurve response to either "submit" or "resubmit" requests; populate
    *   decision response.
    */
    private static void parseResponse(Dom.Document soapEnv, DecisionResponse decResp, Boolean isSubmitCall) {
        Map<String, Dom.XMLNode> derivedVariableByName = new Map<String, Dom.XMLNode>();
        Dom.XMLNode rootElem = soapEnv.getRootElement();
        Dom.XMLNode bodyElem = rootElem.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode respElem = bodyElem.getChildElement('invokeIntegrationServiceFromSTSResponse', 'http://service.integration.ds.com/');
        Dom.XMLNode returnElem = respElem.getChildElement('return', null);
        //system.debug(returnElem.getName());
        //system.debug(returnElem.getText());

        // Get root XML node        
        Dom.Document decisionResponse = new Dom.Document();
        decisionResponse.load(returnElem.getText());
        Dom.XMLNode drRoot = decisionResponse.getRootElement();
        
        // Get customer request id
        Dom.XMLNode crIdElem = drRoot.getChildElement('CustomerRequestID',null);
        decResp.customerRequestId = crIdElem.getText();

        // Get list of derived variables and populate key -> XML node map
        Dom.XMLNode derivedVariables = drRoot.getChildElement('DerivedVariables',null);
        List<Dom.XMLNode> derivedVariableList = derivedVariables.getChildElements();

        for (Dom.XMLNode derivedVariable : derivedVariableList) {
            derivedVariableByName.put(derivedVariable.getChildElement('Name',null).getText(),derivedVariable);
        }
        
        // Decisions element and at least one child is required
        /*
        Dom.XMLNode decisionsElem = drRoot.getChildElement('Decisions',null);
        if (decisionsElem == null) {
            decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            return;
        }
        
        List<Dom.XMLNode> decisionList = decisionsElem.getChildElements();
        if (decisionList.isEmpty()) {
            decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            return;
        }
        
   
        // Populate decision fields
        Dom.XMLNode decisionElem = decisionList[decisionList.size()-1];
        decResp.decision = decisionElem.getChildElement('DecisionNode', null).getText();
        decResp.applicationStatus = decisionElem.getChildElement('Description', null).getText();
        
        */
        
        //Decision Timestamp
        decResp.decisionTimestamp = parseDecisionResponseTimestamp(drRoot.getChildElement('SystemDateTime',null).getText());
        
        //Decision
        String pcodDecision = null;
        try {
            //decResp.decision = derivedVariableByName.get('App_Decision').getChildElement('Value',null).getText();
            pcodDecision = derivedVariableByName.get('App_Decision').getChildElement('Value',null).getText();
        } 
        catch (Exception excp) {                        
            decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            return;
        }
        if(String.isNotBlank(pcodDecision)){
            decResp.decision = pcodDecision;
            decResp.decisionResult = pcodDecision;
            pcodDecision = decisionResultDecisionMap.get(pcodDecision);
            if(String.isNotBlank(pcodDecision)){
                decResp.decision = pcodDecision;
            }
        }
        
        //Application Status
        String pcodAppStatus = null;
        try {
            //decResp.applicationStatus = derivedVariableByName.get('App_Decision_Status').getChildElement('Value',null).getText();
            pcodAppStatus = derivedVariableByName.get('App_Decision_Status').getChildElement('Value',null).getText();
        } 
        catch (Exception excp) {                        
            decResp.errorMessage = UNEXP_ERROR_MESSAGE;
            return;
        }
        if(String.isNotBlank(pcodAppStatus)){
            decResp.applicationStatus = pcodAppStatus;
            decResp.decisionStatus = pcodAppStatus;
            pcodAppStatus = decisionApplicationStatusMap.get(pcodAppStatus);
            if(String.isNotBlank(pcodAppStatus)){
                decResp.applicationStatus = pcodAppStatus;
            }
        }
                
        // Populate submit-specific fields
        if (isSubmitCall == true) {
            
            try {
                decResp.maxCreditCardAllowedAmount = Decimal.valueOf(derivedVariableByName.get('Cons1_Max_CC_Amt').getChildElement('Value',null).getText());
            }
            catch (Exception excp) {
                system.debug('Exception for maxCreditCardAllowedAmount :'+excp); 
                if (Utilities.APP_ACCEPTED_DECISIONS.contains(decResp.decision)) {
                    throw excp;
                }
            }
            
            try {
                decResp.totalCreditWorthiness = Decimal.valueOf(derivedVariableByName.get('Cons1_TCW_Amt').getChildElement('Value',null).getText());                
            } 
            catch (Exception excp) {
                system.debug('Exception for totalCreditWorthiness :'+excp); 
                if (Utilities.APP_ACCEPTED_DECISIONS.contains(decResp.decision)) {
                    throw excp;
                }
            }
            
            
            //read maxLoanAmount for Term Loan Application
            try{
              decResp.MaxLoanAmount = Decimal.valueOf(derivedVariableByName.get('Cons1_Max_Loan_Amt').getChildElement('Value',null).getText());          
            }
            catch (Exception excp) {
              system.debug('Exception for MaxLoanAmount :'+excp);  
            }
            
            try {
                decResp.fraudAlert = derivedVariableByName.get('Cons1_Fraud_Alert_Found').getChildElement('Value',null).getText();                
            } 
            catch (Exception excp) {
                system.debug('Exception for fraudAlert :'+excp);                 
            }
            
            try {
                decResp.applicantType = derivedVariableByName.get('Cons1_Applicant_Type').getChildElement('Value',null).getText();
            } 
            catch (Exception excp) {
                system.debug('Exception for applicantType :'+excp);                 
            }
        }
        
        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        
        //Expenses & Income Information.
        /*
        try{
          decResp.monthlyHousingExpense = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Housing').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for monthlyHousingExpense :'+excp);  
        } 
        */
        
        try{
          decResp.monthlyHousingCost = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Housing').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for monthlyHousingCost :'+excp);  
        } 
                   
        try{
          decResp.monthlyExpenses = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Debt_Payment').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for monthlyExpenses :'+excp);  
        }        
        try{
          decResp.grossMonthlyIncome = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Income').getChildElement('Value',null).getText());
          
          if(decResp.grossMonthlyIncome != null){
            decResp.grossMonthlyIncome = decResp.grossMonthlyIncome.setScale(2);          
          }
        }
        catch (Exception excp) {
          system.debug('Exception for grossMonthlyIncome :'+excp);  
        }
        
        //Credit Scores
        try{
            decResp.creditScore = derivedVariableByName.get('DS_Cons1_CBScore').getChildElement('Value',null).getText();
        }
        catch (Exception excp) {
            system.debug('Exception for creditScore :'+excp);              
        }
        try{
          decResp.dsrScore = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_DSR').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for dsrScore :'+excp);  
        }        
        try{
          decResp.scorecardProgram = derivedVariableByName.get('App_Scorecard').getChildElement('Value',null).getText();
        }
        catch (Exception excp) {
          system.debug('Exception for scorecardProgram :'+excp);  
        }
        
        //Decision Summary Notes
        String decisionSummary = '';
        Set<String> derivedVariableKeys = derivedVariableByName.keySet();        
        for(String derivedVariableKey : derivedVariableKeys){
            system.debug('derivedVariableKey before :'+derivedVariableKey);
            if(derivedVariableKey.startsWith('Detail_Cons1')){ 
                String noteLocal = '';  
                Boolean isException = false;            
                try{
                    system.debug('derivedVariableKey after: '+derivedVariableKey); 
                    //noteLocal = derivedVariableByName.get(derivedVariableKey).getChildElement('Value',null).getText()+'\n';
                    noteLocal = derivedVariableByName.get(derivedVariableKey).getChildElement('Value',null).getText();
                }
                catch (Exception excp) {
                    system.debug('Exception for decisionSummaryNotes :'+excp);
                    isException = true;  
                }  
                
                if(!isException && String.isNotBlank(noteLocal)){
                    decisionSummary = decisionSummary + noteLocal + '\n\n';
                } 
            }
        }
        decResp.decisionSummary = decisionSummary;  
        
        //Credit Bureau Summary
        try{
          decResp.accountsOnFile = Integer.valueOf(derivedVariableByName.get('DS_Cons1_NUMTR').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for accountsOnFile :'+excp);  
        }  
        try{
          decResp.revolvingDebtUtilization = Decimal.valueOf(derivedVariableByName.get('DS_Cons1_UTL').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for revolvingDebtUtilization :'+excp);  
        } 
        try{
          decResp.bankruptcies = Integer.valueOf(derivedVariableByName.get('HD_Cons1_No_of_BKTS').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for bankruptcies :'+excp);  
        } 
        try{
          decResp.monthSinceBKDischarge = Integer.valueOf(derivedVariableByName.get('HD_Cons1_Months_Since_BKTS').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for monthSinceBKDischarge :'+excp);  
        } 
        try{
          decResp.badDebtWriteOff = Decimal.valueOf(derivedVariableByName.get('HD_Cons1_BDWO').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for badDebtWriteOff :'+excp);  
        } 
        try{
          decResp.monthsSinceBadDebtWriteOff = Decimal.valueOf(derivedVariableByName.get('HD_Cons1_Months_Since_BDWO').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for monthsSinceBadDebtWriteOff :'+excp);  
        }    
        
        //Underwriting Rules for 4 Pillars - Updates for Tier Type 
        try{
          decResp.appStrategyTier  = derivedVariableByName.get('App_Strategy_Tier').getChildElement('Value',null).getText();
        }
        catch (Exception excp) {
          system.debug('Exception for appStrategyTier :'+excp);  
        }   
        
        system.debug('errorMessage: ' + decResp.errorMessage);
        system.debug('customerRequestId: ' + decResp.customerRequestId);
        system.debug('decision: ' + decResp.decision);
        system.debug('applicationStatus: ' + decResp.applicationStatus);
        system.debug('decisionTimestamp: ' + decResp.decisionTimestamp);
        system.debug('maxCreditCardAllowedAmount: ' + decResp.maxCreditCardAllowedAmount);
        system.debug('totalCreditWorthiness: ' + decResp.totalCreditWorthiness);
        system.debug('fraudAlert: ' + decResp.fraudAlert);
        system.debug('applicantType: ' + decResp.applicantType);
        
        system.debug('monthlyHousingCost: ' + decResp.monthlyHousingCost);
        system.debug('monthlyExpenses: ' + decResp.monthlyExpenses);
        system.debug('grossMonthlyIncome: ' + decResp.grossMonthlyIncome);
        system.debug('creditScore: ' + decResp.creditScore);
        system.debug('maxLoanAmount: ' + decResp.maxLoanAmount);
        system.debug('dsrScore: ' + decResp.dsrScore);
        system.debug('scorecardProgram: ' + decResp.scorecardProgram);        
        system.debug('decisionSummary: ' + decResp.decisionSummary); 
        
        system.debug('accountsOnFile: ' + decResp.accountsOnFile); 
        system.debug('revolvingDebtUtilization: ' + decResp.revolvingDebtUtilization); 
        system.debug('bankruptcies: ' + decResp.bankruptcies); 
        system.debug('monthSinceBKDischarge: ' + decResp.monthSinceBKDischarge); 
        system.debug('badDebtWriteOff: ' + decResp.badDebtWriteOff); 
        system.debug('monthsSinceBadDebtWriteOff: ' + decResp.monthsSinceBadDebtWriteOff);  
        
        system.debug('appStrategyTier: ' + decResp.appStrategyTier);        
    }
    
    /**
    *   @description Populates PowerCurve error object with request info
    */
    private static void writeErrorRequest(API_Error__c apiError, HttpRequest req) {
        apiError.Request__c = 'Endpoint: ' + req.getEndpoint();
        apiError.Request__c += '\nMethod: ' + req.getMethod();
        apiError.Request__c += '\nHeaders:';
        apiError.Request__c += '\nConnection: ' + req.getHeader('Connection');
        apiError.Request__c += '\nContent-Type: ' + req.getHeader('Content-Type');
        apiError.Request__c += '\nSOAPAction: ' + req.getHeader('SOAPAction');
        apiError.Request__c += '\nBody:\n' + req.getBody();
    }
    
    /**
    *   @description Populates PowerCurve error object with response info
    */
    private static void writeErrorResponse(API_Error__c apiError, HttpResponse resp) {
        apiError.Response__c = 'Status Code: ' + resp.getStatusCode();
        apiError.Response__c += '\nStatus: ' + resp.getStatus();
        apiError.Response__c += '\nHeaders:';
        for (String h : resp.getHeaderKeys()) {
            if (String.isNotBlank(h)) {
                apiError.Response__c += '\n' + h + ': ' + resp.getHeader(h);
            }
        }
        
        apiError.Response__c += '\nBody:\n';
        String respBody = resp.getBody();
        if (String.isNotBlank(respBody)) {
            apiError.Response__c += respBody.replace('&lt;','<');
        }
    }
    
    /** Various helper methods */
    
    private static String formatDate(Date d) {
        if (d == null) {
            return null;
        }
        return Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
    }
    
    private static String formatSIN(Application__c app) {
        if (String.isBlank(app.SIN__c)) {
            return null;
        }
        String sinDigits = app.SIN__c.replaceAll('\\D+','');
        if (sinDigits.length() != 9) {
            return null;
        }
        return sinDigits;
    }
    
    private static String getGender(Application__c app) {
        if (String.isNotBlank(app.Gender__c) && app.Gender__c == 'Male') {
            return 'M';
        }
        return 'F';
    }
    
    private static Integer getAge(Application__c app) {
        if (app.Birth_Date__c == null) {
            return null;
        }
        Date t = Date.today();
        Integer mb = app.Birth_Date__c.monthsBetween(t);
        if (app.Birth_Date__c.month() == t.month() && app.Birth_Date__c.day() > t.day()) {
            mb--;
        }

        return mb/12;
    }
    
    private static String getCurrentBKCP(Application__c app) {
        if (app.Current_BKCP__c == true) {
            return 'true';
        }
        return 'false';
    }
    
    private static String formatPostalCode(String pc) {
        if (String.isBlank(pc)) {
            return null;
        }
        return pc.deleteWhitespace();
    }
    
    private static String formatPhone(String p) {
        if (String.isBlank(p)) {
            return null;
        }
        String fp = p.replaceAll('\\D+','');
        if (fp.length() != 10) {
            return null;
        }
        return fp.substring(0, 3) + '-' + fp.substring(3, 6) + '-' + fp.substring(6, 10);
    }

    // The timestamp we receive should be in the following format: 2015-08-11T20:13:45
    private static DateTime parseDecisionResponseTimestamp(String drts) {
        DateTime dt = null;
        try {
            String[] dtStr = drts.split('T');
            String[] dateStr = dtStr[0].split('-');
            String[] timeStr = dtStr[1].split(':');
            dt = DateTime.newInstance(
                Integer.valueOf(dateStr[0]), 
                Integer.valueOf(dateStr[1]), 
                Integer.valueOf(dateStr[2]), 
                Integer.valueOf(timeStr[0]), 
                Integer.valueOf(timeStr[1]), 
                Integer.valueOf(timeStr[2])
            );
        } catch (Exception e) {
        }

        return dt;
    }
    
    /**
    *   @description Parse PowerCurve response to REDECIDE; populate
    *   decision response.
    */
    private static void parseResponseRedecide(Dom.Document soapEnv, DecisionResponse decResp, Application__c application) {
        Map<String, Dom.XMLNode> derivedVariableByName = new Map<String, Dom.XMLNode>();
        Dom.XMLNode rootElem = soapEnv.getRootElement();
        Dom.XMLNode bodyElem = rootElem.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode respElem = bodyElem.getChildElement('invokeIntegrationServiceFromSTSResponse', 'http://service.integration.ds.com/');
        Dom.XMLNode returnElem = respElem.getChildElement('return', null);
        //system.debug(returnElem.getName());
        //system.debug(returnElem.getText());

        // Get root XML node        
        Dom.Document decisionResponse = new Dom.Document();
        decisionResponse.load(returnElem.getText());
        Dom.XMLNode drRoot = decisionResponse.getRootElement();
        
        // Get customer request id
        Dom.XMLNode crIdElem = drRoot.getChildElement('CustomerRequestID',null);
        decResp.customerRequestId = crIdElem.getText();

        // Get list of derived variables and populate key -> XML node map
        Dom.XMLNode derivedVariables = drRoot.getChildElement('DerivedVariables',null);
        List<Dom.XMLNode> derivedVariableList = derivedVariables.getChildElements();

        for (Dom.XMLNode derivedVariable : derivedVariableList) {
            derivedVariableByName.put(derivedVariable.getChildElement('Name',null).getText(),derivedVariable);
        }
        
        decResp.decisionTimestamp = parseDecisionResponseTimestamp(drRoot.getChildElement('SystemDateTime',null).getText());
        
        try{
          decResp.firstName = derivedVariableByName.get('Cons1_FirstName').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.middleName = derivedVariableByName.get('Cons1_MiddleName').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
                    
        try{
          decResp.lastName = derivedVariableByName.get('Cons1_LastName').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.preferredLanguage = derivedVariableByName.get('Cons1_PreferredLanguage').getChildElement('Value',null).getText(); 
        }
        catch (Exception e) {
        }
        
        try{
          // SIN logic 
          String primaryIdType = derivedVariableByName.get('Cons1_PrimaryIdType').getChildElement('Value',null).getText();
          if((!String.isBlank(primaryIdType)) && (primaryIdType.toUpperCase() == 'SIN')){
            decResp.sin = derivedVariableByName.get('Cons1_PrimaryIdValue').getChildElement('Value',null).getText();
          }
        }
        catch (Exception e) {
        }
        
        try{
          //BirthDay logic
          String birthDateStr = derivedVariableByName.get('Cons1_DOB').getChildElement('Value',null).getText();
          if(!String.isBlank(birthDateStr)){
              decResp.DateOfBirth = parseDecisionResponseBirthDate(birthDateStr);
          }             
        }
        catch (Exception e) {
        }
        
        try{
          decResp.email = derivedVariableByName.get('Cons1_Email').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          //Declared BKCP
          String declaredBKCPStr = derivedVariableByName.get('Cons1_BKCP').getChildElement('Value',null).getText();
          if((!String.isBlank(declaredBKCPStr)) && (declaredBKCPStr.toUpperCase() == 'TRUE')){
              decResp.declaredBKCP = true;
          }
          else{
              decResp.declaredBKCP = false;
          }
        }
        catch (Exception e) {
        }            
        
        /*
        //Salsforce always sends 0 as requested amount
        try{
          decResp.requestedCreditLimit = Decimal.valueOf(derivedVariableByName.get('Cons1_AmountRequested').getChildElement('Value',null).getText());
        }
        catch (Exception e) {
        }
        */
        
        try{
          String genderStr  = derivedVariableByName.get('Cons1_Gender').getChildElement('Value',null).getText();
          if (!String.isBlank(genderStr)){
            if(genderStr == 'M'){
              decResp.gender = 'Male';
            }
            else if(genderStr == 'F'){
              decResp.gender= 'Female';
            }
          }
        }
        catch (Exception e) {
        }
        
        try{
          decResp.preferredMethod = derivedVariableByName.get('Cons1_PreferredMethod').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.maritalStatus = derivedVariableByName.get('Cons1_MaritalStatus').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        //Address Information.
        try{
          String civicNumber = derivedVariableByName.get('Cons1_Addr_CivicNbr_Current').getChildElement('Value',null).getText();
          decResp.streetNumber = civicNumber;
          /*
          //poBox and streetNumber from civicNumber
          decResp.poBox = application.Permanent_Address_PO_Box__c;
          
          if(String.isNotBlank(application.Permanent_Address_PO_Box__c)){
              decResp.streetNumber = civicNumber.replaceAll(application.Permanent_Address_PO_Box__c,'');
          }
          else{
              decResp.streetNumber = civicNumber;
          }
          */            
        }
        catch (Exception e) {
        }
        
        try{
          //decResp.streetName = derivedVariableByName.get('Cons1_Addr_StreetName_Current').getChildElement('Value',null).getText();
          String streetNamePoBox = derivedVariableByName.get('Cons1_Addr_StreetName_Current').getChildElement('Value',null).getText();
          decResp.poBox = application.Permanent_Address_PO_Box__c;
          
          if(String.isNotBlank(application.Permanent_Address_PO_Box__c)){
              decResp.streetName = streetNamePoBox.replaceAll(application.Permanent_Address_PO_Box__c,'').trim();
          }
          else{
              decResp.streetName = streetNamePoBox;
          }
        }
        catch (Exception e) {
        }
        
        try{
          decResp.suiteNumber = derivedVariableByName.get('Cons1_Addr_SuiteNbr_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
                    
        try{
          decResp.city = derivedVariableByName.get('Cons1_Addr_City_Current').getChildElement('Value',null).getText();
       }
        catch (Exception e) {
        }
            
        try{
          decResp.provinceCode = derivedVariableByName.get('Cons1_Addr_ProvinceCd_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.postalCode = derivedVariableByName.get('Cons1_Addr_PostalCd_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.countryCode = derivedVariableByName.get('Cons1_Addr_CountryCd_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.lengthOfResidenceYears = Integer.valueOf(derivedVariableByName.get('Cons1_Addr_LengthResYrs_Current').getChildElement('Value',null).getText());
        }
        catch (Exception e) {
        }
        
        try{
          decResp.lengthOfResidenceMonths = Integer.valueOf(derivedVariableByName.get('Cons1_Addr_LengthResMths_Current').getChildElement('Value',null).getText());
        }
        catch (Exception e) {
        }
        
        try{
          decResp.residentialStatus = derivedVariableByName.get('Cons1_Addr_ResidentStatus_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.addressStatus = derivedVariableByName.get('Cons1_Addr_Status_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        //Employer Information.
        try{
          decResp.employerName = derivedVariableByName.get('Cons1_EmployerName_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employerPhone = derivedVariableByName.get('Cons1_EmployerPhone_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        decResp.employerPoBox = application.Employer_PO_Box__c;

        try{
          String employerAddrs = derivedVariableByName.get('Cons1_EmployerAddrLine1_Current').getChildElement('Value',null).getText();
          decResp.employerStreetName = employerAddrs.replace(application.Employer_PO_Box__c,'').replace(application.Employer_Street_Number__c,'').trim();
          decResp.employerStreetNumber = employerAddrs.replace(application.Employer_PO_Box__c,'').replace(application.Employer_Street_Name__c,'').trim(); 
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employerUnitNumber = derivedVariableByName.get('Cons1_EmployerAddrLine2_Current').getChildElement('Value',null).getText();
            
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employerCity = derivedVariableByName.get('Cons1_EmployerCity_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employerProvinceCode = derivedVariableByName.get('Cons1_EmployerProvinceCd_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employerPostalCode = derivedVariableByName.get('Cons1_EmployerPostalCd_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.incomeInterval = derivedVariableByName.get('Cons1_Emp_IncomeInterval_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employmentYears = Integer.valueOf(derivedVariableByName.get('Cons1_EmpYears_Current').getChildElement('Value',null).getText());
        }
        catch (Exception e) {
        }
        
        try{
          decResp.employmentMonths = Integer.valueOf(derivedVariableByName.get('Cons1_EmpMonths_Current').getChildElement('Value',null).getText());
        }
        catch (Exception e) {
        }
                
        try{
          decResp.employmentStatus = derivedVariableByName.get('Cons1_EmpStatus_Current').getChildElement('Value',null).getText();
        }
        catch (Exception e) {
        }
        
        /*
        try {
            decResp.decision = derivedVariableByName.get('App_Decision').getChildElement('Value',null).getText();
        } 
        catch (Exception excp) {
            
        }
        
        try {
            decResp.applicationStatus = derivedVariableByName.get('App_Decision_Status').getChildElement('Value',null).getText();
        } 
        catch (Exception excp) {
            
        }
        */
        
        //Decision
        String pcodDecision = null;
        try {
            pcodDecision = derivedVariableByName.get('App_Decision').getChildElement('Value',null).getText();
        } 
        catch (Exception excp) {                        
            system.debug('Exception for pcodDecision :'+excp);
        }
        if(String.isNotBlank(pcodDecision)){
            decResp.decision = pcodDecision;
            decResp.decisionResult = pcodDecision;
            pcodDecision = decisionResultDecisionMap.get(pcodDecision);
            if(String.isNotBlank(pcodDecision)){
                decResp.decision = pcodDecision;
            }
        }
        
        //Application Status
        String pcodAppStatus = null;
        try {
            //decResp.applicationStatus = derivedVariableByName.get('App_Decision_Status').getChildElement('Value',null).getText();
            pcodAppStatus = derivedVariableByName.get('App_Decision_Status').getChildElement('Value',null).getText();            
        } 
        catch (Exception excp) {  
            system.debug('Exception for pcodAppStatus :'+excp);
        }
        if(String.isNotBlank(pcodAppStatus)){
            decResp.applicationStatus = pcodAppStatus;
            decResp.decisionStatus = pcodAppStatus;
            pcodAppStatus = decisionApplicationStatusMap.get(pcodAppStatus);
            if(String.isNotBlank(pcodAppStatus)){
                decResp.applicationStatus = pcodAppStatus;
            }
        }

        try {
            decResp.maxCreditCardAllowedAmount = Decimal.valueOf(derivedVariableByName.get('Cons1_Max_CC_Amt').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
            
        }
            
        try {
            decResp.totalCreditWorthiness = Decimal.valueOf(derivedVariableByName.get('Cons1_TCW_Amt').getChildElement('Value',null).getText());                
        } 
        catch (Exception excp) {
            
        }
        
        //read maxLoanAmount for Term Loan Application
        try{
          decResp.MaxLoanAmount = Decimal.valueOf(derivedVariableByName.get('Cons1_Max_Loan_Amt').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for MaxLoanAmount :'+excp);  
        }
        
        try{
            decResp.fraudAlert = derivedVariableByName.get('Cons1_Fraud_Alert_Found').getChildElement('Value',null).getText();                
        } 
        catch (Exception excp) {
            
        }
        
        try {
            decResp.applicantType = derivedVariableByName.get('Cons1_Applicant_Type').getChildElement('Value',null).getText();
        } 
        catch (Exception excp) {
            
        }
        //Cons1_AmountRequested RequestedAmount
        /*
        try {
            decResp.lenderApprovedAmount = Integer.Valueof(derivedVariableByName.get('Cons1_AmountRequested').getChildElement('Value',null).getText());
        } 
        catch (Exception excp) {
            
        }
        */
        //Updated By A5E Consulting 
        //Appilcation Workflow and Data Sync
        //Expenses & Income Information.
        /*
        try{
          decResp.monthlyHousingExpense = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Housing').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for monthlyHousingExpense :'+excp);  
        } 
        */  
        try{
          decResp.monthlyHousingCost = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Housing').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for monthlyHousingCost :'+excp);  
        } 
                 
        try{
          decResp.monthlyExpenses = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Debt_Payment').getChildElement('Value',null).getText());          
        }
        catch (Exception excp) {
          system.debug('Exception for monthlyExpenses :'+excp);  
        }        
        try{
          decResp.grossMonthlyIncome = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_Income').getChildElement('Value',null).getText());
          
          if(decResp.grossMonthlyIncome != null){
            decResp.grossMonthlyIncome = decResp.grossMonthlyIncome.setScale(2);          
          }
        }
        catch (Exception excp) {
          system.debug('Exception for grossMonthlyIncome :'+excp);  
        }
        
        //Credit Scores
        try{
            decResp.creditScore = derivedVariableByName.get('DS_Cons1_CBScore').getChildElement('Value',null).getText();
        }
        catch (Exception excp) {
            system.debug('Exception for creditScore :'+excp);              
        }
        try{
          decResp.dsrScore = Decimal.valueOf(derivedVariableByName.get('AS_Cons1_DSR').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for dsrScore :'+excp);  
        }        
        try{
          decResp.scorecardProgram = derivedVariableByName.get('App_Scorecard').getChildElement('Value',null).getText();
        }
        catch (Exception excp) {
          system.debug('Exception for scorecardProgram :'+excp);  
        }
        
        //Decision Summary Notes
        String decisionSummary = '';
        Set<String> derivedVariableKeys = derivedVariableByName.keySet();        
        for(String derivedVariableKey : derivedVariableKeys){
            //system.debug('derivedVariableKey before :'+derivedVariableKey);
            if(derivedVariableKey.startsWith('Detail_Cons1')){ 
                String noteLocal = '';  
                Boolean isException = false;            
                try{
                    system.debug('derivedVariableKey after: '+derivedVariableKey); 
                    //noteLocal = derivedVariableByName.get(derivedVariableKey).getChildElement('Value',null).getText()+'\n';
                    noteLocal = derivedVariableByName.get(derivedVariableKey).getChildElement('Value',null).getText();
                }
                catch (Exception excp) {
                    system.debug('Exception for decisionSummaryNotes :'+excp);
                    isException = true;  
                }  
                
                if(!isException && String.isNotBlank(noteLocal)){
                    decisionSummary = decisionSummary + noteLocal + '\n\n';
                } 
            }
        }
        decResp.decisionSummary = decisionSummary; 
        
        //Credit Bureau Summary
        try{
          decResp.accountsOnFile = Integer.valueOf(derivedVariableByName.get('DS_Cons1_NUMTR').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for accountsOnFile :'+excp);  
        }  
        
        try{
          decResp.revolvingDebtUtilization = Decimal.valueOf(derivedVariableByName.get('DS_Cons1_UTL').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for revolvingDebtUtilization :'+excp);  
        } 
        
        try{
          decResp.bankruptcies = Integer.valueOf(derivedVariableByName.get('HD_Cons1_No_of_BKTS').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for bankruptcies :'+excp);  
        } 
        
        try{
          decResp.monthSinceBKDischarge = Integer.valueOf(derivedVariableByName.get('HD_Cons1_Months_Since_BKTS').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for monthSinceBKDischarge :'+excp);  
        } 
        
        try{
          decResp.badDebtWriteOff = Decimal.valueOf(derivedVariableByName.get('HD_Cons1_BDWO').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for badDebtWriteOff :'+excp);  
        } 
        
        try{
          decResp.monthsSinceBadDebtWriteOff = Decimal.valueOf(derivedVariableByName.get('HD_Cons1_Months_Since_BDWO').getChildElement('Value',null).getText());
        }
        catch (Exception excp) {
          system.debug('Exception for monthsSinceBadDebtWriteOff :'+excp);  
        }  
        
        //Underwriting Rules for 4 Pillars - Updates for Tier Type 
        try{
          decResp.appStrategyTier  = derivedVariableByName.get('App_Strategy_Tier').getChildElement('Value',null).getText();
        }
        catch (Exception excp) {
          system.debug('Exception for appStrategyTier :'+excp);  
        }          
        
        system.debug('parseResponseRedecide employerStreetNumber: ' + decResp.employerStreetNumber);
        system.debug('parseResponseRedecide employerStreetName: ' + decResp.employerStreetName);
        system.debug('parseResponseRedecide employerPhone: ' + decResp.employerPhone);
        system.debug('parseResponseRedecide employerName: ' + decResp.employerName);
        system.debug('parseResponseRedecide addressStatus: ' + decResp.addressStatus);
        system.debug('parseResponseRedecide residentialStatus: ' + decResp.residentialStatus);
        system.debug('parseResponseRedecide lengthOfResidenceMonths: ' + decResp.lengthOfResidenceMonths);
        system.debug('parseResponseRedecide lengthOfResidenceYears: ' + decResp.lengthOfResidenceYears);
        system.debug('parseResponseRedecide postalCode: ' + decResp.postalCode);
        system.debug('parseResponseRedecide provinceCode: ' + decResp.provinceCode);
        system.debug('parseResponseRedecide city: ' + decResp.city);
        system.debug('parseResponseRedecide suiteNumber: ' + decResp.suiteNumber);
        system.debug('parseResponseRedecide StreetName: ' + decResp.StreetName);
        //system.debug('parseResponseRedecide civicNumber: ' + decResp.civicNumber);
        system.debug('parseResponseRedecide preferredMethod: ' + decResp.preferredMethod);
        system.debug('parseResponseRedecide maritalStatus: ' + decResp.maritalStatus);
        system.debug('parseResponseRedecide gender: ' + decResp.gender);
        system.debug('parseResponseRedecide requestedCreditLimit: ' + decResp.requestedCreditLimit);
        system.debug('parseResponseRedecide declaredBKCP: ' + decResp.declaredBKCP);
        system.debug('parseResponseRedecide email exception');
        system.debug('parseResponseRedecide email: ' + decResp.email);
        system.debug('parseResponseRedecide DateOfBirth: ' + decResp.DateOfBirth);
        system.debug('parseResponseRedecide sin: ' + decResp.sin);  
        system.debug('parseResponseRedecide preferredLanguage: ' + decResp.preferredLanguage);
        system.debug('parseResponseRedecide lastName: ' + decResp.lastName);
        system.debug('parseResponseRedecide middleName: ' + decResp.middleName);
        system.debug('parseResponseRedecide firstName: ' + decResp.firstName);
        system.debug('parseResponseRedecide grossMonthlyIncome: ' + decResp.grossMonthlyIncome);
        system.debug('parseResponseRedecide employerCity: ' + decResp.employerCity);
        system.debug('parseResponseRedecide employerProvinceCode: ' + decResp.employerProvinceCode);
        system.debug('parseResponseRedecide employerPostalCode: ' + decResp.employerPostalCode);
        system.debug('parseResponseRedecide addressStatus: ' + decResp.addressStatus);
        system.debug('parseResponseRedecide incomeInterval: ' + decResp.incomeInterval);
        system.debug('parseResponseRedecide employmentYears: ' + decResp.employmentYears);
        system.debug('parseResponseRedecide employmentMonths: ' + decResp.employmentMonths);
        system.debug('parseResponseRedecide errorMessage: ' + decResp.errorMessage);
        system.debug('parseResponseRedecide customerRequestId: ' + decResp.customerRequestId);
        system.debug('parseResponseRedecide decision: ' + decResp.decision);
        system.debug('parseResponseRedecide applicationStatus: ' + decResp.applicationStatus);
        system.debug('parseResponseRedecide decisionTimestamp: ' + decResp.decisionTimestamp);
        system.debug('parseResponseRedecide maxCreditCardAllowedAmount: ' + decResp.maxCreditCardAllowedAmount);
        system.debug('parseResponseRedecide maxLoanAmount: ' + decResp.maxLoanAmount);
        system.debug('parseResponseRedecide totalCreditWorthiness: ' + decResp.totalCreditWorthiness);
        system.debug('parseResponseRedecide fraudAlert: ' + decResp.fraudAlert);
        system.debug('parseResponseRedecide applicantType: ' + decResp.applicantType);
        
        system.debug('parseResponseRedecide monthlyHousingCost: ' + decResp.monthlyHousingCost);
        system.debug('parseResponseRedecide monthlyExpenses: ' + decResp.monthlyExpenses);
        system.debug('parseResponseRedecide grossMonthlyIncome: ' + decResp.grossMonthlyIncome);
        system.debug('parseResponseRedecide creditScore: ' + decResp.creditScore);
        system.debug('parseResponseRedecide dsrScore: ' + decResp.dsrScore);
        system.debug('scorecardProgram: ' + decResp.scorecardProgram);        
        system.debug('parseResponseRedecide decisionSummary: ' + decResp.decisionSummary);    
        
        system.debug('parseResponseRedecide accountsOnFile: ' + decResp.accountsOnFile); 
        system.debug('parseResponseRedecide revolvingDebtUtilization: ' + decResp.revolvingDebtUtilization); 
        system.debug('parseResponseRedecide bankruptcies: ' + decResp.bankruptcies); 
        system.debug('parseResponseRedecide monthSinceBKDischarge: ' + decResp.monthSinceBKDischarge); 
        system.debug('parseResponseRedecide badDebtWriteOff: ' + decResp.badDebtWriteOff); 
        system.debug('parseResponseRedecide monthsSinceBadDebtWriteOff: ' + decResp.monthsSinceBadDebtWriteOff);    
        
        system.debug('parseResponseRedecide appStrategyTier: ' + decResp.appStrategyTier);
    }
    
    // The birth date we receive should be in the following format: Sat Mar 01 00:00:00 EST 1980
    public static Date parseDecisionResponseBirthDate(String birthDateStr) {
        Date birthDate = null;
        try {
            String[] dtStr = birthDateStr.split(' '); 
            birthDate = Date.newInstance(Integer.valueOf(dtStr[5]), Integer.valueOf(getMonthNumber(dtStr[1])), Integer.valueOf(dtStr[2]));
        } catch (Exception e) {
        }
        return birthDate;
    }
    
    //Get Month Number for given Month Name
    private static String getMonthNumber(String monthName) {
        
        Map<String, String> monthMap = new Map<String, String>();
        monthMap.put('Jan','1');
        monthMap.put('Feb','2');
        monthMap.put('Mar','3');
        monthMap.put('Apr','4');
        monthMap.put('May','5');
        monthMap.put('Jun','6');
        monthMap.put('Jul','7');
        monthMap.put('Aug','8');
        monthMap.put('Sep','9');
        monthMap.put('Oct','10');
        monthMap.put('Nov','11');
        monthMap.put('Dec','12');
        
        return monthMap.get(monthName);
    }   
    
    @TestVisible
    private static void createDecisionResultDecisionMap(){
        decisionResultDecisionMap.put('Appr Not Dis','Approved');
        decisionResultDecisionMap.put('Appr OfferCd','Approved');
        decisionResultDecisionMap.put('Approved','Approved');
        decisionResultDecisionMap.put('AppvAFSI','Approved');
        decisionResultDecisionMap.put('AppvFraud','Approved');
        decisionResultDecisionMap.put('AppvScript','Approved');
        decisionResultDecisionMap.put('Auto App','Approved');
        decisionResultDecisionMap.put('BKCP Rev','Approved');
        decisionResultDecisionMap.put('CC Create','Completed');
        decisionResultDecisionMap.put('Completed','Completed');
        decisionResultDecisionMap.put('Decline Dec','Declined');
        decisionResultDecisionMap.put('Declined','Declined');
        decisionResultDecisionMap.put('EmailAuthSent','Approved');
        decisionResultDecisionMap.put('NotDischFraud','Approved');
        decisionResultDecisionMap.put('Refer','Referred');
        decisionResultDecisionMap.put('Refer Dec','Referred');
        decisionResultDecisionMap.put('Refer Fraud','Referred');
        decisionResultDecisionMap.put('WaitLnDoc','Approved');
        decisionResultDecisionMap.put('WaitLnDocPass','Approved');
    }
    
    @TestVisible
    private static void createDecisionApplicationStatusMap(){
        decisionApplicationStatusMap.put('Analyst Decline','Analyst Declined');
        decisionApplicationStatusMap.put('Approved-AFSI Scripting','AFSI Scripting');
        decisionApplicationStatusMap.put('Approved-BKCP Not Disch','BK/CP No Disch');
        decisionApplicationStatusMap.put('Approved-CC Creation','CC Creation');
        decisionApplicationStatusMap.put('Approved-Email-Auth Sent','Email-Auth Sent');
        decisionApplicationStatusMap.put('Approved-Fraud Investigation','Fraud Investigation');
        decisionApplicationStatusMap.put('Approved-Offer Code','Manager Approval');
        decisionApplicationStatusMap.put('Approved-Scripting Required','Scripting Required');
        decisionApplicationStatusMap.put('Approved-Waiting for Loan Docs','Waiting for Loan Docs');
        decisionApplicationStatusMap.put('Approved-Waiting for Loan Docs-Auth Passed','Waiting for Loan Docs - Auth Passed');
        decisionApplicationStatusMap.put('Auto Approved','Auto Approved');
        decisionApplicationStatusMap.put('BK/CP Review','Review');
        decisionApplicationStatusMap.put('CC Creation','CC Creation');
        decisionApplicationStatusMap.put('CLI Scripting','CLI Scripting');
        decisionApplicationStatusMap.put('Completed - CLI','Completed - CLI');
        decisionApplicationStatusMap.put('Completed - CC & Loan','Not Used');
        decisionApplicationStatusMap.put('Completed - Credit Card','Completed - Credit Card');
        decisionApplicationStatusMap.put('Completed - Loan','Completed - Loan');
        decisionApplicationStatusMap.put('Completed ? CLI','Completed - CLI');
        decisionApplicationStatusMap.put('Conditional','Conditional');
        decisionApplicationStatusMap.put('Declined','System Declined');
        decisionApplicationStatusMap.put('Duplicate','Duplicate');
        decisionApplicationStatusMap.put('Expired','Expired');
        decisionApplicationStatusMap.put('Final Review','Review');
        decisionApplicationStatusMap.put('Fraud Investigation','Fraud Investigation');
        decisionApplicationStatusMap.put('Refer','Review');
        decisionApplicationStatusMap.put('Refer-Fraud Investigation','Fraud Investigation');
        decisionApplicationStatusMap.put('Review','Review');
        decisionApplicationStatusMap.put('Scripting Required','Scripting Required');
        decisionApplicationStatusMap.put('System Declined','System Declined');
        decisionApplicationStatusMap.put('Waiting for Loan Docs','Waiting for Loan Docs');
        decisionApplicationStatusMap.put('Waiting for Loan Docs - Auth Passed','Waiting for Loan Docs - Auth Passed');        
        
        //New Application Status provided by Experian
        decisionApplicationStatusMap.put('Approved-Expired','Expired');
        decisionApplicationStatusMap.put('Completed-Completed - Credit Card','Completed - Credit Card');
        decisionApplicationStatusMap.put('Completed-Completed - CLI','Completed - CLI');
        //decisionApplicationStatusMap.put('Completed-Completed – Loan','Completed - Loan');
        decisionApplicationStatusMap.put('Completed-Completed - Loan','Completed - Loan');
        decisionApplicationStatusMap.put('Declined-Analyst Decline','Analyst Declined');
    }
    
    @TestVisible
    private static String getStreetName(String addPOBox, String addStreetName){
        String addrsStreetName = addStreetName;
        if(String.isNotBlank(addPOBox)){
            addrsStreetName = addPOBox + ' ' + addrsStreetName;
        }
        return addrsStreetName;
    }
    
    //Underwriting Rules for 4 Pillars - Updates for Tier Type
    private static String getTierTypeForRefCode(String refCode){
        String tierType = '';
        if(String.isNotBlank(refCode)){
            Preferred_Partners__c prefPartnr;
            try{
                //Custom Setting Name Limit Work Around
                if(refCode.length() > 38){
                    prefPartnr = Preferred_Partners__c.getValues((refCode.subString(0,38)).toLowerCase());     
                }
                else{
                    prefPartnr = Preferred_Partners__c.getValues(refCode.toLowerCase());
                }
            }
            catch(Exception exp){
                System.debug('Exception in getTierTypeForRefCode :'+exp);
            } 
            
            if(prefPartnr != null){
                tierType = prefPartnr.Tier_Type__c;
                
                if(String.isNotBlank(prefPartnr.Tier_Type__c)){
                    tierType = prefPartnr.Tier_Type__c;
                }
                
                if(String.isNotBlank(tierType) && tierType.equalsIgnoreCase('Default')){
                    tierType = '';
                }
            } 
        }
        
        return tierType;
    }
    /*
    @TestVisible
    private static String getCivicNumber(String addPOBox, String addStreetNumber){
        String addrsCivicNumber = addStreetNumber;
        if(String.isNotBlank(addPOBox)){
            addrsCivicNumber = addPOBox + ' ' + addrsCivicNumber;
        }
        return addrsCivicNumber;
    }
    */
}