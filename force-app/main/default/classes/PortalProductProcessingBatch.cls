global class PortalProductProcessingBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful{
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    String queryStr;
    List<Id> productIdSet;
    global PortalProductProcessingBatch(List<Id> prodIds) {
          System.debug('>>>>docIds>>>>'+prodIds);
	productIdSet = prodIds;
       queryStr = 'SELECT ID,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Account_Purchasing_Entity_Value__c,Legal_Entity_Name__c,Employer_Name__c,Current_Fees__c,  ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Product'){
                //system.debug('fieldMappingInstance.Field_API__c: '+fieldMappingInstance.Field_API__c);
                queryStr += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
        queryStr = queryStr.removeEnd(', ');
        queryStr+= ' FROM Product__c WHERE ID IN: productIdSet';
    }
    global database.QueryLocator start(Database.BatchableContext BC) { 
         return database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Product__c> listProduct) {
        API_Call_Details__c apiCallDetails1 = API_Call_Details__c.getInstance('Agency Portal API');
        String productJSONRequest;
        //String pdfURL = apiCallDetails1.PDF_API_URL__c.replace('Document', 'SFProduct');
        for(Product__c productInstance : listProduct ){
                //Create JSON request for customer update
                //productInstance = listProduct[0];
                String escapeString = '';
                /*String prodStatus = '';
                if(String.isNotBlank(productInstance.Product_Status__c)){
                    escapeString = productInstance.Product_Status__c;
                    prodStatus = escapeString.replaceAll('-','');
                }*/
            String s2;
            s2 =  String.valueOf(productInstance.collection_agency__c).substringBefore('.');
            productInstance.collection_agency__c = Decimal.valueOf(s2);
                system.debug('productInstance '+productInstance.collection_agency__c);
                
                List<Product_Extension__c> listProductExtensions = [SELECT ID,Name,Account_ID__c,Address_Line1__c,Address_Line2__c,City__c,
                                                                    Country__c,Dealer__c, Description__c,Equipment_Description__c,Equipment_Location__c,
                                                                    Equipment_Returned_Date__c,Equipment_S_N__c,Equipment_Value__c,
                                                                    Province__c,Repossession_Date__c,Value__c,Zip_Code__c
                                                                    FROM Product_Extension__c
                                                                    WHERE Account_ID__c = :productInstance.Id limit 1];
                productJSONRequest = '{'+
                    '"Name": "'+productInstance.Name+'",'+
                    '"Legal_Decision_By": "'+productInstance.Legal_Decision_by__r.Name+'",'+
                    '"Pool_Name": "'+productInstance.Pool_Name__r.Pool_ID__c+'",'+
                	'"Created_By": "'+productInstance.Created_By__c+'",'+
                	'"Allocated_Amount_Total": "'+productInstance.Allocated_Amount_Total__c+'",'+
                    '"Account_Purchasing_Entity_Value": "'+productInstance.Account_Purchasing_Entity_Value__c+'",'+
                    '"Legal_Entity_Value": "'+productInstance.Legal_Entity_Name__c+'",'+
                    '"Company_Name": "'+productInstance.Employer_Name__c+'",'+
                    '"Customer_Identifier": "'+productInstance.Customer_Identifier__c+'",'+
                    '"Current_Fees": "'+productInstance.Current_Fees__c+'",';
                
                for(Agency_Portal_Fields_Mapping__c mapping : fieldMapping){
                    if(mapping.Object_Name__c == 'Product'){
                        if(mapping.Field_Type__c != 'DateTime'){
                            productJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                                productInstance.get(mapping.Field_API__c)+'\", ';    
                        }
                        else{
                            if(mapping.Field_Type__c == 'DateTime' && productInstance.get(mapping.Field_API__c) != NULL){
                                DateTime ss = DateTime.valueOf(productInstance.get(mapping.Field_API__c));
                                
                                String convertedDateTime = ss.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
                                system.debug('convertedDateTime::'+mapping.Field_JSON_Tag__c+convertedDateTime);
                                productJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                                    convertedDateTime+'\", ';  
                                
                            }        
                        }
                        //system.debug('mapping.Field_JSON_Tag__c: '+mapping.Field_API__c+productInstance.get(mapping.Field_API__c));
                    }
                    
                }
                //productJSONRequest += '"Product_Status": "'+prodStatus+'",';
                
                if(!listProductExtensions.isEmpty()){
                    // productJSONRequest += '"Name": "'+listProductExtensions[0].Name+'",';
                    productJSONRequest += '"Extension_Description": "'+listProductExtensions[0].Description__c+'",';
                    productJSONRequest += '"Collateral_Address_Line1": "'+listProductExtensions[0].Address_Line1__c+'",';
                    productJSONRequest += '"Collateral_Address_Line2": "'+listProductExtensions[0].Address_Line2__c+'",';
                    productJSONRequest += '"Collateral_City": "'+listProductExtensions[0].City__c+'",';
                    productJSONRequest += '"Account_ID": "'+listProductExtensions[0].Account_ID__c+'",';
                    productJSONRequest += '"Collateral_Country": "'+listProductExtensions[0].Country__c+'",';
                    productJSONRequest += '"Dealer": "'+listProductExtensions[0].Dealer__c+'",';
                    productJSONRequest += '"Equipment_Description": "'+listProductExtensions[0].Equipment_Description__c+'",';
                    productJSONRequest += '"Equipment_Location": "'+listProductExtensions[0].Equipment_Location__c+'",';
                    productJSONRequest += '"Equipment_Returned_Date": "'+listProductExtensions[0].Equipment_Returned_Date__c+'",';
                    productJSONRequest += '"Equipment_S_N": "'+listProductExtensions[0].Equipment_S_N__c+'",';
                    productJSONRequest += '"Equipment_Value": "'+listProductExtensions[0].Equipment_Value__c+'",';
                    productJSONRequest += '"Province": "'+listProductExtensions[0].Province__c+'",';
                    productJSONRequest += '"Repossession_Date": "'+listProductExtensions[0].Repossession_Date__c+'",';
                    productJSONRequest += '"Value": "'+listProductExtensions[0].Value__c+'",';
                    productJSONRequest += '"Collateral_Zip_Code": "'+listProductExtensions[0].Zip_Code__c+'"';
                }
                productJSONRequest = productJSONRequest.removeEnd(', ');
                productJSONRequest += '}';
                
                system.debug('productJSONRequest: '+productJSONRequest);
                
                //Get access token for http request
                String accTokenBulk;
            accTokenBulk = getRequestToken();
                if (accTokenBulk != '') {
                    // Instantiate a new http object
                    Http h = new Http();
                    // Instantiate a new HTTP request
                    HttpRequest req = new HttpRequest();
                    system.debug('productJSONRequest: '+productJSONRequest);
                    req.setBody(productJSONRequest);
                    system.debug('req body'+req.getBody());
                    req.setHeader('Authorization', 'Bearer ' + accTokenBulk);
                    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFProduct');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c+productInstance.Name);
                    req.setMethod('PUT');
                    system.debug('req endpoint:: '+req.getEndpoint());
                    system.debug('req body:: '+req.getBody());
                    productInstance.Outbound_API_Request_Body__c = req.getBody();
                    system.debug('Outbound req body:: '+req.getBody());
                    system.debug('req:: '+req);
                    
                    
                    try{
                        // Send the request, and return a response
                        HttpResponse res = h.send(req);
                        system.debug('res.getBody(): '+res.getBody());
                        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        productInstance.Outbound_API_Response_Body__c = res.getBody();
                        system.debug('Outbound res body::' +res.getBody());
                        if(res.getStatusCode() == 200
                           && bodyMap.get('IsSuccess') == String.valueOf('true')){
                               system.debug(bodyMap.get('ReturnMessage'));
                           }       
                        else{
                            system.debug('Error Response');
                            system.debug(bodyMap.get('ReturnMessage'));
                        }
                    }
                    catch(Exception ex){
                        system.debug('exception ex: '+ex);
                        productInstance.Outbound_API_Response_Body__c = String.valueOf(ex);
                    }
                    
                    /*if(productInstance != NULL){
                        ProductTriggerHandler.runProductTrigger = false;
                        update productInstance;
                        ProductTriggerHandler.runProductTrigger = true;
                    }*/
                }
            }
        		ProductTriggerHandler.runProductTrigger = false;
                update listProduct;
        		system.debug('listProduct::'+listProduct);
                ProductTriggerHandler.runProductTrigger = true;
        }
    
    global void finish(Database.BatchableContext BC){
        
    }
     //Get Access Token
    public static string getRequestToken() {
        system.debug('apiCallDetails: '+apiCallDetails);
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
        
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        system.debug('authorizationtUrl changed: '+authorizationtUrl);
        String bodyParams =  'client_id='+dpapiClientClientId;
        bodyParams =  bodyParams+'&client_secret='+dpapiClientSecret;
        bodyParams =  bodyParams+'&scope='+apiCallDetails.Scope_Prefix__c+dpapiProxyClientId+apiCallDetails.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        
        system.debug('bodyParams: '+bodyParams);        
        system.debug('authorizationtUrl: '+authorizationtUrl);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        
        system.debug('req: '+req);
        HttpResponse hresp = h.send(req);
        system.debug('hresp: '+hresp);
        system.debug('hresp.getBody(): '+hresp.getBody());
        Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        system.debug('wResp: '+wResp.get('access_token'));
        return String.valueOf(wResp.get('access_token'));
    }
}