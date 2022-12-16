/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a test class for CustomerTrigger
 *  @author : A5E Consulting
 *  @date : 04/08/2021
 
 *************************************************************************************************/
@isTest
public class TestCustomerTriggerHandler {
    public static testMethod void updateCustomerPreviousDetailsTest(){
        Application_Config_Settings__c settings = new Application_Config_Settings__c    ();
        settings.Run_Account_Trigger__c = true;
        //settings.Run_Customer_Update_API_for_Portal__c = true;
        insert settings;
        
        Loan_ReEngineering__c lrpSettings = new Loan_ReEngineering__c();
        lrpSettings.Name = 'test';
        insert lrpSettings;
        
        Account accInstance = PaymentProcessorTestUtility.getDistressedAccount();
        
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        productInstance.Customer__c = accInstance.Id;
        productInstance.Status__c = 'New Allocation - New Allocation';
        productInstance.Sub_Status__c = 'Ready';
        productInstance.Product_Status__c = 'Test';
        productInstance.Account_Portfolio_ID__c = '825';
        update productInstance;
        
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.PersonBirthdate = system.today().addYears(-20);
        accInstance.PersonMailingStreet = '3024 Port Street';
        accInstance.PersonMailingCity = 'T';
        accInstance.PersonMailingState = 'ON';
        accInstance.PersonMailingPostalCode = '91762';
        accInstance.PersonHomePhone = '613-555-0172';
        accInstance.Work_Phone__pc = '613-555-0162';
        accInstance.PersonOtherPhone = '613-555-0122';
        accInstance.PersonEmail = 'annatestt@email.com';
        accInstance.SIN__pc = '0123';
        update accInstance;
        
        
    }
}