@Istest(SeeAllData=true)
public class TestCCSProductInterestCalculation {
	public static testMethod void testMethod1() 
    {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c  settings = API_Call_Details__c.getValues('Agency Portal API');
        system.debug('settings:'+settings);
        //API_Call_Details__c  settings = new API_Call_Details__c ();
        //settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        update settings;   

        Account customer = new Account(FirstName = 'FirstName', LastName = 'Last Name', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Easyfinancial CCS Customer').getRecordTypeId());
        insert customer;
        
        Product__c prod2 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.CCS_Stage__c = 'Missed Payment';
        prod2.Current_Balance__c = 1000; 
        prod2.Interest_Rate__c = 10;
        prod2.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023,07,02);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Easyfinancial CCS Account').getRecordTypeId();
        prod2.Customer__c = customer.id;
        insert prod2;  
        
        Product__c prod3 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod3.name = '1234567';
        prod3.CCS_Stage__c = 'In Progress (notice has been sent)';
        prod3.Current_Balance__c = 500; 
        prod3.Interest_Rate__c = 10;
        prod3.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2024,07,02);
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Flexiti CCS Account').getRecordTypeId();
        prod3.Customer__c = customer.id;
        insert prod3;

        Test.startTest();
        CCSProductInterestCalculation obj = new CCSProductInterestCalculation();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}