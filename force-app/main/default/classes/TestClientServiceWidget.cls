/**************************************************************************************************
*
*  Class:   
*
*  @description : TestClientServiceWidget
*  @author : A5E Consulting
*  @date : 21/06/2022  

*************************************************************************************************/
@isTest
public class TestClientServiceWidget {
     public static testMethod void testClientServiceController(){
        test.startTest();
       
        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        place.Commission_Rate__c = 10;
        place.Commission_Rate_Mode__c = 'Commission Rate Only';
        place.Agency_Phone_Number__c = '123456789';
        insert place;
        
        Product__c prod = new Product__c();
        prod.Name = '1566P000';
        prod.Commission_Rate__c=13;
        prod.Value_Tier_at_Time_of_Placement__c = 'A';
        prod.Collection_Agency_Placement__c = place.id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        
        
        ClientServiceWidgetController.getPlacement(prod.id);
        test.stopTest();
    }
    
}