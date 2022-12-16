public with sharing class PowerCurveTestUtilities {
    public static final String Power_Curve_Web_Service_URL = 'https://pcunittest.unittest.ca/Integration/IntegrationService';
    public static final String Power_Curve_Username = 'AFIUnitTester';
    public static final String Power_Curve_Password = 'unittestpassword';
        
    public class PowerCurveRequestMock implements HttpCalloutMock {
        
        private String calloutResponse;
        private Integer calloutStatusCode;
        
        public PowerCurveRequestMock(String resp, Integer sc) {
            calloutResponse = resp;
            calloutStatusCode = sc;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(calloutResponse);
            res.setStatusCode(calloutStatusCode);
            return res;
        }
    }
    
    public static PowerCurveRequestMock getMockAcceptResponse() {
        return new PowerCurveRequestMock(acceptResponse, 200);
    }
    
    public static PowerCurveRequestMock getMockReferResponse() {
         return new PowerCurveRequestMock(referResponse, 200);
    }
    
    //Email Authentication
    //Final Submit Correct Response
    public static PowerCurveRequestMock getMockFullResponse() {
         return new PowerCurveRequestMock(acceptResponseFull, 200);
    }
    
    //Email Authentication
    //Final Submit In-Correct Response
    public static PowerCurveRequestMock getMockFullIncorrectResponse() {
         return new PowerCurveRequestMock(acceptResponseIncorrectFull, 200);
    }
    
    public static PowerCurveRequestMock getMockDeclineResponse() {
         return new PowerCurveRequestMock(declineResponse, 200);
    }  

    public static PowerCurveRequestMock getMockErrorResponse() {
         return new PowerCurveRequestMock(errorResponse, 200);
    }    
    
    public static void verifyReferResponse(PowerCurveWSUtil.DecisionResponse dr) {
        system.assertEquals(null, dr.ErrorMessage);
        system.assertEquals('AFI1332', dr.CustomerRequestId);
        system.assertEquals('Referred', dr.decision);
        system.assertEquals('Review', dr.applicationStatus);
        system.assert(dr.DecisionTimestamp != null);
        
    }
    
    public static void verifyFullResponse(PowerCurveWSUtil.DecisionResponse dr) {
        system.assertEquals(null, dr.ErrorMessage);
        system.assertEquals('AFI1234', dr.CustomerRequestId);
        system.assertEquals('Approved', dr.decision);
        system.assertEquals('Auto Approved', dr.applicationStatus);
        system.assert(dr.DecisionTimestamp != null);        
    }
    
    public static void verifyFullIncorrectResponse(PowerCurveWSUtil.DecisionResponse dr) {
        system.assertEquals(null, dr.ErrorMessage);
        system.assertEquals('AFI1234', dr.CustomerRequestId);
        system.assertEquals(null, dr.decision);
        system.assertEquals(null, dr.applicationStatus);
        system.assert(dr.DecisionTimestamp != null);        
    }
        
    public static void verifyErrorResponse(PowerCurveWSUtil.DecisionResponse dr) {
        system.assert(dr.ErrorMessage != null);
        system.assert(String.isBlank(dr.CustomerRequestId));
        system.assertEquals(null, dr.decision);
        system.assertEquals(null, dr.applicationStatus);
        system.assertEquals(null, dr.DecisionTimestamp);    
        
    }
    
    /* Mock responses */
    
    public static String acceptResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>' + 
    '<ns2:invokeIntegrationServiceFromSTSResponse xmlns:ns2="http://service.integration.ds.com/"><return>&lt;?xml version="1.0"?>' + 
    '&lt;DecisionResponse>' + 
        '&lt;CustomerRequestID>AFI1111&lt;/CustomerRequestID>' +
        '&lt;SourceApplicationID>312&lt;/SourceApplicationID>' +
        '&lt;DSTransactionID>1438220512468&lt;/DSTransactionID>' +
        '&lt;SystemDateTime>2015-07-29T21:42:22&lt;/SystemDateTime>' +
        '&lt;Decisions>' +
            '&lt;Decision>&lt;DecisionNode>MaxCC HO&lt;/DecisionNode>&lt;Name>1500&lt;/Name>&lt;Description>1500&lt;/Description>&lt;Limit>1500.0&lt;/Limit>&lt;Deposit>1500.0&lt;/Deposit>&lt;/Decision>' +
            '&lt;Decision>&lt;DecisionNode>Max CC NHO&lt;/DecisionNode>&lt;Name>2000&lt;/Name>&lt;Description>2000&lt;/Description>&lt;Limit>2000.0&lt;/Limit>&lt;Deposit>2000.0&lt;/Deposit>&lt;/Decision>' +
            '&lt;Decision>&lt;DecisionNode>RiskPr HO&lt;/DecisionNode>&lt;Name>39&lt;/Name>&lt;Description>39&lt;/Description>&lt;Limit>39.0&lt;/Limit>&lt;Deposit>39.0&lt;/Deposit>&lt;/Decision>' +
            '&lt;Decision>&lt;DecisionNode>RiskPr NHO&lt;/DecisionNode>&lt;Name>39&lt;/Name>&lt;Description>39&lt;/Description>&lt;Limit>39.0&lt;/Limit>&lt;Deposit>39.0&lt;/Deposit>&lt;/Decision>' +
            '&lt;Decision>&lt;DecisionNode>Approved&lt;/DecisionNode>&lt;Name>Refer&lt;/Name>&lt;Description>Refer&lt;/Description>&lt;Limit>0.0&lt;/Limit>&lt;Deposit>0.0&lt;/Deposit>&lt;/Decision>' +
        '&lt;/Decisions>' +
        '&lt;Scores/>' + 
        '&lt;DerivedVariables>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>OMIT_ABS_Today&lt;/Name>&lt;Value>547&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Year today&lt;/Name>&lt;Value>2015.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Today_No of Days&lt;/Name>&lt;Value>-1.0&lt;/Value>&lt;/DerivedVariable>' +
                
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Max_CC_Amt&lt;/Name>&lt;Value>1000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_TCW_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Max_Loan_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Fraud_Alert_Found&lt;/Name>&lt;Value>FALSE&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Applicant_Type&lt;/Name>&lt;Value>Traditional&lt;/Value>&lt;/DerivedVariable>' +
            
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision&lt;/Name>&lt;Value>Approved&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision_Status&lt;/Name>&lt;Value>Refer&lt;/Value>&lt;/DerivedVariable>' +
            
                
            '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>3 Months ago&lt;/Name>&lt;Value>Wed Apr 29 17:02:03 EDT 2015&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>6 Months ago&lt;/Name>&lt;Value>Thu Jan 29 17:02:03 EST 2015&lt;/Value>&lt;/DerivedVariable>' +
        '&lt;/DerivedVariables>' +
    '&lt;/DecisionResponse>' +
    '</return></ns2:invokeIntegrationServiceFromSTSResponse></soap:Body></soap:Envelope>';
    
    public static String referResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>' + 
        '<ns2:invokeIntegrationServiceFromSTSResponse xmlns:ns2="http://service.integration.ds.com/"><return>&lt;?xml version="1.0"?>' + 
        '&lt;DecisionResponse>' + 
            '&lt;CustomerRequestID>AFI1332&lt;/CustomerRequestID>' +
            '&lt;SourceApplicationID>312&lt;/SourceApplicationID>' +
            '&lt;DSTransactionID>1438220512468&lt;/DSTransactionID>' +
            '&lt;SystemDateTime>2015-07-29T21:42:22&lt;/SystemDateTime>' +
            '&lt;Decisions>' +
                '&lt;Decision>&lt;DecisionNode>MaxCC HO&lt;/DecisionNode>&lt;Name>1500&lt;/Name>&lt;Description>1500&lt;/Description>&lt;Limit>1500.0&lt;/Limit>&lt;Deposit>1500.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>Max CC NHO&lt;/DecisionNode>&lt;Name>2000&lt;/Name>&lt;Description>2000&lt;/Description>&lt;Limit>2000.0&lt;/Limit>&lt;Deposit>2000.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>RiskPr HO&lt;/DecisionNode>&lt;Name>39&lt;/Name>&lt;Description>39&lt;/Description>&lt;Limit>39.0&lt;/Limit>&lt;Deposit>39.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>RiskPr NHO&lt;/DecisionNode>&lt;Name>39&lt;/Name>&lt;Description>39&lt;/Description>&lt;Limit>39.0&lt;/Limit>&lt;Deposit>39.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>Refer Dec&lt;/DecisionNode>&lt;Name>Refer&lt;/Name>&lt;Description>Refer&lt;/Description>&lt;Limit>0.0&lt;/Limit>&lt;Deposit>0.0&lt;/Deposit>&lt;/Decision>' +
            '&lt;/Decisions>' +
            '&lt;Scores/>' + 
            '&lt;DerivedVariables>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>OMIT_ABS_Today&lt;/Name>&lt;Value>547&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Year today&lt;/Name>&lt;Value>2015.0&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Today_No of Days&lt;/Name>&lt;Value>-1.0&lt;/Value>&lt;/DerivedVariable>' +
                
                '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision&lt;/Name>&lt;Value>Refer Dec&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision_Status&lt;/Name>&lt;Value>Refer&lt;/Value>&lt;/DerivedVariable>' +
            
            
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Max_CC_Amt&lt;/Name>&lt;Value>1000&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_TCW_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Max_Loan_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Fraud_Alert_Found&lt;/Name>&lt;Value>FALSE&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Applicant_Type&lt;/Name>&lt;Value>Traditional&lt;/Value>&lt;/DerivedVariable>' +
                
                '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>3 Months ago&lt;/Name>&lt;Value>Wed Apr 29 17:02:03 EDT 2015&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>6 Months ago&lt;/Name>&lt;Value>Thu Jan 29 17:02:03 EST 2015&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;/DerivedVariables>' +
        '&lt;/DecisionResponse>' +
        '</return></ns2:invokeIntegrationServiceFromSTSResponse></soap:Body></soap:Envelope>';
        
    public static String declineResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>' + 
        '<ns2:invokeIntegrationServiceFromSTSResponse xmlns:ns2="http://service.integration.ds.com/"><return>&lt;?xml version="1.0"?>' + 
        '&lt;DecisionResponse>' + 
            '&lt;CustomerRequestID>AFI2222&lt;/CustomerRequestID>' +
            '&lt;SourceApplicationID>312&lt;/SourceApplicationID>' +
            '&lt;DSTransactionID>1438220512468&lt;/DSTransactionID>' +
            '&lt;SystemDateTime>2015-07-29T21:42:22&lt;/SystemDateTime>' +
            '&lt;Decisions>' +
                '&lt;Decision>&lt;DecisionNode>MaxCC HO&lt;/DecisionNode>&lt;Name>1500&lt;/Name>&lt;Description>1500&lt;/Description>&lt;Limit>1500.0&lt;/Limit>&lt;Deposit>1500.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>Max CC NHO&lt;/DecisionNode>&lt;Name>2000&lt;/Name>&lt;Description>2000&lt;/Description>&lt;Limit>2000.0&lt;/Limit>&lt;Deposit>2000.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>RiskPr HO&lt;/DecisionNode>&lt;Name>39&lt;/Name>&lt;Description>39&lt;/Description>&lt;Limit>39.0&lt;/Limit>&lt;Deposit>39.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>RiskPr NHO&lt;/DecisionNode>&lt;Name>39&lt;/Name>&lt;Description>39&lt;/Description>&lt;Limit>39.0&lt;/Limit>&lt;Deposit>39.0&lt;/Deposit>&lt;/Decision>' +
                '&lt;Decision>&lt;DecisionNode>Decline Dec&lt;/DecisionNode>&lt;Name>Refer&lt;/Name>&lt;Description>Refer&lt;/Description>&lt;Limit>0.0&lt;/Limit>&lt;Deposit>0.0&lt;/Deposit>&lt;/Decision>' +
            '&lt;/Decisions>' +
            '&lt;Scores/>' + 
            '&lt;DerivedVariables>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>OMIT_ABS_Today&lt;/Name>&lt;Value>547&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Year today&lt;/Name>&lt;Value>2015.0&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Today_No of Days&lt;/Name>&lt;Value>-1.0&lt;/Value>&lt;/DerivedVariable>' +
                
                '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision&lt;/Name>&lt;Value>Decline Dec&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision_Status&lt;/Name>&lt;Value>Refer&lt;/Value>&lt;/DerivedVariable>' +
            
                
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Max_CC_Amt&lt;/Name>&lt;Value>1000&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_TCW_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Max_Loan_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Fraud_Alert_Found&lt;/Name>&lt;Value>FALSE&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Applicant_Type&lt;/Name>&lt;Value>Traditional&lt;/Value>&lt;/DerivedVariable>' +
                
                '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>3 Months ago&lt;/Name>&lt;Value>Wed Apr 29 17:02:03 EDT 2015&lt;/Value>&lt;/DerivedVariable>' +
                '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>6 Months ago&lt;/Name>&lt;Value>Thu Jan 29 17:02:03 EST 2015&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;/DerivedVariables>' +
        '&lt;/DecisionResponse>' +
        '</return></ns2:invokeIntegrationServiceFromSTSResponse></soap:Body></soap:Envelope>';

    public static String errorResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>' + 
        '<ns2:invokeIntegrationServiceFromSTSResponse xmlns:ns2="http://service.integration.ds.com/"><return>&lt;?xml version="1.0" encoding="UTF-8"?>' + 
        '&lt;DecisionResponse>' + 
            '&lt;CustomerRequestID/>' + 
            '&lt;Error>' + 
                '&lt;Type>SubmissionFailure&lt;/Type>' + 
                '&lt;Code>599&lt;/Code>' + 
                '&lt;Message>Error Reason No match found for tag [&amp;amp;lt;PreferredMethod&amp;amp;gt;], code [Mobile/Cell Phone], Refer CustomerRequestId [], Reference [ERT14O9QAP] and DateTime [Wed Jul 29 22:45:04 EDT 2015]&lt;/Message>' + 
                '&lt;Description>Error processing application&lt;/Description>' + 
                '&lt;ReferenceNumber>ERT14O9QAP&lt;/ReferenceNumber>' + 
            '&lt;/Error>' + 
        '&lt;/DecisionResponse>' + 
        '</return></ns2:invokeIntegrationServiceFromSTSResponse></soap:Body></soap:Envelope>';
        
    
    public static String acceptResponseFull = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>' + 
        '<ns2:invokeIntegrationServiceFromSTSResponse xmlns:ns2="http://service.integration.ds.com/"><return>&lt;?xml version="1.0"?>' + 
        '&lt;DecisionResponse>' + 
            '&lt;CustomerRequestID>AFI1234&lt;/CustomerRequestID>' +
            '&lt;SourceApplicationID>312&lt;/SourceApplicationID>' +
            '&lt;DSTransactionID>1438220512468&lt;/DSTransactionID>' +
            '&lt;SystemDateTime>2015-07-29T21:42:22&lt;/SystemDateTime>' +
            '&lt;Scores/>' + 
            '&lt;DerivedVariables>' +
            
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_ProgramId&lt;/Name>&lt;Value>73318&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_ProgramName&lt;/Name>&lt;Value>Credit Card&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>App_ProgramProductIdd&lt;/Name>&lt;Value>3779&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_ProgramProductName&lt;/Name>&lt;Value>Affirm Card&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ProgramProductTierId&lt;/Name>&lt;Value>1301&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ProgramProductTierName&lt;/Name>&lt;Value>MasterCard&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_SalesChannelId&lt;/Name>&lt;Value>163&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_SalesChannelName&lt;/Name>&lt;Value>Affirm Website&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_SourceLenderId&lt;/Name>&lt;Value>AFI&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_LenderDealerId&lt;/Name>&lt;Value>A901&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_DealerId&lt;/Name>&lt;Value>8210&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Type&lt;/Name>&lt;Value>Primary Applicant&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_FirstName&lt;/Name>&lt;Value>George&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_MiddleName&lt;/Name>&lt;Value>Thomas&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_LastName&lt;/Name>&lt;Value>Ytwokfour&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_PreferredLanguage&lt;/Name>&lt;Value>English - Canada&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_PrimaryIdType&lt;/Name>&lt;Value>SIN&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_PrimaryIdValue&lt;/Name>&lt;Value>123456789&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>Cons1_DOB&lt;/Name>&lt;Value>Sat Mar 01 00:00:00 EST 1980&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Email&lt;/Name>&lt;Value>george@ggmail.com&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_BKCP&lt;/Name>&lt;Value>True&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_AmountRequested&lt;/Name>&lt;Value>10.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Gender&lt;/Name>&lt;Value>M&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_PreferredMethod&lt;/Name>&lt;Value>Home Phone&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_MaritalStatus&lt;/Name>&lt;Value>Single&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_Type_Current&lt;/Name>&lt;Value>Physical&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_CivicNbr_Current&lt;/Name>&lt;Value>170&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_StreetName_Current&lt;/Name>&lt;Value>Jackson St E&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_SuiteNbr_Current&lt;/Name>&lt;Value>240&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_City_Current&lt;/Name>&lt;Value>Hamilton&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_ProvinceCd_Current&lt;/Name>&lt;Value>ON&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_PostalCd_Current&lt;/Name>&lt;Value>L8N1L4&lt;/Value>&lt;/DerivedVariable>' +         
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_CountryCd_Current&lt;/Name>&lt;Value>CA&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Addr_LengthResYrs_Current&lt;/Name>&lt;Value>3&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Addr_LengthResMths_Current&lt;/Name>&lt;Value>7&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_ResidentStatus_Current&lt;/Name>&lt;Value>Own Property&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Addr_Status_Current&lt;/Name>&lt;Value>Current&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerName_Current&lt;/Name>&lt;Value>ABCD&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerPhone_Current&lt;/Name>&lt;Value>(905)383-2000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerAddrLine1_Current&lt;/Name>&lt;Value>5 Beacon Avenue W&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerAddrLine2_Current&lt;/Name>&lt;Value>Suite 100&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerCity_Current&lt;/Name>&lt;Value>Hamilton&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerProvinceCd_Current&lt;/Name>&lt;Value>ON&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmployerPostalCd_Current&lt;/Name>&lt;Value>L8T2N4&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Emp_IncomeInterval_Current&lt;/Name>&lt;Value>Monthly&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_EmpYears_Current&lt;/Name>&lt;Value>5&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_EmpMonths_Current&lt;/Name>&lt;Value>1&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Emp_GrossMthlyIncome_Current&lt;/Name>&lt;Value>5000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_EmpStatus_Current&lt;/Name>&lt;Value>Full-time&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision&lt;/Name>&lt;Value>Approved&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Decision_Status&lt;/Name>&lt;Value>Auto Approved&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>App_Scorecard&lt;/Name>&lt;Value>Credit Card&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_DSR (Post-credit)&lt;/Name>&lt;Value>16.7&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>DS_Cons1_CBScore&lt;/Name>&lt;Value>604&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>AS_Cons1_Housing&lt;/Name>&lt;Value>800.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Total monthly debt&lt;/Name>&lt;Value>800.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>Cons1_Total_Income&lt;/Name>&lt;Value>5000.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_TCW_Amt&lt;/Name>&lt;Value>3000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Max_CC_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Fraud_Alert_Found&lt;/Name>&lt;Value>True&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>Cons1_Applicant_Type&lt;/Name>&lt;Value>Traditional&lt;/Value>&lt;/DerivedVariable>' +
                            
            '&lt;/DerivedVariables>' +
        '&lt;/DecisionResponse>' +
        '</return></ns2:invokeIntegrationServiceFromSTSResponse></soap:Body></soap:Envelope>';  
        
        public static String acceptResponseIncorrectFull = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>' + 
        '<ns2:invokeIntegrationServiceFromSTSResponse xmlns:ns2="http://service.integration.ds.com/"><return>&lt;?xml version="1.0"?>' + 
        '&lt;DecisionResponse>' + 
            '&lt;CustomerRequestID>AFI1234&lt;/CustomerRequestID>' +
            '&lt;SourceApplicationID>312&lt;/SourceApplicationID>' +
            '&lt;DSTransactionID>1438220512468&lt;/DSTransactionID>' +
            '&lt;SystemDateTime>2015-07-29T21:42:22&lt;/SystemDateTime>' +
            '&lt;Scores/>' + 
            '&lt;DerivedVariables>' +
            
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_ProgramId&lt;/Name>&lt;Value>73318&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_ProgramName&lt;/Name>&lt;Value>Credit Card&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>EApp_ProgramProductIdd&lt;/Name>&lt;Value>3779&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_ProgramProductName&lt;/Name>&lt;Value>Affirm Card&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EProgramProductTierId&lt;/Name>&lt;Value>1301&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EProgramProductTierName&lt;/Name>&lt;Value>MasterCard&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_SalesChannelId&lt;/Name>&lt;Value>163&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_SalesChannelName&lt;/Name>&lt;Value>Affirm Website&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_SourceLenderId&lt;/Name>&lt;Value>AFI&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_LenderDealerId&lt;/Name>&lt;Value>A901&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_DealerId&lt;/Name>&lt;Value>8210&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Type&lt;/Name>&lt;Value>Primary Applicant&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_FirstName&lt;/Name>&lt;Value>George&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_MiddleName&lt;/Name>&lt;Value>Thomas&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_LastName&lt;/Name>&lt;Value>Ytwokfour&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_PreferredLanguage&lt;/Name>&lt;Value>English - Canada&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_PrimaryIdType&lt;/Name>&lt;Value>SIN&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_PrimaryIdValue&lt;/Name>&lt;Value>123456789&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Date" disposition="external">&lt;Name>ECons1_DOB&lt;/Name>&lt;Value>Sat Mar 01 00:00:00 EST 1980&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Email&lt;/Name>&lt;Value>george@ggmail.com&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_BKCP&lt;/Name>&lt;Value>True&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_AmountRequested&lt;/Name>&lt;Value>10.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Gender&lt;/Name>&lt;Value>M&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_PreferredMethod&lt;/Name>&lt;Value>Home Phone&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_MaritalStatus&lt;/Name>&lt;Value>Single&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_Type_Current&lt;/Name>&lt;Value>Physical&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_CivicNbr_Current&lt;/Name>&lt;Value>170&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_StreetName_Current&lt;/Name>&lt;Value>Jackson St E&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_SuiteNbr_Current&lt;/Name>&lt;Value>240&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_City_Current&lt;/Name>&lt;Value>Hamilton&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_ProvinceCd_Current&lt;/Name>&lt;Value>ON&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_PostalCd_Current&lt;/Name>&lt;Value>L8N1L4&lt;/Value>&lt;/DerivedVariable>' +            
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_CountryCd_Current&lt;/Name>&lt;Value>CA&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_Addr_LengthResYrs_Current&lt;/Name>&lt;Value>3&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_Addr_LengthResMths_Current&lt;/Name>&lt;Value>7&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_ResidentStatus_Current&lt;/Name>&lt;Value>Own Property&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Addr_Status_Current&lt;/Name>&lt;Value>Current&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerName_Current&lt;/Name>&lt;Value>ABCD&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerPhone_Current&lt;/Name>&lt;Value>(905)383-2000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerAddrLine1_Current&lt;/Name>&lt;Value>5 Beacon Avenue W&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerAddrLine2_Current&lt;/Name>&lt;Value>Suite 100&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerCity_Current&lt;/Name>&lt;Value>Hamilton&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerProvinceCd_Current&lt;/Name>&lt;Value>ON&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmployerPostalCd_Current&lt;/Name>&lt;Value>L8T2N4&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Emp_IncomeInterval_Current&lt;/Name>&lt;Value>Monthly&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_EmpYears_Current&lt;/Name>&lt;Value>5&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_EmpMonths_Current&lt;/Name>&lt;Value>1&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_Emp_GrossMthlyIncome_Current&lt;/Name>&lt;Value>5000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_EmpStatus_Current&lt;/Name>&lt;Value>Full-time&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_Decision&lt;/Name>&lt;Value>Approved&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_Decision_Status&lt;/Name>&lt;Value>Auto Approved&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>EApp_Scorecard&lt;/Name>&lt;Value>Credit Card&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_DSR (Post-credit)&lt;/Name>&lt;Value>16.7&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>EDS_Cons1_CBScore&lt;/Name>&lt;Value>604&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>EAS_Cons1_Housing&lt;/Name>&lt;Value>800.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_Total monthly debt&lt;/Name>&lt;Value>800.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="Number" disposition="external">&lt;Name>ECons1_Total_Income&lt;/Name>&lt;Value>5000.0&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_TCW_Amt&lt;/Name>&lt;Value>3000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Max_Loan_Amt&lt;/Name>&lt;Value>3000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Max_CC_Amt&lt;/Name>&lt;Value>2000&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Fraud_Alert_Found&lt;/Name>&lt;Value>True&lt;/Value>&lt;/DerivedVariable>' +
            '&lt;DerivedVariable dataType="String" disposition="external">&lt;Name>ECons1_Applicant_Type&lt;/Name>&lt;Value>Traditional&lt;/Value>&lt;/DerivedVariable>' +
                            
            '&lt;/DerivedVariables>' +
        '&lt;/DecisionResponse>' +
        '</return></ns2:invokeIntegrationServiceFromSTSResponse></soap:Body></soap:Envelope>';  
}