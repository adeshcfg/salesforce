/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Request Funds Processing API
*  @author : A5E Consulting
*  @date : 09/06/2021

*************************************************************************************************/
public class PortalPaymentProcessorUtil{   
    static map<String, String> mapPaymentPicklistValues = 
        new map<String, String>{
            'Succeeded' => 'Completed', 
            'Started' => 'In Progress',
            'InProgress' => 'In Progress',
            'Cancelled' => 'Cancelled',
            'Created' => 'New',
            'UnderReview' => 'In Progress'
        };
    
    //update Request Fund update
    public static String updateRequestFund(Map<String,String> paramMap, Payment_Transaction__c requestFund,
                                          String mapJSONResponse){
        Payment_Transaction__c payTransaction = new Payment_Transaction__c  ();
    	try{
          	requestFund.Status__c = mapPaymentPicklistValues.get(paramMap.get('Status'));
            requestFund.Payment_Processor_Request__c = mapJSONResponse;
            update requestFund;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in payment transaction insert :'+ex);
            return ex.getMessage();
        }
    }
    
    //Create Request Fund record 
    public static String createRequestFund(Map<String,String> paramMap, String mapJSONResponse){
        Customer_Payment_Processor_Settings__c payProcSettings = 
        Customer_Payment_Processor_Settings__c.getOrgDefaults();
        
        system.debug('paramMap:'+paramMap);
        system.debug('paramMap.getRecord_Type_Name:'+paramMap.get('Record_Type_Name'));
        Id RequestFundRecordTypeId = 
            Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get(paramMap.get('Record_Type_Name')).getRecordTypeId();
    	String ProductName = paramMap.get('Product_Name');
        list<Product__c> listProducts = [SELECT ID, Collection_Agency__c
                                         FROM Product__c
                                         WHERE Name= :ProductName];
        Payment_Transaction__c requestFundInstance = new Payment_Transaction__c();
        requestFundInstance.Payment_Initiated_By__c = 'End Customer';
        if(!listProducts.isEmpty()){
            requestFundInstance.Product__c = listProducts[0].Id;
            requestFundInstance.Collection_Agency__c = listProducts[0].Collection_Agency__c;
        }
        //Save JSON request
        requestFundInstance.Payment_Processor_Request__c = String.valueOf(paramMap);
        requestFundInstance.Payment_Processor_Id__c = paramMap.get('Payment_Processor_Id');
        requestFundInstance.Customer_Email_Address__c = paramMap.get('Customer_Email_Address');
        requestFundInstance.Connect_Url__c = paramMap.get('Connect_Url');
        system.debug('paramMap.get:'+paramMap.get('Connect_Url'));
        String connectURL = requestFundInstance.Connect_Url__c;                
        system.debug('connectURL1'+connectURL);
        system.debug('check check'+payProcSettings.Payment_URL_To_Get_Param__c);
        connectURL = connectURL.substringAfter(payProcSettings.Payment_URL_To_Get_Param__c);
        system.debug('connectURL: '+connectURL);
        String connectURLFinal = payProcSettings.Base_URL_for_Payment_Page_Iframe__c+'?'+connectURL;
        requestFundInstance.Site_ConnectURL__c = connectURLFinal;
        requestFundInstance.Amount__c = Decimal.valueOf(paramMap.get('Amount'));
        requestFundInstance.Status__c = mapPaymentPicklistValues.get(paramMap.get('Status'));
		requestFundInstance.Number_of_Payments__c = paramMap.get('Number_Of_Payments');
        requestFundInstance.Payment_Type__c = paramMap.get('Payment_Type');
        requestFundInstance.Recurrence_Type__c = paramMap.get('Recurrence_Type');
        if(requestFundInstance.Recurrence_Type__c == 'Monthly'){
            //Check if Last Day of the Month is true in JSON request
            system.debug('paramMap.get.LastDayofTheMonth'+paramMap.get('Last_Day_Of_Month'));
			if(paramMap.containsKey('Last_Day_Of_Month')
            && paramMap.get('Last_Day_Of_Month') == 'true'){
                requestFundInstance.Day_Of_Month__c = 'Last Day of the Month';
            }
            else{
          		requestFundInstance.Day_Of_Month__c = paramMap.get('Day_Of_Month');          
            }
        }
        else{
          requestFundInstance.Day_Of_Week__c = paramMap.get('Day_Of_Week');    
        }
        if(String.isNotBlank(paramMap.get('End_Date'))){
            system.debug('request fund end date from portal: '+paramMap.get('End_Date'));
            requestFundInstance.End_Date__c = Datetime.valueOf(paramMap.get('End_Date').replace('T',' '));
        }
        requestFundInstance.RecordTypeID = RequestFundRecordTypeId;
        requestFundInstance.Status_Change_Date__c = Date.today();
        requestFundInstance.Payment_Processor_Request__c = mapJSONResponse;
        try{
          	insert requestFundInstance;
			return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in payment transaction insert :'+ex);
            return ex.getMessage();
        }
    }
}