/**************************************************************************************************
*
*  Class: ProcessProductBulkBatchAllocation  
*
*  @description : This class create the allocation JSON and call the portal API.
*  @author : A5E Consulting
*  @date : 25/01/2023
* 
*************************************************************************************************/
public class ProcessProductBulkBatchAllocation {
    
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    public static List<String> listProductJSONRequest = new List<String>();
    public static String productJSONRequest;
    public static Integer count = 1;
    public static Integer maxCount = 50;
    
    //fetch data from product object and create the allocation JSON.
    public static List<product__c> processProductBulkBatchone(List<ID> productId, Map<Id,String> placeStatusMap,String docType){
        list<Product__c> listProductupdate = new list<product__c>();
        try{
            String productJSONRequest1;
            String Query = 'SELECT iD,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Employer_Name__c,Current_Fees__c,Portfolio_Name_Lookup__r.Purchase_ID__c, ';
            for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
                if(fieldMappingInstance.Object_Name__c == 'Product'){
                    Query += fieldMappingInstance.Field_API__c + ', ';
                }
            }
            Query = Query.removeEnd(', ');
            Query+= ' FROM Product__c WHERE ID IN: productId';
            list<Product__c> listProduct = Database.query(Query);
            
            //call API.
            productAllocation(listProduct,docType);
            
        }catch(exception e){
            system.debug('exception::'+e);
        }
        return listProductupdate;     
    }
    
    //Create Json for product Allocation and call the portal API.
    public static void productAllocation(List<Product__c> listProduct,String documentType){
        
        Map<id,Product_Extension__c> mapProductExten = new Map<id,Product_Extension__c>();
        list<ID> prodIds = new list<ID>();
        
        for(Product__c prodIdsData : listProduct ){
            prodIds.add(prodIdsData.id);
        }
        
        List<Product_Extension__c> listProductExtensionsData = [SELECT ID,Name,Account_ID__c,Address_Line1__c,Address_Line2__c,City__c,
                                                                Country__c,Dealer__c, Description__c,Equipment_Description__c,Equipment_Location__c,
                                                                Equipment_Returned_Date__c,Equipment_S_N__c,Equipment_Value__c,
                                                                Province__c,Repossession_Date__c,Value__c,Zip_Code__c
                                                                FROM Product_Extension__c
                                                                WHERE Account_ID__c IN :prodIds];
        
        for(Product_Extension__c prodExtenData : listProductExtensionsData){
            mapProductExten.put(prodExtenData.Account_ID__c,prodExtenData);
        }
        //Product__c productInstance ;
        if(!listProduct.isEmpty()){
            for(Product__c productInstance : listProduct ){
                //Create JSON request for customer update
                //productInstance = listProduct[0];
                String escapeString = '';
                
                if(count == 1){
                    productJSONRequest = '[';                
                }
                if(count <= maxCount){
                    productJSONRequest += '{'+
                        '"Name": "'+productInstance.Name+'",'+
                        '"Legal_Decision_By": "'+productInstance.Legal_Decision_by__r.Name+'",'+
                        '"Account_Portfolio_ID": "'+productInstance.Portfolio_Name_Lookup__r.Purchase_ID__c+'",'+
                        '"Pool_Name": "'+productInstance.Pool_Name__r.Pool_ID__c+'",'+
                        '"Created_By": "'+productInstance.Created_By__c+'",'+
                        '"Allocated_Amount_Total": "'+productInstance.Allocated_Amount_Total__c+'",'+
                        '"Company_Name": "'+productInstance.Employer_Name__c+'",'+
                        '"Customer_Identifier": "'+productInstance.Customer_Identifier__c+'",'+
                        '"Current_Fees": "'+productInstance.Current_Fees__c+'",';
                    
                    for(Agency_Portal_Fields_Mapping__c mapping : fieldMapping){
                        if(mapping.Object_Name__c == 'Product'){
                            if(mapping.Field_Type__c != 'DateTime'  && mapping.Field_Type__c != 'Date'){
                                
                                
                            //For Ticket: 4612 - changes done by satyajit
                            String fieldValue = String.valueOf(productInstance.get(mapping.Field_API__c));
                            String escapedValue;
                            if(fieldValue != null){
                               // escapedValue = fieldValue.replaceAll('(?!^\\+)[^\\d]','');
                               //escapedValue = fieldValue.replaceAll('[^a-zA-Z0-9\\s+]', '');
                                escapedValue = fieldValue.replace('\n', '').replace('\r', ' ');   
                				escapedValue = escapedValue.replaceAll('\\s+', ' ');
                                escapedValue = escapedValue.replace('\b', '');
                                escapedValue = escapedValue.replace('\f', '');
                                escapedValue = escapedValue.replace('\"', '');   
                                escapedValue = escapedValue.replace('\\', '');
                                escapedValue = escapedValue.replace('}', ''); 
                                escapedValue = escapedValue.replace('{', '');
                                escapedValue = escapedValue.replace('[', '');
                                escapedValue = escapedValue.replace(']', '');
                                escapedValue = escapedValue.replace('(', '');
                                escapedValue = escapedValue.replace(')', '');
                            }
                            
                            //system.debug(escapedValue);
                            productJSONRequest += '\"' + mapping.Field_JSON_Tag__c + '\":"' + escapedValue + '\", ';
                               // productJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                                   // productInstance.get(mapping.Field_API__c)+'\", ';    
                            }else if(mapping.Field_Type__c == 'Date'){
                                 //For Ticket: 4612 - changes done by satyajit
                                productJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                                   productInstance.get(mapping.Field_API__c)+'\", ';  
                            }else{
                                if(mapping.Field_Type__c == 'DateTime' && productInstance.get(mapping.Field_API__c) != NULL){
                                    DateTime ss = DateTime.valueOf(productInstance.get(mapping.Field_API__c));
                                    
                                    String convertedDateTime = ss.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
                                    productJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                                        convertedDateTime+'\", ';  
                                    
                                }        
                            }
                        }
                        
                    }
                    
                    if(mapProductExten.containskey(productInstance.id)){
                        productJSONRequest += '"Extension_Description": "'+mapProductExten.get(productInstance.id).Description__c+'",';
                        productJSONRequest += '"Collateral_Address_Line1": "'+mapProductExten.get(productInstance.id).Address_Line1__c+'",';
                        productJSONRequest += '"Collateral_Address_Line2": "'+mapProductExten.get(productInstance.id).Address_Line2__c+'",';
                        productJSONRequest += '"Collateral_City": "'+mapProductExten.get(productInstance.id).City__c+'",';
                        productJSONRequest += '"Account_ID": "'+mapProductExten.get(productInstance.id).Account_ID__c+'",';
                        productJSONRequest += '"Collateral_Country": "'+mapProductExten.get(productInstance.id).Country__c+'",';
                        productJSONRequest += '"Dealer": "'+mapProductExten.get(productInstance.id).Dealer__c+'",';
                        productJSONRequest += '"Equipment_Description": "'+mapProductExten.get(productInstance.id).Equipment_Description__c+'",';
                        productJSONRequest += '"Equipment_Location": "'+mapProductExten.get(productInstance.id).Equipment_Location__c+'",';
                        productJSONRequest += '"Equipment_Returned_Date": "'+mapProductExten.get(productInstance.id).Equipment_Returned_Date__c+'",';
                        productJSONRequest += '"Equipment_S_N": "'+mapProductExten.get(productInstance.id).Equipment_S_N__c+'",';
                        productJSONRequest += '"Equipment_Value": "'+mapProductExten.get(productInstance.id).Equipment_Value__c+'",';
                        productJSONRequest += '"Province": "'+mapProductExten.get(productInstance.id).Province__c+'",';
                        productJSONRequest += '"Repossession_Date": "'+mapProductExten.get(productInstance.id).Repossession_Date__c+'",';
                        productJSONRequest += '"Value": "'+mapProductExten.get(productInstance.id).Value__c+'",';
                        productJSONRequest += '"Collateral_Zip_Code": "'+mapProductExten.get(productInstance.id).Zip_Code__c+'"';
                    } 
                    productJSONRequest = productJSONRequest.removeEnd(', ');
                    productJSONRequest += '},';
                    count ++;
                    
                    if(count == maxCount + 1){
                        count = 1;
                        productJSONRequest = productJSONRequest.removeEnd(',');
                        productJSONRequest += ']'; 
                        listProductJSONRequest.add(productJSONRequest);
                        productJSONRequest = '';
                    }
                }else{
                    count = 1;
                    productJSONRequest = productJSONRequest.removeEnd(',');
                    productJSONRequest += ']'; 
                    listProductJSONRequest.add(productJSONRequest);
                    productJSONRequest = '';
                }
                
            }
            if(productJSONRequest != ''){
                productJSONRequest = productJSONRequest.removeEnd(',');
                productJSONRequest += ']'; 
                listProductJSONRequest.add(productJSONRequest);
                
            }
            
            //Call Portal product update API for Allocation.
            AzureUtility.apiCall(listProductJSONRequest,documentType);
        }
        
        //return listProductJSONRequest;
    }
    
}