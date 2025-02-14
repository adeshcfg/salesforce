public class GenerateDepositSlipRecordsController {
    
    public String type { get; set; }
    public Boolean depositSlipAvailable{get;set;}
    public Boolean showFinalDepositSlipButton{get;set;}
    public static List<Insolvency_Payment__c> insolvVardePayments{get;set;}
    public static List<Unallocated_Payment__c> unAllocPayList{get;set;}
    public static List<String> relatedVardeRemittanceIDs = new List<String>();
    public static List<Insolvency_payment__c> listCIHIAccounts{get; set;}
    public static List<Insolvency_payment__c> listVardeCDAccounts{get; set;}
    public static List<Insolvency_payment__c> listFortressAccounts{get; set;}
    public static List<Insolvency_payment__c> listEquitableAccounts{get; set;}
    public static List<Insolvency_payment__c> listVardeAccounts{get; set;}
    List<Insolvency_Payment__c> insolvPayToUpdate = new List<Insolvency_Payment__c>();
    Map<Id, Double> accountInsolvencyPaymentMap = new Map<Id, Double>();
    Application_Config_Settings__c appConfigFinal;//=Application_Config_Settings__c.getOrgDefaults();
    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc {set;get;}
    public String action = 'createPdfAttachment';
    
    public GenerateDepositSlipRecordsController(){
        appConfigFinal = [SELECT Final_Deposit_Slip__c, CCS_Final_Deposit_Slip__c, Do_Not_Run_Payment_Validation__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
        
        insolvVardePayments = new List<Insolvency_Payment__c>();
        unAllocPayList = new List<Unallocated_Payment__c>();
        insolvPayToUpdate = new List<Insolvency_Payment__c>();
        //Application_Config_Settings__c appConfigFinal = Application_Config_Settings__c.getOrgDefaults();
        showFinalDepositSlipButton = false;
        if(appConfigFinal.Final_Deposit_Slip__c == system.today()){
            showFinalDepositSlipButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Deposit slip is locked for the day'));
            return;
        }
        if(checkJobCompletion()){
            showFinalDepositSlipButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Deposit slip is in progress. Notification will be sent over Email.'));
            return;
        }
        List<Deposit_Slip__c> depositSlip = [SELECT Id, Name FROM Deposit_Slip__c WHERE CreatedDate = TODAY AND recordType.developerName = 'Insolvency_Deposit_Slip'];
        
        if(depositSlip.isEmpty()){
            depositSlipAvailable = false;
        }else{
            depositSlipAvailable = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Deposit Slip already created today : <a href="'+System.Url.getSalesforceBaseURL().toExternalForm() +'/'+depositSlip[0].Id+'" target="_blank">'+depositSlip[0].Name+'</a>'));
            
        }
        
    }
    @RemoteAction
    public static Boolean checkJobCompletion(){
        List<AsyncApexJob> listofAsyncJob = [select id,ApexClass.Name,Status, ExtendedStatus, MethodName, CreatedDate from AsyncApexJob where ApexClass.name = 'GenerateDepositSlipQueueable' and createddate = today and status = 'Queued'];
        return !listofAsyncJob.isEmpty();
    }
    public void generateDepositSlip(){
        
        DateTime LastDepositSlipCreatedDate = LastDepositSlipCreatedDate();
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where lastmodifiedDate >= :LastDepositSlipCreatedDate
                                              AND Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        if(listAggregateResults.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records available for Deposit Slip'));
            return;
        }
        //Delete today's old deposit slip
        List<Deposit_slip__c> listDepositSlip = [select id from Deposit_slip__c where createdDate = today AND recordType.developerName = 'Insolvency_Deposit_Slip'];
        DepositSlipTriggerHandler.runDepsoitSlipTrigger = False;
        database.delete(listDepositSlip, false);
        DepositSlipTriggerHandler.runDepsoitSlipTrigger = True;
        
        //Generate new deposit slip
        Deposit_Slip__c deposit = new Deposit_Slip__c();
        deposit.recordTypeId = [select id from RecordType where SobjectType = 'Deposit_Slip__C' and name like '%Insolvency%'].id;
        insert deposit;
        Boolean isError = false;
        
        Boolean flagCCL = false;
        Boolean flagETC = false;
        deposit.CIML_156_Total_Cheque__c = 0;
        deposit.CIML_156_Total_Amount__c = 0.0;
        
        if(listAggregateResults.size() > 0){
            System.enqueueJob(new GenerateDepositSlipQueueable(listAggregateResults, deposit, LastDepositSlipCreatedDate, appConfigFinal, action));
        }
        if(checkJobCompletion()){
            showFinalDepositSlipButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Deposit slip is in progress. Notification will be sent over Email.'));
            return;
        }
    }
    
    // Create attachment
    public static void createAttachment(Blob body, String depositSlipType, Id depositId){
        Attachment attach = new Attachment(); 
        DateTime d = Date.Today() ;
        String dateStr =  d.formatGMT('yyyy-MM-dd') ;
        attach.Body = body;
        attach.Name = depositSlipType+' - '+dateStr + '.pdf';
        attach.IsPrivate = false;
        attach.Description = '';
        attach.ParentId = depositId;
        insert attach;
    }
    
    //change Id's to String of list
    public static List<String> idToStringConvert(List<String> listOfID){
        List<String> listString = new List<String>();
        for(String idString : listOfID){
            listString.add('\'' + idString + '\'');
        }
        
        return listString;
    }
    
    public static DateTime lastDepositSlipCreatedDate(){
        List<Deposit_Slip__c> lastDepositSlip = [SELECT Id, Name, createdDate FROM Deposit_Slip__c WHERE CreatedDate <> TODAY AND recordType.developerName = 'Insolvency_Deposit_Slip' ORDER BY createdDate DESC];
        if(lastDepositSlip.size() > 0){
            return lastDepositSlip[0].createdDate;
        }else{
            system.debug(system.TODAY());
            return system.TODAY();
        }
    }
    
    public static String strCreatedDate(DateTime createdDateToCovert){
        //2019-01-02T11:15:42.000+0000
        String strDate = '' + createdDateToCovert;
        strDate = strDate.replace(' ', 'T');
        strDate += '.000+0000';
        
        return strDate;
    }
    public void finalDepositSlip(){
        
        List<Deposit_Slip__c> todayDepositSlip = [SELECT Id, Name, createdDate FROM Deposit_Slip__c WHERE CreatedDate = TODAY AND recordType.developerName = 'Insolvency_Deposit_Slip' ORDER BY createdDate DESC];
        System.debug('TodayDepositSlip---'+todayDepositSlip);
        if(todayDepositSlip.size()>0){
            showFinalDepositSlipButton = true;
            appConfigFinal.Final_Deposit_Slip__c = system.TODAY();
            update appConfigFinal;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Deposit slip is locked for the day'));
        }
        
    }
}