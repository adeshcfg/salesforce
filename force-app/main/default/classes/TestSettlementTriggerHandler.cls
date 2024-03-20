/**************************************************************************************************
*
*  Class:   
*  @description : This is a Test class for SettlementTriggerHandler
*  @author : A5E Consulting
*  @date : 06/12/2020

*************************************************************************************************/
@isTest
public class TestSettlementTriggerHandler {
    @TestSetup
    static void makeData() {
        Loan_ReEngineering__c loanSettings = new Loan_ReEngineering__c();
        loanSettings.Run_Settlement_Trigger__c = true;
        insert loanSettings;

        List<Placement__c> placeList = new List<Placement__c>();
        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        placeList.add(place);

        place = new Placement__c();
        place.Name = '40';
        place.Agency_Name__c = 'National Credit Recovery Inc.';
        placeList.add(place);
        insert placeList;

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

        list<Account> listAccounts = new List<Account>();
        for (integer i = 0; i < 2; i++) {
            Account accInstance = new Account();
            accInstance.LastName = 'TestName' + i;
            accInstance.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
            listAccounts.add(accInstance);
        }
        insert listAccounts;

        list<Product__c> listProduct = new List<Product__c>();
        for (Account acc : listAccounts) {
            Product__c productWithAgency2 = new Product__c();
            productWithAgency2.Customer__c = acc.Id;
            productWithAgency2.Run_Identifier_Check_On__c = Date.today();
            productWithAgency2.Collection_Agency__c = 6;
            productWithAgency2.Status__c = 'New Allocation - New Allocation';
            productWithAgency2.Sub_Status__c = 'Ready';
            productWithAgency2.Product_Status__c = 'Test';
            productWithAgency2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
            listProduct.add(productWithAgency2);

            Product__c distressedProdInstance = new Product__c();
            distressedProdInstance.Customer__c = acc.Id;
            distressedProdInstance.Run_Identifier_Check_On__c = Date.today();
            distressedProdInstance.Status__c = 'New Allocation - New Allocation';
            distressedProdInstance.Sub_Status__c = 'Ready';
            distressedProdInstance.Product_Status__c = 'Test';
            distressedProdInstance.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
            listProduct.add(distressedProdInstance);
        }
        insert listProduct;

        Judgment__c judgmentInst = new Judgment__c();
        judgmentInst.Run_Identifier_Check_On__c = Date.today();
        judgmentInst.Collection_Agency_Identifier__c = 'A68A';
        judgmentInst.Legal_Agency__c = 'Test Agency';
        insert judgmentInst;

        Judgment__c judgmentInst2 = new Judgment__c();
        judgmentInst2.Run_Identifier_Check_On__c = Date.today();
        judgmentInst2.Legal_Agency__c = 'Test Agency 1';
        insert judgmentInst2;

        Placement__c placemntInst = new Placement__c();
        placemntInst.Name = '11';
        placemntInst.Agency_Name__c = 'ABC';
        insert placemntInst;

        Agency_Portal_Fields_Mapping__c fieldMap = new Agency_Portal_Fields_Mapping__c();
        fieldMap.Field_API__c = 'Product__c';
        fieldMap.Field_JSON_Tag__c = 'Product';
        fieldMap.Object_Name__c = 'Settlement';
        fieldMap.Name = 'Product';
        insert fieldMap;

        Agency_Portal_Fields_Mapping__c fieldMap1 = new Agency_Portal_Fields_Mapping__c();
        fieldMap1.Field_API__c = 'Judgment__c';
        fieldMap1.Field_JSON_Tag__c = 'Judgment';
        fieldMap1.Object_Name__c = 'Settlement';
        fieldMap1.Name = 'Judgment';
        insert fieldMap1;

        Agency_Portal_Fields_Mapping__c fieldMap2 = new Agency_Portal_Fields_Mapping__c();
        fieldMap2.Field_API__c = 'Settlement_Number__c';
        fieldMap2.Field_JSON_Tag__c = 'Settlement_Number';
        fieldMap2.Object_Name__c = 'Settlement';
        fieldMap2.Name = 'Settlement_Number';
        insert fieldMap2;

        Settlement__c settlementInst = new Settlement__c();
        settlementInst.Judgment__c = judgmentInst.Id;
        settlementInst.Placement_Text_Id__c = '6';
        settlementInst.Status__c = 'In Progress';
        insert settlementInst;

        Settlement__c settlementInst1 = new Settlement__c();
        settlementInst1.Product__c = [SELECT Id FROM Product__c WHERE Collection_Agency__c = 6 LIMIT 1].Id;
        settlementInst1.Placement_Text_Id__c = '6';
        settlementInst1.Status__c = 'In Progress';
        insert settlementInst1;
    }

    @isTest
    public static void testInsertHandler() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Test.startTest();
        Settlement__c settlementInst = new Settlement__c();
        settlementInst.Judgment__c = [SELECT Id FROM Judgment__c WHERE Legal_Agency__c = 'Test Agency' LIMIT 1].Id;
        settlementInst.Placement_Text_Id__c = '6';
        settlementInst.Approved_By__c = UserInfo.getUserId();
        settlementInst.Approved_Date__c = Date.today();
        settlementInst.Comment__c = 'Test';
        try {
            insert settlementInst;
        } catch (DmlException ex) {
            System.assertEquals('Their is already active settlement present for Judgment', ex.getDmlMessage(0));
        }
        Test.stopTest();
    }

    @isTest
    public static void testInsertHandler1() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Test.startTest();
        List<Settlement__c> sttlmntData = new List<Settlement__c>();
        String placementId = [SELECT Id FROM Placement__c WHERE Name = '11' LIMIT 1].Id;
        String judgmentId = [SELECT Id FROM Judgment__c WHERE Legal_Agency__c = 'Test Agency 1' LIMIT 1].Id;
        Settlement__c settlementInst2 = new Settlement__c();
        settlementInst2.Judgment__c = judgmentId;
        settlementInst2.Placement__c = placementId;
        settlementInst2.Proposal_Amount__c = 123;
        settlementInst2.Placement_Text_Id__c = '6';
        settlementInst2.Placement_Identifier__c = placementId;
        settlementInst2.Judgment_Identifier__c = judgmentId;
        settlementInst2.Rejected_By__c = UserInfo.getUserId();
        settlementInst2.Rejected_Date__c = Date.today() - 5;
        sttlmntData.add(settlementInst2);
        insert sttlmntData;
        Test.stopTest();
    }

    @isTest
    public static void testInsertHandler2() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Test.startTest();
        list<Settlement__c> listSettlement = new List<Settlement__c>();
        for (Product__c prod : [SELECT Id FROM Product__c]) {
            Settlement__c settlementProdInst = new Settlement__c();
            settlementProdInst.Product__c = prod.Id;
            listSettlement.add(settlementProdInst);
        }
        try {
            insert listSettlement;
        } catch (DmlException ex) {
            System.assertEquals('Their is already active settlement present for Product', ex.getDmlMessage(0));
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateHandler() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        List<Settlement__c> sttlmntData = new List<Settlement__c>();
        String placementId = [SELECT Id FROM Placement__c WHERE Name = '11' LIMIT 1].Id;
        String judgmentId = [SELECT Id FROM Judgment__c WHERE Legal_Agency__c = 'Test Agency 1' LIMIT 1].Id;
        Settlement__c settlementInst2 = new Settlement__c();
        settlementInst2.Judgment__c = judgmentId;
        settlementInst2.Placement__c = placementId;
        settlementInst2.Proposal_Amount__c = 123;
        settlementInst2.Placement_Text_Id__c = '6';
        settlementInst2.Placement_Identifier__c = placementId;
        settlementInst2.Judgment_Identifier__c = judgmentId;
        settlementInst2.Comment__c = 'Test First';
        sttlmntData.add(settlementInst2);
        insert sttlmntData;
        Test.startTest();
        Settlement__c settlementUpdate = [SELECT Id FROM Settlement__c WHERE Placement_Text_Id__c = '6' LIMIT 1];
        settlementUpdate.Judgment__c = [SELECT Id FROM Judgment__c WHERE Legal_Agency__c = 'Test Agency' LIMIT 1].Id;
        settlementUpdate.Proposal_Amount__c = 111;
        settlementUpdate.Comment__c = 'Test';
        update settlementUpdate;
        Test.stopTest();
    }
}
