/**************************************************************************************************
 *
 *  Class:   
 *  @description : Controller class for Cancel PaymentController
 *  @author : A5E Consulting
 *  @date : 07/09/2021
 
 *************************************************************************************************/
public class CancelPaymentTransactionController {
	Id paymentTransactionId;
    public CancelPaymentTransactionController(ApexPages.StandardController sc){
        paymentTransactionId = ApexPages.currentPage().getParameters().get('id');
        system.debug('CancelPaymentTransaction'+paymentTransactionId);
    }
    
    public void cancelTransaction(){
        Payment_Transaction__c payTransaction = [SELECT ID, Status__c, Payment_Processor_Id__c, Parent__c
                                                 FROM Payment_Transaction__c
                                                 WHERE ID= :paymentTransactionId
                                                 LIMIT 1][0];
        if(payTransaction.Status__c == 'Completed'
        || payTransaction.Status__c == 'Cancelled'){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Completed or already Cancelled Transactions cannot be cancelled!'));
        }
        else{         
            Customer_Payment_Processor_Settings__c payProcSettings = 
        		Customer_Payment_Processor_Settings__c.getOrgDefaults();
            
            String accToken;
        	accToken = getRequestToken(payProcSettings);
            
            if (accToken != '') {
                // Instantiate a new http object
                Http h = new Http();
                // Instantiate a new HTTP request
                HttpRequest req = new HttpRequest();
                system.debug('req: '+req);
                //req.setBody(JSONPaymentTransaction);
                req.setHeader('Authorization', 'Bearer ' + accToken);
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                req.setEndpoint(payProcSettings.End_Point__c+'recurrenttransaction/'+payTransaction.Payment_Processor_Id__c);
                req.setMethod('DELETE');
        
                try{
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): '+res.getBody());
                    if(res.getStatusCode() == 200){
                        payTransaction.Payment_Processor_Response__c = res.getBody();
                        payTransaction.Status__c = 'Cancelled';
                        update payTransaction;  
                        
                        Payment_Transaction__c requestFund = new Payment_Transaction__c(ID = payTransaction.Parent__c,
                                                                                       Status__c = 'Cancelled');
                        update requestFund;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Payment Transaction Cancellation completed!'));        
                    } 
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot cancel the transaction!'));        
                    }
                }
                catch(Exception ex){
                    system.debug('exception ex: '+ex);
                } 
            }   
        }
    }
    
    //Get Access Token
    public static string getRequestToken(Customer_Payment_Processor_Settings__c payProcSettings) {
        
        string reqBody = '{'+
                        '"Username": "'+payProcSettings.Username__c+'",'+
                        '"Password": "'+payProcSettings.Password__c+'"'+
                         '}'; 						
        system.debug('reqBody'+reqBody);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqBody);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(payProcSettings.End_Point__c+'Authorize');
        system.debug('req: '+req);
        HttpResponse hresp = h.send(req);
        system.debug('hresp: '+hresp);
        system.debug('hresp.getBody(): '+hresp.getBody());
        Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        Map<String, Object> resultMap = (Map<String, Object>) wResp.get('result');
        system.debug('token'+resultMap.get('Token'));
        return String.valueOf(resultMap.get('Token'));
    }
    
    public pageReference redirect(){
        PageReference retURL = new PageReference('/'+paymentTransactionId);
        retURL.setRedirect(true);
        return retURL;
    }
}