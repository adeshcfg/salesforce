@isTest(seeALlData=false)
public class TestCreditBureauClass {
    @TestSetup
    static void makeData() {
        Work_Assignment__c cimlWs = new Work_Assignment__c();
        cimlWs.RecordTypeId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByDeveloperName().get('Credit_Bureau_Reporting_Files').getRecordTypeId();
        insert cimlWs;
    }

    @isTest
    public static void testCustomerBatch() {
        TestDocumentAPIClient.testDocumentAPI();
        Metro2_File__c metro2File = Metro2_File__c.getOrgDefaults();
        metro2File.Name = 'CreditBureauTU';
        metro2File.bureauIdentifier__c = '1230011';
        metro2File.CA__c = 'CN';
        metro2File.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File.HEADER__c = 'HEADER';
        metro2File.HeaderCheck__c = false;
        metro2File.MaxRowsCount__c = '1365';
        metro2File.ZAP__c = 'ZA';
        metro2File.Account_Type__c = '34';
        metro2File.Identification_Number__c = '481FZ51142';
        metro2File.Agency_Included__c = '68,6';
        metro2File.Number_of_Days_After_Reporting__c = 45;
        metro2File.Payment_Frequency__c = 'D';
        metro2File.Account_Status_Close__c = '13';
        metro2File.Portfolio_Type__c = 'O';
        metro2File.Terms_Duration__c = '001';
        metro2File.Reporter_Address__c = 'Reporter_AddressReporter';
        metro2File.Reporter_Phone__c = '12345634';
        metro2File.Days_Diff_for_Delinquency__c = 240;
        metro2File.Province__c = 'AB,BC,MB,NS,ON';
        metro2File.Product_Status_Excluded__c = '2000';
        insert metro2File;

        Metro__c metroheaderrecsetiing = Metro__c.getOrgDefaults();
        metroheaderrecsetiing.Name = 'Header';
        metroheaderrecsetiing.HeaderCheck__c = false;
        insert metroheaderrecsetiing;

        Credit_Bureau_Reporting_Periods__mdt creditmetadata = new Credit_Bureau_Reporting_Periods__mdt();
        creditmetadata.Province_Name__c = 'AB';
        creditmetadata.TU_Collection_Period__c = 8;
        creditmetadata.TU_Judgment_Period__c = 8;

        Account acc = new Account();
        acc.name = 'Anea';
        acc.Number_Of_Open_Complaint__c = 5;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seller').getRecordTypeId();
        insert acc;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '68';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

        Placement__c plcgy2 = new Placement__c();
        plcgy2.Name = '32';
        plcgy2.Agency_Email__c = 'testing@gmail.com';
        insert plcgy2;

        Judgment__c judg = new Judgment__c();
        judg.Legal_Status__c = 'Judgment';
        judg.Legal_Sub_Status__c = 'Vacated';
        judg.Legal_Agency__c = '68';
        judg.Legal_Agency_Placement__c = plcgy1.id;
        insert judg;

        Portfolio_Name__c protfolio = new Portfolio_Name__c();
        protfolio.Name = 'MBNA24';
        protfolio.Account_Purchasing_Entity_ID__c = 'test';
        protfolio.CIML_Reporting_Name__c = 'testing portfolio';
        insert protfolio;

        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(
            Name = '1111',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
            Product_Status__c = '207000',
            seller__c = acc.id,
            Collection_Agency__c = 68,
            Portfolio_Name_Lookup__c = protfolio.ID,
            Number_Of_Open_Complaint__c = 0,
            Last_Name__c = 'last name',
            Assignment_Date__c = SYSTEM.Today().addDays(-50),
            First_Name__c = 'first name',
            Current_Balance__c = 120.00,
            Last_Payment_Date__c = SYSTEM.Today(),
            TransUnion_Reported_As_Complete_Count__c = null,
            Original_Balance__c = 123.00,
            Middle_Name__c = 'middle',
            Purchase_Face_Value__c = 10.45,
            SIN__c = '123',
            Charged_Off_Amount__c = 100,
            Phone_Home__c = '12345654',
            Date_of_Birth__c = SYSTEM.Today(),
            Address_Line1__c = 'add',
            Address_Line2__c = 'add',
            Exclude_for_Reporting__c = false,
            City__c = 'NES',
            State__c = 'AB',
            Zip_Code__c = '12345',
            //Purchase_Date__c = SYSTEM.Today(),
            Previous_Primary_Account_Number__c = '123458965',
            Last_Payment_Date_Prior_to_CO__c = SYSTEM.Today(),
            Charged_Off_Date__c = SYSTEM.Today().addDays(+1)
        );
        prodList.add(prod);
        insert prodList;

        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement__c = plcgy1.id;
        placeHist.Placement_Date__c = SYSTEM.Today().addDays(-220);
        placeHist.Placement_Recall_Date__c = SYSTEM.Today().addDays(-20);
        placeHist.Current_Total_Bal_at_time_of_Recall__c = 100;
        insert placeHist;

        Placement_History__c placeHist1 = new Placement_History__c();
        placeHist1.product__c = prod.id;
        placeHist1.Placement__c = plcgy2.id;
        placeHist1.Placement_Date__c = SYSTEM.Today().addDays(-20);
        placeHist1.Placement_Recall_Date__c = null;
        placeHist1.Current_Total_Bal_at_time_of_Recall__c = 120;
        insert placeHist1;

        Account_Judgment__c accJudgment = new Account_Judgment__c();
        accJudgment.Product__c = prod.Id;
        accJudgment.Judgment__c = judg.id;
        accJudgment.Status__c = 'Active';
        insert accJudgment;

        Test.startTest();
        CreditBureauReportingTUBatch obj = new CreditBureauReportingTUBatch();
        Database.executeBatch(obj);
        creditBureauClass.getcreditBureauClass('CIML_TransUnion');
        Test.stopTest();
    }

    @isTest
    public static void testCustomerBatch2() {
        TestDocumentAPIClient.testDocumentAPI();
        Metro2_File__c metro2File = Metro2_File__c.getOrgDefaults();
        metro2File.Name = 'CreditBureauTU';
        metro2File.bureauIdentifier__c = '1230011765';
        metro2File.CA__c = 'CN';
        metro2File.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL CANACCEDE FINANCIALt';
        metro2File.HEADER__c = 'HEADER';
        metro2File.HeaderCheck__c = false;
        metro2File.MaxRowsCount__c = '1365';
        metro2File.ZAP__c = 'ZA';
        metro2File.Account_Type__c = '34';
        metro2File.Identification_Number__c = '481FZ511426789345675';
        metro2File.Agency_Included__c = '68,6';
        metro2File.Number_of_Days_After_Reporting__c = 45;
        metro2File.Payment_Frequency__c = 'D';
        metro2File.Account_Status_Close__c = '13';
        metro2File.Portfolio_Type__c = 'O';
        metro2File.Terms_Duration__c = '001';
        metro2File.Reporter_Address__c = 'Reporter_AddressReporter_AddressReporter_AddressReporter_AddressReporter_AddressReporter_Address';
        metro2File.Reporter_Phone__c = '1234563456';
        metro2File.Days_Diff_for_Delinquency__c = 240;
        metro2File.Province__c = 'AB,BC,MB,NS,ON';
        insert metro2File;

        Data_Status_Mapping__c metaData = Data_Status_Mapping__c.getOrgDefaults();
        metaData.name = '207000';
        metaData.Bureau_Reporting_Account_Status__c = 'Open';
        insert metaData;

        Agency_Portal_Settings__c agencyPortal = Agency_Portal_Settings__c.getOrgDefaults();
        agencyPortal.Valid_Payment_Types__c = '1000,1001,1002';
        insert agencyPortal;

        Metro__c metroheaderrecsetiing = Metro__c.getOrgDefaults();
        metroheaderrecsetiing.Name = 'Header';
        metroheaderrecsetiing.HeaderCheck__c = false;
        insert metroheaderrecsetiing;

        Portfolio_Name__c protfolio = new Portfolio_Name__c();
        protfolio.Name = 'MBNA24';
        protfolio.Account_Purchasing_Entity_ID__c = 'test';
        protfolio.CIML_Reporting_Name__c = 'testing portfolioportfoliotest';
        insert protfolio;

        Credit_Bureau_Reporting_Periods__mdt creditmetadata = new Credit_Bureau_Reporting_Periods__mdt();
        creditmetadata.Province_Name__c = 'AB';
        creditmetadata.TU_Collection_Period__c = 8;
        creditmetadata.TU_Judgment_Period__c = 8;

        Account acc = new Account();
        acc.name = 'Anea';
        acc.Number_Of_Open_Complaint__c = 5;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seller').getRecordTypeId();
        insert acc;

        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(
            Name = '111111111111111111111111111111',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
            Product_Status__c = '207000',
            seller__c = acc.id,
            Collection_Agency__c = 68,
            Portfolio_Name_Lookup__c = protfolio.ID,
            Number_Of_Open_Complaint__c = 0,
            Last_Name__c = 'last namelast namelast name',
            Assignment_Date__c = SYSTEM.Today().addDays(-50),
            First_Name__c = 'first name first name',
            Current_Balance__c = 120.00,
            Last_Payment_Date__c = SYSTEM.Today(),
            TransUnion_Reported_As_Complete_Count__c = null,
            Original_Balance__c = 123.00,
            Purchase_Face_Value__c = -10.45,
            Middle_Name__c = 'middle namemiddle name',
            SIN__c = '123456789',
            Phone_Home__c = '12345654',
            Date_of_Birth__c = SYSTEM.Today(),
            Address_Line1__c = 'Address_Line1Address_Line1Addres',
            Address_Line2__c = 'Address_Line2Address_Line2Addres',
            City__c = 'citycitycitycitycity',
            State__c = 'AB',
            Zip_Code__c = '123456789',
            //Purchase_Date__c = SYSTEM.Today(),
            Previous_Primary_Account_Number__c = '123458965123458965123458965789',
            Last_Payment_Date_Prior_to_CO__c = SYSTEM.Today(),
            Charged_Off_Date__c = SYSTEM.Today().addDays(+1),
            Closed_Date__C = SYSTEM.Today()
        );
        prodList.add(prod);
        insert prodList;

        Product_Payments__c prodPayments = new Product_Payments__c(
            Payment_Created_Date__c = System.today().addDays(-23),
            RecordTypeId = Schema.SObjectType.Product_Payments__c.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId(),
            CCS_Account__c = prodList[0].Id,
            Payment_Source__c = '1',
            Payment_Type__c = '1000',
            Payment_Amount__c = 100,
            Payment_Agency__c = '68',
            Is_Payment_Reversed__c = false
        );
        insert prodPayments;

        Test.startTest();
        CreditBureauReportingTUBatch obj = new CreditBureauReportingTUBatch();
        Database.executeBatch(obj);
        creditBureauClass.getcreditBureauClass('CIML_TransUnion');
        Test.stopTest();
    }

    @isTest
    public static void testCustomerBatch3() {
        TestDocumentAPIClient.testDocumentAPI();
        Metro2_File__c metro2File = Metro2_File__c.getOrgDefaults();
        metro2File.Name = 'CreditBureauTU';
        metro2File.bureauIdentifier__c = '1230011765';
        metro2File.CA__c = 'CN';
        metro2File.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL CANACCEDE FINANCIALt';
        metro2File.HEADER__c = 'HEADER';
        metro2File.HeaderCheck__c = false;
        metro2File.MaxRowsCount__c = '1365';
        metro2File.ZAP__c = 'ZA';
        metro2File.Account_Type__c = '34';
        metro2File.Identification_Number__c = '481FZ511426789345675';
        metro2File.Agency_Included__c = '68,6';
        metro2File.Number_of_Days_After_Reporting__c = 45;
        metro2File.Payment_Frequency__c = 'D';
        metro2File.Account_Status_Close__c = '13';
        metro2File.Portfolio_Type__c = 'O';
        metro2File.Terms_Duration__c = '001';
        metro2File.Reporter_Address__c = 'Reporter_AddressReporter_AddressReporter_AddressReporter_AddressReporter_AddressReporter_Address';
        metro2File.Reporter_Phone__c = '1234563456';
        metro2File.Days_Diff_for_Delinquency__c = 240;
        metro2File.Province__c = 'AB,BC,MB,NS,ON';
        metro2File.Name_Excluded_List__c = 'LTD';
        insert metro2File;

        Data_Status_Mapping__c metaData = Data_Status_Mapping__c.getOrgDefaults();
        metaData.name = '207000';
        metaData.Bureau_Reporting_Account_Status__c = 'Open';
        insert metaData;

        Agency_Portal_Settings__c agencyPortal = Agency_Portal_Settings__c.getOrgDefaults();
        agencyPortal.Valid_Payment_Types__c = '1000,1001,1002';
        insert agencyPortal;

        Metro__c metroheaderrecsetiing = Metro__c.getOrgDefaults();
        metroheaderrecsetiing.Name = 'Header';
        metroheaderrecsetiing.HeaderCheck__c = false;
        insert metroheaderrecsetiing;

        Portfolio_Name__c protfolio = new Portfolio_Name__c();
        protfolio.Name = 'MBNA24';
        protfolio.Account_Purchasing_Entity_ID__c = 'test';
        protfolio.CIML_Reporting_Name__c = 'testing portfolioportfoliotesttest';
        insert protfolio;

        Credit_Bureau_Reporting_Periods__mdt creditmetadata = new Credit_Bureau_Reporting_Periods__mdt();
        creditmetadata.Province_Name__c = 'AB';
        creditmetadata.TU_Collection_Period__c = 8;
        creditmetadata.TU_Judgment_Period__c = 8;

        Account acc = new Account();
        acc.name = 'Anea';
        acc.Number_Of_Open_Complaint__c = 5;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seller').getRecordTypeId();
        insert acc;

        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(
            Name = '1111111111111111111111111111111',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
            Product_Status__c = '207000',
            seller__c = acc.id,
            Collection_Agency__c = 68,
            Portfolio_Name_Lookup__c = protfolio.ID,
            Number_Of_Open_Complaint__c = 0,
            Last_Name__c = 'last namelast namelast LTD INC',
            Assignment_Date__c = SYSTEM.Today().addDays(-50),
            First_Name__c = 'first name first LTD INC',
            Current_Balance__c = 120.00,
            Last_Payment_Date__c = SYSTEM.Today(),
            TransUnion_Reported_As_Complete_Count__c = null,
            Original_Balance__c = 123.00,
            Purchase_Face_Value__c = -10.45,
            Middle_Name__c = 'middle namemiddle name',
            SIN__c = '123456789',
            Phone_Home__c = '(902) 463-1341',
            Date_of_Birth__c = SYSTEM.Today(),
            Address_Line1__c = 'Address_Line1Address_Line1Addrestest',
            Address_Line2__c = 'Address_Line2Address_Line2Addrestest',
            City__c = 'citycitycitycitycitytest',
            State__c = 'AB',
            Zip_Code__c = '1234567898',
            //Purchase_Date__c = SYSTEM.Today(),
            Deceased_Date__c = SYSTEM.Today(),
            Previous_Primary_Account_Number__c = '123458965123458965123458965789',
            Last_Payment_Date_Prior_to_CO__c = SYSTEM.Today(),
            Charged_Off_Date__c = SYSTEM.Today().addDays(+1),
            Closed_Date__C = SYSTEM.Today()
        );
        prodList.add(prod);
        insert prodList;

        Product_Payments__c prodPayments = new Product_Payments__c(
            Payment_Created_Date__c = System.today(),
            RecordTypeId = Schema.SObjectType.Product_Payments__c.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId(),
            CCS_Account__c = prodList[0].Id,
            Payment_Source__c = '1',
            Payment_Type__c = '1000',
            Payment_Amount__c = 100,
            Payment_Agency__c = '68',
            Is_Payment_Reversed__c = false
        );
        insert prodPayments;

        Test.startTest();
        CreditBureauReportingTUBatch obj = new CreditBureauReportingTUBatch();
        Database.executeBatch(obj);
        creditBureauClass.getcreditBureauClass('CIML_TransUnion');
        Test.stopTest();
    }

    @isTest
    static void testGetWorkAssignment() {
        Test.startTest();
        String workAssignmentId = creditBureauClass.getWorkAssignment();
        Test.stopTest();
        System.assertNotEquals(null, workAssignmentId);
    }
}
