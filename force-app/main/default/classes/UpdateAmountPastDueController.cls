public class UpdateAmountPastDueController {
    public static String sJOSN;
    public String productID {get;set;}
    public String responseMessage {get;set;}
    public boolean panelHide{get;set;}
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Fidem Portal API');
    public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();
    
    public UpdateAmountPastDueController(){
        panelHide = true;
        responseMessage = 'SUCCESS';
    }
 
    public pageReference updateAmountPastDueAPI(){
        responseMessage = '';
        panelHide = true;
        productID =  ApexPages.currentPage().getParameters().get('id');
        system.debug('productId'+productId);
        list<Product__c> listProduct = [SELECT ID, Name
                                                       FROM Product__c 
                                                       WHERE ID=: productID];
        system.debug('listProduct'+listProduct);
         Product__c prodData; 
         Payload payLoad = new Payload();

         if(!listProduct.isEmpty()){
            prodData = listProduct[0];
         
            for(Product__c productData : listProduct){
            payLoad.acctId = productData.name;
            }
        }
        sJOSN = JSON.serialize(payLoad);

        //Get access token for http request
        String accToken;
        accToken = AzureUtility.getRequestToken('Fidem Portal API');
        system.debug('accToken&&'+accToken);
        system.debug('sJOSN-->'+sJOSN);
        if (accToken != '') {
            ResponseJSON responceJSONData = new ResponseJSON();
            try{
                // Send the request, and return a response
                HttpResponseData httpresData = callAPI(accToken,sJOSN);
                responseMessage = processRequest(httpresData,prodData); 
                system.debug('responseMessage@@'+responseMessage);
            }
            catch(Exception ex){
                API_Error__c apiErrorData = New API_Error__c();
                apiErrorData.Error__c = prodData.name +' '+'Record failed due to'+' '+ex.getMessage()+' '+ex.getStackTraceString();
                apiErrorData.Action__c = 'API Failed';
                if(!Test.isRunningTest()){
                    apiErrorData.Request__c = prodData.name;
                }
                listAPIErrors.add(apiErrorData);
                database.insert(listAPIErrors);
                responseMessage = system.label.Fidem_API_Error_Message;
                panelHide = false;
                //responseMessage = prodData.name +' '+'Record failed due to'+' '+ex.getMessage()+' '+ex.getStackTraceString();
                system.debug('responseMessage@@@@'+responseMessage);
            }
        }
        //Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Processing is completed'));
        system.debug('responseMessage@@@@'); 
        //responseMessage = message;
        return null;
    }
    public string processRequest(HttpResponseData httpresData,product__c prodData){
        //product__c prodData = new product__c(); 
        system.debug('httpresData--->'+httpresData);
        prodData.Outbound_API_Request_Body__c = httpresData.requestBody;
        HttpResponse res = httpresData.res;
        
        system.debug('res***:: '+res);
        system.debug('res body***:: '+res.getBody());
        prodData.Outbound_API_Response_Body__c = res.getBody();
        system.debug('res getStatusCode***:: '+res.getStatusCode());
        system.debug('Outbound res body::' +res.getBody());
        String statusCode = String.valueOf(res.getStatusCode());
        //system.debug('responceJSONData-->'+responceJSONData);
        system.debug('statusCode--->'+statusCode);
        try{
            if(statusCode.startsWith('2') && !test.isRunningTest()){
                ResponseJSON responceJSONData = (ResponseJSON)JSON.deserialize(res.getBody(), ResponseJSON.class);
                if(responceJSONData.isSuccess == true){
                    HostIntegrationDataResult dataResult = responceJSONData.data;
                    prodData.Past_Due_Amount__c = Integer.valueOf(dataResult.amDlq);
                    prodData.Past_Due_Amount_Refresh_Date__c = Datetime.now();
                    ProductTriggerHandler.runProductTrigger = false;
                    update prodData;
                    ProductTriggerHandler.runProductTrigger = true;
                    responseMessage = 'SUCCESS';
                    panelHide = true;
                }else{
                    //responseMessage = responceJSONData.returnMessage;
                    responseMessage = system.label.Fidem_API_Error_Message;
                    panelHide = false;
                }
            }else if(res.getStatusCode() == 500){
                system.debug('inside 500***:: ');
                ResponseErrorJSON responceErrorJSONData = (ResponseErrorJSON)JSON.deserialize(res.getBody(), ResponseErrorJSON.class);
                system.debug('outside 500***2020:: ');
                //responseMessage = processRequest(httpresData,prodData);
                responseMessage = system.label.Fidem_API_Error_Message;
                panelHide = false;
                if(responceErrorJSONData.Code == '2020'){
                    system.debug('inside 500***2020:: ');
                    String accToken = AzureUtility.getRequestToken('Fidem Portal API');
                    httpresData = callAPI(accToken,sJOSN);
                }
            }else{
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                //API error log
                API_Error__c apiErrorData = New API_Error__c();
                apiErrorData.Error__c = prodData.name +' '+'Record failed due to'+' '+bodyMap.get('ReturnMessage');
                apiErrorData.Action__c = 'Fidem API Failed with statusCode'+res.getStatusCode();
                system.debug('httpresData.requestBody--->'+httpresData.requestBody);
                system.debug('httpresData.requestBody.length()---->'+httpresData.requestBody.length());
                if(httpresData.requestBody.length() > 131071){
                    apiErrorData.Request__c = httpresData.requestBody;
                }else{
                    apiErrorData.Request__c = httpresData.requestBody;
                }
                
                if(res.getBody().length() > 131071){
                    
                    apiErrorData.Response__c =res.getBody().subString(0,131071);
                }else{
                    apiErrorData.Response__c =res.getBody();
                }
                listAPIErrors.add(apiErrorData);
                database.insert(listAPIErrors);
                
            }
        }Catch(Exception ex){
            throw ex;
        }
        system.debug('responseMessage'+responseMessage);
        return responseMessage;
    }
    
    public HttpResponseData callAPI(String accToken, String sJOSN){
        HttpResponseData httpData = new HttpResponseData();
        Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setBody(sJOSN);
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c);
            req.setMethod('POST');   
            httpData.requestBody = req.getBody();
            
            system.debug('Outbound req body:: '+req.getBody());

        try{
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('res***:: '+res);
            httpData.res = res;
            system.debug('res body***:: '+res.getBody());
            return httpData;
            
        }Catch(Exception ex){
                throw ex;
            }
    }
    
    public pageReference redirectToProduct(){
        PageReference pageRef = new PageReference('/'+productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public class HttpResponseData {
        HttpResponse res{get; set;}
        String requestBody{get; set;}
    }
    
    public class HostIntegrationDataResult 
    {
        public String amDlq{get; set;}
    }
    public class ResponseJSON
    {
        public boolean isSuccess{get; set;}
        public HostIntegrationDataResult data{get; set;}
        public String returnMessage{get; set;}
        public String code{get; set;}
        public Integer statusCode{get; set;}
        public String tag{get; set;}
    }
    public class ResponseErrorJSON
    {
        public boolean isSuccess{get; set;}
        public boolean data{get; set;}
        public String returnMessage{get; set;}
        public String code{get; set;}
        public Integer statusCode{get; set;}
        public String tag{get; set;}
    }
    public class Payload
    {
        public String acctId{get; set;}
    }
    
}