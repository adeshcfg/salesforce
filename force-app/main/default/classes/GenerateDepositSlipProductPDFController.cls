public class GenerateDepositSlipProductPDFController {
    
    public String type {set;get;}
    public integer size{get;set;}
    public decimal total{get;set;}
    
    public List<Product_payments__c> insolvPayList{set;get;}
    public List<DepositWrapper> lisDepotWrap{get;set;}
    public List<SuspenseWrapper> listSuspWrap{get;set;}
    
    //Affirm Suspense account lists
    public List<SuspenseWrapper> listAAL{get;set;}
    public List<SuspenseWrapper> listETC{get;set;}
    public List<SuspenseWrapper> listAFL{get;set;}
    public List<SuspenseWrapper> listAFSI{get;set;}
    
    //Canaccede Suspense account lists
    public List<SuspenseWrapper> listCAL{get;set;}
    public List<SuspenseWrapper> listCIH{get;set;}
    public List<SuspenseWrapper> listCCL{get;set;}
    public List<SuspenseWrapper> listCIA{get;set;}
    public List<SuspenseWrapper> listCFL{get;set;}
    public List<SuspenseWrapper> listCIML{get;set;}
    
    //Affirm Suspense account total
    public Decimal totalAAL{get;set;}
    public Decimal totalETC{get;set;}
    public Decimal totalAFL{get;set;}
    public Decimal totalAFSI{get;set;}
    
    //Canaccede Suspense account total
    public Decimal totalCAL{get;set;}
    public Decimal totalCIH{get;set;}
    public Decimal totalCCL{get;set;}
    public Decimal totalCIA{get;set;}
    public Decimal totalCFL{get;set;}
    public Decimal totalCIML{get;set;}
    
    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc {set;get;}
    // Controller
    public GenerateDepositSlipProductPDFController(){
        
        type = ApexPages.currentPage().getParameters().get('type');
        total = 0.0;
        insolvPayList = new List<Product_payments__c>();
        lisDepotWrap = new List<DepositWrapper>();
        listSuspWrap = new List<SuspenseWrapper>();
        List<String> listParameter = new List<string>();
        
        //Initialize Affirm Suspense account lists
        listAAL = new List<SuspenseWrapper>();
        listETC = new List<SuspenseWrapper>();
        listAFL = new List<SuspenseWrapper>();
        listAFSI = new List<SuspenseWrapper>();
        
        //Initialize Canaccede Suspense account lists
        listCAL = new List<SuspenseWrapper>();
        listCIH = new List<SuspenseWrapper>();
        listCCL = new List<SuspenseWrapper>();
        listCIA = new List<SuspenseWrapper>();
        listCFL = new List<SuspenseWrapper>();
        listCIML = new List<SuspenseWrapper>();
        
        //Initialize Affirm Suspense account total
        totalAAL = 0.0;
        totalETC = 0.0;
        totalAFL = 0.0;
        totalAFSI = 0.0;
        
        //Initialize Canaccede Suspense account total
        totalCAL = 0.0;
        totalCIH = 0.0;
        totalCCL = 0.0;
        totalCIA = 0.0;
        totalCFL = 0.0;
        totalCIML = 0.0;
            
        system.debug('Type : ' + type);
        String parameter = type;
        if(type == 'Canaccede_Account_Perticulars' || type == 'CIML' || type == ''){
            listParameter.add('CIML');
            listParameter.add('');
            listParameter.add(null);
            parameter = 'CIML';
            //type = 'CIML';
        }else if(type == 'Affirm_Account_Perticulars' || type == 'AFSI'){
            listParameter.add('AFSI');
            //type = 'AFSI';
        }else if (type == 'CCL' || type == 'CLP'){
            listParameter.add('CCL');
            listParameter.add('CLP');
        }else if (type == 'ETC' || type == 'AFF'){
            listParameter.add('ETC');
            listParameter.add('AFF');
        }else{
            listParameter.add(type);
        }
        system.debug('Parameter : ' + listParameter);
        DateTime LastDepositSlipCreatedDate = GenerateDepositSlipProductController.LastDepositSlipCreatedDate();
        system.debug('LastDepositSlipCreatedDate ' + LastDepositSlipCreatedDate);
        List<Remittance__C> listRemittance = [select id, name, Bank_Account_Number__c, Transit_Code__c, Entity_Name__c, 
                                              CCS_Agency__r.name, Cheque_Amount__c, Cheque_Payment_Reference_Number__c
                                              from remittance__C 
                                              where Deposit_Account_Name__c in :listParameter
                                              AND Status__c = 'Processed'
                                              AND Do_Not_Process__c = false
                                              AND lastmodifiedDate > :LastDepositSlipCreatedDate
                                              AND recordType.developerName = 'CCS_Dividend'] ;
        system.debug([SELECT Deposit_Account_Name__c, Status__c FROM remittance__C LIMIT 1]);
        system.debug('listREmittance : ' + listREmittance);
        List<ID> listRemittanceID = new List<ID>();
        for(Remittance__C rem : listRemittance ){
            listRemittanceID.add(rem.id);
        }
        insolvPayList = [SELECT id, name, CCS_Account__r.name, CCS_Account__r.Portfolio_Group_Name_Formula__c,
                         Cheque_Number__c, Deposit_Account_Type__c, Payment_Amount__c,
                         Dividend__r.Cheque_Payment_Reference_Number__c, dividend__r.CCS_Agency__r.name
                        from Product_payments__c
                        where Dividend__c in :listRemittanceID
                        AND dividend__r.recordType.developerName = 'CCS_Dividend'];
        
        List<Unallocated_Payment__c> listUnalloc = [SELECT Id, Account_Number__c, Unallocated_Amount__c, Remittance__c,
                                                    Remittance__r.Trustee_Name__r.Name, Remittance__r.Trustee_Name__c,  
                                                    Remittance__r.Cheque_Payment_Reference_Number__c, 
                                                    Remittance__r.Deposit_Account_Name__c, Remittance__r.CCS_Agency__r.name
                                                    FROM Unallocated_Payment__c 
                                                    WHERE CreatedDate > :LastDepositSlipCreatedDate
                                                    AND remittance__c in :listRemittanceID
                                                    AND Allocated__c = FALSE
                                                    AND Is_Payment_Remitted__c = FALSE
                                                    AND Is_Payments_Reversed__c = null
                                                    AND remittance__r.recordType.developerName = 'CCS_Dividend'];
        size = listRemittance.size();
        depositAcc = depositAccountMap.get(parameter);
        system.debug('deposit account info : ' + depositAcc );
        for(Remittance__C rem : listRemittance ){
            DepositWrapper wrp = new DepositWrapper();
            
            wrp.trusteeName = rem.CCS_Agency__r.name + ' - ' + rem.Cheque_Payment_Reference_Number__c;
            wrp.paymentAmount = rem.Cheque_Amount__c;
            total += rem.Cheque_Amount__c;
            lisDepotWrap.add(wrp);
        }
        system.debug('lisDepotWrap : ' + lisDepotWrap);
        if(type == 'Canaccede_Account_Perticulars' || type == 'Affirm_Account_Perticulars'){
            system.debug('INS size='+insolvPayList);
            for(Product_payments__c insolPay : insolvPayList ){
                
                if(null != insolPay.Deposit_Account_Type__c){
                    depositAcc = depositAccountMap.get(insolPay.Deposit_Account_Type__c);
                }else{
                    depositAcc = depositAccountMap.get('CIML');
                }
                SuspenseWrapper wrp = new SuspenseWrapper();
                
                if(null == depositAcc ){
                    depositAcc = depositAccountMap.get('CIML');
                }
                
                wrp.accountName = insolPay.CCS_Account__r.name;
                wrp.transit = depositAcc.Transit_Number__c;
                wrp.entity = depositAcc.Account_Name_on_Clearing_Account__c;
                wrp.bankAccountName = depositAcc.Account_Number__c;
                wrp.trustee = insolPay.dividend__r.CCS_Agency__r.name + ' - ' + insolPay.Dividend__r.Cheque_Payment_Reference_Number__c;
                wrp.paymentAmount = insolPay.Payment_Amount__c;
                
                if(insolPay.Deposit_Account_Type__c == 'AAL'){
                    listCIH.add(wrp);
                    totalCIH += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'ETC'){
                    listETC.add(wrp);
                    totalETC += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'AFF'){
                    listETC.add(wrp);
                    totalETC += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'AFL'){
                    listAFL.add(wrp);
                    totalAFL += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CAL'){
                    listCAL.add(wrp);
                    totalCAL += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CIH'){
                    listCIH.add(wrp);
                    totalCIH += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CCL'){
                    listCCL.add(wrp);
                    totalCCL += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CLP'){
                    listCCL.add(wrp);
                    totalCCL += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CIA'){
                    listCIH.add(wrp);
                    totalCIH += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CFL'){
                    listCFL.add(wrp);
                    totalCFL += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'CIML' || null == insolPay.Deposit_Account_Type__c){
                    listCIML.add(wrp);
                    totalCIML += insolPay.Payment_Amount__c;
                }else if(insolPay.Deposit_Account_Type__c == 'AFSI'){
                    listAFSI.add(wrp);
                    totalAFSI += insolPay.Payment_Amount__c;
                }
                
                listSuspWrap.add(wrp);
            }
            
            
            for(Unallocated_Payment__c unallo :  listUnalloc){
                
                SuspenseWrapper wrp = new SuspenseWrapper();
                
                if(unallo.remittance__r.Deposit_Account_Name__c == 'CIML'){
                    
                    depositAcc = depositAccountMap.get('CIML');
                    
                    
                    listCIML.add(wrp);
                    totalCIML += unallo.Unallocated_Amount__c;
                }
                if(unallo.remittance__r.Deposit_Account_Name__c == 'AFSI'){
                    
                    depositAcc = depositAccountMap.get('AFSI');
                    
                    listAFSI.add(wrp);
                    totalAFSI += unallo.Unallocated_Amount__c;
                }
                wrp.accountName = (unallo.Account_Number__c==null?'':unallo.Account_Number__c) + ' - Unallocated';
                wrp.transit = depositAcc.Transit_Number__c;
                wrp.entity = depositAcc.Account_Name_on_Clearing_Account__c;
                wrp.bankAccountName = depositAcc.Account_Number__c;
                wrp.trustee = unallo.remittance__r.CCS_Agency__r.name + ' - ' + unallo.remittance__r.Cheque_Payment_Reference_Number__c;
                wrp.paymentAmount = unallo.Unallocated_Amount__c;
            }
            
        }
    }
    
    public class DepositWrapper{
        public String trusteeName{set;get;}
        public Decimal paymentAmount {set;get;}
    }
    public class SuspenseWrapper{
        
        public String accountName {set;get;}
        public String transit {set;get;}
        public String entity {set;get;}
        public String bankAccountName {set;get;}
        public String trustee{set;get;}
        public Decimal paymentAmount {set;get;}
    }
}