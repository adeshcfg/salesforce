public class BulkBuybackPutbackEligibleController {
    public ApexPages.StandardSetController standardController{get;set;}
    public Set<Id> ProdAccIds {set;get;}
    public boolean showButton {get;set;}
    public Boolean showSearch{set;get;} 
    public String insolvencyAccNumbers{set;get;}
    public List<SelectOption> countrieLst {get;set;}
    public String selectedCountry{get;set;}
    public List<Wrapper> wrapList{set;get;}
    public List<Wrapper> wrapListWithAmount{set;get;}   // variable that holds all selected payment records 
    public List<Wrapper> wrapListWithZeroAmount{set;get;}
    
    public BulkBuybackPutbackEligibleController(ApexPages.StandardSetController stdController) { 
        this.standardController = stdController;
    	ProdAccIds = new Set<Id>();
        system.debug('ProdAccIds**'+ProdAccIds);
        showSearch = true;
        showButton = false;
        searchExistingPaymentRecords();
    }
	public void searchExistingPaymentRecords(){
        
        wrapList = new List<Wrapper>(); 
        wrapListWithAmount = new List<Wrapper>();   
        wrapListWithZeroAmount = new List<Wrapper>();   
        // Fetch all existing product records  
        List<Product__c> existingProdList = new List<Product__c>([SELECT Id,Name  
                                                                  FROM Product__c   
                                                                  ORDER BY Name ASC LIMIT 1000]); 
        system.debug('existingProdList'+existingProdList);
        List<Id> prodAccIDs = new List<Id>();   
        Map<Id, Product__c> prodPayMap = new Map<Id, Product__c>();
        
        for(Product__c prodPay : existingProdList){ 
            prodAccIDs.add(prodPay.Id);  
            prodPayMap.put(prodPay.Id, prodPay);
        }
        countrieLst = new List<SelectOption>();
        countrieLst.add(new SelectOption('None','None'));
        countrieLst.add(new SelectOption('Eligible for Buyback','Eligible for Buyback'));
        countrieLst.add(new SelectOption('Eligible for Putback','Eligible for Putback'));
       system.debug('prodAccIDs**'+prodAccIDs);    
    }
    // Method search for given Insolvency account, Estate Number, Primary Borrower and Debtor   
    public PageReference searchInsolvencyAccounts(){
        showButton = true;
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
        system.debug('listProdAccIDs'+listProdAccIDs);
        // Perform search only if user entered some text in search field    
        if(!String.isEmpty(insolvencyAccNumbers)){  
            List<String> searchList = New List<String>();   
            List<String> accNumList = insolvencyAccNumbers.split(',');  
            for(Integer i=0; i<accNumList.size(); i++){ 
                String temp = accNumList.get(i).trim(); 
                temp = '%'+temp+'%';    
                searchList.add(temp);   
            }
            system.debug('searchList'+searchList);
            Boolean searchResultsFound = false; 
                
            for(Product__c productAcc : [SELECT Id, name FROM Product__c WHERE (Name LIKE : searchList) and ID Not IN :listProdAccIDs ORDER BY NAME ASC LIMIT 1000]){    
                 
                Wrapper wrap = new Wrapper();
                    wrap.key = productAcc.Id;   
                    wrap.productAcc = productAcc;
                
                if(wrapList.size() < 999){  
                    checkAndAddToWrapperList(wrap); // seperate selected and non selected records   
                }else{  
                    break;  
                } 
                searchResultsFound = true;  
            }   
            if(!searchResultsFound){    
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No search results found.'));   
            }
            system.debug('selectedCountry123****'+selectedCountry);
        }   
        return null;    
    }
    // Method to check whether insolvency payment list is empty or not  
    public Boolean getwrapIsNotEmpty(){ 
        return (wrapList.size() > 0);   
    }
    // Method to check whether selected payment records list is empty or not    
    public Boolean getwrapListWithAmountNotEmpty(){   
        return (wrapListWithAmount.size() > 0); 
    }
    public void checkAndAddToWrapperList(Wrapper wrap){
        // Add to selected list if amount is entered 
        system.debug('wrap.productAcc.Name::'+wrap.productAcc.Name);
        
        if((wrap.productAcc.Name != NULL) ){ 
            wrapListWithAmount.add(wrap); 
        }   
        else{   
            wrapListWithZeroAmount.add(wrap);
        }   
    }
    // Method filters previous search results, and keeps selected insolvency payments   
    public void filterSearchResults(){
        List<Wrapper> tempWrapList = new List<Wrapper>();   
        for(Wrapper wrap : wrapList){   
            if(wrap.productAcc.Name <> null){ 
                tempWrapList.add(wrap); 
                checkAndAddToWrapperList(wrap); 
            }   
        }   
        wrapList.clear();   
        wrapList.addAll(tempWrapList);  
    }
    public PageReference save(){
        Map<Id,Product__c> productMap = new Map<Id,Product__c>();
        system.debug('inside save');
        // Add selected and non selected results to wraplist variable in order to process   
        if(!wrapListWithZeroAmount.isEmpty()){  
            wrapList.addAll(wrapListWithZeroAmount);    
            wrapListWithZeroAmount.clear(); 
        }   
        if(!wrapListWithAmount.isEmpty()){  
            wrapList.addAll(wrapListWithAmount);    
            //wrapListWithAmount.clear(); 
        }  
        if(selectedCountry == 'None' || selectedCountry == NULL){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select status.'));
            return null; 
        }
        list<Product__c> listProd = new list<Product__c>();
        system.debug('selectedCountry****'+selectedCountry);
        system.debug('wrapList****'+wrapList);
        for(Wrapper prodData : wrapList){
            if(prodData.selected == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select records to process.'));
            	return null;
            }
            if(prodData.selected == true){
                Product__c prod = new Product__c();
                if(prodData.productAcc.Id != NULL){
                    system.debug('selectedCountry inside****'+selectedCountry);
                    prod.id = prodData.productAcc.Id;
               		prod.Purchase_Status__c = selectedCountry;
               		prod.Buyback_Putback_Status_Change_Date__c = Date.Today();
                }
               //listProd.add(prod);
               productMap.put(prod.Id,prod);
            }
            system.debug('productMap****'+productMap);
            
        }
        ProductTriggerHandler.runProductTrigger = false;
        //update listProd;
        update productMap.values();
        ProductTriggerHandler.runProductTrigger = true;
        system.debug('productMap'+productMap);
        for(Wrapper prodData : wrapList){
            if(prodData.selected == true){
                showButton = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Info ,'Records Processed Successfully'));
                wrapListWithAmount.clear();
            }
        }
    	return null;
    }
    
    // Wrapper class to store Insolvency Payment data   
    public class Wrapper{   
        public Id key{set;get;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public Product__c productAcc;    
            
        public void setProdAcc(){   
            productAcc = productAcc;    
        }   
        public Product__c getproductAcc(){   
            return productAcc;  
        }
    }
    
    public PageReference back()
    {
        PageReference cancel = standardController.cancel();
        return cancel;
    }
}