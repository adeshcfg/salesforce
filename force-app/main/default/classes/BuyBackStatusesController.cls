public class BuyBackStatusesController {
    public ApexPages.StandardSetController standardController{get;set;}
    public String currentRecordId {get;set;}
    public boolean showButton {get;set;}
    public List<Product__c> prodList{get;set;}
    public List<SelectOption> countrieLst {get;set;}
    public String selectedCountry{get;set;}
    public boolean showBbInitiateTable {get;set;}
    public boolean showPbbInitiateTable {get;set;}
    public boolean showBbAppRejTable {get;set;}
    public boolean showPbAppRejTable {get;set;}
    public boolean showRemoveReqTable {get;set;}
    
    //public Boolean disabled = false;
    public list<judgmentStagingWrapper> listProductPayStagingWrapper {get;set;}
    public BuyBackStatusesController(ApexPages.StandardSetController stdController) {
        system.debug('Inside costructor');
        showBbInitiateTable = false;
        showPbbInitiateTable = false;
        showBbAppRejTable = false;
        showPbAppRejTable = false;
        showRemoveReqTable = false;
        this.standardController = stdController;
        //String status;
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        
        countrieLst = new List<SelectOption>();
        //countrieLst.add(new SelectOption('None','None'));
        countrieLst.add(new SelectOption('--None--','--None--'));
        countrieLst.add(new SelectOption('Buyback Initiated','Buyback Initiated'));
        countrieLst.add(new SelectOption('Putback Initiated','Putback Initiated'));
        countrieLst.add(new SelectOption('Buyback Approved','Buyback Approved'));
        countrieLst.add(new SelectOption('Putback Approved','Putback Approved'));
        countrieLst.add(new SelectOption('Buyback Rejected','Buyback Rejected'));
        countrieLst.add(new SelectOption('Putback Rejected','Putback Rejected'));
        countrieLst.add(new SelectOption('Remove from Buyback/Putback','Remove from Buyback/Putback'));
        system.debug('options:'+countrieLst);
        system.debug('currentRecordId:'+currentRecordId);
        
    }
    public pageReference statusUpdate(){
        system.debug('inside statusUpdate');
        system.debug('inside selectedCountry' +selectedCountry);
        if(selectedCountry == 'Buyback Initiated'){
            showBbInitiateTable = true;
            showPbbInitiateTable = false;
            showBbAppRejTable = false;
            showPbAppRejTable = false;
            showRemoveReqTable = false;
            prodList =[Select id,name,Purchase_Status__c,collection_agency__c,Buyback_Putback_Status_Change_Date__c
                       ,Putback_buyback_Completed_Date__c
                       from product__c where Purchase_Status__c = 'Eligible for Buyback'];
            system.debug('buyback prodList' +prodList);
        }else if(selectedCountry == 'Putback Initiated'){
            showBbInitiateTable = false;
            showPbbInitiateTable = true;
            showBbAppRejTable = false;
            showPbAppRejTable = false;
            showRemoveReqTable = false;
            prodList =[Select id,name,Purchase_Status__c,collection_agency__c,Buyback_Putback_Status_Change_Date__c
                       ,Putback_buyback_Completed_Date__c
                       from product__c where Purchase_Status__c = 'Eligible for Putback'];
            system.debug('buyback prodList' +prodList);
        }else if(selectedCountry =='Buyback Approved' || selectedCountry =='Buyback Rejected'){
            showBbInitiateTable = false;
            showPbbInitiateTable = false;
            showBbAppRejTable = true;
            showPbAppRejTable = false;
            showRemoveReqTable = false;
            prodList =[Select id,name,Purchase_Status__c,collection_agency__c,Buyback_Putback_Status_Change_Date__c,
                       Putback_buyback_Completed_Date__c
                       from product__c where Purchase_Status__c = 'Buyback Requested'];
        }else if(selectedCountry =='Putback Approved' || selectedCountry =='Putback Rejected'){
            showBbInitiateTable = false;
            showPbbInitiateTable = false;
            showBbAppRejTable = false;
            showPbAppRejTable = true;
            showRemoveReqTable = false;
            prodList =[Select id,name,Purchase_Status__c,collection_agency__c,Buyback_Putback_Status_Change_Date__c,
                       Putback_buyback_Completed_Date__c
                       from product__c where Purchase_Status__c = 'Putback Requested'];
        }else if(selectedCountry =='Remove from Buyback/Putback'){
            showBbInitiateTable = false;
            showPbbInitiateTable = false;
            showBbAppRejTable = false;
            showPbAppRejTable = false;
            showRemoveReqTable = true;
            prodList =[Select id,name,Purchase_Status__c,collection_agency__c,Buyback_Putback_Status_Change_Date__c,
                       Putback_buyback_Completed_Date__c
                       from product__c where Purchase_Status__c = 'Eligible for Buyback' OR 
                      Purchase_Status__c = 'Eligible for Putback' OR 
                      Purchase_Status__c = 'Buyback Initiated' OR 
                      Purchase_Status__c = 'Putback Initiated' OR 
                      Purchase_Status__c = 'Buyback Requested' OR 
                      Purchase_Status__c = 'Putback Requested'];
        }
        if(prodList.isEmpty() || prodList == NULL){
            system.debug('buyback prodList***' +prodList);
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'No Record Found For This Criteria'));
        }
        system.debug('buyback prodList***' +prodList);
        listProductPayStagingWrapper = new list<judgmentStagingWrapper>();
            showButton = false;
            for(Product__c payStaging : prodList){
                Boolean disabled = false;
                   if((payStaging.Collection_Agency__c != null && payStaging.Collection_Agency__c != 9999) 
                      && (payStaging.Purchase_Status__c == 'Eligible for Buyback' ||
                         payStaging.Purchase_Status__c == 'Eligible for Putback')){
                       system.debug('inside Collection_Agency__c not null');
                        disabled = true;                    
                    }
                    listProductPayStagingWrapper.add(new judgmentStagingWrapper(payStaging, disabled));
                    if((payStaging.Collection_Agency__c == null || payStaging.Collection_Agency__c == 9999) && (payStaging.Purchase_Status__c == 'Eligible for Buyback' ||
                                                                  payStaging.Purchase_Status__c == 'Eligible for Putback')){
                        system.debug('inside Collection_Agency__c null');
                        showButton = true;
                    }
                if(payStaging.Purchase_Status__c == 'Buyback Requested' ||
                  payStaging.Purchase_Status__c == 'Putback Requested'){
                    showButton = true;
                }
            }
        return null;
    }
    public pageReference Save(){
        list<Product__c> listProd = new list<Product__c>();
         Map<String, ID> mapAccountNumberID = new Map<String, String>();
        system.debug('prodList::'+prodList);
        for(Product__C accountRecord : prodList ){
            mapAccountNumberID.put(accountRecord.name, accountRecord.id);
        }
        system.debug('listProductPayStagingWrapper'+listProductPayStagingWrapper);
        for(judgmentStagingWrapper judgStagingWrapper : listProductPayStagingWrapper){
            Product__c judgStaging = judgStagingWrapper.payStaging;
            system.debug('judgStaging:'+judgStaging);
            if(judgStagingWrapper.selected == true){
                Product__c prod = new Product__c();
                prod.id = mapAccountNumberID.get(judgStaging.Name);
                if((selectedCountry != 'Remove from Buyback/Putback') && (judgStaging.Purchase_Status__c == 'Eligible for Buyback' || 
                                                                         judgStaging.Purchase_Status__c == 'Eligible for Putback')){
                   prod.Purchase_Status__c = selectedCountry;
                   prod.Buyback_Putback_Status_Change_Date__c = Date.Today();
                }else if((selectedCountry != 'Remove from Buyback/Putback') && (judgStaging.Purchase_Status__c == 'Buyback Requested' ||
                                                                               judgStaging.Purchase_Status__c == 'Putback Requested')){
                   prod.Purchase_Status__c = selectedCountry;
                   prod.Buyback_Putback_Status_Change_Date__c = Date.Today();
                   prod.Putback_buyback_Completed_Date__c = Date.Today();
                }else if((selectedCountry == 'Remove from Buyback/Putback') && (judgStaging.Purchase_Status__c == 'Eligible for Buyback' ||
                      judgStaging.Purchase_Status__c == 'Eligible for Putback' ||
                      judgStaging.Purchase_Status__c == 'Buyback Initiated' ||
                      judgStaging.Purchase_Status__c == 'Putback Initiated' ||
                      judgStaging.Purchase_Status__c == 'Buyback Requested' || 
                      judgStaging.Purchase_Status__c == 'Putback Requested')){
                   prod.Purchase_Status__c = '';
                   prod.Buyback_Putback_Status_Change_Date__c = Date.Today();
                }
                listProd.add(prod);
            }
        }
        ProductTriggerHandler.runProductTrigger = false;
        update listProd;
        ProductTriggerHandler.runProductTrigger = true;
        //disabled = false;
        showButton = false;
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Info ,'Records Processed Successfully'));
        return null;        
    }
     public class judgmentStagingWrapper{
        public Product__c payStaging {get;set;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public judgmentStagingWrapper(Product__c pay, Boolean disable ){
            payStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
    public PageReference back()
    {
        PageReference cancel = standardController.cancel();
        return cancel;
    }
}