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
       		
       		update paymentsToProces;
        }    
    }
	public static void handleAfterInsert(List<Remittance__c> remsNew){
		map<id,Remittance__c> remitMap = new map<id,Remittance__c>();
		for(Remittance__c remit : [select ID,External_Correlation_ID__c from Remittance__c where ID IN : remsNew]){
            remit.External_Correlation_ID__c = remit.ID;
            remitMap.put(remit.ID,remit);
         }
         if(!remitMap.isEmpty()){
            update remitMap.values();
         }
	}
	public static void handleBeforeDelete(List<Remittance__c> remittanceRecords){
		list<Deleted_Records__c> deletedRecords=new list<Deleted_Records__c>();
		user u=[ select id,name from User where name = 'OwnBackUpAdminUser' LIMIT 1];
		for(Remittance__c remittance: remittanceRecords){
			if(remittance.LastModifiedByID != u.ID){
				ID recordID=remittance.ID;
				Deleted_Records__c deletedRec=new Deleted_Records__c();
				deletedRec.Object_Name__c= recordId.getSObjectType().getDescribe().getName();
				deletedRec.Salesforce_Record_Id__c=remittance.External_Correlation_ID__c;
				deletedRecords.add(deletedRec);
			}
		}
		if(!deletedRecords.isEmpty()){
			insert deletedRecords;
		}
	 }
}