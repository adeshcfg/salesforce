/**************************************************************************************************
*
*  Class:   
*
*  @description : Batch class that will process direct_debit transactionsauthor : A5E Consulting
*
*  @date : 16/11/2016   

*************************************************************************************************/
global class VersaPayPaymentSetupBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public final String fundingBatchId;

    public static Loan_ReEngineering__c lrpCust = Loan_ReEngineering__c.getOrgDefaults();
    
    //default constructor
    public VersaPayPaymentSetupBatch(){
    
    }
    
    //constructor that pass Payment Setup batch record Id
    /*
    public VersaPayPaymentSetupBatch(String fundingBatchId){
        this.fundingBatchId = fundingBatchId;
    }
    */
    
    //Query all the product records for Payment Setup Batch record passed.
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        system.debug('Start Time :' + system.now());
        return Database.getQueryLocator([Select id, name, /*SOR_External_ID__c,*/ Disbursement_Amount__c, 
                                        Customer__r.PersonEmail, Customer__r.FirstName, Customer__r.LastName,
                                        PAP_Bank_Code__c, PAP_Transit_Code__c, PAP_Account_Number__c, 
                                        Override_Payment_Date__c, First_Payment_Date__c, //Next_Payment_Date__c, 
                                        Override_Payment_Amount__c, First_Payment_Amount__c,//Next_Payment_Amount__c,
                                        SP_Override_Payment_Date__c, SP_Next_Payment_Due_Date__c, SP_First_Payment_Date__c,
                                        Payment_Amount__c, Payment_Due_Date__c
                                       /* Funding_Source_Token__c */
                                        from Product__c 
                                        WHERE Hold_Payments__c = false
                                       /* AND (Funding_Status__c = 'Funded' OR Funding_Status__c = 'Manually Funded')*/
                                        AND Payment_Setup_Status__c = 'Automated' 
                                        AND External_Status_Current__c = 'Active'
                                        AND Closed_Date__c = null
                                        AND Payment_Released_Date__c != TODAY
                                        AND (Override_Payment_Amount__c != null OR Payment_Amount__c != null OR First_Payment_Amount__c != null)
                                        AND ((SP_Override_Payment_Date__c != null AND SP_Override_Payment_Date__c = TODAY)
                                            OR (SP_Override_Payment_Date__c = null AND SP_Next_Payment_Due_Date__c = TODAY)
                                            OR (SP_Override_Payment_Date__c = null AND SP_Next_Payment_Due_Date__c = null AND SP_First_Payment_Date__c = TODAY)) limit 5                                            
                                        ]);
    }
    
    //Use VersaPayWSUtil to send the request xml to VersaPay and Create n requests for n Term.
    global void execute(Database.BatchableContext BC, List<Product__c> prodList){
        
        system.debug('Batch Start Time :' + system.now());
        List<VersaPay_Product_Payment__c> prodPayList = New List<VersaPay_Product_Payment__c>();
        List<Product__c> prodUpdateList = New List<Product__c>();
        List<API_Error__c> apiErrorList = New List<API_Error__c>();
        
        for(Product__c prod : prodList){
        
            Decimal amountInCents = VersaPayWSUtil.countAmountInCentsDebit(prod.Override_Payment_Amount__c, prod.Payment_Amount__c, prod.First_Payment_Amount__c, prod.SP_First_Payment_Date__c);
            
            Date processOnDate = VersaPayWSUtil.effectiveDateForPayment(prod);
            
            API_Error__c apiError = New API_Error__c();
            
            //VersaPayWSUtil.VersaPayResponse resp = VersaPayWSUtil.createDebitRequest(prod, amountInCents, processOnDate, apiError);
            VersaPayWSUtil.VersaPayResponse resp = VersaPayWSUtil.createDebitRequest(prod, amountInCents, processOnDate, apiError, lrpCust.Default_Company_Name__c);
            
            if(resp != null){
            
                System.debug('resp: '+resp);
                    
                VersaPay_Product_Payment__c prodPay = New VersaPay_Product_Payment__c();
                
                if(String.isBlank(resp.errorMessage)){
                    
                    if(String.isNotBlank(resp.versaPayTokenNumber)){
                        prodPay.VersaPay_Token_Number__c = resp.versaPayTokenNumber;
                    }
                    
                    if(String.isNotBlank(resp.versaPayFromFundToken)){
                        prodPay.VersaPay_From_Fund_Token__c = resp.versaPayFromFundToken;
                    }
                                        
                    if(String.isNotBlank(resp.versaPayToFundToken)){
                        prodPay.VersaPay_To_Fund_Token__c = resp.versaPayToFundToken;
                    }
                    
                    if(String.isNotBlank(resp.versaPayFromAccount)){
                        prodPay.VersaPay_From_Account__c = resp.versaPayFromAccount;
                    }
                    
                    if(String.isNotBlank(resp.versaPayToAccount)){
                        prodPay.VersaPay_To_Account__c = resp.versaPayToAccount;
                    }

                    //update product fileds with blank
                    prod.Override_Payment_Amount__c = null;
                    prod.Override_Payment_Date__c = null;
                    
                }
                else{
                    /*if(resp.errorMessage.contains('Unknow')){
                        prodPay.VersaPay_State__c = 'unknown_error';
                    }
                    if(resp.errorMessage.contains('Server')){
                        prodPay.VersaPay_State__c = 'server_error';
                    }   
                    else{
                        prodPay.VersaPay_State__c = 'error';
                    }*/     
                }
                
                if(amountInCents != null){
                    prodPay.Payment_Amount__c = amountInCents/100;
                }
                
                if(processOnDate != null){
                  prodPay.Process_On__c = processOnDate;                  
                }
                
                prodPay.Last_State_Changed_Date__c = System.Now();
                prodPay.Payment_Posted_To_VersaPay_On__c = System.Now();
                prodPayList.add(prodPay);
                prodPay.VersaPay_State__c = resp.versaPayState;
                
                //update product fileds with blank
                //if('Completed' == prodPay.VersaPay_State__c){
                //    prod.Override_Payment_Amount__c = null;
                //    prod.Override_Payment_Date__c = null;
                //}        
                
                
                //if(String.isNotBlank(resp.errorDescription)){
                prodPay.VersaPay_Payment_Error__c = resp.errorDescription;
                //}
                prodPay.Product__c = prod.Id;
                
            }
            
            if(apiError != null && String.isNotBlank(apiError.Response__c)){
                apiErrorList.add(apiError);
            }
            
            prod.Payment_Released_Date__c = (system.now()).date();
            prodUpdateList.add(prod);
        }
        
        System.debug('prodPayList: '+prodPayList);
        System.debug('prodUpdateList: '+prodUpdateList);
                
        if(prodPayList.size() >0){
            insert prodPayList;
        }
        
        if(prodUpdateList.size() >0){
            ProductTriggerHandler.runProductTrigger = false;
            update prodUpdateList;
            ProductTriggerHandler.runProductTrigger = true;
        }       
        
        for(API_Error__c api : apiErrorList){
            for(VersaPay_Product_Payment__c proPayset : prodPayList){
                System.debug('ID: '+api.Product__c +'='+ proPayset.Product__c);
                if(api.Product__c == proPayset.Product__c){
                    api.VersaPay_Product_Payment__c = proPayset.ID;
                }
            }
        }
        
        System.debug('apiErrorList: '+apiErrorList);
        if(apiErrorList.size() >0){
            insert apiErrorList;
        }
        
        system.debug('Batch End Time :' + system.now());
    }
    
    /*
    global void finish(Database.BatchableContext BC){
        system.debug('End Time :' + system.now());
    }*/
    
    global void finish(Database.BatchableContext BC){
        
        system.debug('End Time :' + system.now());
        
        List <Product__c> remaingCount = [Select id, name, /*SOR_External_ID__c,*/ Disbursement_Amount__c, 
                                        Customer__r.PersonEmail, Customer__r.FirstName, Customer__r.LastName,
                                        PAP_Bank_Code__c, PAP_Transit_Code__c, PAP_Account_Number__c, 
                                        Override_Payment_Date__c, First_Payment_Date__c, //Next_Payment_Date__c, 
                                        Override_Payment_Amount__c, First_Payment_Amount__c,//Next_Payment_Amount__c,
                                        SP_Override_Payment_Date__c, SP_Next_Payment_Due_Date__c, SP_First_Payment_Date__c,
                                        Payment_Amount__c, Payment_Due_Date__c
                                        from Product__c 
                                        WHERE Hold_Payments__c = false
                                        /*AND (Funding_Status__c = 'Funded' OR Funding_Status__c = 'Manually Funded')*/
                                        AND Payment_Setup_Status__c = 'Automated'
                                        AND External_Status_Current__c = 'Active' 
                                        AND Closed_Date__c = null
                                        AND Payment_Released_Date__c != TODAY 
                                        AND (Override_Payment_Amount__c != null OR Payment_Amount__c != null OR First_Payment_Amount__c != null)
                                        AND ((SP_Override_Payment_Date__c != null AND SP_Override_Payment_Date__c = TODAY)
                                            OR (SP_Override_Payment_Date__c = null AND SP_Next_Payment_Due_Date__c = TODAY)
                                            OR (SP_Override_Payment_Date__c = null AND SP_Next_Payment_Due_Date__c = null AND SP_First_Payment_Date__c = TODAY))];
       
        if(remaingCount!=null && remaingCount.size()>0){
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(2);
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(VersaPayPaymentSetupSchedule.class.getName() + '-' + now.format(), cronString, new VersaPayPaymentSetupSchedule());           
        }                            
    }
}