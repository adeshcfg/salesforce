/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of AllDuplicateAccountController
*  @author : A5E Consulting
*  @date : 25/06/2018
* 
*************************************************************************************************/
@IsTest
public class TestAllDuplicateAccountController {
    
    static testMethod void testData(){
        
        //Custom setting record creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Display_Duplicate_Accounts_List_View__c=10;
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config; 
        
        Id devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        
        //Insolvency insertion
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        
        //insolv.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolv.Insolvency_Date__c = Date.Today().addMonths(-1);
        
        insolv.Insolvency_Type__c='Bankruptcy';
        insert insolv;
        
        List<Insolvency_Account__c> insolAcctList = new List<Insolvency_Account__c>();
        
        //Insolvency Account record insertion
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestDup -1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Excluded_from_Purchase__c=False;
        insolAcct.Excluded_Account_Comments__c='TestData';
        insolAcct.Is_Duplicate_Resolved__c=False;
        insolAcct.Insolvency_Type__c='Bankruptcy';
        insolAcct.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct.Product_Code__c='MOR';
        insolAcct.Debtor__c='test';
        insolAcct.PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct.Asset_Status__c='Bulk Purchased';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';    
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcctList.add(insolAcct);

        //Insolvency Account-1 record insertion
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'TestDup -1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Amount__c = 1200.00;
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Excluded_from_Purchase__c=False;
        insolAcct1.Excluded_Account_Comments__c='TestData';
        insolAcct1.Is_Duplicate_Resolved__c=False;
        insolAcct1.Insolvency_Type__c='Bankruptcy';
        insolAcct1.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct1.Product_Code__c='MOR';
        insolAcct1.Debtor__c='test';
        insolAcct1.PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct1.Asset_Status__c='Bulk Purchased';
        insolAcct1.Insolvency__c = insolv.id;
        insolAcct1.Account_Type__c = '';
        insolAcct1.Borrower_Primary__c = '';
        insolAcct1.Type_of_Service__c = '';
        insolAcct1.Claim_Type__c = '';
        insolAcct1.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcctList.add(insolAcct1);
        
        //Insert List containing 2 Insolvency Account records
        insert insolAcctList;
        
        //calling Apex methods 
        AllDuplicateAccountController cc = new AllDuplicateAccountController(); 
        cc.selectedBankName='All';
        cc.performSearch();
        cc.initiateSearch();
        cc.doSave();
        cc.exportDupAcct();
        //cc.AllSearchedAccountList();
        cc.getBankNames();
        cc.getInsolvencyType();
        cc.getInsolvencyStatus();
        cc.getClaimTypes();
        cc.getAssetStatus();
        cc.nextBankAccountList();
        cc.Beginning();    
        //cc.Previous();
        cc.Next();
        cc.End();
        cc.getDisablePrevious();
        cc.getDisableNext();    
        cc.getTotal_size();
        cc.getPageNumber();    
        cc.getTotalPages();
        cc.getTotalStartCount();    
        cc.getTotalEndCount();    
        AllDuplicateAccountController.formatDate(system.today());
        AllDuplicateAccountController.AcctWrpper ccaw=new AllDuplicateAccountController.AcctWrpper(insolAcct,True);
                 
    }
    
}