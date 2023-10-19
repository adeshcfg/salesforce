/**************************************************************************************************
 *
 *  Class:   InlineInsolvencyAccountsCntrl
 *
 *  @description : Used to create multiple Insolvency Accounts in a single page
 *  @author : A5E Consulting
 *  @date : 08/29/2018
 * 
 *************************************************************************************************/
public with sharing class InlineInsolvencyAccountsCntrl {

    // Variables used in VF page
    public Insolvency__c insolv{set;get;}
    public String index{set;get;}
    public List<Wrapper> wrapList {set;get;}
    public String rType{set;get;}
    
    // store insolvency ID to use
    Id insolvId;
    String profileName;
    Boolean runDuplicateCheckForProfile = false;
    Boolean runDuplicateCheckForBank = false;
    
    public list<Insolvency_Account__c> InsolAccList;
    map<id, String> InsolAccNameListOld = new map<id, String>();
    map<id, Id> InsolAccRtypeListOld = new map<id, Id>();
    Set<String> processedNewNumber;
    public Map <String, String> cIRTMap = new Map<String, String>(); // Client Identifier
    public Map <Id, String> insAccntRecorTypeMap;
    
    // Custom setting for specific functionality check
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    // Controller
    public InlineInsolvencyAccountsCntrl(ApexPages.StandardController controller) {
        insolvId = ApexPages.CurrentPage().getParameters().get('id');
        insAccntRecorTypeMap = InsolvencyUtil.getInsAccntRecorTypeMap(); 
        cIRTMap.put('Scotia_Bank_Insolvency_Account', 'Scotia Bank');
        cIRTMap.put('SPL_Insolvency_Account', 'SPL');
        cIRTMap.put('SDA_Insolvency_Account', 'SDA'); 
        cIRTMap.put('Canaccede_Insolvency_Account', 'Canaccede'); 
        cIRTMap.put('Fidem_Insolvency_Account', 'Fidem');
        cIRTMap.put('Fairstone_Insolvency_Account', 'Fairstone'); 
        cIRTMap.put('Goeasy_Insolvency_Account', 'Goeasy'); 
        cIRTMap.put('Canadian_Tire_Insolvency_Account', 'Canadian Tire');
        insolv = [Select Id, 
                            Name, 
                            Insolvency_Type__c, 
                            Insolvency_Date__c, 
                            Insolvency_Status__c, 
                            Debtor__c, 
                            Co_Debtor__c
                     FROM Insolvency__c 
                             WHERE Id =: insolvId];

        wrapList = new List<Wrapper>();
        refreshInsolAcc();
        
        
        //get the Profile name of current login user
        profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        insolvencyRtype = getRecordTypes();
        
    }
    
    // This is used to add one more new insolvency account to add
    public void addMore(){
        addNewInsolvencyAccount();
    }
    
    // Functinality to add new Insolvency account, and populate default values
    public PageReference addNewInsolvencyAccount(){
    
    if(rType == NULL || rType == ''){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Bank Name'));
        return null;
    }
    
        Insolvency_Account__c obj = new Insolvency_Account__c();
        
        // Setting up Insolvency Account status based on Insolvency
        if(insolv.Insolvency_Status__c != NULL && insolv.Insolvency_Status__c.equals('For Owner Review')){
            obj.Insolvency_Status__c = insolv.Insolvency_Status__c;
        }else{
            obj.Insolvency_Status__c = 'New';
        }
        obj.Insolvency__c = insolvId;
        obj.Insolvency_Status__c = 'New';
        obj.Borrower_Primary__c = insolv.Debtor__c;
        obj.Borrower_Coborrower_1__c = insolv.Co_Debtor__c;
        obj.RecordTypeId = rType;
        Wrapper wrap = new Wrapper();
        wrap.key = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        wrap.insolvAcc = obj;
        wrapList.add(wrap);   
        return null;
    }
    
    // Remove specific insolvency account which has been added usin key
    public PageReference removeInsolvencyAccount() {
        Integer i = 0;
        for(Wrapper wrap : wrapList){
            if(wrap.key == index){
                break;
            }
            i++;
        }
        wrapList.remove(i);
        return null;
    }
  
    // This is used to load latest insolvency accounts
    public void refreshInsolAcc(){
        
        InsolAccNameListOld = new map<id, String>();
        InsolAccRTypeListOld = new map<id, Id>();
        
        wrapList = new List<Wrapper>();
        InsolAccList = [select Id, Name, Client_Identifier__c, Bank_Name__c, Account_Number_Without_Space__c, Account_Type__c,
                                RecordType.DeveloperName, 
                                Claim_Type__c, Insolvency_Status__c, Security_Type__c, Security_Description__c, Duplicate_Reasons_Picklist__c,Investment_Group__c,Portfolio_Group_Name__c,Portfolio_Name_Lookup__c
                                from Insolvency_Account__c 
                                where Insolvency__c =: insolvId and recordType.name != 'Unknown Bank'];
        
        /*
        //Coomented to demo only insert functionality                       
        for(Insolvency_Account__c acc : InsolAccList){
            
            Wrapper wrap = new Wrapper();
            wrap.key = acc.Id;
            Insolvency_Account__c ins = new Insolvency_Account__c();
            ins = acc;
             
            wrap.insolvAcc = ins;
            wrapList.add(wrap);
            InsolAccNameListOld.put(acc.Id, acc.Name); 
            InsolAccRTypeListOld.put(acc.Id, acc.RecordTypeId);
        }
        */
    }
    
    // This methid is used to upsert all insolvency accounts that has been modified/created one's
    public void  save(){
        ApexPages.Message msg;
        string mssg;
        processedNewNumber = new Set<String>();
        
        //duplicate check eligible for profile
        list<String> profileEligList = config.Profile_Eligible_for_Duplicate_Check__c.split(',');
        
        //duplicate check eligible for Bank
        list<String> bankEligList = config.Bank_Eligible_for_Duplicate_Check__c.split(',');
        
        for(string profElig : profileEligList){
            if(profileName.contains(profElig)){
                runDuplicateCheckForProfile = true;
                break;
            }
        }

        
        // Account names that are ignored to created Insolvency account
        list<string> ignoreAcctNameList = config.Ignore_Account_Number_for_DuplicateCheck__c.split(',');
        List<Insolvency_Account__c> insolvAccListToCreate = new List<Insolvency_Account__c>();
        
        
        if(!wrapList.isEmpty()){
            for(Wrapper wrap : wrapList){
                Insolvency_Account__c insolvAcc = wrap.insolvAcc;
                if(insolvAcc.Claim_Type__c == 'Secured'){
                    insolvAcc.Type_of_Service__c = 'Service Only';
                }else if(insolvAcc.Claim_Type__c == 'Unsecured'){
                    insolvAcc.Type_of_Service__c = 'Service and Sale';
                }
                insolvAccListToCreate.add(insolvAcc);
                insolvAcc.Borrower_Primary__c = insolv.Debtor__c;
                
                // Populate Account number to avoid nukl exception
                //if(insolvAcc.Account_Number_Without_Space__c == NULL || insolvAcc.Id == NULL){
                    insolvAcc.Account_Number_Without_Space__c = insolvAcc.Name.replaceAll( '\\s+', '');
                //}
                                
                string recordTypeName = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosById().get(insolvAcc.RecordTypeId).getDeveloperName();
                
                
                // Populate client identifier base don record type
                if(insolvAcc.RecordTypeId != null ){
                    insolvAcc.Client_Identifier__c = cIRTMap.get(recordTypeName);
                }
                
                // Check whether bank type should check for duplicate
                for(string bankElig : bankEligList){
                    if(insolvAcc.Client_Identifier__c != null && insolvAcc.Client_Identifier__c.contains(bankElig)){
                        runDuplicateCheckForBank = true;
                        break;
                    }
                }
                
                
                
                // Run diplicate check only if this option is enabled at custom setting
                if(config.Run_Insolvency_Account_Duplicate_Check__c){
                    if(insolvAcc.Id != null){
                        // Existing Insolency goes under duplicate check here
                       if((insolvAcc.Name != InsolAccNameListOld.get(insolvAcc.Id) || insolvAcc.RecordTypeId != InsolAccRTypeListOld.get(insolvAcc.Id)) && !ignoreAcctNameList.contains(insolvAcc.Account_Number_Without_Space__c.toUpperCase())){

                           if(runDuplicateCheckForProfile && runDuplicateCheckForBank && insolvAcc.Duplicate_Reasons_Picklist__c == null){
                                if(dupAccCheckList(insolvAcc.Id, insolvAcc.RecordTypeID, insolvAcc.Name,  insolvAcc.Insolvency__r.Id, ignoreAcctNameList, insolvAcc.Duplicate_Reasons_Picklist__c)){
                                    msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Duplicate record found for ' + insolvAcc.Name );
                                    ApexPages.addMessage(msg);
                                    mssg = 'NA';
                                }
                            }
                        } 
                    }
                    
                    // New Insolvency Account goes under duplicate check here
                    else if(runDuplicateCheckForProfile && runDuplicateCheckForBank){
                        String checkKey = insolvAcc.Account_Number_Without_Space__c+''+insolvAcc.RecordTypeId;
                        Boolean isNewAccDup = true;
                        system.debug(ignoreAcctNameList.contains(insolvAcc.Account_Number_Without_Space__c.toUpperCase())+'====insolvAcc.Account_Number_Without_Space__c.toUpperCase()'+insolvAcc.Account_Number_Without_Space__c.toUpperCase());
                            if(!processedNewNumber.contains(checkKey) || ignoreAcctNameList.contains(insolvAcc.Account_Number_Without_Space__c.toUpperCase())){
                                processedNewNumber.add(checkKey);
                                isNewAccDup = false;
                            }
                        
                        if((dupAccCheckList(insolvAcc.id, insolvAcc.RecordTypeID, insolvAcc.Name,  insolv.Id, ignoreAcctNameList, insolvAcc.Duplicate_Reasons_Picklist__c) || isNewAccDup) ){
                            msg = new ApexPages.Message(ApexPages.Severity.Error, 'Duplicate record found for ' + insolvAcc.Name );
                            ApexPages.addMessage(msg);
                            mssg = 'NA';
                        }
                        
                        if(runDuplicateCheckForProfile && runDuplicateCheckForBank && insolvAcc.Duplicate_Reasons_Picklist__c != null){
                            if(dupAccCheckList(insolvAcc.Id, insolvAcc.RecordTypeID, insolvAcc.Name,  insolvAcc.Insolvency__r.Id, ignoreAcctNameList, insolvAcc.Duplicate_Reasons_Picklist__c)){
                                msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Duplicate record found for ' + insolvAcc.Name );
                                ApexPages.addMessage(msg);
                                mssg = 'NA';
                            }
                        }
                    }
                }
            }
            
            // If there is no duplicate account number found
            if(string.isBlank(mssg)){
                
                // Run insolvency account trigger
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
                
                // dont run duplicate check any where else in this transaction, because we already done above
                Boolean dupcheckInitial = config.Run_Insolvency_Account_Duplicate_Check__c;
                config.Run_Insolvency_Account_Duplicate_Check__c = false;
                update config;
                
                system.debug('ddd'+insolvAccListToCreate);
                // Upsert records                
                List<Database.upsertResult> srList = Database.upsert(insolvAccListToCreate, Insolvency_Account__c.Id, false);
                
                //Back End Validation
                for (Integer cnt = 0; cnt < insolvAccListToCreate.size(); cnt++) {
                    Database.upsertResult upsertResult  = srList[cnt];

                    if (!upsertResult.isSuccess()) {
                        for(Database.Error err : upsertResult.getErrors()) {
                        mssg = 'NA';
                            msg = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage() + ' for ' + insolvAccListToCreate.get(cnt).Name );
                            //msg  = 'Account '
                            ApexPages.addMessage(msg);
                        }
                    }
                }
                config.Run_Insolvency_Account_Duplicate_Check__c = dupcheckInitial;
                update config;
                
                if(string.isBlank(mssg)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Accounts added successfully'));
                    refreshInsolAcc();
                }
            }
        }
    }
    
    //check if Duplicate available
    public boolean dupAccCheckList(Id accId, Id accRTId, string alphaNum, Id insolId, list<string> ignoreAcctNameList, String dupReason){

        boolean dupFound=false;
        string numberWithoutSpace = alphaNum.deleteWhitespace();
        numberWithoutSpace = alphaNum.replaceAll( '\\s+', '');
        List<Insolvency_Account__c> insolAcctDBList = new List<Insolvency_Account__c>();
        
        if(dupReason != null){
            insolAcctDBList = [Select Id, Name 
                                                       from Insolvency_Account__c
                                                       where Id !=: accId
                                                       AND RecordTypeID =: accRTId
                                                       and Insolvency__c =: insolId
                                                       and Account_Number_Without_Space__c =: numberWithoutSpace
                                                       and Account_Number_Without_Space__c NOT IN: ignoreAcctNameList];
        }else if(dupReason == null){
            insolAcctDBList = [Select Id, Name 
                                                       from Insolvency_Account__c
                                                       where Id !=: accId
                                                       AND RecordTypeID =: accRTId
                                                       and Account_Number_Without_Space__c =: numberWithoutSpace
                                                       and Account_Number_Without_Space__c NOT IN: ignoreAcctNameList];
        }
        
        if(insolAcctDBList.size()>0){
            dupFound = true;
        }
        return dupFound;
    } 

    // Updated all insolvency accounts with selected record type
    public void recordTypeSelected(){
        
    }
    
    public List<selectOption> insolvencyRtype {set;get;}
    public List<selectOption> getRecordTypes() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the picklist options
        /*add the first option of '- None -' in case the user doesn't
         want to select a value or in case no values are returned from query below*/
         //options.add(new selectOption('', '- None -')); 
        String defaultRtype = InsolvencyUtil.getRecordTypeToWorkOn();
        for(Recordtype record : [SELECT Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND (NOT  Name LIKE '%unknown%')]) { 
            //query for Record types records 
            options.add(new selectOption(record.id, record.Name)); 
            //for all records found - add them to the picklist options
            
            if(defaultRtype == record.Name){
                rtype = record.Id;
            }
        }
        if(rtype == NULL){
            selectOption sobj = options[0];
            rtype = sobj.getValue();
        }
        
        return options; //return the picklist options
    }
    
    // Wrapper class to use in vf page
    public class Wrapper{
        public String key{set;get;}
        public Insolvency_Account__c insolvAcc{set;get;}
    }
}