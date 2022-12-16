/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a test class for ContactCentreCleaner 
*  @author : A5E Consulting
*  @date : 01/31/2022
* 
*************************************************************************************************/

@isTest
public class TestContactCentreCleaner {    
    
    static testMethod void ContactCentreCleaner(){
   
        // Create Lead record       
        Lead leadData = new Lead();
        leadData.Status = 'Contacted';
        leadData.LastName = 'Text';        
        insert leadData;
        
        //create Campaign record
        Campaign camp = new Campaign();           
        camp.Name = 'Text';
        camp.Status = 'In Progress';
        camp.StartDate = Date.newInstance(2022, 1, 17);
        camp.EndDate = Date.newInstance(2030, 1, 17);        
        insert camp;
        
        //create Campaign Member record
        CampaignMember campMemb = new CampaignMember();
        campMemb.CampaignId = camp.Id;
        campMemb.LeadId = leadData.Id;
        campMemb.Status = 'Responded';        
        insert campMemb;
        
        ContactCentreCleaner ccCleaner = new ContactCentreCleaner(camp.Id);
        ID batchprocessid = Database.executeBatch(ccCleaner);       
    }
}