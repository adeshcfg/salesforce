/**
* @description       : Queueable class to generate Deposit Slips
* @author            : pradeepk@a5econsulting.net
* @group             :
* @last modified on  : 01-27-2025
* @last modified by  : pradeepk@a5econsulting.net
**/
public with sharing class GenerateDepositSlipQueueable implements Queueable, Database.AllowsCallouts{
    public DateTime LastDepositSlipCreatedDate;
    public List<AggregateResult> listOfAggregateResult;
    public AggregateResult aggregateResult;
    public Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Slip__c deposit;
    public Application_Config_Settings__c appConfigFinal;
    public String action = 'Update';
    public Boolean flagCCL = false;
    public Boolean flagETC = false;
    
    public GenerateDepositSlipQueueable(List<AggregateResult> listOfAggregateResult, 
                                        Deposit_Slip__c deposit, 
                                        DateTime LastDepositSlipCreatedDate,
                                        Application_Config_Settings__c appConfigFinal,
                                        String action){
                                            this.action = action;
                                            this.listOfAggregateResult = listOfAggregateResult;
                                            this.deposit = deposit;
                                            this.LastDepositSlipCreatedDate = LastDepositSlipCreatedDate;
                                            this.appConfigFinal = appConfigFinal;
                                            if(listOfAggregateResult.size() > 0){
                                                this.aggregateResult = listOfAggregateResult[0];
                                            }                                            
                                        }
    public GenerateDepositSlipQueueable(List<AggregateResult> listOfAggregateResult,
                                        Deposit_Slip__c deposit, 
                                        DateTime LastDepositSlipCreatedDate,
                                        Application_Config_Settings__c appConfigFinal,
                                        String action, Boolean flagCCL, Boolean flagETC
                                        ){
        									this.action = action;
                                            this.flagCCL = flagCCL;
                                            this.flagETC = flagETC;
        									this.listOfAggregateResult = listOfAggregateResult;
                                            this.deposit = deposit;
                                            this.LastDepositSlipCreatedDate = LastDepositSlipCreatedDate;
                                            this.appConfigFinal = appConfigFinal;
                                            if(listOfAggregateResult.size() > 0){
                                                this.aggregateResult = listOfAggregateResult[0];
                                            }
                                        }
    /**
    * @description : Execute method
    * @author pradeepk@a5econsulting.net | 01-27-2025
    * @param context
    **/
    public void execute(QueueableContext context) { 
        if(aggregateResult != null){            
            String depoAccName = (String)aggregateResult.get('Deposit_Account_Name__c');
            System.debug('depoAccName:: '+depoAccName);
            if(null == depoAccName){
                action = 'skipNcontinue';
            }
            if(flagCCL == false && (depoAccName == 'CCL' || depoAccName == 'CLP')){
                flagCCL = true;
                action = 'createPdfAttachment';
            }else if(flagCCL == true && (depoAccName == 'CCL' || depoAccName == 'CLP')){
                action = 'skipNcontinue';
            }        
            if(flagETC == false && (depoAccName == 'ETC' || depoAccName == 'AFF')){
                flagETC = true;
                action = 'createPdfAttachment';
            }else if(flagETC == true && (depoAccName == 'ETC' || depoAccName == 'AFF')){
                action = 'skipNcontinue';
            }
            if(depoAccName != 'CCL' &&
              depoAccName != 'CLP' &&
              depoAccName != 'ETC' &&
              depoAccName != 'AFF' &&
              null != depoAccName){
                action = 'createPdfAttachment';
            }
        }
        
        switch on action{
            when 'updatePayments'{
                updatePayments();
            }
            when 'createPdfAttachment'{
                createPdfAttachment();
            }
            when 'skipNcontinue'{
                skipNcontinue();
            }
        }
    }
    public void sendNotification(){
        /* Sending of email */
        List<Deposit_Slip__c> depositSlipRecord = [select id, name from Deposit_Slip__c where createdDate = Today AND recordType.developerName = 'Insolvency_Deposit_Slip' order by createdDate];
        if(depositSlipRecord.size() > 0){
           	String emailId = UserInfo.getUserEmail();
            if(!String.isBlank(emailId)){
               	List<String> toAddressList = new List<String>{emailId};
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = toAddressList;
                message.htmlBody = 'Deposit Slip generated successfully : <a href="' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + depositSlipRecord[0].Id + '" target="_blank">' + depositSlipRecord[0].Name + '</a>';
                message.subject = 'Generate Deposit Slip';
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }             
        }        
    }
    public void skipNcontinue(){
        if(listOfAggregateResult.size() > 0){
           	listOfAggregateResult.remove(0);
            if (!Test.isRunningTest()) {
                if(listOfAggregateResult.size() > 0){
                    System.enqueueJob(new GenerateDepositSlipQueueable(listOfAggregateResult, deposit, LastDepositSlipCreatedDate, appConfigFinal, 'createPdfAttachment', flagCCL, flagETC));
                }else{
                    System.enqueueJob(new GenerateDepositSlipQueueable(listOfAggregateResult, deposit, LastDepositSlipCreatedDate, appConfigFinal, 'updatePayments', flagCCL, flagETC));
                } 
            }
        }        
    }
    public void updatePayments(){
        List<Insolvency_payment__C> listPayment = [select id, name, remittance__r.Deposit_Account_Name__c
                                                   from Insolvency_payment__C
                                                   where remittance__r.lastmodifiedDate >= :LastDepositSlipCreatedDate
                                                   AND remittance__r.Status__c = 'Processed'
                                                   AND Remittance__r.Do_Not_Process__c = false
                                                   AND remittance__r.recordtype.Developername = 'Insolvency_Dividend'
                                                   AND Is_Payment_Remitted__c = False];
        
        List<Unallocated_payment__C> listUnallocPay = [select id, name, remittance__r.Deposit_Account_Name__c
                                                       from Unallocated_payment__C
                                                       where remittance__r.lastmodifiedDate >= :LastDepositSlipCreatedDate
                                                       AND remittance__r.Status__c = 'Processed'
                                                       AND remittance__r.recordtype.Developername = 'Insolvency_Dividend'
                                                       AND allocated__c = false
                                                       AND Remittance__r.Do_Not_Process__c = false
                                                       AND Is_Payment_Remitted__c = false
                                                       AND Is_Payments_Reversed__c = null];
        
        for(Insolvency_payment__C insolPay : listPayment){
            insolpay.Deposit_Slip__c = deposit.Id;
        }
        //Application_Config_Settings__c appConfig = Application_Config_Settings__c.getOrgDefaults();
        appConfigFinal.Do_Not_Run_Payment_Validation__c = true;
        update appConfigFinal;
        Set<Insolvency_Payment__c> setPaymentRecords = new Set<Insolvency_Payment__c>(listPayment );
        List<Insolvency_Payment__c> listPaymentRecordsToUpdate = new List<Insolvency_Payment__c>(setPaymentRecords);
        update listPaymentRecordsToUpdate;
        appConfigFinal.Do_Not_Run_Payment_Validation__c = false;
        update appConfigFinal;
        
        //Update Unallocated Payments
        for(Unallocated_payment__C insolPay : listUnallocPay){
            insolpay.Deposit_Slip__c = deposit.Id;
        }
        update listUnallocPay;
        
        update deposit;
        
        //Send Email Notification to the user notifying the completion of deposit slip generation
        sendNotification();
    }
    
    public void createPdfAttachment(){
        try {
            String depoAccName = (String)aggregateResult.get('Deposit_Account_Name__c');
            
            PageReference depositSlip = new PageReference('/apex/GenerateSlip');
            depositSlip.getParameters().put('type', depoAccName);            
            blob pdfBody;
            if(Test.isRunningTest()) {
                pdfBody = Blob.valueOf('test');
            }else{
                pdfBody = depositSlip.getContent();
            }
            
            GenerateDepositSlipRecordsController.createAttachment(pdfBody, (depositAccountMap.get(depoAccName )).Entity_Name__c, deposit.Id);
            
            if(depoAccName == 'CIML'){
                PageReference depositSlipCanaccede = new PageReference('/apex/GenerateSlip');
                depositSlipCanaccede.getParameters().put('type', 'Canaccede_Account_Perticulars');
                
                blob pdfBodyCanaccede;
                if(Test.isRunningTest()) {
                    pdfBodyCanaccede = Blob.valueOf('test');
                }else{
                    pdfBodyCanaccede = depositSlipCanaccede.getContent();
                }
                
                GenerateDepositSlipRecordsController.createAttachment(pdfBodyCanaccede, 'Canaccede Suspense Account', deposit.Id);
                
            }
            if(depoAccName == 'AFSI'){
                PageReference depositSlipAffirm = new PageReference('/apex/GenerateSlip');
                depositSlipAffirm.getParameters().put('type', 'Affirm_Account_Perticulars');
                
                blob pdfBodyAffirm;
                if(Test.isRunningTest()) {
                    pdfBodyAffirm = Blob.valueOf('test');
                }else{
                    pdfBodyAffirm = depositSlipAffirm.getContent();
                }
                GenerateDepositSlipRecordsController.createAttachment(pdfBodyAffirm, 'Fidem Suspense Account', deposit.Id);
                
            }
            
            if(depoAccName == 'AAL'){
                deposit.CIHI_877_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.CIHI_877_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'ETC' || depoAccName == 'AFF'){
                deposit.A1LP_394_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.A1LP_394_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'AFL'){
                deposit.ACQ_618_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.ACQ_618_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'CAL'){
                deposit.CAL_767_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.CAL_767_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'CIH'){
                deposit.CIHI_877_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.CIHI_877_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'CCL' || depoAccName == 'CLP'){
                deposit.CCLP_130_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.CCLP_130_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'CIA'){
                deposit.CIHI_877_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.CIHI_877_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'CFL'){
                deposit.CFL_602_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.CFL_602_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else if(depoAccName == 'AFSI'){
                deposit.AFSI_631_Total_Cheque__c = (Integer)aggregateResult.get('total');
                deposit.AFSI_631_Total_Amount__c = (Decimal)aggregateResult.get('amount');
            }else {
                deposit.CIML_156_Total_Cheque__c += (Integer)aggregateResult.get('total');
                deposit.CIML_156_Total_Amount__c += (Decimal)aggregateResult.get('amount');
            }
            listOfAggregateResult.remove(0);
            if (!Test.isRunningTest()) {
                if(listOfAggregateResult.size() > 0){
                    System.enqueueJob(new GenerateDepositSlipQueueable(listOfAggregateResult, deposit, LastDepositSlipCreatedDate, appConfigFinal, 'createPdfAttachment', flagCCL, flagETC));
                }else{
                    System.enqueueJob(new GenerateDepositSlipQueueable(listOfAggregateResult, deposit, LastDepositSlipCreatedDate, appConfigFinal, 'updatePayments', flagCCL, flagETC));
                }
            }
        }catch(Exception ex){
            System.debug('Exception occured: '+ex.getMessage());
        }
    }
}