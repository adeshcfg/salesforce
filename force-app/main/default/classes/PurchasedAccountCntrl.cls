/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to initiate debtnext purchased insolvency account export job  
 *  @author : A5E Consulting
 *  @date : 10/09/2016
 
 *************************************************************************************************/
 
public class PurchasedAccountCntrl {
	
	public Boolean showJobButton{get;set;}
	public Boolean showResultMessage{get;set;}	
	public List <PurchasedAccountListWrpper> palWrapperList{get;set;}
	
	//Constructor
	public PurchasedAccountCntrl(){
		showJobButton = false;
		showResultMessage = false;
		palWrapperList = new List <PurchasedAccountListWrpper>();
		
		List <Purchased_Account_List__c> pals = [Select Id, Name, 
														Number_of_Records_Processed__c, 
														CreatedDate 
														from Purchased_Account_List__c 
														order by CreatedDate desc
														Limit 30];
		if(pals.size() > 0){
			for(Purchased_Account_List__c pal : pals){
				palWrapperList.add(new PurchasedAccountListWrpper(pal));
			}
		}
		
		List<Insolvency_Account__c> pendingExportAccounts = [Select id, name, 
																	Purchase_Export_Completed__c, Purchase_Export_Completed_Date__c 
																	from Insolvency_Account__c
																	where Purchase_Export_Completed__c = false
																	//and Insolvency_Status__c = 'Purchased'
																	];
		if(pendingExportAccounts.size() > 0){
			showJobButton = true;			
		}
	}
	
	//Execute when Click on VFpage Button and create DebtNext CSV File
    public void runJob(){
    	PurchasedAccountCSVUtil.runCSVJob();
    	showJobButton = false;
		showResultMessage = true;    	
    }
	
	//Wrapper class
	public class PurchasedAccountListWrpper{
        public Purchased_Account_List__c pal{get;set;}
        public string recordLink{get;set;}
        
        public PurchasedAccountListWrpper(Purchased_Account_List__c pal){
            this.pal = pal;
            recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + pal.Id;
        }        
    }
}