/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a test class for customer portal processing
 *  @author : A5E Consulting
 *  @date : 27/11/2020
 
 *************************************************************************************************/

@isTest
public class TestCustomerPortalProcessing {

    @testSetup
    public static void testData(){
        ID CanaccedeCustomerRecordTypeID = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
        ID DistressedProductRecordTypeID = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        
        Account accInstance = new Account();
		accInstance.FirstName = 'Anna';
        accInstance.LastName = 'Stark';
        accInstance.PersonBirthdate = system.today().addYears(-30);
        accInstance.PersonMailingStreet = '3024 Port Road';
        accInstance.PersonMailingCity = 'Toronto';
        accInstance.PersonMailingState = 'Ontario';
        accInstance.Secret_Code__c = 'a9oBVw1Q';
        accInstance.Secret_Code_Expiration_Date__c = system.today().addDays(5);
        accInstance.RecordTypeId = CanaccedeCustomerRecordTypeID;
        insert accInstance; 
        
        Product__c productInstance = new Product__c();
        productInstance.Customer__c = accInstance.Id;
        productInstance.First_Name__c = 'Anna';
        productInstance.Last_Name__c = 'Stark';
        productInstance.Run_Identifier_Check_On__c = Date.today();
        productInstance.Collection_Agency__c = 68;
        productInstance.RecordTypeId = DistressedProductRecordTypeID;
        insert productInstance;
        
        Account multipleAccountInstance1  = new Account();
        multipleAccountInstance1.LastName = 'Smith';
        multipleAccountInstance1.Secret_Code__c = 'a4oBcUQ';
        multipleAccountInstance1.Secret_Code_Expiration_Date__c = system.today().addDays(5);
        multipleAccountInstance1.RecordTypeId = CanaccedeCustomerRecordTypeID;
        insert multipleAccountInstance1;
        
        Product__c multipleProdInstance1 = new Product__c();
        multipleProdInstance1.Customer__c = multipleAccountInstance1.Id;
        multipleProdInstance1.First_Name__c = 'David';
        multipleProdInstance1.Last_Name__c = 'Smith';
        multipleProdInstance1.Collection_Agency__c = 68;
        multipleProdInstance1.RecordTypeId = DistressedProductRecordTypeID;
        insert multipleProdInstance1;
        
        Product__c multipleProdInstance2 = new Product__c();
        multipleProdInstance2.Customer__c = multipleAccountInstance1.Id;
        multipleProdInstance2.First_Name__c = 'David';
        multipleProdInstance2.Last_Name__c = 'Smith';
        multipleProdInstance2.Collection_Agency__c = 68;
        multipleProdInstance2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();        
        insert multipleProdInstance2;
        
        Customer_Portal_Setting__c portalSetting = new Customer_Portal_Setting__c();
        portalSetting.Error_page_URL__c  ='www.google.com';
        portalSetting.Canaccede_Customer_RecordTypeID__c = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
        portalSetting.Distressed_Product_RecordTypeID__c = DistressedProductRecordTypeID;
        insert portalSetting;
        
        Placement__c placementInstance = new Placement__c();
        placementInstance.Name = '68';
        placementInstance.Agency_Name__c = 'ICT';
        placementInstance.Agency_Email__c = 'ict_agency@test.com';
        placementInstance.Agency_Phone_Number__c = '68989967415';
        placementInstance.Agency_City__c = 'Agency Test Address';
        placementInstance.Agency_Logo_URL__c = 'www.url.com';
        placementInstance.Include_In_Portal_Search__c = true;
        insert placementInstance;
    }
    
    public static testmethod void testIncorrectData(){
        Test.setCurrentPageReference(new PageReference('AccountSearch'));
        Product__c product = new Product__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(product);
        AccountSearchController controller = new AccountSearchController(sc);
        //Birthdate entered is greater than today
        controller.dateOfBirthStr = '01-01-2022';
        controller.searchAccounts();
        
        //Search with incorrect authentication code
        controller.authenticationCode = 'abc';
        controller.provinceName = 'ON';
        controller.searchAccounts();

    }
    public static testmethod void testFirstUser(){
        Test.setCurrentPageReference(new PageReference('AccountSearch'));
        Product__c product = new Product__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(product);
        AccountSearchController controller = new AccountSearchController(sc);
        
        controller.authenticationCode = 'a9oBVw1Q';
        controller.searchAccounts();
        
        Account account = [SELECT ID from Account LIMIT 1];
        Test.setCurrentPageReference(new PageReference('AccountRegistration'));
        System.currentPageReference().getParameters().put('uniqueId', account.ID);
        
        AccountRegistrationController registrationController = new AccountRegistrationController();
        registrationController.userPhone = '928495445';
        registrationController.userEmail = 'testemail@test.com';
        registrationController.userMarketingConsent = true;
        registrationController.terms = true;
        registrationController.registerAccount();
        
        controller.authenticationCode = 'a9oBVw1Q';
        controller.searchAccounts();
    }
    
    public static testMethod void testAccountDetails(){
        Account account = [SELECT ID from Account WHERE Secret_Code__c = 'a9oBVw1Q' LIMIT 1];
        account.Verification_Status__c = 'Verified';
        account.Search_Performed__c = true;
        update account;
        //test blank params in URL
        Test.setCurrentPageReference(new PageReference('AccountResults'));
        AccountResultsController resultController = new AccountResultsController();
        resultController.check();
        //test securecode in URL
        System.currentPageReference().getParameters().put('secureCode', 'a9oBVw1Q');
        AccountResultsController resultController2 = new AccountResultsController();
        resultController2.check();
		
		//test incorrect url param        
        Test.setCurrentPageReference(new PageReference('AccountResults'));
        AccountResultsController resultController3 = new AccountResultsController();
        System.currentPageReference().getParameters().put('uniqueId', '9878');
        resultController3.check();
        
        //test correct URL param
        System.currentPageReference().getParameters().put('uniqueId', account.ID);
        AccountResultsController resultController4 = new AccountResultsController();
        resultController4.check();
        
        Test.setCurrentPageReference(new PageReference('AccountSearch'));
        Product__c product = new Product__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        AccountSearchController searchController = new AccountSearchController(sc);
        searchController.firstName = 'Anna';
        searchController.lastName = 'Stark';
        searchController.address1 = '3024 Port Road';
        searchController.address2 = '';
        searchController.provinceName = 'Ontario';
        searchController.searchAccounts();
    }
    
    public static testMethod void testSearchError(){
        Test.setCurrentPageReference(new PageReference('AccountSearch'));
        Product__c product = new Product__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(product);
        AccountSearchController controller = new AccountSearchController(sc);
        //Search with incorrect authentication code
        controller.authenticationCode = 'a4oBcUQ';
        controller.searchAccounts();   
    }
    
    public static testMethod void testAccountInitiate(){
        Account account = [SELECT ID from Account WHERE Secret_Code__c = 'a9oBVw1Q' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('AccountInitiate'));
        Product__c product = new Product__c();
        
        System.currentPageReference().getParameters().put('uniqueId', account.ID);
        AccountInitiateController controller = new AccountInitiateController();
        controller.checkNavigation();
        
        account.User_Registration_Date__c = system.today();
        account.Verification_Status__c = 'Verified';
        update account;
        
        controller.checkNavigation();
    }
    
    public static testMethod void testAccountVerification(){
        Account account = [SELECT ID from Account WHERE Secret_Code__c = 'a9oBVw1Q' LIMIT 1];
        account.Verification_Auth_Token__c = 'sEff9HTDcvb';
        update account;
        Test.setCurrentPageReference(new PageReference('AccountVerification'));
        
        System.currentPageReference().getParameters().put('vat', 'sEff9HTDcvb');
        AccountVerificationController  controller = new AccountVerificationController ();
        controller.checkVerifyRequest();
        
        account.User_Registration_Date__c = system.today();
        account.Verification_Status__c = 'Verified';
        update account;
        controller.checkVerifyRequest();
        
        account.Verification_Expiration_Date__c = system.today().addDays(-1);
        update account;
        controller.checkVerifyRequest();
    }
}