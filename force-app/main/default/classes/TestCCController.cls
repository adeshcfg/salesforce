/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a test class for CCController
 *  @author : A5E Consulting
 *  @date : 02/01/2022
 * 
 *************************************************************************************************/

@isTest
public class TestCCController {   

 static testMethod void ccControllerTest(){
 
        
        //Create Lead record       
        Lead leadData = new Lead();
        leadData.Status = 'Contacted';
        leadData.LastName = 'Text';        
        insert leadData;
     
        //Create Campaign record
        Campaign camp = new Campaign();           
        camp.Name = 'Text';
        camp.Status = 'In Progress';
        camp.StartDate = Date.newInstance(2022, 1, 17);
        camp.EndDate = Date.newInstance(2022, 1, 17);       
        insert camp;
            
        //Create Campaign Member record
        CampaignMember campMemb = new CampaignMember();
        campMemb.CampaignId = camp.Id;
        campMemb.LeadId = leadData.Id;
        campMemb.Status = ' Responded';     
        insert campMemb;
            
        ApexPages.currentPage().getParameters().put('name', camp.Name);
        ApexPages.StandardController sc = new ApexPages.StandardController(camp);       
        CCController ccController1 = new CCController(sc);
        ccController1.deleteCCRecords();    
        
        CCController ccController2 = new CCController();      
    }
 }