/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyAccountRecordTypeController
 *  @author : A5E Consulting
 *  @date : 05/16/2018
 
 *************************************************************************************************/
 @isTest
public class TestInsolvencyAccRecordTypeController {
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Trigger__c = true;
        insert config;  
    }
    
    static testMethod void testController(){
        UserRole obj=new UserRole(Name= 'ABC'); 
		insert obj;
        
    	User u = new User(
     	ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     	LastName = 'last',
		Email = 'puser000@amamama.com',
        Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     	CompanyName = 'TEST',
     	Title = 'title',
     	Alias = 'alias',
     	TimeZoneSidKey = 'America/Los_Angeles',
     	EmailEncodingKey = 'UTF-8',
     	LanguageLocaleKey = 'en_US',
     	LocaleSidKey = 'en_US',
     	UserRoleId = obj.Id,
        To_Work_On__c = 'Scotia Bank'
		);
        insert u;
        
        //Call Controller method
      //  ApexPages.StandardController sc = new ApexPages.StandardController(u);
        InsolvencyAccountRecordTypeController contr = new InsolvencyAccountRecordTypeController();
        contr.getEligibleRecordTypeOptions();
        contr.getRecordToWorkOn();
        contr.getRecordTypeToWorkOn();
        contr.redirPage();
    }

}