/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for DeleteDelinquencyTrackerBatch
*  @author : A5E Consulting
*  @date : 07/13/2017   

*************************************************************************************************/
@isTest
public class TestDeleteDelinquencyTrackerBatch{

    public Static testMethod void delDTBatch(){
    
        //create Product Snapshot Custom Setting Record    
        createDTCS();
                
        //create Delinquency_Tracker__c records
        createDTRecords();
        
        //execute DeleteDelinquencyTrackerBatch
        Database.executeBatch(New DeleteDelinquencyTrackerBatch());
    }
    
    //create Delinquency Tracker records
    public static void createDTRecords(){
        
        Delinquency_Tracker__c dtRec = New Delinquency_Tracker__c();
        dtRec.Iteration_Number__c = 2;
        insert dtRec;
        
        dtRec = New Delinquency_Tracker__c();
        dtRec.Iteration_Number__c = 2;
        insert dtRec;
    }
    
    //Create Custom Setting Record
    public static void createDTCS(){
        
        Delinquency_Tracker_Settings__c dtCS = New Delinquency_Tracker_Settings__c();
        dtCS.Iteration_Limit__c = 1;
        dtCS.Next_Iteration__c = 2;        
        insert dtCS; 
    }    
}