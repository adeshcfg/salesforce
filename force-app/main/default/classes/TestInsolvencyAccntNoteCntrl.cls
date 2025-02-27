/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyAccntNoteCntrl
 *  @author : A5E Consulting
 *  @date : 12/07/2016
 * 
 *************************************************************************************************/
 
@isTest
private class TestInsolvencyAccntNoteCntrl{
	
    @testSetup
    static void testData(){
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
    }
        
    //Test Method
    static testMethod void insolvencyNoteTest(){
        //Insolvency Record
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insolv.Debtor_2_Estate_Number__c = '985236987';       
        insert insolv;
                
        //Insolvency Account Record
        Insolvency_Account__c insAccnt = new Insolvency_Account__c();
        insAccnt.Name='1056649437375';
        insAccnt.Account_Type__c='Auto';
        insAccnt.Insolvency_Status__c='New';
        insAccnt.Borrower_Primary__c='test';
        insAccnt.Type_of_Service__c='Service and Sale';
        insAccnt.Claim_Type__c='Unsecured';
        insAccnt.Insolvency__c = insolv.Id;
        insAccnt.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        insert insAccnt;
        
        //Note Record
        Note testNote = new Note();
        testNote.parentId = insAccnt.Id;
        testNote.Title = 'Test Note';
        testNote.Body = 'Test Body';        
        insert testNote;
        
        //Call controller
        Apexpages.currentpage().getparameters().put('id',insAccnt.id);
        InsolvencyAccntNoteCntrl inac = new InsolvencyAccntNoteCntrl(new ApexPages.StandardController(insAccnt));
        System.assertEquals(1, inac.getInslNoteWrappers().size());
        
	}
}