public class TrusteeAssignmentController{
    
    //Trustee Office Account record id
    Id trusteeOfficeRecordTypeId;
    
    //Related Insolvency record
    public Insolvency__c insolv {set;get;}
    
    public String companyName {set;get;}
    public String officeName {set;get;}
    public String streetAddress{set;get;}
    public String phoneNumber {set;get;}
    public String businessEmail {set;get;}
    public String fax{set;get;}
    public String cityAddress{set;get;}
    public String stateAddress{set;get;}
    public String postalCodeAddress{set;get;}
    public String countryAddress{set;get;}
    public Boolean activeTrusteesOnly{set;get;}
    
    //Search rEsults List
    public List<Account> accList {set;get;}
    
    public Id selectedAccountId{set;get;}
    public Boolean searchPerformed {set;get;}
    public Boolean trusteeUpdated{set;get;}
    
    //Phone Number Format
    private final String REGEX_PHONE_NUMBER = '^\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$';
    
    //Navigation variables
    public Integer counter = 0;//TO track the number of records parsed
    public Integer limitSize = 20;//Number of records to be displayed
    public Integer totalSize =0; //To Store the total number of records available
    public Integer gettotalSize (){
        return totalSize ;
    }
    public Integer getcounter(){
        return counter;
    }
    
    public Integer getlimitSize(){
        return limitSize;
    }
    
    public List<Account> accountsToShow{set;get;}
    
    //Constructor
    public TrusteeAssignmentController(ApexPages.StandardController controller) {
        accountsToShow = new List<Account>();
        
        insolv = (Insolvency__c)controller.getRecord();
        insolv = [SELECT Id, Trustee__c,Trustee__r.Name, Trustee__r.Parent.Name FROM Insolvency__c WHERE Id =: insolv.Id];
        
        trusteeOfficeRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Trustee Office' LIMIT 1].Id;
        if(insolv.Trustee__c != null){
            officeName = insolv.Trustee__r.Name;
            companyName = insolv.Trustee__r.Parent.Name;
        }
        
        accList = new List<Account>();
        searchPerformed = false;
    }   
    
    //Search Trustee based on filter criteria    
    public PageReference searchTrustee(){
        
        searchPerformed = true;
        accountsToShow = new List<Account>();
        //String dbQuery = 'SELECT Name, Account.Name, AccountId, Account.Phone, MobilePhone, OtherPhone, Phone, Account.BillingStreet, Account.BillingCity,Account.BillingState,Account.BillingPostalcode,Account.BillingCountry, MailingStreet, MailingCity, MailingState, MailingPostalcode, MailingCountry FROM Contact WHERE RecordTypeId =: trsuteeContactRecordTypeId ';
        String dbQuery = 'SELECT Id, Name, Parent.Name, Business_Email__c, Phone, Fax, BillingStreet, BillingCity, BillingState, BillingPostalcode, BillingCountry, Is_Active__c FROM Account WHERE RecordTypeId =: trusteeOfficeRecordTypeId';
        if(activeTrusteesOnly){
            dbQuery+= ' AND Is_Active__c = true';
        }
        List<String> searchFilters = new List<String>();
        List<String> optionalFilters = new List<String>();
        List<String> finalFilters = new List<String>();
        
        //Parent Company Name
        if(companyName != null && companyName.trim() != ''){
            searchFilters.add(' Parent.Name LIKE \'%'+String.escapeSingleQuotes(companyName)+'%\' ');
        }
        
        //Ofice Name
        if(officeName != null && officeName.trim() != ''){
            searchFilters.add(' Name LIKE \'%'+String.escapeSingleQuotes(officeName)+'%\' ');
        }
        
        //Office Phone Number
        if(!String.isBlank(phoneNumber)){
            String phone = phoneNumber;
            //Pattern phonePattern = Pattern.compile(REGEX_PHONE_NUMBER);
            //if(phonePattern.matcher(phoneNumber).matches() == false){
            //    return null;
            //}
            //optionalFilters.add('( Phone =: Phone )');
            optionalFilters.add('( Phone LIKE\'%' + Phone + '%\')');
        }
        
        //Office Street Address
        if(!String.isBlank(streetAddress)){
            optionalFilters.add('( BillingStreet LIKE\'%' + String.escapeSingleQuotes(streetAddress) + '%\')');
        }
        
        //Office Postal Code
        if(!String.isBlank(postalCodeAddress)){
            string postalCode = postalCodeAddress.deleteWhiteSpace();
            optionalFilters.add('( Billing_Postal_Code_without_Space__c LIKE\'%' + postalCode + '%\')');
        }
        
        //Office Email
        if(!String.isBlank(businessEmail )){
            optionalFilters.add('( Business_Email__c LIKE\'%' + businessEmail + '%\')');
        }
        
        //Office Fax
        if(!String.isBlank(fax)){
            optionalFilters.add('( Fax LIKE\'%' + fax + '%\')');
        }
        
        //Office City Address
        if(!String.isBlank(cityAddress)){
            optionalFilters.add('( BillingCity LIKE\'%' + String.escapeSingleQuotes(cityAddress) + '%\')');
        }
        
        //Office State Address
        if(!String.isBlank(stateAddress)){
            optionalFilters.add('( BillingState LIKE\'%' + String.escapeSingleQuotes(stateAddress) + '%\')');
        }
        
        if(!searchFilters.isEmpty()){
            String nameFilterString = String.join(searchFilters, ' AND ' );
            nameFilterString = '('+nameFilterString+')';
            finalFilters.add(nameFilterString);
        }
        
        if(!optionalFilters.isEmpty()){
            String optionalFilterString = String.join( optionalFilters, ' AND ' );
            finalFilters.add(optionalFilterString);
        }
        
        String finalFilterString =String.join(finalFilters, ' AND ');
        system.debug('======'+finalFilterString);
        
        if(!String.isBlank(finalFilterString)){
            dbQuery = dbQuery+' AND ('+finalFilterString+')';
        }
        dbQuery = dbQuery+' ORDER BY Name ASC LIMIT 50000';
        system.debug('dbQuery :'+dbQuery);
        accList = Database.query(dbQuery);
        
        //Store the total size
        totalSize = accList.size();
        
        Set<Id> accIds =new Set<Id>();
        for(Account accnt : accList){
            
            if(!String.isBlank(accnt.BillingCity) && !accIds.contains(accnt.Id)){
                accnt.BillingCity = accnt.BillingCity+', ';
                accIds.add(accnt.Id);
            }
        }
        
        //Intial adding of account to accountsToShow
        //check the total records are more than limitSize and assign the records
        if((counter+limitSize) <= totalSize){
            for(Integer i=0;i<limitSize;i++){
                accountsToShow.add(accList.get(i));
            }
        }
        else{
            for(Integer i=0;i<totalSize;i++){
                accountsToShow.add(accList.get(i));
            }
        }
        
        system.debug('counter+limitSize =='+counter+limitSize+' totalSize =='+totalSize);
        
        return null;
    }
    
    
    //Navigation methods
    //Begin    
    public void beginning(){
        
        accountsToShow.clear();
        counter = 0;
        if((counter + limitSize) <= totalSize){
       
            for(Integer i=0;i<limitSize;i++){
                accountsToShow.add(accList.get(i));
            }
        } 
        else{
       
            for(Integer i=0;i<totalSize;i++){
                accountsToShow.add(accList.get(i));
            }
        }
    }
    
    //Next Records
    public void next(){
        
        accountsToShow.clear();
        counter = counter+limitSize;
       
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter-1;i<(counter+limitSize);i++){
                accountsToShow.add(accList.get(i));
            }
        } 
        else{
            for(Integer i=counter;i<totalSize;i++){
                accountsToShow.add(accList.get(i));
            }
        }
    }
    
    //Previoius Records
    public void previous(){
   
        accountsToShow.clear();
        counter = counter-limitSize;       
        
        if((counter+limitSize) <= totalSize){
        for(Integer i=counter;i<(counter+limitSize); i++){
            accountsToShow.add(accList.get(i));
            }
        }
    }
    
    //Last Records
    public void last (){
        
        accountsToShow.clear();
       
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } 
        else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
        }
       
        for(Integer i=counter-1;i<totalSize-1;i++){
                accountsToShow.add(accList.get(i));
        }
    }
    
    //Disable Next Link
    public Boolean getDisableNext(){
   
        if((counter + limitSize) >= totalSize){
            return true;
        }           
        else{
            return false;
        }            
    }
   
    //Disable Previous Link
    public Boolean getDisablePrevious(){
   
        if(counter == 0){
            return true;
        }            
        else{
            return false;
        }   
    } 
    
    //Update Trustee_Contact and Trustee_Account 
    public void updateInsolvency(){
        if(selectedAccountId != null){
            insolv.Trustee__c= selectedAccountId;
        }
        system.debug('==='+selectedAccountId );
        InsolvencyTriggerHandler.runInsolvencyTrigger = false;
        
        try{
            update insolv;
            InsolvencyTriggerHandler.runInsolvencyTrigger = true;
            trusteeUpdated = true;
        }
        catch(Exception ex){
            system.debug('Ex==='+ex.getMessage());
            trusteeUpdated = false;
            Insolvency_Error__c inslErr = new Insolvency_Error__c();
            inslErr.Insolvency__c = insolv.Id;
            inslErr.Action__c = 'Trustee Assignment';
            inslErr.Error__c = 'Exception: ' + ex.getTypeName();
            inslErr.Error__c += '\nMessage: ' + ex.getMessage();
            inslErr.Error__c += '\nStack trace:\n' + ex.getStackTraceString();
            
            try{
                insert inslErr;
            }
            catch(Exception inslErrEx){
                system.debug('inslErr Message :'+inslErrEx.getMEssage());
            }
        }        
    }    
    
    //Account selected
    public PageReference accountSelected(){
        selectedAccountId = ApexPages.currentPage().getParameters().get('accid');
        system.debug('===='+selectedAccountId);
        return null;
    }
}