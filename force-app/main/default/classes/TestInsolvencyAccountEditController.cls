@isTest(seeAllData = false)
public class TestInsolvencyAccountEditController{

    @testSetup 
    static void testData() {
         // create poc custom settings
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', CFG_Trustee_Email_Default_content__c = 'test', CFG_Trustee_Email_Default_Subject__c ='test');
         insert poc;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c();
         insolv.name = 'test-Edit001';
         insert insolv;
         
         // insert insolvency account
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c(Insolvency__c = insolv.Id, OwnerID = UserInfo.getUserId());
         insert insolvAacc ;
         
                                                     
         Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = true , Run_Record_Ownership__c = true);
         insert appConfig;
    }
    
    public testmethod static void testInsolvencyLock(){
         Insolvency_Account__c insolvAcc = [SELECT OwnerID FROM Insolvency_Account__c LIMIT 1];
         insolvAcc.OwnerID= USerinfo.getUSerId();
        update insolvAcc;
         ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
          // call the constructor
          InsolvencyAccountEditController controller = new InsolvencyAccountEditController (new ApexPages.StandardController(insolvAcc ));
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
        insolvAcc.Client_Identifier__c = null;
           update insolvAcc;
            controller.redirPage();
    }
}