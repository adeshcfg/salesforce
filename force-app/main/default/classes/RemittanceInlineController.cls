/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to display Remittance Documents
 *  @author : A5E Consulting
 *  @date : 09/10/2018
 *  
 *************************************************************************************************/
public class RemittanceInlineController{
	
	public List<RemAttachWrap> remAttachWrapList{get;set;}
	
	//Constructor
    public RemittanceInlineController(ApexPages.StandardController controller) {
    	
    	String insolvencyPaymentId = ApexPages.currentPage().getParameters().get('Id');
    	
    	remAttachWrapList = new List<RemAttachWrap>();
    	
    	Insolvency_Payment__c insolvencyPayment = [Select Id, Name, Remittance__c 
    														from Insolvency_Payment__c
    														where  Id =: insolvencyPaymentId];
    														
       
    	Id remittanceId = insolvencyPayment.Remittance__c;
    	
    	if(remittanceId != null){
    		
    		Remittance__c paymentRemittance = [Select Id, Email_to_Case_Reference_Number__c 
    													 from Remittance__c
    													 where Id =: remittanceId];
    													 
    		String caseRefId = paymentRemittance.Email_to_Case_Reference_Number__c;
    		
    		if(!String.isBlank(caseRefId)){
    			List<Attachment> remAttachList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId 
														FROM Attachment 
														WHERE ParentId in (select id from EMailMessage where relatedToid =: caseRefId) 
														ORDER BY CreatedDate DESC];
    												
	    		if(remAttachList.size() > 0 ){
	    			for(Attachment remAttach : remAttachList){
	    				remAttachWrapList.add(new RemAttachWrap(remAttach));
	    			}
	    		}
    			
    		}
    		
    		
    		/*
    		
    		List<Attachment> remAttachList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId FROM Attachment 
    												WHERE ParentId =: remittanceId];
    												
    		if(remAttachList.size() > 0 ){
    			for(Attachment remAttach : remAttachList){
    				remAttachWrapList.add(new RemAttachWrap(remAttach));
    			}
    		}
    		*/
    	}
    }
    
    //Attachment Wrapper
    public class RemAttachWrap{
    	
        public Attachment attach{get;set;}
        
        public RemAttachWrap(Attachment attach){
            this.attach = attach;
            
        }
    }
}