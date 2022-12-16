/**************************************************************************************************
*
*  Class:   
*
*  @description : Utility class for common Functions distressed Products  record
*  @author : A5E Consulting
*  @date : 23/01/2022

*************************************************************************************************/

public class DistressedUtilites_Total {
    
      //Function to Update Current total Balance
    Public static Decimal UpdateTotalCurrentBalance(Product__c Product){
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
    }
}