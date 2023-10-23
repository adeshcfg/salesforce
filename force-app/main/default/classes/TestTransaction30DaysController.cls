@istest
public class TestTransaction30DaysController {
	@isTest
    static void TestMethod1(){
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.OwnerId= UserInfo.getUserId();
        prod.Data_Status_Description__c='Warehouse:';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
         ApexPages.currentPage().getParameters().put('id', prod.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(prod);
        Transaction30DaysController controller1 = new Transaction30DaysController(sc);
    }
}