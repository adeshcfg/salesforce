/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : Utility class that generates Product CSV file
 *  @author : A5E Consulting
 *  @date : 08/06/2022   
 
 *************************************************************************************************/
public with sharing class SnapshotProcessor {
    public static final String PRODUCT_SNAPSHOT = 'Product Snapshot';
    
    //Method to generate CSV stringm and file
    @future(callout = true)
    public static void createSnapshotFile(List<Id> productIds, Id agencyId) {
        //CSV Header
        string csvHeaders = getCSVHeader();
        
        //CSV record data content
        string csvString = '';
        csvString = getCSVHeaderData(productIds);
        
        Placement__c placement = [SELECT Agency_Name__c FROM Placement__c WHERE Id =: agencyId LIMIT 1];
        // CSV header and CSV Content
        string finalStr = csvHeaders + csvString;

        DocumentAPIClientUtil.ParsedResponse parsedResponse = DocumentAPIClient.postDocument(Blob.valueOf(finalStr) , 
                                                                    'Product Snapshot.csv',
                                                                    'account');
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = PRODUCT_SNAPSHOT;
        docInfo.Document_URL__c = parsedResponse.docUrl;
        docInfo.Document_Name__c = placement.Agency_Name__c+' - '+System.today()+'.csv';
        docInfo.Document_Id__c = parsedResponse.docId;
        docInfo.Placement_Agency__c = agencyId;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        //PortalDocumentStorageProcessingAPI.processDocumentStorage(docInfo.id);
        insert docInfo;
        
        //processDocumentStorage(docInfo.id);
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        //PortalDocumentStorageProcessingAPI.processDocumentStorage(docInfo.id);
       //string accessToken = Utilities.getAzureAccessToken('Agency Portal API');
       // Utilities.document_API_URL
    }
    
    //Query custom product records
    private static List<Product__c> productQuery(List<Id> productIds){
        return [SELECT Id,
                        Name,
                        Customer__c,
                        COLLECTION_AGENCY__C,
                        Agency_Company__c , //Collection_Agency_Name,
                        CURRENT_PRINCIPAL_BALANCE__C,
                        CURRENT_BALANCE__C,
                        INTEREST_RATE__C,    
                        CURRENT_INTEREST_AMOUNT__C,    
                        Current_Bal_NSF_Fees__c,
                        CURRENT_BAL_COURT_FEES__C,    
                        CURRENT_BAL_OTHER_FEES__C,    
                        CURRENT_BAL_ATTORNEY_FEES__C,    
                        CURRENT_BAL_GENERAL_FEES__C,    
                        Commission_Rate__c, //Comission_Rate__c
                        Collection_Agency_Placement__c,Previous_Secondary_Account_Number__c,Previous_Primary_Account_Number__c,First_Name__c,Middle_Name__c,
                        Last_Name__c,Primary_Debtor_AKA_Name__c,Email_Address__c,Employer_Name__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Zip_Code__c,Country__c,Date_of_Birth__c,Phone_Home__c,
                        Phone_Work__c,Phone_Other__c,SIN__c,Product_Status__c,Codebtor_First_Name__c,Codebtor_Middle_Name__c,Codebtor_Last_Name__c,Codebtor_Employer_Name__c,Codebtor_Email_Address__c,
                        Codebtor_Phone_Home__c,Codebtor_Phone_Work__c,Codebtor_Phone_Other__c,Codebtor_Address_Line1__c,Codebtor_Address_Line2__c,Codebtor_Zip_Code__c,Codebtor_Country__c,Codebtor_City__c,
                        Codebtor_State__c,Codebtor_Date_of_Birth__c,Assignment_Date__c,Assignment_Accepted_Date__c,Status_Changed_Date__c,Stat_Barred_Date_External__c,Originating_Creditor__c,
                        Open_Date__c,Charged_Off_Date__c,Last_Payment_Date__c,Last_Payment_Amount__c,Charged_Off_Amount__c,Pool_Name__c,Fraud_Date__c,Last_Payment_Date_Prior_to_CO__c,
                        Last_Payment_Amount_Prior_to_CO__c,Account_Portfolio_Code__c,Value_Tier_at_Time_of_Placement__c,Number_Of_Open_Complaint__c,Commission_Rate_at_Time_of_Placement__c,
                        Current_Principal_Amount__c,Extinguished_Status__c,Extinguished_Date__c,Placement_Status__c,Settlement_Rate__c
                    FROM Product__c
                    WHERE Id IN: productIds ];
    }
    
    @AuraEnabled  
    public static List<Document_Storage__c> getFiles(String recordId){
        system.debug('entered getFiles');
        system.debug('recordId: '+recordId);
        System.debug('@BASE_URL'+URL.getSalesforceBaseUrl().toExternalForm());
        
        // For all other user simply return the file list
        return [SELECT ID, 
                Document_ID__c,
                Document_Name__c,
                Document_URL__c,
                Document_Type__c,
                CreatedDate,
                Content_Type__c,
                Work_Assignment__c,
                Created_By__c,
                Document_Storage_Number__c,
                Parent_WorkAssignment_Product__c,
                File_Processing_Status__c,
                Staging_Records_Created__c,
                Visibility__c,
                Product__c
                FROM Document_Storage__c 
                WHERE 
                Placement_Agency__c  =:recordId 
                ORDER BY CreatedDate DESC ];        
    }

    @AuraEnabled  
    public static DocumentDetails previewDocument(String documentId) {
        return FileUploadToAzureController.previewDocument(documentId);
    } 
    
    private static string getCSVHeader(){
        string csvHeaders = 'ID, NAME, CUSTOMER, CURRENT_PRINCIPAL_BALANCE__C,'+
        ' CURRENT_BALANCE, INTEREST_RATE, CURRENT_INTEREST_AMOUNT, NSF_FEES, CURRENT_BAL_COURT_FEES, '+
        'CURRENT_BAL_OTHER_FEES, CURRENT_BAL_ATTORNEY_FEES, CURRENT_BAL_GENERAL_FEES,  Commission_Rate,Secondary_Account,'+
        'Primary_Account,Agency_Id,Primary_First_Name, Primary_Middle_Name, Primary_Last_Name, Primary_AKA_Name, Primary_Email,'+
        'Primary_Company_Name, Primary_Address1, Primary_Address2, Primary_City, Primary_State, Primary_Postal_Code,'+
        'Primary_Country_Name,Primary_Dob_Name, Primary_Home_Phone, Primary_Work_Phone, Primary_Personotherphone,'+
        'Primary_SIN, Status_Code, Secondry_First_Name, Secondry_Middle_Name, Secondry_Last_Name, Secondry_Company,'+
        'Secondry_Email,Secondry_Home_Phone,Secondry_Work_Phone,Secondry_Cphone_Name,Secondry_Address1,Secondry_Address2,'+
        'Secondry_Postal_Code,Secondry_Country,Secondry_City,Secondry_State,Secondry_Dob_Name,Placement_Date,Placement_Accepted_Date,'+
        'Placement_Status_Change_Date,Stat_Barred_Date_External,Originator,Open_Date,Charge_Off_Date,Last_Payment_Date,'+
        'Last_Payment_Amount,Charge_Off_Amount,Interest_Rate(%) ,Pool_Name,Fraud_Date,Last_Payment_Prior_To_CO_Date,'+
        'Last_Payment_Prior_To_CO_Amount,Portfolio_Code,Value_Tier_at_Time_of_Placement,Complaint,Placed_Commission_Rate(%),'+
        'Current_Commission_Rate,Current_Settlement_Rate,Current_Principal,Current_Interest,Extinguished_Status,'+
        'Extinguished_Date,Placement_Status \n';
        return csvHeaders;
    }
    
    private static string getCSVHeaderData(List<Id> prodIds){
        string csvString = '';
        // Query product and frame csv string
        for(Product__c prod: productQuery(prodIds)){
            String recordStr = prod.Id+','+
                            + prod.Name +','
                            + prod.Customer__c +','
                            //+ prod.COLLECTION_AGENCY__C +','
                            //+ prod.Agency_Company__c +','
                            + prod.CURRENT_PRINCIPAL_BALANCE__c +','
                            + prod.CURRENT_BALANCE__c +','
                            + prod.INTEREST_RATE__c +','
                            + prod.CURRENT_INTEREST_AMOUNT__c +','
                            + prod.Current_Bal_NSF_Fees__c +','
                            + prod.CURRENT_BAL_COURT_FEES__c +','
                            + prod.CURRENT_BAL_OTHER_FEES__c +','
                            + prod.CURRENT_BAL_ATTORNEY_FEES__c +','
                            + prod.CURRENT_BAL_GENERAL_FEES__c  +','
                            + ((prod.Commission_Rate__c != null) ? prod.Commission_Rate__c+'' : '')  +','+prod.Previous_Secondary_Account_Number__c+','+prod.Previous_Primary_Account_Number__c+','+prod.Collection_Agency__c+','+prod.First_Name__c+','
                +prod.Middle_Name__c+','+prod.Last_Name__c+','+prod.Primary_Debtor_AKA_Name__c+','+prod.Email_Address__c+','+prod.Employer_Name__c+','+prod.Address_Line1__c+','+prod.Address_Line2__c+','
                +prod.City__c+','+prod.State__c+','+prod.Zip_Code__c+','+prod.Country__c+','+prod.Date_of_Birth__c+','+prod.Phone_Home__c+','+prod.Phone_Work__c+','+prod.Phone_Other__c+','+prod.SIN__c+','
                +prod.Product_Status__c+','+prod.Codebtor_First_Name__c+','+prod.Codebtor_Middle_Name__c+','+prod.Codebtor_Last_Name__c+','+prod.Codebtor_Employer_Name__c+','+prod.Codebtor_Email_Address__c+','+prod.Codebtor_Phone_Home__c+','+prod.Codebtor_Phone_Work__c+','+prod.Codebtor_Phone_Other__c+','
                +prod.Codebtor_Address_Line1__c+','+prod.Codebtor_Address_Line2__c+','+prod.Codebtor_Zip_Code__c+','+prod.Codebtor_Country__c+','+prod.Codebtor_City__c+','+prod.Codebtor_State__c+','+prod.Codebtor_Date_of_Birth__c+','+prod.Assignment_Date__c+','+prod.Assignment_Accepted_Date__c+','
                +prod.Status_Changed_Date__c+','+prod.Stat_Barred_Date_External__c+','+prod.Originating_Creditor__c+','+prod.Open_Date__c+','+prod.Charged_Off_Date__c+','+prod.Last_Payment_Date__c+','+prod.Last_Payment_Amount__c+','+prod.Charged_Off_Amount__c+','+prod.Interest_Rate__c+','
                +prod.Pool_Name__c+','+prod.Fraud_Date__c+','+prod.Last_Payment_Date_Prior_to_CO__c+','+prod.Last_Payment_Amount_Prior_to_CO__c+','+prod.Account_Portfolio_Code__c+','+prod.Value_Tier_at_Time_of_Placement__c+','+prod.Number_Of_Open_Complaint__c+','+prod.Commission_Rate_at_Time_of_Placement__c+','
                +prod.Commission_Rate__c+','+prod.Settlement_Rate__c+','+prod.Current_Principal_Amount__c+','+prod.Current_Interest_Amount__c+','+prod.Extinguished_Status__c+','+prod.Extinguished_Date__c+','+prod.Placement_Status__c+' \n';
            csvString = csvString + recordStr;
        }
        return csvString;
    }
}