/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to manage inline Insolvency Cases
 *  @author : A5E Consulting
 *  @date : 10/12/2017
 *  
 *************************************************************************************************/

public with sharing class InsolvencyCasesILCntrl{
    
    public String insolvencyId{get;set;}
    public List<CaseWrpper> insolvencyWrapperCases{get;set;}
    public List<CaseWrpper> insolvencyAccountWrapperCases{get;set;}
    public String newCaseLink{get;set;}
    public Boolean isCommunityReadOnlyUser {set;get;}
    public Boolean isCommunityUser {set;get;}
    
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    public Boolean createNewCase{get;set;}
  
    public InsolvencyCasesILCntrl(ApexPages.StandardController controller) {
        
        String baseUrl;
        
        //Check if user is internal user or external user
        createNewCase = true;
        
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName.contains('Community User')){
            //createNewCase = false;
            baseUrl = getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        
        //Insolvency ID
        insolvencyId = ApexPages.currentPage().getParameters().get('id');
        
        Insolvency__c insolvncy = [Select Id, Name from Insolvency__c where id =: insolvencyId limit 1];
        
        //Cases related to Insolvency
        List <Case> insolvencyCases = [Select Id, Subject, Status, 
                                              Assigned_To__r.name,
                                              CreatedDate, Is_Email_to_Case__c,
                                              Insolvency__c, Estate_ID__c, Insolvency_Account__c, Bank_Name__c    
                                              from Case 
                                              where Insolvency__c =: insolvencyId];
        if(insolvencyCases.size() > 0){
            insolvencyWrapperCases = new List<CaseWrpper>();
            for(Case insolvencyCase : insolvencyCases){
                insolvencyWrapperCases.add(new CaseWrpper(insolvencyCase, baseUrl));
            }           
        }
        
        //Related Insolvency Accounts ID
        Set<Id> insolvencyAccountIds = new Set<Id>();
        List<Insolvency_Account__c> insolvencyAccounts = [Select Id from Insolvency_Account__c where Insolvency__c =: insolvencyId];
        if(insolvencyAccounts.size() > 0){
            for(Insolvency_Account__c insolvencyAccount : insolvencyAccounts){
                insolvencyAccountIds.add(insolvencyAccount.Id);
            }
            
            //Cases related to related Insolvency Accounts
            List <Case> insolvencyAccountCases = [Select id, Subject, Status,
                                                         Assigned_To__r.name, 
                                                         CreatedDate, Is_Email_to_Case__c,
                                                         Insolvency_Account__c, Account_Number__c, Bank_Name__c   
                                                         from Case 
                                                         where Insolvency_Account__c in : insolvencyAccountIds];
            if(insolvencyAccountCases.size() > 0){
                insolvencyAccountWrapperCases = new List<CaseWrpper>();
                for(Case insolvencyAccountCase : insolvencyAccountCases){
                    insolvencyAccountWrapperCases.add(new CaseWrpper(insolvencyAccountCase, baseUrl));
                }           
            }
        }
        
        newCaseLink = createCaseLink(baseUrl, insolvncy.Id, insolvncy.name);
        
        //Check whether current user is readonly profile or not
        isCommunityReadOnlyUser = InsolvencyUtil.isCommunityReadOnlyUser();
        isCommunityUser = InsolvencyUtil.isCommunityUser();
    }   
    
    public class CaseWrpper{
        public Case cse{get;set;}
        public String caseLink {get;set;}
        public String insolvencyAccountLink {get;set;}
        public string dateOpened {get;set;}
        
        public CaseWrpper(Case cse, String baseUrl){
            this.cse = cse;
            this.caseLink = baseUrl + '/' + cse.Id;
            this.dateOpened = (cse.createdDate).format('MM/dd/yyyy');
            
            if(cse.Insolvency_Account__c != null){
                this.insolvencyAccountLink = baseUrl + '/' + cse.Insolvency_Account__c;
            }
        }       
    }
    
    public String createCaseLink(String BaseUrl, String insolvencyID, String insolvencyName){       
        pageReference pgRef = new pageReference(BaseUrl + '/500/e?' + config.Insolvency_Case_Field_ID__c + '=' + insolvencyName + '&' + config.Insolvency_Case_Field_ID__c + '_lkid=' + insolvencyID + '&retURL=' + insolvencyID);
        pgRef.setRedirect(true);
        return pgRef.getUrl();
    }
    
    public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        System.debug('comm.siteUrl' + comm.siteUrl);
        return comm.siteUrl;
    } 
}