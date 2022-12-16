/**************************************************************************************************
 *
 *  Class:   InsolvencyAccountCopyDataController
 *
 *  @description : This is a controller class for Insolvency Account Copy Data page
 *  @author : A5E Consulting
 *  @date : 04/04/2018
 
 *************************************************************************************************/
 
 public class InsolvencyAccountCopyDataController {

    // Insolvency Account variable to use in vf page
    public Insolvency_Account__c insolvAcc {set;get;}
    public InsolvencyAccountCopyDataController(ApexPages.StandardController controller) {
        insolvAcc = [Select Insolvency__r.Name, Insolvency__r.Debtor_2_Estate_Number__c, 
                            Insolvency__r.Insolvency_Type__c, Insolvency__r.Insolvency_Date__c, 
                            Insolvency__r.Debtor__c, Insolvency__r.Debtor_1_Date_of_Birth__c, 
                            Insolvency__r.Co_Debtor__c, Insolvency__r.Debtor_2_Date_of_Birth__c 
                            from insolvency_Account__c 
                            where Id =: ApexPages.currentPage().getParameters().get('Id')];
    }
}