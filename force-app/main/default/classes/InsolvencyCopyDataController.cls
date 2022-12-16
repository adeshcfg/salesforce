/**************************************************************************************************
 *
 *  Class:   InsolvencyCopyDataController
 *
 *  @description : This is a controller class for Insolvency Copy Data page
 *  @author : A5E Consulting
 *  @date : 13/04/2018
 
 *************************************************************************************************/
 
 public class InsolvencyCopyDataController {

    // Insolvency variables to use in vf page
    public Insolvency__c insolv {set;get;}
    
    public InsolvencyCopyDataController(ApexPages.StandardController controller) {
        insolv = [Select Name, Debtor_2_Estate_Number__c, 
                         Insolvency_Type__c, Insolvency_Date__c, 
                         Debtor__c, Debtor_1_Date_of_Birth__c, 
                         Co_Debtor__c, Debtor_2_Date_of_Birth__c 
                         from insolvency__c 
                         where Id =: ApexPages.currentPage().getParameters().get('Id')];
    }
}