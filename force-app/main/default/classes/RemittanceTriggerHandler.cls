/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Remittance object 
 *  @author : A5E Consulting
 *  @date : 09/26/2018
 
 *************************************************************************************************/
public class RemittanceTriggerHandler{
	
	public static boolean runRemittanceTrigger = true; 
    
    //After Update
    public static void handleAfterUpdate(List<Remittance__c> remsNew, Map<Id, Remittance__c> oldMap) {
    	
    	//Not all Remittance need to be processed after update
        List <Id> remIdsToProcess = new List <Id>();
        for(Remittance__c remNew : remsNew){
        	Remittance__c remOld =  oldMap.get(remNew.Id);
        	
        	if(
        		(remNew.Cheque_Payment_Reference_Number__c != remOld.Cheque_Payment_Reference_Number__c)
        		||
        		(remNew.Payment_Posting_Date__c != remOld.Payment_Posting_Date__c)
        		){
        			remIdsToProcess.add(remNew.Id);		
        		}
            
        }
        
        //Fetch and update Payments
        List<Insolvency_Payment__c> paymentsToProces = [SELECT Id,
        														Cheque_Payment_Reference_Number__c, Payment_Posting_Date__c,
        														Remittance__r.Cheque_Payment_Reference_Number__c, Remittance__r.Payment_Posting_Date__c 
                                								FROM Insolvency_Payment__c 
                                								WHERE  
                                								Remittance__c IN: remIdsToProcess
                                						];
                                						
        if(paymentsToProces.size() > 0){
       		for(Insolvency_Payment__c paymentToProces : paymentsToProces){
       			paymentToProces.Cheque_Payment_Reference_Number__c = paymentToProces.Remittance__r.Cheque_Payment_Reference_Number__c;
       			paymentToProces.Payment_Posting_Date__c = paymentToProces.Remittance__r.Payment_Posting_Date__c;
       		}
       		try{
           		 update paymentsToProces;
            }catch (DMLException ex) {
                String errorMessage = AddNewAccountToJudgmentController.readDMLMessage(ex);
                for(Remittance__c rems : remsNew){
                    If (errorMessage.trim().equalsIgnoreCase('Payment is remitted back and now it can not be edited')){
                        rems.addError('The Dividend Insolvency payment is remitted back and now it can not be edited');
                    }else{
                         rems.addError(errorMessage);
                    }
                }
            }catch(Exception ex){
                String errorMessage = ex.getMessage();
                for(Remittance__c rems : remsNew){
                    rems.addError(errorMessage);
                }
            }
        }    
    }
	public static void handleAfterInsert(List<Remittance__c> remsNew){
		ArchiveUnarchiveUtility.assignExternalCorID(remsNew);
	}
	public static void handleBeforeDelete(List<Remittance__c> remittanceRecords){
		ArchiveUnarchiveUtility.insertDeletedRecords(remittanceRecords);
	 }
    
}