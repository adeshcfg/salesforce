/**************************************************************************************************
*
*  Class:   
*
*  @description : Webservice for Zum Rails Webhook
*  @author : A5E Consulting
*  @date : 09/06/2021

*************************************************************************************************/
@RestResource(urlMapping='/PaymentProcessor/*') 
global class PaymentProcessorListner{
    
    //Webhook function
    @HttpPost
    global static string listenWebHook(){    
        //Store Response
        RestRequest req = RestContext.request;
        system.debug('req.requestBody: '+req);
        Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        Map<String, Object> mapData = (Map<String, Object>) mapJSONResponse.get('Data');
        Map<String, String> mapParameters = new Map<String, String>();
        system.debug('mapData: '+mapData);
        for(String mapkey : mapData.keySet()){
            system.debug('mapkey: '+mapkey + ' value:'+mapData.get(mapkey));
        }
        map<String, String> mapHeaders = req.headers;
        
        //iterate through they keys, to store string values
        for(String paramKey : mapData.keySet()){
            mapParameters.put(paramKey, String.valueOf(mapData.get(paramKey)));
            system.debug('header: ' + paramKey + ' value: ' + mapData.get(paramKey));
        }
                
        /*
        //Test code for checking webhook contents
        List<String> param1 = new list<String>();
        param1.add('sayali.salve@canaccede.com');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(param1);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Allocated Product Payments Upload Status';
        message.plainTextBody = String.valueOf(mapData);
        system.debug('message: '+message);
        Messaging.SendEmailResult[] results;
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        results = Messaging.sendEmail(messages);
        //Test Code ends 
        */   
        
        if(PaymentProcessorListnerUtil.verifyAuthenticity(req.requestBody, mapHeaders)){
            system.debug('authetincated');
            //Decision variables
            //Create or update the payment based on transaction id
            List<Payment_Transaction__c> listVPPay = [SELECT id, Payment_Processor_Id__c
                                                      FROM Payment_Transaction__c 
                                                      WHERE Payment_Processor_Id__c =: mapParameters.get('Id') limit 1];
            system.debug('listVPPay: 1'+listVPPay);
            if(!listVPPay.isEmpty()){
                PaymentProcessorListnerUtil.updatePaymentTransaction(mapParameters);   
            }
            else{
                PaymentProcessorListnerUtil.createPaymentTransaction(mapParameters, String.valueOf(mapJSONResponse));
            }
        }else{
            system.debug('sign is wrong');
        }     
        
        return null;
    }
}