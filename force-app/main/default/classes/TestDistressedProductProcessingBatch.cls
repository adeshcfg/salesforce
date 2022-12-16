/**************************************************************************************************
*
*  Class:   
*
*  @description : TestDistressedProductProcessingBatch
*  @author : A5E Consulting
*  @date : 04/07/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestDistressedProductProcessingBatch {
    
    private static Agency_Portal_Settings__c AgencyPort;
    
    static testMethod void insertTestData(){
        AgencyPort = new Agency_Portal_Settings__c();
        AgencyPort.Number_of_Days__c = 365;
        insert AgencyPort;
        
        Product__c prod =  new Product__c ();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Override_Payment_Amount__c = 100;
        prod.Override_Payment_Date__c = System.today()+1;
        prod.Closed_Date__c = null;
        prod.Hold_Payments__c = false;
        prod.Funding_Status__c = 'Funded';
        prod.Source_System__c = 'Megasys';
        prod.Payment_Setup_Status__c = 'Automated' ;
        prod.External_Status_Current__c = 'Active';
        prod.Payment_Released_Date__c = System.Today()+2;
        prod.First_Payment_Date__c = System.today() + 2;
        prod.Payment_Amount__c  = 200;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Current_Principal_Balance__c = 100;
        prod.Interest_Rate__c = 10;
        prod.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 12, 19);
        prod.Insolvency_Date__c = Null;
        prod.Deceased_Date__c = Null;
        prod.Interest_Waived_Off__c = false;
        Insert prod;
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
        DistressedProductProcessingBatch cb = New DistressedProductProcessingBatch();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,listProducts);
        cb.Finish(null);
    }
   /* private static Product__c createProduct(){
         Product__c prod =  new Product__c ();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Override_Payment_Amount__c = 100;
        prod.Override_Payment_Date__c = System.today()+1;
        prod.Closed_Date__c = null;
        prod.Hold_Payments__c = false;
        prod.Funding_Status__c = 'Funded';
        prod.Source_System__c = 'Megasys';
        prod.Payment_Setup_Status__c = 'Automated' ;
        prod.External_Status_Current__c = 'Active';
        prod.Payment_Released_Date__c = System.Today()+2;
        prod.First_Payment_Date__c = System.today() + 2;
        prod.Payment_Amount__c  = 200;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Current_Principal_Balance__c = 100;
        prod.Interest_Rate__c = 10;
        prod.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 12, 19);
        prod.Insolvency_Date__c = Null;
        prod.Deceased_Date__c = Null;
        Insert prod;
        return prod;
        
    }*/
}