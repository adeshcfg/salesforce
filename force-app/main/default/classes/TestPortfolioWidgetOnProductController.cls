/**************************************************************************************************
*
*  Class:   
*
*  @description : PortfolioWidgeton Product
*  @author : A5E Consulting
*  @date : 30/09/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestPortfolioWidgetOnProductController {
   
    static testMethod void insertTestData(){
        Portfolio_Name__c protfolio =  new Portfolio_Name__c ();
        protfolio.Name = 'MBNA24';
        protfolio.Account_Purchasing_Entity_ID__c = 'test';
        Insert protfolio;
        
       
        product__c productInstance = new product__c();
        productInstance.Portfolio_Name_Lookup__c = protfolio.ID;
        insert productInstance;
        portfolioWidgetOnProductController.getproduct(productInstance.ID);
        
    }


}