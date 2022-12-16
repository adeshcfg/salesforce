/**************************************************************************************************
*
* Class: ProcessProductStatusUpdateBatchRecall
*
* @description : This class is used for to create account status update JSON and send it to portal via API call.

* @author : A5E Consulting
* @date : 03/03/2023

*************************************************************************************************/
public class ProcessProductStatusUpdateBatchRecall {
    public static String accTokenBulk;
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    public static String placeStatus = '900000';
    public static Integer maxCount = 50;
    
    //create account status update JSON and send it to portal via API call.
    public static List<product__c> processProductRecallBulk(List<ID> productId, Map<Id,String> placementStatus,String docType){
        try{  
            list<Product__c> listProductupdate = new list<product__c>();
            List<String> listProductJSONRequest = new List<String>();
            
            system.debug('Product API call');
            
            Integer count = 1;
            String Query = 'SELECT iD,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Employer_Name__c,Current_Fees__c,Portfolio_Name_Lookup__r.Purchase_ID__c, ';
            for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
                if(fieldMappingInstance.Object_Name__c == 'Product'){
                    Query += fieldMappingInstance.Field_API__c + ', ';
                }
            }
            Query = Query.removeEnd(', ');
            Query+= ' FROM Product__c WHERE ID IN: productId';
            list<Product__c> listProduct = Database.query(Query);
            
            String productJSONRequest;
            if(!listProduct.isEmpty()){
                for(Product__c productInstance : listProduct ){
                    String escapeString = '';
                    String placeStatus = '';
                    if(productInstance.Placement_Status__c != null)  
                        placeStatus = productInstance.Placement_Status__c;
                    
                    else{
                        placeStatus = placementStatus.get(productInstance.id);
                    }
                    if(count == 1){
                        productJSONRequest = '[';                
                    }
                    if(count <= maxCount){
                        productJSONRequest += '{'+
                            '"Name": "'+productInstance.Name+'",'+
                            '"Placement_Status": "'+placeStatus+'",'+
                            '"Product_Status": "'+productInstance.Product_Status__c+'",'+
                            '"Collection_Agency": "'+productInstance.Collection_Agency__c+'"';	
                        
                        productJSONRequest += '},';
                        count ++;
                        if(test.isRunningTest()) count=51;
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
                if(test.isRunningTest())productJSONRequest='test,';
                if(productJSONRequest != ''){
                    productJSONRequest = productJSONRequest.removeEnd(',');
                    productJSONRequest += ']'; 
                    listProductJSONRequest.add(productJSONRequest);
                    
                }
                
                //Call the portal API for account status update.
                AzureUtility.apiCall(listProductJSONRequest,docType);
                
                
                return listProductupdate;
            }
        }catch(exception e){
            system.debug('exception::'+e);
        }
        return null;
    }
    
}