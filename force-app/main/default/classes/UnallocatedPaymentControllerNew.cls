public class UnallocatedPaymentControllerNew {

    public Insolvency_Payment__c insolvPay {set;get;}
    public Product_Payments__c prodPay  {set;get;}
    public Unallocated_Payment__c unAloccPay{set;get;}
    public Boolean isAllocated {set;get;}
    Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
    public Deposit_Accounts__c depositAcc {set;get;}
    public String selected  {set;get;}
    public List<SelectOption> accList{set;get;}
    
    public UnallocatedPaymentControllerNew(ApexPages.StandardController controller){
    //public UnallocatedPaymentControllerNew(){
        insolvPay = new Insolvency_Payment__c();
        prodPay = new Product_Payments__c();
        if(ApexPages.currentPage().getParameters().get('insolvAcc') != null)
        insolvPay.Insolvency_Account__c = ApexPages.currentPage().getParameters().get('insolvAcc');
        
        if(ApexPages.currentPage().getParameters().get('ccsAcc') != null)
        prodPay.CCS_Account__c = ApexPages.currentPage().getParameters().get('ccsAcc');
        
        unAloccPay = [SELECT id, Payment_Reference_Number__c, Payment_Date__c, Remittance__c, Remittance__r.Cheque_Payment_Reference_Number__c, Remittance__r.Payment_Posting_Date__c, 
                      Allocated__c, Unallocated_Amount__c, Account_Number__c, Deposit_Slip__c, Is_Payment_Remitted__c, Cheque_Number__c, Payment_Posting_Date__c, deposit_Slip__r.createdDate,
                      Unallocated_Fairshare_Amount__c,Is_Payments_Reversed__c,Remitted_Back_To__r.Name, SOR_Allocated_Date__c, SOR_Cheque_Reference_Number__c, Allocated_To__c 
                      FROM Unallocated_Payment__c WHERE ID=: ApexPages.currentPage().getParameters().get('id')];
        if(unAloccPay.Allocated__c){
            ApexPages.Message myMsg;
            if(unAloccPay.Allocated_To__c == 'Insolvency' || unAloccPay.Allocated_To__c == 'CCS'){
                myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Unallocated payment is allocated to another Account '+ unAloccPay.Account_Number__c);
            }else{
                myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Unallocated payment is allocated to another SOR - '+ unAloccPay.Allocated_To__c );
            }
            ApexPages.addMessage(myMsg);
        }
        if(unAloccPay.Is_Payment_Remitted__c){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Unallocated payment is remitted back to ' + unAloccPay.Remitted_Back_To__r.Name);
             ApexPages.addMessage(myMsg);
        }
       if(unAloccPay.Is_Payments_Reversed__c != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Unallocated payment is reversed back due to ' + unAloccPay.Is_Payments_Reversed__c );
             ApexPages.addMessage(myMsg);
        }
        accList = new List<SelectOption>() ;
        //accList.addAll();
        List<Schema.PicklistEntry> ple = (Unallocated_Payment__c.Allocated_To__c.getDescribe()).getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            accList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        } 
        selected = accList[0].getValue();
        /*
        accList.add(new SelectOption('Inslovency' , 'Inslovency')) ;
        accList.add(new SelectOption('CCS' , 'CCS')) ;
        accList.add(new SelectOption('FDR' , 'FDR'));
        accList.add(new SelectOption('Megasys' , 'Megasys'));
        accList.add(new SelectOption('Debtnext' , 'Debtnext'));
        */
        
    }
    
    public void check(){
        system.debug('test '+selected);
            if(selected == 'Insolvency'){
                if(insolvPay.Insolvency_Account__c == NULL){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Insolvency Account'));        
                    return;
                }
                insolpaysave();
            }
         
        if(selected == 'CCS'){
            if(prodPay.CCS_Account__c== NULL){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select CCS Account'));
                return;
            }
            prodpaysave();
        }

            if(selected == 'FDR' || selected == 'Megasys' || selected == 'Distressed'){
                if(unAloccPay.SOR_Allocated_Date__c== NULL){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please provide Payment Date')); 
                    return;       
                }
                if(unAloccPay.SOR_Cheque_Reference_Number__c == NULL){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please provide Payment Reference Number'));
                    return;
                }
                sorSave();
            }
    }
    
    public void insolpaysave(){
        
        insolvPay.Remittance__c = unAloccPay.Remittance__c;
        insolvPay.Payment_Amount__c = unAloccPay.Unallocated_Amount__c;
        if(unAloccPay.Remittance__c == null){
        insolvPay.Payment_Posting_Date__c = unAloccPay.Payment_Posting_Date__c;
        insolvPay.Cheque_Payment_Reference_Number__c = unAloccPay.Cheque_Number__c; 
        }else{
        insolvPay.Payment_Posting_Date__c = unAloccPay.Remittance__r.Payment_Posting_Date__c;
        insolvPay.Cheque_Payment_Reference_Number__c = unAloccPay.Remittance__r.Cheque_Payment_Reference_Number__c;  
        }
        insolvPay.Deposit_Slip__c = unAloccPay.Deposit_Slip__c;
        insolvPay.Unallocated_Payment__c = unAloccPay.id;
        String month = ((System.today()).Month() < 10 ? ('0' + (System.today()).Month()) : (''+(System.today()).Month()));
        insolvPay.Payment_Posting_Month__c = ''+ (System.today()).Year()+month;
        insolvPay.recordTypeid =  [select id from RecordType where SobjectType = 'Insolvency_payment__c' and name like '%Remittance%'].id;
        
        Insolvency_Account__C insolAcc = [select id, name, Portfolio_Group_Name__c 
                                         from Insolvency_account__c where id = :insolvPay.Insolvency_Account__c]; 
                                         
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
            appConfig.Do_Not_Run_Payment_Validation__c = false;
            update appConfig;
            
            unAloccPay.Account_Number__c = [SELECT Name FROM Insolvency_Account__c WHERE ID =:insolvPay.Insolvency_Account__c LIMIT 1].Name;
            unAloccPay.Allocated__c = true;
            unAloccPay.Allocated_To__c = selected;
            update unAloccPay;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Insolvency Account is allocated now.'));
            
            DateTime dT = System.now();
            Date todayDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            
            if(null != unAloccPay.Deposit_Slip__c){
                DateTime dateTimeValue = unAloccPay.deposit_Slip__r.createdDate;
                Date createdDatewithoutTime = date.newinstance(dateTimeValue.year(), dateTimeValue.month(), dateTimeValue.day());
            
                if(createdDatewithoutTime <> todayDate ){
                    return;
                }
            }
              
            List<Remittance__c> remList = [select id, name, Deposit_Account_Name__c from REmittance__C where id = :unAloccPay.Remittance__c];
            Remittance__c rem = new Remittance__c();
            if(remList.size()==1){
                rem = remList.get(0);
            }else{
                return;
            }
            
           
            List<Unallocated_payment__C> listUnallocPay = [select id from Unallocated_payment__C where Allocated__c = FALSE and Remittance__c = :rem.id ];
            
            List<AggregateResult> listAggregateResults = [select count(id) total, Deposit_Account_Type__c 
                                              from Insolvency_payment__C
                                              where remittance__C = :unAloccPay.Remittance__c
                                              group by Deposit_Account_Type__c ];
            
            List<String> listDepositAccountName = new List<String>();
            for(AggregateResult aggrRecord : listAggregateResults ){
                listDepositAccountName.add((String)aggrRecord.get('Deposit_Account_Type__c'));
            }
            system.debug('Deposit Slip : ' + listAggregateResults);
            
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
        }
    }
    public void prodpaysave(){
        
        prodPay.Dividend__C = unAloccPay.Remittance__c;
        prodPay.Payment_Amount__c = unAloccPay.Unallocated_Amount__c;
        if(unAloccPay.Remittance__c == null){
            prodPay.Payment_Posting_Date__c = unAloccPay.Payment_Posting_Date__c;
            prodPay.Cheque_Number__c = unAloccPay.Cheque_Number__c;
        }else{
            prodPay.Payment_Posting_Date__c = unAloccPay.Remittance__r.Payment_Posting_Date__c;
            prodPay.Cheque_Number__c = unAloccPay.Remittance__r.Cheque_Payment_Reference_Number__c;     
        }
        prodPay.Deposit_Slip__c = unAloccPay.Deposit_Slip__c;
        prodPay.Unallocated_Payment__c = unAloccPay.id;
        prodPay.FairShare_Amount__c = unAloccPay.Unallocated_Fairshare_Amount__c;
        String month = ((System.today()).Month() < 10 ? ('0' + (System.today()).Month()) : (''+(System.today()).Month()));
        prodPay.Payment_Posting_Month__c = ''+ (System.today()).Year()+month;
        
        prodPay.recordTypeid =  [select id from RecordType where SobjectType = 'Product_Payments__c' and developername = 'CCS_Dividend_Payment'].id;
        
        Product__c insolAcc = [select id, name, Portfolio_Group_Name_Formula__c 
                                         from Product__c where id = :prodPay.CCS_Account__C];
        System.debug(insolAcc);  
        
        if(insolAcc.Portfolio_Group_Name_Formula__c != null){
            prodPay.Deposit_Account_Type__c = (insolAcc.Portfolio_Group_Name_Formula__c).subString(0,3);
        }else{
            prodPay.Deposit_Account_Type__c = 'CIML';
        }
        try{
            Application_Config_Settings__c appConfig = Application_Config_Settings__c.getOrgDefaults();
            appConfig.Do_Not_Run_Payment_Validation__c = true;
            update appConfig;
            insert prodPay;
            
            System.debug(insolAcc);
            
            appConfig.Do_Not_Run_Payment_Validation__c = false;
            update appConfig;
            
            unAloccPay.Account_Number__c = [SELECT Name FROM Product__c WHERE ID =:prodPay.CCS_Account__c LIMIT 1].Name;
            unAloccPay.Allocated__c = true; 
            unAloccPay.Allocated_To__c = selected;
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
                rem.Deposit_Account_Name__c = prodPay.Deposit_Account_Type__c;
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
                if(listDepositAccountName[0] == prodPay.Deposit_Account_Type__c){
                    rem.Deposit_Account_Name__c = prodPay.Deposit_Account_Type__c;
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
            system.debug('exception'+ex);       
        }
    }
    
    public void sorSave(){
        
        try{
            unAloccPay.Allocated__c = true;
            unAloccPay.Allocated_To__c = selected;
            update unAloccPay;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Payment Reference Number and Payment Date is updated successfully')); 
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));        
        }
    }
}