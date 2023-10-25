public with sharing class Transaction30DaysController {
    public String productID {get;set;}
    public Product__c product {get;set;}
    public String transactionHeader{get;set;}
    public List<String> transactionValue{get;set;}
    
    public Transaction30DaysController(ApexPages.StandardController stdController) {
        productID =  ApexPages.currentPage().getParameters().get('id');
        product = [SELECT ID, Name, Transactions_Last_30_Days__c
                   FROM Product__c WHERE ID= :productID];
        transactionHeader= product.Transactions_Last_30_Days__c.substringBeforeLast('Amt')+'Amt';
        List<string> liststring = new List<string> {product.Transactions_Last_30_Days__c};
            transactionValue = new List<string>();
        string str='';
        system.debug('Transactions_Last_30_Days__c: '+product.Transactions_Last_30_Days__c);
        liststring = product.Transactions_Last_30_Days__c.split('\n');
        for(String strv:liststring){
            if(strv<>null){
                str=strv.replace(' ','&nbsp');
                transactionValue.add(str);
            }
            
            system.debug('liststring: '+strv);
        }
        //system.debug('transactionValue: '+transactionValue);
    }
}