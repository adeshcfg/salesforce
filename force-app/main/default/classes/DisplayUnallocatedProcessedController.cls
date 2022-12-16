public class DisplayUnallocatedProcessedController {
public list<Unallocated_Payment__c	> listUnallocatedPayments {get;set;}
    Id EFTRecordId;
    public String paymentRecordType{get;set;}
    
    public DisplayUnallocatedProcessedController(){
        EFTRecordId = ApexPages.currentPage().getParameters().get('id');
        paymentRecordType = ApexPages.currentPage().getParameters().get('rt');
        
        if(EFTRecordId != null){
        	listUnallocatedPayments = [SELECT ID, Account_Number__c, Cheque_Number__c, Payment_Posting_Date__c,
                              		      	  Unallocated_Fairshare_Amount__c, Unallocated_Amount__c, Debtor_Name__c,
                                       		  Estate_Number__c
                              		   FROM Unallocated_Payment__c 
                                       WHERE EFT_Files__c = :EFTRecordId];    
        }
        
        if(listUnallocatedPayments.isEmpty()){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Unallocated Payments to display!'));
        }
    }
    public pageReference redirectPaymentUpload(){
        PageReference retURL;
        if(paymentRecordType == 'CCS'){
            retURL = new PageReference('/apex/PaymentUpload?id='+EFTRecordId);
        }
        else{
            retURL = new PageReference('/apex/InsolvencyPaymentUpload?id='+EFTRecordId);
        }
        retURL.setRedirect(true);
        return retURL;
    }
}