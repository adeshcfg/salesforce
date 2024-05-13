/**************************************************************************************************
*
* Class: AzureUtility
*
* @description : get access token and call the allocation and account status update API based on document type.  
* @author : A5E Consulting
* @date : 10/03/2023
* Test Class: TestDisplayProductAllocStagController,TestPortalJudgmentProcessingAPI,TestUpdateAmountPastDueController

*************************************************************************************************/
public class AzureUtility {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public static String accTokenBulk;
    public static List<String> allocate = new List<String>{ 'Product Allocation File', 'Product Allocation Individual' };
    public static List<String> recall = new List<String>{ 'Account Status Update File', 'Account Status Update Pool' };
    public static List<API_Error__c> ErrorList = new List<API_Error__c>();

    //Call allocation/account status update API based in document type.
    public static String apiCall(List<String> listProductJSONRequest1, string docType) {
        accTokenBulk = getRequestToken();
        List<Product__c> prodList = new List<Product__c>();
        if (docType == 'Product Allocation Individual' || docType == 'Account Status Update Pool') {
            List<Object> productJsonList = (List<Object>) JSON.deserializeUntyped(listProductJSONRequest1[0]);
            Map<String, Object> jsonMap = (Map<String, Object>) productJsonList[0];
            String productName = String.valueOf(jsonMap.get('Name'));
            prodList = [SELECT Id, Collection_Agency_Placement__c FROM Product__c WHERE Name = :productName];
        }
        for (String ProductJSONRequest : listProductJSONRequest1) {
            //Get access token for http request
            if (accTokenBulk != '') {
                // Instantiate a new http object
                Http h = new Http();
                // Instantiate a new HTTP request
                HttpRequest req = new HttpRequest();
                req.setBody(ProductJSONRequest);
                req.setHeader('Authorization', 'Bearer ' + accTokenBulk);
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                if (allocate.contains(docType)) {
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFProduct');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c + 'bulk');
                    req.setMethod('PUT');
                } else if (recall.contains(docType)) {
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFBulkProductUpdate');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c + 'bulk');
                    req.setMethod('PATCH');
                }

                try {
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if (res.getStatusCode() == 200 && !Test.isRunningTest()) {
                        if (docType == 'Product Allocation Individual') {
                            ProductAllocationIndividualController.getSnapshortRecords(prodList);
                        } else if (docType == 'Account Status Update Pool') {
                            AgencyPoolAllocationController.getSnapshortRecords(prodList);
                        }
                    } else {
                        try {
                            API_Error__c apiError = new API_Error__c();
                            apiError.End_Point__c = 'Bulk API';
                            if (req.getBody().length() > 131071) {
                                apiError.Request__c = req.getBody().subString(0, 131071);
                            } else {
                                apiError.Request__c = req.getBody();
                            }
                            if (res.getBody().length() > 131071) {
                                apiError.Response__c = res.getBody().subString(0, 131071);
                            } else {
                                apiError.Response__c = res.getBody();
                            }

                            ErrorList.add(apiError);
                        } catch (Exception ex) {
                            system.debug('exception ex: ' + ex);
                        }
                    }
                } catch (Exception ex) {
                    system.debug('exception ex: ' + ex);
                }
            }
        }
        if (!ErrorList.isEmpty()) {
            insert ErrorList;
        }

        return null;
    }

    //Get Access Token
    public static string getRequestToken() {
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl = apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi = apiCallDetails.PDF_API_URL__c;

        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        String bodyParams = 'client_id=' + dpapiClientClientId;
        bodyParams = bodyParams + '&client_secret=' + dpapiClientSecret;
        bodyParams = bodyParams + '&scope=' + apiCallDetails.Scope_Prefix__c + dpapiProxyClientId + apiCallDetails.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);

        HttpResponse hresp;
        if (!test.isRunningTest()) {
            hresp = h.send(req);
            Map<String, Object> wResp = (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
            return String.valueOf(wResp.get('access_token'));
        } else {
            return null;
        }
    }

    public static string getRequestToken(API_Call_Details__c apiCallDetails) {
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl = apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi = apiCallDetails.PDF_API_URL__c;

        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        String bodyParams = 'client_id=' + dpapiClientClientId;
        bodyParams = bodyParams + '&client_secret=' + dpapiClientSecret;
        bodyParams = bodyParams + '&scope=' + apiCallDetails.Scope_Prefix__c + dpapiProxyClientId + apiCallDetails.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);

        HttpResponse hresp;
        hresp = h.send(req);
        Map<String, Object> wResp = (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        return String.valueOf(wResp.get('access_token'));
    }

    public static string getRequestToken(string apiName) {
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance(apiName);

        return getRequestToken(apiCallDetails);
    }

    public static String apiCallToPortal(
        string apiName,
        List<String> JSONRequestList,
        string replacePdfApiUrl,
        List<sobject> objectInstance,
        string portalApiCall
    ) {
        Judgment__c judInstanceData;
        String name = '';
        String endPoint = '';
        if (portalApiCall == 'Judgment') {
            for (Judgment__c judInstance : (List<Judgment__c>) objectInstance) {
                name = judInstance.name;
                endPoint = judInstance.Judgment_Number__c;
                judInstance.Outbound_API_Request_Body__c = JSONRequestList[0];
                judInstanceData = judInstance;
            }
        }
        String accToken = getRequestToken(apiName);
        // Instantiate a new http object
        for (String JSONRequest : JSONRequestList) {
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setBody(JSONRequest);
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', replacePdfApiUrl);
            req.setEndpoint(apiCallDetails.PDF_API_URL__c + endPoint);
            req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
            req.setMethod('PUT');

            try {
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (portalApiCall == 'Judgment') {
                    judInstanceData.Outbound_API_Response_Body__c = res.getBody();
                }

                String statusCode = String.valueOf(res.getStatusCode());
                if (statusCode.startsWith('2') && bodyMap.get('IsSuccess') == String.valueOf('true')) {
                } else if (!statusCode.startsWith('2')) {
                    String userName = UserInfo.getName();
                    API_Error__c apiErrorData = new API_Error__c();
                    apiErrorData.Action__c = 'API Failed';
                    apiErrorData.Request__c = name;
                    if (res.getBody().length() > 131071) {
                        apiErrorData.Response__c = res.getBody().subString(0, 131071);
                    } else {
                        apiErrorData.Response__c = res.getBody();
                    }
                    ErrorList.add(apiErrorData);

                    CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName, apiErrorData.Response__c, apiErrorData.Action__c);
                }
            } catch (Exception ex) {
                String userName = UserInfo.getName();
                API_Error__c apiErrorData = new API_Error__c();
                apiErrorData.Error__c = ex.getMessage();
                apiErrorData.Action__c = 'API Failed';
                if (!Test.isRunningTest()) {
                    apiErrorData.Request__c = name;
                }
                ErrorList.add(apiErrorData);

                CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName, apiErrorData.Error__c, apiErrorData.Action__c);
            }

            insert ErrorList;
            if (judInstanceData != null) {
                JudgmentTriggerHandler.runJudgmentTrigger = false;
                update judInstanceData;
                JudgmentTriggerHandler.runJudgmentTrigger = true;
            }
        }
        return null;
    }
}
