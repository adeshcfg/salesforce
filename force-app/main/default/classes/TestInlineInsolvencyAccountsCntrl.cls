/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InlineInsolvencyAccountsCntrl
 *  @author : A5E Consulting
 *  @date : 03/09/2018
 * 
 *************************************************************************************************/

@isTest
public class TestInlineInsolvencyAccountsCntrl{

    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Profile_Eligible_for_Duplicate_Check__c = [SELECT Name FROM Profile WHERE ID =: UserInfo.getProfileId() LIMIT 1].Name;
        config.Bank_Eligible_for_Duplicate_Check__c = 'Scotia';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        insert config;  
    }
    
    //Test Controller
    static testMethod void testController(){
        //Insolvency 
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insolv.Insolvency_Status__c = 'For Owner Review';
        insert insolv;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();

 
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.RecordTypeId = scotiabank;
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct;
        
        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        InlineInsolvencyAccountsCntrl obj = new InlineInsolvencyAccountsCntrl(new ApexPages.StandardController(insolv) );
        obj.rType = scotiabank;
        InlineInsolvencyAccountsCntrl.Wrapper wrap = new InlineInsolvencyAccountsCntrl.Wrapper();
        wrap.key = 'key';
        obj.wrapList.clear();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.insolvency__c = insolv.Id;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insolAcct1.Name = '1234';
        insolAcct1.RecordTypeId = scotiabank;
        wrap.insolvAcc = insolAcct1;
        obj.wrapList.add(wrap);
        
        obj.index = 'key';
        obj.removeInsolvencyAccount();
        obj.wrapList.add(wrap);
        
        InlineInsolvencyAccountsCntrl.Wrapper wrap1 = new InlineInsolvencyAccountsCntrl.Wrapper();
        wrap1.key = 'key';
        insolAcct.Name = 'testxx';
        wrap1.insolvAcc = insolAcct;
        obj.wrapList.add(wrap1);
        obj.save();
        
        obj.dupAccCheckList(null, null, '1234',insolv.Id, new list<string>(), 'reason');


        obj.addMore();   
        
        //Insolvency 
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'insolv123';
        insolAcct.Claim_Type__c = 'Unsecured';
        insert insolv1;    
        ApexPages.currentPage().getParameters().put('id', insolv1.Id);
        InlineInsolvencyAccountsCntrl obj1 = new InlineInsolvencyAccountsCntrl(new ApexPages.StandardController(insolv) );
        obj.recordTypeSelected();
        obj.getRecordTypes();
    }
}