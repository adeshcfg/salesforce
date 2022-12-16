/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of AllDuplicateAccountsExportController
*  @author : A5E Consulting
*  @date : 07/08/2018
* 
*************************************************************************************************/
@IsTest
public class TestAllDuplicateAccountsExportController {
	static testMethod void testData(){
        
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config; 
        
        Id devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
                
        //Insolvency 
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        insert insolv;
        
        List<Insolvency_Account__c> insolAcctList = new List<Insolvency_Account__c>();
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestDup-1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
       // insolAcct.Insolvency_Status__c = '';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcctList.add(insolAcct);
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'TestDup-1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Amount__c = 1200.00;
        insolAcct1.Claim_Type__c = 'Secured';
        //insolAcct1.Insolvency_Status__c = '';
        insolAcct1.Insolvency__c = insolv.id;
        insolAcct1.Account_Type__c = '';
        insolAcct1.Borrower_Primary__c = '';
        insolAcct1.Type_of_Service__c = '';
        insolAcct1.Claim_Type__c = '';
        insolAcct1.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcctList.add(insolAcct1);
        insert insolAcctList;
        
        AllDuplicateAccountsExportController cc = new AllDuplicateAccountsExportController(); 
        cc.selectedBankName = 'Scotia Bank';
        cc.selectedClaimType = 'Secured';
        cc.selectedInsolvencyType = 'All';
        cc.selectedProcessingStatus = 'All';
        cc.getInsolAcounts();
        
        AllDuplicateAccountsExportController cc1 = new AllDuplicateAccountsExportController(); 
        cc1.selectedBankName = 'Scotia Bank';
        cc1.selectedClaimType = 'Secured';
        cc1.selectedInsolvencyType = 'Test';
        cc1.selectedProcessingStatus = 'Test';
        cc1.getInsolAcounts();
    }
}