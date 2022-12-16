public class InsolvencyAccountPopupMessage {
    public String insolvencyAccntId{get;set;}
    public Boolean displayPopup {get;set;}
    public Insolvency_Account__c insolvncyAccnt{get;set;}
    public InsolvencyAccountPopupMessage(ApexPages.StandardController controller) {
        insolvencyAccntId = ApexPages.currentPage().getParameters().get('id');
        insolvncyAccnt = [SELECT Id,Insolvency_Status__c,Accepted_Sent_to_Collections__c
                          FROM Insolvency_Account__c WHERE Id =: insolvencyAccntId limit 1];
        displayPopup = true;
    }
    
    //public void showPopup()
    //{	
    
    //displayPopup = true;
    
    //}
    public void closePopup()
    {	
        
        displayPopup = false;
        redirectPopup();
        
    }
    public pagereference redirectPopup()
    { 
        insolvncyAccnt.Accepted_Sent_to_Collections__c = false;
        update insolvncyAccnt;
        PageReference newPage = New PageReference('/apex/InsolvencyAccountView');
        newPage.getParameters().put('id',insolvncyAccnt.id);
        newPage.setRedirect(true);
        return newPage;
        
    }
}