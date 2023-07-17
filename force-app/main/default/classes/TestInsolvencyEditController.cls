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
        
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = true, Run_Record_Ownership__c = true, Domain_Name__c = '@rcfax.test');
        insert appConfig;
    }
    
    public testmethod static void testInsolvencyLockSB(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        User u = TestInsolvencyAccountEditController.getCommunityUser('Scotia Bank Community User');
        TestInsolvencyAccountEditController.shareInsolvencyRecord(u.Id);
        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        // call the constructor
        InsolvencyEditController controller = new InsolvencyEditController(new ApexPages.StandardController(insolv));
        controller.redirPage();
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolv.Client_Identifiers__c = null;
        update insolv;
        controller.redirPage();
    }
    
    public testmethod static void testInsolvencyLockCB(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        User u = TestInsolvencyAccountEditController.getCommunityUser('SPL Community User');
        TestInsolvencyAccountEditController.shareInsolvencyRecord(u.Id);
        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        // call the constructor
        InsolvencyEditController controller = new InsolvencyEditController(new ApexPages.StandardController(insolv));
        controller.redirPage();
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolv.Client_Identifiers__c = null;
        update insolv;
        controller.redirPage();
    }
    
    public testmethod static void testInsolvencyLockSDA(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        User u = TestInsolvencyAccountEditController.getCommunityUser('SDA Community User');
        TestInsolvencyAccountEditController.shareInsolvencyRecord(u.Id);
        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        // call the constructor
        InsolvencyEditController controller = new InsolvencyEditController(new ApexPages.StandardController(insolv));
        controller.redirPage();
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolv.Client_Identifiers__c = null;
        update insolv;
        controller.redirPage();
    }
    
    public testmethod static void testInsolvencyLockFS(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        User u = TestInsolvencyAccountEditController.getCommunityUser('Fairstone Community User');
        TestInsolvencyAccountEditController.shareInsolvencyRecord(u.Id);
        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        // call the constructor
        InsolvencyEditController controller = new InsolvencyEditController(new ApexPages.StandardController(insolv));
        controller.redirPage();
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolv.Client_Identifiers__c = null;
        update insolv;
        controller.redirPage();
    }

    public testmethod static void testInsolvencyLockGE(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        User u = TestInsolvencyAccountEditController.getCommunityUser('Goeasy Community User');
        TestInsolvencyAccountEditController.shareInsolvencyRecord(u.Id);
        ApexPages.currentPage().getParameters().put('id', insolv.Id);
        // call the constructor
        InsolvencyEditController controller = new InsolvencyEditController(new ApexPages.StandardController(insolv));
        System.runAs(u){
            controller.redirPage();
        }
        insolv.Client_Identifiers__c = null;
        update insolv;
        controller.redirPage();
    }

    @IsTest
    static void testFileSizeToString(){
        Test.startTest();
        InsolvencyUtil.fileSizeToString(1025);
        InsolvencyUtil.fileSizeToString(1025*1024);
        InsolvencyUtil.fileSizeToString(1025*1024*1024);
        Test.stopTest();
    }

    @IsTest
    static void testFormatFaxAsEmail(){
        Test.startTest();
        InsolvencyUtil.formatFaxAsEmail('12345');
        Test.stopTest();
    }
}