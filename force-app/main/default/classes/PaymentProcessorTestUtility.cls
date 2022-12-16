/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Utility class for Customer Portal Test classes 
 *  @author : A5E Consulting
 *  @date : 16/07/2021
 
 *************************************************************************************************/
@isTest
public class PaymentProcessorTestUtility {
    public static Account getDistressedAccount(){
        ID CanaccedeCustomerRecordTypeID = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
               
        Account accInstance = new Account();
        accInstance.FirstName = 'Anna';
        accInstance.LastName = 'Stark';
        accInstance.PersonBirthdate = system.today().addYears(-30);
        accInstance.PersonMailingStreet = '3024 Port Road';
        accInstance.PersonMailingCity = 'Toronto';
        accInstance.PersonMailingState = 'Ontario';
        accInstance.PersonMailingPostalCode = '91761';
        accInstance.PersonHomePhone = '613-555-0178';
        accInstance.Work_Phone__pc = '613-555-0165';
        accInstance.PersonOtherPhone = '613-555-0126';
        accInstance.PersonEmail = 'annatest@email.com';
        accInstance.Secret_Code__c = 'A9OBVW1Q';
        accInstance.Secret_Code_Expiration_Date__c = system.today().addDays(5);
        accInstance.RecordTypeId = CanaccedeCustomerRecordTypeID;
        accInstance.Portal_Profile_Update_Date__c = system.today();
        accInstance.SIN__pc = '123456789';
        insert accInstance; 
        
        return accInstance;
    }
    
    public static Product__c getDistressedProduct(){
        ID DistressedProductRecordTypeID = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        
        Product__c productInstance = new Product__c();
        //productInstance.Customer__c = accInstance.Id;
        productInstance.Name = 'Test Product';
        productInstance.First_Name__c = 'Anna1';
        productInstance.Last_Name__c = 'Stark1';
        productInstance.Email_Address__c = 'anna@email.com';
        productInstance.Date_of_Birth__c = system.today().addYears(-29);
        productInstance.Address_Line1__c = 'Street1';
        productInstance.City__c = 'T';
        productInstance.Zip_Code__c = '91762';
        productInstance.State__c = 'ON';   
        productInstance.Phone_Home__c = '613-555-0111';
        productInstance.Phone_Work__c = '613-555-0112';
        productInstance.Collection_Agency__c = 68;
        productInstance.RecordTypeId = DistressedProductRecordTypeID;
        productInstance.Collection_Agency__c = 68;
        productInstance.Status__c = 'New Allocation - New Allocation';
        productInstance.Sub_Status__c = 'Ready';
        productInstance.Account_Portfolio_ID__c = '825';
        productInstance.Product_Status__c = 'Test';
        //productInstance.Previous_Primary_Account_Number__c = '112345655';
        insert productInstance;
        
        return productInstance;
    }
    
    public static Payment_Transaction__c getRecurringRequestFund(){
        ID recurringRequestFundId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get('Request Funds Recurring').getRecordTypeId();
        
        Payment_Transaction__c payTransactionInstance = new Payment_Transaction__c();
        payTransactionInstance.RecordTypeId = recurringRequestFundId;
        payTransactionInstance.Payment_Type__c = 'Recurrent Payment';
        payTransactionInstance.Recurrence_Type__c= 'Monthly';
        payTransactionInstance.Amount__c = 10;
        payTransactionInstance.CSV_Export_Completed__c = false;
        payTransactionInstance.Day_Of_Month__c = '24';
        payTransactionInstance.Customer_Email_Address__c = 'anna@email.com';
        payTransactionInstance.End_Date__c = system.today().addMonths(4);
        payTransactionInstance.Payment_Processor_Id__c = '111';
        payTransactionInstance.Connect_Url__c = 'test.com';
        payTransactionInstance.Site_ConnectURL__c = 'test.com';
        insert payTransactionInstance;
        
        return payTransactionInstance;
    }
    
       
    public static Payment_Transaction__c getRecurringPaymentChild(){
        ID recurringPayChildId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get('Recurring Payment Child').getRecordTypeId();
        
        Payment_Transaction__c payTransactionInstance = new Payment_Transaction__c();
        payTransactionInstance.RecordTypeId = recurringPayChildId;
        payTransactionInstance.Payment_Type__c = 'Recurrent Payment';
        payTransactionInstance.Recurrence_Type__c= 'Monthly';
        payTransactionInstance.Amount__c = 10;
        payTransactionInstance.Status__c = 'Completed';
        payTransactionInstance.CSV_Export_Completed__c = false;
        payTransactionInstance.Day_Of_Month__c = '24';
        payTransactionInstance.Customer_Email_Address__c = 'anna@email.com';
        payTransactionInstance.Payment_Processor_Id__c = '33333';
        insert payTransactionInstance;
        return payTransactionInstance;
    }
    
    public static Payment_Transaction__c getRecurringPaymentMaster(){
        ID recurringPayMasterId = Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get('Recurring Payment Master').getRecordTypeId();
        
        Payment_Transaction__c payTransactionInstance = new Payment_Transaction__c();
        payTransactionInstance.RecordTypeId = recurringPayMasterId;
        payTransactionInstance.Payment_Type__c = 'Recurrent Payment';
        payTransactionInstance.Recurrence_Type__c= 'Monthly';
        payTransactionInstance.Amount__c = 10;
        payTransactionInstance.Status__c = 'Completed';
        payTransactionInstance.CSV_Export_Completed__c = false;
        payTransactionInstance.Day_Of_Month__c = '24';
        payTransactionInstance.Next_Payment_Date__c = system.today().addDays(1);
        payTransactionInstance.Customer_Email_Address__c = 'anna@email.com';
        payTransactionInstance.Payment_Processor_Id__c = '1111111';
        payTransactionInstance.End_Date__c = date.newinstance(2020, 4, 28);
        
        insert payTransactionInstance;
        
        return payTransactionInstance;
    }
    
}