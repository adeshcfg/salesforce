@isTest
public class TestCTBPaymentGeneratorScheduler {
    
    @isTest
    static void CTBInsolvencyAccountTestMethod(){
        Application_Config_Settings__c cs = new Application_Config_Settings__c(Insolvency_Account_Batch_Count__c = 1,Profile_Eligible_for_Duplicate_Check__c = 'Scotia',
                                                                              Bank_Eligible_for_Duplicate_Check__c = 'Scotia',Eligible_for_Validn_Needed_Calculation__c = 'Scotia',
                                                                              Eligible_for_Claim_Type_Calculation__c = 'SPL');
        insert cs;
        
        CTB_File_Automation__mdt province2 = new CTB_File_Automation__mdt();
        province2.Label = 'Insolvency Daily Update';
        province2.Header_Record_Type__c = 'H';
        province2.Member_Type__c = 'O';
        province2.Member_ID__c = '999';
        province2.File_Type__c = 'T';
        province2.File_Format_Identifier__c = 'DRN00001';
        province2.Detail_Record_Type__c = 'D';
        province2.Product_Description__c = 'Canadian Tire Credit Card';
        province2.DRN_Trustee_ID__c = '1';
        province2.Trailer_Record_Type__c = 'T';
        
        Account parentAcc  = new Account(name = 'Parent Account');
        insert parentAcc;
        Account childAcc  = new Account(name = 'Child aAccount', ParentId = parentAcc.Id);
        childAcc.BillingStreet = 'test billing street';
        childAcc.BillingCity = 'test billing city';
        childAcc.BillingState = 'test billing state';
        childAcc.BillingPostalCode = '111111';
        insert childAcc;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insolv1.Insolvency_Received_Date__c = System.today();
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insolv1.Debtor_1_Mailing_Street__c = 'test mailing street';
        insolv1.Debtor_1_Mailing_City__c = 'test mailing city';
        insolv1.Debtor_1_Mailing_State_Province__c = 'Alberta';
        insolv1.Insolvency_Date__c = System.today();
        insolv1.Trustee__c = childAcc.Id;
        insolv1.Debtor_1_Middle_Name__c = 'test middle name';
        insolv1.Debtor_1_Mailing_Postal_Code__c = 'T2G 5T7';
        insolv1.Debtor_1_SIN__c = 'test';
        insolv1.Debtor_1_First_Name__c = 'Test';
        insolv1.Debtor_1_Middle_Name__c = 'Test';
        insolv1.Debtor_1_Mailing_State_Province__c = 'Ontario';
        insolv1.Insolvency_Received_Date__c = Date.newInstance(2022, 12, 5);
        insert insolv1;
        
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'TestTestInslAcc222';
        insolAcct1.Insolvency_Status__c = 'For Owner Review';
        insolAcct1.Insolvency_Sub_Status__c = 'Pending File';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insolAcct1.Product_Code__c = 'MC';
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.RecordTypeId = Schema.getGlobalDescribe().get('Insolvency_Account__c').getDescribe().getRecordTypeInfosByName().get('Canadian Tire Insolvency Account').getRecordTypeId();
        insolAcct1.Debtor_1_Last_Name__c = 'test last name';
        insolAcct1.Debtor_1_First_Name__c  = 'test first name';
        insolAcct1.CTB_Date_of_Birth__c = System.today();
        insolAcct1.Percent_of_increased_return_from_voting__c = 10;
        insolAcct1.Debtor_1_First_Name__c = 'Test';
        insolAcct1.Debtor_1_Last_Name__c = 'Test';
        
        insert insolAcct1;
        
        
        test.startTest();
            CTBInsolvencyAccountGeneratorScheduler ctb=new CTBInsolvencyAccountGeneratorScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test CTB Check', sch, ctb); 
        Test.stopTest(); 
    }
    
    @isTest
    static void CTBInsolvencyAccountTestMethod1(){
        Application_Config_Settings__c cs = new Application_Config_Settings__c(Insolvency_Account_Batch_Count__c = 1,Profile_Eligible_for_Duplicate_Check__c = 'Scotia',
                                                                              Bank_Eligible_for_Duplicate_Check__c = 'Scotia',Eligible_for_Validn_Needed_Calculation__c = 'Scotia',
                                                                              Eligible_for_Claim_Type_Calculation__c = 'SPL');
        insert cs;
        
        Account parentAcc  = new Account(name = 'Parent Account');
        insert parentAcc;
        Account childAcc  = new Account(name = 'Child aAccount', ParentId = parentAcc.Id);
        childAcc.BillingStreet = 'testbillingstreettestbillingstreettestbillingstreettestbillingstreettestbillingstreet';
        childAcc.BillingCity = 'testbillingcitytestbillingcitytestbillgg';
        childAcc.BillingState = 'ON';
        childAcc.BillingPostalCode = 'testbillingBilling';
        insert childAcc;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insolv1.Insolvency_Received_Date__c = System.today();
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insolv1.Debtor_1_Mailing_Street__c = 'testmailingstreettestmailingstreettestmailingstreettestmailingstreettestmailingstreet';
        insolv1.Debtor_1_Mailing_City__c = 'testmailingcitytestmailingcitytestmailingcity';
        insolv1.Debtor_1_Mailing_State_Province__c = 'Alberta';
        insolv1.Insolvency_Date__c = System.today();
        insolv1.Trustee__c = childAcc.Id;
        insolv1.Debtor_1_Middle_Name__c = 'test middle name';
        insolv1.Debtor_1_Mailing_Postal_Code__c = 'T2G5T7T2G5T75689';
        insolv1.Debtor_1_SIN__c = 'testSINtt';
        insolv1.Debtor_1_Date_of_Birth__c = System.today();
        insolv1.Created_By_Doc_Parser__c = true;
        insert insolv1;
        
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222TestInslAcc';
        insolAcct1.Insolvency_Status__c = 'For Owner Review';
        insolAcct1.Insolvency_Sub_Status__c = 'Pending File';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insolAcct1.Product_Code__c = 'MC';
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.RecordTypeId = Schema.getGlobalDescribe().get('Insolvency_Account__c').getDescribe().getRecordTypeInfosByName().get('Canadian Tire Insolvency Account').getRecordTypeId();
        insolAcct1.Debtor_1_Last_Name__c = 'testlastnametestlastnametestlastnametestt';
        insolAcct1.Debtor_1_First_Name__c  = 'testfirstnametestfirstnametestfirstnametestfirstname';
        insolAcct1.CTB_Date_of_Birth__c = NULL;
        insolAcct1.Percent_of_increased_return_from_voting__c = 20;
        insert insolAcct1;
        
        
        test.startTest();
            CTBInsolvencyAccountGeneratorScheduler ctb=new CTBInsolvencyAccountGeneratorScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test CTB Check', sch, ctb); 
        Test.stopTest(); 
    }
    
    @isTest
    static void CTBInsolvencyTestNegativeMethod(){
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Staging';
        insolv1.Insolvency_Received_Date__c = System.today();
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insert insolv1;
        
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'TestInslAcc222';
        insolAcct1.Insolvency_Status__c = 'For Owner Review';
        insolAcct1.Insolvency_Sub_Status__c = 'Pending File';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insolAcct1.Product_Code__c = 'MC';
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.RecordTypeId = Schema.getGlobalDescribe().get('Insolvency_Account__c').getDescribe().getRecordTypeInfosByName().get('Canadian Tire Insolvency Account').getRecordTypeId();
        insolAcct1.Percent_of_increased_return_from_voting__c = 130;
        insert insolAcct1;
        
        
        test.startTest();
            CTBInsolvencyAccountGeneratorScheduler ctb=new CTBInsolvencyAccountGeneratorScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test CTB Check', sch, ctb); 
        Test.stopTest(); 
    }
    
    @isTest
    static void testMethod2(){
        Application_Config_Settings__c cs = new Application_Config_Settings__c(Insolvency_Account_Batch_Count__c = 1,Profile_Eligible_for_Duplicate_Check__c = 'Scotia',
                                                                              Bank_Eligible_for_Duplicate_Check__c = 'Scotia',Eligible_for_Validn_Needed_Calculation__c = 'Scotia',
                                                                              Eligible_for_Claim_Type_Calculation__c = 'SPL',Ignore_Account_Number_for_DuplicateCheck__c = 'TRAILER');
        insert cs;
        
        Trustee_Fees__c trusteeFees = Trustee_Fees__c.getOrgDefaults();
        trusteeFees.Trustee_Administration_Fee__c = 10;
        trusteeFees.Counselling_Fee__c = 10;
        trusteeFees.Receiver_Fee__c = 10;
        trusteeFees.Trustee_Variable_Fee_Rate__c = 10;
        insert trusteeFees;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insolv1.Total_Unsecured_Liabilities_Clc__c = 10;
        insolv1.Insolvency_Type__c = 'Consumer Proposal';
        insolv1.Payment_Amount__c = 10;
        insolv1.Number_of_Payments__c = 5;
        insolv1.Previous_Trustee_Variable_Fees__c = 70;
        insert insolv1;
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'TestInslAcc';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Product_Code__c = 'MC';
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Percent_of_increased_return_from_voting__c = 110;
        insolAcct1.Claim_Amount__c = 50;
        insolAcct1.Client_Identifier__c = 'Canadian Tire';    
        insert insolAcct1;
        
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Payment_Amount__c = 1023456789;
        payment1.Insolvency_Account__c =insolAcct1.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        insert payment1;
        
        test.startTest();
        CTBPaymentGeneratorScheduler ctb=new CTBPaymentGeneratorScheduler();       
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test CTB Check', sch, ctb); 
        Test.stopTest(); 
    }
}