public class DisplayAllocatedProductController {
    public list<Product_Payments__c> listProductPayment {get;set;}
    Id EFTRecordId;
    public DisplayAllocatedProductController(){
        EFTRecordId = ApexPages.currentPage().getParameters().get('id');
        if(EFTRecordId != null){
        	listProductPayment = [SELECT ID, CCS_Account__c, Cheque_Number__c, Payment_Posting_Date__c,
                              		 	 Payment_Source__c, FairShare_Amount__c, Payment_Amount__c, CCS_Account__r.First_Name__c,
                                  		 CCS_Account__r.Last_Name__c
                              	  FROM Product_Payments__c 
                                  WHERE EFT_Files__c = :EFTRecordId];    
        }
        
        if(listProductPayment.isEmpty()){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Allocated Product Payments to display!'));
        }
    }
    public pageReference redirectPaymentUpload(){
        PageReference retURL = new PageReference('/apex/PaymentUpload?id='+EFTRecordId);
        retURL.setRedirect(true);
        return retURL;
    }
}