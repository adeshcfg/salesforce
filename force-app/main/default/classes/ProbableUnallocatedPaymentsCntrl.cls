public class ProbableUnallocatedPaymentsCntrl {
    public List<Unallocated_Payment__c> unAllocPayList {set;get;}
    public Insolvency_Account__c insolvAcc {set;get;}
    public ProbableUnallocatedPaymentsCntrl(ApexPages.StandardController controller) {
        insolvAcc = [SELECT Id, Name, Bank_Name__c FROM Insolvency_Account__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
        unAllocPayList = [SELECT Id, Name, Allocated__c, Account_Number__c, Bank_Name__c, Remittance__c, Unallocated_Amount__c, Estate_Number__c
                            FROM 
                                Unallocated_Payment__c 
                            WHERE     
                                Account_Number__c=: insolvAcc.Name 
                                AND Allocated__c = false
                                AND (Bank_Name__c =: insolvAcc.Bank_Name__c OR Bank_Name__c = NULL)
                                ];
    }

}