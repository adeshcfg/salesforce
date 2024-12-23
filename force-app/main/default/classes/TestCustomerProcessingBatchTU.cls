@isTest
public class TestCustomerProcessingBatchTU {
    @TestSetup
    static void makeData() {
        Work_Assignment__c cimlWs = new Work_Assignment__c();
        cimlWs.RecordTypeId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByDeveloperName().get('Credit_Bureau_Reporting_Files').getRecordTypeId();
        insert cimlWs;
    }

    @isTest
    public static void testCustomerBatchTU() {
        TestDocumentAPIClient.testDocumentAPI();
        // Metro2 File Custom Setting
        Metro2_File__c metro2File = Metro2_File__c.getOrgDefaults();
        metro2File.Name = 'TransUnion';
        metro2File.bureauIdentifier__c = '1230011';
        metro2File.CA__c = 'CN';
        metro2File.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File.HEADER__c = 'HEADER';
        metro2File.HeaderCheck__c = false;
        metro2File.MaxRowsCount__c = '1365';
        metro2File.ZAP__c = 'ZA';
        metro2File.Account_Type__c = '34';
        metro2File.Identification_Number__c = '481FZ51142';
        metro2File.Number_of_Times_To_Report__c = 3;
        insert metro2File;

        Metro__c metroheaderrecsetiing = Metro__c.getOrgDefaults();
        metroheaderrecsetiing.Name = 'Header';
        metroheaderrecsetiing.HeaderCheck__c = false;
        insert metroheaderrecsetiing;

        Id ccsRecordTYpeId = getsObjectRecordTypeId('Product__c', 'CCS Account');

        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(
            Name = '1111',
            RecordTypeId = ccsRecordTYpeId,
            Last_Name__c = 'last name',
            First_Name__c = 'first name',
            Disbursement_Date__c = SYSTEM.Today(),
            Open_Date_TU__c = SYSTEM.Today(),
            Payment_Frequency__c = 'Weekly',
            Monthly_Payment_Amount__c = 1252.00,
            Current_Balance__c = 120.00,
            Original_Balance__c = 123.00,
            Original_Credit_Amount__c = 123.00,
            FairShare_Percentage__c = 12,
            Last_Payment_Amount__c = 123.00,
            Past_Due_Amount__c = 12.00,
            Last_Delinquency_Date__c = SYSTEM.Today(),
            CCS_Stage_Last_Changed__c = SYSTEM.Today(),
            Last_Payment_Date__c = SYSTEM.Today(),
            Middle_Name__c = 'middle',
            SIN__c = '123',
            Phone_Home__c = '12345654',
            Date_of_Birth__c = SYSTEM.Today(),
            Address_Line1__c = 'add',
            Address_Line2__c = 'add',
            City__c = 'NES',
            // State__c = 'CA',
            Provinces__c = 'Nova Scotia',
            Zip_Code__c = '12345',
            CCS_Stage__c = 'Completed',
            TransUnion_Reported_As_Complete_Count__c = null,
            Investment_Group__c = 'BNS CCS 1',
            //Purchase_Date__c = SYSTEM.Today(),
            Suppressed_in_TU__c = false,
            Original_Date_of_Delinquency__c = SYSTEM.Today()
        );
        prodList.add(prod);

        Product__c prod2 = new Product__c(
            Name = '123451234512345123451234512345',
            RecordTypeId = ccsRecordTYpeId,
            Last_Name__c = 'last name of length2',
            First_Name__c = 'first name of length 25 c',
            Disbursement_Date__c = SYSTEM.Today(),
            Open_Date_TU__c = SYSTEM.Today(),
            Payment_Frequency__c = 'Weekly',
            Monthly_Payment_Amount__c = 1252.00,
            Current_Balance__c = 120.00,
            FairShare_Percentage__c = 12,
            Last_Payment_Amount__c = 123.00,
            CCS_Stage_Last_Changed__c = SYSTEM.Today(),
            Last_Payment_Date__c = SYSTEM.Today(),
            Middle_Name__c = 'middle name length20',
            SIN__c = '123456789',
            Phone_Home__c = '1234567890',
            Address_Line1__c = 'address1 of length 32 characters',
            Address_Line2__c = 'address2 of length 32 characters',
            City__c = 'NEWYORK CITY OF USUS',
            //State__c = 'A',
            Provinces__c = 'Nova Scotia',
            Zip_Code__c = '123456789',
            TransUnion_Reported_As_Complete_Count__c = 1,
            Investment_Group__c = 'BNS CCS 1',
            Suppressed_in_TU__c = false,
            //Purchase_Date__c = SYSTEM.Today(),
            Original_Date_of_Delinquency__c = SYSTEM.Today()
        );
        prodList.add(prod2);
        insert prodList;

        MetroFlatFileData__c metroFlatFile = new MetroFlatFileData__c();
        metroFlatFile.HeaderCheck__c = true;
        insert metroFlatFile;

        Id ccsProductPayment = getsObjectRecordTypeId('Product_Payments__c', 'CCS Product Payment');
        Product_Payments__c prodPayments = new Product_Payments__c(
            Payment_Created_Date__c = System.today(),
            RecordTypeId = ccsProductPayment,
            CCS_Account__c = prodList[0].Id,
            Payment_type__c = '1000'
        );
        insert prodPayments;
        CustomerProcessingBatchTU obj = new CustomerProcessingBatchTU();
        Database.executeBatch(obj);
    }

    //Get Object Record Type ID
    public static Id getsObjectRecordTypeId(String objectStr, String recordTypeLabel) {
        SObjectType objToken = Schema.getGlobalDescribe().get(objectStr);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, Schema.RecordTypeInfo> rtMapByName = objDef.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName = rtMapByName.get(recordTypeLabel);
        Id recid = rtByName.getRecordTypeId();
        return recid;
    }
}
