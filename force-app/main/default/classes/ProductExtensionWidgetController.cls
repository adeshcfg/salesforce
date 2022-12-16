/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a Controller class to show widget on Product . 
*  @author : A5E Consulting
*  @date : 14/07/2022

*************************************************************************************************/
public class ProductExtensionWidgetController {
    
    @AuraEnabled 
    public static List<Product_Extension__c> getProductExtension (String parentId){
      //  List<Product__c> settlprolist= [SELECT Product__c, Judgment__C from Product__c where id=: parentId ];
        system.debug('Product ID::'+parentId);
        List<Product_Extension__c> prodExtensionList= [SELECT id,Name, Account_ID__c, Dealer__c,City__c,Country__c,Value__c,Description__c,
                                                       Repossession_Date__c,Address_Line1__c,Address_Line2__c,Zip_Code__c,
                                                       Equipment_Description__c,Equipment_S_N__c,Equipment_Value__c,
                                                       Equipment_Location__c,Equipment_Returned_Date__c
                                                       from Product_Extension__c where Account_ID__c=: parentId];
        return prodExtensionList;
    }
}