/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a Controller class to Show portfolio data on product . 
*  @author : A5E Consulting
*  @date : 29/09/2022

*************************************************************************************************/
public class portfolioWidgetOnProductController {
  @AuraEnabled 
    public static List<Portfolio_Name__c> getproduct(String parentId){
    	List<Product__C> prodlists= [SELECT id,name,Portfolio_Name_Lookup__c from Product__C where id=: parentId ];
        list<Portfolio_Name__c> portfolioList = new List<Portfolio_Name__c>();
        for(Product__C proid:prodlists){
            if(proid.Portfolio_Name_Lookup__c <> NULL){
            	portfolioList = [SELECT id,Name,Account_Purchasing_Entity_ID__c,Account_Type__c,Bank_Account_Name__c,Bank_Account_Number__c,
                                 Bill_of_Sale__c,Charge_Off_policy__c,Collateral_Information_Provided__c,Ineligible_Accounts__c,
                                 Interest_Accrual_Strategy__c,Interest_Purchase__c,Investment_Group__c,Media_Availabilty__c,Media_Types_Available__c,
                                 Portfolio_Group_Name__c,Purchase_Accounts__c,Purchase_Amount__c,Purchase_Code__c,Purchase_date__c,
                                 Purchase_Factor__c,Purchase_Group__c,Purchase_Group_Debtnext__c,Purchase_Price_Percent__c,Purchase_Value__c,Purchasing_Entity__c,
                                 Putback_provision_days__c,Putback_buyback_policy__c,Seller__r.Name,Purchase_ID__c
                                 from Portfolio_Name__c where Id =: proid.Portfolio_Name_Lookup__c];
            }
        }
        
        return portfolioList; 
    }
}