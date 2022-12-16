/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyNoteCntrl
 *  @author : A5E Consulting
 *  @date : 12/08/2016
 * 
 *************************************************************************************************/
 
@isTest
private class TestInsolvencyNoteCntrl{
	
	@testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Trigger__c = true;
        insert config;  
    }
	
	//Test Method
	static testMethod void insolvencyNoteTest(){
        
        //Insolvency Record
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insolv.Debtor_2_Estate_Number__c = '985236987';       
        insert insolv;
        
        //Note Record
        Note testNote = new Note();
        testNote.parentId = insolv.Id;
        testNote.Title = 'Test Note';
        testNote.Body = 'Test Body';        
        insert testNote;
        
        //Call controller
        Apexpages.currentpage().getparameters().put('id',insolv.id);
        InsolvencyNoteCntrl inc = new InsolvencyNoteCntrl(new ApexPages.StandardController(insolv));            
        System.assertEquals(1, inc.getInslNoteWrappers().size());
	}
}