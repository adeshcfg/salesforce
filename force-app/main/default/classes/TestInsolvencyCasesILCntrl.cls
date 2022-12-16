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
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
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