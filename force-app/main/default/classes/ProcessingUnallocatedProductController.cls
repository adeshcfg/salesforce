public class ProcessingUnallocatedProductController {

    public Product_Payments__C insolvPay {set;get;}
    public Unallocated_Payment__c unAloccPay{set;get;}
    public Boolean isAllocated {set;get;}
    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc {set;get;}
    
    public ProcessingUnallocatedProductController(ApexPages.StandardController controller){
        insolvPay = new Product_Payments__C();
        if(ApexPages.currentPage().getParameters().get('insolvAcc') != null)
        insolvPay.CCS_Account__c = ApexPages.currentPage().getParameters().get('insolvAcc');
        unAloccPay = [SELECT id, Remittance__c, Remittance__r.Cheque_Payment_Reference_Number__c, Remittance__r.Payment_Posting_Date__c, 
                      Allocated__c, Unallocated_Amount__c, Account_Number__c, Deposit_Slip__c, Is_Payment_Remitted__c, Cheque_Number__c, Payment_Posting_Date__c, deposit_Slip__r.createdDate,
                      Unallocated_Fairshare_Amount__c
                      FROM Unallocated_Payment__c WHERE ID=: ApexPages.currentPage().getParameters().get('id')];
        if(unAloccPay.Allocated__c){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Unallocated payment is allocated to another CCS Account '+ unAloccPay.Account_Number__c);
             ApexPages.addMessage(myMsg);
        }
        if(unAloccPay.Is_Payment_Remitted__c){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Unallocated payment is remitted back to bank ');
             ApexPages.addMessage(myMsg);
        }
    }
    
    public void save(){ 
        insolvPay.Dividend__C = unAloccPay.Remittance__c;
        insolvPay.Payment_Amount__c = unAloccPay.Unallocated_Amount__c;
        if(unAloccPay.Remittance__c == null){
        insolvPay.Payment_Posting_Date__c = unAloccPay.Payment_Posting_Date__c;
        insolvPay.Cheque_Number__c = unAloccPay.Cheque_Number__c;
        }else{
        insolvPay.Payment_Posting_Date__c = unAloccPay.Remittance__r.Payment_Posting_Date__c;
        insolvPay.Cheque_Number__c = unAloccPay.Remittance__r.Cheque_Payment_Reference_Number__c;     
        }
        insolvPay.Deposit_Slip__c = unAloccPay.Deposit_Slip__c;
        insolvPay.Unallocated_Payment__c = unAloccPay.id;
        insolvPay.FairShare_Amount__c = unAloccPay.Unallocated_Fairshare_Amount__c;
        String month = ((System.today()).Month() < 10 ? ('0' + (System.today()).Month()) : (''+(System.today()).Month()));
        insolvPay.Payment_Posting_Month__c = ''+ (System.today()).Year()+month;
        
        insolvPay.recordTypeid =  [select id from RecordType where SobjectType = 'Product_Payments__c' and developername = 'CCS_Dividend_Payment'].id;
        
        Product__c insolAcc = [select id, name, Portfolio_Group_Name__c 
                                         from Product__c where id = :insolvPay.CCS_Account__C];
        System.debug(insolAcc);  
        
        if(insolAcc.Portfolio_Group_Name__c != null){
            insolvPay.Deposit_Account_Type__c = (insolAcc.Portfolio_Group_Name__c).subString(0,3);
        }else{
            insolvPay.Deposit_Account_Type__c = 'CIML';
        }
        try{
            Application_Config_Settings__c appConfig = Application_Config_Settings__c.getOrgDefaults();
            appConfig.Do_Not_Run_Payment_Validation__c = true;
            update appConfig;
            insert insolvPay;
            
            System.debug(insolAcc);
            
            appConfig.Do_Not_Run_Payment_Validation__c = false;
            update appConfig;
            
            unAloccPay.Account_Number__c = [SELECT Name FROM Product__c WHERE ID =:insolvPay.CCS_Account__c LIMIT 1].Name;
            unAloccPay.Allocated__c = true;
            update unAloccPay;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'CCS Account is allocated now.'));
            
            DateTime dT = System.now();
            Date todayDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            if(null != unAloccPay.Deposit_Slip__c){
                
                DateTime dateTimeValue = unAloccPay.deposit_Slip__r.createdDate;
                Date createdDatewithoutTime = date.newinstance(dateTimeValue.year(), dateTimeValue.month(), dateTimeValue.day());
            
                if(createdDatewithoutTime <> todayDate ){
                    return;
                }
            }
            
            List<Remittance__c> remList = [select id, name, Deposit_Account_Name__c from Remittance__C where id = :unAloccPay.Remittance__c];
            Remittance__c rem = new Remittance__c();
            if(remList.size()==1){
                rem = remList.get(0);
            }else{
                return;
            }
                
            
            
            List<Unallocated_payment__C> listUnallocPay = [select id from Unallocated_payment__C where Allocated__c = FALSE and Remittance__c = :rem.id ];
            
            List<AggregateResult> listAggregateResults = [select count(id) total, Deposit_Account_Type__c 
                                              from Product_Payments__C
                                              where Dividend__c = :unAloccPay.Remittance__c
                                              group by Deposit_Account_Type__c ];
            
            List<String> listDepositAccountName = new List<String>();
            for(AggregateResult aggrRecord : listAggregateResults ){
                listDepositAccountName.add((String)aggrRecord.get('Deposit_Account_Type__c'));
            }
            system.debug('Deposit Slip : ' + listAggregateResults + listAggregateResults.size());
            system.debug('Deposit Name : ' + listDepositAccountName + listDepositAccountName.size());
            system.debug('UnallocPay Size : ' + listUnallocPay + listUnallocPay.size());
            
            if(listUnallocPay.size() == 0 && listAggregateResults.size() == 0){
                //Do Nothing
            }else if(listUnallocPay.size() > 0 && listAggregateResults.size() == 0){
                rem.Deposit_Account_Name__c = insolvPay.Deposit_Account_Type__c;
            }else if(listUnallocPay.size() > 0 && listAggregateResults.size() == 1){
                if(listDepositAccountName.contains('CCL') || listDepositAccountName.contains('CLP') ||
                   listDepositAccountName.contains('CIA') || listDepositAccountName.contains('CAL') ||
                   listDepositAccountName.contains('CIH')){
                    rem.Deposit_Account_Name__c = 'CIML';
                }else if(listDepositAccountName.contains('ETC') || listDepositAccountName.contains('AFF') ||
                        listDepositAccountName.contains('AAL') || listDepositAccountName.contains('AFL')){
                    rem.Deposit_Account_Name__c = 'AFSI';
                }
                
            }else if(listUnallocPay.size() > 0 && listAggregateResults.size() > 1){
                
                if(listDepositAccountName.contains('CIH')){
                    if(listDepositAccountName.contains('CCL') || listDepositAccountName.contains('CLP') ||
                      listDepositAccountName.contains('CIA') || listDepositAccountName.contains('CAL') ){
                        rem.Deposit_Account_Name__c = 'CIML';
                    }else if(listDepositAccountName.contains('ETC') || listDepositAccountName.contains('AFF') ||
                            listDepositAccountName.contains('AAL') || listDepositAccountName.contains('AFL')){
                        rem.Deposit_Account_Name__c = 'AFSI';
                    }
                }else if(listDepositAccountName.contains('CCL') || listDepositAccountName.contains('CLP') ||
                        listDepositAccountName.contains('CIA') || listDepositAccountName.contains('CAL') ){
                    rem.Deposit_Account_Name__c = 'CIML';
                }else if(listDepositAccountName.contains('ETC') || listDepositAccountName.contains('AFF') ||
                        listDepositAccountName.contains('AAL') || listDepositAccountName.contains('AFL')){
                    rem.Deposit_Account_Name__c = 'AFSI';
                }
            }else if(listUnallocPay.size() == 0 && listAggregateResults.size() == 1){
                if(listDepositAccountName[0] == insolvPay.Deposit_Account_Type__c){
                    rem.Deposit_Account_Name__c = insolvPay.Deposit_Account_Type__c;
                }else {
                    //No Changes
                }
            }else if(listUnallocPay.size() == 0 && listAggregateResults.size() > 1){
                if(listDepositAccountName.contains('CCL') && listDepositAccountName.contains('CLP')){
                    rem.Deposit_Account_Name__c = 'CCL';
                }else if(listDepositAccountName.contains('ETC') && listDepositAccountName.contains('AFF')){
                    rem.Deposit_Account_Name__c = 'ETC';
                }else
                if(listDepositAccountName.contains('CIH')){
                    if(listDepositAccountName.contains('CCL') || listDepositAccountName.contains('CLP') ||
                      listDepositAccountName.contains('CIA') || listDepositAccountName.contains('CAL') ){
                        rem.Deposit_Account_Name__c = 'CIML';
                    }else if(listDepositAccountName.contains('ETC') || listDepositAccountName.contains('AFF') ||
                            listDepositAccountName.contains('AAL') || listDepositAccountName.contains('AFL')){
                        rem.Deposit_Account_Name__c = 'AFSI';
                    }
                }else if(listDepositAccountName.contains('CCL') || listDepositAccountName.contains('CLP') ||
                        listDepositAccountName.contains('CIA') || listDepositAccountName.contains('CAL') ){
                    rem.Deposit_Account_Name__c = 'CIML';
                }else if(listDepositAccountName.contains('ETC') || listDepositAccountName.contains('AFF') ||
                        listDepositAccountName.contains('AAL') || listDepositAccountName.contains('AFL')){
                    rem.Deposit_Account_Name__c = 'AFSI';
                }
            }
            
            Application_Config_Settings__c acs = Application_Config_Settings__c.getOrgDefaults();
            system.debug('acs.Final_Deposit_Slip__c : ' + acs.Final_Deposit_Slip__c );
            if(acs.Final_Deposit_Slip__c == null || acs.Final_Deposit_Slip__c <= system.TODAY()){
                if(null != rem.Deposit_Account_Name__c ){
                    depositAcc = depositAccountMap.get(rem.Deposit_Account_Name__c);
                }else{
                    depositAcc = depositAccountMap.get('CIML');
                } 
                 rem.Bank_Account_Number__c = depositAcc.Account_Number__c;
                 rem.Transit_Code__c = depositAcc.Transit_Number__c;
                 rem.Entity_Name__c = depositAcc.Entity_Name__c;
                 rem.Deposit_Account_Name__c = depositAcc.Name;
                
                acs.Run_Remittance_Validation__c = false;
                update acs;
                update rem;
                acs.Run_Remittance_Validation__c = true;
                update acs;
            }
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage())); 
            system.debug(ex);       
        }
    }
}