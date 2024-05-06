public without sharing class PaymentReversalController {
    
    public String insolvencyAccNumbers{set;get;}
    Public string PaymentReversal{set;get;}
    Public string options {get; set;}
    public Remittance__c remit{set;get;}
    Application_Config_Settings__c appConfig;
    public String remitID = ApexPages.currentPage().getParameters().get('id');
    //Remitance Record Type
    private RecordType remittanceRecType;
    
    //Pictlistvalue for visualforce page\\
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new selectOption('None', 'None'));//
        options.add(new selectOption('NSF', 'NSF'));
        options.add(new SelectOption('Stopped','Stopped'));
        options.add(new SelectOption('Unauthorised','Unauthorised'));
        options.add(new SelectOption('Stale Dated','Stale Dated'));
        options.add(new SelectOption('Payment posted to Incorrect account','Payment posted to Incorrect account'));
        return options;
    }
    
    // Consturactor for CCS Dividend and insolvency dividend//
    Public PaymentReversalController(ApexPages.StandardController controller) {
        
        appConfig = [SELECT Do_Not_Run_Payment_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
        
        remit= [SELECT Id, name,  Status__c FROM Remittance__c WHERE Id =:remitID];
        if(remit.Status__c=='Payment Reversed'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment is already reversed on the dividend'));
            
        }else if(remit.Status__c=='In Progress' || remit.Status__c=='New'){
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment cannot be reversed for New/In progress Dividends'));
            
        }
    }
    
    // fetch the ccs payments //
    public void ccspayments(){
        list<Product_Payments__c> updatedPayments=new list<Product_Payments__c>();
        /*Id remittanceRecType  = Schema.SObjectType.Product_Payments__C.getRecordTypeInfosByName().get('CCS_Dividend_Payment').getRecordTypeId();*/
        /* map<id,Remittance__c> mapAPM = new map<id,Remittance__c>([select id,name from Product_Payments__c where ID = :remittanceRecType ]);*/
        /*String remitID = ApexPages.currentPage().getParameters().get('id');*/
        list<Remittance__c> listRemit= [SELECT Id, name, Cheque_Amount__c, Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c, 
                                        Status__c, CCS_Agency__c, CCS_Agency__r.name, Email_to_Case_Reference_Number__c, Assigned_To__c,
                                        Fairshare_Amount__c,Payment_Reversal_Date__c
                                        FROM Remittance__c WHERE Id =:remitID and recordtype.name='CCS Dividend'];
        if(listRemit.size()>0){
            //fetch the all ccsproduct payments from the dividends//
            List<Product_Payments__C> productPaymentList = new List<Product_Payments__C>();
            List<Product_Payments__c> existingProdPayList = ([SELECT Id, 
                                                              CCS_Account__c, FairShare_Amount__c,Unallocated_Payment__r.name,
                                                              Payment_Amount__c,Payment_Reversed__c,Payment_Posting_Month__c,Payment_Created__c,Deposit_Account_Type__c,Balance_Before_Payment__c,Balance_After_Payment__c,Gross_Payment_Amount__c,
                                                              CCS_Account__r.Agency_Company__c,Dividend__r.name,Deposit_Slip__r.name,Cheque_Number__c,Payment_Posting_Date__c
                                                              FROM Product_Payments__c
                                                              WHERE Dividend__c =: listRemit[0].Id] );
            
            
            for(Product_Payments__c prodPay : existingProdPayList){
                if(prodpay.Payment_Reversed__c==null){
                    prodpay.Payment_Reversed__c=PaymentReversal;
                    updatedPayments.add(prodpay);
                    Product_Payments__c clonedRec = prodpay.clone();
                    system.debug('clonedRec '+clonedRec );
                    clonedRec.CCS_Account__c=prodpay.CCS_Account__c;
                    clonedRec.FairShare_Amount__c=0-prodpay.FairShare_Amount__c;
                    clonedRec.Payment_Reversed__c = PaymentReversal;
                    clonedRec.Payment_Amount__c=0-prodpay.Payment_Amount__c;
                    productPaymentList.add(clonedRec);// =prodpay.clone();
                    //clonedpayments.add(prodPay);
                    
                }
            }
            if(!updatedPayments.isEmpty()){
                update updatedPayments;
            }
            if(productPaymentList.size()>0){
                system.debug('------prodPay--------'); 
                insert productPaymentList;
                system.debug('------productPaymentList--------'+productPaymentList); 
            }
            else{
                return;
            }
        }
    }
    // fetch and update unallocated payments for ccs products and insolvency from dividends//
    
    public void Unallocated(){
        /*String remitID = ApexPages.currentPage().getParameters().get('id');*/
        
        list<Remittance__c>  listremit= [SELECT Id, name, Cheque_Amount__c, Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c, 
                                         Status__c, CCS_Agency__c, CCS_Agency__r.name, Email_to_Case_Reference_Number__c, Assigned_To__c,
                                         Fairshare_Amount__c
                                         FROM Remittance__c WHERE Id =: remitID];
        
        List<Unallocated_Payment__c> unallocatedpaylist= new List<Unallocated_Payment__c>();
        List<Unallocated_Payment__c > existingunallocpayments=([SELECT Id, Account_Number__c, Bank_Name__c, Debtor_Name__c, Estate_Number__c, Remittance__c,Is_Payment_Remitted__c,
                                                                Unallocated_Amount__c, Allocated__c, Unallocated_Fairshare_Amount__c,Is_Payments_Reversed__c
                                                                FROM Unallocated_Payment__c
                                                                WHERE Remittance__c =: listremit[0].Id
                                                                AND Allocated__c = FALSE]);
        
        for(Unallocated_Payment__c unallacc: existingunallocpayments){
            if(unallacc.Is_Payments_Reversed__c==null && unallacc.Allocated__c !=True && unallacc.Is_Payment_Remitted__c !=true){
                /*Unallocated_Payment__c unallclonedRec = unallacc.clone();*/
                unallacc.Is_Payments_Reversed__c = PaymentReversal;
                unallocatedpaylist.add(unallacc);
                
            }
        }
        if(unallocatedpaylist.size()>0){
            update unallocatedpaylist;
        }
    }
    
    // for insolvency payments and unalloacted insolvency payment//
    public void insonlencypayments(){
        
        List<Insolvency_Payment__c> insolvencyPaymentsList = new List<Insolvency_Payment__c>();
        /*id insolvencyremittanceRecType  = Schema.SObjectType.Insolvency_Payment__c.getRecordTypeInfosByName().get('Insolvency_Dividend').getRecordTypeId();*/
        /*String remitID = ApexPages.currentPage().getParameters().get('id');*/
        list<Remittance__c> listremit= [SELECT Id, name, Cheque_Amount__c, Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c, 
                                        Status__c, Email_to_Case_Reference_Number__c,Trustee_Name__c
                                        FROM Remittance__c WHERE Id =: remitID and recordtype.name='Insolvency Dividend'];
        
        if(listremit.size()>0){
            // fetching the insolvency paymrnts from dividend//
            List<Insolvency_Payment__c> existinginsolvencyPaymentsList =([select id,Payment_Amount__c,Payment_Reversed__c, Payment_Posting_Date__c,Insolvency_Account__r.name,Is_Payment_Remitted__c,
                                                                          Payment_Posting_Month__c,Payment_Source__c,Cheque_Payment_Reference_Number__c,Remittance__r.name
                                                                          FROM Insolvency_Payment__c
                                                                          WHERE Remittance__c =: listremit[0].Id]);
            
            for(Insolvency_Payment__c insolPay : existinginsolvencyPaymentsList){
                if(insolPay.Payment_Reversed__c ==null && insolPay.Is_Payment_Remitted__c!=true ){
                    system.debug('PaymentReversal-'+PaymentReversal);
                    insolPay.Payment_Reversed__c= PaymentReversal;
                    insolvencyPaymentsList.add(insolPay);
                    
                }
            }
            
            if(insolvencyPaymentsList.size()>0){
                
                //Stop vaidation rule for Insolvency payment
                appConfig.Do_Not_Run_Payment_Validation__c = True;
                update appConfig;
                
                //Update Insolvency payments
                update insolvencyPaymentsList;
                
                //Start Insolvency Payment validation rule
                appConfig.Do_Not_Run_Payment_Validation__c = False;
                update appConfig;
            }else{
                return;
            }
        } 
    }
    
    
    public PageReference submit(){
        
        Unallocated();
        ccspayments();
        insonlencypayments();
        
        //Update dividend record with Payment reversal status and Payment Reversal Date
        remit.Status__c = 'Payment Reversed';
        remit.Payment_Reversal_Date__c=system.today();
        update remit;
        
        return null;
    }
    
}