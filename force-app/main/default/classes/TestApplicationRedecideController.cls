/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a test class for ApplicationRedecideController
 *  @author : A5E Consulting
 *  @date : 09/08/2020
 *  
 
 *************************************************************************************************/
@isTest
public class TestApplicationRedecideController {
    private static Application_Form_Configuration__c afc;
    private static Application_Form_Settings__c appFormSettings;
    
    private static Application__c application;
    private static Application__c appln;
    
    static void insertTestData() {
        afc = new Application_Form_Configuration__c();
        afc.AML_Member_Code__c = 'Member_Code';
        afc.AML_Password__c = 'password';
        afc.AML_Product_Code__c = 'Product_Code';
        afc.AML_Route_Type__c = 'Test';
        afc.AML_User_Reference__c = 'MyTest';
        afc.Auth_Endpoint__c = 'authentication'; 
        afc.Client_ID__c = 'Client_ID';
        afc.Client_Secret__c = 'Client_Secret';
        afc.Endpoint__c = 'adjudication'; 
        afc.Error_Text__c = 'B';
        afc.FFR__c = 'Y';
        afc.Grant_Type__c = 'client_credentials';
        afc.Language__c = 'English';
        afc.Member_Code__c = 'Member_Code';
        afc.Owning_Bureau__c = 'Y';
        afc.Password__c = 'Password';
        afc.Product__c = 'Product';
        afc.RouteDest__c = 'Canada';
        afc.RouteType__c = 'Test';
        afc.Scope__c = 'Scope';
        afc.Summary__c = 'Y';
        afc.TradeMop__c = 'Y';
        afc.UserReference__c = 'TEST';
        afc.Timeout_for_Webservice__c = 30000;        
        insert afc;
        
        appFormSettings = new Application_Form_Settings__c();
        appFormSettings.Minimum_Employment_Length__c = 12;
        insert appFormSettings;
        
        Date testBirthDate = System.today().addYears(-30);
        application = new Application__c();
        application.Salutation__c = 'Ms.';
        application.First_Name__c = 'Test';
        application.Last_Name__c = 'Email';
        application.Birth_Date__c = testBirthDate;
        application.Email_Address__c = 'abc@test.com';
        application.Employment_Status__c = 'Full-time  ';
        application.Verification_Status__c = 'Email Sent – Analyst';
        application.Number_of_Dependants__c = '3';
        application.Home_Owner__c = 'Own Property';
        application.Housing_Costs__c = 20;
        application.Monthly_Expenses__c = 40;
        application.Gross_Monthly_Income__c = 20;
        application.Employment_Years__c = 3;
        application.Permanent_Address_Street_Number__c = '123';
        application.Permanent_Address_Street_Name__c = 'Test Street';
        application.Permanent_Address_City__c = 'Test';
        application.Permanent_Address_PostalCode__c = '12345';
        application.Permanent_Address_Province__c = 'Test';
        application.Home_Phone__c = '123456';
        application.Cell_Phone__c = '123456';
        application.Work_Phone__c = '123456';
        application.Marital_Status__c = 'Married';
        application.Employment_Months__c = 3;
        insert application;
        
    }
    
    public static testMethod void testApplicationResubmit1(){
        //Inert test Data
        insertTestData();
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    public static testMethod void testApplicationResubmit2(){
        //Inert test Data
        insertTestData();
        //to throw exception
        application.CurrentBKCP__c = 'None';
        update application;
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    public static testMethod void testApplicationResubmit3(){
        //Inert test Data
        insertTestData();
        //to throw exception
        application.Decision__c = 'Needs Review';
        update application;
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    public static testMethod void testApplicationResubmit4(){
        //Inert test Data
        insertTestData();
        //to throw exception
        application.SIN__c = '98888';
        update application;
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    public static testMethod void testApplicationResubmit5(){
        //Inert test Data
        insertTestData();
        //to throw exception
        application.AML_Response__c = '<BureauHit>Y</BureauHit>';
        application.Webservice_Response__c = '<Hit>Y</Hit>';
        update application;
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        //Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    //Employment Length
    public static testMethod void testApplicationResubmitEmplyment(){
        //Inert test Data
        insertTestData();
        
        application.Employment_Years__c = 0;
        application.Employment_Months__c = 5;
        application.Previous_Employment_Years__c = 0;
        application.Previous_Employment_Months__c = 6;
        update application;
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    //NO BKCP
    public static testMethod void testApplicationResubmitNoBKCP(){
        //Inert test Data
        insertTestData();        
        application.CurrentBKCP__c = 'None';
        update application;
        
        Test.startTest();
        //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //Set Test page
        PageReference pageRef = Page.ApplicationReSubmit;
        Test.setCurrentPage(pageRef);
        system.debug('application: '+application);
        ApexPages.currentPage().getParameters().put('id', application.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(application);
        ApplicationRedecideController controller = new ApplicationRedecideController(sc);
        //method call
        controller.reDecide();
        //controller.declineReasonValue('ANNUAL_INCOME_FAILED');
        Test.stopTest();
    }
    
    
    
    Static string mockWebServiceStringBody(){
        String body = '{"REL4Report":"<REL4Report><UserReference>TEST'+
            '</UserReference><MemberCode>975ZZ60043</MemberCode><Date>20200310</Date><Time>183447</Time><Product>07000'+
            '</Product><TU_FFR_Report><Hit>Y</Hit><OnFileDate>19871102</OnFileDate><Names><Name>'+
            '<LastName>ISABELL</LastName><FirstName>FERNANDO</FirstName></Name><Name><LastName>ISABELL'+
            '</LastName><FirstName>FERN</FirstName></Name></Names><PersonalInformation><SIN>000000000</SIN><DOB>19550825'+
            '</DOB></PersonalInformation><TransAlerts><TransAlert><Code>0</Code><Text>CLEAR</Text></TransAlert></TransAlerts>'+
            '<Addresses><Address><Street>170 JACKSON ST E</Street><City>HAMILTON</City><Prov>ON</Prov>'+
            '<Postal>L8N1L4</Postal><DateReported>20050501</DateReported></Address></Addresses><Telephones><Telephone> '+
            '<Number>9053185555</Number></Telephone></Telephones><Employments><Employment><EmpName>'+
            'THE MILL STORE</EmpName><DateSeparated>00000000</DateSeparated><DateVerified>00000000</DateVerified><Income>0'+
            '</Income></Employment><Employment><EmpName>THE HOLIDAY INN</EmpName><DateSeparated>00000000</DateSeparated>'+
            '<DateVerified>00000000</DateVerified><Income>0</Income></Employment></Employments><Bankruptcies><Bankruptcy>'+
            '<DateRevised>20200301</DateRevised><Reference>32049979</Reference><FilingNumber>32-049979</FilingNumber>'+
            '<DateReported>20171101</DateReported><DateDischarged>20190124</DateDischarged><Assets>1000</Assets><Liabilities>'+
            '51600</Liabilities><Narrative>BK</Narrative><StatusCode>BD</StatusCode><TrusteeName>SCOTT &amp; PICHELLI LTD'+
            '</TrusteeName><TrusteeCompany>3600 BILLINGS CT BURLINGTON</TrusteeCompany></Bankruptcy></Bankruptcies><Messages>'+
            '<Message><Code>000045</Code><Text>CURRENT ADDRESS IS REPORTED AS MISUSED (BY VICTIM)</Text></Message></Messages>'+
            '<ScoreProducts><ScoreProduct><Product>00093</Product><Score>576</Score><ScoreDerogatoryAlert>A'+
            '</ScoreDerogatoryAlert><Factor1>43</Factor1><Factor2>45</Factor2><Factor3>22</Factor3><Factor4>0'+
            '</Factor4><ScoreCard>03</ScoreCard></ScoreProduct></ScoreProducts></TU_FFR_Report></REL4Report>"'+
            ',"dPricing":[{"maximumCreditAmount":500.0,"interestRate":34.99}],"IFSXMLRs":"'+
            '<IFSXML><UserReference>MyTest</UserReference><UniqueID>000000005254</UniqueID>'+
            '<AML><AMLBureau>Y</AMLBureau><AMLDirserv></AMLDirserv><BureauHit>N</BureauHit><LastName>Y</LastName>'+
            '<FirstName>Y</FirstName><MiddleName>Y</MiddleName><Civic>X</Civic><Street>Y</Street><Apt>Y</Apt><City>'+
            'Y</City><Prov>Y</Prov><Postal>Y</Postal><Telephone>Y</Telephone><DOB>Y</DOB><SIN>X</SIN><FraudFlag>Y'+
            '</FraudFlag><AMLCivic>170</AMLCivic></AML><ConsumerStatement><Type>2</Type><Text>test</Text></ConsumerStatement></IFSXML>"}';
        
        
        return body;
    }
    
    Static String mockWebServiceAuthenticationString(){
        String authBody = '{"token_type":"test","expires_in":"","ext_expires_in":"","access_token":"test"}';
        
        return authBody;
    }
}