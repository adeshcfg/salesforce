/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to export All Duplicate Insolvency Accounts
 *  @author : A5E Consulting
 *  @date : 07/31/2018
 * 
 *************************************************************************************************/

public with sharing class AllDuplicateAccountsExportController {
    public list<Insolvency_Account__c> insolAccList{get; set;}
    public Insolvency_Account__c insolAcc{get; set;}
    public String accQry;
    public string selectedBankName;
    public string selectedInsolvencyType;
    public string selectedProcessingStatus;
    public string formattedStartDate;
    public string formattedEndDate;
    public String selectedClaimType;
    public List<String> duplicateNameList;
    public list<string> ignoreAcctNameList;
    
    public AllDuplicateAccountsExportController(){
        insolAcc = new Insolvency_Account__c();
        duplicateNameList = new List<String>();
        
        selectedBankName = ApexPages.CurrentPage().getParameters().get('BankName');
        selectedInsolvencyType = ApexPages.CurrentPage().getParameters().get('InsolvencyType');
        selectedProcessingStatus = ApexPages.CurrentPage().getParameters().get('ProcessingStatus');
        formattedStartDate = ApexPages.CurrentPage().getParameters().get('StartDate');
        formattedEndDate = ApexPages.CurrentPage().getParameters().get('EndDate');
        selectedClaimType = ApexPages.CurrentPage().getParameters().get('ClaimType');
        
        system.debug('selectedBankName ='+selectedBankName );
        system.debug('selectedInsolvencyType='+selectedInsolvencyType );
        system.debug('selectedProcessingStatus='+selectedProcessingStatus );
        system.debug('formattedStartDate='+formattedStartDate );
        system.debug('formattedEndDate='+formattedEndDate );
        system.debug('selectedClaimType='+selectedClaimType );
        
        //Get ignore Account Names List from custom setting
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        ignoreAcctNameList = new list<string>();
        string acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
        ignoreAcctNameList = acctNameCS.split(',');
        system.debug('ignoreAcctNameList : '+ignoreAcctNameList);
        
        getInsolAcounts();
    }
    
    public list<Insolvency_Account__c> getInsolAcounts(){
        List<String> accountNames = new List<String>();       
        
        List<String> selectedInsolvencyTypeList;
        if(String.isNotBlank(selectedInsolvencyType)){
            if(selectedInsolvencyType.contains('All')){
                selectedInsolvencyType = 'All';
            }
            else{
                selectedInsolvencyType = selectedInsolvencyType.remove('[');
                selectedInsolvencyType = selectedInsolvencyType.remove(']');
                selectedInsolvencyTypeList = selectedInsolvencyType.split(', ');
                System.debug('selectedInsolvencyTypeList size :'+selectedInsolvencyTypeList.size());
            }
        }
         
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
            }
            
        }
        
        //All accounts based on filters
        String accQry = 'Select id, Account_Number_Without_Space__c from Insolvency_Account__c where Insolvency__c!=null';
        
        //Bnk Names
        if(String.isNotBlank(selectedBankName) && selectedBankName!='All'){
            //accQry += ' AND Bank_Name__c =:selectedBankName';
            accQry += ' AND Client_Identifier__c =:selectedBankName';
        }
        
        //Check Date Criteria
        if(String.isNotBlank(formattedStartDate)){
            accQry += ' AND PoC_Created_Date__c >='+formattedStartDate+'T00:00:00.000+0000';
        }
        if(String.isNotBlank(formattedEndDate)){
            accQry += ' AND PoC_Created_Date__c <='+formattedEndDate+'T23:59:59.000+0000';
        }
        
        //Insolvency Type 
        if(String.isNotBlank(selectedInsolvencyType)){
            if(selectedInsolvencyType!='All'){
                if(selectedInsolvencyTypeList[0] != ''){
                    //accQry += ' AND Insolvency_Type__c in: selectedInsolvencyTypeList';
                    accQry += ' AND Insolvency__r.Insolvency_Type__c in: selectedInsolvencyTypeList';
                }
            }
        }
        
        //Insolvency Processing Status 
        if(String.isNotBlank(selectedProcessingStatus)){
            if(selectedProcessingStatus!='All'){
                if(selectedProcessingStatusList[0] != ''){
                    accQry += ' AND Insolvency_Status__c in: selectedProcessingStatusList';
                }
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
        //accQry += ' Order by CreatedDate Desc limit 50000';
        
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
        
        if(null!=results){
            for(AggregateResult aggres : results){           
                duplicateNameList.add((String)aggres.get('Account_Number_Without_Space__c')); 
            }
        }
         System.debug('duplicateNameList :'+duplicateNameList);
         
         insolAccList = AllDuplicateAccountList();
         return insolAccList;
    }
    
    public list<Insolvency_Account__c> AllDuplicateAccountList(){
        
        system.debug('ignoreAcctNameList =='+ignoreAcctNameList );
        system.debug('duplicateNameList=='+duplicateNameList);
        system.debug('selectedBankName=='+selectedBankName);
        
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
        query += ' order by Account_Number_Without_Space__c';
        
        return database.query(query);
    }
}