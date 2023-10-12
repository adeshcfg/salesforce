/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to calculate Product is eligible to Interest Waiver or not
 *  @author : A5E Consulting
 *  @date : 12/10/2023
 
 *************************************************************************************************/
public class InterestWaiverBatch implements Database.Batchable<sObject> { 
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //List<String> productNames = new List<String>{'1070P6324'};
        return Database.getQueryLocator(
            [Select id , name ,Interest_Stopped__c,Interest_Amount_Last_Calculated_Date__c,Interest_Waived_Off_Start_Date__c ,Interest_Waived_Of_End_Date__c from product__c where RecordType.DeveloperName= 'Distressed_Account' 
             and (Current_Principal_Balance__c = NULL OR Current_Principal_Balance__c <= 0 OR 
                  Interest_Rate__c = NULL OR Interest_Rate__c = 0 OR Interest_Amount_Last_Calculated_Date__c = NULL 
                  OR Collection_Sub_Status__c = 'Paid in Full Account' OR Collection_Sub_Status__c = 'Settled in Full Account' 
                  OR Collection_Sub_Status__c = 'Deceased' OR Collection_Sub_Status__c = 'Bankrupt Account'
                  OR Collection_Sub_Status__c = 'Credit Counselling' OR Insolvency_Date__c != NULL OR Deceased_Date__c != NULL
                  )
             //AND Name IN: productNames 
            ]
        );
        
    }     
    
    public void execute(Database.BatchableContext bc, List<Product__c> listProducts){ 
		Map<id,product__c> mapProduct = new Map<id,product__c>();
        for(Product__c prodData : listProducts){
             prodData.Interest_Stopped__c = true;
             mapProduct.put(prodData.id,prodData);
        }
        ProductTriggerHandler.runProductTrigger = false;
        update mapProduct.values();
        ProductTriggerHandler.runProductTrigger = true;
    }

    //Finish method
    public void finish(Database.BatchableContext bc){  
       
    }
    
}