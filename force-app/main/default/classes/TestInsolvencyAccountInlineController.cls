/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyAccountInlineController
 *  @author : A5E Consulting
 *  @date : 04/03/2018
 *
 *************************************************************************************************/

@isTest
public class TestInsolvencyAccountInlineController {
    @testSetup
    static void testData() {
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Profile_Eligible_for_Duplicate_Check__c = 'SPL,Goeasy Community User';
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL,Goeasy';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Status_Validations__c = false;
        insert config;
    }

    //Test Controller
    static testMethod void testController() {
        //Insolvency
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insert insolv;

        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        //insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.Client_Identifier__c = 'Goeasy';
        insert insolAcct;

        insolAcct = [SELECT Id, Name FROM insolvency_Account__c WHERE id = :insolAcct.Id];
        insolAcct.name = 'Test 222';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Claim_Amount__c = null;
        insolAcct.Borrower_Primary__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Product_Code__c = '';
        insolAcct.Account_Type__c = '';
        insolAcct.Claim_Amount__c = 100;
        insolAcct.Client_Identifier__c = 'Goeasy';
        update insolAcct;
        //Database.update(insolAcct, false);

        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        ApexPages.currentPage().getParameters().put('viewPage', '');
        ApexPages.StandardController sc = new ApexPages.StandardController(insolv);
        InsolvencyAccountInlineController cc = new InsolvencyAccountInlineController(sc);
        cc.profileName = 'Scotia Bank Community User';
        cc.runDuplicateCheckForBank = true;
        cc.runDuplicateCheckForProfile = true;
        cc.save();
        list<string> ignoreNamesList = new List<string>{ 'UNKNOWN' };
        cc.dupAccCheckList(insolAcct.Id, insolAcct.RecordTypeId, insolAcct.Name, insolAcct.Insolvency__r.Id, ignoreNamesList);
        cc.getInslAcctWrappers();
        //cc.getCommunityUrl();
        cc.message = 'Error has occured';

        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        ApexPages.currentPage().getParameters().put('viewPage', '');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(insolv);
        InsolvencyAccountInlineController cc1 = new InsolvencyAccountInlineController(sc);
        cc1.profileName = 'CFG - Insolvency User';
        cc1.runDuplicateCheckForBank = true;
        cc1.runDuplicateCheckForProfile = true;
        cc1.save();
        list<string> ignoreNamesList1 = new List<string>{ 'UNKNOWN' };
        cc1.dupAccCheckList(insolAcct.Id, insolAcct.RecordTypeId, insolAcct.Name, insolAcct.Insolvency__r.Id, ignoreNamesList1);
        cc1.getInslAcctWrappers();
        cc.createExistingInsolAccountLink('Test', 'Test');
        cc1.message = 'Error has occured';
    }

    static testMethod void testController2() {
        //Insolvency
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insert insolv;

        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.Client_Identifier__c = 'Goeasy';
        insert insolAcct;

        insolAcct = [SELECT Id, Name FROM insolvency_Account__c WHERE id = :insolAcct.Id];
        insolAcct.name = 'Test 222';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Claim_Amount__c = null;
        insolAcct.Borrower_Primary__c = 'Test';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Product_Code__c = 'AUTO';
        insolAcct.Account_Type__c = 'Auto';
        insolAcct.Claim_Amount__c = 100;
        insolAcct.Client_Identifier__c = 'Goeasy';
        update insolAcct;
        //Database.update(insolAcct, false);

        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        ApexPages.currentPage().getParameters().put('viewPage', '');
        ApexPages.StandardController sc = new ApexPages.StandardController(insolv);
        InsolvencyAccountInlineController cc = new InsolvencyAccountInlineController(sc);
        cc.profileName = 'Scotia Bank Community User';
        cc.runDuplicateCheckForBank = true;
        cc.runDuplicateCheckForProfile = true;
        cc.save();
        list<string> ignoreNamesList = new List<string>{ 'UNKNOWN' };
        cc.dupAccCheckList(insolAcct.Id, insolAcct.RecordTypeId, insolAcct.Name, insolAcct.Insolvency__r.Id, ignoreNamesList);
        cc.getInslAcctWrappers();
        //cc.getCommunityUrl();
        cc.message = 'Error has occured';

        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        ApexPages.currentPage().getParameters().put('viewPage', '');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(insolv);
        InsolvencyAccountInlineController cc1 = new InsolvencyAccountInlineController(sc);
        cc1.profileName = 'CFG - Insolvency User';
        cc1.runDuplicateCheckForBank = true;
        cc1.runDuplicateCheckForProfile = true;
        cc1.save();
        list<string> ignoreNamesList1 = new List<string>{ 'UNKNOWN' };
        cc1.dupAccCheckList(insolAcct.Id, insolAcct.RecordTypeId, insolAcct.Name, insolAcct.Insolvency__r.Id, ignoreNamesList1);
        cc1.getInslAcctWrappers();
        cc.createExistingInsolAccountLink('Test', 'Test');
        cc1.message = 'Error has occured';
    }

    @isTest
    static void testCommunityUser() {
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insert insolv;

        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.Client_Identifier__c = 'Goeasy';
        insert insolAcct;

        insolAcct = [SELECT Id, Name FROM insolvency_Account__c WHERE id = :insolAcct.Id];
        insolAcct.name = 'Test 222';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Claim_Amount__c = null;
        insolAcct.Borrower_Primary__c = 'Test';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Product_Code__c = 'AUTO';
        insolAcct.Account_Type__c = 'Auto';
        insolAcct.Claim_Amount__c = 100;
        insolAcct.Client_Identifier__c = 'Goeasy';
        update insolAcct;
        //Database.update(insolAcct, false);

        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        ApexPages.currentPage().getParameters().put('viewPage', '');

        User u = TestInsolvencyAccountEditController.getCommunityUser('Goeasy Community User');
        TestInsolvencyAccountEditController.shareInsolvencyRecord(u.Id);
        System.runAs(u) {
            ApexPages.StandardController scCommunity = new ApexPages.StandardController(insolv);
            InsolvencyAccountInlineController ccCommunity = new InsolvencyAccountInlineController(scCommunity);
        }
    }
}
