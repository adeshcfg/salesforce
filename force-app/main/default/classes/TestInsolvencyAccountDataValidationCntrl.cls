/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a Test class for InsolvencyAccountDataValidationCntrl
 *  @author : A5E Consulting
 *  @date : 05/08/2018
 
 *************************************************************************************************/
@isTest
public class TestInsolvencyAccountDataValidationCntrl {
    
    //Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
   	//config = [SELECT Run_Insolvency_Account_Trigger__c FROM Application_Config_Settings__c FOR UPDATE]; //update for lock issue
    //Boolean runTrigger = config.Run_Insolvency_Account_Trigger__c;
    
    static testMethod void InsolvencyAccountDataValidationCntrl(){
        
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
        
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        RecordType RecrdId = [Select Id from RecordType where SObjectType = 'Insolvency_Account__c' and DeveloperName = 'Scotia_Bank_Insolvency_Account'];
         insolAcct.name = 'test11';
         insolAcct.RecordTypeId=RecrdId.id;
        insolAcct.Insolvency_Type__c='Division 1 Proposal';
        insolAcct.Claim_Type__c= 'Unsecured';
        insolAcct.Type_of_Service__c ='Service Only';
        insert insolAcct;
    }
        
         static testMethod void InsolvencyAccountDataValidationCntrl1(){
             
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
             
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        RecordType RecrdId = [Select Id from RecordType where SObjectType = 'Insolvency_Account__c' and DeveloperName = 'Scotia_Bank_Insolvency_Account'];
        insolAcct.name = 'test22';
        insolAcct.RecordTypeId=RecrdId.id;
        insolAcct.Insolvency_Type__c='Consumer Proposal';
        insolAcct.Claim_Type__c= 'Secured';
        insolAcct.Type_of_Service__c ='Service and Sale';
        insert insolAcct;
            
        
        //Call Controller method
        ApexPages.StandardController sc = new ApexPages.StandardController(insolAcct);
        InsolvencyAccountDataValidationCntrl contr = new InsolvencyAccountDataValidationCntrl(sc);
         
}

}