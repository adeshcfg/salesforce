/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Class that deletes Delinquency Tracker Records based on Iteration number     
*  @author : A5E Consulting
*  @date : 07/12/2017   

*************************************************************************************************/
public class DeleteDelinquencyTrackerBatch implements Database.Batchable<sObject>{
	
	//fetch Delinquency Tracker custom Settings record
	public Delinquency_Tracker_Settings__c cs = Delinquency_Tracker_Settings__c.getOrgDefaults();
    
    //fetch eligible Product Snapshots records
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id, Name FROM Delinquency_Tracker__c WHERE Iteration_Number__c =: cs.Next_Iteration__c ]);
    }
    
    //delete all the records returned by the query.
    public void execute(Database.BatchableContext BC, List<Delinquency_Tracker__c> dtList){
    
        if(dtList.size() != 0){
            delete dtList;
        }
    }
    
    //initiate the CreateProductSnapshotBatch Job
    public void finish(Database.BatchableContext BC){        
        Database.executeBatch(new DelinquencyTrackerBatch());
    }

}