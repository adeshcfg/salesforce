/**************************************************************************************************
*
*  Class: PayoffCalculatorController
*
*  @description : This is a controller class to fetch data from Product and Judgment and use for payoff calculator
*  @author : A5E Consulting
*  @date : 03/Feb/2021
*
*************************************************************************************************/
public class PayoffCalculatorController {
    
    @AuraEnabled 
    public static PayoffCalculatorWrapper getproduct(String parentId){
        List<Product__C> prodList = [SELECT Name, Customer__r.name, Current_Principal_Balance__c, Last_Payment_Date__c, Interest_Rate__c, Previous_Primary_Account_Number__c from Product__C where Id =: parentId limit 1];
        
        //Fetch related Judgment Record
        List<Account_Judgment__c> accJudgmentList = [select id, name, Judgment__c, Judgment__r.Judgment_Amount__c, Judgment__r.Judgment_Date__c, Product__c, status__c from Account_Judgment__c where Product__c =: parentId and status__c = 'Active' limit 1];
        PayoffCalculatorWrapper payoffWrapper = new PayoffCalculatorWrapper();
        
        if(accJudgmentList.size() > 0){            
            if(accJudgmentList[0].Judgment__r.Judgment_Amount__c!=null || accJudgmentList[0].Judgment__r.Judgment_Amount__c > 0){
                payoffWrapper.principalBalance = accJudgmentList[0].Judgment__r.Judgment_Amount__c;
            }else{
                payoffWrapper.principalBalance = prodList[0].Current_Principal_Balance__c;    
            }
            
            if(accJudgmentList[0].Judgment__r.Judgment_Date__c!=null){
                if(accJudgmentList[0].Judgment__r.Judgment_Date__c < prodList[0].Last_Payment_Date__c){
                    payoffWrapper.principalBalanceDate = prodList[0].Last_Payment_Date__c;
                }else{
                    payoffWrapper.principalBalanceDate = accJudgmentList[0].Judgment__r.Judgment_Date__c;  
                }
            }else{
                payoffWrapper.principalBalanceDate = prodList[0].Last_Payment_Date__c;  
            }
            
            payoffWrapper.interestRate = prodList[0].Interest_Rate__c;
            payoffWrapper.accountNumber = prodList[0].Previous_Primary_Account_Number__c;
            payoffWrapper.name = prodList[0].Customer__r.name;
        }else{
            payoffWrapper.principalBalance = prodList[0].Current_Principal_Balance__c;
            payoffWrapper.principalBalanceDate = prodList[0].Last_Payment_Date__c;
            payoffWrapper.interestRate = prodList[0].Interest_Rate__c;
            payoffWrapper.accountNumber = prodList[0].Previous_Primary_Account_Number__c;
            payoffWrapper.name = prodList[0].Customer__r.name;
        }        
        //return prodList[0];
        return payoffWrapper;
    }
    
    //Wrapper class
    public class PayoffCalculatorWrapper{
        @AuraEnabled public decimal principalBalance;
        @AuraEnabled public Date principalBalanceDate;
        @AuraEnabled public decimal interestRate;
        @AuraEnabled public String accountNumber;
        @AuraEnabled public String name;
    }
}