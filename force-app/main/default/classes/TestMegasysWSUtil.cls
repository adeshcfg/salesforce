/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for MegaSys
*  @author : A5E Consulting
*  @date : 08/25/2016   

*************************************************************************************************/
@isTest
public class TestMegasysWSUtil{
    
    private static Loan_ReEngineering__c loanReCS;
    private static Application__c app;
    
    static void insertTestData() {
        
        loanReCS = New  Loan_ReEngineering__c();  
        loanReCS.Megasys_Account_Import_Code__c = 'Affirm Term Loan Import';
        loanReCS.Megasys_Client_Number__c = '420';
        loanReCS.Megasys_End_Point__c = 'https://omegasandbox.megasys.net/Client/WebServices/CustomerPortal.asmx';
        loanReCS.Megasys_Password__c = 'testPass';
        loanReCS.Megasys_User_Name__c = 'testUserName';
        loanReCS.Request_Timeout__c=60000;
        insert loanReCS;
        
        //create test Application record
        app = createApplicationTest();
        System.debug('Created Date:' +app.CreatedDate);
    }
    
    public static testmethod void testMegaSysWSUtil() {
        insertTestData();
        MegasysWSUtil.execute(app);
        
        HttpCalloutMock  loginResponse = new MegasysWSUtilReqMock (getLoginBody());
        Test.setMock(HttpCalloutMock.class, loginResponse);
        
        //MegasysWSUtil.getRespoceLogin(app);
        Product__c prod = MegaSysUtilities.createProdRecord(app);
        MegasysWSUtil.getRespoceLogin(app, prod);
        
        HttpResponse resTest = MegasysWSUtil.getXMLSingleNewAccountImport(app, prod, 'jnaslkdandsdas');
        
        MegasysWSUtil.getRespoceLogout(app, prod, 'jnaslkdandsdas');
        MegasysWSUtil.parseAccntImportResponse(createHttpReq(), resTest, app, prod);
        MegasysWSUtil.getDataFromResponse(getLoginBody(),'LoginResult');
    }
    
    //return httprequest
    public static HttpRequest createHttpReq(){
        HttpRequest req=new HttpRequest();
        req.setEndpoint('endPoint');
        req.setMethod('POST');
        req.setBody('jsonBody');
        return req;
    }    
    //return Application record from TestRecordFactory
    public static Application__c createApplicationTest(){
        
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
        app = New Application__c();
        String appJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/Application__c/500E0000002nH2fIAE"},"CreatedDate":"2012-10-04T17:54:26.000+0000"}'; 
        app = (Application__c) JSON.deserialize(appJSON, Application__c.class );
        app.Home_Owner__c = 'Rent';
        app.Last_Name__c = 'Rent';
        app.First_Name__c = 'Rent';
        app.Permanent_Address_City__c = 'city';
        app.Permanent_Address_PO_Box__c = '1';
        app.Permanent_Address_PostalCode__c = 'S5R5G7';
        app.Permanent_Address_Province__c = 'MB';
        app.Permanent_Address_Street_Name__c = 'Name';
        app.Months_At_Permanent_Address__c = 1;
        app.Years_At_Permanent_Address__c = 1;
        app.Home_Phone__c = '1233211233';
        app.Work_Phone__c = '1233211233';
        app.Cell_Phone__c = '1233211233';
        app.SIN__c = '123';
        app.Email_Address__c = 'test@test.com';
        app.Birth_Date__c = System.today().addYears(-30);
        app.Employment_Years__c = 1;
        app.Employment_Months__c = 1;
        app.Interest_Rate__c = 0;
        app.Number_of_Payments__c = 0;
        app.First_Payment_Amount__c = 0;
        //app.Regular_Payment_Amount__c = 0;
        app.Regular_Payment_Amount__c = 100;
        app.Total_of_Payment__c = 0;
        app.Loan_Start_Date__c = System.today();
        app.Loan_Amount__c = 0;
        app.Permanent_Address_PostalCode__c = 'F3 D3 f4';
        
        insert app;
        return app;
    }
    
    private static String getLoginBody(){
        
        string loginXML = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><LoginResponse xmlns="http://omega.megasys.net/Client/WebServices/"><LoginResult>a0e2e142-124b-42c8-b69c-a8b3bbd4d807</LoginResult></LoginResponse></soap:Body></soap:Envelope>';
        return loginXML;
    }
    
}