@isTest(seeAllData = false)
public class TestInsolvencyEditController{

    @testSetup 
    static void testData() {
         // create poc custom settings
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', CFG_Trustee_Email_Default_content__c = 'test', CFG_Trustee_Email_Default_Subject__c ='test');
         insert poc;
         
         // insert insolvency account
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c();
         insert insolvAacc ;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(name = 'test-insolEdit', Client_Identifiers__c = 'Scotia Bank');
         insert insolv;
                                                     
         Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = true, Run_Record_Ownership__c = true);
         insert appConfig;
    }
    
    public testmethod static void testInsolvencyLock(){
         Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
         ApexPages.currentPage().getParameters().put('id', insolv.Id);
          // call the constructor
          InsolvencyEditController controller = new InsolvencyEditController(new ApexPages.StandardController(insolv));
          controller.redirPage();
           controller.redirPage();
           
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
             LocaleSidKey = 'en_US'
        );
        insert u;
        System.runAs(u){
            controller.redirPage();
        }
        insolv.Client_Identifiers__c = null;
           update insolv;
            controller.redirPage();
    }
}