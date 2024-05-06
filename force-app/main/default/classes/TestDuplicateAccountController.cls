/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for DuplicateAccountController
 *  @author : A5E Consulting
 *  @date : 06/29/2018
 * 
 *************************************************************************************************/
@isTest
public class TestDuplicateAccountController {
    
    static testMethod void DuplicateAccountTest(){
        //Custom setting record Creation
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
        
        test.startTest();
        //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        insolv1.Name = '12456789';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolvList.add(insolv1);
        insert insolvList;
    
        //Insolvency Account records
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        Insolvency_Account__c ia2 = new Insolvency_Account__c();
        List<Insolvency_Account__c> iaList = new List<Insolvency_Account__c>();
        RecordType RecrdId = [Select Id from RecordType where SObjectType = 'Insolvency_Account__c' and DeveloperName = 'Scotia_Bank_Insolvency_Account'];
        ia1.Name = 'QA-001';
        Ia1.RecordTypeId=RecrdId.id;
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Is_Duplicate_Resolved__c = false;
        insert ia1;
        
        //Update Insolvency record
        ia1.Insolvency_Status__c = 'For Owner Review';
        update ia1;
        
        ia2.RecordTypeId=RecrdId.id;
        ia2.Name = 'QA- 001';
        ia2.Insolvency_Status__c = 'New';
        ia2.Claim_Type__c = 'Secured';
        ia2.Insolvency__c = insolv1.Id;
        ia2.Reasons_for_Duplicate_Account_Number__c = 'Allow Duplicate';
        ia2.Is_Duplicate_Resolved__c = true;
        insert ia2;
        
        ia1.Insolvency_Status__c = 'For Owner Review';
        update ia1;
        
        iaList.add(ia1);  
        iaList.add(ia2);
        
        ApexPages.currentPage().getParameters().put('id', ia2.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ia2);
        DuplicateAccountController cc = new DuplicateAccountController(sc); 
        
        //Calling methods
        //cc.DuplicateAccountList(ia2.Id);
        cc.save();
        cc.getInslAcctWrappers();
        test.stopTest();
    }
}