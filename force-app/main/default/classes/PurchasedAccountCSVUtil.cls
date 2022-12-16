/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a utility class that creates debtnext purchased insolvency account export csv  
 *  @author : A5E Consulting
 *  @date : 10/09/2016
 
 *************************************************************************************************/
 
public class PurchasedAccountCSVUtil {
	
	public static final String csvHeader = 'pri_acctno,sec_acctno,type\n';
	
	public static Purchased_Account_List__c runCSVJob(){
		Purchased_Account_List__c pal;
		
		List<Insolvency_Account__c> pendingExportAccountsList = getPendingExportAccountsList();
		
		if(pendingExportAccountsList.size() > 0){
			
			String createPurchaseExportCSV = createPurchaseExportCSV(pendingExportAccountsList);
			if(String.isNotBlank(createPurchaseExportCSV)){
				pal = new Purchased_Account_List__c();
				pal.Number_of_Records_Processed__c = pendingExportAccountsList.size();	
				insert pal;	
				
				//CSV Attachment
		        Attachment attch = new Attachment();
		        attch.Body = Blob.valueOf(createPurchaseExportCSV);
		        attch.Name = 'DebtNext_Purchased_Accounts.csv';
		        attch.ParentId = pal.ID ; 
		        insert attch;	
		        
		        //Update Export flag
		        List<Insolvency_Account__c> palUpdateList = New List<Insolvency_Account__c>();
		        for(Insolvency_Account__c pendingExportAccount : pendingExportAccountsList){
		        	pendingExportAccount.Purchase_Export_Completed_Date__c = System.Today();
            		pendingExportAccount.Purchase_Export_Completed__c = true;    
            		palUpdateList.add(pendingExportAccount);
                }
                if(palUpdateList.size() > 0){
                	InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
                	update palUpdateList;
                	InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
                }
			}
		}
		
		return pal;
	}
	
	private static List<Insolvency_Account__c> getPendingExportAccountsList(){
		
		return [Select id, name, 
						Purchase_Export_Completed__c, Purchase_Export_Completed_Date__c,
						Insolvency__r.Name, //pri_acctno
						Insolvency__r.Debtor_2_Estate_Number__c, //sec_acctno
						Account_Type__c //type
						from Insolvency_Account__c
						where Purchase_Export_Completed__c = false
						and Insolvency_Status__c = 'Purchased'];
		
	} 
	
	private static String createPurchaseExportCSV(List<Insolvency_Account__c> pendingExportAccountsList){
		String finalStr = '' ;		
		for(Insolvency_Account__c pendingExportAccount : pendingExportAccountsList){
			finalStr += 
						'"'+pendingExportAccount.Insolvency__r.Name //pri_acctno
						+'","'+pendingExportAccount.Insolvency__r.Debtor_2_Estate_Number__c //sec_acctno
						+'","'+pendingExportAccount.Account_Type__c //type 
						+'"\n';
		}
		finalStr = csvHeader + finalStr;  
		
		return finalStr;		
	}
}