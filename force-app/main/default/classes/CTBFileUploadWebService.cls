/**
 * @description       : Class for CTB File creation callouts
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-06-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
@RestResource(urlMapping='/CTBFileUploadWebService/*')
global with sharing class CTBFileUploadWebService {
    @HttpPost
    global static String postCTBFile() {
        Map<String, Object> stringMap = new Map<String, Object>();
        stringMap.put('success', true);
        PortalDocumentStorageProcessor.createResponse(JSON.serialize(stringMap, true), 200);
        return JSON.serialize(stringMap, true);
    }
}
