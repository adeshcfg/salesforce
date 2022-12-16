/**************************************************************************************************
*
*  Class:   
*
*  @description : SettlementWidgetController
*  @author : A5E Consulting
*  @date : 04/07/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestSettlementWidgetController {
        
    static testMethod void insertTestData(){
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
        
       
        Settlement__C settlementInstance = new Settlement__C();
        settlementInstance.product__c = prod.ID;
        insert settlementInstance;
        SettlementWidgetController.getproduct(settlementInstance.ID);
        
    }
}