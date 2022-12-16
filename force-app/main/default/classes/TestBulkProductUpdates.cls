/**************************************************************************************************
*
*  Class:   
*
*  @description : TestBulkProductUpdates
*  @author : A5E Consulting
*  @date : 19/07/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestBulkProductUpdates {
    
     static testMethod void insertTestData(){
         List<Product__c> Listprod = new List<Product__c>();
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
        Listprod.add(prod);
        Insert Listprod;
        
        Test.StartTest();
		BulkProductUpdates instancevar = new BulkProductUpdates(Listprod);
		ID batchprocessid = Database.executeBatch(instancevar);
		Test.StopTest();
         // Database.executeBatch(new BulkProductUpdates(), 1);
         
     }
}