/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyCasesILCntrl
 *  @author : A5E Consulting
 *  @date : 10/12/2016
 * 
 *************************************************************************************************/
 
@isTest
private class TestInsolvencyCasesILCntrl{
	
	@testSetup
    static void testData(){
        //Application config creation
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;
    }
	
	//Test Controller
	static testMethod void controllerTest(){
		
		//Insolvency 
		Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insert insolv;
        
        //Insolvency Account
        Insolvency_Account__c insolvAcc = new Insolvency_Account__c();
        insolvAcc.name = 'insolvAccnt';
        insolvAcc.Insolvency__c = insolv.Id;
        insolvAcc.Account_Number_Without_Space__c='123';
        insert insolvAcc;
        
        //Cases
        Case insolvCase = new Case();
        insolvCase.Insolvency__c = insolv.id;
        insert insolvCase;        
        Case insolvAccntCase = new Case();
        insolvAccntCase.Insolvency_Account__c = insolvAcc.id;
        insert insolvAccntCase;   

		ApexPages.currentPage().getParameters().put('id', insolv.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(insolv);
        InsolvencyCasesILCntrl cc = new InsolvencyCasesILCntrl(sc);    
	}

}