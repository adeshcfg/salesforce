public class DisplayStriplistInsolAllocatedController {
    public list<Insolvency_Payment__c> listInsolvencyPayment {get;set;}
    public boolean ShowOk {get;set;}
    Id DividendID;
    
    public DisplayStriplistInsolAllocatedController(){
        ShowOk = false;
        DividendID = ApexPages.currentPage().getParameters().get('id');
        if(DividendID == NULL){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Dividend record ID is missing'));  
        }
        listInsolvencyPayment = [SELECT ID,Cheque_Payment_Reference_Number__c, Debtor_Name__c, 
                                 		Insolvency_Account__r.Debtor_Name_Formula__c,
                                        Account_Number__c, Estate_Number__c,Payment_Amount__c, Insolvency_Account__c
                                 FROM Insolvency_Payment__c WHERE Remittance__c = :DividendID];
		
        if(listInsolvencyPayment.isEmpty()){
            ShowOk = true;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Allocated Insolvency Payments'));
        }
    }
    
    public pageReference Save(){
        PageReference retURL = new PageReference('/apex/StriplistInsolvencyPaymentUpload?id='+DividendID);
        retURL.setRedirect(true);
        return retURL;
    }
    public pageReference Redirect(){
        PageReference retURL = new PageReference('/apex/StriplistInsolvencyPaymentUpload?id='+DividendID);
        retURL.setRedirect(true);
        return retURL;
    }

}