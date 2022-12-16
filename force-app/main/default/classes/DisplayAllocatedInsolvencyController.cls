public class DisplayAllocatedInsolvencyController {
    public list<Insolvency_Payment__c> listInsolvencyPayment {get;set;}
    Id EFTRecordId;
    
    public DisplayAllocatedInsolvencyController(){
        EFTRecordId = ApexPages.currentPage().getParameters().get('id');
        if(EFTRecordId != null){
        	listInsolvencyPayment = [SELECT ID,Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c,Payment_Amount__c,
                                    		Payment_Source__c, Payment_Type__c,Insolvency_Account__c, Deposit_Slip__c,
                                     		Debtor_Name__c, Estate_Number__c
                                 	 FROM Insolvency_Payment__c 
                                     WHERE EFT_Files__c = :EFTRecordId];    
        }
        if(listInsolvencyPayment.isEmpty()){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Allocated Insolvency Payments to display!'));
        }
    }
    
    public pageReference Save(){
        PageReference retURL = new PageReference('/apex/InsolvencyPaymentUpload?id='+EFTRecordId);
        retURL.setRedirect(true);
        return retURL;
    }
}