public class JudgmentWidgetController {
// Account number list      
    @AuraEnabled 
    public static List<Product__C> getaccountnumbers(String parentId){
        system.debug('record id is ' +parentId);
        //judglist = [SELECT Id from judgment__C where ID=:parentId];
        list<string> lisacc= new list<string>(); 
        List<Id> lisid= new List<Id>();
        list<Account_Judgment__c> accjud= [SELECT Product__c from Account_Judgment__c where Product__c!=null AND Judgment__c =: parentId ];
        for(Account_Judgment__c proid:accjud){
           lisid.add(proid.product__c); 
        }
        list<product__C> prod= [SELECT Name, First_Name__c,Co_Borrower_First_Name__c,Last_Name__c,Co_Borrower_Last_Name__c, 
                                Codebtor_First_Name__c, Codebtor_Last_Name__c,
                                Current_Principal_Balance__c,Current_Interest_Rate__c,Current_Interest_Amount__c,Current_Balance__c,
                                Product_Type__c,Collection_Agency__c,Collection_Agency_Formula__c,Refer_to_Legal__c,Collection_Sub_Status__c,
                                Interest_Rate__c from Product__C where Id In: lisid];
        
        return prod;
    }
}

/*public class JudgmentWidgetController {
    @AuraEnabled
    public static List<Product__C> getaccountnumbers(String parentId){
    List<Account_Judgment__c> judgmentprolist= [SELECT Product__c from Account_Judgment__c where id=: parentId ];
        system.debug('product record is' + judgmentprolist);
        List<Product__c> prodlist = new List<Product__c>();
        for(Account_Judgment__c productid : judgmentprolist){
            if (productid.Product__c <> NULL){
                prodlist = [SELECT Name, First_Name__c,Co_Borrower_First_Name__c,Last_Name__c,Co_Borrower_Last_Name__c,Current_Principal_Balance__c,
                            Current_Interest_Rate__c,Current_Interest_Amount__c,Current_Balance__c,Product_Type__c,Collection_Agency__c,
                            Collection_Agency_Formula__c,Refer_to_Legal__c,Collection_Sub_Status__c,Interest_Rate__c
                            from Product__C where Id =: productid.Product__c];
            }
        }
        return prodlist;
    }
    
}*/