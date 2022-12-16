@isTest
public class TestPoolTriggerHandler {
    
    static testMethod void testHandler(){
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='89';
        insert plcgy;
        
        List<Pool__c> poolData = new List<Pool__c>();
        Pool__c poolInstance = new Pool__c();
        poolInstance.Placement_Agency__c = 89;
        poolInstance.Placement_agency_lookup__c = plcgy.id;
        poolData.add(poolInstance);
        insert poolData;
        
        poolInstance.Commission_Rate__c = 12;
        update poolData;
        
    }

}