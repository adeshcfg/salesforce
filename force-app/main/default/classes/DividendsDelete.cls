/**
* @description       : Dividend delation with the related payments and Assignment records.
* @author            : nagendra.yanadigalla@canaccede.com
* @last modified on  : 2024-11-18
* @last modified by  : nagendra.yanadigalla@canaccede.com
**/

public class DividendsDelete {
    // public static boolean displayPopup;
    
    Public DividendsDelete(ApexPages.StandardController controller) {
    }
    public static void deleteDividend(){
        
        string dividendId = ApexPages.currentPage().getParameters().get('id');
        
        Remittance__c dividend = new Remittance__c();
        List<SObject> recordsToDelete = new List<SObject>();
        
        try{  
            dividend = [SELECT Id, Email_to_Case_Reference_Number__c 
                        FROM Remittance__c 
                        WHERE Id = :dividendId];
        }catch(Exception e) {
            System.debug('List has no rows for assignment to SObject' + e.getMessage());
        } 
        
        // If there is an Assignment record, delete it
        if (String.isNotBlank(dividend.Email_to_Case_Reference_Number__c)) {
            
            List <Case> assignment = [SELECT Id 
                                      FROM case 
                                      WHERE ID = :dividend.Email_to_Case_Reference_Number__c LIMIT 1];
            try{ 
                if(Test.isRunningTest() && dividendId == '111111111111111'){
                    DmlException dmlEx = new DmlException('TEST_EXCEPTION_MESSAGE');
                    throw new DmlException(dmlEx);
                }
                if (!assignment.isEmpty()) {
                    DELETE assignment;                
                }
                
            }catch (DmlException de) {
                System.debug('Exception during assignment deletion ' + de.getMessage());
                Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getMessage());
                insert error;
            } 
            
        }
        
        //related Insolvency Payment records
        List<Insolvency_Payment__c> insolvencyPayments = [SELECT Id 
                                                          FROM Insolvency_Payment__c 
                                                          WHERE Remittance__c = :dividendId];
        
        try{  
            if(Test.isRunningTest() && dividendId == '111111111111111'){
                DmlException dmlEx = new DmlException('TEST_EXCEPTION_MESSAGE');
                throw new DmlException(dmlEx);
            }
            
            if (!insolvencyPayments.isEmpty()) {
                DELETE insolvencyPayments;
            }
            
        }catch (DmlException de) {
            System.debug('Exception during insolvency Payments deletion ' + de.getMessage());
            Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getMessage());
            insert error;
        }
        
        // related Unallocated_Payment__c records
        List<Unallocated_Payment__c> unallocatedPayments = [SELECT Id 
                                                            FROM Unallocated_Payment__c
                                                            WHERE Remittance__c = :dividendId];
        try{  
            if(Test.isRunningTest() && dividendId == '111111111111111'){
                DmlException dmlEx = new DmlException('TEST_EXCEPTION_MESSAGE');
                throw new DmlException(dmlEx);
            }
            
            if (!unallocatedPayments.isEmpty()) {
                DELETE unallocatedPayments;
            }
            
        }catch (DmlException de) {
            System.debug('Exception during unallocated Payments deletion ' + de.getMessage());
            Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getMessage());
            insert error;
        } 
        
        //Dividend record to the delete
        
        try{ 
            if(Test.isRunningTest() && dividendId == '111111111111111'){
                DmlException dmlEx = new DmlException('TEST_EXCEPTION_MESSAGE');
                throw new DmlException(dmlEx);
            }
            
            DELETE dividend;
            
        }catch (DmlException de) {
            System.debug('Exception during Dividend deletion ' + de.getMessage());
            Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getMessage());
            insert error;
        } 
    } 
    //displayPopup = true;
    
    public static PageReference closePopup() {
        return new ApexPages.Action('{!List}').invoke();
    }
    
}