public class UpdateAmountPastDueController {
    public static String sJOSN;
    public String productID {get;set;}
    public static String responseMessage {get;set;}
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Fidem Portal API');
    public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();
    
    public UpdateAmountPastDueController(ApexPages.StandardController stdController) {
        system.debug('inside UpdateAmountPastDueController');
        productID =  ApexPages.currentPage().getParameters().get('id');
        updateAmountPastDue(productID);
        responseMessage = '';
    }
    
    public static void updateAmountPastDue(ID productId){
        updateAmountPastDueAPI(productId);
    }
   
    public static void updateAmountPastDueAPI(ID productId){
        system.debug('productId'+productId);
        list<Product__c> listProduct = [SELECT ID, Name
                                                       FROM Product__c 
                                                       WHERE ID= :productId];
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
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setBody(sJOSN);
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            //apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFInventoryEquipment');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c);
            req.setMethod('POST');         
            prodData.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());

            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res***:: '+res);
                system.debug('res body***:: '+res.getBody());
                prodData.Outbound_API_Response_Body__c = res.getBody();
                ResponceJSON responceJSONData = (ResponceJSON)JSON.deserializeUntyped(res.getBody());
                system.debug('Outbound res body::' +res.getBody());
                String statusCode = String.valueOf(res.getStatusCode());
                if(statusCode.startsWith('2')){
                    if(responceJSONData.isSuccess == true){
                        HostIntegrationDataResult dataResult = responceJSONData.data;
                     	prodData.Past_Due_Amount__c = Integer.valueOf(dataResult.amDlq);
                    }else{
                        responseMessage = responceJSONData.returnMessage;
                        //return responceJSONData.returnMessage;
                    }
                }       
                else{
                   //API error log
                    API_Error__c apiErrorData = New API_Error__c();
                    apiErrorData.Action__c = 'API Failed';
                    apiErrorData.Error__c = prodData.name;
                    if(req.getBody().length() > 131071){
                        apiErrorData.Request__c =req.getBody().subString(0,131071);
                    }else{
                        apiErrorData.Request__c =req.getBody();
                    }
                    if(res.getBody().length() > 131071){
                        apiErrorData.Response__c =res.getBody().subString(0,131071);
                    }else{
                        apiErrorData.Response__c =res.getBody();
                    }
                    listAPIErrors.add(apiErrorData);
                }
            }
            catch(Exception ex){
                //API error log
                API_Error__c apiErrorData = New API_Error__c();
                apiErrorData.Error__c = prodData.name +' '+'Record failed due to'+' '+ex.getMessage()+' '+ex.getStackTraceString();
                apiErrorData.Action__c = 'API Failed';
                if(!Test.isRunningTest()){
                    apiErrorData.Request__c = prodData.name;
                }
                
                listAPIErrors.add(apiErrorData);
                system.debug('exception ex: '+ex);
            }
            if(prodData != NULL){
                ProductTriggerHandler.runProductTrigger = false;
                update prodData;
                ProductTriggerHandler.runProductTrigger = true;
            }
        }
    }
    
    public pageReference redirectToProduct(){
        PageReference pageRef = new PageReference('/'+productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public class HostIntegrationDataResult 
    {
        public String amDlq;
    }
    public class ResponceJSON
    {
        public boolean isSuccess;
        public HostIntegrationDataResult data;
        public String returnMessage;
        public String code;
        public Integer statusCode;
        public String tag;
    }
    public class Payload
    {
        public String acctId;
    }
}