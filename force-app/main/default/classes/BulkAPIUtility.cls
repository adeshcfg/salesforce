public class BulkAPIUtility {
    
    @InvocableMethod(label='Upload CSV' description='Upload the CSV data in system using Bulk API 2.0')
    public static List<ResponseWrapper> importBulkdata(List<BulkDataWrapper> dataWrapperList) {
        User usr = [Select Id,Name From User where Id =: Userinfo.getUserId()];
        String lineEditing = 'LF';
        /*if(usr.System_Type__c == 'MAC') {
            lineEditing = 'LF';
        }*/
        
        ResponseWrapper rw = new ResponseWrapper();
        if(dataWrapperList.size() == 0) {
            rw.response =  'Please send correct data.';
        }
        
        String objectName = dataWrapperList[0].objectName;
        String operation = dataWrapperList[0].operation;
        String contentDocumentId = dataWrapperList[0].fileIdList;
        
        //ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId ];
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest');
        request.setHeader('content-type', 'application/json' );
        request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
        system.debug('userInfo.getSessionId::'+userInfo.getSessionId());
        String body = '{ '+
            //'"externalIdFieldName": "Id",'+  
            '"lineEnding": "'+lineEditing+'",'+
            '"operation": "'+operation+'",'+
            '"object": "'+objectName+'",'+
            '"contentType": "CSV"'+
            '}';
        
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        
        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id');
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
            request1.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId+'/batches');
            request1.setHeader('content-type', 'text/csv' );
            request1.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());  
           // request1.setBody(cv.VersionData.toString());
           String bodyData = dataWrapperList[0].data.toString();
            system.debug('bodyData::'+bodyData);
            system.debug('jobId::'+jobId);
           request1.setBodyAsBlob(dataWrapperList[0].data);
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
             system.debug('getStatusCode::'+resp1.getStatusCode());
            if(resp1.getStatusCode() <= 299) {
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
                request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId);
                request2.setHeader('content-type', 'application/json' );
                request2.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
                
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
                Delete [SELECT ID FROM contentDocument WHERE ID =: contentDocumentId];
                system.debug('resp2 getStatusCode::'+resp2.getStatusCode());
                if(resp2.getStatusCode() <= 299) {
                    system.debug('inside getStatusCode::');
                    rw.response = 'Data processing Start '+jobId;
                    rw.jobId = jobId;
                    
                } else {
                    system.debug('ERROR Loop::');
                    rw.response = 'There was an error. Please contact your admin.';
                }
            }
        }
        return new List<ResponseWrapper>{rw};
    }
    
    public class BulkDataWrapper {
        @InvocableVariable(label='File Ids' description='File Ids' required=true)
        public Id fileIdList;
        @InvocableVariable(label='Object Name' description='Object Name' required=true)
        public String objectName;
        @InvocableVariable(label='Operation' description='operation' required=true)
        public String operation;
        public Blob data;
        
    }
    
    public class ResponseWrapper {
        @InvocableVariable(label='Response' description='Response' required=true)
        public String response;
        public String jobId;
    }
    public static List<ResponseWrapper> loadDataUsingBulkAPI(Blob data, String fileId, String sObjectName) {
        BulkDataWrapper b = new BulkDataWrapper();
        b.fileIdList = fileId;
        b.objectName = sObjectName;
        b.operation = 'insert';
        b.data = data;
        return importBulkdata(new List<BulkDataWrapper>{b});
    }
    
   /* public static void getSuccessfullJobResult(String jobId, String documentStorageId) {
        system.debug('---Limit Heap Size---'+Limits.getLimitHeapSize());
        Set<String> productList = new Set<String>();
        Set<String> poolNameList = new Set<String>();
        HttpRequest request2 = new HttpRequest();
        request2.setMethod('GET');
        request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId+'/successfulResults');
        request2.setHeader('content-type', 'text/csv' );
        request2.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        HttpResponse resp = new http().send(request2);
        if(resp.getStatusCode() == 200) {
            String csvAsString = resp.getBody();
            String[] csvFileLines = csvAsString.split('\n');
            for(Integer i=1; i < csvFileLines.size(); i++) {
                String[] csvRecordData = csvFileLines[i].split(',');
                system.debug('--+--'+csvRecordData[2]);
                String productName = csvRecordData[2].removeEnd('"');
                String poolName = csvRecordData[4].removeEnd('"');
                productList.add(productName.removeStart('"'));
                poolNameList.add(poolName.removeStart('"'));
            }
            //return productList;
        }
        //CFG_ProcessBulkAPIResult.prepareFileProcessingLink(documentStorageId, productList, poolNameList);
        system.debug('---After Use Heap Size---'+Limits.getHeapSize());
        //return productList;
    }*/
}