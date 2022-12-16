/**************************************************************************************************
* Class:   
*
*  @description : This is a controller class to manage All Duplicate Insolvency Accounts
*  @author : A5E Consulting
*  @date : 26/04/2019
* 
*************************************************************************************************/
@isTest
public class TestAllDuplicateAccountInlineContrl {
    
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
        config.Run_Remittance_Validation__c = false;
        insert config; 
        
        //Insolvency 
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        insert insolv;
        
        //Insolvency Account record
        Id devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        List<Insolvency_Account__c> insolAcctList = new List<Insolvency_Account__c>();
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestDup -1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct.Insolvency__c = insolv.id;							
        insolAcct.Asset_Status__c='Purchased';
        insolAcct.Duplicate_Reasons_Picklist__c='Re-filed Insolvency with new Estate #';
        insolAcct.RecordTypeId=devRecordTypeId;
        insert insolAcct;
        
        //Test.setCurrentPage(URL.getSalesforceBaseUrl().toExternalForm());
        ApexPages.currentPage().getParameters().put('id',insolAcct.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(insolAcct);
		AllDuplicateAccountInlineContrl Aci= new AllDuplicateAccountInlineContrl(sc);
        Aci.showDupAccount();
        AllDuplicateAccountInlineContrl.AcctWrpper aaw= new AllDuplicateAccountInlineContrl.AcctWrpper(insolAcct,'');
        Aci.getInslAcctWrappers();
        //Aci.getCommunityUrl();
    }
}