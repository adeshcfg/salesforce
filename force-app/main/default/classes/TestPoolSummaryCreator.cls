@isTest
public class TestPoolSummaryCreator {
    public static testMethod void testMethod1() {
        
        Pool__c poolData = new Pool__c();
        poolData.Placepool_Facevalue__c = 100;
        poolData.Placepool_Accounts__c = 3;
        //poolData.add(poolInstance);
        insert poolData;
        
        Product__c prod3 = new Product__c();
        prod3.Name = '1566P450';
        prod3.collection_agency__c = 29;
        prod3.Pool_Name__c = poolData.id;
        insert prod3;
        
       PoolSummaryCreator.populatePoolData(poolData.id);
    }
}