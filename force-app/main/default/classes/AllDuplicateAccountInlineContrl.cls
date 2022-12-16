/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to manage inline Duplicate Insolvency Accounts
 *  @author : A5E Consulting
 *  @date : 03/12/2019
 * 
 *************************************************************************************************/
 
public with sharing class AllDuplicateAccountInlineContrl {
    public string accId;
    public String profileName;
    public String baseUrl{get;set;}
    Insolvency_Account__c wihoutSpaceAccName = new Insolvency_Account__c();
    public list<Insolvency_Account__c> accList = new list<Insolvency_Account__c>();
    
    //controller constructor
    public AllDuplicateAccountInlineContrl(ApexPages.StandardController controller) {
        accId= ApexPages.CurrentPage().getParameters().get('id');
        
        //get the Profile name of current login user
        profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        // Check whether current user is commnity user or not and set URL
        if(profileName.contains('Community User')){
            baseUrl = getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        showDupAccount();
    }
    
    //to get related duplicate accounts
    public void showDupAccount(){
        wihoutSpaceAccName = [select Account_Number_without_Space__c from Insolvency_Account__c where id =: accId limit 1];
        accList = [select Id, Name, Insolvency__r.Name, Bank_Name__c, Vendor_Orginator__c, Asset_Status__c, Duplicate_Reasons_Picklist__c
                    from Insolvency_Account__c 
                    where Account_Number_without_Space__c =: wihoutSpaceAccName.Account_Number_without_Space__c 
                    and Id !=: accId];
    }
    
    //wrapper class
    public class AcctWrpper{
        public Insolvency_Account__c acc{get;set;}
        public String accLink {get;set;}
        
        public AcctWrpper(Insolvency_Account__c acc, String baseUrl){
            this.acc = acc;
            this.accLink = baseUrl + '/' + acc.Id;        
        }       
    }
    
    //Populate and return Note Wrappers
    public List<AcctWrpper> getInslAcctWrappers(){
        
        List<AcctWrpper> accWrappers = new List<AcctWrpper>();
        
               
        for(Insolvency_Account__c acct: AccList){
            accWrappers.add(new AcctWrpper(acct, baseUrl));
        }
        return accWrappers;
    }  
    
    // method to fetch community URL
    public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        return comm.siteUrl;
    } 

}