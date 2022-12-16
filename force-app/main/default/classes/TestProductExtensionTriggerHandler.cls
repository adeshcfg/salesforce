@isTest
public class TestProductExtensionTriggerHandler {
    public static testMethod void TestAfterInsertUpdate(){
        Product__c prod = new Product__c();
        prod.Name = '1566P000';
        prod.Commission_Rate__c=13;
        prod.Value_Tier_at_Time_of_Placement__c = 'A';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        
        List<Product_Extension__c> prodExtList = new List<Product_Extension__c>();
        Product_Extension__c prodExt = new Product_Extension__c();
        prodExt.Dealer__c = 'Test Dealer';
        prodExt.Account_ID__c = prod.id;
        prodExt.Description__c = 'Test Description';
        prodExt.Value__c = 1;
        prodExt.Address_Line1__c = 'Test Add 1';
        prodExt.Address_Line2__c = 'Test Add 2';
        prodExt.City__c = 'Test City';
        prodExt.Zip_Code__c = 'Test ZipCode';
        prodExt.Country__c = 'Test Country';
        insert prodExt;
        prodExt.Dealer__c = 'Test Dealers Data';
        update prodExt;
        prodExtList.add(prodExt);
        
        
        
        
        ProductExtensionTriggerHandler.handleBeforeInsert(prodExtList);
        
        
    }
}