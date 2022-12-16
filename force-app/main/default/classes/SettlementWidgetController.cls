public class SettlementWidgetController {
//@AuraEnabled Public static List<Settlement__C> settljudglist{set;get;}
 
	@AuraEnabled 
    public static List<Product__C> getproduct(String parentId){
    	List<Settlement__C> settlprolist= [SELECT Product__c, Judgment__C from Settlement__C where id=: parentId ];
        system.debug('product record is' + settlprolist);
        List<Id> lisid= new List<Id>();
        list<product__C> prodList = new List<Product__C>();
        for(Settlement__C proid:settlprolist){
            if(proid.product__c <> NULL){
            	prodList = [SELECT Name, First_Name__c,Co_Borrower_First_Name__c,Last_Name__c,Co_Borrower_Last_Name__c,Current_Principal_Balance__c,
                            Current_Interest_Rate__c,Current_Interest_Amount__c,Current_Balance__c,Product_Type__c,Collection_Agency__c,
                            Collection_Agency_Formula__c,Refer_to_Legal__c,Collection_Sub_Status__c,Interest_Rate__c
                            from Product__C where Id =: proid.product__c];
            }else if(proid.Judgment__c <> NULL){
                prodList = JudgmentWidgetController.getaccountnumbers(proid.Judgment__c);
            }
        }
        
        return prodList;
        
        
    }
    
}