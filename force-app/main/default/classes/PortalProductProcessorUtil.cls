/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Product Processing API
*  @author : A5E Consulting
*  @date : 18/08/2021

*************************************************************************************************/
public class PortalProductProcessorUtil {
    //Create Request Fund record 
    public static map<String, Placement_Status_Code_Mapping__c> mapPlacementCodeStatus;
   
    public static String processProduct(Map<String,String> paramMap, Product__c productInstance){
   
    //Placement_Status_Code_Mapping__c statusCodes = Placement_Status_Code_Mapping__c.getDefaultAll();
        List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
        //map of Placement Code and Placement Status  
        mapPlacementCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        //mapPlacementStatus = new map<String, String>();
        for(Placement_Status_Code_Mapping__c reasons : [SELECT Parent_Status__c,Placement_Status_Code__c,
                                                               Status__c,Sub_Status__c, Complete_Status__c
                                                        FROM Placement_Status_Code_Mapping__c
                                                        ORDER BY Status__c]){
            mapPlacementCodeStatus.put(reasons.Placement_Status_Code__c, reasons);
             
        }
        system.debug('mapPlacementCodeStatus:'+mapPlacementCodeStatus);
        for(Agency_Portal_Fields_Mapping__c mapping : fieldMapping){
            if(mapping.Object_Name__c == 'Product'){
                if(paramMap.containsKey(mapping.Field_JSON_Tag__c) 
                && String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                    system.debug('paramMap.get(mapping.Field_JSON_Tag__c) :'+paramMap.get(mapping.Field_JSON_Tag__c));
                    if(mapping.Field_Type__c == 'Currency' 
                    || mapping.Field_Type__c == 'Percent' 
                    || mapping.Field_Type__c == 'Number'){
                      if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                         productInstance.put(mapping.Field_API__c,Decimal.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                      }                  
                    }
                    else if(mapping.Field_Type__c == 'Date'){
                        if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                            productInstance.put(mapping.Field_API__c,Date.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                        }      
                    }
                    else if(mapping.Field_Type__c == 'DateTime'){
                        if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                            
                            String str = '"2013-01-30T07:38:44.268Z"';
                            system.debug(JSON.deserialize(str, DateTime.class));
                            system.debug(DateTime.valueOf(JSON.deserialize(str, DateTime.class)));
                            String ss = '"'+paramMap.get(mapping.Field_JSON_Tag__c)+'"';
                            system.debug('ssss'+ss);
							DateTime convertedDateTime = DateTime.valueOf(JSON.deserialize(ss, DateTime.class));
                            system.debug('convertedDateTime::'+convertedDateTime);
                            productInstance.put(mapping.Field_API__c,convertedDateTime); 
                            system.debug('convertedDateTime::'+convertedDateTime);
                            //productInstance.put(mapping.Field_API__c,DateTime.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                        }      
                    }
                    else if(mapping.Field_Type__c == 'Checkbox'){
                        if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                            productInstance.put(mapping.Field_API__c,Boolean.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                        }      
                    }
                    else{
                        system.debug('mapping.Field_API__c::'+mapping.Field_API__c + mapping.Field_Type__C);
                        productInstance.put(mapping.Field_API__c, paramMap.get(mapping.Field_JSON_Tag__c));
                    }    
                }
            }
            
            
        }
    
            if(String.isNotBlank(paramMap.get('Refer_to_Legal'))){
             if(String.isNotBlank(paramMap.get('Placement_Status'))){
                productInstance.Status__c = mapPlacementCodeStatus.get(paramMap.get('Placement_Status')).Parent_Status__C+' '+'-'+' '+mapPlacementCodeStatus.get(paramMap.get('Placement_Status')).Status__C;
                productInstance.Sub_Status__c = mapPlacementCodeStatus.get(paramMap.get('Placement_Status')).Sub_Status__c;
               }
            }
        
        try{
            //to not run product trigger
            productTriggerHandler.runproductTrigger = false;
            
            //Populate identifier fields from handler method
            list<Product__c> listProduct = new list<Product__c>();
            listProduct.add(productInstance);
            getProductRelatedAgencyData(listproduct);
            productInstance.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            productInstance.Inbound_API_Response_Body__c = 'Successfully Created';
            Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
            if(productInstance.ID == NULL){
                productInstance.RecordTypeID = portalSettings.Distressed_Product_RecordTypeID__c ;
                insert productInstance;
            }
            else{
                update productInstance;
            }
            productTriggerHandler.runproductTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in product processing :'+ex);
            productTriggerHandler.runproductTrigger = false;
            productInstance.Inbound_API_Response_Body__c = ex.getMessage();
            if(productInstance.ID != NULL){
                update productInstance;
            }
            productTriggerHandler.runproductTrigger = true;
            return ex.getMessage();
        }
    }
    
    //using this inner method populate the Lookup fields using agency data.
    public static void getProductRelatedAgencyData(list<Product__c> listProduct){
        set<String> setCustomerID = new set<String>();
        set <String> setAgencyUserEmailAddress= new set<String>();  // Set of agency user id
        map<String, String> mapCustomers = new map<String, String>();
        map<String, string> mapAgencyUserId = new map<String, string>(); // Map of agency user id
        
        for(Product__c productObj : listProduct){
            if(String.isNotBlank(productObj.Customer_identifier__c)){
                setCustomerID.add(productObj.Customer_identifier__c);    
            }
            if(String.isNotBlank(productObj.Sent_for_Review_by__c)){
                setAgencyUserEmailAddress.add(productObj.Sent_for_Review_by__c);
            }
        }
        
        for(Account customer : [SELECT ID, SF_ID__c
                                FROM Account
                                WHERE SF_ID__c IN : setCustomerID]){
            mapCustomers.put(customer.SF_ID__c, customer.Id);
        }

        for(Agency_User__c Agency_UserName : [SELECT First_Name__c, Last_Name__c,Email_Address__c
                                FROM Agency_User__c
                                WHERE Email_Address__c IN : setAgencyUserEmailAddress]){
            mapAgencyUserId.put(Agency_UserName.Email_Address__c, Agency_UserName.First_Name__C + ' ' + Agency_UserName.Last_Name__c);
                                    system.debug('Agency_UserName.Email_Address__c:-'+Agency_UserName.Email_Address__c);
                                    system.debug('Name:-'+Agency_UserName.First_Name__C + ' ' + Agency_UserName.Last_Name__c);
         }
   
        for(Product__c productObj : listProduct){    
            productObj.Sent_for_Review_by__c = mapAgencyUserId.get(productObj.Sent_for_Review_by__c);
            system.debug('Sent_for_Review_by__c'+mapAgencyUserId.get(productObj.Sent_for_Review_by__c));
        }
    }
    
    
    
    public String returnDateTimeString(String dateTimeToConvert){
        
        String str = '"2013-01-30T07:38:44.268Z"';
		system.debug(JSON.deserialize(str, DateTime.class));
        String convertedDateTime = String.valueOf(JSON.deserialize(dateTimeToConvert, DateTime.class));
        return convertedDateTime;
    }
}