/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class is integration layer for the Document upload and access functionality
 *  @author : A5E Consulting
 *  @date : 07/12/2021
 *
 *************************************************************************************************/
public with sharing class DocumentAPIClient {
    //public static string BANK_SCRAPE = 'Bank Scrape';
    public static string contentType;

    //This submit method is for call to Agency Portal API Post method
    public static DocumentAPIClientUtil.ParsedResponse postDocument(Blob attachmentBody, String attachmentName, String SObjectName) {
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();

        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docStorageAPI = [
            SELECT
                AuthorizationtUrl__c,
                Client_ID__c,
                Client_Secret__c,
                Proxy_Client_ID__c,
                PDF_API_URL__c,
                Tenand_ID__c,
                Scope_Prefix__c,
                Scope_Suffix__c,
                API_Request_Timeout__c
            FROM API_Call_Details__c
            WHERE Name = 'Agency Portal API'
        ];

        String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl = docStorageAPI.AuthorizationtUrl__c;
        String apiURL = docStorageAPI.PDF_API_URL__c;
        //append object name
        //apiURL = apiURL +SObjectName;

        String encodedString = EncodingUtil.urlEncode(attachmentName, 'UTF-8');
        attachmentName = encodedString;
        //attachmentName = attachmentName.replaceAll(' ', '%20%');
        apiURL = apiURL + SObjectName + '?name=' + attachmentName;
        system.debug('urllll: ' + apiURL);
        //apiURL = apiURL +'Customer HTTP/1.1';
        /*if(azureDoc.Document_Type__c == 'Bank Statement'){
            apiURL = apiURL.replace('Revardo', 'bnkstmt');
        }else if(azureDoc.Document_Type__c == 'Bank Scrape'){
            apiURL = apiURL.replace('Revardo', 'flinks');
        }*/

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        //bodyParams =  bodyParams+'&scope='+docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        HTTPResponse res = http.send(req);
        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');

        //TEST CODE
        //String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';

        //create http request
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiURL);
        documentApiReq.setMethod('POST');
        documentApiReq.setHeader('Content-Type', 'application/octet-stream');
        //documentApiReq.setHeader('Content-Type', 'multipart/form-data');
        //documentApiReq.setHeader('Content-Type', 'multipart/form-data; boundary='+boundary);
        //req.setHeader('x-ms-blob-type', 'BlockBlob');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        //documentApiReq.setBody(boundary);
        documentApiReq.setBodyAsBlob(attachmentBody);
        //documentApiReq.setBody(boundary);
        //documentApiReq.setBody('hello string');
        //system.debug('documentApiReq :'+documentApiReq.getBody());
        //system.debug('string body: '+ String.valueOf(documentApiReq.getBody()));
        //Add Custom Setting
        documentApiReq.setTimeout(Integer.valueOf(docStorageAPI.API_Request_Timeout__c));
        HTTPResponse res2 = new HttpResponse();
        system.debug('Request : ' + documentApiReq);
        res2 = http.send(documentApiReq);

        //Store request and response
        parsedResponse.request = documentApiReq.getBody();
        parsedResponse.response = res2.getBody();
        system.debug('res: ' + res2);
        system.debug('res status code ' + res2.getStatusCode());
        system.debug('res body ' + res2.getBody());

        //check if webservice reply is success
        if (res2.getStatusCode() == 200) {
            //get response
            parsedResponse = parseResponse(res2.getBody(), parsedResponse);
            system.debug('parsedResponse in docapiclient: ' + parsedResponse);
        } else {
        }

        return parsedResponse;
    }

    public static DocumentAPIClientUtil.ParsedResponse postDocument2(String documentid, String attachmentName, String SObjectName) {
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();

        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docStorageAPI = [
            SELECT
                AuthorizationtUrl__c,
                Client_ID__c,
                Client_Secret__c,
                Proxy_Client_ID__c,
                PDF_API_URL__c,
                Tenand_ID__c,
                Scope_Prefix__c,
                Scope_Suffix__c,
                API_Request_Timeout__c
            FROM API_Call_Details__c
            WHERE Name = 'Agency Portal API'
        ];

        String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl = docStorageAPI.AuthorizationtUrl__c;
        String apiURL = docStorageAPI.PDF_API_URL__c;
        //append object name
        //apiURL = apiURL +SObjectName;

        String encodedString = EncodingUtil.urlEncode(attachmentName, 'UTF-8');
        attachmentName = encodedString;
        //attachmentName = attachmentName.replaceAll(' ', '%20%');
        // apiURL = apiURL +SObjectName + '?name='+attachmentName;//PR Rajesh >>comment when testing done
        // string ss = EncodingUtil.Base64Encode(attachmentBody);//For test Rajesh>> un comment when testing done
        apiURL = apiURL + 'sobjects/' + documentid + '/' + SObjectName + '?name=' + attachmentName; //For test Rajesh >>un comment when testing done
        system.debug('urllll@@@@@@: ' + apiURL);
        //apiURL = apiURL +'Customer HTTP/1.1';

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        //bodyParams =  bodyParams+'&scope='+docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        HTTPResponse res = http.send(req);
        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');

        //create http request
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiURL);
        documentApiReq.setMethod('POST');
        documentApiReq.setHeader('Content-Type', 'application/json');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        documentApiReq.setBody('');
        documentApiReq.setTimeout(Integer.valueOf(docStorageAPI.API_Request_Timeout__c));
        HTTPResponse res2 = new HttpResponse();
        system.debug('Request : ' + documentApiReq);
        res2 = http.send(documentApiReq);

        //Store request and response
        parsedResponse.request = documentApiReq.getBody();
        parsedResponse.response = res2.getBody();
        system.debug('res: ' + res2);
        system.debug('res status code ' + res2.getStatusCode());
        system.debug('res body ' + res2.getBody());

        //check if webservice reply is success
        if (res2.getStatusCode() == 200) {
            //get response
            parsedResponse = parseResponse(res2.getBody(), parsedResponse);
            system.debug('parsedResponse in docapiclient: ' + parsedResponse);
        } else {
        }

        return parsedResponse;
    }

    //parse response method
    public static DocumentAPIClientUtil.ParsedResponse parseResponse(String response, DocumentAPIClientUtil.ParsedResponse parsedResponse) {
        DocumentAPIClientUtil.WebServiceResponseJSONObject webServiceResponseValue = new DocumentAPIClientUtil.WebServiceResponseJSONObject();
        webServiceResponseValue = webServiceResponseValue.parse(response);
        system.debug('webServiceResponseValue: ' + webServiceResponseValue);
        if (null != webServiceResponseValue.id) {
            parsedResponse.docId = webServiceResponseValue.id;
            parsedResponse.docId = webServiceResponseValue.docId;
            parsedResponse.docUrl = webServiceResponseValue.docUrl;
        }

        return parsedResponse;
    }

    // Update file type with actual content type once after inserting the file
    /*@future(callout=true)
    public static void updateContentType(List<Id> azureDocIds){
        List<Document_Storage__c> azureDocsToUpdate = new List<Document_Storage__c>();
        for(Document_Storage__c azureDoc: [SELECT Id, Content_Type__c, Document_Id__c 
                                           FROM Document_Storage__c  
                                           WHERE Id IN: azureDocIds]){
            getDocument(azureDoc.Document_ID__c);
            System.debug('Old contentType'+azureDoc.Content_Type__c);
            System.debug('New contentType'+contentType);
            if(!contentType.equalsIgnoreCase(azureDoc.Content_Type__c)){
                azureDoc.Content_Type__c = contentType;
                azureDocsToUpdate.add(azureDoc);
            }
        }
        if(!azureDocsToUpdate.isEmpty()){  
            update azureDocsToUpdate;
        }
    }*/

    //This submit method is for call to Agency Portal API GET method (called from PreviewPdfController)
    public static Blob getDocument(String documentID) {
        System.debug('documentID ' + documentID);
        Document_Storage__c azureDoc = [
            SELECT Document_Type__c, Document_ID__c, Document_URL__c
            FROM Document_Storage__c
            WHERE Document_ID__c = :documentID
        ];
        system.debug('azureDoc::' + azureDoc); // Bank Scrape
        Blob document = null;

        if (documentId.length() == 18) {
            system.debug('Blockrun documentID');
            return [SELECT VersionData FROM ContentVersion WHERE Id = :documentID LIMIT 1].VersionData;
        }

        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docStorageAPI = [
            SELECT
                AuthorizationtUrl__c,
                Client_ID__c,
                Client_Secret__c,
                Proxy_Client_ID__c,
                PDF_API_URL__c,
                Tenand_ID__c,
                Scope_Prefix__c,
                Scope_Suffix__c,
                API_Request_Timeout__c
            FROM API_Call_Details__c
            WHERE Name = 'Agency Portal API'
        ];

        /*String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl =  docStorageAPI.AuthorizationtUrl__c;
        //API URL should be in format:https://{Domain}/api/Document/DocumentURL
        //String apiURL =  docStorageAPI.PDF_API_URL__c+azureDoc.Document_Extension__c+'/';
        //String apiURL =  docStorageAPI.PDF_API_URL__c + azureDoc.Document_URL__c;
        String apiURL =  docStorageAPI.PDF_API_URL__c + 'account@f9a60f4f-2ca5-4ddb-afbc-c9326346beb8_pdf';
        system.debug('apiURL in get info: '+apiURL);
        
        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams =  'client_id='+clientId;
        bodyParams =  bodyParams+'&client_secret='+clientSecret;
        bodyParams =  bodyParams+'&scope='+'api://'+apiID+'/.default';
        //bodyParams =  bodyParams+'&scope='+docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        system.debug('bodyParams in getDocument:::'+bodyParams);
        String accessToken;*/

        String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl = docStorageAPI.AuthorizationtUrl__c;
        //API URL should be in format:https://{Domain}/api/Document/docx/DocumentID
        // String apiURL =  docStorageAPI.PDF_API_URL__c+azureDoc.Document_URL__c; >> Rajesh    documentID
        String apiURL = docStorageAPI.PDF_API_URL__c + azureDoc.Document_URL__c;

        //String apiURL =  docStorageAPI.PDF_API_URL__c + 'account@f9a60f4f-2ca5-4ddb-afbc-c9326346beb8_pdf';
        system.debug('apiURL in getinfo :' + apiURL);

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        //bodyParams =  bodyParams+'&scope='+'api://'+apiID+'/.default';
        //bodyParams =  bodyParams+'&scope='+docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';
        system.debug('bodyParams in getDocumentInfo:::' + bodyParams);
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        system.debug('bodyParams ' + bodyParams);
        system.debug('length ' + String.valueOf(bodyParams.length()));
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        system.debug('req ' + req);
        //HTTPResponse res;
        //if(!test.isRunningTest()){
        HTTPResponse res = http.send(req);

        //}
        system.debug('res.getBody ' + res.getBody());
        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');
        System.debug('accessToken::' + accessToken);
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiURL); //634a7c38-8174-4612-940c-eadd694808bf

        documentApiReq.setMethod('GET');
        documentApiReq.setHeader('Content-Type', 'application/octet-stream');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);

        documentApiReq.setTimeout(Integer.valueOf(docStorageAPI.API_Request_Timeout__c));
        HTTPResponse res2 = new HttpResponse();

        try {
            res2 = http.send(documentApiReq);
            string[] headerkeys = res2.getHeaderKeys();
            System.debug('Content-Type:::' + headerkeys);
            //Store request and response
            system.debug('res ' + res2.getStatusCode());
            //system.debug('res '+res2.getBody());
        } catch (Exception e) {
            // exception generated
        }

        //check if webservice reply is success
        if (res2.getStatusCode() == 201 || res2.getStatusCode() == 200) {
            //get response
            contentType = res2.getHeader('Content-Type');

            if (contentType == 'application/pdf') {
                system.debug('block run');
                document = res2.getBodyAsBlob();
            } else if (contentType == 'application/json') {
                document = Blob.toPdf(res2.getBody());
            } else if (contentType == 'application/octet-stream') {
                try {
                    document = res2.getBodyAsBlob();
                } catch (Exception ex) {
                    document = Blob.toPdf(res2.getBody());
                }
            } else if (contentType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                document = res2.getBodyAsBlob();
            } else {
                try {
                    document = res2.getBodyAsBlob();
                } catch (Exception ex) {
                    document = Blob.toPdf(res2.getBody());
                }
            }
        } else {
            //failed to vote
        }
        return document;
    }

    //This submit method is for call to Agency Portal API GET method (called from FileUploadToAzureController)
    public static DocumentDetails getDocumentInfo(String documentID) {
        System.debug('documentID: ' + documentID);
        DocumentDetails docDetails = new DocumentDetails();
        Document_Storage__c azureDoc = [
            SELECT Document_Type__c, Document_ID__c, Document_URL__c
            FROM Document_Storage__c
            WHERE Document_ID__c = :documentID
            LIMIT 1
        ];
        // Bank Scrape
        Blob document = null;

        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docStorageAPI = [
            SELECT
                AuthorizationtUrl__c,
                Client_ID__c,
                Client_Secret__c,
                Proxy_Client_ID__c,
                PDF_API_URL__c,
                Tenand_ID__c,
                Scope_Suffix__c,
                Scope_Prefix__c,
                API_Request_Timeout__c
            FROM API_Call_Details__c
            WHERE Name = 'Agency Portal API'
        ];

        String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl = docStorageAPI.AuthorizationtUrl__c;
        //API URL should be in format:https://{Domain}/api/Document/docx/DocumentID
        String apiURL = docStorageAPI.PDF_API_URL__c + azureDoc.Document_URL__c;
        //String apiURL =  docStorageAPI.PDF_API_URL__c + 'account@f9a60f4f-2ca5-4ddb-afbc-c9326346beb8_pdf';
        system.debug('apiURL in getinfo :' + apiURL);

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        //bodyParams =  bodyParams+'&scope='+'api://'+apiID+'/.default';
        //bodyParams =  bodyParams+'&scope='+docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';
        system.debug('bodyParams in getDocumentInfo:::' + bodyParams);
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        system.debug('bodyParams ' + bodyParams);
        system.debug('length ' + String.valueOf(bodyParams.length()));
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        system.debug('req ' + req);
        HTTPResponse res;
        //if(!test.isRunningTest()){
        res = http.send(req);
        //}
        // system.debug('res.getBody '+res.getBody());
        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');
        System.debug('accessToken::' + accessToken);
        // Send JSON to Voting Automation engine
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiURL); //634a7c38-8174-4612-940c-eadd694808bf

        documentApiReq.setMethod('GET');
        // ! - uncomment below two lines
        documentApiReq.setHeader('Content-Type', 'application/octet-stream');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        documentApiReq.setTimeout(Integer.valueOf(docStorageAPI.API_Request_Timeout__c));
        HTTPResponse res2 = new HttpResponse();
        system.debug('Request2::: : ' + documentApiReq);
        system.debug('res22::: : ' + res2);
        //if(!test.isRunningTest()){
        res2 = http.send(documentApiReq);
        // }
        string[] headerkeys = res2.getHeaderKeys();
        System.debug('Content-Type:::' + headerkeys);
        //Store request and response
        system.debug('res status code22:: ' + res2.getStatusCode());

        //check if webservice reply is success
        if (res2.getStatusCode() == 201 || res2.getStatusCode() == 200) {
            //get response
            System.debug('Content-Type:::' + res2.getHeader('Content-Type'));
            contentType = res2.getHeader('Content-Type');
            docDetails.contentType = contentType;
            if (contentType == 'application/pdf') {
                document = res2.getBodyAsBlob();
            } else if (contentType == 'application/json') {
                document = Blob.toPdf(res2.getBody());
            } else if (contentType == 'application/octet-stream') {
                try {
                    document = res2.getBodyAsBlob();
                } catch (Exception ex) {
                    document = Blob.toPdf(res2.getBody());
                }

                //document = Blob.toPdf(res2.getBody());
            } else if (contentType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                document = res2.getBodyAsBlob();
            } else {
                try {
                    document = res2.getBodyAsBlob();
                } catch (Exception ex) {
                    document = Blob.toPdf(res2.getBody());
                }
            }
            docDetails.document = document;
            //system.debug('Name:'+docDetails.Title);
        } else {
            //failed to vote
        }

        return docDetails;
    }

    //This submit method is for call to Agency Portal API GET method (called from documentstoragetrigger)
    public static String getDocumentJSON(String documentURL) {
        System.debug('documentURL: ' + documentURL);
        system.debug('GET DOCUMENT JSON API CALL');
        DocumentDetails docDetails = new DocumentDetails();

        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docStorageAPI = [
            SELECT
                AuthorizationtUrl__c,
                Client_ID__c,
                Client_Secret__c,
                Proxy_Client_ID__c,
                PDF_API_URL__c,
                Tenand_ID__c,
                Scope_Suffix__c,
                Scope_Prefix__c,
                API_Request_Timeout__c
            FROM API_Call_Details__c
            WHERE Name = 'Agency Portal API'
        ];

        String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl = docStorageAPI.AuthorizationtUrl__c;
        //API URL should be in format:https://{Domain}/api/Document/docx/DocumentID
        String apiURL = docStorageAPI.PDF_API_URL__c + documentURL;
        system.debug('apiURL in getJSON :' + apiURL);

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';
        system.debug('bodyParams in getDocumentInfo:::' + bodyParams);
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        HTTPResponse res = http.send(req);

        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');
        System.debug('accessToken in getJSON::' + accessToken);

        // Send JSON to Voting Automation engine
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiURL); //634a7c38-8174-4612-940c-eadd694808bf
        documentApiReq.setMethod('GET');
        documentApiReq.setHeader('Accept', 'application/json');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        HTTPResponse res2 = new HttpResponse();
        res2 = http.send(documentApiReq);
        system.debug('GetJSON Response::' + res2.getBody());
        system.debug('getJSON status code:: ' + res2.getStatusCode());
        String document;
        document = res2.getBody();
        system.debug('JSON RESPONSE document : ' + document);
        //check if webservice reply is success
        if (res2.getStatusCode() == 200) {
            //get response
            System.debug('Content-Type:::' + res2.getHeader('Content-Type'));
            contentType = res2.getHeader('Content-Type');
            docDetails.contentType = contentType;
            if (contentType == 'application/json') {
                document = res2.getBody();
            }
        } else {
            //failed to vote
        }

        return document;
    }
    //Added by Rajesh 4134
    public static string createDocumentFromAzure(String folderId, String name) {
        DocumentAPIClientUtil.ReverseProxyAPI parsedResponse = new DocumentAPIClientUtil.ReverseProxyAPI();
        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docStorageAPI = [
            SELECT
                AuthorizationtUrl__c,
                Client_ID__c,
                Client_Secret__c,
                Proxy_Client_ID__c,
                PDF_API_URL__c,
                Tenand_ID__c,
                Scope_Prefix__c,
                Scope_Suffix__c,
                API_Request_Timeout__c
            FROM API_Call_Details__c
            WHERE Name = 'Agency Portal API'
        ];

        String tenandId = docStorageAPI.Tenand_ID__c;
        String apiID = docStorageAPI.Proxy_Client_ID__c;
        String clientId = docStorageAPI.Client_ID__c;
        String clientSecret = docStorageAPI.Client_Secret__c;
        String authorizationtUrl = docStorageAPI.AuthorizationtUrl__c;
        String apiURL = docStorageAPI.PDF_API_URL__c;

        // String encodedString = EncodingUtil.urlEncode(attachmentName,'UTF-8');
        //   attachmentName = encodedString;
        List<String> docUrlSplitted = name.split('@', 2);
        apiURL = apiURL + 'sobjects/folders/' + folderId + '?name=' + docUrlSplitted[0] + '@' + EncodingUtil.urlEncode(docUrlSplitted[1], 'UTF-8');
        system.debug('urllll@@@@@@: ' + apiURL);

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + docStorageAPI.Scope_Prefix__c + apiID + docStorageAPI.Scope_Suffix__c;
        bodyParams = bodyParams + '&grant_type=client_credentials';
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        HTTPResponse res = http.send(req);
        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');

        //create http request
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiURL);
        documentApiReq.setMethod('POST');
        documentApiReq.setHeader('Content-Type', 'application/json');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        documentApiReq.setBody('');
        documentApiReq.setTimeout(Integer.valueOf(docStorageAPI.API_Request_Timeout__c));
        HTTPResponse res2 = new HttpResponse();
        system.debug('Request : ' + documentApiReq);
        res2 = http.send(documentApiReq);

        //Store request and response
        parsedResponse.request = documentApiReq.getBody();
        parsedResponse.response = res2.getBody();
        system.debug('res: ' + res2);
        system.debug('res status code ' + res2.getStatusCode());
        system.debug('res body ' + res2.getBody());

        //check if webservice reply is success
        if (res2.getStatusCode() == 200) {
            //get response
            // parsedResponse = parseResponse(res2.getBody(), parsedResponse);
            parsedResponse = (DocumentAPIClientUtil.ReverseProxyAPI) System.JSON.deserialize(
                parsedResponse.response,
                DocumentAPIClientUtil.ReverseProxyAPI.class
            );
            system.debug('parsedResponse in docapiclient: ' + parsedResponse);
        } else {
        }

        return parsedResponse.data.id;
    }
}
