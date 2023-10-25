public class Transaction30DaysController {
    public String productID {get;set;}
    public Product__c product {get;set;}
    public List<String> transactionValue{get;set;}
    
    public Transaction30DaysController(ApexPages.StandardController stdController) {
        productID =  ApexPages.currentPage().getParameters().get('id');
        product = [SELECT ID, Name, Transactions_Last_30_Days__c
                   FROM Product__c WHERE ID= :productID];
        List<string> liststring = new List<string> {product.Transactions_Last_30_Days__c};
        transactionValue = new List<string>();
        string str='';
        //5330: to replace line terminator for html BR tag 24-10-1023 23:10:00
        liststring = product.Transactions_Last_30_Days__c.split('\n');
        for(String strv:liststring){
        //5330: forcing all spaces replace with &nbsp 24-10-1023 23:10:00
            if(strv<>null){
                str=strv.replace(' ','&nbsp');
                transactionValue.add(str);
            }
        }
    }
}