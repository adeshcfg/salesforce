/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PortalCustomerProcessor
 *  @author : A5E Consulting
 *  @date : 07/099/2021
 
 *************************************************************************************************/
@isTest
public class TestPortalCustomerProcessor {
    public static testMethod void parseCustmerJSONTest(){
        Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        system.debug('ss'+customerInstance.SF_ID__c);
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        productInstance.Customer__c = customerInstance.Id;
        update productInstance;
        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Primary_FirstName":"Anna", "Primary_LastName": "Stark",'+
                                    '"Primary_PersonEmail": "anna@test.com","Primary_SIN": 11111,"Primary_PersonMailingStreet": "test",'+
                                    '"Primary_PersonMailingCity": "test","Primary_PersonMailingPostalCode": "123","Primary_PersonMailingState": "test","Primary_PersonHomePhone": 1245666,"Primary_Work_Phone": 1245666,"Primary_PersonOtherPhone": 1245666}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalCustomerProcessor.processCustomer();
    }
    
    public static testMethod void updateCustomerTest(){
        /*Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        system.debug('ss'+customerInstance.SF_ID__c);
        Product__c product = PaymentProcessorTestUtility.getDistressedProduct();
        product.Customer__c = customerInstance.Id;
        update product;

        system.debug('sss'+customerInstance.Products__r);*/

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
        insert accInstance; 
        
        
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
        //productInstance.State__c = 'ON';
        productInstance.Phone_Home__c = '613-555-0111';
        productInstance.Phone_Work__c = '613-555-0112';
        productInstance.Collection_Agency__c = 68;
        productInstance.RecordTypeId = DistressedProductRecordTypeID;
        productInstance.Collection_Agency__c = 68;
        productInstance.Customer__c = accInstance.Id;
        insert productInstance;
        
        
        
        
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Primary_FirstName', 'Annie');
        paramMap.put('Primary_LastName','james');
        paramMap.put('Primary_PersonEmail','test@testemail.com');
        //paramMap.put('Primary_SIN','123333');
        paramMap.put('Primary_PersonMailingStreet','testStreet');
        paramMap.put('Primary_PersonMailingCity','testCity');
        paramMap.put('Primary_PersonMailingPostalCode','55555');
        paramMap.put('Primary_PersonMailingState','testState');
        paramMap.put('Primary_PersonHomePhone','2222222');
        paramMap.put('Primary_Work_Phone','1111111');
        paramMap.put('Primary_PersonOtherPhone','111111');
        
        PortalCustomerProcessorUtil.updateCustomer(paramMap, accInstance);
    }
}