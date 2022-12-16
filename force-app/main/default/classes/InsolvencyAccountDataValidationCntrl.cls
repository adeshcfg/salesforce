public class InsolvencyAccountDataValidationCntrl {
    public Boolean showErrorDiv {set;get;}
    public String errorMessage {set;get;}
    public String SECURED_NOT_MATCH_WITH_SERVICE = 'Warning: Secured Claim types should have Type of Service as \"Service Only\"';
    public String UNSECURED_NOT_MATCH_WITH_SERVICE = 'Warning: Unsecured Claim types should have Type of Service as \"Service and Sale\"';
    
    public InsolvencyAccountDataValidationCntrl(ApexPages.StandardController controller) {
        showErrorDiv = true;
        Insolvency_Account__c insolvAcc = [SELECT Id, 
                                                  Claim_Type__c,
                                                  Insolvency_Type__c,
                                                  Type_of_Service__c  
                                           FROM 
                                               Insolvency_Account__c 
                                           WHERE 
                                               ID =: controller.getId()];
        if(insolvAcc.Insolvency_Type__c != NULL && insolvAcc.Insolvency_Type__c.equalsignorecase('Division 1 Proposal')){
            showErrorDiv = false;
        }else if(insolvAcc.Claim_Type__c != NULL && insolvAcc.Type_of_Service__c != NULL){
            if(insolvAcc.Claim_Type__c == 'Unsecured' && insolvAcc.Type_of_Service__c != 'Service and Sale'){
                errorMessage = UNSECURED_NOT_MATCH_WITH_SERVICE;
            }
            if(insolvAcc.Claim_Type__c == 'Secured' && insolvAcc.Type_of_Service__c != 'Service Only'){
                errorMessage = SECURED_NOT_MATCH_WITH_SERVICE;
            }
        }
    }
}