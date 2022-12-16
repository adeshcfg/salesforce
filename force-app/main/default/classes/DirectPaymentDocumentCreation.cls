/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a batch class to create direct payment document storage to send portal
 *  @author : A5E Consulting
 *  @date : 11/07/2022
 
 *************************************************************************************************/
public class DirectPaymentDocumentCreation implements Schedulable{
	static Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
	static map<String, ID> mapAgencyID;
    public static string TRANSACTIONS = 'Transactions';
    
    public static void execute(SchedulableContext sc){
    	createDocumentStorage();
    }
    
    //method to create work assignment and associated document storage for direct pay notification
    public static void createDocumentStorage(){
        //variables
        list<Document_Storage__c> listDocStorage = new list<Document_Storage__c>();
        list<Product_Payments__c> listProductPayments = new list<Product_Payments__c>();
        map<String, Decimal> mapAgencyTotalPayments = new Map<String, Decimal>();
        map<String, String> mapAgencyCSV = new Map<String, String>();
        mapAgencyID = new map<String, ID>();
        map<String, String> mapAgencyNames = new map<String, String>();
        
        map<String, Document_Storage__c> mapAgencyDocumentStorage = new Map<String, Document_Storage__c>();
        
        //payment csv string with headers
        String paymentcsv = 'data_id,tran_date,tran_amount,pay_source,pay_type,pri_acctno';
        
        Date dtTodayDate = System.Today();

        Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
        
        string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                
        //get direct payments created today
        listProductPayments = [SELECT ID, Payment_Posting_Date__c, CCS_Account__c,CCS_Account__r.Name, Payment_Agency__c, Payment_Posting_Date_Text__c,
                               Payment_Amount__c, Payment_Source__c,Payment_provided_agency__c,  Payment_provided_agency__r.Agency_Name__c,
                               Payment_Type__c,
                               CCS_Account__r.Previous_Primary_Account_Number__c	
                               FROM Product_Payments__c
                               WHERE CreatedDate = TODAY
                               AND (Payment_Source__C = '2' OR Payment_Source__c = '3')
                               AND Payment_Agency__c != NULL
                               //AND Payment_Agency__c = '102'
                               ORDER BY Payment_Agency__c];
        
        if(!listProductPayments.isEmpty()){
            for(Product_Payments__c prodPayment : listProductPayments){
                //create map with agency and associated payment file
            	if(mapAgencyTotalPayments.containsKey(prodPayment.Payment_Agency__C)){
                    mapAgencyTotalPayments.put(prodPayment.Payment_Agency__c, 
                                               mapAgencyTotalPayments.get(prodPayment.Payment_Agency__c) + prodPayment.Payment_Amount__c);
                    paymentcsv = mapAgencyCSV.get(prodPayment.Payment_Agency__c);
                    paymentcsv += '\n';
                    paymentcsv +=    prodPayment.CCS_Account__r.Name 
                        	   +','+ prodPayment.Payment_Posting_Date_Text__c 
                        	   +','+ prodPayment.Payment_Amount__c
                               +','+ prodPayment.Payment_Source__c
                        	   +','+ prodPayment.Payment_Type__c
                        	   +','+ prodPayment.CCS_Account__r.Previous_Primary_Account_Number__c;
                    mapAgencyCSV.put(prodPayment.Payment_Agency__c, paymentcsv);
                    
                }    
                else{
                    mapAgencyID.put(prodPayment.Payment_Agency__c, prodPayment.Payment_provided_agency__c);
                    mapAgencyTotalPayments.put(prodPayment.Payment_Agency__c, prodPayment.Payment_Amount__c);
                    mapAgencyNames.put(prodPayment.Payment_Agency__c, prodPayment.Payment_Provided_Agency__r.Agency_name__c);
                    paymentcsv = 'data_id,tran_date,tran_amount,pay_source,pay_type,pri_acctno';
                    paymentcsv += '\n';
                    paymentcsv +=    prodPayment.CCS_Account__r.Name 
                        	   +','+ prodPayment.Payment_Posting_Date_Text__c 
                        	   +','+ prodPayment.Payment_Amount__c
                               +','+ prodPayment.Payment_Source__c
                        	   +','+ prodPayment.Payment_Type__c
                        	   +','+ prodPayment.CCS_Account__r.Previous_Primary_Account_Number__c;
                    mapAgencyCSV.put(prodPayment.Payment_Agency__c, paymentcsv);       
                }
            }
                        
            system.debug('mapAgencyID::'+mapAgencyID);
            for(String payAgency : mapAgencyCSV.keySet()){
                blob paymentFile;
                
                if(String.isNotBlank(payAgency)){
                	if(Test.isRunningTest()) {
                    	paymentFile = Blob.valueOf('test');
                    }else{
                        paymentFile = Blob.valueOf(mapAgencyCSV.get(payAgency));
                    }    
                }
                
                /*DocumentAPIClientUtil.ParsedResponse parsedResponse = DocumentAPIClient.postDocument(paymentFile , 
                                                                                             'Direct Payment.csv',  'Task');
                */
                //create work assignment record 
                Work_Assignment__c workAssignment = new Work_Assignment__c();
                workAssignment.Requested_Date__c = Date.today();
                
                workAssignment.Title__c = 'Direct Payment Notification for Placement ' + payAgency + '('+ mapAgencyNames.get(payAgency) + ') on ' 
                    					+ strDate;
                workAssignment.Description__c = 'Total Amount received from Direct Payment on Agency ' +payAgency + ' is: '+ mapAgencyTotalPayments.get(payAgency);
                workAssignment.Assign_To__c = 'Agency';
                workAssignment.Priority__c = 'Medium';
                workAssignment.Purpose__c = 'Payment';
                workAssignment.Sub_Purpose__c = 'Payment';
                workAssignment.Placement_Agency__c = mapAgencyID.get(payAgency);
                workAssignment.Placement_Agency_Identifier__c = payAgency;
                if(!Test.isRunningTest()){
                	workAssignment.RecordTypeID = portalSettings.Agency_Work_Assignment_RecordTypeID__c;
                }
                workAssignment.Status__c = 'Completed';
                workAssignment.Notification_Type__c = TRANSACTIONS;
                workAssignment.Total_Amount_of_Payments__c = mapAgencyTotalPayments.get(payAgency);
                insert workAssignment;
                
                String TaskNumber = [SELECT ID, task_Number__c from Work_Assignment__c WHERE ID = :workAssignment.ID][0].Task_Number__c;
                
                /*Document_Storage__c docInfo = new Document_Storage__c();
                docInfo.Document_Name__c = 'Direct Payments for' +payAgency+'.csv';
                docInfo.Document_Type__c = 'Direct Payment';
                docInfo.Document_URL__c = parsedResponse.DocUrl;
                docInfo.Document_Id__c = parsedResponse.docId;
                docInfo.Placement_Agency__c = mapAgencyID.get(payAgency);
                docInfo.Placement_Identifier__c = payAgency;
                docInfo.Work_Assignment__c = workAssignment.ID;
                docInfo.Work_Assignment_Identifier__c = TaskNumber;
                docInfo.Payment_Type__c = 'Direct Payment';
                docInfo.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
                docInfo.Created_By__c = UserInfo.getName();
                docInfo.Creator__c = docInfo.Created_By__c;
                docInfo.Document_Extension__c = 'csv';
                docInfo.Uploaded_By__c = 'Internal User';
                docInfo.Document_Related_To__c = 'Task';
                docInfo.Payment_Type__c = 'Direct Payment';
                system.debug('docInfo::'+docInfo);
                listDocStorage.add(docInfo);*/
                postDocumentAPI(paymentFile, workAssignment.ID, TaskNumber, payAgency, mapAgencyID.get(payAgency), '',
                             '');
            }
            
        }
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        //insert docInfo;
        insert listDocStorage;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        //SendDirectPaymentDocumentToPortalBatch btch = new SendDirectPaymentDocumentToPortalBatch();
		//Parameters of ExecuteBatch(context,BatchSize)
		//database.executebatch(btch);       

       
    }
    
    @future(callout = true)
    public static void postDocumentAPI(Blob paymentFile, String workAssignmentID, String TaskNumber, String payAgency, String agencyID,
                                      String docUrl, String docId){
        system.debug('paymentFile::'+paymentFile);
        system.debug('agencyID:'+agencyID);
        //Calls the Azure cloud API to store documents on Azure.
        
        system.debug('docUrl::'+docUrl);
        system.debug(' workAssignmentID'+workAssignmentID);
        system.debug('TaskNumber '+TaskNumber);
        system.debug(' payAgency'+payAgency);
        system.debug('agencyID '+agencyID);

		DocumentAPIClientUtil.ParsedResponse parsedResponse = DocumentAPIClient.postDocument(paymentFile , 
                                                                                             'Direct Payment.csv',  'Task');
                
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Direct Payments for ' +payAgency+'.csv';
        docInfo.Document_Type__c = 'Direct Payment';
        docInfo.Document_URL__c =parsedResponse.DocUrl;
        docInfo.Document_Id__c = parsedResponse.docId;
        docInfo.Placement_Agency__c = agencyID;
        docInfo.Placement_Identifier__c = payAgency;
        docInfo.Work_Assignment__c = workAssignmentID;
        docInfo.Work_Assignment_Identifier__c = TaskNumber;
        docInfo.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
        docInfo.Created_By__c = UserInfo.getName();
        docInfo.Creator__c = docInfo.Created_By__c;
        docInfo.Document_Extension__c = 'csv';
        docInfo.Uploaded_By__c = 'Internal User';
        docInfo.Document_Related_To__c = 'Task';
		docInfo.Record_Type_Identifier__c = 'Distressed';
        docInfo.Payment_Type__c = TRANSACTIONS;
        system.debug('docInfo::'+docInfo);
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        insert docInfo;
		DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
}