/**************************************************************************************************
*
*  Class:   
*
*  @description : TestDistressedProductProcessingBatch
*  @author : A5E Consulting
*  @date : 04/07/2022  

*************************************************************************************************/
@isTest(seeAllData=false)
public class TestDistressedProductProcessingBatch {
    private static Agency_Portal_Settings__c AgencyPort;

    static testMethod void insertTestData() {
        AgencyPort = new Agency_Portal_Settings__c();
        AgencyPort.Number_of_Days__c = 365;
        insert AgencyPort;

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;

        Product__c prod = new Product__c();
        string recrdid = [
            SELECT id
            FROM RecordType
            WHERE sobjecttype = 'product__c' AND RecordType.Name = 'Distressed Account'
        ]
        .id;
        prod.customer__c = customer.Id;
        prod.RecordTypeId = recrdid;
        prod.Override_Payment_Amount__c = 100;
        prod.Override_Payment_Date__c = System.today() + 1;
        prod.Closed_Date__c = null;
        prod.Hold_Payments__c = false;
        prod.Funding_Status__c = 'Funded';
        prod.Source_System__c = 'Megasys';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.External_Status_Current__c = 'Active';
        prod.Payment_Released_Date__c = System.Today() + 2;
        prod.First_Payment_Date__c = System.today() + 2;
        prod.Payment_Amount__c = 200;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Current_Principal_Balance__c = 100;
        prod.Interest_Rate__c = 10;
        prod.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 12, 19);
        prod.Insolvency_Date__c = null;
        prod.Deceased_Date__c = null;
        prod.Interest_Waived_Off__c = false;
        prod.State__c = 'Test';
        insert prod;
        
        List<Product__c> listProducts = new List<Product__c>();
        listProducts.add(prod);

        Province_Interest_Rate__c proInterest = new Province_Interest_Rate__c();
        proInterest.Province_Name__c = 'Test';
        proInterest.Province_Acronym__c = 'Test String data';
        proInterest.Interest_Rate__c = 22;
        proInterest.Start_Date__c = Date.today().addDays(-2);
        proInterest.End_Date__c = Date.today().addDays(2);
        insert proInterest;

        Judgment__c judgmentInstance = new Judgment__c();
        judgmentInstance.Product_1__c = prod.name;
        judgmentInstance.Interest_Rate_one__c = 25;
        judgmentInstance.Balance_one__c = 5000;
        judgmentInstance.Judgment_Date__c = Date.today().addDays(-5);
        judgmentInstance.Legal_Status__c = 'Judgment';
        judgmentInstance.Legal_Sub_Status__c = 'Claim Issued';
        judgmentInstance.Legal_Agency__c = '6';
        insert judgmentInstance;

        Account_Judgment__c acc = new Account_Judgment__c();
        acc.Product__c = prod.Id;
        acc.Judgment__c = judgmentInstance.ID;
        insert acc;

        //Database.executeBatch(new DistressedProductProcessingBatch(), 1);
        DistressedProductProcessingBatch cb = new DistressedProductProcessingBatch();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null, listProducts);
        cb.Finish(null);
    }
    static testMethod void insertTestData1() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;

        Product__c prod = new Product__c();
        string recrdid = [ SELECT id FROM RecordType WHERE sobjecttype = 'product__c' AND RecordType.Name = 'Distressed Account'].id;
        prod.customer__c = customer.Id;
        prod.RecordTypeId = recrdid;
        prod.Product_Status__c = 'Test';
        prod.Current_Principal_Balance__c = 100;
        prod.Interest_Rate__c = 10;
        prod.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 12, 19);
        prod.Interest_Waived_Off_Start_Date__c = Date.newInstance(2023, 12, 15);
        prod.Interest_Waived_Of_End_Date__c = Date.newInstance(2023, 12, 25);
        prod.Insolvency_Date__c = null;
        prod.Deceased_Date__c = null;
        prod.Interest_Waived_Off__c = true;
        prod.State__c = 'Test String data';
        prod.Current_Interest_Amount__c = 10;
        insert prod;
        
        Product__c prod1 = new Product__c();
        string recrdid1 = [ SELECT id FROM RecordType WHERE sobjecttype = 'product__c' AND RecordType.Name = 'Distressed Account'].id;
        prod1.customer__c = customer.Id;
        prod1.RecordTypeId = recrdid1;
        prod1.Product_Status__c = 'Test';
        prod1.Current_Principal_Balance__c = 100;
        prod1.Interest_Rate__c = 10;
        prod1.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 12, 26);
        prod1.Interest_Waived_Off_Start_Date__c = Date.newInstance(2023, 12, 25);
        prod1.Interest_Waived_Of_End_Date__c = Date.newInstance(2023, 12, 26);
        prod1.Insolvency_Date__c = null;
        prod1.Deceased_Date__c = null;
        prod1.Interest_Waived_Off__c = true;
        prod1.State__c = 'Test String data';
        prod1.Current_Interest_Amount__c = 10;
        insert prod1;
        List<Product__c> listProducts = new List<Product__c>();
        listProducts.add(prod);
        listProducts.add(prod1);
        
        Province_Interest_Rate__c proInterest = new Province_Interest_Rate__c();
        proInterest.Province_Name__c = 'Test';
        proInterest.Province_Acronym__c = 'Test String data';
        proInterest.Interest_Rate__c = 22;
        proInterest.Start_Date__c = Date.today().addDays(-2);
        proInterest.End_Date__c = Date.today().addDays(2);
        insert proInterest;
        
        DistressedProductProcessingBatch cb = new DistressedProductProcessingBatch();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null, listProducts);
        cb.Finish(null);
    }
}