public class UpdateAmountPastDueController {
    public static String sJOSN;
    public String productID {get;set;}
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Fidem Portal API');
    
    public UpdateAmountPastDueController(ApexPages.StandardController stdController) {
        system.debug('inside UpdateAmountPastDueController');
        productID =  ApexPages.currentPage().getParameters().get('id');
        updateAmountPastDue(productID);
    }
    
    public static void updateAmountPastDue(ID productId){
        updateAmountPastDueAPI(productId);
    }
    @future (callout=true)
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
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+prodData.name);
            req.setMethod('PUT');         
            prodData.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
			
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                prodData.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body::' +res.getBody());
                //system.debug('Outbound res body::' +res.getStatusCode().startsWith('2'));
                String statusCode = String.valueOf(res.getStatusCode());
                if(statusCode.startsWith('2')
                && bodyMap.get('IsSuccess') == String.valueOf('true')){
                    system.debug(bodyMap.get('ReturnMessage'));
                     SuccessJSON successJSONData = new SuccessJSON();
                     successJSONData.isSuccess = true;
                     //successJSONData.HostIntegrationDataResult = true;
                }       
                else{
                    ErrorJSON errorJSONData = new ErrorJSON();
                    errorJSONData.isSuccess = false;
                    errorJSONData.returnMessage = 'Error Response';
                    errorJSONData.statusCode = res.getStatusCode();
                    system.debug('Error Response');
                    system.debug(bodyMap.get('ReturnMessage'));
                }
            }
            catch(Exception ex){
                system.debug('exception ex: '+ex);
            }
            if(prodData != NULL){
                ProductTriggerHandler.runProductTrigger = false;
                update prodData;
                ProductTriggerHandler.runProductTrigger = true;
            }
        }
    }
    public class HostIntegrationDataResult 
    {
        public String amDlq;
    }
    
    public class SuccessJSON
    {
        public boolean isSuccess;
        public HostIntegrationDataResult data;
    }
    public class ErrorJSON
    {
        public boolean isSuccess;
        public String returnMessage;
        public Integer statusCode;
    }
    public class Payload
    {
        public String acctId;
    }
}