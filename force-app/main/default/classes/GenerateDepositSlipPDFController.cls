public class GenerateDepositSlipPDFController {
    
    public String type {set;get;}
    public Integer size{get;set;}
    List<Id> insolvAccIds = new List<Id>();
    
    public Decimal total {set;get;}
    public List<Insolvency_Payment__c> insolvPayList{set;get;}
    public Map<String, Wrapper> insolvPayMap {set;get;}
    
    //Clearing Account Maps
    public Map<String, Wrapper> insolvPayMapCCL {set;get;}
    public Map<String, Wrapper> insolvPayMapCAL {set;get;}
    public Map<String, Wrapper> insolvPayMapCIA {set;get;}
    public Map<String, Wrapper> insolvPayMapCIH {set;get;}
    public Map<String, Wrapper> insolvPayMapETC {set;get;}
    
    //Clearing Account Total per Group
    public Decimal totalCIA {set;get;}
    public Decimal totalCCL {set;get;}
    public Decimal totalCIH {set;get;}
    public Decimal totalETC {set;get;}
    public Decimal totalCAL {set;get;}
    
    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc {set;get;}
    
    public GenerateDepositSlipPDFController (){
        
        /*type = ApexPages.currentPage().getParameters().get('type');
        insolvPayList = new List<Insolvency_Payment__c>();
        GenerateDepositSlipRecordsController dscn = new GenerateDepositSlipRecordsController();
        totalCIA = 0.0;
        totalCCL = 0.0;
        totalCIH = 0.0;
        totalCAL = 0.0;
        totalETC = 0.0;

        dscn.fetchVardeRemittance();
        
        List<Unallocated_payment__c> listUnalloPay = new List<Unallocated_payment__c>();
        if(type == 'varde' || type == 'Varde_Account_Perticulars'){
            listUnalloPay = dscn.fetchUnallocatedPayments();
            List<Insolvency_Payment__c> listCIHIAccounts = GenerateDepositSlipRecordsController.fetchRecords('CIH');
            List<Insolvency_Payment__c> listVardeCDAccounts = GenerateDepositSlipRecordsController.fetchRecords('CAL');
            List<Insolvency_Payment__c> listFortressAccounts = GenerateDepositSlipRecordsController.fetchRecords('CCL');
            List<Insolvency_Payment__c> listEquitableAccounts = GenerateDepositSlipRecordsController.fetchRecords('ETC');
            insolvPayList = GenerateDepositSlipRecordsController.fetchVardeRecords();
        }else if(type == 'fortress'){
            insolvPayList = GenerateDepositSlipRecordsController.fetchRecords('CCL');
        }else if(type == 'CIHI'){
            insolvPayList = GenerateDepositSlipRecordsController.fetchRecords('CIH');
        }else if(type == 'vardeCD'){
            insolvPayList = GenerateDepositSlipRecordsController.fetchRecords('CAL');
        }else if(type == 'equitable'){
            insolvPayList = GenerateDepositSlipRecordsController.fetchRecords('ETC');
        }
        
        system.debug('insolvPayList  - ' + insolvPayList);
        system.debug('listUnalloPay - ' + listUnalloPay);
        GenerateSlipController(insolvPayList, listUnalloPay, type);
        */
    }
    
    public void GenerateSlipController(List<Insolvency_payment__c> paymentList, List<Unallocated_Payment__C> unallocatedPayments, String type){
        /*total = 0.00;
        insolvPayMap = new Map<String, Wrapper>();
        //type = ApexPages.currentPage().getParameters().get('type');
        
        if(type != 'Varde_Account_Perticulars' ){
            
            //size = Integer.valueOf(ApexPages.currentPage().getParameters().get('size'));
            
            System.debug(type+'type - '+size);
            System.debug('size - '+insolvAccIds);
            
            if(type == 'varde' ){
                depositAcc = depositAccountMap.get('CIA');
            }else if(type == 'fortress'){
                depositAcc = depositAccountMap.get('CCL');
            }else if(type == 'CIHI'){
                depositAcc = depositAccountMap.get('CIH');
            }else if(type == 'vardeCD'){
                depositAcc = depositAccountMap.get('CAL');
            }else if(type == 'equitable'){
                depositAcc = depositAccountMap.get('ETC');
            }
            
            Set<String> chequeCount = new Set<String>();
            for(Insolvency_Payment__c insolvPay : paymentList){
                Wrapper wrap = new Wrapper();
                wrap.trustee = insolvPay.Remittance__r.Trustee_Name__r.name + ' - CHEQUE: ' + insolvPay.Remittance__r.Cheque_Payment_Reference_Number__c;
                wrap.paymentAmount = insolvPay.Payment_Amount__c;
                if(insolvPay.Payment_Amount__c != null){
                    total += insolvPay.Payment_Amount__c;
                    
                    if(insolvPayMap.containsKey(insolvPay.Remittance__r.Cheque_Payment_Reference_Number__c)){
                        wrap.paymentAmount += insolvPayMap.get(insolvPay.Remittance__r.Cheque_Payment_Reference_Number__c).paymentAmount;
                    }
                    insolvPayMap.put(insolvPay.Remittance__r.Cheque_Payment_Reference_Number__c, wrap);
                    chequeCount.add(insolvPay.Cheque_Payment_Reference_Number__c);
                }
                
                system.debug('insolvPayMap : ' + insolvPayMap);
            }
            
            if(type == 'varde' ){
                List<String> insolvAccNames = new List<String>();
                
                for(Unallocated_Payment__c unalloc : unallocatedPayments){
                    Wrapper wrap = new Wrapper();
                    wrap.trustee = (null == unalloc.Remittance__r.Trustee_Name__r.Name?'':unalloc.Remittance__r.Trustee_Name__r.Name) + ' - CHEQUE: '+unalloc.Remittance__r.Cheque_Payment_Reference_Number__c;
                    
                    if(unalloc.Unallocated_Amount__c != null){
                        wrap.paymentAmount = unalloc.Unallocated_Amount__c;
                        total += unalloc.Unallocated_Amount__c;
                        
                        if(insolvPayMap.containsKey(unalloc.Remittance__r.Cheque_Payment_Reference_Number__c)){
                            wrap.paymentAmount += insolvPayMap.get(unalloc.Remittance__r.Cheque_Payment_Reference_Number__c).paymentAmount;
                        }
                        insolvPayMap.put(unalloc.Remittance__r.Cheque_Payment_Reference_Number__c, wrap);
                        chequeCount.add(unalloc.Remittance__r.Cheque_Payment_Reference_Number__c);
                        
                    }
                }
            }
            
            size = chequeCount.size();
            system.debug('size: ' + size);
            system.debug('insolvPayMap: ' + insolvPayMap);
            
        }else{
            
            Set<String> chequeCount = new Set<String>();
            totalCIA = 0.0;
            totalCCL = 0.0;
            totalCIH = 0.0;
            totalCAL = 0.0;
            totalETC = 0.0;
            insolvPayMapCCL = new Map<String, Wrapper>();
            insolvPayMapCAL = new Map<String, Wrapper>();
            insolvPayMapCIA = new Map<String, Wrapper>();
            insolvPayMapCIH = new Map<String, Wrapper>();
            insolvPayMapETC = new Map<String, Wrapper>();
            
            for(Insolvency_Payment__c insolvPay : insolvPayList){
                Wrapper wrap = new Wrapper();
                wrap.trustee = insolvPay.Remittance__r.Trustee_Name__r.name + ' - CHEQUE: ' + insolvPay.Remittance__r.Cheque_Payment_Reference_Number__c;
                wrap.paymentAmount = insolvPay.Payment_Amount__c;
                system.debug('Portfolio Group Name ' + insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c);
                if(null == insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c){
                    depositAcc = depositAccountMap.get('CIA');
                }else{
                    if(insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('CIA')){
                        depositAcc = depositAccountMap.get('CIA');  
                    }
                    else if(insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('CCL') ||
                            insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('CLP')){
                        depositAcc = depositAccountMap.get('CCL');  
                    }
                    else if(insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('CIH')){
                        depositAcc = depositAccountMap.get('CIH');  
                    }
                    else if(insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('CAL')){
                        depositAcc = depositAccountMap.get('CAL');  
                    }
                    else if(insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('ETC') || 
                            insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('AFF') || 
                            insolvPay.Insolvency_Account__r.Portfolio_Group_Name__c.contains('AFL')){
                        depositAcc = depositAccountMap.get('ETC');  
                    }else {
                        depositAcc = depositAccountMap.get('CIA');  
                    }
                }
                
                wrap.accountName = insolvPay.Insolvency_account__r.name;
                wrap.transit = depositAcc.Transit_Number__c;
                wrap.entity = depositAcc.Entity_Name__c;
                wrap.bankAccountName = depositAcc.Account_Number__c;
                
                if(insolvPay.Payment_Amount__c != null){
                    system.debug(insolvPay.Payment_Amount__c);
                    system.debug('total'+total);
                    
                    total += insolvPay.Payment_Amount__c;
                    wrap.paymentAmount = insolvPay.Payment_Amount__c;
                    //insolvPayMap.put(insolvPay.Id, wrap);
                    
                }
                
                if(depositAcc.name == 'CIA'){
                    insolvPayMapCIA.put(insolvPay.Id, wrap);
                    totalCIA += insolvPay.Payment_Amount__c;
                }else if(depositAcc.name == 'CCL'){
                    insolvPayMapCCL.put(insolvPay.Id, wrap);
                    totalCCL += insolvPay.Payment_Amount__c;
                }else if(depositAcc.name == 'CIH'){
                    insolvPayMapCIH.put(insolvPay.Id, wrap);
                    totalCIH += insolvPay.Payment_Amount__c;
                }else if(depositAcc.name == 'CAL'){
                    insolvPayMapCAL.put(insolvPay.Id, wrap);
                    totalCAL += insolvPay.Payment_Amount__c;
                }else if(depositAcc.name == 'ETC'){
                    insolvPayMapETC.put(insolvPay.Id, wrap);
                    totalETC += insolvPay.Payment_Amount__c;
                }
                
                chequeCount.add(insolvPay.Cheque_Payment_Reference_Number__c);
            }
            
            List<String> insolvAccNames = new List<String>();
            
            depositAcc = depositAccountMap.get('CIA');  
            for(Unallocated_Payment__c unalloc : unallocatedPayments){
                Wrapper wrap = new Wrapper();
                wrap.trustee = unalloc.Remittance__r.Trustee_Name__r.Name + ' - CHEQUE: '+unalloc.Remittance__r.Cheque_Payment_Reference_Number__c;
                depositAcc = depositAccountMap.get('CIA');  
                wrap.accountName = (unalloc.Account_Number__c == null?' - UNALLOCATED':unalloc.Account_Number__c + ' - UNALLOCATED');
                wrap.transit = depositAcc.Transit_Number__c;
                wrap.entity = depositAcc.Entity_Name__c;
                wrap.bankAccountName = depositAcc.Account_Number__c;
                
                if(unalloc.Unallocated_Amount__c != null){
                    wrap.paymentAmount = unalloc.Unallocated_Amount__c;
                    system.debug(unalloc.Unallocated_Amount__c);
                    system.debug('total'+total);
                    totalCIA += unalloc.Unallocated_Amount__c;
                    insolvPayMapCIA.put(unalloc.Id, wrap);
                    
                }
                chequeCount.add(unalloc.Remittance__r.Cheque_Payment_Reference_Number__c);
            }
            size = chequeCount.size();
        }
        
        */
    }
    public Integer getPerticularsSize(){
        return insolvPayMap.keySet().size();
    }
    
    public class Wrapper{
        public String accountName {set;get;}
        public String transit {set;get;}
        public String entity {set;get;}
        public String bankAccountName {set;get;}
        public String trustee{set;get;}
        public Decimal paymentAmount {set;get;}
    }
}