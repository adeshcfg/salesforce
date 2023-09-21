@isTest(seeALlData=false)
public class TestCreditBureauClass {
    @isTest public static void testCustomerBatch(){
        Metro2_File__c metro2File = Metro2_File__c.getOrgDefaults();
        metro2File.Name = 'CreditBureauTU';
        metro2File.bureauIdentifier__c = '1230011';
        metro2File.CA__c = 'CN';
        metro2File.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File.HEADER__c = 'HEADER';
        metro2File.HeaderCheck__c = FALSE;
        metro2File.MaxRowsCount__c = '1365';
        metro2File.ZAP__c = 'ZA';
        metro2File.Account_Type__c = '34';
        metro2File.Identification_Number__c = '481FZ51142';
        metro2File.Agency_Included__c = '68,6';
        metro2File.Number_of_Days_After_Reporting__c = 45;
        insert metro2File;
        
        Metro2_File__c metro2File1 = Metro2_File__c.getOrgDefaults();
        metro2File1.Name = 'Equifax';
        metro2File1.bureauIdentifier__c = '1230011';
        metro2File1.CA__c = 'CN';
        metro2File1.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File1.HEADER__c = 'HEADER';
        metro2File1.HeaderCheck__c = FALSE;
        metro2File1.MaxRowsCount__c = '1365';
        metro2File1.ZAP__c = 'ZA';
        metro2File1.Account_Type__c = '34';
        metro2File1.Identification_Number__c = '481FZ51142';
        metro2File1.Agency_Included__c = '68,6';
        metro2File1.Number_of_Days_After_Reporting__c = 45;
        metro2File1.Number_of_Times_To_Report__c = 1;
        //insert metro2File1;
        
        Metro__c metroheaderrecsetiing  = Metro__c.getOrgDefaults();
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
        acc.RecordTypeId = Schema.SObjectType.Account .getRecordTypeInfosByName().get('Seller').getRecordTypeId();
        insert acc;
        
        Judgment__c judg = new Judgment__c();
        judg.Legal_Status__c = 'Judgment';
        judg.Legal_Sub_Status__c = 'Vacated';
        insert judg;
        
        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(
                                        Name='1111',
                                        RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
										Product_Status__c = '207000',
            							seller__c = acc.id,
										Collection_Agency__c= 68,
										Number_Of_Open_Complaint__c = 0,
										Last_Name__c = 'last name',
										Assignment_Date__c = SYSTEM.Today().addDays(-50),
                                        First_Name__c = 'first name',
                                        Open_Date__c = SYSTEM.Today(),
										Payment_Frequency__c = 'Weekly',
										Monthly_Payment_Amount__c = 1252.00,
										Current_Balance__c = 120.00,
                                        Last_Payment_Date__c = SYSTEM.Today(),
                                        Original_Date_of_Delinquency__c =  SYSTEM.Today(),
                                        TransUnion_Reported_As_Complete_Count__c = null,                         
                                        Disbursement_Date__c = SYSTEM.Today(),
                                        Open_Date_EQ__c = SYSTEM.Today(), 
                                        Original_Balance__c = 123.00,
                                        Original_Credit_Amount__c = 123.00,
                                        FairShare_Percentage__c = 12,
                                        Past_Due_Amount__c = 12.00,
                                        Last_Delinquency_Date__c = SYSTEM.Today(),
                                        CCS_Stage_Last_Changed__c = SYSTEM.Today(),
                                        Middle_Name__c = 'middle',
                                        SIN__c = '123',
                                        Phone_Home__c = '12345654',
                                        Date_of_Birth__c = SYSTEM.Today(),
                                        Address_Line1__c = 'add',
                                        Address_Line2__c = 'add',
                                        City__c = 'NES',
                                        State__c = 'AB', 
                                        Zip_Code__c = '12345',
                                        Provinces__c = 'Nova Scotia',
                                        CCS_Stage__c = 'Completed',
                                        Investment_Group__c = 'BNS CCS 1',
                                        Purchase_Date__c = SYSTEM.Today(),
            							Charged_Off_Date__c = SYSTEM.Today().addDays(-1)
                                        );
        prodList.add(prod);

        /*Product__c prod2 = new Product__c(
                                        Name='123451234512345123451234512345',
                                        RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
                                        Last_Name__c = 'last name of length2',
                                        First_Name__c = 'first name of length 25 c',
                                        Disbursement_Date__c = SYSTEM.Today(),
                                        Open_Date_EQ__c = SYSTEM.Today(), 
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
                                        State__c = 'A',
                                        Provinces__c = 'Nova Scotia',
                                        Zip_Code__c = '123456789',
                                        Investment_Group__c = 'BNS CCS 1',
                                        Purchase_Date__c = SYSTEM.Today()
                                        );
        prodList.add(prod2);*/
        insert prodList;
        
		Account_Judgment__c accJudgment = new Account_Judgment__c();        //accJudgment.Judgment__c = judgmetInstance.Id;
        accJudgment.Product__c = prod.Id;
        accJudgment.Judgment__c = judg.id;
        accJudgment.Status__c = 'Active';
        insert accJudgment;
        
        Product_Payments__c prodPayments = new Product_Payments__c(
                                                Payment_Created_Date__c = System.today(),
                                                RecordTypeId = Schema.SObjectType.Product_Payments__c.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId(),
                                                CCS_Account__c = prodList[0].Id,
            									Payment_Source__c = '1'
                                            );
        insert prodPayments;
        
        Test.startTest();
        CreditBureauReportingTUBatch obj = new CreditBureauReportingTUBatch();
        Database.executeBatch(obj);
        creditBureauClass.getcreditBureauClass('CreditBureau');
        Test.stopTest();
    }
    
    @isTest public static void testCustomerBatch1(){  
        List <Metro2_File__c> metro2Data = new List <Metro2_File__c>();
        Metro2_File__c metro2File1 = Metro2_File__c.getOrgDefaults();
        metro2File1.Name = 'Equifax';
        metro2File1.bureauIdentifier__c = '1230011';
        metro2File1.CA__c = 'CN';
        metro2File1.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File1.HEADER__c = 'HEADER';
        metro2File1.HeaderCheck__c = FALSE;
        metro2File1.MaxRowsCount__c = '1365';
        metro2File1.ZAP__c = 'ZA';
        metro2File1.Account_Type__c = '34';
        metro2File1.Identification_Number__c = '481FZ51142';
        metro2File1.Agency_Included__c = '68,6';
        metro2File1.Number_of_Days_After_Reporting__c = 45;
        metro2File1.Number_of_Times_To_Report__c = 1;
        metro2File1.Product_Status_Excluded__c = '207000,206000';
        metro2Data.add(metro2File1);
        
        Metro2_File__c metro2File2 = Metro2_File__c.getOrgDefaults();
        metro2File2.Name = 'CreditBureauTU';
        metro2File2.Product_Status_Excluded__c = '207000,206000';
        metro2File2.Agency_Included__c = '68,6';
        metro2File2.Number_of_Days_After_Reporting__c = 45;
        metro2Data.add(metro2File2);
        insert metro2Data;
        
        Metro__c metroheaderrecsetiing  = Metro__c.getOrgDefaults();
        metroheaderrecsetiing.Name = 'Header';
        metroheaderrecsetiing.HeaderCheck__c = false;
        insert metroheaderrecsetiing;
        
        Test.startTest();
        creditBureauClass.getcreditBureauClass('Equifax');
        Test.stopTest();
    }
    
    @isTest public static void testCustomerBatch2(){
        Metro2_File__c metro2File = Metro2_File__c.getOrgDefaults();
        metro2File.Name = 'CreditBureauTU';
        metro2File.bureauIdentifier__c = '1230011';
        metro2File.CA__c = 'CN';
        metro2File.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File.HEADER__c = 'HEADER';
        metro2File.HeaderCheck__c = FALSE;
        metro2File.MaxRowsCount__c = '1365';
        metro2File.ZAP__c = 'ZA';
        metro2File.Account_Type__c = '34';
        metro2File.Identification_Number__c = '481FZ51142';
        metro2File.Agency_Included__c = '68,6';
        metro2File.Number_of_Days_After_Reporting__c = 45;
        insert metro2File;
        
        Metro2_File__c metro2File1 = Metro2_File__c.getOrgDefaults();
        metro2File1.Name = 'Equifax';
        metro2File1.bureauIdentifier__c = '1230011';
        metro2File1.CA__c = 'CN';
        metro2File1.Canaccede_Financial_Group__c = 'CANACCEDE FINANCIAL';
        metro2File1.HEADER__c = 'HEADER';
        metro2File1.HeaderCheck__c = FALSE;
        metro2File1.MaxRowsCount__c = '1365';
        metro2File1.ZAP__c = 'ZA';
        metro2File1.Account_Type__c = '34';
        metro2File1.Identification_Number__c = '481FZ51142';
        metro2File1.Agency_Included__c = '68,6';
        metro2File1.Number_of_Days_After_Reporting__c = 45;
        metro2File1.Number_of_Times_To_Report__c = 1;
        //insert metro2File1;
        
        Metro__c metroheaderrecsetiing  = Metro__c.getOrgDefaults();
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
        acc.RecordTypeId = Schema.SObjectType.Account .getRecordTypeInfosByName().get('Seller').getRecordTypeId();
        insert acc;
        
        /*Judgment__c judg = new Judgment__c();
        judg.Legal_Status__c = 'Judgment';
        judg.Legal_Sub_Status__c = 'Vacated';
        insert judg;*/
        
        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(
                                        Name='1111',
                                        RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
										Product_Status__c = '207000',
            							seller__c = acc.id,
										Collection_Agency__c= 68,
										Number_Of_Open_Complaint__c = 0,
										Last_Name__c = 'last name testing purpose incre',
										Assignment_Date__c = SYSTEM.Today().addDays(-50),
                                        First_Name__c = 'first name testing purpose',
                                        Open_Date__c = SYSTEM.Today(),
										Payment_Frequency__c = 'Weekly',
										Monthly_Payment_Amount__c = 1252.00,
										Current_Balance__c = 120.00,
                                        Last_Payment_Date__c = SYSTEM.Today(),
                                        Original_Date_of_Delinquency__c =  SYSTEM.Today(),
                                        TransUnion_Reported_As_Complete_Count__c = null,                         
                                        Disbursement_Date__c = SYSTEM.Today(),
                                        Open_Date_EQ__c = SYSTEM.Today(), 
                                        Original_Balance__c = 123.00,
                                        Original_Credit_Amount__c = 123.00,
                                        FairShare_Percentage__c = 12,
                                        Past_Due_Amount__c = 12.00,
                                        Last_Delinquency_Date__c = SYSTEM.Today(),
                                        CCS_Stage_Last_Changed__c = SYSTEM.Today(),
                                        Middle_Name__c = 'middle testing purpose',
                                        SIN__c = '123456789',
                                        Phone_Home__c = '1234565487',
                                        Date_of_Birth__c = SYSTEM.Today(),
                                        Address_Line1__c = 'addteryuioplkjhferwsdfgyuiopljhl',
                                        Address_Line2__c = 'addteryuioplkjhferwsdfgyuiopljop',
                                        City__c = 'NESJKLOIUYHGDFSERTYU',
                                        State__c = 'AB', 
                                        Zip_Code__c = '12345',
                                        Provinces__c = 'Nova Scotia',
                                        CCS_Stage__c = 'Completed',
                                        Investment_Group__c = 'BNS CCS 1',
                                        Purchase_Date__c = SYSTEM.Today(),
            							Charged_Off_Date__c = SYSTEM.Today().addDays(-1)
                                        );
        prodList.add(prod);
        insert prodList;
        
		Account_Judgment__c accJudgment = new Account_Judgment__c();        //accJudgment.Judgment__c = judgmetInstance.Id;
        accJudgment.Product__c = prod.Id;
        accJudgment.Status__c = 'Active';
        insert accJudgment;
        
        Product_Payments__c prodPayments = new Product_Payments__c(
                                                Payment_Created_Date__c = System.today(),
                                                RecordTypeId = Schema.SObjectType.Product_Payments__c.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId(),
                                                CCS_Account__c = prodList[0].Id,
            									Payment_Source__c = '1'
                                            );
        insert prodPayments;
        
        Test.startTest();
        CreditBureauReportingTUBatch obj = new CreditBureauReportingTUBatch();
        Database.executeBatch(obj);
        creditBureauClass.getcreditBureauClass('CreditBureau');
        Test.stopTest();
    }
}