@istest
public class TestProductStatusUpdateController {
    @isTest
    static void TestMethod1(){
        //Product Record Creation
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
        
        //Data Status Mapping Custom Settings records insertion
        Data_Status_Mapping__c dataMap = new Data_Status_Mapping__c();
        dataMap.name = '310000';
        dataMap.Description__C = 'Pending Allocation test';
        insert dataMap;
        
        Data_Status_Mapping__c dataMap1 = new Data_Status_Mapping__c();
        dataMap1.name = 'Test1';
        dataMap1.Description__C = 'Warehouse Test';
        insert dataMap1;
        
        Data_Status_Mapping__c dataMap2 = new Data_Status_Mapping__c();
        dataMap2.name = 'Test2';
        dataMap2.Description__C = 'close Test';
        insert dataMap2;
        
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(prod);
        ProductStatusUpdateIndividualController controller1 = new ProductStatusUpdateIndividualController(sc);
        controller1.redirectToProduct();
        controller1.selectedValueAction = 'Warehouse Test';
        controller1.updateProduct();        
        
    }
    @isTest
    static void TestMethod2(){
        
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        
        //Data Status Mapping Custom Settings records insertion
        Data_Status_Mapping__c dataMap = new Data_Status_Mapping__c();
        dataMap.name = '310000';
        dataMap.Description__C = 'Pending Allocation test';
        insert dataMap;
        
        Data_Status_Mapping__c dataMap1 = new Data_Status_Mapping__c();
        dataMap1.name = 'Test1';
        dataMap1.Description__C = 'Warehouse Test';
        insert dataMap1;
        
        Data_Status_Mapping__c dataMap2 = new Data_Status_Mapping__c();
        dataMap2.name = 'Test2';
        dataMap2.Description__C = 'close Test';
        insert dataMap2;
        //Product Record Creation
        Product__C prod1 = new Product__c();
        
        prod1.RecordTypeId=recrdid;
        prod1.Name ='123456789';
        prod1.Previously_Reviewed_for_Legal_Action__c=True;
        prod1.Current_Principal_Balance__c=101;
        prod1.Current_Interest_Amount__c=1000;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.OwnerId= UserInfo.getUserId();
        prod1.Data_Status_Description__c='Pending Allocation:';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod1;
        ProductTriggerHandler.runProductTrigger = True;
        
        
        ApexPages.currentPage().getParameters().put('id', prod1.Id);
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(prod1);
        ProductStatusUpdateIndividualController controller2 = new ProductStatusUpdateIndividualController(sc1);
        controller2.redirectToProduct();
        controller2.selectedValueAction = 'Warehouse Test';
        controller2.updateProduct();        
        
    }
    @isTest
    static void Testmethod3(){
        
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        
        //Data Status Mapping Custom Settings records insertion
        Data_Status_Mapping__c dataMap = new Data_Status_Mapping__c();
        dataMap.name = '310000';
        dataMap.Description__C = 'Pending Allocation test';
        insert dataMap;
        
        Data_Status_Mapping__c dataMap1 = new Data_Status_Mapping__c();
        dataMap1.name = 'Test1';
        dataMap1.Description__C = 'Warehouse Test';
        insert dataMap1;
        
        Data_Status_Mapping__c dataMap2 = new Data_Status_Mapping__c();
        dataMap2.name = 'Test2';
        dataMap2.Description__C = 'close Test';
        insert dataMap2;
        
        //Product Record Creation
        Product__C prod2 = new Product__c();
        
        prod2.RecordTypeId=recrdid;
        prod2.Name ='123456789';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.OwnerId= UserInfo.getUserId();
        prod2.Data_Status_Description__c='closed:';
        
        ProductTriggerHandler.runProductTrigger = False;
        insert prod2;
        ProductTriggerHandler.runProductTrigger = True;
        
        ApexPages.currentPage().getParameters().put('id', prod2.Id);
        ApexPages.StandardController sc2 = new ApexPages.standardController(prod2);
        ProductStatusUpdateIndividualController controller3 = new ProductStatusUpdateIndividualController(sc2);
        controller3.redirectToProduct();
        controller3.selectedValueAction = 'Warehouse Test';
        controller3.updateProduct();  
        controller3.statusFlag=true;
        
    }
}