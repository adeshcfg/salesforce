/**************************************************************************************************
*
*  Class:   
*  @description : This is a webservice class(provide) to create/update Product Record from 
*                 Salesforce to Portal DB
*  @author : A5E Consulting
*  @date : 17/01/2022

*************************************************************************************************/
public class PortalProductProcessingAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    public static String accTokenBulk;
    
    @future (callout=true)
    public static void processProduct(ID productId){
        system.debug('Product API call');
        String Query = 'SELECT ID,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Seller__r.Name,Employer_Name__c,Current_Fees__c,Portfolio_Name_Lookup__r.Purchase_ID__c,  ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Product'){
                //system.debug('fieldMappingInstance.Field_API__c: '+fieldMappingInstance.Field_API__c);
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
        Query = Query.removeEnd(', ');
        system.debug('Query after:'+Query);
        Query+= ' FROM Product__c WHERE ID=: productId';
        system.debug('Query: '+Query);
        list<Product__c> listProduct = Database.query(Query);
        system.debug('listProduct: '+listProduct);
        
        String productJSONRequest;
        Product__c productInstance ;
        if(!listProduct.isEmpty()){
            //Create JSON request for customer update
            productInstance = listProduct[0];
            String escapeString = '';
            /*String prodStatus = '';
            if(String.isNotBlank(productInstance.Product_Status__c)){
                escapeString = productInstance.Product_Status__c;
                prodStatus = escapeString.replaceAll('-','');
            }*/
            
            system.debug('productInstance '+productInstance);
            
            List<Product_Extension__c> listProductExtensions = [SELECT ID,Name,Account_ID__c,Address_Line1__c,Address_Line2__c,City__c,
                                                                Country__c,Dealer__c, Description__c,Equipment_Description__c,Equipment_Location__c,
                                                                Equipment_Returned_Date__c,Equipment_S_N__c,Equipment_Value__c,
                                                                Province__c,Repossession_Date__c,Value__c,Zip_Code__c,Model__c,Identification__c,
                                                                Security_Registration_Number__c,Security_Registration_Date__c,Security_Registration_Expiry_Date__c,
                                                                Repossession_Proceeds__c
                                                                FROM Product_Extension__c
                                                                WHERE Account_ID__c = :productId];
            productJSONRequest = '{'+
                '"Name": "'+productInstance.Name+'",'+
                '"Legal_Decision_By": "'+productInstance.Legal_Decision_by__r.Name+'",'+
                '"Account_Portfolio_ID": "'+productInstance.Portfolio_Name_Lookup__r.Purchase_ID__c+'",'+
            	'"Pool_Name": "'+productInstance.Pool_Name__r.Pool_ID__c+'",'+
            	'"Created_By": "'+productInstance.Created_By__c+'",'+
                '"Allocated_Amount_Total": "'+productInstance.Allocated_Amount_Total__c+'",'+
            	//'"Account_Purchasing_Entity_Value": "'+productInstance.Account_Purchasing_Entity_Value__c+'",'+
                //'"Legal_Entity_Value": "'+productInstance.Legal_Entity_Name__c+'",'+
                '"Company_Name": "'+productInstance.Employer_Name__c+'",'+
                '"Customer_Identifier": "'+productInstance.Customer_Identifier__c+'",'+
                '"Seller": "'+productInstance.Seller__r.Name+'",'+
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
            system.debug('listProductExtensions**'+listProductExtensions);
            /*
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
                productJSONRequest += '"Collateral_Zip_Code": "'+listProductExtensions[0].Zip_Code__c+'",';
                productJSONRequest += '"Model": "'+listProductExtensions[0].Model__c+'",';
                productJSONRequest += '"Identification": "'+listProductExtensions[0].Identification__c+'",';
                productJSONRequest += '"Security_Registration_Number": "'+listProductExtensions[0].Security_Registration_Number__c+'",';
                productJSONRequest += '"Security_Registration_Date": "'+listProductExtensions[0].Security_Registration_Date__c+'",';
                productJSONRequest += '"Security_Registration_Expiry_Date": "'+listProductExtensions[0].Security_Registration_Expiry_Date__c+'",';
                productJSONRequest += '"Repossession_Proceeds": "'+listProductExtensions[0].Repossession_Proceeds__c+'"';
            }*/
            productJSONRequest = productJSONRequest.removeEnd(', ');
            productJSONRequest += '}';
        }
        system.debug('productJSONRequest: '+productJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('productJSONRequest: '+productJSONRequest);
            req.setBody(productJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
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
            }
            
            if(productInstance != NULL){
                ProductTriggerHandler.runProductTrigger = false;
                update productInstance;
                ProductTriggerHandler.runProductTrigger = true;
            }
        }
    }
    
    public static void processProductBulkBatch(List<ID> productId){    
        Id batchJobId = Database.executeBatch(new PortalProductProcessingAPIBatch(productId), 40);
    }
    @future (callout=true)
    public static void processProductBulk(List<ID> productId){
        accTokenBulk = getRequestToken();
        String Query = 'SELECT ID,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Employer_Name__c,Current_Fees__c,Portfolio_Name_Lookup__r.Purchase_ID__c, ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Product'){
                //system.debug('fieldMappingInstance.Field_API__c: '+fieldMappingInstance.Field_API__c);
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
        }
        Query = Query.removeEnd(', ');
        Query+= ' FROM Product__c WHERE ID IN: productId';
        list<Product__c> listProduct = Database.query(Query);        
        String productJSONRequest;
        //Product__c productInstance ;
        if(!listProduct.isEmpty()){
            // Production Issue - Limited for loop to 100 records to avoid 101 callout limit
            Integer listProductSize = listProduct.size() > 100 ? 100 : listProduct.size();
            for(Integer i = 0; i < listProductSize ; i++){
                Product__c productInstance = listProduct[i];
                //Create JSON request for customer update
                //productInstance = listProduct[0];
                String escapeString = '';
                /*String prodStatus = '';
                if(String.isNotBlank(productInstance.Product_Status__c)){
                    escapeString = productInstance.Product_Status__c;
                    prodStatus = escapeString.replaceAll('-','');
                }*/
                List<Product_Extension__c> listProductExtensions = [SELECT ID,Name,Account_ID__c,Address_Line1__c,Address_Line2__c,City__c,
                                                                    Country__c,Dealer__c, Description__c,Equipment_Description__c,Equipment_Location__c,
                                                                    Equipment_Returned_Date__c,Equipment_S_N__c,Equipment_Value__c,
                                                                    Province__c,Repossession_Date__c,Value__c,Zip_Code__c
                                                                    FROM Product_Extension__c
                                                                    WHERE Account_ID__c = :productInstance.Id limit 1];
                productJSONRequest = '{'+
                    '"Name": "'+productInstance.Name+'",'+
                    '"Legal_Decision_By": "'+productInstance.Legal_Decision_by__r.Name+'",'+
                    '"Account_Portfolio_ID": "'+productInstance.Portfolio_Name_Lookup__r.Purchase_ID__c+'",'+
                    '"Pool_Name": "'+productInstance.Pool_Name__r.Pool_ID__c+'",'+
                	'"Created_By": "'+productInstance.Created_By__c+'",'+
                	'"Allocated_Amount_Total": "'+productInstance.Allocated_Amount_Total__c+'",'+
                    //'"Account_Purchasing_Entity_Value": "'+productInstance.Account_Purchasing_Entity_Value__c+'",'+
                    //'"Legal_Entity_Value": "'+productInstance.Legal_Entity_Name__c+'",'+
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
                
                //Get access token for http request
                if (accTokenBulk != '') {
                    // Instantiate a new http object
                    Http h = new Http();
                    // Instantiate a new HTTP request
                    HttpRequest req = new HttpRequest();
                    req.setBody(productJSONRequest);
                    req.setHeader('Authorization', 'Bearer ' + accTokenBulk);
                    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFProduct');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c+productInstance.Name);
                    req.setMethod('PUT');
                    productInstance.Outbound_API_Request_Body__c = req.getBody();                    
                    try{
                        // Send the request, and return a response
                        HttpResponse res = h.send(req);
                        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        productInstance.Outbound_API_Response_Body__c = res.getBody();
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
                    }
                    
                    if(productInstance != NULL){
                        ProductTriggerHandler.runProductTrigger = false;
                        //update productInstance;
                        ProductTriggerHandler.runProductTrigger = true;
                    }
                }
            }
        }
        
    }

    public static List<product__c> processProductBulkBatchone(Set<Id> setProductIds) {
        accTokenBulk = getRequestToken();
        List<Product__c> listProduct = new List<Product__c>();
        List<Product__c> listProductupdate = new List<Product__c>();
        Map<String, Product_Extension__c> mapProductIdProdExtension = new Map<String, Product_Extension__c>();
        String productJSONRequest;
        if (!setProductIds.isEmpty()) {
            for (Product_Extension__c prodExtension : [
                SELECT
                    ID,
                    Name,
                    Account_ID__c,
                    Address_Line1__c,
                    Address_Line2__c,
                    City__c,
                    Country__c,
                    Dealer__c,
                    Description__c,
                    Equipment_Description__c,
                    Equipment_Location__c,
                    Equipment_Returned_Date__c,
                    Equipment_S_N__c,
                    Equipment_Value__c,
                    Province__c,
                    Repossession_Date__c,
                    Value__c,
                    Zip_Code__c
                FROM Product_Extension__c
                WHERE Account_ID__c IN :setProductIds
            ]) {
                mapProductIdProdExtension.put(prodExtension.Account_ID__c, prodExtension);
            }
            String query = 'SELECT ID,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Employer_Name__c,Current_Fees__c,Portfolio_Name_Lookup__r.Purchase_ID__c, ';
            for (Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping) {
                if (fieldMappingInstance.Object_Name__c == 'Product') {
                    query += fieldMappingInstance.Field_API__c + ', ';
                }
            }
            query = query.removeEnd(', ');
            query += ' FROM Product__c WHERE ID IN: setProductIds';
            listProduct = Database.query(String.escapeSingleQuotes(query));
        }
        if (!listProduct.isEmpty()) {
            for (Product__c productInstance : listProduct) {
                String escapeString = '';
                productJSONRequest =
                    '{' +
                    '"Name": "' +
                    productInstance.Name +
                    '",' +
                    '"Legal_Decision_By": "' +
                    productInstance.Legal_Decision_by__r.Name +
                    '",' +
                    '"Account_Portfolio_ID": "' +
                    productInstance.Portfolio_Name_Lookup__r.Purchase_ID__c +
                    '",' +
                    '"Pool_Name": "' +
                    productInstance.Pool_Name__r.Pool_ID__c +
                    '",' +
                    '"Created_By": "' +
                    productInstance.Created_By__c +
                    '",' +
                    '"Allocated_Amount_Total": "' +
                    productInstance.Allocated_Amount_Total__c +
                    '",' +
                    '"Company_Name": "' +
                    productInstance.Employer_Name__c +
                    '",' +
                    '"Customer_Identifier": "' +
                    productInstance.Customer_Identifier__c +
                    '",' +
                    '"Current_Fees": "' +
                    productInstance.Current_Fees__c +
                    '",';

                for (Agency_Portal_Fields_Mapping__c mapping : fieldMapping) {
                    if (mapping.Object_Name__c == 'Product') {
                        if (mapping.Field_Type__c != 'DateTime') {
                            productJSONRequest += '\"' + mapping.Field_JSON_Tag__c + '\":"' + productInstance.get(mapping.Field_API__c) + '\", ';
                        } else {
                            if (mapping.Field_Type__c == 'DateTime' && productInstance.get(mapping.Field_API__c) != null) {
                                DateTime ss = DateTime.valueOf(productInstance.get(mapping.Field_API__c));
                                String convertedDateTime = ss.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                                productJSONRequest += '\"' + mapping.Field_JSON_Tag__c + '\":"' + convertedDateTime + '\", ';
                            }
                        }
                    }
                }
                if (mapProductIdProdExtension.containsKey(productInstance.Id)) {
                    productJSONRequest += '"Extension_Description": "' + mapProductIdProdExtension.get(productInstance.Id).Description__c + '",';
                    productJSONRequest += '"Collateral_Address_Line1": "' + mapProductIdProdExtension.get(productInstance.Id).Address_Line1__c + '",';
                    productJSONRequest += '"Collateral_Address_Line2": "' + mapProductIdProdExtension.get(productInstance.Id).Address_Line2__c + '",';
                    productJSONRequest += '"Collateral_City": "' + mapProductIdProdExtension.get(productInstance.Id).City__c + '",';
                    productJSONRequest += '"Account_ID": "' + mapProductIdProdExtension.get(productInstance.Id).Account_ID__c + '",';
                    productJSONRequest += '"Collateral_Country": "' + mapProductIdProdExtension.get(productInstance.Id).Country__c + '",';
                    productJSONRequest += '"Dealer": "' + mapProductIdProdExtension.get(productInstance.Id).Dealer__c + '",';
                    productJSONRequest += '"Equipment_Description": "' + mapProductIdProdExtension.get(productInstance.Id).Equipment_Description__c + '",';
                    productJSONRequest += '"Equipment_Location": "' + mapProductIdProdExtension.get(productInstance.Id).Equipment_Location__c + '",';
                    productJSONRequest += '"Equipment_Returned_Date": "' + mapProductIdProdExtension.get(productInstance.Id).Equipment_Returned_Date__c + '",';
                    productJSONRequest += '"Equipment_S_N": "' + mapProductIdProdExtension.get(productInstance.Id).Equipment_S_N__c + '",';
                    productJSONRequest += '"Equipment_Value": "' + mapProductIdProdExtension.get(productInstance.Id).Equipment_Value__c + '",';
                    productJSONRequest += '"Province": "' + mapProductIdProdExtension.get(productInstance.Id).Province__c + '",';
                    productJSONRequest += '"Repossession_Date": "' + mapProductIdProdExtension.get(productInstance.Id).Repossession_Date__c + '",';
                    productJSONRequest += '"Value": "' + mapProductIdProdExtension.get(productInstance.Id).Value__c + '",';
                    productJSONRequest += '"Collateral_Zip_Code": "' + mapProductIdProdExtension.get(productInstance.Id).Zip_Code__c + '"';
                }
                productJSONRequest = productJSONRequest.removeEnd(', ');
                productJSONRequest += '}';

                //Get access token for http request
                if (String.isNotBlank(accTokenBulk)) {
                    // Instantiate a new http object
                    Http h = new Http();
                    // Instantiate a new HTTP request
                    HttpRequest req = new HttpRequest();
                    req.setBody(productJSONRequest);
                    req.setHeader('Authorization', 'Bearer ' + accTokenBulk);
                    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFProduct');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c + productInstance.Name);
                    req.setMethod('PUT');
                    productInstance.Outbound_API_Request_Body__c = req.getBody();
                    try {
                        // Send the request, and return a response
                        HttpResponse res = h.send(req);
                        Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        productInstance.Outbound_API_Response_Body__c = res.getBody();
                        if (res.getStatusCode() == 200 && bodyMap.get('IsSuccess') == String.valueOf('true')) {
                            System.Debug(bodyMap.get('ReturnMessage'));
                        } else {
                            System.Debug('Error Response');
                            System.Debug(bodyMap.get('ReturnMessage'));
                        }
                    } catch (Exception ex) {
                        System.Debug('exception ex: ' + ex);
                    }
                    if (productInstance != null) {
                        listProductupdate.add(productInstance);
                    }
                }
            }
            return listProductupdate;
        }
        return null;
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
        HttpResponse hresp;
        if(!test.isRunningTest()){
         hresp = h.send(req);
        Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        system.debug('wResp: '+wResp.get('access_token'));
        return String.valueOf(wResp.get('access_token'));
        }else{
            return null;
        }
    }
    
    /*
    public static void processProductNonFutureContext (ID productId){
        system.debug('Product API call');
        String Query = 'SELECT ID,Legal_Decision_by__r.Name,Customer_Identifier__c,  ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Product'){
                //system.debug('fieldMappingInstance.Field_API__c: '+fieldMappingInstance.Field_API__c);
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
        Query = Query.removeEnd(', ');
        system.debug('Query after:'+Query);
        Query+= ' FROM Product__c WHERE ID=: productId';
        system.debug('Query: '+Query);
        list<Product__c> listProduct = Database.query(Query);
        system.debug('listProduct: '+listProduct);
        
        String productJSONRequest;
        Product__c productInstance ;
        if(!listProduct.isEmpty()){
            //Create JSON request for customer update
            productInstance = listProduct[0];
            String escapeString = '';
            String prodStatus = '';
            if(String.isNotBlank(productInstance.Product_Status__c)){
                escapeString = productInstance.Product_Status__c;
                prodStatus = escapeString.replaceAll('-','');
            }
            
            system.debug('productInstance '+productInstance);
            
            List<Product_Extension__c> listProductExtensions = [SELECT ID,Name,Account_ID__c,Address_Line1__c,Address_Line2__c,City__c,
                                                                Country__c,Dealer__c, Description__c,Equipment_Description__c,Equipment_Location__c,
                                                                Equipment_Returned_Date__c,Equipment_S_N__c,Equipment_Value__c,
                                                                Province__c,Repossession_Date__c,Value__c,Zip_Code__c
                                                                FROM Product_Extension__c
                                                                WHERE Account_ID__c = :productId];
            productJSONRequest = '{'+
                '"Name": "'+productInstance.Name+'",'+
                '"Legal_Decision_By": "'+productInstance.Legal_Decision_by__r.Name+'",';
            for(Agency_Portal_Fields_Mapping__c mapping : fieldMapping){
                if(mapping.Object_Name__c == 'Product'){
                    system.debug('mapping.Field_JSON_Tag__c: '+mapping.Field_API__c+productInstance.get(mapping.Field_API__c));
                    productJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                        productInstance.get(mapping.Field_API__c)+'\", ';
                }
            }
            productJSONRequest += '"Product_Status": "'+prodStatus+'",';
            
            if(!listProductExtensions.isEmpty()){
                // productJSONRequest += '"Name": "'+listProductExtensions[0].Name+'",';
                productJSONRequest += '"Extension_Description": "'+listProductExtensions[0].Description__c+'",';
                productJSONRequest += '"Address_Line1": "'+listProductExtensions[0].Address_Line1__c+'",';
                productJSONRequest += '"Address_Line2": "'+listProductExtensions[0].Address_Line2__c+'",';
                productJSONRequest += '"City": "'+listProductExtensions[0].City__c+'",';
                productJSONRequest += '"Account_ID": "'+listProductExtensions[0].Account_ID__c+'",';
                productJSONRequest += '"Country": "'+listProductExtensions[0].Country__c+'",';
                productJSONRequest += '"Dealer": "'+listProductExtensions[0].Dealer__c+'",';
                productJSONRequest += '"Equipment_Description": "'+listProductExtensions[0].Equipment_Description__c+'",';
                productJSONRequest += '"Equipment_Location": "'+listProductExtensions[0].Equipment_Location__c+'",';
                productJSONRequest += '"Equipment_Returned_Date": "'+listProductExtensions[0].Equipment_Returned_Date__c+'",';
                productJSONRequest += '"Equipment_S_N": "'+listProductExtensions[0].Equipment_S_N__c+'",';
                productJSONRequest += '"Equipment_Value": "'+listProductExtensions[0].Equipment_Value__c+'",';
                productJSONRequest += '"Province": "'+listProductExtensions[0].Province__c+'",';
                productJSONRequest += '"Repossession_Date": "'+listProductExtensions[0].Repossession_Date__c+'",';
                productJSONRequest += '"Value": "'+listProductExtensions[0].Value__c+'",';
                productJSONRequest += '"Zip_Code": "'+listProductExtensions[0].Zip_Code__c+'"';
            }
            productJSONRequest = productJSONRequest.removeEnd(',');
            productJSONRequest += '}';
        }
        system.debug('productJSONRequest: '+productJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('productJSONRequest: '+productJSONRequest);
            req.setBody(productJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
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
            }
            
            if(productInstance != NULL){
                ProductTriggerHandler.runProductTrigger = false;
                update productInstance;
                ProductTriggerHandler.runProductTrigger = true;
            }
        }
    } */   
}