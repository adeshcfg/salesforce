/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a test class for FidemCustomerNotificationBatch
 *  @author : A5E Consulting
 *  @date : 05/24/2021
 
 *************************************************************************************************/ 

@isTest
public class TestFidemCustomerNotificationBatch {
 
    @isTest 
    public static void TestFidemCustomerNotificationBatch() {
        
        //To fetch Record type Id of Credit card account record type from Product
        list<RecordType> recordTypeProdList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Product__c' and recordtype.name='Credit Card Account']);
        
        //To fetch Record type Id of Customer
        String RecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId();
        
        List<Account> listAcc = new List<Account>();
        List<Product__c> listProd = new List<Product__c>();
         
        //Creation of Person Account
        Account personAcc = new Account(
            RecordTypeID=RecTypeId,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            PersonHasOptedOutOfEmail = false 
        );
        
        listAcc.add(personAcc);
        
        //Creation of Person Accoun 2
        Account personAcc2 = new Account(
            RecordTypeID=RecTypeId,
            FirstName='Test FName1',
            LastName='Test LName1',
            PersonMailingStreet='test2@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test2@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            PersonHasOptedOutOfEmail = false 
        );        
        listAcc.add(personAcc2);
        insert listAcc;
        
        //Creation of Product
        Product__c prod = new Product__c();
        prod.RecordTypeId = recordTypeProdList[0].Id;
        prod.Name = 'Test-001';
        prod.Current_Balance__c=123;
        prod.PRIN_Number__c=200;
        prod.Last_Statement_Date__c = System.Today().addDays(-1);
        prod.External_Status_Current__c = 'j';
        prod.Stmt_Hold_Flag__c = 'R';
        prod.Paperless_Statement__c = false;
        prod.Customer__c = listAcc[0].id;
        listProd.add(prod);
        
        //Creation of Product2
        Product__c prod2 = new Product__c();
        prod2.RecordTypeId = recordTypeProdList[0].Id;
        prod2.Name = 'Test-002';
        prod2.Current_Balance__c=1234;
        prod2.PRIN_Number__c=200;
        prod2.Last_Statement_Date__c = System.Today().addDays(-1);
        prod2.External_Status_Current__c = 'j';
        prod2.Paperless_Statement__c = true;
        prod2.Customer__c = listAcc[1].id;
        listProd.add(prod2);
        insert listProd;
        
        //Executing Batch Class
        FidemCustomerNotificationBatch obj = new FidemCustomerNotificationBatch();
        DataBase.executeBatch(obj); 
    }
}