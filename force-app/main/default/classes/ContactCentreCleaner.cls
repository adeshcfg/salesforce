/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class is responsible for deleting of Contact Centre records
 *  @author : A5E Consulting
 *  @date : 01/27/2022
 * 
 *************************************************************************************************/

public class ContactCentreCleaner implements Database.Batchable<sobject>{    

    public String campaignID{ get; set ; }
    
    public ContactCentreCleaner(String campaignID){
        
        this.campaignID = campaignID;
    
    }
    
    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
       
        return Database.getQueryLocator([SELECT Id from CampaignMember where Campaign.ID =:campaignID] );
                                            
       
    }
    
    // Execute method
    public void execute(Database.BatchableContext BC, List<CampaignMember> campaignMembers) {
    
        try{
        
            delete campaignMembers;
        
        }
        catch(Exception e){
        
            //do nothing
        
        }
        
    }
    
    // Finish Method 
    public void finish(Database.BatchableContext BC) {
        
        //Call other Processor jobs
    }
}