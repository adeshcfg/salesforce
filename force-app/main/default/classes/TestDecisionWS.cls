/**************************************************************************************************
*
*  Class:   
*
*  @description : This class for test code coverage for the Adjudication and AML web service
*  @author : A5E Consulting
*  @date : 03/30/2020   
*
*************************************************************************************************/
@isTest
private class TestDecisionWS{

    private static Application_Form_Configuration__c afc;
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
        
        Date testBirthDate = System.today().addYears(-30);
        //Create Account
        TestRecordsFactory.TestAccountWrapper accntWrapper = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper.firstName = 'firstName';
        accntWrapper.lastName = 'lastName';
        accntWrapper.email = 'testuser@testOrg.com';
        accntWrapper.sin = 'dummysin'; 
        accntWrapper.birthDate = testBirthDate;
        Account accnt = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper, true);
        
        //Create Application
        TestRecordsFactory.TestApplicationWrapper applnWrapper = new TestRecordsFactory.TestApplicationWrapper();
        applnWrapper.name = 'RedecideApp';
        applnWrapper.firstName = 'firstName';
        applnWrapper.lastName = 'lastName';
        applnWrapper.email = 'testuser@testOrg.com';
        applnWrapper.sin = 'dummysin';  
        applnWrapper.birthDate = testBirthDate;
        applnWrapper.employmentYear = 3;
        applnWrapper.employmentMonth = 3;
        
        appln = TestRecordsFactory.createApplicationRecordAndInsert(applnWrapper, true);
        
    }

    static testMethod void testMethod1() {
        insertTestData();
        Test.startTest();
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        DecisionWSUtil.IntegrationResponse intResp = DecisionWS.submit(appln, afc);
        system.debug('Response : ' + intResp);
        intResp.adjudicationResponse = '<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>' + intResp.adjudicationResponse;
        system.debug('adjudication Response : ' + intResp);
        intResp = DecisionWS.parseXMLResponseAdjudication(intResp.adjudicationResponse, intResp);
        intResp.amlResponse = '<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>' + intResp.amlResponse;
        intResp = DecisionWS.parseXMLResponseAML(intResp.amlResponse , intResp);
        
        String errorAML = '<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><IFSXML><UserReference>MyTest</UserReference>'+
                        '<Errors><Error>test</Error><Message>Test Message</Message></Errors></IFSXML>';
        intResp = DecisionWS.parseXMLResponseAML(errorAML , intResp);
        
        intResp = DecisionWS.reDecide(appln, afc);
        Test.stopTest();
    }

    @isTest static void testMethod2() {
        insertTestData();
        
        appln.AML_Response__c = '<BureauHit>Y</BureauHit>';
        update appln;
        
        Test.startTest();
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
        HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        DecisionWSUtil.IntegrationResponse intResp = DecisionWS.submit(appln, afc);
        system.debug('Response : ' + intResp);
        intResp.adjudicationResponse = '<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>' + intResp.adjudicationResponse;
        system.debug('adjudication Response : ' + intResp);
        intResp = DecisionWS.parseXMLResponseAdjudication(intResp.adjudicationResponse, intResp);
        intResp.amlResponse = '<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>' + intResp.amlResponse;
        intResp = DecisionWS.parseXMLResponseAML(intResp.amlResponse , intResp);
        
        String errorAML = '<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><IFSXML><UserReference>MyTest</UserReference>'+
                        '<Errors><Error>test</Error><Message>Test Message</Message></Errors></IFSXML>';
        intResp = DecisionWS.parseXMLResponseAML(errorAML , intResp);
        
        intResp = DecisionWS.reDecide(appln, afc);
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