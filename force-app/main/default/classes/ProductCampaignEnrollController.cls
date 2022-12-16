/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is used for Product Campaign Verification 
 *  @author : A5E Consulting
 *  @date : 06/17/2021
 
 *************************************************************************************************/
 
public without sharing class ProductCampaignEnrollController {
    
    //Variables
    public Boolean nullEnrollID {get;set;}
    public Boolean campaignEnrollError {get;set;}
    public Boolean campaignCodeExpired {get;set;}
    public Boolean alreadyEnrolled {get;set;}
    
       
    //Product record
    public Product__c prd {get;set;}
    
    //Constants
    public static final String ENROLL_STATUS_ENROLLED = 'Enrolled';
    public static final String ALREADY_ENROLLED = 'Already Enrolled';
    
    //Constructor    
    public ProductCampaignEnrollController(){
        
        nullEnrollID = true;
        campaignEnrollError = false;
        campaignCodeExpired = false;
        alreadyEnrolled = false;
               
    }  
    
    //Veirfying prd
    public void checkVerifyRequest() {
    
        String cCode = ApexPages.currentPage().getParameters().get('cCode');
        
        if (cCode != null && cCode != '') {
        
            nullEnrollID = false;
            
            prd = getProductByCampaignId(cCode);
            
            if (prd != null) { 
                // Enroll already complete    
                if(prd.Campaign_Enroll_Status__c == ENROLL_STATUS_ENROLLED){
                    alreadyEnrolled = True; 
                }
                
                // Check if email expired
                else if (Datetime.now() > prd.Campaign_Expiration_Date__c) {
                    // Expired (handle error case)
                    campaignCodeExpired = true;
                }                    
                
            } 
            else {
                // Campaign code not recognized
                campaignEnrollError = true;
            }
            
        } else {
            // Campaign code missing
            campaignEnrollError = true;                        
        }
        //Display correct message
        if (campaignEnrollError == false && campaignCodeExpired == false && alreadyEnrolled == false) {
        
            //Update prd
            prd.Campaign_Enroll_Status__c = ENROLL_STATUS_ENROLLED;
            prd.Campaign_Enroll_Completion_Date__c = Datetime.now();
            
            try{
                ProductTriggerHandler.runProductTrigger = false;
                update prd;
                ProductTriggerHandler.runProductTrigger = true;
            }   
            catch(Exception exp){
                campaignEnrollError = true;
                System.debug('Exception = '+exp);
            }
        }
    }  
    
    // Fetching Product with Campaign Code
    public Product__c getProductByCampaignId(String cCode) { 
        List<Product__c> products = [SELECT Id, 
                                            Campaign_Code__c,
                                            Campaign_Enroll_Status__c,
                                            Campaign_Enroll_Completion_Date__c,
                                            Campaign_Expiration_Date__c 
                                            FROM Product__c 
                                            WHERE 
                                            recordType.name='Credit Card Account' and 
                                            Campaign_Code__c!=null and                                          
                                            Campaign_Code__c =: cCode];
        
        System.debug('Products Size :'+products.size());
        return (products.size() > 0) ? products[0] : null;
    }
}