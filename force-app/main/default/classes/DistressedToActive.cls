/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Batch Class that mark distressed products as Active if updated today, by ETL 
*  @author : A5E Consulting
*  @date : 20 Feb 2019  

*************************************************************************************************/
public Class DistressedToActive implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    
        
        return Database.getQueryLocator([select id, name, recordType.Name, Record_Last_Updated_In_Staging__c,
                                         Collection_Sub_Status__c
                                         from product__c where recordType.name = 'Distressed Account'
                                         AND Collection_Sub_Status__c = 'RECALLED'
                                         AND Collection_Agency__c <> null]);
    }
    
    public void execute(Database.BatchableContext BC, List<Product__C> prodList){
        
        for(Product__C prod : prodList){
            prod.Collection_Sub_Status__c = '';
            
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        update prodList;
        ProductTriggerHandler.runProductTrigger = true;
    }
    
    public void finish(Database.BatchableContext BC){
    
    }
    
}