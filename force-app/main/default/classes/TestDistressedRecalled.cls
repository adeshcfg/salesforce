/**************************************************************************************************
*
*  Class:   
*
*  @description : Test Class that mark distressed products as RECALLED
*  @author : A5E Consulting
*  @date :  22 April 2019  

*************************************************************************************************/
@isTest
public class TestDistressedRecalled {
    static testMethod void DistressedRecalled(){
          list<RecordType> rList = [Select id 
                                            From RecordType 
                                            Where sObjectType = 'product__c'and RecordType.Name = 'Distressed Account'];
        
        
        List<Product__c> prodList = new List<Product__c>();
         Product__c prod = new Product__c();
         prod.Record_Last_Updated_In_Staging__c = system.today();
         prod.Collection_Sub_Status__c = null;
         prod.recordTypeId = rList[0].id;
         prod.Collection_Agency__c = null;
         prodList.add(prod);
         ProductTriggerHandler.runProductTrigger = false;
        insert prodList;
        ProductTriggerHandler.runProductTrigger = true;
        
        Database.executeBatch(New DistressedRecalled(), 100);
    }      
          
}