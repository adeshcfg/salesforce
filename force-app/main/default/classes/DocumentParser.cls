/**************************************************************************************************
 *
 *  Trigger:    DocumentParser
 *
 *  @description : Sends pdf content to Document parser to fetch JSON and update Parsed Response Holder Object
 *  @author : A5E Consulting
 *  @date : 04/28/2020
 
 *************************************************************************************************/
public with sharing class DocumentParser {
    public virtual class BaseException extends Exception {
    }
    public class OtherException extends BaseException {
    }
    public static List<Case> caseListToUpdate = new List<Case>();

    // Replace special words, words with spaces in json response to align with attribute names defines in DocumentResponseParser class
    public static Map<String, String> replaceAttributesMap = new Map<string, String>{
        '"Bankrupt"' => '"Debtor"',
        '"Débiteur"' => '"Debtor"',
        '"Failli"' => '"Debtor"',
        '"Faillie"' => '"Debtor"',
        '"Débitrice"' => '"Debtor"',
        '"Failli(e)"' => '"Debtor"',
        '"Debtors"' => '"Debtor"',
        '"Débiteurs"' => '"Debtor"',
        '"Faillis"' => '"Debtor"',
        '"Failli ou débiteur"' => '"Debtor"',
        '"Other"' => '"Others"',
        '"Autres membres del’unité familiale"' => '"Others"',
        '"Other members of the family unit"' => '"Others"',
        '"Other Members of the family unit"' => '"Others"',
        '"Other Members ofthe family unit"' => '"Others"',
        '"Autres membres de l’unité familiale"' => '"Others"',
        '"Autres membres   de l’unité familiale"' => '"Others"',
        '"Autres membres de  l’unité familiale"' => '"Others"',
        '"Bankrupt Other Members ofthefamily unit"' => '"Others"',
        '"Bankrupt Other Members of the family unit"' => '"Others"',
        '"Other Members Total  of the family unit"' => '"Others"',
        '"Autres membres de                    l’unité familiale"' => '"Others"',
        '"Autres membres de                                                                                        l’unité familiale"' => '"Others"',
        '"Bankrupt  Other Members     of the family unit"' => '"Others"',
        '"Autres membres de                                                                                              l’unité familiale"' => '"Others"',
        '"Other members of  the family unit"' => '"Others"',
        '"Autres membres de\r\nl’unité familiale"' => '"Others"',
        '"Conjoint(e)"' => '"Spouse"',
        '"paymentsExpenses"' => '"payments"',
        '"MONTHLY INCOME"' => '"MontlhyIncomeIgnore"'
    };

    // Replace special words in json response to align with attribute names defines in DocumentResponseParser class
    public static Map<String, String> replaceBadAttributesMap = new Map<string, String>{ '"Failli(e)"' => '"Debtor"', '"Conjoint(e)"' => '"Spouse"' };

    //Method sends pdf Blob to Document parser and stores response JSON under Parsed Response Holder Object
    @future(callout=true)
    //public static void sendDoc(List<ID> listID){
    public static void sendDoc(Map<ID, ID> mapID) {
        //
        List<ID> listID = new List<ID>();
        listID.addAll(mapID.keySet());

        //Declaration and Intialize variables
        List<Attachment> attach = new List<Attachment>();
        List<EmailMessage> emailMsg = new List<EmailMessage>();
        API_Call_Details__c docParseApi = [
            SELECT AuthorizationtUrl__c, Client_ID__c, Client_Secret__c, Proxy_Client_ID__c, Tenand_ID__c, PDF_API_URL__c
            FROM API_Call_Details__c
            WHERE Name = 'Document Parser API'
        ];

        String dptenandId = docParseApi.Tenand_ID__c;
        String dpapiProxyClientId = docParseApi.Proxy_Client_ID__c;
        String dpapiClientClientId = docParseApi.Client_ID__c;
        String dpapiClientSecret = docParseApi.Client_Secret__c;
        String authorizationtUrl = docParseApi.AuthorizationtUrl__c;
        String parsePDFApi = docParseApi.PDF_API_URL__c;

        authorizationtUrl = authorizationtUrl.replace('{{dptenandId}}', dptenandId);
        String bodyParams = 'client_id=' + dpapiClientClientId;
        bodyParams = bodyParams + '&client_secret=' + dpapiClientSecret;
        bodyParams = bodyParams + '&scope=' + 'api://' + dpapiProxyClientId + '/.default';
        bodyParams = bodyParams + '&grant_type=client_credentials';
        String accessToken;
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, Document_ID__c, Status FROM CASE WHERE Id IN :listID]);
        for (ID strId : listID) {
            attach = [SELECT id, name, body FROM Attachment WHERE ID = :mapID.get(strID)];
            Case assignment = caseMap.get(strId);
            if (!attach.isEmpty()) {
                Blob blobBody = attach[0].Body;
                HTTPResponse res2;
                Parsed_Response_Holder__c parsedResponse = new Parsed_Response_Holder__c();

                // Get access token by authenticating using key parameters
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody(bodyParams);
                req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
                req.setEndpoint(authorizationtUrl);

                try {
                    HTTPResponse res = http.send(req);
                    Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    accessToken = (String) resJson.get('access_token');

                    // Send document content to document parser API
                    HttpRequest docParseApiReq = new HttpRequest();
                    docParseApiReq.setEndpoint(parsePDFApi);
                    docParseApiReq.setMethod('POST');
                    docParseApiReq.setHeader('Content-Type', 'application/octet-stream');
                    docParseApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
                    docParseApiReq.setBodyAsBlob(blobBody);
                    docParseApiReq.setTimeout(90000);
                    res2 = http.send(docParseApiReq);

                    parsedResponse.assignment__c = strId; //to link assignment to parsed response
                    // Insert Parsed Response Holder record with JSON
                    if (res2.getStatusCode() == 200) {
                        parsedResponse.Status__c = 'Pending';
                        parsedResponse.Parsed_Response__c = res2.getBody();
                        if (res2.getBody() == null || res2.getBody() == 'null' || res2.getBody().trim() == '' || res2.getBody().trim() == '{}') {
                            updateParsedResponse(parsedResponse, res2, 'Received no response from Document Parser');
                            assignment.status = 'Manually Process';
                        } else {
                            parsedResponse.Parsed_Response_Formatted__c = formatJson(res2.getBody());
                        }
                    } else if (res2.getStatusCode() == 400 || res2.getStatusCode() == 500) {
                        Map<String, Object> errorResponse = (Map<String, Object>) JSON.deserializeUntyped(res2.getBody());
                        String errorMessage = String.valueOf(errorResponse.get('title')) + ' - ' + String.valueOf(errorResponse.get('detail'));
                        if (errorResponse.containsKey('report')) {
                            errorMessage += ' - ' + String.valueOf(errorResponse.get('report'));
                        }
                        updateParsedResponse(parsedResponse, res2, errorMessage);
                        assignment.status = 'System Error';
                    }
                } catch (Exception e) {
                    updateParsedResponse(parsedResponse, res2, 'Exception in communication with Document Parser');
                    assignment.status = 'System Error';
                }
                insert parsedResponse;

                if (assignment.status <> 'System Error') {
                    CaseComment addCom = new CaseComment();
                    addCom.CommentBody = attach[0].name + ' has been processed';
                    addCom.ParentID = assignment.id;
                    insert addCom;
                }

                parsedResponse = [SELECT id, name, Status__c FROM Parsed_Response_Holder__c WHERE id = :parsedResponse.id];
                assignment.Document_ID__c = parsedResponse.Name;

                //fetch updated assignment
                Case updatedAssignment = [SELECT id, status FROM case WHERE id = :assignment.id];
                if (assignment.status == 'In Progress') {
                    assignment.status = updatedAssignment.status;
                }
                caseListToUpdate.add(assignment);
            }
        }
        if (!caseListToUpdate.isEmpty()) {
            CaseTriggerHandler.runCaseTrigger = false;
            update caseListToUpdate;
            CaseTriggerHandler.runCaseTrigger = true;
        }
    }

    // Update Parser response with error details
    public static void updateParsedResponse(Parsed_Response_Holder__c parsedResponse, HttpResponse res, String errorDetails) {
        parsedResponse.Status__c = 'Error';
        if (res != null && res.getBody() != null) {
            parsedResponse.Parsed_Response__c = res.getBody();
        }
        parsedResponse.Error_Details__c = errorDetails;
    }

    // Removing \n \r from JSON
    public static string formatJson(String parseJson) {
        // Remove unecessary delimiters from json string
        parseJson = parseJson.replaceAll('\\r', '');
        parseJson = parseJson.replaceAll('\\n', ' ');
        parseJson = parseJson.replaceAll('\r', '');
        parseJson = parseJson.replaceAll('\n', ' ');

        //remove white spaces
        parseJson = parseJson.replaceAll('\\s+', ' ');

        // Above moethod doesnt work some times, so writing below index specific code if still special characters are exist to replace
        Integer index;
        while (parseJson.indexOf('\\r') != -1) {
            index = parseJson.indexOf('\\r');
            parseJson = parseJson.left(index) + parseJson.right(parseJson.length() - index - 2);
        }
        while (parseJson.indexOf('\\n') != -1) {
            index = parseJson.indexOf('\\n');
            parseJson = parseJson.left(index) + parseJson.right(parseJson.length() - index - 2);
        }

        // replace special words
        for (String badString : replaceAttributesMap.keySet()) {
            parseJson = parseJson.replaceAll(badString, replaceAttributesMap.get(badString));
        }
        parseJson = replaceSpecialString(parseJson);
        return parseJson;
    }

    // Method replaces words that cannot be replaced by replaceAll method
    public static string replaceSpecialString(String parseJson) {
        Integer index; // catch index of words where it starts in the JSON
        for (String badString : replaceBadAttributesMap.keySet()) {
            while (parseJson.indexOf(badString) != -1) {
                index = parseJson.indexOf(badString);
                parseJson =
                    parseJson.left(index) +
                    '' +
                    replaceAttributesMap.get(badString) +
                    '' +
                    parseJson.right(parseJson.length() - index - (badString.length()));
            }
        }
        return parseJson;
    }
}
