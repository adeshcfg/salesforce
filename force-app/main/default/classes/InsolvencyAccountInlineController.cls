/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to manage inline Insolvency Accounts
 *  @author : A5E Consulting
 *  @date : 03/19/2018
 * 
 *************************************************************************************************/
public with sharing class InsolvencyAccountInlineController {
    public string InsolId;
    public String message{get;set;} 
    public list<Insolvency_Account__c> InsolAccList{get; set;}
    public map<id, string> InsolAccListOld{get; set;}
    public map<id, string> InsolAccStatusListOld{get; set;}
    //public map<Id,ID> insolAccRTId{get; set;}
    public Boolean isCommunityReadOnly {set;get;}
    public Boolean isCommunityUser {set;get;}
    public String urlForPage{get;set;}
    public String baseUrl{get;set;}
    public string newInsolAccLink{get; set;}
    public String profileName;
    public boolean isViewPage{get;set;}
    public string insolAccountId{get; set;}
    public boolean isLightningCommunity{get;set;}
    public String urlPathPrefix{get;set;}
    public boolean runDuplicateCheckForProfile = false;
    public boolean runDuplicateCheckForBank = false;
    public Boolean isCommunityQAUser {set;get;}
    public map<Id, Insolvency_Account__c> insolAccMap = new map<Id, Insolvency_Account__c>();
    public set<Id> accIdSet = new set<Id>(); 
    
    Application_Config_Settings__c config;// = Application_Config_Settings__c.getOrgDefaults();
    
    //Controller Constructor
    public InsolvencyAccountInlineController(ApexPages.StandardController controller) {
       InsolId = ApexPages.CurrentPage().getParameters().get('id');
       isViewPage = false;
       if(ApexPages.CurrentPage().getParameters().get('viewPage')!=null){
           isViewPage  = true;
       }
       
       config = [SELECT Insolvency_Account_Object_ID__c, Insolvency_Account_Field_ID__c, Run_Insolvency_Account_Duplicate_Check__c,
                    Profile_Eligible_for_Duplicate_Check__c, Bank_Eligible_for_Duplicate_Check__c, 
                    Ignore_Account_Number_for_DuplicateCheck__c FROM Application_Config_Settings__c];
       
       refreshInsolAcc();
       
       //fetch id, name in map for duplicate
       InsolAccListOld = new map<id, string>();
       InsolAccStatusListOld = new map<id, string>();
       
       for(Insolvency_Account__c acc : InsolAccList){
           InsolAccListOld.put(acc.Id, acc.Name); 
           InsolAccStatusListOld.put(acc.Id, acc.Insolvency_Status__c);
       }
       
       system.debug('InsolAccListOld='+InsolAccListOld);
       system.debug('Insolvency Id='+InsolId );
       
       
       //Check whether current user is community user or not
       isCommunityUser = InsolvencyUtil.isCommunityUser();
        
       String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'QA Community User Readonly'){
            isCommunityQAUser = true;
        }
        else{
            isCommunityQAUser = false;
        }
       
       //Check whether current user is readonly profile or not
       isCommunityReadOnly = InsolvencyUtil.isCommunityReadOnlyUser();
        system.debug('isCommunityReadOnly::'+isCommunityReadOnly);
    //    isGoeasyCommunityUser = InsolvencyUtil.isGoeasyBankCommunityUser(UserInfo.getProfileId());
       //get the Profile name of current login user
        profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        // Check whether current user is commnity user or not and set URL
        if(profileName.contains('Community User') && !Test.isRunningTest()){
            baseUrl = InsolvencyAccntNoteCntrl.getCommunityUrl();
            isLightningCommunity = InsolvencyAccntNoteCntrl.isLightningCommunity;
            if(isLightningCommunity) {
                urlPathPrefix = InsolvencyAccntNoteCntrl.isProduction ? '/s' : '/' + InsolvencyAccntNoteCntrl.urlPathPrefix + '/s';
            }
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        Insolvency__c insolvncy = [Select Id, Name from Insolvency__c where id =: InsolId limit 1];
        
        newInsolAccLink = createInsolAccLink(baseUrl, insolvncy.Id, insolvncy.name, profileName);
        
        insolAccountId = baseUrl + '/';  //createExistingInsolAccountLink(baseUrl, profileName);
       
       // Method call to open new insolvency account page in same window
       viewPageinNewWindow();
    }
    
    public void refreshInsolAcc(){
        InsolAccList = [select Id, Name, Client_Identifier__c, Bank_Name__c, Account_Number_Without_Space__c, /*Account_Number_AlphaNumeric__c,*/ 
                        Insolvency__c, Insolvency__r.Name, Insolvency_Status__c, Account_Type__c,
                        Product_Code__c, Borrower_Primary__c, Type_of_Service__c, Claim_Type__c, Claim_Amount__c, 
                        Interest_Rate__c, Expected_Account_Recovery_Ratio__c, Last_Payment_Date__c, Last_Payment_Amount__c,Voting_Options__c, Latest_Payment_Date__c, Amended_Claim_Flag__c, 
                        Voting_Letter_Comments__c, Security_Description__c, Secured_Asset_Amount__c,Is_Duplicate_Resolved__c,Total_Remittance_count__c ,recordType.name,
                        recordType.developername,RecordTypeId
                        from Insolvency_Account__c 
                        where Insolvency__c =: InsolId and recordType.name != 'Unknown Bank' order by Latest_Payment_Date__c desc];
    }
                                                                
    public String createInsolAccLink(String BaseUrl, String insolvencyID, String insolvencyName, string profileName){ 
        pageReference pageRef;
        
        // set page reference URL for Scotia bank community user
        
     if(profileName.contains('Common')){
         pageRef = Page.InsolvencyAccountRecordType;
         Map<String, String> paramMap = pageRef.getParameters();
         paramMap.remove('save_new'); 
         paramMap.put('ent', config.Insolvency_Account_Object_ID__c); 
         paramMap.put('nooverride', '1');
     }
     else if(profileName.contains('Community')){
         pageRef = new pageReference(BaseUrl + '/' + Insolvency_Account__c.SObjectType.getDescribe().getKeyPrefix() + '/e?' + config.Insolvency_Account_Field_ID__c + '=' + insolvencyName + '&' + config.Insolvency_Account_Field_ID__c + '_lkid=' + insolvencyID + '&retURL='+ BaseUrl + '/' + insolvencyID);              
     }
     
        else{
            //pageRef = new pageReference(baseUrl + '/setup/ui/recordtypeselect.jsp?ent=' + config.Insolvency_Account_Object_ID__c + '&retURL='+ baseUrl +'/'+InsolId + '&save_new_url=' + baseUrl + '/' + Insolvency_Account__c.SObjectType.getDescribe().getKeyPrefix() + '/e?' + config.Insolvency_Account_Field_ID__c + '=' + insolvencyName + '&' + config.Insolvency_Account_Field_ID__c + '_lkid=' + insolvencyID + '&retURL=' + baseUrl +'/'+InsolId);
            pageRef = Page.InsolvencyAccountRecordType;
            Map<String, String> paramMap = pageRef.getParameters();
            //paramMap.putAll(ApexPages.currentPage().getParameters());
            paramMap.remove('save_new'); 
            paramMap.put('ent', config.Insolvency_Account_Object_ID__c); 
            //paramMap.put('retURL', baseUrl +'/'+InsolId); 
            paramMap.put(config.Insolvency_Account_Field_ID__c, insolvencyName); 
            //paramMap.put(config.Insolvency_Account_Field_ID__c + '_lkid', insolvencyID); 
            paramMap.put('nooverride', '1');
                                   
        }
        
        pageRef.setRedirect(true);
        system.debug('URL=='+pageRef);
        return pageRef.getUrl();
    }
    
    //Base URL for existing Insolvency Accounts
    public string createExistingInsolAccountLink(String BaseUrl, string profileName){
        pageReference pageRef;
        pageRef = new pageReference(BaseUrl + '/');   
        pageRef.setRedirect(true);
        return pageRef.getUrl();
        
    }
    
    //Record update method
    public pagereference save(){
        ApexPages.Message msg;
        string mssg;
        
        Set<String> insAccntName = new Set<String>();
        list<Insolvency_Account__c> insolAccDupList = new list<Insolvency_Account__c>();
        
        //Get Updated Account Number list
        for(Insolvency_Account__c insolAccDup : InsolAccList){
            if(insolAccDup.Name != InsolAccListOld.get(insolAccDup.Id)){
                insolAccDupList.add(insolAccDup);
            }
        }
       
        for(Insolvency_Account__c iaL: InsolAccList ){
            
             if(String.isBlank(iaL.Insolvency_Status__c)){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select Insolvency Status for ' + iaL.Name);
                ApexPages.addMessage(msg);
                mssg = 'NA';
            }
             if(String.isBlank(iaL.Account_Type__c)){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select Product Type for ' + iaL.Name);
                ApexPages.addMessage(msg);
                mssg = 'NA';
            }
             if(iaL.Borrower_Primary__c == null){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please enter Primary Borrower for ' + iaL.Name);
                ApexPages.addMessage(msg);
                mssg = 'NA';
            }
            if(String.isBlank(iaL.Claim_Type__c)){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select Claim Type for ' + iaL.Name);
                ApexPages.addMessage(msg);
                mssg = 'NA';
            }
            if(String.isBlank(iaL.Voting_Options__c)){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select Product Code for ' + iaL.Name );
                ApexPages.addMessage(msg);
                mssg = 'NA';
            }
    // Ticket#472 - No POC required then claim amount is still mandatory field (Inline Page) related chanages
          if(profileName.contains('Community User')){
              if(iaL.Claim_Amount__c == null && iaL.Insolvency_Status__c =='No PoC Required' && iaL.recordType.Name.contains('SDA')){
                 //no work
                }else if(iaL.Claim_Amount__c != null){
                //no work
            }else{
            
               msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please enter Claim Amount for ' + iaL.Name );
                system.debug('recordTypeIdTestENter');
                ApexPages.addMessage(msg);
                
                mssg = 'NA';
            }
            }else if(iaL.Claim_Amount__c == null){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please enter Claim Amount for ' + iaL.Name );
                system.debug('recordTypeIdTestENter');
                ApexPages.addMessage(msg);
                
                mssg = 'NA';
            }
             if(profileName.contains('Community') && iaL.Insolvency_Status__c == 'New'){
                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Invalid Insolvency Processing Status for ' + iaL.Name );
                ApexPages.addMessage(msg);
                mssg = 'NA';
            }
            
            system.debug('InsolAccListOld='+InsolAccListOld.get(iaL.Id));
            system.debug('iaL.Name='+iaL.Name);
            
            //Run duplicate check
            if(config.Run_Insolvency_Account_Duplicate_Check__c){
            
                //duplicate check eligible for profile
                list<String> profileEligList = new list<String>();
                string profileEligCS = config.Profile_Eligible_for_Duplicate_Check__c;
                profileEligList = profileEligCS.split(',');
                                    
                for(string profElig : profileEligList){
                    if(profileName.contains(profElig)){
                        runDuplicateCheckForProfile = true;
                        break;
                    }
                }
                                    
                //duplicate check eligible for Bank
                list<String> bankEligList = new list<String>();
                string bankEligCS = config.Bank_Eligible_for_Duplicate_Check__c;
                bankEligList = bankEligCS.split(',');
                                    
                for(string bankElig : bankEligList){
                    if(iaL.Client_Identifier__c.contains(bankElig)){
                        runDuplicateCheckForBank = true;
                        break;
                    }
                }
                
                //duplicate check not to consider account names from custom setting
                list<string> ignoreAcctNameList = new list<string>();
                string acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
                ignoreAcctNameList = acctNameCS.split(',');
            
                if(iaL.Name != InsolAccListOld.get(iaL.Id) && !ignoreAcctNameList.contains(iaL.Account_Number_Without_Space__c.toUpperCase())){
                    if(runDuplicateCheckForProfile && runDuplicateCheckForBank){
                        if(dupAccCheckList(iaL.Id, iaL.RecordTypeID, iaL.Name,  iaL.Insolvency__r.Id, ignoreAcctNameList)){
                            msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Duplicate record found for ' + iaL.Name );
                            ApexPages.addMessage(msg);
                            mssg = 'NA';
                        }
                    }
                } 
            }
            
           /*
           //Insolvency Status dates for SLA tracking
           if(iaL.Insolvency_Status__c != InsolAccStatusListOld.get(iaL.Id)){
                if(String.isNotBlank(iaL.Insolvency_Status__c)){
                    if(iaL.Insolvency_Status__c == 'For Owner Review'){
                        iaL.Sent_For_Owner_Review_Date__c = system.now();
                    }
                    else if(iaL.Insolvency_Status__c == 'PoC Details Provided'){
                        iaL.PoC_Details_Provided_Date__c = system.now();
                    }
                    else if(iaL.Insolvency_Status__c == 'No PoC Required'){
                        iaL.No_PoC_Required_Date__c = system.now();
                    }
                    else if(iaL.Insolvency_Status__c == 'Claim Filed'){
                        iaL.Claim_Filed_Date__c = system.now();
                    }
                }   
            } */
            
        }
        
        
        if(string.isBlank(mssg)){
            //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            List<Database.SaveResult> srList = Database.update(InsolAccList, false);
            
            //Back End Validation
            for (Integer cnt = 0; cnt < InsolAccList.size(); cnt++) {
                Database.SaveResult saveResults = srList[cnt];
                Insolvency_Account__c recordToCheck = InsolAccList[cnt];
                if (!saveResults.isSuccess()) {
                    for(Database.Error err : saveResults.getErrors()) {
                        msg = new ApexPages.Message(ApexPages.Severity.WARNING, err.getMessage() + ' for ' + recordToCheck.Name );
                        ApexPages.addMessage(msg);
                    }
                } 
            }
           //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;    
        }
        
        
        return ApexPages.CurrentPage();
    }   
     
    // open same page in new window method
    public void viewPageinNewWindow(){
        pageReference pgRef = new pageReference(baseUrl+ '/apex/InsolvencyAccountInline?id=' + InsolId);
        pgRef.setRedirect(true);
        urlForPage = pgRef.getUrl() + '&viewPage=yes';
    }
    
    // method to fetch community URL
    /* public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        System.debug('comm.siteUrl=' + comm.siteUrl);
        return comm.siteUrl;
    }  */
    
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
        
               
        for(Insolvency_Account__c acct: InsolAccList){
            accWrappers.add(new AcctWrpper(acct, baseUrl));
        }
        
        return accWrappers;
    }  
    
    //check if Duplicate available
    public boolean dupAccCheckList(Id accId, Id accRTId, string alphaNum, Id insolId, list<string> ignoreAcctNameList){
        boolean dupFound=false;
        string numberWithoutSpace = alphaNum.deleteWhitespace();
        system.debug('accId='+accId);
        system.debug('accRTId='+accRTId);
        system.debug('alphaNum='+alphaNum);
        
        List<Insolvency_Account__c> insolAcctDBList = [Select Id, Name 
                                                       from Insolvency_Account__c
                                                       where Id !=: accId
                                                       and RecordTypeID =: accRTId
                                                       and Account_Number_Without_Space__c =: numberWithoutSpace 
                                                       //and Insolvency__r.Id =: insolId
                                                       and Account_Number_Without_Space__c NOT IN: ignoreAcctNameList];
        
        if(insolAcctDBList.size()>0){
            dupFound = true;
        }
        return dupFound;
    } 
    
}