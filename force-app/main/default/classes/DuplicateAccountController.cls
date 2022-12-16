/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to manage Duplicate Insolvency Accounts
 *  @author : A5E Consulting
 *  @date : 06/15/2018
 * 
 *************************************************************************************************/

public with sharing class DuplicateAccountController {
    public string insolAccId;
    public Id insolAccRTId;
    public String baseUrl{get;set;}
    public string acctNameCS;
    public list<Insolvency_Account__c> insolAccList{get; set;}
    public list<string> ignoreAcctNameList{get; set;}
    public static Application_Config_Settings__c config;// = Application_Config_Settings__c.getOrgDefaults();

    //controller
    public DuplicateAccountController(ApexPages.StandardController controller) {
        
        config = [SELECT Ignore_Account_Number_for_DuplicateCheck__c /*, Run_Insolvency_Status_Validations__c*/ FROM Application_Config_Settings__c];//update for lock issue
       //duplicate check not to consider account names from custom setting
        ignoreAcctNameList = new list<string>();
        acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
        ignoreAcctNameList = acctNameCS.split(',');
        
        insolAccId = ApexPages.CurrentPage().getParameters().get('id');               
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        insolAccList = DuplicateAccountList(insolAccId);
    }
    
    //method to fetch duplicate account number list
    public list<Insolvency_Account__c> DuplicateAccountList(string insolAccId){
        string AccId = insolAccId;
        Insolvency_Account__c insolAcc = new Insolvency_Account__c();
        insolAcc = [Select Id, Name, /*Account_Number_AlphaNumeric__c,*/ RecordTypeID, RecordType.Name, Excluded_from_Purchase__c, Account_Number_Without_Space__c from Insolvency_Account__c where Id =: AccId];
        
        list<Insolvency_Account__c> insolAcctList = new list<Insolvency_Account__c>([Select Id, Name, Insolvency__r.Name, Bank_Name__c, Excluded_Account_Comments__c, Asset_Status__c,
                                                                                    Duplicate_Reasons_Picklist__c, Reasons_for_Duplicate_Account_Number__c, Account_Number_Without_Space__c, Excluded_from_Purchase__c, 
                                                                                    RecordTypeID, RecordType.Name from Insolvency_Account__c
                                                                                    where Account_Number_Without_Space__c =: insolAcc.Account_Number_Without_Space__c 
                                                                                    and Id !=: insolAccId 
                                                                                    and RecordTypeID =: insolAcc.RecordTypeID
                                                                                    and Account_Number_Without_Space__c NOT IN: ignoreAcctNameList 
                                                                                    ]);           
        return insolAcctList;
    }
    
    //Save method
    public pagereference save(){
        ApexPages.Message msg;
        boolean error = false;
         for(Insolvency_Account__c acct: insolAccList){
            
            if(string.isBlank(acct.Duplicate_Reasons_Picklist__c)){
                msg = new ApexPages.Message(ApexPages.severity.WARNING,'Duplicate Reason can not be blank. Please Enter Reasons for Duplicate Account for '+ acct.Name);
                ApexPages.addMessage(msg);
                error = true;
            }
            
        }
        //Don't run validation rules
        //Application_Config_Settings__c config = [SELECT FROM Application_Config_Settings__c FOR UPDATE];
        
        /*
         //Read and store the actual value of the insolvency status validation field
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        */
        
        if(!error){
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            update insolAccList;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        }
        
        /*
        config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
        update config;
        */
        
        return ApexPages.CurrentPage();
    }
    
    // method to fetch community URL
    public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        System.debug('comm.siteUrl=' + comm.siteUrl);
        return comm.siteUrl;
    } 
    
    //Populate and return insolvency account Wrappers
    public List<AcctWrpper> getInslAcctWrappers(){
        
        List<AcctWrpper> accWrappers = new List<AcctWrpper>();
        
        for(Insolvency_Account__c acct: insolAccList){
            accWrappers.add(new AcctWrpper(acct, baseUrl));
        }
        return accWrappers;
    }   
    
    //Wrapper class 
    public class AcctWrpper{
        public Insolvency_Account__c acc{get;set;}
        public String accLink {get;set;}
        public string insolLink{get;set;}
        
        public AcctWrpper(Insolvency_Account__c acc, String baseUrl){
            this.acc = acc;
            this.accLink = baseUrl + '/' + acc.Id;   
            this.insolLink = baseUrl + '/' + acc.Insolvency__r.Id;
        }       
    }
}