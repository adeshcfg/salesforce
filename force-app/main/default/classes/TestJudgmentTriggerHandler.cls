/**************************************************************************************************
 *
 *  Test Class:
 *
 *  @description : This is a Testclass for JudgmentTrigger Handler Class
 *  @author : A5E Consulting
 *  @date : 06/12/20
 *
 *************************************************************************************************/
@isTest
public class TestJudgmentTriggerHandler {
    @testSetup
    static void testData() {
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

        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Product_Coll_Sub_Status_Validation__c = true;
        config.Run_JudgmentTrigger__c = true;
        insert config;

        Agency_Portal_Settings__c agencyConfig = Agency_Portal_Settings__c.getOrgDefaults();
        agencyConfig.Send_Notification__c = true;
        insert agencyConfig;
    }

    public static testMethod void TestJudgment() {
        List<Judgment__c> judgList = new List<Judgment__c>();
        List<Judgment__c> judgList1 = new List<Judgment__c>();
        Map<String, product__c> productmap = new Map<String, product__c>();
        Map<Id, Judgment__c> mapNewJudgment = new Map<Id, Judgment__c>();
        Map<Id, Judgment__c> mapOldJudgment = new Map<Id, Judgment__c>();
        list<Judgment__c> listInternalNewJudgment = new List<Judgment__c>();
        set<String> prodName = new Set<String>();
        set<ID> prodNameId = new Set<ID>();
        list<String> listJudgmentStatuses = new List<String>();
        map<String, ID> mapProductNameIds = new Map<String, ID>();
        map<String, Product__c> mapProductData = new Map<String, Product__c>();
        Map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new Map<String, Judgment_product_codes_mapping__c>();

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '101';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'Testing';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Purchase_Province__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        ProductTriggerHandler.runProductTrigger = false;
        insert prodInstance;
        ProductTriggerHandler.runProductTrigger = true;
        mapProductData.put(prodInstance.Name, prodInstance);

        //product payment record creation
        Product_Payments__c prodpay = new Product_Payments__c();
        prodpay.CCS_Account__c = prodInstance.id;
        prodpay.Payment_Amount__c = 20;
        prodpay.Payment_Posting_Date__c = System.today().addDays(-1);
        prodpay.Principal_Payment_Amount__c = 1000;
        prodpay.Interest_Payment_Amount__c = 500;
        prodpay.Payment_Type__c = '1004';
        prodpay.Payment_Source__c = '1';
        prodpay.Deposit_Account_Type__c = 'ETC';
        prodpay.Payment_Posting_Date_Text__c = 'Thursday';
        prodpay.Ignore_Warning__c = true;
        prodpay.Interest_Adjustment__c = 5;
        prodpay.Payment_Posting_Date__c = System.today() - 1;
        prodpay.Payment_Provided_Agency__c = plcgy1.id;
        prodpay.Pay_Non_Recoverable_Fee__c = 5;
        prodpay.Pay_Recoverable_Fee__c = 5;
        prodpay.Pay_NSF__c = '100';
        prodpay.Product_Commission_Rate__c = 2;
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay;
        ProductPaymentsTriggerHandler.runProductTrigger = true;

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

        /* Account_Judgment__c accJudgment = new Account_Judgment__c(); //accJudgment.Judgment__c = judgmetInstance.Id;
        accJudgment.Product__c = prodInstance.Id;
        accJudgment.Status__c = 'Active';
        insert accJudgment; */

        Judgment__C judgmetInstance = new Judgment__C();
        string recrdid = [SELECT id FROM RecordType WHERE sobjecttype = 'Judgment__C' AND RecordType.Name = 'Judgment'].id;
        judgmetInstance.RecordTypeId = recrdid;
        judgmetInstance.Legal_Status__c = 'Judgment';
        judgmetInstance.Legal_Sub_Status__c = 'Vacated';
        judgmetInstance.Product_1__c = prodInstance.name;
        judgmetInstance.Interest_Rate_one__c = 11;
        judgmetInstance.Balance_one__c = 11;
        judgmetInstance.Agency_Initiated_Legal_Action_Lookup__c = place.Id;
        judgmetInstance.Superior_Court__c = supCourt.Id;
        judgmetInstance.Small_Claims_Court__c = smCourt.Id;
        judgmetInstance.Enforcement_County__c = enCourt.Id;
        judgmetInstance.County__c = court.Id;
        judgmetInstance.Collection_Agency_Identifier__c = '1';
        judgmetInstance.Legal_Agency__c = place.Name;
        judgmetInstance.Agency_Initiated_Legal_Action__c = '1';
        judgmetInstance.Legal_Status__c = 'Judgment';
        judgmetInstance.Judgment_Amount__c = 1000;
        judgmetInstance.Judgment_Date__c = Date.newInstance(2016, 12, 9);
        judgmetInstance.Product_2__c = 'Testing';
        judgmetInstance.Interest_Rate_two__c = 10;
        judgmetInstance.Balance_two__c = 15000;
        judgmetInstance.Balance_three__c = 100;
        judgmetInstance.Balance_four__c = 110;
        judgmetInstance.Balance_five__c = 120;
        judgmetInstance.Current_Principal_Balance__c = 1222;
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        insert judgmetInstance;
        judgList.add(judgmetInstance);
        Test.startTest();
        JudgmentTriggerHandler.handleBeforeInsert(judgList);
        JudgmentTriggerHandler.validationRuleonProductAgencies(judgList);
        Test.stopTest();
        Judgment__C judInstance = new Judgment__C();
        judInstance.Legal_Status__c = 'Judgment';
        judInstance.Legal_Sub_Status__c = 'Granted';
        judInstance.Product_1__c = 'Testing';
        judInstance.Interest_Rate_one__c = 21;
        judInstance.Balance_one__c = 99;
        judInstance.Judgment_Amount__c = null;
        judInstance.Judgment_Date__c = Date.newInstance(2016, 12, 9);
        judInstance.Superior_Court__c = supCourt.Id;
        judInstance.Small_Claims_Court__c = smCourt.Id;
        judInstance.Enforcement_County__c = enCourt.Id;
        judInstance.County__c = court.Id;
        judInstance.Collection_Agency_Identifier__c = '1';
        judInstance.Legal_Agency__c = '101';
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        insert judInstance;
        judgList.add(judInstance);
        judgList1.add(judInstance);
        mapNewJudgment.put(judInstance.id, judInstance);

        Account_Judgment__c acctJudgment1 = new Account_Judgment__c();
        acctJudgment1.Judgment__c = judInstance.Id;
        acctJudgment1.Product__c = prodInstance.Id;
        acctJudgment1.Status__c = 'Active';
        insert acctJudgment1;

        Judgment__C judInstance1 = new Judgment__C();
        judInstance1.Legal_Status__c = 'Judgment';
        judInstance1.Legal_Sub_Status__c = 'Vacated';
        judInstance1.Legal_Agency__c = '101';
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        insert judInstance1;
        judgList.add(judInstance1);
        mapOldJudgment.put(judInstance.id, judgmetInstance);

        Judgment__C judgInstance = new Judgment__C();
        judgInstance.Superior_Court__c = supCourt.Id;
        judgInstance.Small_Claims_Court__c = smCourt.Id;
        judgInstance.Enforcement_County__c = enCourt.Id;
        judgInstance.County__c = court.Id;
        judgInstance.Collection_Agency_Identifier__c = '1';
        judgInstance.Legal_Agency__c = '101';
        update listInternalNewJudgment;
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        insert judgInstance;
        listInternalNewJudgment.add(judgInstance);

        Account_Judgment__c acctJudgment = new Account_Judgment__c();
        acctJudgment.Judgment__c = judgmetInstance.Id;
        acctJudgment.Product__c = prodInstance.Id;
        acctJudgment.Status__c = 'Active';
        insert acctJudgment;

        prodNameId.add(acctJudgment.Product__c);
        mapProductNameIds.put(prodInstance.Name, acctJudgment.Product__c);
        prodName.add(prodInstance.Name);

        judgmetInstance.Legal_Sub_Status__c = 'Vacated';
        judgmetInstance.Superior_Court__c = supCourt1.Id;
        listInternalNewJudgment.add(judgInstance);
        judgmetInstance.Small_Claims_Court__c = smCourt1.Id;
        judgmetInstance.Enforcement_County__c = enCourt1.Id;
        judgmetInstance.County__c = court1.Id;
        judgmetInstance.Collection_Agency_Identifier__c = '2';
        judgInstance.Legal_Agency__c = place.Id;

        listJudgmentStatuses.add(judInstance.Legal_Status__c);

        JudgmentTriggerHandler.setAccountJudgmentInactive(judgList);
        system.debug('mapNewJudgment test class' + mapNewJudgment);
        system.debug('mapOldJudgment test class' + mapOldJudgment);
        JudgmentTriggerHandler.populateJudgmentWithPlacement(judgList);
        JudgmentTriggerHandler.recalculateDisbursmentFees(new Set<id>{ prodInstance.Id });
        JudgmentTriggerHandler.updateProductLegalStatus(mapNewJudgment, mapOldJudgment);
        JudgmentTriggerHandler.updateProductStatusesOnJudgment(judgList1, listJudgmentStatuses);
        JudgmentTriggerHandler.handleBeforeUpdate(judgList1, mapOldJudgment);
        JudgmentTriggerHandler.validationRuleonProductAgencies(judgList1, mapOldJudgment);
        judInstance.Superior_Court__c = supCourt.Id;
        judInstance.Small_Claims_Court__c = smCourt.Id;
        judInstance.Enforcement_County__c = enCourt.Id;
        judInstance.County__c = court.Id;
        judInstance.Product_1__c = prodInstance.name;
        judInstance.Product_2__c = '12345';
        judInstance.Product_3__c = '67890';
        judInstance.Product_4__c = '12456';
        judInstance.Product_5__c = '87695';
        judInstance.Judgment_Date__c = Date.newInstance(2016, 12, 9);
        judgList1.add(judInstance);

        JudgmentTriggerHandler.handleBeforeUpdate(judgList1, mapOldJudgment);
        JudgmentTriggerHandler.handleAfterUpdate(judgList1, mapOldJudgment);

        Product__c product = new Product__c();
        product.name = '12345';
        product.Payment_Setup_Status__c = 'Automated';
        product.Funding_Status__c = 'Released Batch';
        product.Funding_Type__c = 'Automated';
        insert product;

        productmap.put(product.name, product);

        judgmetInstance.Judgment_Date__c = null;
        judgmetInstance.Legal_Sub_Status__c = 'Vacated';
        judgList.add(judgmetInstance);
        mapOldJudgment.put(judgmetInstance.id, judgmetInstance);
        mapOldJudgment.put(judInstance1.id, judInstance1);
        JudgmentTriggerHandler.handleAfterUpdate(judgList1, mapOldJudgment);
        JudgmentTriggerHandler.validationRules(judgList, mapOldJudgment);
    }
    public static testMethod void TestJudgmentValidationRules() {
        Product__c prodInstance1 = new Product__c();
        prodInstance1.Name = 'TestName';
        prodInstance1.Funding_Status__c = 'Funded';
        prodInstance1.Funding_Type__c = 'Automated';
        prodInstance1.Disbursement_Amount__c = 3000.00;
        prodInstance1.Status__c = 'New Allocation - New Allocation';
        prodInstance1.Sub_Status__c = 'Ready';
        prodInstance1.Product_Status__c = 'Test';
        prodInstance1.State__c = 'AB';
        prodInstance1.Purchase_Province__c = 'AB';
        ProductTriggerHandler.runProductTrigger = false;
        insert prodInstance1;

        Account_Judgment__c accJudgment1 = new Account_Judgment__c();
        accJudgment1.Product__c = prodInstance1.Id;
        accJudgment1.Status__c = 'Active';
        insert accJudgment1;

        list<String> listJudgmentStatuses = new List<String>();
        list<Judgment__c> judgList2 = new List<Judgment__c>();
        Judgment__c judgInst = new Judgment__c();
        judgInst.Legal_Sub_Status__c = 'Claim Issued';
        judgInst.Legal_Status__c = 'Pre-Judgment';
        judgInst.Legal_Agency__c = '29';
        judgList2.add(judgInst);

        Judgment__c judgInst2 = new Judgment__c();
        judgInst2.Legal_Sub_Status__c = 'Granted';
        judgInst2.Legal_Status__c = 'Judgment';
        judgInst2.Legal_Agency__c = '29';
        judgList2.add(judgInst2);

        Judgment__c judgInst3 = new Judgment__c();
        judgInst3.Legal_Status__c = 'Judgment';
        judgInst3.Legal_Sub_Status__c = 'Consent Judgment';
        judgInst3.Legal_Agency__c = '29';
        judgList2.add(judgInst3);

        Judgment__c judgInst4 = new Judgment__c();
        judgInst4.Legal_Status__c = 'Post-Judgment';
        judgInst4.Legal_Sub_Status__c = 'Wage Garnishment';
        judgInst4.Legal_Agency__c = '29';
        judgList2.add(judgInst4);

        Judgment__c judgInst5 = new Judgment__c();
        judgInst5.Legal_Status__c = 'Post-Judgment';
        judgInst5.Legal_Sub_Status__c = 'Writ Filed';
        judgInst5.Legal_Agency__c = '29';
        judgList2.add(judgInst5);

        Judgment__c judgInst6 = new Judgment__c();
        judgInst6.Legal_Status__c = 'Post-Judgment';
        judgInst6.Legal_Sub_Status__c = 'Writ Filed';
        judgInst6.Legal_Agency__c = '29';
        judgInst6.Product_2__c = 'abc';
        judgInst6.Suit_Amount_2__c = 60;
        judgList2.add(judgInst6);

        Judgment__c judgInst9 = new Judgment__c();
        judgInst9.Legal_Status__c = 'Post-Judgment';
        judgInst9.Legal_Sub_Status__c = 'Writ Filed';
        judgInst9.Legal_Agency__c = '29';
        judgInst9.Product_2__c = 'abc';
        judgInst9.Suit_Amount_2__c = 60;
        judgList2.add(judgInst9);

        Judgment__c judgInst7 = new Judgment__c();
        judgInst7.Legal_Status__c = 'Post-Judgment';
        judgInst7.Legal_Sub_Status__c = 'Writ Filed';
        judgInst7.Legal_Agency__c = '29';
        judgInst7.Product_3__c = 'abc';
        judgInst7.Suit_Amount_3__c = 60;
        judgList2.add(judgInst7);

        Judgment__c judgInst8 = new Judgment__c();
        judgInst8.Legal_Status__c = 'Post-Judgment';
        judgInst8.Legal_Sub_Status__c = 'Writ Filed';
        judgInst8.Legal_Agency__c = '29';
        judgInst8.Product_4__c = 'abc';
        judgInst8.Suit_Amount_4__c = 60;
        judgList2.add(judgInst8);

        Judgment__c judgInst10 = new Judgment__c();
        judgInst10.Legal_Status__c = 'Post-Judgment';
        judgInst10.Legal_Sub_Status__c = 'Writ Filed';
        judgInst10.Legal_Agency__c = '29';
        judgInst10.Product_5__c = 'abc';
        judgInst10.Suit_Amount_5__c = 60;
        judgList2.add(judgInst10);

        Judgment__c judgInst11 = new Judgment__c();
        judgInst11.Legal_Sub_Status__c = 'Claim Issued';
        judgInst11.Legal_Status__c = 'Pre-Judgment';
        judgInst11.Legal_Agency__c = '29';
        judgInst11.Product_2__c = 'abc';
        judgInst11.Suit_Amount_2__c = 60;
        judgList2.add(judgInst11);

        Judgment__c judgInst12 = new Judgment__c();
        judgInst12.Legal_Sub_Status__c = 'Claim Issued';
        judgInst12.Legal_Status__c = 'Pre-Judgment';
        judgInst12.Legal_Agency__c = '29';
        judgInst12.Product_3__c = 'abc';
        judgInst12.Suit_Amount_3__c = 60;
        judgList2.add(judgInst12);

        Judgment__c judgInst13 = new Judgment__c();
        judgInst13.Legal_Sub_Status__c = 'Claim Issued';
        judgInst13.Legal_Status__c = 'Pre-Judgment';
        judgInst13.Legal_Agency__c = '29';
        judgInst13.Product_4__c = 'abc';
        judgInst13.Suit_Amount_4__c = 60;
        judgList2.add(judgInst13);

        Judgment__c judgInst14 = new Judgment__c();
        judgInst14.Legal_Sub_Status__c = 'Claim Issued';
        judgInst14.Legal_Status__c = 'Pre-Judgment';
        judgInst14.Legal_Agency__c = '29';
        judgInst14.Product_5__c = 'abc';
        judgInst14.Suit_Amount_5__c = 60;
        judgList2.add(judgInst14);

        Judgment__c judgInst15 = new Judgment__c();
        judgInst2.Legal_Sub_Status__c = 'Granted';
        judgInst2.Legal_Status__c = 'Judgment';
        judgInst2.Legal_Agency__c = '29';
        judgInst14.Product_1__c = 'abc';
        judgInst14.Suit_Amount_1__c = 60;
        judgList2.add(judgInst2);

        Judgment__c judgInst16 = new Judgment__c();
        judgInst16.Legal_Sub_Status__c = 'Granted';
        judgInst16.Legal_Status__c = 'Judgment';
        judgInst16.Legal_Agency__c = '29';
        judgInst16.Product_2__c = 'abc';
        judgInst16.Suit_Amount_2__c = 60;
        judgList2.add(judgInst16);

        Judgment__c judgInst17 = new Judgment__c();
        judgInst17.Legal_Sub_Status__c = 'Granted';
        judgInst17.Legal_Status__c = 'Judgment';
        judgInst17.Legal_Agency__c = '29';
        judgInst17.Product_3__c = 'abc';
        judgInst17.Suit_Amount_3__c = 60;
        judgList2.add(judgInst17);

        Judgment__c judgInst18 = new Judgment__c();
        judgInst18.Legal_Sub_Status__c = 'Granted';
        judgInst18.Legal_Status__c = 'Judgment';
        judgInst18.Legal_Agency__c = '29';
        judgInst18.Product_4__c = 'abc';
        judgInst18.Suit_Amount_4__c = 60;
        judgList2.add(judgInst18);

        Judgment__c judgInst19 = new Judgment__c();
        judgInst19.Legal_Sub_Status__c = 'Granted';
        judgInst19.Legal_Status__c = 'Judgment';
        judgInst19.Legal_Agency__c = '29';
        judgInst19.Product_5__c = 'abc';
        judgInst19.Suit_Amount_5__c = 60;
        judgList2.add(judgInst19);

        Judgment__c judgInst20 = new Judgment__c();
        judgInst20.Legal_Status__c = 'Judgment';
        judgInst20.Legal_Sub_Status__c = 'Consent Judgment';
        judgInst20.Legal_Agency__c = '29';
        judgInst20.Product_2__c = 'abc';
        judgInst20.Suit_Amount_2__c = 60;
        judgList2.add(judgInst20);

        Judgment__c judgInst21 = new Judgment__c();
        judgInst21.Legal_Status__c = 'Judgment';
        judgInst21.Legal_Sub_Status__c = 'Consent Judgment';
        judgInst21.Legal_Agency__c = '29';
        judgInst21.Product_3__c = 'abc';
        judgInst21.Suit_Amount_3__c = 60;
        judgList2.add(judgInst21);

        Judgment__c judgInst22 = new Judgment__c();
        judgInst22.Legal_Status__c = 'Judgment';
        judgInst22.Legal_Sub_Status__c = 'Consent Judgment';
        judgInst22.Legal_Agency__c = '29';
        judgInst22.Product_4__c = 'abc';
        judgInst22.Suit_Amount_4__c = 60;
        judgList2.add(judgInst22);

        Judgment__c judgInst23 = new Judgment__c();
        judgInst23.Legal_Status__c = 'Judgment';
        judgInst23.Legal_Sub_Status__c = 'Consent Judgment';
        judgInst23.Legal_Agency__c = '29';
        judgInst23.Product_5__c = 'abc';
        judgInst23.Suit_Amount_5__c = 60;
        judgList2.add(judgInst23);

        Judgment__c judgInst24 = new Judgment__c();
        judgInst24.Legal_Status__c = 'Post-Judgment';
        judgInst24.Legal_Sub_Status__c = 'Wage Garnishment';
        judgInst24.Legal_Agency__c = '29';
        judgInst24.Product_2__c = 'abc';
        judgInst24.Suit_Amount_2__c = 60;
        judgList2.add(judgInst24);

        Judgment__c judgInst25 = new Judgment__c();
        judgInst25.Legal_Status__c = 'Post-Judgment';
        judgInst25.Legal_Sub_Status__c = 'Wage Garnishment';
        judgInst25.Legal_Agency__c = '29';
        judgInst25.Product_3__c = 'abc';
        judgInst25.Suit_Amount_3__c = 60;
        judgList2.add(judgInst25);

        Judgment__c judgInst26 = new Judgment__c();
        judgInst26.Legal_Status__c = 'Post-Judgment';
        judgInst26.Legal_Sub_Status__c = 'Wage Garnishment';
        judgInst26.Legal_Agency__c = '29';
        judgInst26.Product_4__c = 'abc';
        judgInst26.Suit_Amount_4__c = 60;
        judgList2.add(judgInst26);

        Judgment__c judgInst27 = new Judgment__c();
        judgInst27.Legal_Status__c = 'Post-Judgment';
        judgInst27.Legal_Sub_Status__c = 'Wage Garnishment';
        judgInst27.Legal_Agency__c = '29';
        judgInst27.Product_5__c = 'abc';
        judgInst27.Suit_Amount_5__c = 60;
        judgList2.add(judgInst27);

        Judgment__c judgInst28 = new Judgment__c();
        judgInst28.Legal_Status__c = 'Post-Judgment';
        judgInst28.Legal_Sub_Status__c = 'Writ Filed';
        judgInst28.Legal_Agency__c = '29';
        judgInst28.Product_2__c = 'abc';
        judgInst28.Suit_Amount_2__c = 60;
        judgList2.add(judgInst28);

        Judgment__c judgInst29 = new Judgment__c();
        judgInst29.Legal_Status__c = 'Post-Judgment';
        judgInst29.Legal_Sub_Status__c = 'Writ Filed';
        judgInst29.Legal_Agency__c = '29';
        judgInst29.Product_3__c = 'abc';
        judgInst29.Suit_Amount_3__c = 60;
        judgList2.add(judgInst29);

        Judgment__c judgInst30 = new Judgment__c();
        judgInst30.Legal_Status__c = 'Post-Judgment';
        judgInst30.Legal_Sub_Status__c = 'Writ Filed';
        judgInst30.Legal_Agency__c = '29';
        judgInst30.Product_4__c = 'abc';
        judgInst30.Suit_Amount_4__c = 60;
        judgList2.add(judgInst30);

        Judgment__c judgInst31 = new Judgment__c();
        judgInst31.Legal_Status__c = 'Post-Judgment';
        judgInst31.Legal_Sub_Status__c = 'Writ Filed';
        judgInst31.Legal_Agency__c = '29';
        judgInst31.Product_5__c = 'abc';
        judgInst31.Suit_Amount_5__c = 60;
        judgList2.add(judgInst31);

        Judgment__c judgInst32 = new Judgment__c();
        judgInst32.Legal_Status__c = 'Pre-Judgment';
        judgInst32.Legal_Sub_Status__c = 'Claim Served';
        judgInst32.Legal_Agency__c = '29';
        judgInst32.Product_2__c = 'abc';
        judgInst32.Suit_Amount_2__c = 60;
        judgList2.add(judgInst32);

        Judgment__c judgInst33 = new Judgment__c();
        judgInst33.Legal_Status__c = 'Pre-Judgment';
        judgInst33.Legal_Sub_Status__c = 'Claim Served';
        judgInst33.Legal_Agency__c = '29';
        judgInst33.Product_3__c = 'abc';
        judgInst33.Suit_Amount_3__c = 60;
        judgList2.add(judgInst33);

        Judgment__c judgInst34 = new Judgment__c();
        judgInst34.Legal_Status__c = 'Pre-Judgment';
        judgInst34.Legal_Sub_Status__c = 'Claim Served';
        judgInst34.Legal_Agency__c = '29';
        judgInst34.Product_4__c = 'abc';
        judgInst34.Suit_Amount_4__c = 60;
        judgList2.add(judgInst34);

        Judgment__c judgInst35 = new Judgment__c();
        judgInst35.Legal_Status__c = 'Pre-Judgment';
        judgInst35.Legal_Sub_Status__c = 'Claim Served';
        judgInst35.Legal_Agency__c = '29';
        judgInst35.Product_5__c = 'abc';
        judgInst35.Suit_Amount_5__c = 60;
        judgList2.add(judgInst35);

        Judgment__c judgInst36 = new Judgment__c();
        judgInst36.Legal_Status__c = 'Post-Judgment';
        judgInst36.Legal_Sub_Status__c = 'Writ & Garnishment';
        judgInst36.Legal_Agency__c = '29';
        judgInst36.Product_2__c = 'abc';
        judgInst36.Suit_Amount_2__c = 60;
        judgList2.add(judgInst36);

        Judgment__c judgInst37 = new Judgment__c();
        judgInst37.Legal_Status__c = 'Post-Judgment';
        judgInst37.Legal_Sub_Status__c = 'Writ & Garnishment';
        judgInst37.Legal_Agency__c = '29';
        judgList2.add(judgInst37);

        Judgment__c judgInst38 = new Judgment__c();
        judgInst38.Legal_Status__c = 'Post-Judgment';
        judgInst38.Legal_Sub_Status__c = 'Writ & Garnishment';
        judgInst38.Legal_Agency__c = '29';
        judgInst38.Product_3__c = 'abc';
        judgInst38.Suit_Amount_3__c = 60;
        judgList2.add(judgInst38);

        Judgment__c judgInst39 = new Judgment__c();
        judgInst39.Legal_Status__c = 'Post-Judgment';
        judgInst39.Legal_Sub_Status__c = 'Writ & Garnishment';
        judgInst39.Legal_Agency__c = '29';
        judgInst39.Product_4__c = 'abc';
        judgInst39.Suit_Amount_4__c = 60;
        judgList2.add(judgInst39);

        Judgment__c judgInst40 = new Judgment__c();
        judgInst40.Legal_Status__c = 'Post-Judgment';
        judgInst40.Legal_Sub_Status__c = 'Writ & Garnishment';
        judgInst40.Legal_Agency__c = '29';
        judgInst40.Product_5__c = 'abc';
        judgInst40.Suit_Amount_5__c = 60;
        judgList2.add(judgInst40);

        listJudgmentStatuses.add('Pre-Judgment');
        listJudgmentStatuses.add('Judgment');
        listJudgmentStatuses.add('Post-Judgment');

        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name = 'A-0010';
        mapping.Codes__c = '220000';
        mapping.Judgment_Legal_Status__c = 'Pre-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Claim Issued';
        mapping.Product_Parent__c = 'Pre-Judgment';
        mapping.Product_Status__c = 'Pre - Judgment - In Process';
        mapping.Product_Sub_status__c = 'Claim Issued';
        insert mapping;

        Judgment_product_codes_mapping__c mapping2 = new Judgment_product_codes_mapping__c();
        mapping2.name = 'A-0022';
        mapping2.Codes__c = '290000';
        mapping2.Judgment_Legal_Status__c = 'Judgment';
        mapping2.Judgment_Legal_Sub_Status__c = 'Granted';
        mapping2.Product_Parent__c = 'Judgment';
        mapping2.Product_Status__c = 'Judgment Verdict - Granted';
        mapping2.Product_Sub_status__c = 'Default Judgment';
        insert mapping2;

        Judgment_product_codes_mapping__c mapping3 = new Judgment_product_codes_mapping__c();
        mapping3.name = 'A-0045';
        mapping3.Codes__c = '290005';
        mapping3.Judgment_Legal_Status__c = 'Judgment';
        mapping3.Judgment_Legal_Sub_Status__c = 'Consent Judgment';
        mapping3.Product_Parent__c = 'Judgment';
        mapping3.Product_Status__c = 'Judgment Verdict - Granted';
        mapping3.Product_Sub_status__c = 'Consent Judgment';
        insert mapping3;

        Judgment_product_codes_mapping__c mapping4 = new Judgment_product_codes_mapping__c();
        mapping4.name = 'A-0029';
        mapping4.Codes__c = '293000';
        mapping4.Judgment_Legal_Status__c = 'Post-Judgment';
        mapping4.Judgment_Legal_Sub_Status__c = 'Wage Garnishment';
        mapping4.Product_Parent__c = 'Post-Judgment';
        mapping4.Product_Status__c = 'Post - Judgment - In Process';
        mapping4.Product_Sub_status__c = 'Wage Garnishment';
        insert mapping4;

        Judgment_product_codes_mapping__c mapping5 = new Judgment_product_codes_mapping__c();
        mapping5.name = 'A-0031';
        mapping5.Codes__c = '295000';
        mapping5.Judgment_Legal_Status__c = 'Post-Judgment';
        mapping5.Judgment_Legal_Sub_Status__c = 'Writ Filed';
        mapping5.Product_Parent__c = 'Post-Judgment';
        mapping5.Product_Status__c = 'Post - Judgment - In Process';
        mapping5.Product_Sub_status__c = 'Writ Filed';
        insert mapping5;

        Judgment_product_codes_mapping__c mapping6 = new Judgment_product_codes_mapping__c();
        mapping6.name = 'A-0011';
        mapping6.Codes__c = '220020';
        mapping6.Judgment_Legal_Status__c = 'Pre-Judgment';
        mapping6.Judgment_Legal_Sub_Status__c = 'Claim Served';
        mapping6.Product_Parent__c = 'Pre-Judgment';
        mapping6.Product_Status__c = 'Pre - Judgment - In Process';
        mapping6.Product_Sub_status__c = 'Claim Served';
        insert mapping6;

        Judgment_product_codes_mapping__c mapping7 = new Judgment_product_codes_mapping__c();
        mapping7.name = 'A-0011';
        mapping7.Codes__c = '295020';
        mapping7.Judgment_Legal_Status__c = 'Post-Judgment';
        mapping7.Judgment_Legal_Sub_Status__c = 'Writ & Garnishment';
        mapping7.Product_Parent__c = 'Post-Judgment';
        mapping7.Product_Status__c = 'Post - Judgment - In Process';
        mapping7.Product_Sub_status__c = 'Writ & Garnishment';
        insert mapping7;
        Test.startTest();
        JudgmentTriggerHandler.validationRulesProductToJudgment(judgList2, listJudgmentStatuses);
        Test.stopTest();
    }

    public static testMethod void TestgetJudgementRelatedData() {
        Superior_Court__C supCourt = new Superior_Court__C();
        supCourt.Name = 'XYZ';
        insert supCourt;

        Small_Claims_Court__c smCourt = new Small_Claims_Court__c();
        smCourt.Name = 'XYZ';
        insert smCourt;

        Enforcement_County__c enCourt = new Enforcement_County__c();
        enCourt.Name = 'XYZ';
        insert enCourt;

        Court__c court1 = new Court__c();
        court1.Name = 'ABC';
        insert court1;

        Court__c court = new Court__c();
        court.Name = 'XYZ';
        insert court;

        List<Judgment__c> judgmntList = new List<Judgment__c>();
        Judgment__C judInst = new Judgment__C();
        judInst.Legal_Status__c = 'Judgment';
        judInst.Legal_Sub_Status__c = 'Granted';
        judInst.Product_1__c = '201';
        judInst.Interest_Rate_one__c = 21;
        judInst.Balance_one__c = 99;
        judInst.Judgment_Amount__c = null;
        judInst.Judgment_Date__c = Date.newInstance(2016, 12, 19);
        judInst.Superior_Court__c = supCourt.Id;
        judInst.Small_Claims_Court__c = smCourt.Id;
        judInst.Enforcement_County__c = enCourt.Id;
        judInst.County__c = court.Id;
        judInst.Collection_Agency_Identifier__c = '1';
        judInst.Legal_Agency__c = '29';

        judgmntList.add(judInst);
        Test.startTest();
        JudgmentTriggerHandler.getJudgmentRelatedData(judgmntList);
        JudgmentTriggerHandler.nameFormat('ontario');
        Test.stopTest();
    }

    public static testMethod void TestJudgmentData() {
        List<Judgment__c> judgList = new List<Judgment__c>();
        List<Judgment__c> judgList1 = new List<Judgment__c>();
        map<id, Judgment__c> mapOldJudgment = new Map<id, Judgment__c>();
        map<id, Judgment__c> mapOldJud = new Map<id, Judgment__c>();
        list<String> listLegalStatuses = new List<String>();
        Judgment__c judgment = new Judgment__c();
        judgment.Court__c = 'Small Claims Court';
        judgment.Small_Claims_Court__c = null;
        judgList.add(judgment);

        Judgment__c judgment1 = new Judgment__c();
        judgment1.Legal_Status__c = 'Pre-legal';
        judgment1.Court__c = 'Superior Court of Justice';
        judgment1.Superior_Court__c = null;
        judgList.add(judgment1);
        mapOldJudgment.put(judgment1.id, judgment1);

        Superior_Court__C supCourt1 = new Superior_Court__C();
        supCourt1.Name = 'ABC';
        insert supCourt1;

        judgList.add(judgment1);
        Small_Claims_Court__c smCourt = new Small_Claims_Court__c();
        smCourt.Name = 'XYZ';
        insert smCourt;

        JudgmentTriggerHandler.handleBeforeInsert(judgList);
        JudgmentTriggerHandler.handleAfterInsert(judgList);
        Judgment__c judgment2 = new Judgment__c();
        judgment2.Court__c = 'Superior Court of Justice';
        judgment2.Superior_Court__c = supCourt1.id;
        judgment2.Legal_Status__c = 'Post-Judgment';
        judgment2.Legal_Sub_Status__c = 'Vacated';
        judgList.add(judgment2);

        Judgment__c judgment3 = new Judgment__c();
        judgment3.Court__c = 'Small Claims Court';
        judgment3.Small_Claims_Court__c = smCourt.id;
        judgment3.Legal_Agency__c = '29';
        judgment3.Agency_Initiated_Legal_Action__c = '29';
        judgment3.Legal_Status__c = 'Pre-Judgment';
        judgList.add(judgment3);

        product__c prod = new product__c();
        prod.name = '12345';
        prod.Current_Principal_Balance__c = 120;
        prod.Collection_Agency__c = 29;
        insert prod;

        product__c prod1 = new product__c();
        prod1.name = '54321';
        prod1.Current_Principal_Balance__c = 120;
        insert prod1;

        product__c prod2 = new product__c();
        prod2.name = '67890';
        prod2.Current_Principal_Balance__c = 100;
        insert prod2;

        product__c prod3 = new product__c();
        prod3.name = '90876';
        prod3.Current_Principal_Balance__c = 140;
        insert prod3;

        product__c prod4 = new product__c();
        prod4.name = '45678';
        prod4.Current_Principal_Balance__c = 130;
        insert prod4;
        Test.startTest();
        JudgmentTriggerHandler.handleBeforeUpdate(judgList, mapOldJudgment);
        Test.stopTest();
        Judgment__c judgment5 = new Judgment__c();
        judgment5.Legal_Status__c = 'Pre-Judgment';
        judgment5.Judgment_Date__c = Date.newInstance(2021, 12, 9);

        Judgment__c judgment4 = new Judgment__c();
        judgment4.Court__c = 'Small Claims Court';
        judgment4.Small_Claims_Court__c = smCourt.id;
        judgment4.Legal_Agency__c = '29';
        judgment4.Agency_Initiated_Legal_Action__c = '29';
        judgment4.Legal_Status__c = 'Judgment';
        judgment4.Legal_Sub_Status__c = 'Default Judgment';
        judgment4.Judgment_Date__c = Date.newInstance(2022, 5, 9);
        judgment4.Placed_Agency__c = '29';
        judgment4.Interest_Rate_one__c = 5;
        judgment4.Balance_one__c = 120;
        judgment4.Interest_Rate_two__c = 5;
        judgment4.Balance_two__c = 100;
        judgment4.Interest_Rate_three__c = 5;
        judgment4.Balance_three__c = 110;
        judgment4.Interest_Rate_four__c = 5;
        judgment4.Balance_four__c = 140;
        judgment4.Interest_Rate_five__c = 5;
        judgment4.Balance_five__c = 130;
        judgment4.Product_1__c = '12345';
        judgment4.Product_2__c = '54321';
        judgment4.Product_3__c = '67890';
        judgment4.Product_4__c = '90876';
        judgment4.Product_5__c = '45678';
        judgList1.add(judgment4);
        listLegalStatuses.add(judgment4.Legal_Status__c);

        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name = 'A-0007';
        mapping.Judgment_Legal_Status__c = 'Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Default Judgment';
        mapping.Codes__c = '290000';
        mapping.Product_Parent__c = 'Judgment';
        insert mapping;

        Account_Judgment__c acctJudgment = new Account_Judgment__c();
        acctJudgment.Judgment__c = judgment4.Id;
        acctJudgment.Product__c = prod.Id;
        acctJudgment.Status__c = 'Active';
        insert acctJudgment;

        Account_Judgment__c acctJudgment1 = new Account_Judgment__c();
        acctJudgment1.Judgment__c = judgment4.Id;
        acctJudgment1.Product__c = prod1.Id;
        acctJudgment1.Status__c = 'Active';
        insert acctJudgment1;

        Account_Judgment__c acctJudgment2 = new Account_Judgment__c();
        acctJudgment2.Judgment__c = judgment4.Id;
        acctJudgment2.Product__c = prod2.Id;
        acctJudgment2.Status__c = 'Active';
        insert acctJudgment2;

        Account_Judgment__c acctJudgment3 = new Account_Judgment__c();
        acctJudgment3.Judgment__c = judgment4.Id;
        acctJudgment3.Product__c = prod3.Id;
        acctJudgment3.Status__c = 'Active';
        insert acctJudgment3;

        Account_Judgment__c acctJudgment4 = new Account_Judgment__c();
        acctJudgment4.Judgment__c = judgment4.Id;
        acctJudgment4.Product__c = prod4.Id;
        acctJudgment4.Status__c = 'Active';
        insert acctJudgment4;

        JudgmentTriggerHandler.updateJudgmentInterestBalOnProduct(judgList1, mapOldJudgment);
        JudgmentTriggerHandler.updateProductStatusesOnJudgment(judgList1, listLegalStatuses);
    }
}