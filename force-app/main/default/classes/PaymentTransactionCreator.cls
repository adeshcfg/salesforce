/**************************************************************************************************
*
*  Class:   
*
*  @description : API call for Zum Rails
*  @author : A5E Consulting
*  @date : 25/06/2021

*************************************************************************************************/
public class PaymentTransactionCreator {
    
    //Variables
    static final String REQUEST_FUNDS_ONE_TIME = 'Request Funds One Time';
    
    static Customer_Payment_Processor_Settings__c payProcSettings = 
        Customer_Payment_Processor_Settings__c.getOrgDefaults();
    static String EmailAddress;
    
    //Method to post Payments to Zumrails
    @future (callout=true)
    public static void postPaymentToZumrails(Id payTransactionId){
        Payment_Transaction__c payTransaction = [SELECT ID, Product__r.Customer__c, RecordTypeId, Day_Of_Week__c,
                                                 		Recurrence_Type__c, End_Date__c, Amount__c, Day_Of_Month__c
                                                 FROM Payment_Transaction__c 
                                                 WHERE ID= :payTransactionId][0];
        list<Account> listCustomer = [SELECT ID, User_Provided_Email__c, PersonEmail 
                                      FROM Account 
                                      WHERE ID= :payTransaction.Product__r.Customer__c];
        
        String recordTypeName = 
            Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosById().get(payTransaction.RecordTypeId).getname();
        String JSONPaymentTransaction;
        //Get the associated Customers email address
        if(!listCustomer.isEmpty() && String.isNotBlank(listCustomer[0].PersonEmail)){
            EmailAddress = listCustomer[0].PersonEmail;
        }
        
        system.debug('recordtypename: '+recordtypename);
        //Create JSON request based on Payment record type
        if(recordTypeName == REQUEST_FUNDS_ONE_TIME){
            JSONPaymentTransaction = '{'+
                                        '"Type": "Request",'+
                                        '"Amount":'+payTransaction.Amount__c+','+
                                        '"AmountType": "Fixed",'+
                                        '"AllowMoreThanOneTransaction": false,'+
                                        '"Email": "'+EmailAddress+'",'+
                                        '"SendEmailNotification": false'+
                                        '}';
        }
        else{
            system.debug('enddate: '+payTransaction.End_Date__c);
            String formattedEndDate;
            if(payTransaction.End_Date__c != null){
              formattedEndDate = payTransaction.End_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');  
            }
            
            system.debug('formatted: '+formattedEndDate);
            system.debug('payTransaction.Day_Of_Month__c '+payTransaction.Day_Of_Month__c);
            JSONPaymentTransaction = 
                '{'+
  				'"RequestFundsType": "Fixed",'+
  				'"Amount": '+ payTransaction.Amount__c+','+
  				'"IsRecurrent": true,'+
  				(payTransaction.Recurrence_Type__c == 'Weekly' ? ('"DayOfWeek": "'+payTransaction.Day_Of_Week__c+'",') : '') +
                (payTransaction.Recurrence_Type__c == 'BiWeekly' ? ('"DayOfWeek": "'+payTransaction.Day_Of_Week__c+'",') : '') +
                ((payTransaction.Recurrence_Type__c == 'Monthly'&& payTransaction.Day_Of_Month__c != 'Last Day of the Month') ? ('"DayOfMonth": '+ String.valueOf(payTransaction.Day_Of_Month__c)+',') : '') +
                ((payTransaction.Recurrence_Type__c == 'Monthly' && payTransaction.Day_Of_Month__c == 'Last Day of the Month') ? ('"LastDayOfTheMonth": '+ 'true'+',') : '') +
  				'"RecurrenceType": "'+payTransaction.Recurrence_Type__c+'",'+
  				'"EndDate": "'+formattedEndDate+'",'+
  				'"AllowMoreThanOneTransaction": false,'+
  				'"email": "'+EmailAddress+'",'+
                '"SendEmailNotification": false,  '+
                //'"EndDate": "'+formattedEndDate+'",'+
                '"Comment":' +payProcSettings.Comment__c +
				'}';
        }
        
        payTransaction.Payment_Processor_Request__c = JSONPaymentTransaction;
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
			// Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('req: '+req);
            system.debug('JSONPaymentTransaction: '+JSONPaymentTransaction);
            req.setBody(JSONPaymentTransaction);
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setEndpoint(payProcSettings.End_Point__c+'requestfunds');
            req.setMethod('POST');
    
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Map<String, Object> resultMap = (Map<String, Object>) bodyMap.get('result');
                Map<String, String> mapData = new Map<String, String>();
                for(String paramKey : resultMap.keySet()){
                    mapData.put(paramKey, String.valueOf(resultMap.get(paramKey)));
                    system.debug('header: ' + paramKey + ' value: ' + mapData.get(paramKey));
                }

                system.debug('resultMap: '+resultMap);
                payTransaction.Payment_Processor_Response__c = res.getBody();
                payTransaction.Payment_Processor_Id__c = mapData.get('Id');
                String connectURL = mapData.get('ConnectUrl');    
                system.debug('connectURL before :'+connectURL);
                connectURL = connectURL.substringAfter(payProcSettings.Payment_URL_To_Get_Param__c);
                system.debug('connectURL: '+connectURL);
                String connectURLFinal = payProcSettings.Base_URL_for_Payment_Page_Iframe__c+'?'+connectURL;
                system.debug('connectURLFinal: '+connectURLFinal);
                payTransaction.Connect_Url__c = mapData.get('ConnectUrl');
                payTransaction.Site_ConnectURL__c = connectURLFinal;
                payTransaction.Customer_Email_Address__c = EmailAddress;
                payTransaction.Status__c = 'In Progress';
                system.debug('payTransaction: '+payTransaction);
                update payTransaction;
            }
            catch(Exception ex){
                system.debug('exception ex: '+ex);
            } 
        }
    }
    
    //Get Access Token
    public static string getRequestToken() {
        
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
}