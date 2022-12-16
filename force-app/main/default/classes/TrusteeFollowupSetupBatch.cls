/***************************************************
* Author         : A5E Consultancy
* Created On     : 1 March 2020
* Description    : Sets up TrusteeFollowUpBatch 
*
***************************************************/
public class TrusteeFollowupSetupBatch implements Database.Batchable<sobject>{

     // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator ([SELECT Id, 
                                              Name, 
                                              Last_Trustee_Followup_Sent_Date__c
                                              from Account
                                              Where recordType.Name='Trustee Office']);   
    
    }
    
    // Execute method
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
    
        List<Account> trusteeOffices = (List<Account>) scope;
        
        for(Account trusteeOffice : trusteeOffices){
            trusteeOffice.Number_Of_Emails_Sent_Today__c = 0;       
        }
        
        update trusteeOffices;
    
    }

    // Finish Method
    public void finish(Database.BatchableContext BC) {
        //Execute TrusteeFollowUpBatch
        Database.executeBatch(new TrusteeFollowUpBatch(), 50);
    }
}