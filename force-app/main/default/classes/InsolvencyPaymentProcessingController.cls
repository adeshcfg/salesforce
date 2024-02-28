/************************************************************************************************** 
*   
*  Class:   InsolvencyPaymentProcessingController   
*   
*  @description : This is a controller class to manage Insolvency Payment Processing    
*  @author : A5E Consulting 
*  @date : 09/06/2018   
*   
*************************************************************************************************/  
public class InsolvencyPaymentProcessingController{ 
        
    public String insolvencyAccNumbers{set;get;}    
    public Id insolvAccId ; 
    public Boolean showSearch{set;get;} 
    public List<Attachment> attList;    
    public Set<Id> ProdAccIds {set;get;}    
    public List<Wrapper> wrapList{set;get;} 
    public List<Wrapper> wrapListWithAmount{set;get;}   // variable that holds all selected payment records 
    public List<Wrapper> wrapListWithZeroAmount{set;get;}   // variable that holds all search result records    
    public List<AttachWrap> listAttachWrap{get;set;}    
    
    public String calAmountDiffMsg {set;get;}   
        
    public Decimal totalAmount = 0.00;  
        
    public Remittance__c remit{set;get;}    
    List<Insolvency_Payment__c> productPaymentList = new List<Insolvency_Payment__c>(); 
    public Boolean showViewButton {set;get;}    
    public boolean refreshParent{get;set;}  
    //Remitance Record Type 
    private RecordType remittanceRecType;   
        
    Public static Boolean stopDuplicateScreenCheck{get;set;}    
    public String FetchUpdatedRecord{get;set;}  
    //Attachment for dividend   
    public List<Attachment> attachDocument{get;set;}    
    public String errorMsgTrustee{get;set;} 
        
    //Constructor   
    public InsolvencyPaymentProcessingController(ApexPages.StandardController controller) { 
        ProdAccIds = new Set<Id>(); 
        remit = new Remittance__c();    
            
        FetchUpdatedRecord = '';    
        refreshParent = false;  
        unAllocPaymentList = new List< Unallocated_Payment__c>();   
        //Remitance Record Type - fetch 
        remittanceRecType = [Select Id  
                             from RecordType    
                             where  
                             SObjectType = 'Insolvency_Payment__c' and  
                             DeveloperName = 'Remittance']; 
            
        showSearch = true;  
            
        String remitID = ApexPages.currentPage().getParameters().get('id'); 
            
        remit = [SELECT Id, name,Deposit_Account_Name__c,Cheque_Amount__c, Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c,     
                 Status__c, Trustee_Name__c, Trustee_Name__r.name, Email_to_Case_Reference_Number__c, Assigned_To__c    
                 FROM Remittance__c WHERE Id =: remitID];   
            
        // Validation on Remittance fields  
        String msg='';  
        system.debug('remit.Cheque_Payment_Reference_Number__c '+remit.Cheque_Payment_Reference_Number__c); 
        if(remit.Cheque_Payment_Reference_Number__c == NULL){   
            msg = 'Cheque Payment Reference Number';    
        }   
        if(remit.Cheque_Amount__c == NULL){ 
            if(msg.length() >0 && remit.Payment_Posting_Date__c == NULL){   
                    
                msg = msg+',';  
            }   
            if(remit.Payment_Posting_Date__c != NULL && remit.Cheque_Amount__c == NULL && remit.Cheque_Payment_Reference_Number__c == NULL){    
                msg = msg+' and';   
            }   
                
            msg = msg+' Dividend Amount,';  
        }   
        //if(remit.Payment_Posting_Date__c == NULL){    
                
            //msg = msg+' Payment Posting Date';    
        //} 
        if(remit.Trustee_Name__c == NULL){  
            if(msg.length() >0){    
                msg = msg+' and';   
            }   
            msg = msg+' Trustee Name';  
        }   
        if(msg.length() > 0){   
            msg = msg+' data is not available'; 
            showSearch = False; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg)); 
        }   
            
        system.debug('allocatedAccountNumbers'+allocatedAccountNumbers);    
        fetchAttachment();  
        searchExistingPaymentRecords(); 
    }   
        
    // Method to search if there is any Insolvency payment records exist for Remittance 
    public void searchExistingPaymentRecords(){ 
        wrapList = new List<Wrapper>(); 
        wrapListWithAmount = new List<Wrapper>();   
        wrapListWithZeroAmount = new List<Wrapper>();   
        // Fetch all existing insolvency payments   
        List<Insolvency_Payment__c> existingProdPayList = new List<Insolvency_Payment__c>([SELECT Id,   
                                                                                       Insolvency_Account__c,   
                                                                                       Payment_Amount__c,   
                                                                                       Insolvency_Account__r.Trustee_Office__c  
                                                                                       FROM Insolvency_Payment__c   
                                                                                       WHERE remittance__c =: remit.Id ORDER BY Name ASC]); 
        List<Id> prodAccIDs = new List<Id>();   
        Map<Id, Insolvency_Payment__c> prodPayMap = new Map<Id, Insolvency_Payment__c>();   
        Decimal tempTotal = 0;  
        Set<ID> differentTrusties = new Set<ID>();  
        for(Insolvency_Payment__c prodPay : existingProdPayList){   
                
            prodAccIDs.add(prodPay.Insolvency_Account__c);  
            prodPayMap.put(prodPay.Insolvency_Account__c, prodPay); 
            if(remit.Trustee_Name__r.name  != prodPay.Insolvency_Account__r.Trustee_Office__c){ 
                differentTrusties.add(prodPay.Insolvency_Account__c);   
            }   
        }   
            
        List<ID> differentTrustiesList = new List<ID>(differentTrusties);   
        if(differentTrusties.size() > 0){   
            List<Insolvency_Account__C> listAccountsMismatchTrustee = [SELECT ID, Name from Insolvency_Account__C where ID IN : differentTrustiesList]; 
            String errorMsgTrustee = 'Trustee Mismatch with Dividend Trustee : ';   
            Integer count = 0;  
            for(Insolvency_Account__C insolAcc : listAccountsMismatchTrustee){  
                 count ++;  
                system.debug('Count : ' + Count);   
                errorMsgTrustee += ' <a href="'+System.Url.getSalesforceBaseURL().toExternalForm() +'/'+insolAcc.Id+'" target="_blank">'+insolAcc.Name+'</a>,'; 
                
                if(count == 10){    
                    errorMsgTrustee += '<br/>'; 
                   count=0; 
                }   
            }   
            errorMsgTrustee = errorMsgTrustee.removeEnd(',');   
            errorMsgTrustee = '<p>' + errorMsgTrustee + '</p>'; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsgTrustee));   
            //return;   
        }   
            
        for(Insolvency_Account__C prodAcc : [SELECT Id, Name, Bank_Name__c, Debtor_1_Estate_Number__c, Trustee_Company__c,  
                                               Borrower_Primary__c, Debtor__c, Asset_Status__c, Previous_Account_Reference__c,  
                                               Portfolio_Group_Name__c  
                                              FROM Insolvency_Account__C    
                                              WHERE Id IN :prodAccIDs   
                                              ORDER BY Name ASC LIMIT 500]){    
                                        
                                      system.debug('if condition : ' + prodAccIds.contains(prodAcc.Id));    
                                      if(prodAccIds.contains(prodAcc.Id)){  
                                            
                                          allocatedAccountNumbers.add(prodAcc.Name);    
                                          Insolvency_Payment__c productPayment = prodPayMap.get(prodAcc.Id);    
                                          productPayment.Remittance__c = remit.Id;  
                                          ProdAccIds.add(prodAcc.Id);   
                                            
                                          Wrapper wrap = new Wrapper(); 
                                          wrap.productPay = productPayment; 
                                          wrap.key = prodAcc.Id;    
                                          //wrap.check = true;  
                                          wrap.productAcc = prodAcc;    
                                          if(wrapList.size() < 999){    
                                              //wrapList.add(wrap); 
                                              checkAndAddToWrapperList(wrap);   
                                          }else{    
                                              break;    
                                          } 
                                            
                                          if(productPayment.Payment_Amount__c != null){ 
                                              tempTotal = tempTotal+ productPayment.Payment_Amount__c;  
                                          } 
                                      } 
                                  } 
            
        unAllocPaymentList = [SELECT Id, Account_Number__c, Bank_Name__c, Debtor_Name__c, Estate_Number__c, Remittance__c,  
                              Unallocated_Amount__c, Allocated__c   
                              FROM Unallocated_Payment__c   
                              WHERE Remittance__c =: remit.Id   
                              AND Allocated__c = FALSE LIMIT 1000]; 
            
        tempTotal+= getUnallocatedAmount(); 
        system.debug('getUnallocatedAmount()=='+getUnallocatedAmount());    
        if(tempTotal != NULL && remit.Cheque_Amount__c != NULL && (tempTotal != remit.Cheque_Amount__c) && prodAccIDs.size() >0){   
            String calAmountDiffMsg='Total Amount entered does not match with the Dividend Amount.';    
            if(remit.Cheque_Amount__c < tempTotal){ 
                calAmountDiffMsg += ' (▲ exceeds $'+(tempTotal - remit.Cheque_Amount__c).toPlainString()+')';   
            }else if(remit.Cheque_Amount__c > tempTotal){   
                calAmountDiffMsg += ' (▼ lower $'+(remit.Cheque_Amount__c - tempTotal).toPlainString()+')'; 
            }   
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, calAmountDiffMsg));  
        }   
    }   
        
    List<String> allocatedAccountNumbers = new List<String>();  
        
    // Method search for given Insolvency account, Estate Number, Primary Borrower and Debtor   
    public PageReference searchInsolvencyAccounts(){    
        wrapList = new List<Wrapper>(); 
        // add selected and non selected results to wraplist variable in order to process   
        if(!wrapListWithAmount.isEmpty()){  
            wrapList.addAll(wrapListWithAmount);    
            wrapListWithAmount.clear(); 
        }   
        if(!wrapListWithZeroAmount.isEmpty()){  
            wrapList.addAll(wrapListWithZeroAmount);    
            wrapListWithZeroAmount.clear(); 
        }   
        Remittance__C remStatus = [select id, name, Status__c from remittance__C where id = :remit.id]; 
        if(remStatus.status__C == 'Processed'){ 
            FetchUpdatedRecord = 'Duplicate';   
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Dividend has already been processed'));    
            return null;    
        }   
        filterSearchResults();  
        List<ID> listProdAccIDs = new List<ID>();   
        ProdAccIds.clear(); 
        if(insolvencyAccNumbers.trim().length()==0){    
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter data in search field.')); 
            return null;    
        }   
            
        // Filter selected payment records, and exclude from further search 
        for(Wrapper wrap : wrapList){   
            listProdAccIDs.add(wrap.key);   
        }   
        // Perform search only if user entered some text in search field    
        if(!String.isEmpty(insolvencyAccNumbers)){  
            List<String> searchList = New List<String>();   
            List<String> accNumList = insolvencyAccNumbers.split(',');  
            for(Integer i=0; i<accNumList.size(); i++){ 
                String temp = accNumList.get(i).trim(); 
                temp = '%'+temp+'%';    
                searchList.add(temp);   
            }   
            Boolean searchResultsFound = false; 
                
            for(Insolvency_Account__C productAcc : [SELECT Id, name, Bank_Name__c, Debtor_1_Estate_Number__c, Borrower_Primary__c, Trustee_Company__c, Debtor__c, Asset_Status__c, Previous_Account_Reference__c, Portfolio_Group_Name__c FROM Insolvency_Account__C WHERE (Name LIKE : searchList OR Borrower_Primary__c LIKE : searchList OR Debtor__c  LIKE : searchList OR Debtor_1_Estate_Number__c LIKE : searchList OR Previous_Account_Reference__c LIKE : searchList) and ID Not IN :listProdAccIDs ORDER BY NAME ASC LIMIT 1000]){    
                if(!ProdAccIds.contains(productAcc.Id)){    
                    Insolvency_Payment__c productPayment = new Insolvency_Payment__c(); 
                    productPayment.Insolvency_account__c = productAcc.Id;   
                    productPayment.Remittance__c = remit.Id;    
                    ProdAccIds.add(productAcc.Id);  
                        
                    Wrapper wrap = new Wrapper();   
                    wrap.productPay = productPayment;   
                    wrap.key = productAcc.Id;   
                    wrap.productAcc = productAcc;   
                    if(wrapList.size() < 999){  
                        checkAndAddToWrapperList(wrap); // seperate selected and non selected records   
                    }else{  
                        break;  
                    }   
                }   
                searchResultsFound = true;  
            }   
            if(!searchResultsFound){    
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No search results found.'));   
            }   
        }   
        return null;    
    }   
        
    public void checkAndAddToWrapperList(Wrapper wrap){ 
            
        // Add to selected list if amount is entered    
        if((wrap.productPay.Payment_Amount__c != NULL && wrap.productPay.Payment_Amount__c >0) ){   
            //if(wrapListWithAmount.size() < 1000){ 
                wrapListWithAmount.add(wrap);   
            //} 
        }   
        else{   // Add to non selected list if amount is not entered    
            //if(wrapListWithZeroAmount.size() < 1000){ 
                wrapListWithZeroAmount.add(wrap);   
            //} 
        }   
    }   
    // Method filters previous search results, and keeps selected insolvency payments   
    public void filterSearchResults(){  
        List<Wrapper> tempWrapList = new List<Wrapper>();   
        for(Wrapper wrap : wrapList){   
            if(wrap.productPay.Payment_Amount__c <> null || wrap.productPay.Payment_Amount__c > 0){ 
                tempWrapList.add(wrap); 
                checkAndAddToWrapperList(wrap); 
            }   
        }   
            
        wrapList.clear();   
        wrapList.addAll(tempWrapList);  
    }   
        
    // Method to check whether insolvency payment list is empty or not  
    public Boolean getwrapIsNotEmpty(){ 
        return (wrapList.size() > 0);   
    }   
    // Method to check whether selected payment records list is empty or not    
    public Boolean getwrapListWithAmountNotEmpty(){ 
        return (wrapListWithAmount.size() > 0); 
    }   
        
    // Method to check whether non selected payment records list is empty or not    
    public Boolean getwrapListWithZeroAmountNotEmpty(){ 
        return (wrapListWithZeroAmount.size() > 0); 
    }   
        
    // Method to save/update Insolvency payment records 
    public Boolean saveInsolveyncyPayments(){   
        calAmountDiffMsg='';    
        productPaymentList.clear(); 
        wrapList.clear();   
        // Add selected and non selected results to wraplist variable in order to process   
        if(!wrapListWithZeroAmount.isEmpty()){  
            wrapList.addAll(wrapListWithZeroAmount);    
            wrapListWithZeroAmount.clear(); 
        }   
        if(!wrapListWithAmount.isEmpty()){  
            wrapList.addAll(wrapListWithAmount);    
            wrapListWithAmount.clear(); 
        }   
            
        List<ID> AccountTrusteeMismatch = new List<ID>();   
            
        totalAmount = 0.00; 
            
        for(Wrapper wrap : wrapList){   
            if(wrap.productPay.Payment_Amount__c != null && wrap.productPay.Payment_Amount__c > 0){ 
                checkAndAddToWrapperList(wrap); 
                    
                Insolvency_Payment__c prodPayment = wrap.productPay;    
                if(prodPayment.Insolvency_Account__c == NULL){  
                    prodPayment.Insolvency_Account__c = wrap.key;   
                }   
                prodPayment.Remittance__c = remit.Id;   
                prodPayment.Cheque_Payment_Reference_Number__c = remit.Cheque_Payment_Reference_Number__c;  
                //prodPayment.Payment_Posting_Date__c = remit.Payment_Posting_Date__c;  
                // Update Allocated Payment Postin Date to Today's date 
                prodPayment.Payment_Posting_Date__c = System.today();   
                //Remitance Record Type - fetch 
                prodPayment.recordTypeId = remittanceRecType.Id;    
                productPaymentList.add(prodPayment);    
                    
                if(wrap.productAcc.Trustee_Company__c <> remit.Trustee_Name__r.name  ){ 
                    AccountTrusteeMismatch.add(wrap.key);   
                }   
                    
                totalAmount += wrap.productPay.Payment_Amount__c;   
                    
                /*if(remit.Cheque_Amount__c < totalAmount){ 
                    system.debug('exceeds $'+(totalAmount - remit.Cheque_Amount__c));   
                    calAmountDiffMsg = ' (▲ exceeds $'+(totalAmount - remit.Cheque_Amount__c).toPlainString()+')';  
                        
                }else if(remit.Cheque_Amount__c > totalAmount){ 
                    system.debug('lower $'+(totalAmount - remit.Cheque_Amount__c)); 
                    calAmountDiffMsg = ' (▼ lower $'+(remit.Cheque_Amount__c - totalAmount).toPlainString()+')';    
                        
                }*/ 
            }else{  
                //checkAndAddToWrapperList(wrap);   
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Net Amount cannot be Negative, Zero or blank for allocated section'));       
                /*return false;*/   
            }   
            /*if (wrap.productPay.Payment_Amount__c == 0){      
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Net Amount cannot be Zero for Allocated Payments'));   
                return false;   
            } */            
        }   
        //totalAmount = getTotalAmount();   
            
        Decimal unallocatedAmountTotal = getUnallocatedAmount();    
        totalAmount += unallocatedAmountTotal;  
            
        /*remit = [SELECT Id, Deposit_Account_Name__c,name, Cheque_Amount__c, Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c,  
                 Status__c, Trustee_Name__c, Trustee_Name__r.name, Email_to_Case_Reference_Number__c, Assigned_To__c    
                 FROM Remittance__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];*/   
        // If Cheque amount on Remittance is not equal to total amount from Insolvency Payments 
        system.debug(totalAmount+' = remit.Cheque_Amount__c '+remit.Cheque_Amount__c);  
            
        if(remit.Cheque_Amount__c != totalAmount){  
                
            String calAmountDiffMsg = '';   
            if(remit.Cheque_Amount__c <> totalAmount){  
                calAmountDiffMsg='Total Amount entered does not match with the Dividend Amount.';   
            }   
                
            if(remit.Cheque_Amount__c < totalAmount){   
                calAmountDiffMsg += ' (▲ exceeds $'+(totalAmount - remit.Cheque_Amount__c).toPlainString()+')'; 
            }else if(remit.Cheque_Amount__c > totalAmount){ 
                calAmountDiffMsg += ' (▼ lower $'+(remit.Cheque_Amount__c - totalAmount).toPlainString()+')';   
            }   
                
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, calAmountDiffMsg));    
                
            if(AccountTrusteeMismatch.size() > 0){  
                List<Insolvency_Account__C> listAccountsMismatchTrustee = [SELECT ID, Name from Insolvency_Account__C where ID IN : AccountTrusteeMismatch];    
                String errorMsgTrustee = 'Trustee Mismatch with Dividend Trustee: ';    
                Integer count=0;    
                for(Insolvency_Account__C insolAcc : listAccountsMismatchTrustee){  
                    count+=1;   
                    errorMsgTrustee += '<a href="'+System.Url.getSalesforceBaseURL().toExternalForm() +'/'+insolAcc.Id+'" target="_blank">'+ insolAcc.Name+'</a>,'; 
                    if(count==12){  
                     errorMsgTrustee +='<br/>'; 
                        count=0;    
                    }   
                }   
                errorMsgTrustee = errorMsgTrustee.removeEnd(',');   
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsgTrustee));   
            }   
        }else { 
            AggregateResult[] productPaymentResults = [select SUM(Payment_Amount__c) prodPayAmount from Insolvency_Payment__c where remittance__c = :remit.id group by remittance__c ]; 
            AggregateResult[] unallocatedPaymentResults = [select SUM(Unallocated_Amount__c) unAllocAmount from unallocated_payment__c where remittance__c = :remit.id group by remittance__c]; 
            Remittance__C remitUpdated = [select id, status__c from remittance__C where id = :remit.id];    
            Decimal totalChequeAmount = (productPaymentResults.size() > 0? (Decimal)productPaymentResults[0].get('prodPayAmount'): 0.0) +   
                (unallocatedPaymentResults.size() > 0 ?(Decimal)unallocatedPaymentResults[0].get('unAllocAmount'): 0.0);    
            if(totalChequeAmount == remit.Cheque_Amount__c || remitUpdated.status__c == 'Processed'){   
                FetchUpdatedRecord = 'Duplicate';   
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Dividend has already been processed'));    
                return false;   
            }       
            if(!productPaymentList.isEmpty()){  
                if(remit.Cheque_Amount__c == totalAmount){  
                    system.debug('INSERT....'); 
                    Savepoint sp = Database.setSavepoint(); 
                    upsert productPaymentList;  
                        
                    if(/*unAllocPaymentToSave != null &&*/ !unAllocPaymentToSave.isEmpty()){    
                        upsert unAllocPaymentToSave;    
                    }   
                    system.debug('status : ' + remit.status__C);    
                    //assignBankInformation();  
                    system.debug('remit updated');  
                    //update Remittance record  
                    remit.Status__c = 'Processed';  
                    // Update payment Posting date when status is Processed 
                    if(remit.Status__c == 'Processed'){ 
                       remit.Payment_Posting_Date__c=System.today();    
                      } 
                    //update remit; 
                    Database.SaveResult updateResult = Database.update(remit, false);   
                    if(!updateResult.isSuccess()){  
                        Database.rollback(sp);  
                        FetchUpdatedRecord = 'Duplicate';   
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Dividend has already been processed'));    
                        return false;   
                    }   
                    refreshParent = true;   
                    //assignBankDetailsToPayment(); 
                        
                    assignBankInformation(remit.Id);    
                    FetchUpdatedRecord = 'Processed';   
                    showSearch = False; 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Insolvency payments updated successfully')); 
                    //return true;  
                }   
            }   
            if(productPaymentList.isEmpty() && /*unAllocPaymentToSave != null &&*/ !unAllocPaymentToSave.isEmpty()){    
                Savepoint sp = Database.setSavepoint(); 
                upsert unAllocPaymentToSave;    
                remit.Status__c = 'Processed';  
                    
                //Payment posting date on dividend is updated to Today's date when status is processed  
                    
                if( remit.Status__c == 'Processed'){    
                remit.Payment_Posting_Date__c = system.today();     
                }   
                    
                system.debug('status : ' + remit.status__C);    
                //assignBankInformation();  
                system.debug('remit updated');  
                Database.SaveResult updateResult = Database.update(remit, false);   
                if(!updateResult.isSuccess()){  
                    Database.rollback(sp);  
                    FetchUpdatedRecord = 'Duplicate';   
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Dividend has already been processed'));    
                    return false;   
                }   
                FetchUpdatedRecord = 'Processed';   
                refreshParent = true;   
                //assignBankDetailsToPayment(); 
                assignBankInformation(remit.Id);    
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Unallocated Payments saved successfully'));  
                return true;    
            }   
        }   
        return false;   
            
    }   
        
    // Method that will be used to rerender total amount    
    public pagereference calculateTotal(){  
        return null;    
    }   
        
    // Return the total of Net Payment amounts  
    public Decimal getTotalAmount(){    
        totalAmount = 0.00; 
        calAmountDiffMsg='';    
        // Calculate the total from selected Insolvency Payments    
        for(Wrapper wrap : wrapListWithAmount){ 
            if( wrap.productPay.Payment_Amount__c != null && wrap.productPay.Payment_Amount__c > 0){    
                totalAmount+=wrap.productPay.Payment_Amount__c; 
            }   
        }   
        Decimal unallocatedAmountTotal = getUnallocatedAmount();    
        totalAmount += unallocatedAmountTotal;  
        if(remit.Cheque_Amount__c < totalAmount){   
            system.debug('exceeds $'+(totalAmount - remit.Cheque_Amount__c));   
            calAmountDiffMsg = ' (▲ exceeds $'+(totalAmount - remit.Cheque_Amount__c).toPlainString()+')';  
                
        }else if(remit.Cheque_Amount__c > totalAmount){ 
            system.debug('lower $'+(totalAmount - remit.Cheque_Amount__c)); 
            calAmountDiffMsg = ' (▼ lower $'+(remit.Cheque_Amount__c - totalAmount).toPlainString()+')';    
                
        }   
        return totalAmount; 
    }   
        
    // Wrapper class to store Insolvency Payment data   
    public class Wrapper{   
        public Id key{set;get;} 
        public Insolvency_Account__C productAcc;    
            
        public void setProdAcc(){   
            productAcc = productAcc;    
        }   
        public Insolvency_Account__C getproductAcc(){   
            return productAcc;  
        }   
        public Insolvency_Payment__c productPay {set;get;}  
    }   
        
    public List< Unallocated_Payment__c> unAllocPaymentList {set;get;}  
    public void addUnallocatedPayment(){    
        if(unAllocPaymentList == null){ 
            unAllocPaymentList = new List< Unallocated_Payment__c>();   
        }   
        system.debug('here12'); 
        unAllocPaymentList.add(new Unallocated_Payment__c());   
            
        wrapList.clear();   
        // Add selected and non selected results to wraplist variable in order to process   
        if(!wrapListWithZeroAmount.isEmpty()){  
            wrapList.addAll(wrapListWithZeroAmount);    
            wrapListWithZeroAmount.clear(); 
        }   
        if(!wrapListWithAmount.isEmpty()){  
            wrapList.addAll(wrapListWithAmount);    
            wrapListWithAmount.clear(); 
        }   
            
        for(Wrapper wrap: wrapList){    
            checkAndAddToWrapperList(wrap); 
        }   
    }   
        
    public Decimal getUnallocatedAmount(){  
        Decimal totalUnallocated = 0.00;    
        for(Unallocated_Payment__c unAlloc : unAllocPaymentList){   
            if(unAlloc.Unallocated_Amount__c != null){  
                totalUnallocated+=unAlloc.Unallocated_Amount__c;    
            }   
            system.debug(totalUnallocated+'unAlloc.Unallocated_Amount__c'+unAlloc.Unallocated_Amount__c);   
        }   
        return totalUnallocated;    
    }   
        
    // Save button displayed only where there search results, or selected payment records   
    public Boolean getShowSaveButton(){ 
        return ( (unAllocPaymentList.size() > 0 || (wrapListWithAmount.size() > 0 || wrapListWithZeroAmount.size() > 0 )) && remit.Status__c <> 'Processed' );  
    }   
    // Check whether unallocated amount list is empty or not    
    public Boolean getunAllocAmountIsNotEmpty(){    
        return (unAllocPaymentList.size() > 0); 
    }   
    // Check duplicate payment records  
    public Boolean isDuplicateWithInsolvnecyPayment(Unallocated_Payment__c unAlloc){    
        if(unAlloc.Account_Number__c != NULL && unAlloc.Estate_Number__c != NULL && unAlloc.Bank_Name__c != NULL){  
            String dupKey = unAlloc.Account_Number__c.toUpperCase()  + unAlloc.Bank_Name__c.toUpperCase()+ unAlloc.Estate_Number__c.toUpperCase();  
            for(Wrapper wrap : wrapList){   
                Insolvency_Payment__c productPayment = wrap.productPay; 
                system.debug('insolvPayment.Account_Number__c ='+wrap.productAcc.Name); 
                //system.debug('insolvPayment.Bank_Name__c ='+wrap.productAcc.Bank_Name__c);    
                //system.debug('insolvAcc.Debtor_1_Estate_Number__c ='+wrap.productAcc.Debtor_1_Estate_Number__c);  
                    
                String key = wrap.productAcc.Name.toUpperCase() + wrap.productAcc.Bank_Name__c.toUpperCase() /*+wrap.productAcc.Debtor_1_Estate_Number__c.toUpperCase()*/;  
                system.debug('key='+key);   
                system.debug('dupKey='+dupKey); 
                if(dupKey == key){  
                    return true;    
                }   
            }   
        }   
        return false;   
    }   
        
    List<Unallocated_Payment__c> unAllocPaymentToSave;  
    public Boolean saveUnAllocatedAmount(){ 
        String recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%insolvency%'].id;
        Decimal totalUnAllocAmount = 0.00;  
        unAllocPaymentToSave = new List<Unallocated_Payment__c>();  
        for(Unallocated_Payment__c unAlloc : unAllocPaymentList){   
            if(isDuplicateWithInsolvnecyPayment(unAlloc)){  
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Duplicate Unallocated amount details with Account number '+unAlloc.Account_Number__c));    
                return null;    
            }   
            unAlloc.Remittance__c = remit.Id;   
            system.debug(unAlloc.Account_Number__c+'=='+unAlloc.Estate_Number__c+'==='+unAlloc.Debtor_Name__c); 
            if((unAlloc.Unallocated_Amount__c == null || unAlloc.Unallocated_Amount__c <= 0) && (unAlloc.Account_Number__c == null || unAlloc.Account_Number__c.length() == 0) && unAlloc.Debtor_Name__c == null  ){    
                system.debug('continuee....');  
                continue;   
            }   
            if((unAlloc.Account_Number__c == null || unAlloc.Account_Number__c.length() == 0 || string.isBlank(unAlloc.Account_Number__c) /*|| string.isBlank(unAlloc.Debtor_Name__c)*/ ) && unAlloc.Debtor_Name__c == null  ){ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Account Number or Debtor Name on each Unallocated Payment'));         
                return null;    
            }   
                
            if(unAlloc.Unallocated_Amount__c != null && unAlloc.Unallocated_Amount__c > 0 ){    
                    
                totalUnAllocAmount += unAlloc.Unallocated_Amount__c;    
                unalloc.recordTypeId = recordTypeId;
                //payment postin date on Unallocated payment is Today's date when payment is posted 
                unalloc.Payment_Posting_Date__c=system.today(); 
                unAllocPaymentToSave.add(unAlloc);  
                    
            }else{  
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment Amount cannot be blank or 0 or Negative for unallocated section'));    
                return null;                            
            }   
                
        }   
        try{    
            system.debug(totalUnAllocAmount+' = totalUnAllocAmount.... & '+remit.Cheque_Amount__c); 
            Boolean allocatedSectionError = saveInsolveyncyPayments();  
        }catch(System.DmlException ex){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getDmlMessage(0)));  
        }   
            
        return null;    
    }   
        
    /*  
    public void assignBankInformation(){    
            
        Set<String> setPortfolioGroupName = new Set<String>();  
        for(Wrapper wrp : wrapList){    
            if(wrp.productPay.Payment_Amount__c <> null && wrp.productPay.Payment_Amount__c > 0){   
                if(String.isNotBlank(wrp.productAcc.Portfolio_Group_Name__c)){  
                    
                    String PortfolioGroupName = (wrp.productAcc.Portfolio_Group_Name__c).subString(0,3);    
                    if(PortfolioGroupName == 'CIA' || PortfolioGroupName == 'AAL'){ 
                        PortfolioGroupName = 'CIH'; 
                    }       
                    setPortfolioGroupName.add(PortfolioGroupName);  
                }else{  
                    setPortfolioGroupName.add('');  
                }   
            }   
        }   
            
        List<Unallocated_Payment__c> listUnallocatedPayments = new List<Unallocated_Payment__c>();  
        for(Unallocated_Payment__c unAlloc : unAllocPaymentList){   
            if(unAlloc.Unallocated_Amount__c != null && unAlloc.Unallocated_Amount__c > 0 ){    
                    
                listUnallocatedPayments.add(unAlloc);   
                    
            }   
        }   
        system.debug('list of portfolio Group Name : ' + setPortfolioGroupName);    
        system.debug('Size of unallocated payment : ' + listUnallocatedPayments.size());    
            
        if(listUnallocatedPayments.size() > 0 && setPortfolioGroupName.size() == 0){    
            assignBankDetailstoRemit('CIML');   
        }else if(listUnallocatedPayments.size() > 0 && setPortfolioGroupName.size() > 0){   
            if(setPortfolioGroupName.contains('')){ 
                assignBankDetailstoRemit('CIML');   
            }else if(setPortfolioGroupName.contains('CIH')){    
                if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||    
                   setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ){    
                       assignBankDetailstoRemit('CIML');    
                   }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||   
                            setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){    
                                assignBankDetailstoRemit('AFSI');   
                   }else{   
                       assignBankDetailstoRemit('CIML');    
                   }    
            }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||  
                     setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ){  
                         assignBankDetailstoRemit('CIML');  
                     }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') || 
                              setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){  
                                  assignBankDetailstoRemit('AFSI'); 
                     }else{ 
                         assignBankDetailstoRemit('CIML');  
                     }  
        }else if(listUnallocatedPayments.size() == 0 && setPortfolioGroupName.size() > 0){  
                
            if(setPortfolioGroupName.contains('')){ 
                assignBankDetailstoRemit('CIML');   
            }else if(setPortfolioGroupName.size() > 2){ 
                    
                if(setPortfolioGroupName.contains('CIH')){  
                    if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||    
                       setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ){    
                           assignBankDetailstoRemit('CIML');    
                       }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||   
                                setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){    
                                    assignBankDetailstoRemit('AFSI');   
                                }else{  
                                    assignBankDetailstoRemit('CIML');   
                                }   
                }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||  
                         setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ){  
                             assignBankDetailstoRemit('CIML');  
                         }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') || 
                                  setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){  
                                      assignBankDetailstoRemit('AFSI'); 
                                  }else{    
                                      assignBankDetailstoRemit('CIML'); 
                                  } 
            }else if(setPortfolioGroupName.size() == 2){    
                if(setPortfolioGroupName.contains('CCL') && setPortfolioGroupName.contains('CLP')){ 
                    assignBankDetailstoRemit('CCL');    
                }else if(setPortfolioGroupName.contains('ETC') && setPortfolioGroupName.contains('AFF')){   
                    assignBankDetailstoRemit('ETC');    
                }else if(setPortfolioGroupName.contains('CIH')){    
                    if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||    
                       setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ){    
                           assignBankDetailstoRemit('CIML');    
                       }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||   
                                setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){    
                                    assignBankDetailstoRemit('AFSI');   
                                }else{  
                                    assignBankDetailstoRemit('CIML');   
                                }   
                }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||  
                         setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ){  
                             assignBankDetailstoRemit('CIML');  
                         }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') || 
                                  setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){  
                                      assignBankDetailstoRemit('AFSI'); 
                                  }else{    
                                      assignBankDetailstoRemit('CIML'); 
                                  } 
                    
            }else if(setPortfolioGroupName.size() == 1){    
                if(setPortfolioGroupName.contains('CCL')){  
                    assignBankDetailstoRemit('CCL');    
                }else if(setPortfolioGroupName.contains('CLP')){    
                    assignBankDetailstoRemit('CCL');    
                }else if(setPortfolioGroupName.contains('CIA')){    
                    assignBankDetailstoRemit('CIH');    
                }else if(setPortfolioGroupName.contains('AFF')){    
                    assignBankDetailstoRemit('ETC');    
                }else if(setPortfolioGroupName.contains('AFL')){    
                    assignBankDetailstoRemit('AFL');    
                }else if(setPortfolioGroupName.contains('ETC')){    
                    assignBankDetailstoRemit('ETC');    
                }else if(setPortfolioGroupName.contains('CIH')){    
                    assignBankDetailstoRemit('CIH');    
                }else if(setPortfolioGroupName.contains('CAL')){    
                    assignBankDetailstoRemit('CAL');    
                }else if(setPortfolioGroupName.contains('AAL')){    
                    assignBankDetailstoRemit('CIH');    
                }else{  
                    assignBankDetailstoRemit('CIML');   
                }   
            }else{  
                assignBankDetailstoRemit('CIML');   
            }   
        }   
            
    }*/ 
        
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
        
    /*  
    public void assignBankDetailsToPayment(){   
        List<Insolvency_Payment__c> listPaymentstoUpdate = [select id, Deposit_Account_Type__c,     
                                                          Insolvency_Account__r.Portfolio_Group_Name__c     
                                                          from Insolvency_Payment__c    
                                                          where remittance__c = :remit.id]; 
            
        //system.debug('Deposit_Accounts__c : ' + remit.Deposit_Account_Name__c);   
        if(remit.Deposit_Account_Name__c <> 'CIML' && remit.Deposit_Account_Name__c <> 'AFSI'){ 
                
            for(Insolvency_Payment__c insolPay : listPaymentstoUpdate){ 
                insolPay.Deposit_Account_Type__c = remit.Deposit_Account_Name__c;   
            }   
        }else{  
            for(Insolvency_Payment__c insolPay : listPaymentstoUpdate){ 
                Map<String, Deposit_Accounts__c> depositAccountMap = Deposit_Accounts__c.getAll();  
                Deposit_Accounts__c depositAcc = new Deposit_Accounts__c(); 
                system.debug('Deposit_Accounts__c : ' + insolPay.Insolvency_Account__r.Portfolio_Group_Name__c);    
                if(null != insolPay.Insolvency_Account__r.Portfolio_Group_Name__c){ 
                    depositAcc = depositAccountMap.get((insolPay.Insolvency_Account__r.Portfolio_Group_Name__c).subString(0,3));    
                }   
                if(null == insolPay.Insolvency_Account__r.Portfolio_Group_Name__c ||    
                   null == depositAcc ){    
                       depositAcc = depositAccountMap.get('CIML');  
                   }    
                    
                insolPay.Deposit_Account_Type__c = depositAcc.Name; 
            }   
        }   
            
        update listPaymentstoUpdate;    
    }*/ 
        
    void fetchAttachment(){ 
        attachDocument = [select id, name, Description, CreatedDate, LastModifiedDate, parentID     
                          from attachment where parentID =:remit.ID ORDER BY CreatedDate DESC]; 
            
        if(!String.isBlank(remit.Email_to_Case_Reference_Number__c)){   
            List<Attachment> listAttach = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId    
                                           FROM Attachment  
                                           WHERE ParentId in (select id from EMailMessage where relatedToid =: remit.Email_to_Case_Reference_Number__c)     
                                           ORDER BY CreatedDate DESC];  
                
            attachDocument.addAll(listAttach);  
                
        } 
        listAttachWrap = new List<AttachWrap>();
          for(Attachment att:attachDocument){
           AttachWrap awp = new AttachWrap(att);
           listAttachWrap.add(awp);  
        }  
            
    }   
        
     public Boolean getAttachIsNotEmpty(){  
        return (attachDocument.size() > 0); 
    }   
  
     public class AttachWrap{   
        public dateTime dateCreated {get;set;}  
        public dateTime datemodified {get;set;} 
        public String strCreatedDate {get;set;} 
        public String strlastModifiedDate {get;set;}    
        public String strID{get;set;}   
        public string attachmentName{get;set;}  
            
            public AttachWrap(Attachment attach){   
                this.dateCreated = attach.CreatedDate;          
                this.dateModified = attach.lastModifiedDate;    
                this.strCreatedDate = attach.CreatedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString()); 
                this.strlastModifiedDate = attach.LastModifiedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());   
                this.strID = attach.id; 
                this.attachmentName = attach.name;  
    
            }           
    }   
        
    @future 
    public static void assignBankInformation(String remitID){   
        
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
                   setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ||
                   setPortfolioGroupName.contains('CFL')){    
                       depositAcc = assignBankDetailstoRemit('CIML');   
                   }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||   
                            setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){    
                                depositAcc = assignBankDetailstoRemit('AFSI');  
                   }else{   
                       depositAcc = assignBankDetailstoRemit('CIML');   
                   }    
            }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||  
                     setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ||
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
                       setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ||
                       setPortfolioGroupName.contains('CFL')){    
                           depositAcc = assignBankDetailstoRemit('CIML');   
                       }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||   
                                setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){    
                                    depositAcc = assignBankDetailstoRemit('AFSI');  
                                }else{  
                                    depositAcc = assignBankDetailstoRemit('CIML');  
                                }   
                }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||  
                         setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ||
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
                       setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ||
                       setPortfolioGroupName.contains('CFL')){    
                           depositAcc = assignBankDetailstoRemit('CIML');   
                       }else if(setPortfolioGroupName.contains('ETC') || setPortfolioGroupName.contains('AFF') ||   
                                setPortfolioGroupName.contains('AAL') || setPortfolioGroupName.contains('AFL')){    
                                    depositAcc = assignBankDetailstoRemit('AFSI');  
                                }else{  
                                    depositAcc = assignBankDetailstoRemit('CIML');  
                                }   
                }else if(setPortfolioGroupName.contains('CCL') || setPortfolioGroupName.contains('CLP') ||  
                         setPortfolioGroupName.contains('CIA') || setPortfolioGroupName.contains('CAL') ||
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
            
       // Application_Config_Settings__c acs = Application_Config_Settings__c.getOrgDefaults();   
        //Application_Config_Settings__c acs=[select id,Run_Remittance_Validation__c from Application_Config_Settings__c FOR UPDATE];
       // acs.Run_Remittance_Validation__c = False;   
        //update acs; 
        RemittanceTriggerHandler.runRemittanceTrigger=False;
            
        //update remit;   
        Database.SaveResult remitUpdateResult=Database.update(remit,False);  
        if(!remitUpdateResult.isSuccess() || test.isRunningTest()){
            List<String> lstEmail = new list<string>{System.Label.API_Failed_Email};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
            mail.setToAddresses(lstEmail);    
            mail.setSubject('Remittance Update is failed and ID of Remittance is :'+remit.ID);   
          if(!remitUpdateResult.getErrors().isEmpty())  mail.setPlainTextBody('Remittance Update is failed and ID of Remittance is : '+remit.ID +'and due to an error : '+ remitUpdateResult.getErrors().get(0));
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        RemittanceTriggerHandler.runRemittanceTrigger=True;
       // acs.Run_Remittance_Validation__c = True;    
        //update acs; 
            
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
}