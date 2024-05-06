/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PortalJudgmentProcessor and PortalJudgmentProcessorUtil
 *  @author : A5E Consulting
 *  @date : 28/01/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalJudgmentProcessor {
    @TestSetup
    static void makeData() {
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Balance_one__c';
        FieldMap.Field_JSON_Tag__c = 'Balance_one';
        FieldMap.Object_Name__c = 'Judgment';
        FieldMap.Name = 'Balance one';
        FieldMap.Field_Type__c = 'Currency';
        insert FieldMap;

        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Judgment_Number__c';
        FieldMap1.Field_JSON_Tag__c = 'Judgment_Number';
        FieldMap1.Object_Name__c = 'Judgment';
        FieldMap1.Name = 'Judgment Number';
        insert FieldMap1;

        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Date_Writ_Issued__c';
        FieldMap2.Field_JSON_Tag__c = 'Date_Writ_Issued';
        FieldMap2.Object_Name__c = 'Judgment';
        FieldMap2.Name = 'Date_Writ_Issued';
        FieldMap2.Field_Type__c = 'Date';
        insert FieldMap2;

        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Legal_Status__c';
        FieldMap3.Field_JSON_Tag__c = 'Legal_Status';
        FieldMap3.Object_Name__c = 'Judgment';
        FieldMap3.Name = 'Legal_Status';
        insert FieldMap3;
    }

    public static testMethod void testJudgment() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.addHeader('Content-Type', 'application/json');
        req.requestUri = '/services/apexrest/PortalJudgmentProcessor/';
        String postData = '{"Judgment_Number":"JC-111","Date_Writ_Issued": "2022-06-27 00:00:00"}';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PortalJudgmentProcessor.postJudgment();
        Test.stopTest();
    }

    public static testMethod void updateJudgmentTest() {
        Province_Tax_Rate_Mapping__mdt province2 = new Province_Tax_Rate_Mapping__mdt();
        province2.Label = 'Alberta';
        province2.Province_Acronym__c = 'AB';
        province2.Province_Name__c = 'Alberta';
        province2.Province_Tax_Rate__c = 5;
        province2.Canada_Tax_Rate__c = 5;
        province2.Total_Tax_Rate__c = 10;

        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        Superior_Court__C supCourt = new Superior_Court__C();
        supCourt.Name = 'XYZ';
        insert supCourt;

        Superior_Court__C supCourt1 = new Superior_Court__C();
        supCourt1.Name = 'ABC';
        insert supCourt1;

        Small_Claims_Court__c smCourt = new Small_Claims_Court__c();
        smCourt.Name = 'XYZ';
        insert smCourt;

        Small_Claims_Court__c smCourt1 = new Small_Claims_Court__c();
        smCourt1.Name = 'ABC';
        insert smCourt1;

        Enforcement_County__c enCourt = new Enforcement_County__c();
        enCourt.Name = 'XYZ';
        insert enCourt;

        Enforcement_County__c enCourt1 = new Enforcement_County__c();
        enCourt1.Name = 'ABC';
        insert enCourt1;

        Court__c court = new Court__c();
        court.Name = 'XYZ';
        insert court;

        Court__c court1 = new Court__c();
        court1.Name = 'ABC';
        insert court1;

        Placement__c place = new Placement__c();
        place.Name = '1';
        insert place;

        Product__C prod = new Product__c();
        string recrdid = [SELECT id FROM RecordType WHERE sobjecttype = 'product__c' AND RecordType.Name = 'Distressed Account'].id;
        prod.RecordTypeId = recrdid;
        prod.Name = '123456789';
        prod.Previously_Reviewed_for_Legal_Action__c = true;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Current_Principal_Balance__c = 101;
        prod.Current_Interest_Amount__c = 1000;
        prod.State__C = 'ON';
        insert prod;

        Map<id, Judgment__c> mapJudgment = new Map<id, Judgment__c>();
        Judgment__c judgment = new Judgment__c();
        string recordid = [SELECT id FROM RecordType WHERE sobjecttype = 'Judgment__C' AND RecordType.Name = 'Judgment'].id;
        judgment.RecordTypeId = recordid;
        judgment.Judgment_Number__c = 'JC-111';
        judgment.Legal_Agency__c = 'Test Agency';
        judgment.Country__c = 'CANADA';
        judgment.Created_By__c = 'TESTABC';
        judgment.Last_Modified_By__c = 'TEST123';
        judgment.Current_Interest_Balance__c = 1000;
        judgment.Current_Principal_Balance__c = 1000.00;
        judgment.Suit_Amount__c = 200;
        judgment.Company_Name__c = 'Test';
        judgment.Writ_Renewal_Date__c = Date.newInstance(2016, 12, 9);
        judgment.Garnishment_Date__c = Date.newInstance(2016, 12, 9);
        judgment.Agency_Initiated_Legal_Action_Lookup__c = place.Id;
        judgment.Superior_Court__c = supCourt.Id;
        judgment.Small_Claims_Court__c = smCourt.Id;
        judgment.Enforcement_County__c = enCourt.Id;
        judgment.County__c = court.Id;
        judgment.Agency_Initiated_Legal_Action__c = '1';
        judgment.Judgment_Province__c = 'ON';
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        insert judgment;
        JudgmentTriggerHandler.runJudgmentTrigger = true;
        mapJudgment.put(judgment.id, judgment);

        judgment.Agency_Initiated_Legal_Action__c = '2';

        update judgment;

        list<Payment_Transaction__c> listPaymentTransactionToProcess = new List<Payment_Transaction__c>();
        map<ID, Payment_Transaction__c> mapPaymentTransactions = new Map<ID, Payment_Transaction__c>();

        Payment_Transaction__c prductTran = new Payment_Transaction__c();
        prductTran.Amount__c = 100;
        prductTran.Collection_Agency__c = 29;
        prductTran.Error_Message__c = 'Hello Msg';

        insert prductTran;
        listPaymentTransactionToProcess.add(prductTran);
        mapPaymentTransactions.put(prductTran.id, prductTran);

        Map<Id, Judgment__c> mapJudgment1 = new Map<Id, Judgment__c>();
        Judgment__c judgment1 = new Judgment__c();
        judgment1.Judgment_Number__c = 'JC-111';
        judgment1.Legal_Agency__c = '1';
        judgment1.Country__c = 'CANADA';
        judgment1.Created_By__c = 'TESTABC';
        judgment1.Last_Modified_By__c = 'TEST123';
        judgment1.Current_Interest_Balance__c = 1000;
        judgment1.Current_Principal_Balance__c = 1000.00;
        judgment1.Suit_Amount__c = 200;
        judgment1.Company_Name__c = 'Test';
        judgment1.Writ_Renewal_Date__c = Date.newInstance(2016, 12, 9);
        judgment1.Garnishment_Date__c = Date.newInstance(2016, 12, 9);
        judgment1.Agency_Initiated_Legal_Action_Lookup__c = place.Id;
        judgment1.Superior_Court__c = supCourt.Id;
        judgment1.Small_Claims_Court__c = smCourt.Id;
        judgment1.Enforcement_County__c = enCourt.Id;
        judgment1.County__c = court.Id;
        judgment1.Agency_Initiated_Legal_Action__c = '1';
        judgment1.Judgment_Province__c = 'Alberta';
        judgment1.Superior_Court_Identifier__c = 'XYZ';
        judgment1.Small_Claims_Court_Identifier__c = 'XYZ';
        judgment1.Enforcement_County_Identifier__c = 'ABC';
        judgment1.County_Identifier__c = 'XYZ';
        judgment1.Legal_Status__c = 'Pre-legal';
        judgment1.Legal_Sub_Status__c = 'Recommended for legal action	';
        insert judgment1;
        mapJudgment.put(judgment.id, judgment1);

        map<String, String> paramMap = new Map<String, String>();
        paramMap.put('Judgment_Number', 'JC-111');
        paramMap.put('Date_Writ_Issued', '2022-01-03');
        paramMap.put('Legal_Status', 'Judgment');
        paramMap.put('Balance_one', '1000');
        PortalJudgmentProcessorUtil.processJudgment(paramMap, judgment1);
    }
}
