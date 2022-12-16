/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a Batch class to manage Insolvency Snapshots
*  @author : A5E Consulting
*  @date : 04/26/2018
* 
*************************************************************************************************/

public class InsolvencySnapshotBatch implements Database.Batchable<sObject>{
    
    public static List <String> statusNames = New List<String>();
    public static List <String> bankNames = New List<String>();
    
     
    static{
        
        //List of Statuses        
        List<Schema.PicklistEntry> pikListStatusValues = Insolvency_Snapshot__c.Insolvency_Status__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pikListStatusValue : pikListStatusValues) {
            statusNames.add(pikListStatusValue.getValue());
        }
        System.debug('statusNames list :'+statusNames);
        
        //List of Banks        
        List<Schema.PicklistEntry> pikListBankValues = Insolvency_Snapshot__c.Bank_Name__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pikListBankValue : pikListBankValues) {
            bankNames.add(pikListBankValue.getValue());
        }
        
        System.debug('bankNames list :'+bankNames);
    }
    
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([select id, 
                                                Claim_Amount__c, Claim_Type__c, 
                                                Insolvency__r.Insolvency_Status__c, 
                                                Client_Identifier__c 
                                                from Insolvency_Account__c 
                                                where Insolvency__c!= null
                                                ]);
    }
    
    //Execute Method
    public void execute(Database.BatchableContext BC, List<Insolvency_Account__c> insAccnts){
        
        List<Insolvency_Snapshot__c> snapObjDBList = [select Id, 
                                          					Insolvency_Status__c, 
                                          					Bank_Name__c,
                                          					Number_of_Secured_Accounts__c,
			                                				Number_of_Unsecured_Accounts__c,
			                                				Total_Secured_Claim_Amount__c,
			                                				Total_Unsecured_Claim_Amount__c
                                          					from Insolvency_Snapshot__c
                                          					where Snapshot_Date__c = today];  
         
         System.debug('bankNames list execute   :'+bankNames);           
        
        //Create and Populate Bank map
        Map<String, Map<String, Insolvency_Snapshot__c>> statusbankSnapObjMap = new Map<String, Map<String, Insolvency_Snapshot__c>>();
         
         
        //Initilaize with temp records 
        for(String statusName : statusNames){
        	
        	Map<String, Insolvency_Snapshot__c> bankSnapObjMap = new Map<String, Insolvency_Snapshot__c>();
          
          	for(String bankName : bankNames){
          		
          		Insolvency_Snapshot__c snapObjectTmp = new Insolvency_Snapshot__c();
              
              	snapObjectTmp.Bank_Name__c = bankName; 
                snapObjectTmp.Insolvency_Status__c = statusName;
              
                //initilizing 0 to avoid null pointer exception
                snapObjectTmp.Number_of_Secured_Accounts__c = 0;
		        snapObjectTmp.Number_of_Unsecured_Accounts__c = 0;
		        snapObjectTmp.Total_Secured_Claim_Amount__c = 0;
		        snapObjectTmp.Total_Unsecured_Claim_Amount__c = 0;
                snapObjectTmp.Snapshot_Date__c = system.today();
                           
                bankSnapObjMap.put(bankName, snapObjectTmp); 
            
            }    
          
            statusbankSnapObjMap.put(statusName, bankSnapObjMap);           
            
        }
        
        
        //Replace temp records with DB records       
        if(snapObjDBList.size() > 0){
            for(Insolvency_Snapshot__c snapObjDB : snapObjDBList){
              Map<String, Insolvency_Snapshot__c> bankSnapObjMapDB = new Map<String, Insolvency_Snapshot__c>();
                bankSnapObjMapDB.put(snapObjDB.Bank_Name__c, snapObjDB);
                statusbankSnapObjMap.put(snapObjDB.Insolvency_Status__c, bankSnapObjMapDB);
            }
        }
        
        //Popluate the data for Insolvency_Snapshot
        for(Insolvency_Account__c insAccnt : insAccnts){
          
          Map<String, Insolvency_Snapshot__c> bankSnapObjMaptmp = statusbankSnapObjMap.get(insAccnt.Insolvency__r.Insolvency_Status__c);
          
          if(bankSnapObjMaptmp != null){
            
              Insolvency_Snapshot__c snapObjToUpdate = bankSnapObjMaptmp.get(insAccnt.Client_Identifier__c);
              if(snapObjToUpdate != null){
              
                if(insAccnt.Claim_Type__c == 'Secured'){                  
                  snapObjToUpdate.Number_of_Secured_Accounts__c =  snapObjToUpdate.Number_of_Secured_Accounts__c + 1;
                  if(insAccnt.claim_Amount__c != null){
                    snapObjToUpdate.Total_Secured_Claim_Amount__c =  snapObjToUpdate.Total_Secured_Claim_Amount__c + insAccnt.claim_Amount__c;  
                  }                                    
                }
                
                else  if(insAccnt.Claim_Type__c == 'Unsecured'){
                  snapObjToUpdate.Number_of_Unsecured_Accounts__c =  snapObjToUpdate.Number_of_Unsecured_Accounts__c + 1;
                  if(insAccnt.claim_Amount__c != null){
                    snapObjToUpdate.Total_Unsecured_Claim_Amount__c =  snapObjToUpdate.Total_Unsecured_Claim_Amount__c + insAccnt.claim_Amount__c;  
                  }                    
                }
            
                bankSnapObjMaptmp.put(snapObjToUpdate.Bank_Name__c, snapObjToUpdate);
                statusbankSnapObjMap.put(snapObjToUpdate.Insolvency_Status__c, bankSnapObjMaptmp);  
            }    
          } 
        }
        
        //Upsert Records
        List<Insolvency_Snapshot__c> snapObjectsToUpdate = new List<Insolvency_Snapshot__c>();
        
        for(String statusName : statusNames){
          
          Map<String, Insolvency_Snapshot__c> bankSnapObjMap = statusbankSnapObjMap.get(statusName);
          
          for(String bankName:bankSnapObjMap.keySet()){ 
              snapObjectsToUpdate.add(bankSnapObjMap.get(bankName));
          }
        }
        
        if(snapObjectsToUpdate.size() > 0){
            upsert snapObjectsToUpdate;
        }        
    }
    
    //Finish
    public void finish(Database.BatchableContext BC){
        //Do Nothing
    }

}