/**************************************************************************************************
*
*  Class:   
*
*  @description : ProductExtensionTriggerHandler
*  @author : A5E Consulting
*  @date : 01/07/2022  

*************************************************************************************************/
public class ProductExtensionTriggerHandler {
    public static void handleAfterInsert(List<Product_Extension__c> listNewProducts){
        for(Product_Extension__c prodExt :listNewProducts ){
            if(prodExt.Account_ID__c != null){
                //Call API
                // PortalProductProcessingAPI.processProduct(prodExt.Account_ID__c);
            }
        } 
    }
    
    public static void handleAfterUpdate(List<Product_Extension__c> listNewProducts){
        for(Product_Extension__c prodExt :listNewProducts ){
            if(prodExt.Account_ID__c != null){
                //Call API
                // PortalProductProcessingAPI.processProduct(prodExt.Account_ID__c);
            }
        } 
    }
    public static void handleBeforeInsert(List<Product_Extension__c> listNewProducts){
        set<id> productIds=new set<id>(); 
        for(Product_Extension__c prodExt:listNewProducts){
            productIds.add(prodExt.Account_ID__c);
        }
        list<Product_Extension__c> prodExtList=[select id,name from Product_Extension__c where Account_ID__c in :productIds];
        for(Product_Extension__c prodExtension :listNewProducts)
        {
            if(prodExtList.size()>=1)
                prodExtension.addError('More than 1 Product Extension record is not Allowed on Product');
        }
    }
    
}