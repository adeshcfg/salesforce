/**************************************************************************************************
 *
 *  Class:   POCDocController
 *
 *  @description : This class implemets functionality to provide user in generating Poc Pacage data of an insolvancy account
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 
 *************************************************************************************************/
public class POCDocController{
    //Collection
    //map to store french translation of POCPackageSettings in english 
    public map<String, String> mapPOCPackageSettingTranslation{get;set;}
    
    public Insolvency_Account__c insolvAcc {set;get;}
    public PoC_Package_Settings__c pocPackage{set;get;}
    
    public Remittance_Group_Mapping_For_PoC__c remGroupMap{set;get;}
    public Boolean isAnyException {set;get;}
    public String insolAccName {set;get;}
   
    // Boolean check for paragraphs
    public Boolean unSecClaim {set;get;}
    public Boolean dontClaim {set;get;}
    public Boolean claimAmount {set;get;}
    public Boolean claimOfLess {set;get;}
    public Boolean secureClaim {set;get;}
    public Boolean copyOfReport {set;get;}
    public Boolean claimRight {set;get;}
    public Boolean claimByFarmers {set;get;}
    public Boolean claimByWage{set;get;}
    public Boolean claimForCustomer{set;get;}
    
    public Boolean claimBySubSec813{set;get;}
    public Boolean claimBySubSec814{set;get;}
    public Boolean claimAgnstDirector{set;get;}
    
    public Boolean voteForAcceptance {set;get;}
    public Boolean voteAgainstAcceptance {set;get;}
    public Boolean meetingOfCredits {set;get;}
     
    // Boolean checks for sections
    public Boolean form31{set;get;}
    public Boolean form37{set;get;}
    public Boolean statementOfAccount{set;get;}
    public Boolean amendedPOCcheck{get;set;}
    //Constants
    public static final String POC_DOC_DESCRIPTION = 'PoC Document';
    public String formattedDate{get;set;}  
    public String formattedDateToday{get;set;}
    public String formattedLastpaymentDate{get;set;}
    public String formattedDateTodayHeader{get;set;}
    
    //Language options French Translation
    public string language{get;set;}
    public string pageName{get;set;}
    
    
    public POCDocController(){
        system.debug('pageName@@'+pageName);
        isAnyException = false;
        canaccedeError = false;
        canaccedeErrorMsg = '';
        amendedPOCcheck = false;
        EligibleVoting = true;
        AssetError = false;
        AssetErrorMsg = '';
        mapPOCPackageSettingTranslation = new map<String, String>();
        mapPOCPackageSettingTranslation.put('The Bank of Nova Scoatia', 'LA BANQUE DE NOUVELLE-ÉCOSSE');
        mapPOCPackageSettingTranslation.put('Bankruptcy', 'la faillite');
        mapPOCPackageSettingTranslation.put('Consumer Proposal', 'Proposition de Consomateur');
        mapPOCPackageSettingTranslation.put('Division 1 Proposal', 'Proposition de la division 1');
        
        try{ 
            
            // Add those two properties in your Apex controller
     Map<Integer, String> frenchDates = new Map<Integer, String>();
        frenchDates.put(1, 'Janvier');
        frenchDates.put(2, 'Février');
        frenchDates.put(3, 'Mars');
        frenchDates.put(4, 'Avril');
        frenchDates.put(5, 'Mai');
        frenchDates.put(6, 'Juin');
        frenchDates.put(7, 'Juillet');
        frenchDates.put(8, 'Août');
        frenchDates.put(9, 'Septembre');
        frenchDates.put(10, 'Octobre');
        frenchDates.put(11, 'Novembre');
        frenchDates.put(12, 'Décembre');


            insolvAcc = [SELECT Id, Name, Secured_Name__c,Business_Account__c,Insolvency_Type__c,
                                //Debtor_1_Estate_Number__c, Debtor_2_Estate_Number__c,
                                Insolvency__r.Name, Insolvency__r.Debtor_2_Estate_Number__c,
                                Insolvency__r.Eligible_For_Voting_Decision__c,
                                Insolvency__r.Voting_Decision__c,
                                Insolvency__r.Debtor_1_Mailing_City__c ,Insolvency__r.Debtor_1_Mailing_State_Province__c,
                                //Added for DebtNext Changes
                                Insolvency__r.Insolvency_Type__c,Portfolio_Group_Name__c,Vendor_Orginator__c,
                                Portfolio_Name_Lookup__c, Investment_Group__c,
                                Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Trustee__r.BillingCity,
                                Insolvency__r.Trustee__r.BillingState,Insolvency__r.Trustee__r.BillingPostalCode,
                                Insolvency__r.Trustee__r.BillingCountry,
                                //Added for Affirm PoC
                                Insolvency__r.Debtor_1_Mailing_Street__c,Insolvency__r.Debtor_2_Mailing_Street__c,
                                Insolvency__r.Debtor_2_Mailing_City__c,
                                Insolvency__r.Debtor_1_Mailing_Postal_Code__c,Insolvency__r.Debtor_2_Mailing_Postal_Code__c,
                                //Debtor_1_Court_Number__c, Debtor_2_Court_Number__c,
                                Insolvency__r.Debtor_1_Court_Number__c, Insolvency__r.Debtor_2_Court_Number__c, 
                                Insolvency__r.Court_District_Name__c, Insolvency__r.Court_Division_Number__c, Insolvency__r.Court_Province__c,
                                Insolvency__r.Insolvency_Date__c, Secured_Asset_Amount__c,Security_Description__c,Vehicle_Identification_Number__c,
                                Voting_Letter_Comments__c, Claim_Type__c, Claim_Amount__c,Amended_Claim_Flag__c,
                                Insolvency__r.Trustee__r.Name, Insolvency__r.Trustee__r.Parent.Name, Client_Identifier__c,
                                Last_Payment_Date__c, Last_Payment_Amount__c, Interest_Rate__c, Insolvency_Status__c,Asset_Status__c,                               
                                Insolvency__r.Debtor_1_First_Name__c, Insolvency__r.Debtor_1_Last_Name__c, Insolvency__r.Debtor_1_Middle_Name__c, 
                                Insolvency__r.Debtor_2_First_Name__c, Insolvency__r.Debtor_2_Last_Name__c, Insolvency__r.Debtor_2_Middle_Name__c,Bank_Name__c, 
                                Statements_Required__c, Proof_of_Claim_Required__c, Voting_Options__c ,Include_Voting_Letter__c, Amended_PoC_Created_Date__c, PoC_Created_Date__c, Account_Type__c   
                                FROM Insolvency_Account__c 
                                WHERE Id =: ApexPages.currentPage().getParameters().get('Id')];
                                
         Datetime dateNow = Datetime.now();
         if(insolvAcc.Insolvency__r.Insolvency_Date__c!=null){
         formattedDate= String.valueOf(' '+frenchDates.get(insolvAcc.Insolvency__r.Insolvency_Date__c.month()) 
                                       + ' '+String.valueOf(insolvAcc.Insolvency__r.Insolvency_Date__c.year()));
            }
          
            
            formattedDateToday = String.valueOf(' '+frenchDates.get(dateNow.month()) 
                                       + ' '+String.valueOf(dateNow.year()));
          if(insolvAcc.Last_Payment_Date__c!=null){
            formattedLastpaymentDate = String.valueOf(String.valueOf(insolvAcc.Last_Payment_Date__c.month())+' '+frenchDates.get(insolvAcc.Last_Payment_Date__c.month()) 
                                       + ' '+String.valueOf(insolvAcc.Last_Payment_Date__c.year()));
            }
            formattedDateTodayHeader = String.valueOf(' '+frenchDates.get(dateNow.month()) + ' '+dateNow.day()+' '+String.valueOf(dateNow.year()));
            // Read poc Package custom setting to fetch related data
            pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
            
            system.debug('Custom setting data : ' + pocPackage);
            //Fetch first 3 letters of Portfolio Group Name
            //String portGroupMapShort = LEFT(insolvAcc.Portfolio_Group_Name__c,3);
            if(insolvAcc.Portfolio_Group_Name__c != null){
                String portGroupMapShort = insolvAcc.Portfolio_Group_Name__c.LEFT(3);
                // Read Remittance group mapping custom setting to fetch related data
                remGroupMap = (Remittance_Group_Mapping_For_PoC__c)Remittance_Group_Mapping_For_PoC__c.getValues(portGroupMapShort);
             
            }
            //read whether to display or not sections
            //statementOfAccount = insolvAcc.Statements_Required__c;
            statementOfAccount = insolvAcc.Proof_of_Claim_Required__c;
            form31 = insolvAcc.Proof_of_Claim_Required__c;
            //form37 = insolvAcc.Include_Voting_Letter__c;
            if('Canaccede' == insolvAcc.Client_Identifier__c && 'Bankruptcy' == insolvAcc.Insolvency__r.Insolvency_Type__c){
                form37 = false;
            }
            else{
                form37 = insolvAcc.Include_Voting_Letter__c;
            }
            
            //Default checks for paragraphs
            copyOfReport = true; 
            if(insolvAcc.Voting_Options__c  == 'Vote Accept'){
                voteForAcceptance = true;
            }else if(insolvAcc.Voting_Options__c  == 'Vote: Decline - No Meeting Requested'){
                voteAgainstAcceptance = true;
            }else if(insolvAcc.Voting_Options__c  == 'Vote: Decline - With Creditor Meeting Request'){
                meetingOfCredits = true;
            }
            if(insolvAcc.Claim_Type__c == 'Secured'){
                secureClaim = true;
            }
            else if(insolvAcc.Claim_Type__c == 'Unsecured'){
                unSecClaim = true;
                dontClaim = true;  
            }
            if(insolvAcc.PoC_Created_Date__c <> null && insolvAcc.Amended_Claim_Flag__c == False){
                amendedPOCcheck = true; 
            }
            if(insolvAcc.Proof_of_Claim_Required__c ==false){
                pocDocError = 'Sorry, you cannot generate a proof of claim unless "Proof of Claim Required" checkbox is checked on this account';
            }
            if(insolvAcc.Insolvency_Status__c != 'PoC Details Provided' ){
                statusError = 'Sorry, you cannot generate a proof of claim unless this account is in "PoC Details Provided" status';
            }
            
            /* Commented the code on 19.06.20 to revert changes
             * if((null == insolvAcc.Insolvency__r.Eligible_For_Voting_Decision__c  || insolvAcc.Insolvency__r.Eligible_For_Voting_Decision__c == false)){
                                                                                         
             EligibleVotingError = 'Sorry, you cannot generate a proof of claim when related Insolvency is not Eligible for Voting';
             EligibleVoting=false;
            }*/
            
            // updated if condition only to check voting decision 19.06.20
            system.debug('voting decision : '+insolvAcc.Insolvency__r.Voting_Decision__c);
            system.debug('insolvency acc : '+insolvAcc.Insolvency__c);
            if(insolvAcc.Insolvency__r.Voting_Decision__c=='Needs Manual Review'){
                EligibleVotingError = 'Sorry, you cannot generate a proof of claim when Voting Decision is Needs Manual Review';                                                                             
                EligibleVoting=false; 
            }
            if('Canaccede' == insolvAcc.Client_Identifier__c && insolvAcc.Vendor_Orginator__c == null){
                canaccedeError = true;
                canaccedeErrorMsg = 'Sorry, you cannot generate a proof of claim unless this account has Vendor value populated on the account';
            }
            system.debug('Name of Bank__: '+insolvAcc.Client_Identifier__c);
            
             if(insolvAcc.Asset_Status__c !='Purchased' && insolvAcc.Asset_Status__c !='Debt Purchase' && insolvAcc.Asset_Status__c !='Bulk Purchased' && insolvAcc.Asset_Status__c !='Duplicate Purchased')
            {
                AssetError = true;
                AssetErrorMsg = 'Sorry, you cannot generate a proof of claim unless this account is in Purchased / Debt Purchase / Bulk Purchased / Duplicate Purchased status';     
                 
            }            
            if('Canaccede' == insolvAcc.Client_Identifier__c && ( 
                    insolvAcc.Portfolio_Group_Name__c == null || insolvAcc.Portfolio_Name_Lookup__c == null || insolvAcc.Investment_Group__c == null)){
                canaccedeError = true;
                canaccedeErrorMsg = 'Sorry, you cannot generate a proof of claim unless this account has Vendor value, Portfolio Group Name, Portfolio Name and Investment Group Name populated on the account';
            }
            
            if('Fidem' == insolvAcc.Client_Identifier__c && ( 
                    insolvAcc.Portfolio_Group_Name__c == null || insolvAcc.Portfolio_Name_Lookup__c == null || insolvAcc.Investment_Group__c == null)){
                canaccedeError = true;
                canaccedeErrorMsg = 'Sorry, you cannot generate a proof of claim unless this account has Portfolio Group Name, Portfolio Name and Investment Group Name populated on the account';
            }
            //System.debug('A:' + insolvAcc.Vendor_Orginator__c + 'C' + insolvAcc.client_identifier__c);
            //System.debug('B:' + insolvAcc.Portfolio_Group_Name__c + 'D');
        
            //Check trustee is Service Nova Scotia or not for Account masking
            List<String> trusteeCheckList = new List<String>();
            String idWithAccountStatement = pocPackage.Account_Statement_Not_Allowed__c;
            trusteeCheckList = idWithAccountStatement.split(',');
            Boolean isTrusteeSerNovSco = false;
            for(String trusteeCheck: trusteeCheckList){
                if(insolvAcc.Insolvency__r.Trustee__r.ParentId == trusteeCheck){
                    isTrusteeSerNovSco = true;
                }
                
            } 
            if(isTrusteeSerNovSco == true){
                insolAccName = insolvAcc.Secured_Name__c;
            }
            else{
                insolAccName  = insolvAcc.Name;
            }
        }
        Catch(Exception ex){
            system.debug('exception'+ex.getStackTraceString());
            isAnyException = true;
        }
    }
    public String pocDocError{set;get;}
    public String statusError{set;get;}
    public Boolean AssetError{set;get;}
    public String AssetErrorMsg{set;get;}
    public Boolean canaccedeError{set;get;}
    public String canaccedeErrorMsg{get;set;}
    public String EligibleVotingError{set;get;}
    public Boolean EligibleVoting{set;get;}
    /* Method used to save poc package as pdf to insolvancy account */
    public PageReference savePOCDoc() {
        system.debug('language: '+language);
        system.debug('insolvAcc.Client_Identifier__c: '+insolvAcc.Client_Identifier__c);
        // Read pdf and pass all necessary parameters to pocdoc page
        PageReference pdf;   
        
        //create PDF for POCDoc based on client identifier and language selected on page
        if(insolvAcc.Client_Identifier__c =='Canaccede'){
            if(language == 'en_US'){
                pdf = Page.POCDocDataCanaccede;     
            }
            if(language == 'fr'){
                pdf = Page.POCDocDataFrenchCanaccede;     
            }
        }
        else if(insolvAcc.Client_Identifier__c =='Fidem'){
            pdf = Page.POCDocDataAffirm; 
        }
        else if(insolvAcc.Client_Identifier__c =='Canadian Tire'){
            if(language == 'en_US'){
                system.debug('pdf in english');
                pdf = Page.POCDocDataCanadianTire;     
            }
            if(language == 'fr'){
                system.debug('pdf in french');
                pdf = Page.POCDocDataFrenchCanadianTire;     
            }
        }else if(insolvAcc.Client_Identifier__c =='Goeasy'){
            if(language == 'en_US'){
                system.debug('pdf in english');
                pdf = Page.POCDocDataEasyFinancial;     
            }
            if(language == 'fr'){
                system.debug('pdf in french');
                pdf = Page.POCDocDataFrenchEasyFinancial;     
            }
        }
        else{
            system.debug('Scotia Bank');
            if(language == 'en_US'){
                system.debug('pdf in english');
                pdf = Page.POCDocData;     
            }
            if(language == 'fr'){
                system.debug('pdf in french');
                pdf = Page.POCDocDataFrenchStream;     
            }
        }
        system.debug('IDDD: '+ApexPages.currentPage().getParameters().get('Id'));
        system.debug('pdf: '+pdf);
        pdf.getParameters().put('id',ApexPages.currentPage().getParameters().get('Id'));
        pdf.getParameters().put('statementOfAccount', String.valueOf(statementOfAccount));
        pdf.getParameters().put('votingLetter', String.valueOf(form37));
        pdf.getParameters().put('proofOfClaim', String.valueOf(form31));
        
        pdf.getParameters().put('unSecClaim', String.valueOf(unSecClaim));
        pdf.getParameters().put('dontClaim', String.valueOf(dontClaim));
        pdf.getParameters().put('claimAmount', String.valueOf(claimAmount));
        pdf.getParameters().put('claimOfLess', String.valueOf(claimOfLess));
        pdf.getParameters().put('secureClaim', String.valueOf(secureClaim));
        pdf.getParameters().put('claimRight', String.valueOf(claimRight));
        
        pdf.getParameters().put('claimByFarmers', String.valueOf(claimByFarmers));
        pdf.getParameters().put('claimByWage', String.valueOf(claimByWage));
        pdf.getParameters().put('claimForCustomer', String.valueOf(claimForCustomer));
        pdf.getParameters().put('claimBySubSec813', String.valueOf(claimBySubSec813));
        pdf.getParameters().put('claimBySubSec814', String.valueOf(claimBySubSec814));
        pdf.getParameters().put('claimAgnstDirector', String.valueOf(claimAgnstDirector));
        pdf.getParameters().put('copyOfReport', String.valueOf(copyOfReport));
        pdf.getParameters().put('voteForAcceptance', String.valueOf(voteForAcceptance));
        pdf.getParameters().put('voteAgainstAcceptance', String.valueOf(voteAgainstAcceptance));
        pdf.getParameters().put('meetingOfCredits', String.valueOf(meetingOfCredits));
        
        
        // Create attachment
        Attachment attach = new Attachment();       
        Blob body;
        try {
            if (!Test.IsRunningTest()){
                body = pdf.getContent();
            }
            else{
                body = Blob.valueOf('Test');
                
            }
        } catch (Exception ex) {
            body = Blob.valueOf('Error : ' + ex);
            isAnyException = true;
            handleException(ex);
            return null;
        }
        
        attach.Body = body;
        DateTime d = Date.Today() ;
        String dateStr =  d.formatGMT('yyyy-MM-dd') ;
        attach.Name = (insolvAcc.Amended_Claim_Flag__c ?'Amended PoC - ' :'PoC - ')+dateStr +' - '+insolvAcc.Insolvency__r.Name + ' - '+ insolAccName + ' - '+ (insolvAcc.Insolvency__r.Debtor_1_First_Name__c != null? insolvAcc.Insolvency__r.Debtor_1_First_Name__c : '')+' '+(insolvAcc.Insolvency__r.Debtor_1_Last_Name__c != null ? insolvAcc.Insolvency__r.Debtor_1_Last_Name__c: '')+'.pdf';
        attach.IsPrivate = false;
        attach.Description = POC_DOC_DESCRIPTION;
        attach.ParentId = insolvAcc.Id;
        insert attach;
        
        /*
        //Don't run validation rules
        Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c FOR UPDATE];
        
        // Read and store actuall value about running validation rule
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        */
        
        //Don't run InsolvencyAccountTrigger
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        
        try{
            // Update status value of Insolvancy account
            insolvAcc.Insolvency_Status__c = 'PoC Package Generated';
            insolvAcc.Insolvency_Status_Last_Changed__c = System.now();            
            
            if(insolvAcc.PoC_Created_Date__c== null){
                insolvAcc.PoC_Created_Date__c = system.now();
            }
            else{
                insolvAcc.Amended_PoC_Created_Date__c = system.now();
            }
            
            update insolvAcc;
            
            //update the No of POC Details Provided on Insolvency for Scotia
            Id insolvencyId = insolvAcc.Insolvency__c;
            Insolvency__c insolvencyObj = new Insolvency__c(Id = insolvencyId);
            insolvencyObj.Number_of_POC_Details_Provided_Accounts__c = 
            database.countQuery('select count() from insolvency_account__c where insolvency_status__C = \'PoC Details provided\''+
                               +'and Insolvency__c = :insolvencyId and (RecordType.DeveloperName = \'Scotia_Bank_Insolvency_Account\' OR RecordType.DeveloperName = \'SDA_Insolvency_Account\' OR RecordType.DeveloperName = \'SPL_Insolvency_Account\' OR RecordType.DeveloperName = \'Fairstone_Insolvency_Account\' OR RecordType.DeveloperName = \'Canadian_Tire_Insolvency_Account\')');
            InsolvencyTriggerHandler.runInsolvencyTrigger = false;
            update insolvencyObj;
            InsolvencyTriggerHandler.runInsolvencyTrigger = true;
            
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            */
            
            // Revert back custom setting value with previous value
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            
        }catch(Exception ex){
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            */
            isAnyException = true;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            handleException(ex);
        }
        
        amendedPOCcheck = false;
        
        system.debug('amendedPOCcheck ::: ' + amendedPOCcheck);
        return null;
    }    
    
    public void handleException(Exception ex){
        Insolvency_Error__c inslErr = new Insolvency_Error__c();
            inslErr.Insolvency_Account__c = insolvAcc.Id;
            inslErr.Action__c = 'PoC Generation';
            inslErr.Error__c = 'Exception: ' + ex.getTypeName();
            inslErr.Error__c += '\nMessage: ' + ex.getMessage();
            inslErr.Error__c += '\nStack trace:\n' + ex.getStackTraceString();
            
            try{
                insert inslErr;
            }
            catch(Exception inslErrEx){
                system.debug('inslErr Message :'+inslErrEx.getMessage());
            }
    }
    
    //change the language logic from POCDoc page
    public PageReference changeLanguage(){
        system.debug('language: '+language);
        system.debug('pageName: '+pageName);
        
        if(language == 'fr'){
            system.debug('french');
            PageReference pageRef;
            if(pageName == 'Canaccede'){
                pageRef = new PageReference('/apex/POCDocFrenchCanaccedePreview?Id='+insolvAcc.Id);
                pageRef.setRedirect( true ); 
            }
            else if(pageName == 'CanadianTire'){
                pageRef = new PageReference('/apex/POCDocFrenchCanadianTirePreview?Id='+insolvAcc.Id);
                pageRef.setRedirect( true ); 
            }
            else if(pageName == 'Goeasy'){
                pageRef = new PageReference('/apex/POCDocDataFrenchEasyFinancial?Id='+insolvAcc.Id);
                pageRef.setRedirect( true ); 
            }
            else{
                 system.debug('here');
                 pageRef = new PageReference('/apex/POCDocFrenchStreamPreview?Id='+insolvAcc.Id);
                 pageRef.setRedirect( true ); 
            }
            system.debug('pageRef: '+pageRef);
            return pageRef;
        }
        else{
            system.debug('english');
            PageReference pageRef;
            if(pageName == 'Canaccede'){
                pageRef = new PageReference('/apex/POCDocCanaccede?Id='+insolvAcc.Id);
                pageRef.setRedirect( true ); 
            }
            else if(pageName == 'CanadianTire'){
                pageRef = new PageReference('/apex/POCDocCanadianTire?Id='+insolvAcc.Id);
                pageRef.setRedirect( true ); 
            }
            else if(pageName == 'Goeasy'){
                pageRef = new PageReference('/apex/POCDocDataEasyFinancial?Id='+insolvAcc.Id);
                pageRef.setRedirect( true ); 
            }
            else{
                 system.debug('english here Scotia');
                 pageRef = new PageReference('/apex/POCDoc?Id='+insolvAcc.Id);
                 pageRef.setRedirect( true ); 
            }            
            system.debug('pageRef: '+pageRef);
            return pageRef;
        }
    }
}