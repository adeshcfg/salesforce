public class InsolvencyPopupMessage {
 public String insolvencyAccntId{get;set;}

public Boolean sentToCollections {get;set;}
 public Insolvency_Account__c insolvncyAccnt{get;set;}
  
public InsolvencyPopupMessage(ApexPages.StandardController controller){
        
        //Insolvency Account ID
        insolvencyAccntId = ApexPages.currentPage().getParameters().get('id');  
          
        //Insolvency Account record
insolvncyAccnt = [SELECT Id,Name,Accepted_Sent_to_Collections__c,Insolvency_Status__c  
                            FROM Insolvency_Account__c WHERE Id =: insolvencyAccntId limit 1];
 if(insolvncyAccnt.Accepted_Sent_to_Collections__c == true && insolvncyAccnt.Insolvency_Status__c!='Sent to collections'){
            senttocollections = true;
        }              
    }
           
public PageReference displayPopup() { 
    PageReference newPage;
    if(insolvncyAccnt.Insolvency_Status__c!='Sent to collections'){
            /*newPage = New PageReference('/apex/InsolvencyAccntPopUp');
        	newPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        	newPage.setRedirect(true);*/
        	return null;

    }else{
      
        newPage = New PageReference('/apex/InsolvencyAccountView');
        newPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        newPage.setRedirect(true);
        return newPage;
    }
			
}
}