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
        Insolvency_Account__c insolvAcc = new Insolvency_Account__c(Insolvency__c = insolv.Id,Account_Number_Without_Space__c ='1234',Client_Identifier__c ='Scotia',Insolvency_Status__c ='PoC Package Generated', OwnerID = UserInfo.getUserId(),Claim_Amount__c =10);
        insert insolvAcc ;    
        
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = true , Run_Record_Ownership__c = true,Ignore_Account_Number_for_DuplicateCheck__c = 'LINEOFCREDIT',
                                                                                     Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm,Fairstone',Bank_Eligible_for_Duplicate_Check__c='SPL,SDA,Scotia,Affirm',
                                                                                     Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank,SPL,SDA,Fairstone',Eligible_for_Claim_Type_Calculation__c= 'Scotia Bank,SPL,SDA,Fairstone');
        insert appConfig;
    }
    
    public static User getCommunityUser(String profileName){ 
        Account acc = new Account(Name='aset');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, FirstName= 'fname', LastName='lname');
        insert con;
               
        User uzer = new User();
        uzer.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        uzer.FirstName = 'CSRTest';
        uzer.Lastname = 'TestUser';
        uzer.Email = 'CSRTestUser@testOrg.com';
        uzer.Alias = 'testals';
        uzer.TimeZoneSidKey = 'America/Los_Angeles';
        uzer.LocaleSidKey = 'en_US';
        uzer.EmailEncodingKey = 'UTF-8';
        uzer.LanguageLocaleKey = 'en_US';
        uzer.ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        uzer.Phone='9161234456';
        uzer.Street='Some Street';
        uzer.City='Torranto';
        uzer.PostalCode='23456';
        uzer.Country = 'CAN';
        uzer.State = 'MA';
        uzer.isActive = true; 
        uzer.ContactId = con.Id;       
        insert uzer;
        return uzer;       
    }
    
    public static void shareInsolvencyRecord(String userId){
        Insolvency__c insolvency = [Select Id From Insolvency__c Limit 1];
        Insolvency__Share insShare= new Insolvency__Share();
        insShare.ParentId = insolvency.Id;
        insShare.AccessLevel='Edit';
        insShare.UserOrGroupId = userId;
        insShare.RowCause='manual';
        Database.SaveResult sr = Database.insert(insShare,false);
    }
    
    public testmethod static void testInsolvencyLockSB(){
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        User u = getCommunityUser('Scotia Bank Community User');
        shareInsolvencyRecord(u.Id);
        Insolvency__c insolv = [SELECT name FROM Insolvency__c LIMIT 1];
        Insolvency_Account__c insolvAcc = [SELECT OwnerID,Client_Identifier__c FROM Insolvency_Account__c LIMIT 1];
        insolvAcc.OwnerID= Userinfo.getUserId();
        update insolvAcc;
        ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
        // call the constructor
        InsolvencyAccountEditController controller = new InsolvencyAccountEditController (new ApexPages.StandardController(insolvAcc));
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolvAcc.Client_Identifier__c = null;
        update insolvAcc;
        controller.redirPage();
    }
    
    public testmethod static void testInsolvencyLockCB(){
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        User u = getCommunityUser('SPL Community User');
        shareInsolvencyRecord(u.Id);
        Insolvency_Account__c insolvAcc = [SELECT OwnerID FROM Insolvency_Account__c LIMIT 1];
        insolvAcc.OwnerID= Userinfo.getUserId();
        update insolvAcc;
        ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
        // call the constructor
        InsolvencyAccountEditController controller = new InsolvencyAccountEditController (new ApexPages.StandardController(insolvAcc));
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolvAcc.Client_Identifier__c = null;
        update insolvAcc;
        controller.redirPage();
    }
    
    public testmethod static void testInsolvencyLockSDA(){
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        User u = getCommunityUser('SDA Community User');
        shareInsolvencyRecord(u.Id);
        Insolvency_Account__c insolvAcc = [SELECT OwnerID FROM Insolvency_Account__c LIMIT 1];
        insolvAcc.OwnerID= Userinfo.getUserId();
        update insolvAcc;
        ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
        // call the constructor
        InsolvencyAccountEditController controller = new InsolvencyAccountEditController (new ApexPages.StandardController(insolvAcc));
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolvAcc.Client_Identifier__c = null;
        update insolvAcc;
        controller.redirPage();
    }
    
    public testmethod static void testInsolvencyLockFS(){
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        User u = getCommunityUser('Fairstone Community User');
        shareInsolvencyRecord(u.Id);
        Insolvency_Account__c insolvAcc = [SELECT OwnerID FROM Insolvency_Account__c LIMIT 1];
        insolvAcc.OwnerID= Userinfo.getUserId();
        update insolvAcc;
        ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
        // call the constructor
        InsolvencyAccountEditController controller = new InsolvencyAccountEditController (new ApexPages.StandardController(insolvAcc));
        controller.redirPage();
        System.runAs(u){
            controller.redirPage();
        }
        insolvAcc.Client_Identifier__c = null;
        update insolvAcc;
        controller.redirPage();
    }

    public testmethod static void testInsolvencyLockGE(){
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        User u = getCommunityUser('Goeasy Community User');
        shareInsolvencyRecord(u.Id);
        Insolvency_Account__c insolvAcc = [SELECT OwnerID FROM Insolvency_Account__c LIMIT 1];
        insolvAcc.OwnerID= Userinfo.getUserId();
        update insolvAcc;
        ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
        // call the constructor
        InsolvencyAccountEditController controller = new InsolvencyAccountEditController (new ApexPages.StandardController(insolvAcc));
        System.runAs(u){
            controller.redirPage();
        }
        insolvAcc.Client_Identifier__c = null;
        update insolvAcc;
        controller.redirPage();
    }
}