/**
 * @description       : Class for CTB File creation callouts
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-08-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
@RestResource(urlMapping='/CTBFileUploadWebService/*')
global with sharing class CTBFileUploadWebService {
    @HttpPost
    global static String handleCTBFileTransmission() {
        switch on RestContext.request.requestURI.substringAfterLast('/') {
            when 'SFUpload' {
                System.debug('SFUpload API called');
            }
            when 'FTPUpload' {
                System.debug('FTPUpload API called');
            }
        }
        Map<String, Object> stringMap = new Map<String, Object>();
        stringMap.put('success', true);
        PortalDocumentStorageProcessor.createResponse(JSON.serialize(stringMap, true), 200);
        return JSON.serialize(stringMap, true);
    }
}
