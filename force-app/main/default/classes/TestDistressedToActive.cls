/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Batch Class that mark distressed products as Active if updated today, by ETL 
*  @author : A5E Consulting
*  @date : 22 April 2019  

*************************************************************************************************/
@isTest
public class TestDistressedToActive {

@isTest   
static  void setup(){
ProductTriggerHandler.runProductTrigger = True;
List<Product__c> prodlist=new List<Product__c>();
RecordType rt=[select id,Name from RecordType where Name='Distressed Account' and sObjectType='Product__c' limit 1];
Product__c prod1=new Product__c();
prod1.RecordTypeId=rt.id;
prod1.Collection_Sub_Status__c ='Recalled';
prod1.Record_Last_Updated_In_Staging__c =system.today();
prodlist.add(prod1);
Product__c prod2=new Product__c();
prod2.RecordTypeId=rt.id;
prod2.Collection_Sub_Status__c ='Recalled';
prod2.Record_Last_Updated_In_Staging__c =system.today();
prodlist.add(prod2);
insert prodlist;
system.debug('product list output'+prodlist);

//prod.Record_Last_Updated_In_Staging__c =system.today();
//ProductTriggerHandler.runProductTrigger = false;
//update prod;
//ProductTriggerHandler.runProductTrigger = true;

test.startTest();
DistressedToActive da=new DistressedToActive();
Database.QueryLocator ql=da.start(null);
da.execute(null,prodlist);
da.finish(null);
test.stopTest();
}
}