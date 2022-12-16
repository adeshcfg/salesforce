/**************************************************************************************************
*
*  Class:       
*
*  @description : This class will be the utility methods and wrapper classes for the Striplist payment processing
*  @author : A5E Consulting
*  @date : 14-10-2020
*
*************************************************************************************************/
public class StriplistUtil{
    
    //Wrapper class for insolvency payment records
    public class paymentRecordsWrapper{
        public String accountNumber{get;set;}
        public String accountID{get;set;}
        public String debtorName{get;set;}
        public String estateNumber{get;set;}
        public String amount{get;set;}
        public Remittance__c insolvencyAccInstance{get;set;}
    }
    
    public boolean readSuccess {get;set;}
    public List<String> listFieldNames{get;set;}
    paymentRecordsWrapper payWrapRecord;
    
    String fieldValue;
    Integer fieldNumber;
    Map <String, Integer> fieldNumberMap = new Map <String, Integer> ();
    
    public List<paymentRecordsWrapper> deSerializeJSON(String dataAsString){
        List<paymentRecordsWrapper>  listPaymentRecordWrapper = (List<paymentRecordsWrapper>)JSON.deserialize(dataAsString, List<paymentRecordsWrapper>.class);
        return listPaymentRecordWrapper;
    }
    public List<List<paymentRecordsWrapper>> readFromFile(String dataAsString){
        List<List<paymentRecordsWrapper>> listWrapper = new List<List<paymentRecordsWrapper>>();
        listFieldNames = new List<String>();
        readSuccess = FALSE;
        
        try{
            listWrapper = readCSVFile(DataAsString);
            system.debug('listWrapper size in util'+listWrapper.size());
            return listWrapper;
        }
        catch(exception e){
            readSuccess = FALSE;
            system.debug('exception in reading file: '+e);
        }
        return null;
    }  
      
    public List<List<paymentRecordsWrapper>> readCSVFile(String dataAsString) {
        List<List<paymentRecordsWrapper>> listWrapper = new List<List<paymentRecordsWrapper>>();
        List<paymentRecordsWrapper> listWrapperTemp = new List<paymentRecordsWrapper>();
        String[] DataLines = new String[] {};
        listFieldNames = new List<String>();
        DataLines = dataAsString.split('\n');
        string[] csvFieldNames = DataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            listFieldNames.add(csvFieldNames[i].trim());
        }
        for (Integer i = 1; i < DataLines.size(); i++) {
            payWrapRecord = new paymentRecordsWrapper();
            system.debug('DataLines[i] : '+DataLines[i]);
            string[] csvRecordData = DataLines[i].split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
            system.debug('csvRecordData: '+csvRecordData);
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                system.debug('fieldNumber: '+fieldNumber);
                fieldValue = csvRecordData[fieldNumber];
                system.debug('fieldValue: '+fieldValue);
                assignToWrapper(payWrapRecord, fieldValue, fieldName);
            }
            if(listWrapperTemp.size() < 40){
                payWrapRecord.insolvencyAccInstance = new Remittance__c();
                listWrapperTemp.add(payWrapRecord);
            }else{
                payWrapRecord.insolvencyAccInstance = new Remittance__c();
                listWrapperTemp.add(payWrapRecord);
                listWrapper.add(listWrapperTemp);
                listWrapperTemp = new List<paymentRecordsWrapper>();
            }
        }
        if(listWrapperTemp.size() > 0){
            listWrapper.add(listWrapperTemp);
        }
        if(listWrapper.size() > 0){
            readSuccess = TRUE;
        }  
        
        return listWrapper;          
    }
    
    public paymentRecordsWrapper assignToWrapper(paymentRecordsWrapper prdWrp, String fieldValue, String fieldName){       
        if(fieldName.trim() == 'accountNumber'){
            prdWrp.accountNumber = fieldValue.remove('\\n').deleteWhitespace();
        }
        
        if(fieldName.trim() == 'accountID'){
            prdWrp.accountID = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'amount'){
            prdWrp.amount = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'estateNumber'){
            prdWrp.estateNumber = fieldValue.deleteWhitespace();
        }
        
        if(fieldName.trim() == 'debtorName'){
            prdWrp.debtorName = fieldValue.trim().remove('"');            
        }
        return prdWrp;
    }
    
      public void assignBankInformation(String remitID){
    
        List<Remittance__C> remitList = [select id, name, status__C, Bank_Account_Number__c from remittance__C where id =: remitID];
        Remittance__C remit = new Remittance__C();
        
        if(null == remitList || remitList.size() < 1){
            return;
        }else{
            remit = remitList[0];
        }
        
        Set<String> setPortfolioGroupName = new Set<String>();
        
        List<Insolvency_Payment__c> listPaymentstoUpdate = [select id, Deposit_Account_Type__c, 
                                                          Insolvency_Account__r.Portfolio_Group_Name__c 
                                                          from Insolvency_Payment__c
                                                          where remittance__c = :remit.id];
                                                          
        for(Insolvency_Payment__c insPay : listPaymentstoUpdate){
            if(String.isNotBlank(insPay.Insolvency_Account__r.Portfolio_Group_Name__c)){
            
                String PortfolioGroupName = (insPay.Insolvency_Account__r.Portfolio_Group_Name__c).subString(0,3);
                if(PortfolioGroupName == 'CIA' || PortfolioGroupName == 'AAL'){
                    PortfolioGroupName = 'CIH';
                }
                setPortfolioGroupName.add(PortfolioGroupName);
            }else{
                setPortfolioGroupName.add('');
            }
        }
        
        List<Unallocated_Payment__c> listUnallocatedPayments = [SELECT id, name from Unallocated_payment__c where remittance__c = :remitID];

        system.debug('list of portfolio Group Name : ' + setPortfolioGroupName);
        system.debug('Size of unallocated payment : ' + listUnallocatedPayments.size());
        
        Deposit_Accounts__c depositAcc = new Deposit_Accounts__c();
        
        if(listUnallocatedPayments.size() > 0 && setPortfolioGroupName.size() == 0){
            depositAcc = assignBankDetailstoRemit('CIML');
        }else if(listUnallocatedPayments.size() > 0 && setPortfolioGroupName.size() > 0){
            if(setPortfolioGroupName.contains('')){
                depositAcc = assignBankDetailstoRemit('CIML');
            }else if(setPortfolioGroupName.contains('CIH')){
                if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||
                   setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL')  ||
                       setPortfolioGroupName.contains('CFL')){
                       depositAcc = assignBankDetailstoRemit('CIML');
                   }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||
                            setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){
                                depositAcc = assignBankDetailstoRemit('AFSI');
                   }else{
                       depositAcc = assignBankDetailstoRemit('CIML');
                   }
            }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||
                     setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL')  ||
                       setPortfolioGroupName.contains('CFL')){
                         depositAcc = assignBankDetailstoRemit('CIML');
                     }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||
                              setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){
                                  depositAcc = assignBankDetailstoRemit('AFSI');
                     }else{
                         depositAcc = assignBankDetailstoRemit('CIML');
                     }
        }else if(listUnallocatedPayments.size() == 0 && setPortfolioGroupName.size() > 0){
            
            if(setPortfolioGroupName.contains('')){
                depositAcc = assignBankDetailstoRemit('CIML');
            }else if(setPortfolioGroupName.size() > 2){
                
                if(setPortfolioGroupName.contains('CIH')){
                    if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||
                       setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL')  ||
                       setPortfolioGroupName.contains('CFL')){
                           depositAcc = assignBankDetailstoRemit('CIML');
                       }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||
                                setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){
                                    depositAcc = assignBankDetailstoRemit('AFSI');
                                }else{
                                    depositAcc = assignBankDetailstoRemit('CIML');
                                }
                }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||
                         setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL')  ||
                       setPortfolioGroupName.contains('CFL')){
                             depositAcc = assignBankDetailstoRemit('CIML');
                         }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||
                                  setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){
                                      depositAcc = assignBankDetailstoRemit('AFSI');
                                  }else{
                                      depositAcc = assignBankDetailstoRemit('CIML');
                                  }
            }else if(setPortfolioGroupName.size() == 2){
                if(setPortfolioGroupName.contains('CCL') && setPortfolioGroupName.contains('CLP')){
                    depositAcc = assignBankDetailstoRemit('CCL');
                }else if(setPortfolioGroupName.contains('ETC') && setPortfolioGroupName.contains('AFF')){
                    depositAcc = assignBankDetailstoRemit('ETC');
                }else if(setPortfolioGroupName.contains('CIH')){
                    if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||
                       setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL')  ||
                       setPortfolioGroupName.contains('CFL')){
                           depositAcc = assignBankDetailstoRemit('CIML');
                       }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||
                                setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){
                                    depositAcc = assignBankDetailstoRemit('AFSI');
                                }else{
                                    depositAcc = assignBankDetailstoRemit('CIML');
                                }
                }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||
                         setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL')  ||
                       setPortfolioGroupName.contains('CFL')){
                             depositAcc = assignBankDetailstoRemit('CIML');
                         }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||
                                  setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){
                                      depositAcc = assignBankDetailstoRemit('AFSI');
                                  }else{
                                      depositAcc = assignBankDetailstoRemit('CIML');
                                  }
                
            }else if(setPortfolioGroupName.size() == 1){
                if(setPortfolioGroupName.contains('CCL')){
                    depositAcc = assignBankDetailstoRemit('CCL');
                }else if(setPortfolioGroupName.contains('CLP')){
                    depositAcc = assignBankDetailstoRemit('CCL');
                }else if(setPortfolioGroupName.contains('CIA')){
                    depositAcc = assignBankDetailstoRemit('CIH');
                }else if(setPortfolioGroupName.contains('AFF')){
                    depositAcc = assignBankDetailstoRemit('ETC');
                }else if(setPortfolioGroupName.contains('AFL')){
                    depositAcc = assignBankDetailstoRemit('AFL');
                }else if(setPortfolioGroupName.contains('ETC')){
                    depositAcc = assignBankDetailstoRemit('ETC');
                }else if(setPortfolioGroupName.contains('CIH')){
                    depositAcc = assignBankDetailstoRemit('CIH');
                }else if(setPortfolioGroupName.contains('CAL')){
                    depositAcc = assignBankDetailstoRemit('CAL');
                }else if(setPortfolioGroupName.contains('AAL')){
                    depositAcc = assignBankDetailstoRemit('CIH');
                }else if(setPortfolioGroupName.contains('CFL')){
                    depositAcc = assignBankDetailstoRemit('CFL');
                }else{
                    depositAcc = assignBankDetailstoRemit('CIML');
                }
            }else{
                depositAcc = assignBankDetailstoRemit('CIML');
            }
        }
        
        remit.Bank_Account_Number__c = depositAcc.Account_Number__c;
        remit.Transit_Code__c = depositAcc.Transit_Number__c;
        remit.Entity_Name__c = depositAcc.Entity_Name__c;
        remit.Deposit_Account_Name__c = depositAcc.Name;
        
        Application_Config_Settings__c acs = Application_Config_Settings__c.getOrgDefaults();
        
        acs.Run_Remittance_Validation__c = False;
        update acs;
        
        update remit;
        
        acs.Run_Remittance_Validation__c = True;
        update acs;
        
        if(remit.Deposit_Account_Name__c <> 'CIML' && remit.Deposit_Account_Name__c <> 'AFSI'){
            
            for(Insolvency_Payment__c insolPay : listPaymentstoUpdate){
                insolPay.Deposit_Account_Type__c = remit.Deposit_Account_Name__c;
            }
        }else{
            for(Insolvency_Payment__c insolPay : listPaymentstoUpdate){
                Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
                Deposit_Accounts__c depositAccRecord = new Deposit_Accounts__c();
                system.debug('Deposit_Accounts__c : ' + insolPay.Insolvency_Account__r.Portfolio_Group_Name__c);
                if(null != insolPay.Insolvency_Account__r.Portfolio_Group_Name__c){
                    depositAccRecord = depositAccountMap.get((insolPay.Insolvency_Account__r.Portfolio_Group_Name__c).subString(0,3));
                }
                if(null == insolPay.Insolvency_Account__r.Portfolio_Group_Name__c ||
                   null == depositAccRecord ){
                       depositAccRecord = depositAccountMap.get('CIML');
                   }
                
                insolPay.Deposit_Account_Type__c = depositAccRecord.Name;
            }
        }
        
        update listPaymentstoUpdate;
        
    }
    
     public static Deposit_Accounts__c assignBankDetailstoRemit(String strDeposAcc){
        Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();
        Deposit_Accounts__c depositAcc = new Deposit_Accounts__c();
        
        depositAcc = depositAccountMap.get(strDeposAcc);
        /*remit.Bank_Account_Number__c = depositAcc.Account_Number__c;
        remit.Transit_Code__c = depositAcc.Transit_Number__c;
        remit.Entity_Name__c = depositAcc.Entity_Name__c;
        remit.Deposit_Account_Name__c = depositAcc.Name;*/
        
        return depositAcc;
    }
}