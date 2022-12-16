/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a Batch class to update the Insolvency status if the Insolvency Account 
status is Claim filed/No PoC required       
*  @author : A5E Consulting
*  @date : 10/08/2018
* 
*************************************************************************************************/

public class InsolvencyStatusUpdateBatch implements Database.Batchable<sObject>{
  
    /*  Query all the insolvency account whose status is 'Claim Filed' & 'No PoC Required',and their 
corresponding insolvency having status 'For Owner Review' */
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id, Name, Insolvency_Status__c, Insolvency_Status_Last_Changed__c, lastmodifieddate, lastmodifiedby.name,
                                         (SELECT Id,Insolvency_Status_Last_Changed__c,lastmodifiedby.name FROM Insolvency_Accounts__r order By Insolvency_Status_Last_Changed__c desc )
                                         from Insolvency__c 
                                         WHERE Id not in (SELECT Insolvency__c FROM Insolvency_Account__c 
                                                          WHERE Insolvency_Status__c!='Claim Filed' AND insolvency_Status__c != 'No Poc Required') 
                                         AND Id in (SELECT Insolvency__c FROM Insolvency_Account__c)
                                         AND Insolvency_Status__c = 'For Owner Review' order BY Insolvency_Status_Last_Changed__c desc]);
    }
    
    // Update Insolvency status from 'For Owner Review' to 'Active' and Update the last insolvency status date also
    
    public void execute(Database.BatchableContext BC , List<Insolvency__c> insolList) {
            
       
        for(Insolvency__c insol:insolList){
            
            //Get last updated Insolvency Account
            Insolvency_Account__c lastUpdatedAccount = insol.Insolvency_Accounts__r.get(0);  
            DateTime lastChangedDate =  lastUpdatedAccount.Insolvency_Status_Last_Changed__c;
          
            //Update Insolvency     
            insol.Insolvency_Status__c = 'Active';
            insol.Insolvency_Status_Last_Changed__c = lastChangedDate;
            
            //Update SLA tracking
            
            insol.Set_to_Active_Date__c = lastChangedDate;
            insol.Set_to_Active_By__c =lastUpdatedAccount.LastModifiedById;
                   
       }
       
        //Don't run the insolvency trigger
       
        InsolvencyTriggerHandler.runInsolvencyTrigger = false;
        
        try {            
            update insolList;            
        } catch(Exception e) {
            System.debug(e);
        }
        
        InsolvencyTriggerHandler.runInsolvencyTrigger = true; 
    }   
    
    
    public void finish(Database.BatchableContext BC){
        //Do Nothing
    }    
}