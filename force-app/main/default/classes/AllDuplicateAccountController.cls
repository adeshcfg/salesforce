/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to manage All Duplicate Insolvency Accounts
 *  @author : A5E Consulting
 *  @date : 06/19/2018
 * 
 *************************************************************************************************/

public with sharing class AllDuplicateAccountController {
    
    public String selectedBankName{get;set;}
    public String selectedInsolvencyType {get;set;}
    public String selectedProcessingStatus {get;set;}
    public String selectedClaimType {get;set;}
    public String selectedBulkAssetStatus {get;set;}
    
    public Insolvency_Account__c insolAcc{get; set;}
    public String formattedStartDate;
    public String formattedEndDate;    
    
    //WRapper for results
    public list<AcctWrpper> accWrappers{get; set;}
    
    public List<String> duplicateNameList{get; set;}
    public List<String> ignoreAcctNameList;
        
    //Pagination
    public Integer startNo {get;set;}
    public integer counter {get;set;}
    public integer list_size{get;set;}
    public integer total_size{get;set;}
    
    //Configurations
    public Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    //public String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    
    //Controller
    public AllDuplicateAccountController() { 
        
        list_size = Integer.valueOf(config.Display_Duplicate_Accounts_List_View__c);
        
        String acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
        ignoreAcctNameList = acctNameCS.split(','); 
        system.debug('ignoreAcctNameList =='+ignoreAcctNameList );
        total_size =0;
        startNo = 1;
        counter = 0;
        insolAcc = new Insolvency_Account__c();
        
        //includeAllDuplicate = false;
        performSearch();        
    } 
    
    /*
    //Initiate Search
    public PageReference refreshBankList(){
        performSearch();
        return null;
    }
    */
    
    //Initiate Search
    public PageReference initiateSearch(){
        performSearch();
        return null;
    }
    
    //Perform Date
    public void performSearch(){  
        
        System.debug('selectedClaimType :'+selectedClaimType);
        System.debug('selectedInsolvencyType :'+selectedInsolvencyType);
        System.debug('selectedProcessingStatus :'+selectedProcessingStatus);
        
        //Multi-Select
        List <String> selectedInsolvencyTypeList;
        if(String.isNotBlank(selectedInsolvencyType)){
            if(selectedInsolvencyType.contains('All')){
                selectedInsolvencyType = 'All';
            }
            else{
                selectedInsolvencyType = selectedInsolvencyType.remove('[');
                selectedInsolvencyType = selectedInsolvencyType.remove(']');
                selectedInsolvencyTypeList = selectedInsolvencyType.split(', ');
                System.debug('selectedInsolvencyTypeList size :'+selectedInsolvencyTypeList.size());
                System.debug('selectedInsolvencyTypeList :'+selectedInsolvencyTypeList);
            }
        }
        
        //Multi-Select 
        List <String> selectedProcessingStatusList;
        if(String.isNotBlank(selectedProcessingStatus)){
            if(selectedProcessingStatus.contains('All')){
                selectedProcessingStatus = 'All';
            }
            else{
                selectedProcessingStatus = selectedProcessingStatus.remove('[');
                selectedProcessingStatus = selectedProcessingStatus.remove(']');
                selectedProcessingStatusList = selectedProcessingStatus.split(', ');
                System.debug('selectedProcessingStatusList size :'+selectedProcessingStatusList.size());
                System.debug('selectedProcessingStatusList :'+selectedProcessingStatusList);
            }
        }
        
        //All accounts based on filters
        List<String> accountNames = new List<String>();       
        String accQry = 'Select id, Account_Number_Without_Space__c from Insolvency_Account__c where Insolvency__c!=null';
        
        system.debug('5653 selectedBanksName '+selectedBankName);  
        //Bnk Names
        if(String.isNotBlank(selectedBankName) && selectedBankName!='All'){
            //accQry += ' AND Client_Identifier__c =:selectedBankName';
            accQry += ' AND Client_Identifier__c =:selectedBankName';            
        }
        
        //PoC Created Dates
        if(insolAcc.Insolvency_Date__c!=null && insolAcc.Purchase_Date__c !=null){
            formattedStartDate = formatDate(insolAcc.Insolvency_Date__c);
            formattedEndDate = formatDate(insolAcc.Purchase_Date__c);
            accQry += ' AND PoC_Created_Date__c >='+formattedStartDate+'T00:00:00.000+0000';
            accQry += ' AND PoC_Created_Date__c <='+formattedEndDate+'T23:59:59.000+0000';
        }
        
        //Insolvency Type 
        if(String.isNotBlank(selectedInsolvencyType) && selectedInsolvencyType!='All'){
            if(selectedInsolvencyTypeList[0] != ''){
                //accQry += ' AND Insolvency__r.Insolvency_Type__c =:selectedInsolvencyType';
                accQry += ' AND Insolvency__r.Insolvency_Type__c in: selectedInsolvencyTypeList';
            }
        }
        
        //Insolvency Processing Status 
        if(String.isNotBlank(selectedProcessingStatus) && selectedProcessingStatus!='All'){
            if(selectedProcessingStatusList[0] != ''){
                //accQry += ' AND Insolvency_Status__c =:selectedProcessingStatus';
                accQry += ' AND Insolvency_Status__c in: selectedProcessingStatusList';    
            }        
        }
        
        //Claim Type
        if(String.isNotBlank(selectedClaimType) && selectedClaimType!='All'){
            accQry += ' AND Claim_Type__c =:selectedClaimType';
        }
        
        //Ignore Name list
        accQry += ' AND Account_Number_Without_Space__c NOT IN: ignoreAcctNameList ' ;
        
        //Limit 2000
        accQry += ' Order by CreatedDate Desc limit 2000';
        
        System.debug('accQry :'+accQry);
        
        //Query and populate names
        for(Insolvency_Account__c acc : database.query(accQry)){
            accountNames.add(acc.Account_Number_Without_Space__c);
            System.debug('accountNames :'+accountNames);
        }
        
        //New aggregate queries
        String aggQry = 'Select count(Id), Account_Number_Without_Space__c from Insolvency_Account__c ';
                aggQry += ' where Insolvency__c!=null AND Account_Number_Without_Space__c in:accountNames';
                aggQry += ' Group BY Account_Number_Without_Space__c Having Count(ID) > 1 ';
        List<AggregateResult> results = (List<AggregateResult>)Database.query(aggQry);
        
        duplicateNameList = new List<String>();
        if(null!=results){
            for(AggregateResult aggres : results){
                duplicateNameList.add((String)aggres.get('Account_Number_Without_Space__c'));   
                System.debug('duplicateNameList :'+duplicateNameList);         
            }
        }
        
        System.debug('duplicateNameList :'+duplicateNameList);
        
        list<Insolvency_Account__c> tempInsolAccList = getAllDuplicateAccountList();      
        system.debug('tempInsolAccList(final)=='+tempInsolAccList.size());  
        accWrappers = new List<AcctWrpper>(); 
        if(null != tempInsolAccList){
            for(Insolvency_Account__c acct:tempInsolAccList){
                //accWrappers.add(new AcctWrpper(acct, baseUrl, false));
                accWrappers.add(new AcctWrpper(acct, false));
            }
        }
    }
    
    public list<Insolvency_Account__c> getAllDuplicateAccountList(){
        
        //Pagination Count
        String countString = 'Select count() from Insolvency_Account__c where RecordTypeID != null ';
               countString += 'AND Account_Number_Without_Space__c NOT IN: ignoreAcctNameList ' ;
               countString +=' AND Account_Number_Without_Space__c in :duplicateNameList';
        
        if(String.isNotBlank(selectedBankName) && selectedBankName!='All'){
            countString += ' AND Client_Identifier__c =:selectedBankName';
        }
        total_size = database.countQuery(countString);
        
        //Final query
        String query = 'Select Id, Name, Insolvency__r.Name,Excluded_from_Purchase__c,Bank_Name__c, Client_Identifier__c,';
                     query += 'Excluded_Account_Comments__c,Is_Duplicate_Resolved__c,Account_Number_Without_Space__c,';
                     query += 'Reasons_for_Duplicate_Account_Number__c,Insolvency_Status__c,';
                     query += 'Claim_Amount__c,Purchase_Price__c,Claim_Type__c,Insolvency_Type__c,Insolvency_Date__c,';
                     query += 'Account_Type__c,Product_Code__c,Debtor__c,PoC_Created_Date__c,Purchase_Factor__c,';
                     query += 'Insolvency__r.Insolvency_Date__c, Insolvency__r.Insolvency_Type__c,';
                     query += 'RecordTypeID, RecordType.Name,Asset_Status__c from Insolvency_Account__c ';
                     query += ' where RecordTypeID != null ';
                     query += 'AND Account_Number_Without_Space__c not in :ignoreAcctNameList ' ;
                     query += 'AND Account_Number_Without_Space__c in :duplicateNameList';
        
        if(String.isNotBlank(selectedBankName) && selectedBankName!='All'){
            query += ' AND Client_Identifier__c =:selectedBankName';
        }
        query += ' order by Account_Number_Without_Space__c limit :list_size offset :counter ';
        
        return database.query(query);
    }
    
    /*
    public list<Insolvency_Account__c> getAllDuplicateAccountList1(){
        
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        //Integer duplicateAccountLimit = Integer.valueOf(config.Display_Duplicate_Accounts_List_View__c);
        list<Insolvency_Account__c> insolAcctList = new list<Insolvency_Account__c>();
        
          String countString = 'Select count() from Insolvency_Account__c where RecordTypeID != null ';
            //countString +=' AND Account_Number_Without_Space__c != \'Unknown\' ';
            countString +=' AND Account_Number_Without_Space__c in :duplicateNameList';
        
            if(null!=selectedBankName && selectedBankName!='All'){
                countString += ' AND Bank_Name__c =:selectedBankName';
            }
                total_size = database.countQuery(countString);
                system.debug('-----Total Duplicate Count-------'+total_size);
            
            //duplicate check not to consider account names from custom setting
            //list<string> ignoreAcctNameList = new list<string>();
            //string acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
            //ignoreAcctNameList = acctNameCS.split(',');
            
            
            String query = 'Select Id, Name, Insolvency__r.Name,Excluded_from_Purchase__c,Bank_Name__c,';
                     query += 'Excluded_Account_Comments__c,Is_Duplicate_Resolved__c,Account_Number_Without_Space__c,';
                     query += 'Reasons_for_Duplicate_Account_Number__c,Insolvency_Status__c,';
                     query += 'Claim_Amount__c,Purchase_Price__c,Claim_Type__c,Insolvency_Type__c,Insolvency_Date__c,';
                     query += 'Account_Type__c,Product_Code__c,Debtor__c,PoC_Created_Date__c,Purchase_Factor__c,';
                     query += 'Insolvency__r.Insolvency_Date__c, Insolvency__r.Insolvency_Type__c,';
                     query += 'RecordTypeID, RecordType.Name,Asset_Status__c from Insolvency_Account__c ';
                     query += ' where RecordTypeID != null ';
                    // query += 'AND Account_Number_Without_Space__c != \'Unknown\' ';
                    query += 'AND Account_Number_Without_Space__c NOT IN: ignoreAcctNameList ' ;
                     query += 'AND Account_Number_Without_Space__c in :duplicateNameList';
        if(null!=selectedBankName && selectedBankName!='All'){
            query += ' AND Bank_Name__c =:selectedBankName';
        }
        query += ' order by Account_Number_Without_Space__c limit :list_size offset :counter ';
        list<Insolvency_Account__c> tempinsolAcctList = database.query(query);
        system.debug('---------record count---------'+tempinsolAcctList.size());
                
        Map<Id,Id> duplicateIdKeyMap = new Map<Id,Id>();
        list<Insolvency_Account__c> tempinsolAcctList2 = tempinsolAcctList;
        for(Insolvency_Account__c acc:tempinsolAcctList){             
            for(Insolvency_Account__c acc2:tempinsolAcctList2){
                if( acc.id != acc2.id
                    && acc.Account_Number_Without_Space__c == acc2.Account_Number_Without_Space__c 
                   && acc.RecordTypeID == acc2.RecordTypeID && acc.Bank_Name__c == acc2.Bank_Name__c
                  && !ignoreAcctNameList.contains(acc2.Account_Number_Without_Space__c.toUpperCase())){
                 // && !acc.Name.toUpperCase().contains('UNKNOWN')){
                       if(!duplicateIdKeyMap.containsKey(acc2.Id) ){
                            insolAcctList.add(acc2);                            
                            duplicateIdKeyMap.put(acc2.Id,acc2.Id);
                       }
                   }
            }            
        }
        return insolAcctList;
    }
    */
    
    //Save method
    public pagereference doSave(){
        
        boolean accNotSelected = false;
        for(AcctWrpper acct: accWrappers){
            if(acct.isSelected){
                accNotSelected = True;
            }
        }
        
        if(!accNotSelected){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select at least one Insolvency Account to update'));
            return null;
        }
        
        if(String.isBlank(selectedBulkAssetStatus)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select Asset Status for bulk update'));
            return null;
        }
        
        List<Insolvency_Account__c> updateInsolAccList = new List<Insolvency_Account__c>();
        for(AcctWrpper acct: accWrappers){
            if(acct.isSelected){
                if(String.isNotBlank(selectedBulkAssetStatus)){
                    acct.acc.Asset_Status__c = selectedBulkAssetStatus;
                }
                updateInsolAccList.add(acct.acc);
            }
        }
        
        if(updateInsolAccList.size() > 0){
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            update updateInsolAccList;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;    
        }
        
        PageReference successPage = Page.AllDuplicateAccount;
        //successPage.setRedirect(true);
        successPage.setRedirect(false);
        return successPage;
    }
    
    //export duplicate accounts
    public pageReference exportDupAcct(){
        PageReference pr = new PageReference('/apex/AllDuplicateAccountsExport');
        pr.getParameters().put('BankName',selectedBankName);
        pr.getParameters().put('InsolvencyType', selectedInsolvencyType);
        pr.getParameters().put('ProcessingStatus', selectedProcessingStatus);
        pr.getParameters().put('StartDate', formattedStartDate);
        pr.getParameters().put('EndDate', formattedEndDate);
        pr.getParameters().put('ClaimType', selectedClaimType);
        return pr;
    }
    
    //Bank Names dropdown
    public List < SelectOption > getBankNames() {
        List < SelectOption > types = new List < SelectOption > ();
        types.add(new SelectOption('All', 'All Banks'));
        
        Schema.DescribeFieldResult fieldResult = Insolvency_Account__c.Client_Identifier__c.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : ples){
            if('Unknown' != ple.getLabel() && ple.getValue()){
                types.add(new SelectOption(ple.getLabel(), ple.getLabel()));    
            }
            // 5653 set value for goeasy as there is a difference between the api name and lable name of Esyfinancial (Client_Identifier__c)//
          /*  else if (ple.getValue()=='Easyfinancial') {
                types.add(new SelectOption('Goeasy','Goeasy')); 
            }*/ {
                
            }
            
        }   
        system.debug('5653 types'+types);  
        return types;
    }
    
    //Insolvency Type Dropdown
    public List < SelectOption > getInsolvencyType() {
        List < SelectOption > types = new List < SelectOption > ();
        types.add(new SelectOption('All', 'All'));
        
        Schema.DescribeFieldResult fieldResult = Insolvency_Account__c.Insolvency_Type__c.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : ples){
            types.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }      
        return types;
    }
    
    //Insolvency / Processing Status Dropdown
    public List < SelectOption > getInsolvencyStatus() {
        List < SelectOption > types = new List < SelectOption > ();
        types.add(new SelectOption('All', 'All'));
        
        Schema.DescribeFieldResult fieldResult = Insolvency_Account__c.Insolvency_Status__c.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : ples){
            types.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }      
        return types;
    }
    
    //Claim Type Dropdown
    public List < SelectOption > getClaimTypes() {
        List < SelectOption > types = new List < SelectOption > ();
        types.add(new SelectOption('All', 'All'));
        
        Schema.DescribeFieldResult fieldResult = Insolvency_Account__c.Claim_Type__c.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : ples){
            types.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }      
        return types;
    }
    
    //Asset Status Dropdown
    public List < SelectOption > getAssetStatus() {
        List < SelectOption > types = new List < SelectOption > ();
        types.add(new SelectOption('', 'Please Select'));
        
        Schema.DescribeFieldResult fieldResult = Insolvency_Account__c.Asset_Status__c.getDescribe();
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : ples)
        {
            types.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }      
        return types;
    }
    
    //Pagination Methods
    //Next List
    public PageReference nextBankAccountList(){
        list<Insolvency_Account__c> tempInsolAccList = getAllDuplicateAccountList();
        accWrappers = new list<AcctWrpper>(); 
        for(Insolvency_Account__c acct:tempInsolAccList){
            //accWrappers.add(new AcctWrpper(acct, baseUrl,false));
            accWrappers.add(new AcctWrpper(acct, false));
        }
        return null;
    }
    
    //user clicked beginning
    public PageReference Beginning() { 
      counter = 0;
      nextBankAccountList();
      return null;
    }
    
    //user clicked previous button
    public PageReference Previous() { 
        counter -= list_size;
        nextBankAccountList();
        return null;
    }

    //user clicked next button
    public PageReference Next() { 
        counter += list_size;
        nextBankAccountList();
        return null;
    }
    
    //user clicked end
    public PageReference End() { 
        counter = total_size - math.mod(total_size, list_size);
        nextBankAccountList();
        return null;
    }

    //this will disable the previous and beginning buttons
    public Boolean getDisablePrevious() { 
        if (counter>0) return false; else return true;
    }
    
    //this will disable the next and end buttons
    public Boolean getDisableNext() { 
        if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
        return total_size;
    }

    public Integer getPageNumber() {
        return counter/list_size + 1;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } 
        else {
            return (total_size/list_size);
        }
    }
    
    public Integer getTotalStartCount(){        
        return startNo+counter;
    }
    
    public Integer getTotalEndCount(){
        if(total_size>list_size+counter){
            return list_size+counter;
        }
        else{
            return total_size;
        }
    }
    
    //Utility methods to format dates
    public static String formatDate(Date d) {
        
        String ds = d.year()+'-';
        String m = String.valueOf(d.month());
        if(m.length()==1){
            ds += '0';
        }
        ds += m+'-';
        String dy = String.valueOf(d.day());
        if(dy.length()==1){
            ds += '0';
        }
        ds +=dy;
        
        return ds;
    }
    
    //Utility methods to format dates
    /*
    public static List<String> converStringToStringList(String selectedProcessingStatus) {
        
        List<String> selectedProcessingStatusList = new List<String>();
        selectedProcessingStatus = selectedProcessingStatus.remove('[');
        selectedProcessingStatus = selectedProcessingStatus.remove(']');
        List<String> tempSelectedProcessingStatusList = selectedProcessingStatus.split(',');
        for(String tempSelectedProcessingStatus : tempSelectedProcessingStatusList){
            System.debug('Value is = 1'+tempSelectedProcessingStatus+'2');
            selectedProcessingStatusList.add(tempSelectedProcessingStatus.trim());
        }
        
        return selectedProcessingStatusList;
    }
    */
    
    //Wrapper class 
    public class AcctWrpper{
        public Insolvency_Account__c acc{get;set;}
        public String accLink {get;set;}
        public string insolLink{get;set;}
        public boolean isSelected {get; set;}
        
        /*
        public AcctWrpper(Insolvency_Account__c acc, String baseUrl){
            this.acc = acc;
            this.accLink = baseUrl + '/' + acc.Id;   
            this.insolLink = baseUrl + '/' + acc.Insolvency__r.Id;
        }
        */
        
        /*
        public AcctWrpper(Insolvency_Account__c acc, String baseUrl, boolean sel){
            this.acc = acc;
            this.accLink =  '/' + acc.Id;   
            this.insolLink =  '/' + acc.Insolvency__r.Id;
            this.isSelected = sel;
        }
        */
        
        public AcctWrpper(Insolvency_Account__c acc, boolean sel){
            this.acc = acc;
            this.accLink =  '/' + acc.Id;   
            this.insolLink =  '/' + acc.Insolvency__r.Id;
            this.isSelected = sel;
        }
    }
}