/**************************************************************************************************
*
*  Class:   
*
*  @description : Test   class for common Functions distressed Products  record
*  @author : A5E Consulting
*  @date : 23/01/2022

*************************************************************************************************/
@isTest
public class TestDistressedUtilites_Total{
      static testMethod void UpdateTotalCurrentBalanceTest(){
           Decimal totCurrBal=0;
           Product__c prod = new Product__c();
       	   prod.name = '123451212';
           prod.Current_Principal_Balance__c = 100;
           prod.Current_Interest_Amount__c =20;
           prod.Current_Bal_NSF_Fees__c =10;
           insert prod;
           totCurrBal=DistressedUtilites_Total.UpdateTotalCurrentBalance(prod);
      }
      //Function to Update Current total Balance
   /* Public static Decimal UpdateTotalCurrentBalance(Product__c Product){
        Decimal totCurrBal=0;
        //Current_Principal_Balance__c
        //Current_Interest_Amount__c
        //Recoverable_Fee__c
        //Current_Bal_NSF_Fees__c
        System.debug('UpdateTotalCurrentBalance Called');
        if(Product.Current_Principal_Balance__c!=null){
            totCurrBal += Product.Current_Principal_Balance__c;
        }
        if(Product.Current_Interest_Amount__c!=null){
            totCurrBal += Product.Current_Interest_Amount__c;
        }
        if(Product.Recoverable_Fee__c!=null){
            totCurrBal += Product.Recoverable_Fee__c;
        }
        if(Product.Current_Bal_NSF_Fees__c!=null){
            totCurrBal += Product.Current_Bal_NSF_Fees__c;
        }
        Return totCurrBal;
    }*/
}