public class GenerateDepositSlipProductController {
    
    public String type { get; set; }
    public Boolean depositSlipAvailable{get;set;}
    public Boolean showFinalDepositSlipButton{get;set;}
    public static List<Product_Payments__C> insolvVardePayments{get;set;}
    public static List<Unallocated_Payment__c> unAllocPayList{get;set;}
    public static List<String> relatedVardeRemittanceIDs = new List<String>();
    public static List<Product_Payments__C> listCIHIAccounts{get; set;}
    public static List<Product_Payments__C> listVardeCDAccounts{get; set;}
    public static List<Product_Payments__C> listFortressAccounts{get; set;}
    public static List<Product_Payments__C> listEquitableAccounts{get; set;}
    public static List<Product_Payments__C> listVardeAccounts{get; set;}
    List<Product_Payments__C> insolvPayToUpdate = new List<Product_Payments__C>();
    Map<Id, Double> accountInsolvencyPaymentMap = new Map<Id, Double>();
    Application_Config_Settings__c appConfigFinal;//==Application_Config_Settings__c.getOrgDefaults();
    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc {set;get;}
    
    public GenerateDepositSlipProductController(){
        
        appConfigFinal = [SELECT CCS_Final_Deposit_Slip__c, Do_Not_Run_Payment_Validation__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
        
        insolvVardePayments = new List<Product_Payments__C>();
        unAllocPayList = new List<Unallocated_Payment__c>();
        insolvPayToUpdate = new List<Product_Payments__C>();
        //Application_Config_Settings__c appConfigFinal = Application_Config_Settings__c.getOrgDefaults();
        showFinalDepositSlipButton = false;
        if(appConfigFinal.CCS_Final_Deposit_Slip__c == system.today()){
            showFinalDepositSlipButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Deposit slip is locked for the day'));
            return;
        }
        
        List<Deposit_Slip__c> depositSlip = [SELECT Id, Name FROM Deposit_Slip__c WHERE LastModifiedDate = TODAY AND recordType.developerName = 'CCS_Deposit_Slip'];
        
        if(depositSlip.isEmpty()){
            depositSlipAvailable = false;
        }else{
            depositSlipAvailable = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Deposit Slip already created today : <a href="'+System.Url.getSalesforceBaseURL().toExternalForm() +'/'+depositSlip[0].Id+'" target="_blank">'+depositSlip[0].Name+'</a>'));
            
        }
        
    }
    
    public void generateDepositSlip(){
        
        DateTime LastDepositSlipCreatedDate = LastDepositSlipCreatedDate();
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where lastmodifiedDate >= :LastDepositSlipCreatedDate
                                              AND Status__c = 'Processed'
                                              AND recordType.developerName = 'CCS_Dividend'
                                              AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        if(listAggregateResults.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records available for Deposit Slip'));
            return;
        }
        //Delete today's old deposit slip
        List<Deposit_slip__c> listDepositSlip = [select id from Deposit_slip__c where createdDate = today AND recordType.developerName = 'CCS_Deposit_Slip'];
        DepositSlipTriggerHandler.runDepsoitSlipTrigger = False;
        database.delete(listDepositSlip, false);
        DepositSlipTriggerHandler.runDepsoitSlipTrigger = True;
        
        //Generate new deposit slip
        Deposit_Slip__c deposit = new Deposit_Slip__c();
        deposit.recordTypeId = [select id from RecordType where SobjectType = 'Deposit_Slip__C' and name like '%CCS%'].id;
        insert deposit;
        Boolean isError = false;
        
        Boolean flagCCL = false;
        Boolean flagETC = false;
        deposit.CIML_156_Total_Cheque__c = 0;
        deposit.CIML_156_Total_Amount__c = 0.0;
        
        system.debug('Results : ' + listAggregateResults );
        for(AggregateResult listAggr : listAggregateResults ){
            
            system.debug('listAggr : ' + listAggr);
            String depoAccName = (String)listAggr.get('Deposit_Account_Name__c');
            
            if(null == depoAccName){
                //depoAccName = 'CIML';
                continue;
            }
            if(flagCCL == false && (depoAccName == 'CCL' || depoAccName == 'CLP')){
                flagCCL = true;
            }else if(flagCCL == true && (depoAccName == 'CCL' || depoAccName == 'CLP')){
                continue;
            }
            
            if(flagETC == false && (depoAccName == 'ETC' || depoAccName == 'AFF')){
                flagETC = true;
            }else if(flagETC == true && (depoAccName == 'ETC' || depoAccName == 'AFF')){
                continue;
            }
            
            PageReference depositSlip = new PageReference('/apex/GenerateProductSlip');
            depositSlip.getParameters().put('type', depoAccName);
            
            blob pdfBody;
            if(Test.isRunningTest()) {
                pdfBody = Blob.valueOf('test');
            }else{
                pdfBody = depositSlip.getContent();
            }
            
            createAttachment(pdfBody, (depositAccountMap.get(depoAccName )).Entity_Name__c, deposit.Id);
            
            if((String)listAggr.get('Deposit_Account_Name__c') == 'CIML'){
                PageReference depositSlipCanaccede = new PageReference('/apex/GenerateProductSlip');
                depositSlipCanaccede.getParameters().put('type', 'Canaccede_Account_Perticulars');
                
                blob pdfBodyCanaccede;
                if(Test.isRunningTest()) {
                    pdfBodyCanaccede = Blob.valueOf('test');
                }else{
                    pdfBodyCanaccede = depositSlipCanaccede.getContent();
                }
                
                createAttachment(pdfBodyCanaccede, 'Canaccede Suspense Account', deposit.Id);
            
            }
            if((String)listAggr.get('Deposit_Account_Name__c') == 'AFSI'){
                PageReference depositSlipAffirm = new PageReference('/apex/GenerateProductSlip');
                depositSlipAffirm.getParameters().put('type', 'Affirm_Account_Perticulars');
                
                blob pdfBodyAffirm;
                if(Test.isRunningTest()) {
                    pdfBodyAffirm = Blob.valueOf('test');
                }else{
                    pdfBodyAffirm = depositSlipAffirm.getContent();
                }
                
                createAttachment(pdfBodyAffirm, 'Fidem Suspense Account', deposit.Id);
                
            }
            
            if(depoAccName == 'AAL'){
                deposit.CIHI_877_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.CIHI_877_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'ETC' || depoAccName == 'AFF'){
                deposit.A1LP_394_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.A1LP_394_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'AFL'){
                deposit.ACQ_618_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.ACQ_618_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'CAL'){
                deposit.CAL_767_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.CAL_767_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'CIH'){
                deposit.CIHI_877_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.CIHI_877_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'CCL' || depoAccName == 'CLP'){
                deposit.CCLP_130_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.CCLP_130_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'CIA'){
                deposit.CIHI_877_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.CIHI_877_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'CFL'){
                deposit.CFL_602_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.CFL_602_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else if(depoAccName == 'AFSI'){
                deposit.AFSI_631_Total_Cheque__c = (Integer)listAggr.get('total');
                deposit.AFSI_631_Total_Amount__c = (Decimal)listAggr.get('amount');
            }else {
                deposit.CIML_156_Total_Cheque__c += (Integer)listAggr.get('total');
                deposit.CIML_156_Total_Amount__c += (Decimal)listAggr.get('amount');
            }
            
        }
        
        List<Product_Payments__C> listPayment = [select id, name, Dividend__r.Deposit_Account_Name__c
                                              from Product_Payments__C
                                              where Dividend__r.lastmodifiedDate >= :LastDepositSlipCreatedDate
                                              AND Dividend__r.Status__c = 'Processed'
                                              AND dividend__r.recordType.developerName = 'CCS_Dividend'
                                              AND Dividend__r.Do_Not_Process__c = false
                                              AND Is_Payment_Remitted__c = False];
                                              
        List<Unallocated_payment__C> listUnallocPay = [select id, name, remittance__r.Deposit_Account_Name__c
                                              from Unallocated_payment__C
                                              where remittance__r.lastmodifiedDate >= :LastDepositSlipCreatedDate
                                              AND remittance__r.Status__c = 'Processed'
                                              AND allocated__c = false
                                              AND remittance__r.recordType.developerName = 'CCS_Dividend'
                                              AND remittance__r.Do_Not_Process__c = false
                                              AND Is_Payment_Remitted__c = false
                                              ANd Is_Payments_Reversed__c = null];
        
        for(Product_Payments__C insolPay : listPayment){
            insolpay.Deposit_Slip__c = deposit.Id;
        }
        //Application_Config_Settings__c appConfig = Application_Config_Settings__c.getOrgDefaults();
        appConfigFinal.Do_Not_Run_Payment_Validation__c = true;
        update appConfigFinal;
        Set<Product_Payments__C> setPaymentRecords = new Set<Product_Payments__C>(listPayment );
        List<Product_Payments__C> listPaymentRecordsToUpdate = new List<Product_Payments__C>(setPaymentRecords);
        update listPaymentRecordsToUpdate;
        appConfigFinal.Do_Not_Run_Payment_Validation__c = false;
        update appConfigFinal;
        
        //Update Unallocated Payments
        for(Unallocated_payment__C insolPay : listUnallocPay){
            insolpay.Deposit_Slip__c = deposit.Id;
        }
        update listUnallocPay;
        
        update deposit;
        
        List<Deposit_Slip__c> depositSlipRecord = [select id, name from Deposit_Slip__c where createdDate = Today AND recordType.developerName = 'CCS_Deposit_Slip' order by createdDate];
        depositSlipAvailable = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Deposit Slip generated successfully : <a href="'+System.Url.getSalesforceBaseURL().toExternalForm() +'/'+depositSlipRecord[0].id+'" target="_blank">'+depositSlipRecord[0].Name+'</a>'));
        
    }
    
    // Create attachment
    public void createAttachment(Blob body, String depositSlipType, Id depositId){
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
        List<Deposit_Slip__c> lastDepositSlip = [SELECT Id, Name, createdDate FROM Deposit_Slip__c WHERE CreatedDate <> TODAY AND recordType.developerName = 'CCS_Deposit_Slip' ORDER BY createdDate DESC];
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
        
        List<Deposit_Slip__c> todayDepositSlip = [SELECT Id, Name, createdDate FROM Deposit_Slip__c WHERE CreatedDate = TODAY AND recordType.developerName = 'CCS_Deposit_Slip' ORDER BY createdDate DESC];
        System.debug('TodayDepositSlip---'+todayDepositSlip);
        if(todayDepositSlip.size()>0){
            showFinalDepositSlipButton = true;
            appConfigFinal.CCS_Final_Deposit_Slip__c = system.TODAY();
            update appConfigFinal;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Deposit slip is locked for the day'));
        }
        
    }
}