/**************************************************************************************************
 *
 *  Class: TestApplicationFormCanaccedeController   
 *
 *  @description : This is test class for Application Form Canaccede landing page
   @author : A5E Consulting
   @date : 07/08/2020
 
 *************************************************************************************************/
@isTest
public class TestApplicationFormCanaccedeController {
    public static testMethod void testForm(){
        Application_Form_Settings__c setting = new Application_Form_Settings__c();
        setting.Redirect_URL_from_Canaccede_to_Fidem__c = 'www.testurl.com';
        insert setting;
        
        Insolvency__c insolv=new Insolvency__c();
        insolv.Name='1000000';
        insolv.Insolvency_Type__c='Bankruptcy';
        insolv.Insolvency_Received_Date__c=system.today();
        insolv.Insolvency_Date__c=system.today();
        insolv.Debtor_1_Mailing_State_Province__c='Ontario';
        insolv.Debtor_2_Mailing_State_Province__c='Ontario';
        insolv.Debtor_2_Estate_Number__c='10000000';
        insolv.Insolvency_Status__c='Staging';
        insolv.Debtor_1_Court_Number__c='1023';
        insolv.Court_Division_Number__c='1234';
        insolv.Court_District_Name__c='sample';
        insolv.Court_Province_Name__c='sample';
        insolv.Debtor_1_First_Name__c='Synthia';
        insolv.Debtor_1_Last_Name__c='Cloud';
        insolv.Offer_Code__c = 'Test OfferCode';
        insolv.Debtor_1_Mailing_Street__c='sample address';
        insolv.Debtor_1_Mailing_City__c='city sample';
        insolv.Debtor_1_Employer_Postal_Code__c='L7S1X3';
        insolv.Debtor_1_Date_of_Birth__c=system.today();
        insolv.Debtor_1_Gender__c='male';
        insolv.Insolvency_Status_Last_Changed__c=System.now();
        insolv.Expected_Discharge_Month__c='24';
        insolv.Insolvency_Date__c=system.today();
        insert insolv;
        insolv.Name='1000001';
        insolv.Debtor_2_Estate_Number__c='1000002';
        update insolv;

        
        /*Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Canaccede_Customer').getRecordTypeId();
        Account account = new Account();
        account.FirstName = 'Synthia';
        account.LastName = 'Cloud';
        account.RecordTypeId = accRecordTypeId;
        insert account;
        
        system.debug('value : '+[SELECT personcontactid from Account]);
        Id productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Distressed_Account').getRecordTypeId();
        Product__c product = new Product__c();
        product.Name = 'Distressed Product';
        product.RecordTypeId = productRecordTypeId;
        product.Customer__c = account.Id;
        insert product;
        
        Campaign campaign = new Campaign();
        campaign.Name = 'Test Campaign';
        campaign.IsActive = true;
        campaign.StartDate = system.today().addMonths(-10);
        campaign.EndDate = system.today().addMonths(10);
        insert campaign;
        
        Contact contact = new Contact();
        contact.FirstName = 'Synthia';
        contact.LastName = 'Cloud';
        //contact.AccountId = account.Id;
        insert contact;
        
        CampaignMember campaignMember = new CampaignMember();
        campaignMember.ContactId = [SELECT personcontactid from Account][0].personcontactid;
        campaignMember.Offer_Code__c = 'Test OfferCode';
        campaignMember.CampaignId = campaign.Id;
        insert campaignMember;*/
        
        Test.StartTest();
        PageReference pageRef = Page.ApplicationFormCanaccede; 
        Test.setCurrentPageReference(pageRef);
        ApplicationFormCanaccedeController  controller = new ApplicationFormCanaccedeController();
        controller.FirstName2 = 'Synthia';
        controller.LastName2 = 'Cloud1';
        controller.dateofbirth = '11-11-1987';
        controller.Email = 'synthiac@gmail.com';
        controller.Uniqueid = 'Test OfferCode';
        Application__c app1 = new Application__c();
        //controller.app = app1;
        //invalid phone number
        controller.cellPhone = '98524155';
        controller.nextProcessing();
        //valid phone, invalid data -lastname
        controller.cellPhone = '9852415521';
        controller.nextProcessing();
        //valid data
        controller.LastName2 = 'Cloud';
        controller.consent = true;
        controller.nextProcessing();
        
        Test.StopTest();
    }
}