@isTest
public class TestPoolSummaryBatchClass {
	public static testMethod void testMethod1() {
        Pool__c poolData = new Pool__c();
        poolData.Placepool_Facevalue__c = 100;
        poolData.Placepool_Accounts__c = 3;
        insert poolData;
        
        Product__c prod3 = new Product__c();
        prod3.Name = '1566P450';
        prod3.collection_agency__c = 29;
        prod3.Pool_Name__c = poolData.id;
        insert prod3;
        
        Test.startTest();
            PoolSummaryBatchClass obj = new PoolSummaryBatchClass();
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }
    
    public static testMethod void testMethod2() {
        Pool__c poolData = new Pool__c();
        poolData.Placepool_Facevalue__c = 100;
        poolData.Placepool_Accounts__c = 3;
        insert poolData;
        
        Product__c prod3 = new Product__c();
        prod3.Name = '1566P450';
        prod3.collection_agency__c = 29;
        prod3.Pool_Name__c = poolData.id;
        insert prod3;
        
        Test.startTest();
          PoolSummaryScheduleClass sh1 = new PoolSummaryScheduleClass();
          String sch = '0 0 23 * * ?';
          system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
       
    }
}