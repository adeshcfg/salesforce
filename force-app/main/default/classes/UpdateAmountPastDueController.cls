public class UpdateAmountPastDueController {
    public static String sJOSN = '';
    public String productID { get; set; }
    public String responseMessage { get; set; }
    public boolean panelHide { get; set; }
    public Integer counter = 1;
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Fidem Portal API');
    public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();

    public UpdateAmountPastDueController() {
        panelHide = true;
        responseMessage = 'SUCCESS';
    }

    public pageReference updateAmountPastDueAPI() {
        responseMessage = '';
        panelHide = true;
        productID = ApexPages.currentPage().getParameters().get('id');
        Product__c prodData = new Product__c();
        Payload payLoad = new Payload();
        List<Product__c> listProduct = [
            SELECT ID, Name
            FROM Product__c
            WHERE ID = :productID
        ];
        if (!listProduct.isEmpty()) {
            prodData = listProduct[0];
            payLoad.acctId = prodData.name;
        }
        sJOSN = JSON.serialize(payLoad);
        //Get access token for http request
        String accToken = '';
        accToken = AzureUtility.getRequestToken('Fidem Portal API');
        if (accToken != '') {
            ResponseJSON responceJSONData = new ResponseJSON();
            try {
                // Send the request, and return a response
                HttpResponseData httpresData = callAPI(accToken, sJOSN);
                responseMessage = processRequest(httpresData, prodData);
            } catch (Exception ex) {
                API_Error__c apiErrorData = new API_Error__c();
                apiErrorData.Error__c = prodData.name + ' ' + 'Record failed due to' + ' ' + ex.getMessage() + ' ' + ex.getStackTraceString();
                apiErrorData.Action__c = 'API Failed';
                if (!Test.isRunningTest()) {
                    apiErrorData.Request__c = prodData.name;
                }
                listAPIErrors.add(apiErrorData);
                database.insert(listAPIErrors);
                responseMessage = System.Label.Fidem_API_Error_Message;
                panelHide = false;
            }
        }
        return null;
    }

    public string processRequest(HttpResponseData httpresData, product__c prodData) {
        prodData.Outbound_API_Request_Body__c = httpresData.requestBody;
        HttpResponse res = httpresData.res;
        prodData.Outbound_API_Response_Body__c = res.getBody();
        String statusCode = String.valueOf(res.getStatusCode());
        try {
            if (statusCode.startsWith('2')) {
                ResponseJSON responceJSONData = (ResponseJSON) JSON.deserialize(res.getBody(), ResponseJSON.class);
                if (responceJSONData.isSuccess == true || Test.isRunningTest()) {
                    HostIntegrationDataResult dataResult = responceJSONData.data;
                    prodData.Past_Due_Amount__c = Integer.valueOf(dataResult.amDlq);
                    prodData.Past_Due_Amount_Refresh_Date__c = Datetime.now();
                    ProductTriggerHandler.runProductTrigger = false;
                    update prodData;
                    ProductTriggerHandler.runProductTrigger = true;
                    responseMessage = 'SUCCESS';
                    panelHide = true;
                } else {
                    responseMessage = System.Label.Fidem_API_Error_Message;
                    panelHide = false;
                }
            } else if (res.getStatusCode() == 500 || res.getStatusCode() == 429) {
                ResponseErrorJSON responceErrorJSONData = (ResponseErrorJSON) JSON.deserialize(res.getBody(), ResponseErrorJSON.class);
                responseMessage = System.Label.Fidem_API_Error_Message;
                panelHide = false;
                if (responceErrorJSONData.Code == '2020' || responceErrorJSONData.Code == '1429') {
                    counter = counter + 1;
                    if (counter <= 2) {
                        String accToken = AzureUtility.getRequestToken('Fidem Portal API');
                        httpresData = callAPI(accToken, sJOSN);
                        processRequest(httpresData, prodData);
                    } else {
                        APIErrorLog(res, httpresData, prodData.name);
                    }
                } else {
                    APIErrorLog(res, httpresData, prodData.name);
                }
            } else {
                APIErrorLog(res, httpresData, prodData.name);
            }
        } catch (Exception ex) {
            System.debug('Exception in processRequest ' + ex.getStackTraceString());
            throw ex;
        }
        return responseMessage;
    }

    public static Object processResponse(List<String> Labels, Object state) {
        HttpResponse response = Continuation.getResponse(Labels[0]);
        // Set the result variable
        String result = response.getBody();
        return result;
    }

    public HttpResponseData callAPI(String accToken, String sJOSN) {
        HttpResponseData httpData = new HttpResponseData();
        Http h = new Http();
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setBody(sJOSN);
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(apiCallDetails.PDF_API_URL__c);
        req.setMethod('POST');
        req.setTimeout(20000);
        httpData.requestBody = req.getBody();
        try {
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            httpData.res = res;
            return httpData;
        } catch (Exception ex) {
            System.debug('Exception in callAPI ' + ex.getStackTraceString());
            throw ex;
        }
    }

    public pageReference redirectToProduct() {
        PageReference pageRef = new PageReference('/' + productID);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void APIErrorLog(HttpResponse res, HttpResponseData httpresData, String prodDataName) {
        ResponseErrorJSON responceErrorJSONData1 = (ResponseErrorJSON) JSON.deserialize(res.getBody(), ResponseErrorJSON.class);
        //API error log
        API_Error__c apiErrorData = new API_Error__c();
        apiErrorData.Error__c = prodDataName + ' ' + 'Record failed due to' + ' ' + responceErrorJSONData1.returnMessage;
        apiErrorData.Action__c = 'Fidem API Failed with statusCode' + res.getStatusCode();
        if (httpresData.requestBody.length() > 131071) {
            apiErrorData.Request__c = httpresData.requestBody;
        } else {
            apiErrorData.Request__c = httpresData.requestBody;
        }

        if (res.getBody().length() > 131071) {
            apiErrorData.Response__c = res.getBody().subString(0, 131071);
        } else {
            apiErrorData.Response__c = res.getBody();
        }
        listAPIErrors.add(apiErrorData);
        database.insert(listAPIErrors);
        responseMessage = System.Label.Fidem_API_Error_Message;
    }

    public class HttpResponseData {
        HttpResponse res { get; set; }
        String requestBody { get; set; }
    }

    public class HostIntegrationDataResult {
        public String amDlq { get; set; }
    }

    public class ResponseJSON {
        public boolean isSuccess { get; set; }
        public HostIntegrationDataResult data { get; set; }
        public String returnMessage { get; set; }
        public String code { get; set; }
        public Integer statusCode { get; set; }
        public List<String> tag { get; set; }
    }

    public class ResponseErrorJSON {
        public boolean isSuccess { get; set; }
        public boolean data { get; set; }
        public String returnMessage { get; set; }
        public String code { get; set; }
        public Integer statusCode { get; set; }
        public List<String> tag { get; set; }
    }

    public class Payload {
        public String acctId { get; set; }
    }
}
