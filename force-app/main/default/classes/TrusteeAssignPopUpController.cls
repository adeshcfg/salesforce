public class TrusteeAssignPopUpController{

    public Boolean isNewInsolvency{set;get;}
    
    public TrusteeAssignPopUpController(ApexPages.StandardController controller) {
        
        Insolvency__c insolv = (Insolvency__c)controller.getRecord();
        insolv = [SELECT CreatedDate, LastModifiedDate FROM Insolvency__c WHERE Id =: insolv.Id];
        if(insolv.CreatedDate == insolv.LastModifiedDate){
            isNewInsolvency = true;
        }
    }
}