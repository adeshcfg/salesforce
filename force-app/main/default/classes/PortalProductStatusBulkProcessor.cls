/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process Productbulk record(consume API)
*  @author : A5E Consulting
*  @date : 14/03/2022

*************************************************************************************************/
@RestResource(urlMapping='/PortalBulkProductStatusProcessing/*')
global class PortalProductStatusBulkProcessor {
    @HttpPost
    global static string postAssignment() {
        //Store Response
        RestRequest req = RestContext.request;
        Map<String, Object> mapJSONResponse = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        Map<String, String> mapParameters = new Map<String, String>();
        map<String, String> mapHeaders = req.headers;

        //iterate through they keys, to store string values
        for (String paramKey : mapJSONResponse.keySet()) {
            mapParameters.put(paramKey, String.valueOf(mapJSONResponse.get(paramKey)));
        }
        String statusResponse = '';
        statusResponse = PortalProductStatusBulkProcessingUtil.processBulkProducts(req.requestBody.toString());

        Map<String, Object> stringMap = new Map<String, Object>();
        if (statusResponse == 'success') {
            stringMap.put('success', true);
            createResponse(JSON.serialize(stringMap, true), 200);
        } else {
            stringMap.put('errors', true);
            stringMap.put('reason', statusResponse);
            createResponse(JSON.serialize(stringMap, true), 500);
        }
        return JSON.serialize(stringMap, true);
    }

    public static void createResponse(String responseBody, Integer statusCode) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        RestContext.response.addHeader('Content-Type', 'application/json');
    }
}
