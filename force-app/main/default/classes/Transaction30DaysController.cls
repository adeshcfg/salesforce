public with sharing class Transaction30DaysController {
	//public String TransactionData {get;set;}
    public String productID {get;set;}
    public Product__c product {get;set;}
    //public string[] myval {get; set;}
    
    public Transaction30DaysController(ApexPages.StandardController stdController) {
        productID =  ApexPages.currentPage().getParameters().get('id');
        product = [SELECT ID, Name, Transactions_Last_30_Days__c
                   FROM Product__c WHERE ID= :productID];
        system.debug('product: '+product);
        //TransactionData = product.Transactions_Last_30_Days__c;
        //TransactionData.replace(' ','&nbsp;');
        
		/*system.debug('TransactionData'+TransactionData);
        String spl = product.Transactions_Last_30_Days__c;
        String sp2 =  spl.replace(' ','\n');

        system.debug('sp2'+sp2);
        sp2.replaceAll( '\\s+', '');
        system.debug('sp2'+sp2);
        string[] myval = new string[] {TransactionData};
            system.debug('myval'+myval);*/

        //product.Transactions_Last_30_Days__c = String.join(' ', '\n');

    }
}