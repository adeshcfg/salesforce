/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to create Document Storage and WA for Account Updates to Portal
 *  @author : A5E Consulting
 *  @date : 05/09/2022
 
 *************************************************************************************************/
public class ProductUpdateSchedulable implements Schedulable{
    static Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
	static map<Integer, ID> mapAgencyID;
    static String strDate;
    
    public static void execute(SchedulableContext sc){
    	createDocumentStorage();
        //DirectPaymentDocumentCreation.execute(null);
    }
    
    //method to create work assignment and associated document storage for Product Updates
    public static void createDocumentStorage(){
        //variables
        list<Document_Storage__c> listDocStorage = new list<Document_Storage__c>();
        //transient list<Product__history> listProductsHostory = new list<Product__history>();
        map<Integer, String> mapAgencyCSV = new Map<Integer, String>();
        mapAgencyID = new map<Integer, ID>();
        map<Integer, String> mapAgencyNames = new map<Integer, String>();
        
        map<String, Document_Storage__c> mapAgencyDocumentStorage = new Map<String, Document_Storage__c>();
        
        //payment csv string with headers
        String paymentcsv = 'data_id,field_name,old_value,new_value,changed_date';
        
        Date dtTodayDate = System.Today();

        Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
        
        strDate = dtTodayDateTime.format('MM/dd/yyyy');
                
        //get direct payments created today
        /*if(Test.isRunningTest()) {
            listProductsHostory = [SELECT Id, Field, OldValue, NewValue, ParentId,parent.name, CreatedDate, Parent.Collection_Agency_Placement__r.Agency_Name__c, Parent.Collection_Agency__c, Parent.Collection_Agency_Placement__c	
                               FROM Product__history
                               WHERE CreatedDate = TODAY
                               AND Parent.Collection_Agency__c != NULL
                               AND Parent.Collection_Agency_Placement__c != NULL
                               ORDER BY Parent.Collection_Agency__c limit 100];
        } else {
            listProductsHostory = [SELECT Id, Field, OldValue, NewValue, ParentId,parent.name, CreatedDate, Parent.Collection_Agency_Placement__r.Agency_Name__c, Parent.Collection_Agency__c, Parent.Collection_Agency_Placement__c	
                               FROM Product__history
                               WHERE CreatedDate = TODAY 
                               AND Parent.Collection_Agency__c != NULL
                               AND Parent.Collection_Agency_Placement__c != NULL 
                                   //and parentId ='a0D7g000003IkxS'  
                               ORDER BY Parent.Collection_Agency__c DESC limit 50000];
        }*/
        System.debug('========== Heap Size :: ' + Limits.getHeapSize());
        String type='Product__c';
        //Id idVar = '';
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		/*for (String fieldName: fieldMap.keySet()) {
			System.debug('##Field API Name='+fieldName);// list of all field API name
		}*/
		if(!Test.isRunningTest()){
            for(List<Product__history> listProductsHostory : [SELECT Id, Field, OldValue, NewValue, ParentId,parent.name, CreatedDate, Parent.Collection_Agency_Placement__r.Agency_Name__c, Parent.Collection_Agency__c, Parent.Collection_Agency_Placement__c FROM Product__history
                                   WHERE CreatedDate = TODAY AND Parent.Collection_Agency__c != NULL AND Parent.Collection_Agency_Placement__c != NULL  and Field != 'Interest_Amount_Last_Calculated_Date__c' and Field != 'Current_Principal_Balance__c' and Field != 'Effective_Current_Balance__c' and field !='Current_Interest_Amount__c' and Field != 'Current_Balance__c' and Field != 'Status__c' and Field != 'Sub_Status__c' and Field != 'Product_Status__c'ORDER BY Parent.Collection_Agency__c ]){
                for(Product__history productHistory : listProductsHostory){
                Integer collectionAgencyInt = Integer.valueOf(productHistory.Parent.Collection_Agency__c);
            	if(mapAgencyCSV.containsKey(collectionAgencyInt)){
                    paymentcsv = mapAgencyCSV.get(collectionAgencyInt);
                    //system.debug('productHistoryField**' +productHistory.Field);
                    if(productHistory.Field != 'Current_Interest_Amount__c' && productHistory.Field != 'Effective_Current_Balance__c' && productHistory.Field != 'Current_Principal_Balance__c' && productHistory.Field != 'Interest_Amount_Last_Calculated_Date__c' && productHistory.Field != 'Current_Balance__c'){
                        if(fieldMap.get(productHistory.Field) != null){
                            paymentcsv += '\n';
                            paymentcsv +=productHistory.Parent.Name 
                                +','+fieldMap.get(productHistory.Field).getDescribe().getLabel()
                                +','+ productHistory.OldValue
                                +','+ productHistory.NewValue
                                +','+ productHistory.CreatedDate;
                            mapAgencyCSV.put(collectionAgencyInt , paymentcsv);
                        }
                    }    
                    
                } else{
                    mapAgencyID.put(collectionAgencyInt , productHistory.Parent.Collection_Agency_Placement__c);
                    mapAgencyNames.put(collectionAgencyInt , productHistory.Parent.Collection_Agency_Placement__r.Agency_name__c);
                    paymentcsv = 'DataId,Field,Old Value,New Value,Date';
                    if(productHistory.Field != 'Current_Interest_Amount__c' && productHistory.Field != 'Effective_Current_Balance__c' && productHistory.Field != 'Current_Principal_Balance__c' && productHistory.Field != 'Interest_Amount_Last_Calculated_Date__c' && productHistory.Field != 'Current_Balance__c'){
                        if(fieldMap.get(productHistory.Field) != null){
                            paymentcsv += '\n';
                            paymentcsv +=productHistory.Parent.Name 
                                +','+ fieldMap.get(productHistory.Field).getDescribe().getLabel()
                                +','+ productHistory.OldValue
                                +','+ productHistory.NewValue
                                +','+ productHistory.CreatedDate;
                            mapAgencyCSV.put(collectionAgencyInt , paymentcsv);       
                        }
                    }
                }
            }
         }
	}
	else{
		 for(List<Product__history> listProductsHostory : [SELECT Id, Field, OldValue, NewValue, ParentId,parent.name, CreatedDate, Parent.Collection_Agency_Placement__r.Agency_Name__c, Parent.Collection_Agency__c, Parent.Collection_Agency_Placement__c FROM Product__history
                                   WHERE CreatedDate = TODAY AND Parent.Collection_Agency__c != NULL AND Parent.Collection_Agency_Placement__c != NULL  and Field != 'Interest_Amount_Last_Calculated_Date__c' and Field != 'Current_Principal_Balance__c' and Field != 'Effective_Current_Balance__c' and field !='Current_Interest_Amount__c' and Field != 'Current_Balance__c' and Field != 'Status__c' and Field != 'Sub_Status__c' and Field != 'Product_Status__c'ORDER BY Parent.Collection_Agency__c limit 100]){
                for(Product__history productHistory : listProductsHostory){
                Integer collectionAgencyInt = Integer.valueOf(productHistory.Parent.Collection_Agency__c);
            	if(mapAgencyCSV.containsKey(collectionAgencyInt)){
                    paymentcsv = mapAgencyCSV.get(collectionAgencyInt);
                    //system.debug('productHistoryField**' +productHistory.Field);
                    if(productHistory.Field != 'Current_Interest_Amount__c' && productHistory.Field != 'Effective_Current_Balance__c' && productHistory.Field != 'Current_Principal_Balance__c' && productHistory.Field != 'Interest_Amount_Last_Calculated_Date__c' && productHistory.Field != 'Current_Balance__c'){
                        if(fieldMap.get(productHistory.Field) != null){
                            paymentcsv += '\n';
                            paymentcsv +=productHistory.Parent.Name 
                                +','+fieldMap.get(productHistory.Field).getDescribe().getLabel()
                                +','+ productHistory.OldValue
                                +','+ productHistory.NewValue
                                +','+ productHistory.CreatedDate;
                            mapAgencyCSV.put(collectionAgencyInt , paymentcsv);
                        }
                    }    
                    
                } else{
                    mapAgencyID.put(collectionAgencyInt , productHistory.Parent.Collection_Agency_Placement__c);
                    mapAgencyNames.put(collectionAgencyInt , productHistory.Parent.Collection_Agency_Placement__r.Agency_name__c);
                    paymentcsv = 'DataId,Field,Old Value,New Value,Date';
                    if(productHistory.Field != 'Current_Interest_Amount__c' && productHistory.Field != 'Effective_Current_Balance__c' && productHistory.Field != 'Current_Principal_Balance__c' && productHistory.Field != 'Interest_Amount_Last_Calculated_Date__c' && productHistory.Field != 'Current_Balance__c'){
                        if(fieldMap.get(productHistory.Field) != null){
                            paymentcsv += '\n';
                            paymentcsv +=productHistory.Parent.Name 
                                +','+ fieldMap.get(productHistory.Field).getDescribe().getLabel()
                                +','+ productHistory.OldValue
                                +','+ productHistory.NewValue
                                +','+ productHistory.CreatedDate;
                            mapAgencyCSV.put(collectionAgencyInt , paymentcsv);       
                        }
                    }
                }
            }
         }
		
	}
                        
            system.debug('mapAgencyID::'+mapAgencyID);
            Map<String, Blob> accountUpdateFileMap= new Map<String, Blob>();
            Map<String, String> agencyNameMap= new Map<String, String>();
            List<Work_Assignment__c> workAssignmentList = new List<Work_Assignment__c>();
            for(Integer payAgency : mapAgencyCSV.keySet()){
                String strAgency = String.valueOf(payAgency);
                String agencyName = mapAgencyNames.get(payAgency);
                if(payAgency != null){
                    Blob fileBlob;
                	if(Test.isRunningTest()) {
                    	fileBlob = Blob.valueOf('test');
                    }else{
                        fileBlob = Blob.valueOf(mapAgencyCSV.get(payAgency));
                    }    
                    accountUpdateFileMap.put(strAgency, fileBlob);
                }
				agencyNameMap.put(strAgency, agencyName);
                //create work assignment record 
                Work_Assignment__c workAssignment = new Work_Assignment__c();
                workAssignment.Requested_Date__c = Date.today();
                
                workAssignment.Title__c = 'Account updated for Agency ' + payAgency + ','+ agencyName + ' on ' + strDate;
                workAssignment.Assign_To__c = 'Agency';
                workAssignment.Priority__c = 'Medium';
                workAssignment.Purpose__c = 'Query';
                workAssignment.Sub_Purpose__c = 'General Inquiries';
                workAssignment.Placement_Agency__c = mapAgencyID.get(payAgency);
                workAssignment.Placement_Agency_Identifier__c = strAgency;
                workAssignment.RecordTypeID = portalSettings.CFGWorkAssignmentRecordTypeId__c;
                workAssignment.Status__c = 'Completed';
                workAssignment.Notification_Type__c = 'Account Update';
                workAssignmentList.add(workAssignment);
            }
            
            insert workAssignmentList;
            List<Work_Assignment__c> woList = [SELECT ID, Task_Number__c,Placement_Agency_Identifier__c, Placement_Agency__c from Work_Assignment__c WHERE ID IN :workAssignmentList];
            
            for(Work_Assignment__c wassignObj: woList) {
                postDocumentAPI(accountUpdateFileMap.get(wassignObj.Placement_Agency_Identifier__c), wassignObj.ID, wassignObj.Task_Number__c, wassignObj.Placement_Agency_Identifier__c, wassignObj.Placement_Agency__c, '',
                             '', agencyNameMap.get(wassignObj.Placement_Agency_Identifier__c) );
            }
        //}      
    }
    
    @future(callout = true)
    public static void postDocumentAPI(Blob accountUpdateFile, String workAssignmentID, String TaskNumber, String payAgency, String agencyID,
                                      String docUrl, String docId, String agencyNames){
        String fileName = 'Account updated for Agency ' + payAgency + ','+ agencyNames + ' on ' + strDate+'.csv';
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        if(!Test.isRunningTest()) {
           parsedResponse = DocumentAPIClient.postDocument(accountUpdateFile , fileName,  'Task');
        } else {
           parsedResponse.DocUrl = 'Test';
           parsedResponse.docId = 'Test';
        }
                
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = fileName;
        docInfo.Document_Type__c = 'Account Updates';
        docInfo.Document_URL__c =parsedResponse.DocUrl;
        docInfo.Document_Id__c = parsedResponse.docId;
        docInfo.Placement_Agency__c = agencyID;
        docInfo.Placement_Identifier__c = payAgency;
        docInfo.Work_Assignment__c = workAssignmentID;
        docInfo.Work_Assignment_Identifier__c = TaskNumber;
        docInfo.Payment_Type__c = 'Account Update';
        docInfo.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
        docInfo.Created_By__c = UserInfo.getName();
        docInfo.Creator__c = docInfo.Created_By__c;
        docInfo.Document_Extension__c = 'csv';
        docInfo.Uploaded_By__c = 'Internal User';
        docInfo.Document_Related_To__c = 'Task';
		docInfo.Record_Type_Identifier__c = 'Distressed';
        system.debug('docInfo::'+docInfo);
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        insert docInfo;
		DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
}