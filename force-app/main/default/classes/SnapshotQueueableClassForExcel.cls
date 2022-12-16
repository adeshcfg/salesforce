public class SnapshotQueueableClassForExcel implements Queueable, Database.AllowsCallouts{
    private List<Id> prodIds = new List<Id>();
    private Id placementId;
    private string finalStr;
    private String PRODUCT_SNAPSHOT = 'Product Snapshot';
      public string csvString = '';
    
    Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
    
    public SnapshotQueueableClassForExcel(List<Id> productIds, Id agencyId) {
        placementId = agencyId;
        prodIds = productIds; 
        
    }
    
    public void execute(QueueableContext context) {
        Placement__c placement = [SELECT Name, Agency_Name__c FROM Placement__c WHERE Id =: placementId LIMIT 1];
        //CSV Header
        string csvHeaders = getCSVHeader();
        //CSV record data content
        csvString = getCSVHeaderData(prodIds,placementId);  
        // CSV header and CSV Content
        finalStr = csvHeaders + csvString;
        //finalStr = finalStr.replaceAll('null','');
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+finalStr);
        Blob fileBlob = Blob.valueOf(finalStr);
        
        
        
        if(!Test.isRunningTest()) {
            parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Snapshot.csv', 'account');
            system.debug('parsedResponse in controller: '+parsedResponse);
        }else{
            parsedResponse.docUrl = 'Test';
            parsedResponse.docId = 'Test';
        }
       
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = PRODUCT_SNAPSHOT;
        docInfo.Document_URL__c = parsedResponse.docUrl;
        docInfo.Document_Name__c = placement.Agency_Name__c+' - '+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.xls';
        docInfo.Document_Id__c = parsedResponse.docId;
        docInfo.Placement_Agency__c = placementId;
        docInfo.Visibility__c = config.Document_Storage_Default_Visibility__c;
        insert docInfo;
        
        
        notificationCallAPI(placement.Name,docInfo.Document_Type__c, docInfo.Document_Name__c);
        
    }
    @future (callout=true)
    public static void notificationCallAPI(String placeId,String Type,String Title){
        if(!Test.isRunningTest()) {
        	PortalNotificationAPI.sendPaymentNotification(placeId,'Account','Account Allocations','','Product Snapshot Created.');
        }
    }
    
    //Query custom product records
    private static List<Product__c> productQuery(List<Id> productIds,Id placementId){
        return [SELECT Id,
                        Name,
                        Customer__c,
                        COLLECTION_AGENCY__C,
                        Agency_Company__c , //Collection_Agency_Name,
                        CURRENT_PRINCIPAL_BALANCE__C,
                        CURRENT_BALANCE__C,
                        INTEREST_RATE__C,    
                        CURRENT_INTEREST_AMOUNT__C,  
                        Commission_Rate__c, //Comission_Rate__c
                        Collection_Agency_Placement__c,Previous_Secondary_Account_Number__c,Previous_Primary_Account_Number__c,First_Name__c,Middle_Name__c,
                        Last_Name__c,Primary_Debtor_AKA_Name__c,Email_Address__c,Employer_Name__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Zip_Code__c,Country__c,Date_of_Birth__c,Phone_Home__c,
                        Phone_Work__c,Phone_Other__c,SIN__c,Product_Status__c,Codebtor_First_Name__c,Codebtor_Middle_Name__c,Codebtor_Last_Name__c,Codebtor_Employer_Name__c,Codebtor_Email_Address__c,
                        Codebtor_Phone_Home__c,Codebtor_Phone_Work__c,Codebtor_Phone_Other__c,Codebtor_Address_Line1__c,Codebtor_Address_Line2__c,Codebtor_Zip_Code__c,Codebtor_Country__c,Codebtor_City__c,
                        Codebtor_State__c,Codebtor_Date_of_Birth__c,Assignment_Date__c,Assignment_Accepted_Date__c,Status_Changed_Date__c,Stat_Barred_Date_External__c,Originating_Creditor__c,Data_Status_Description__c,
                        Open_Date__c,Charged_Off_Date__c,Last_Payment_Date__c,Last_Payment_Amount__c,Charged_Off_Amount__c,Pool_Name__c,Fraud_Date__c,Last_Payment_Date_Prior_to_CO__c,Last_Delinquency_Date__c,
                        Last_Payment_Amount_Prior_to_CO__c,Account_Portfolio_Code__c,Value_Tier_at_Time_of_Placement__c,Number_Of_Open_Complaint__c,Commission_Rate_at_Time_of_Placement__c,Codebtor_Alias_Name__c,
                        Current_Principal_Amount__c,Extinguished_Status__c,Extinguished_Date__c,Placement_Status__c,Settlement_Rate__c,Allocated_Amount_Principal__c,Allocated_Amount_Interest__c,Allocated_Amount_Fees__c,Total_of_Payments__c,
                        Placed_Settlement_Rate__c,Fee_Recovery__c,Legal_Entity__c,Statute_Status__c,Insolvency_On_File_Secondary_Debtor__c,Insolvency_On_File_Primary_Debtor__c,Credit_Score_Primary_Debtor__c, Credit_Score_Secondary_Debtor__c,
                        Current_Bal_Attorney_Fees__c,Current_Bal_Court_Fees__c,Current_Bal_General_Fees__c,Current_Bal_NSF_Fees__c,Current_Bal_Other_Fees__c,Product_Type__c,Pool_Name__r.Name,Pool_Name_Text__c,Portfolio_Name__c,Seller__c,Credit_Limit__c,
                		Company_Name__c,Customer_Language__c,Homeowner__c,Codebtor_SIN__c,Codebtor_Customer_Language__c,Insolvency_Date__c,Insolvency_Type__c,Deceased_Date__c,Co_Borrower_AKA_Name__c,Statute_Date__c,Guarantor_Cell_Phone__c,
                		Portfolio_Group_Name__c,Account_Purchasing_Entity_Value__c,Investment_Group__c,FDR_Account_ID__c,Insolvency_Discharge_Date__c,Value_Tier__c
                    FROM Product__c
                    WHERE Id IN: productIds AND Collection_Agency_Placement__c =: placementId];
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
        string csvHeaders = 'id'+'\t'+' placepool_id'+'\t'+'data_id'+'\t'+'purchasegroup_id'+'\t'+'purchase_companycode'+'\t'+'status_code'+'\t'
        +'pri_acctno'+'\t'+'sec_acctno'+'\t'+'type'+'\t'+'originator'+'\t'+'intrate'+'\t'+'term'+'\t'+'cycleid'+'\t'+'acctopen'+'\t'+'lastactivity'+'\t'+'lastactivityamt'+'\t'
        +'lastpayment'+'\t'+'lastpaymentamt'+'\t'+'delinquency'+'\t'+'chargeoff'+'\t'+'chargeoffamt'+'\t'+'bal_total'+'\t'+''+
        +'bal_principal'+'\t'+'bal_interest'+'\t'+'bal_fees_court'+'\t'+'bal_fees_attorney'+'\t'+'bal_fees_nsf'+'\t'+' bal_fees_general'+'\t'
        +'bal_fees_other'+'\t'+'lineofcredit'+'\t'+'pri_sin'+'\t'+'pri_taxid'+'\t'+'pri_dob'+'\t'+'pri_last'+'\t'+'pri_middle'+'\t'+'pri_first'+'\t'+'pri_company'+'\t'
        +'pri_email'+'\t'+'pri_add1'+'\t'+'pri_add2'+'\t'+'pri_municipality'+'\t'+'pri_province'+'\t'+'pri_postcode'+'\t'+'pri_country'+'\t'+'pri_hphone'+'\t'+'pri_wphone'+'\t'
        +'pri_driverlicense'+'\t'+'pri_language'+'\t'+'pri_homeowner'+'\t'+'pri_jobcode'+'\t'+'sec_sin'+'\t'+'sec_taxid'+'\t'+'sec_dob'+'\t'+'sec_last'+'\t'+'sec_middle'+'\t'
        +'sec_first'+'\t'+'sec_company'+'\t'+'sec_email'+'\t'+'sec_add1'+'\t'+'sec_add2'+'\t'+'sec_municipality'+'\t'+'sec_province'+'\t'+'sec_postcode'+'\t'+'sec_country'+'\t'
        +'sec_wphone'+'\t'+'sec_hphone'+'\t'+'sec_driverlicense'+'\t'+'sec_language'+'\t'+'sec_homeowner'+'\t'+'sec_jobcode'+'\t'+'sec_liable'+'\t'+'bk_insolvency'+'\t'+'bk_type'+'\t'+'bk_case'+'\t'+'bk_division'+'\t'
        +'dec_date'+'\t'+'fraud_date'+'\t'+'occurrence_date'+'\t'+'judgment_filed'+'\t'+'judgment_served'+'\t'+'judgment_writ'+'\t'+'judgment_date'+'\t'+'judgment_province'+'\t'+'judgment_amount'+'\t'
        +'judgment_bal_total'+'\t'+'judgment_bal_principal'+'\t'+'judgment_bal_interest'+'\t'+'judgment_bal_court'+'\t'+'judgment_bal_attorney'+'\t'+'judgment_bal_nsf'+'\t'
        +'judgment_bal_fees'+'\t'+'judgment_bal_other'+'\t'+'judgment_claim_amount'+'\t'+'judgment_intrate'+'\t'+'data_indicator'+'\t'+'data_indicator_01'+'\t'
        +'data_indicator_02'+'\t'+'club_id'+'\t'+'club_name'+'\t'+'data_bal_disbursement'+'\t'+'placedetail_fee_recovery'+'\t'+'bk_estate'+'\t'+'bk_annulled'+'\t'
        +'bk_reason'+'\t'+'trustee_name'+'\t'+'trustee_add1'+'\t'+'trustee_add2'+'\t'+'pri_alias'+'\t'+'sec_alias'+'\t'+'statute_date'+'\t'+'pri_cphone'+'\t'+'sec_cphone'+'\t'
        +'gp_cphone'+'\t'+'gs_cphone'+'\t'+'purchasegroup_name'+'\t'+'pri_cid'+'\t'+'entity_name'+'\t'+'sec_cid'+'\t'+'gp_cid'+'\t'+'gs_cid'+'\t'+'purchased_from'+'\t'+'Placement Date'+'\t'+'FDR Account ID'+'\t'+'Number of Open Complaint'+'\t'
        +'Last Payment Date Prior to CO'+'\t'+'Last Payment Amount Prior to CO'+'\t'+'Insolvency On File Primary Debtor'+'\t'+'Insolvency On File Secondary Debtor'+'\t'+'Extinguished Date'+'\t'+'Value Tier'+'\t'
        +'Value Tier at Time of Placement'+'\t'+'Placed Commission Rate (%)'+'\t'+'Current Commission Rate'+'\t'+'Placed Settlement Rate (%)'+'\t'+'Current Settlement Rate'+'\t'+'Insolvency Discharge Date'+'\t'+'Insolvency Refused Date \n'; 	
        return csvHeaders;
    }
    public static string getCSVHeaderData(List<Id> prodIds,Id placementId){
        string csvString = '';
        String FilingDate = '';
        String DateDebtorServed = '';
        String JudgmentDate = '';
        String JudgmentProvince = '';
        Decimal Allocated_Total = 0;
        Decimal current_Fees = 0;
        string isSettlementActive;
        List<id> ListJudgmentIds = new List<id>();
        set<Id> setCustomerID = new set<Id>();
        set<Id> setSellerID = new set<Id>();
        map<id,Account> mapAccount = new map<id,Account>();
        map<id,Account> mapAccountData = new map<id,Account>();
        map<id,id> mapProductAndJudgmentIds = new map<id,id>();
        system.debug('prodIds check**'+prodIds);
        List<Product__c> product = [SELECT Id, Name,Customer__c,Seller__c
                                    FROM Product__c 
                                    WHERE Id IN :prodIds ];
        for(Product__c prod : product){
            setCustomerID.add(prod.Customer__c);
            setSellerID.add(prod.Seller__c);
        }
        List<Settlement__c> newSettle = [SELECT Id, Status__c ,Product__r.Name
                                    FROM Settlement__c 
                                    WHERE (Product__c IN :prodIds AND Product__c != NULL)
                                    AND (Status__c != 'Rejected' AND Status__c  != 'Withdraw') ];
        
        for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c,Product__r.name,
                                                Judgment__r.Filing_Date__c 
                                               FROM Account_Judgment__c 
                                               WHERE Product__c IN :prodIds AND Product__c != NULL
                                              	AND Status__c= 'Active']){
             mapProductAndJudgmentIds.put(accJudgment.Product__c,accJudgment.Judgment__c);                                              
             ListJudgmentIds.add(accJudgment.Judgment__c);       
                                               }
        list<Judgment__c> judgment = new list<Judgment__c>();
        map<id,Judgment__c> mapJudgment = new map<id,Judgment__c>();
        if(!ListJudgmentIds.isEmpty()){
            judgment = [SELECT Id, Name,Filing_Date__c,Date_Debtor_Served__c,Judgment_Date__c,
                                    Judgment_Province__c
                                    FROM Judgment__c 
                                    WHERE Id IN :ListJudgmentIds];
            for(Judgment__c judgmentData : judgment){
                mapJudgment.put(judgmentData.id,judgmentData);
            }
        }
        
        
        for(Account Customer : [SELECT ID, Name, SF_ID__c,Insolvency_Annulled_Date__c,Insolvency_Refused_Date__c
                                     FROM Account
                                WHERE ID IN :setCustomerID]){
                                 mapAccount.put(Customer.id,Customer);   
                                }
        
        for(Account CustomerData : [SELECT ID, Name, SF_ID__c
                                     FROM Account
                                    WHERE ID IN :setSellerID]){
                                    mapAccountData.put(CustomerData.id,CustomerData);       
                                    }
        //system.debug('judgment***'+judgment);
        //system.debug('Filing_Date__c***'+accJudgment.Judgment__r.Filing_Date__c);
        // Query product and frame csv string
        for(Product__c prod: productQuery(prodIds,placementId)){
            Judgment__c judData = new Judgment__c();
            if(prod.Allocated_Amount_Principal__c != null){
               Allocated_Total += prod.Allocated_Amount_Principal__c;
            }
            if(prod.Allocated_Amount_Interest__c != null){
                Allocated_Total += prod.Allocated_Amount_Interest__c;
            }
            if(prod.Allocated_Amount_Fees__c != null){
                Allocated_Total += prod.Allocated_Amount_Fees__c;
            }
            if(!newSettle.isEmpty()){
                isSettlementActive = 'Yes';
            }else{
                isSettlementActive = 'No';
            }
            if(prod.Current_Bal_Attorney_Fees__c != null){
                current_Fees += prod.Current_Bal_Attorney_Fees__c;
            }
            if(prod.Current_Bal_Court_Fees__c != null){
                current_Fees += prod.Current_Bal_Court_Fees__c;
            }
            if(prod.Current_Bal_General_Fees__c != null){
                current_Fees += prod.Current_Bal_General_Fees__c;
            }
            if(prod.Current_Bal_NSF_Fees__c != null){
                current_Fees += prod.Current_Bal_NSF_Fees__c;
            }
            if(prod.Current_Bal_Other_Fees__c != null){
                current_Fees += prod.Current_Bal_Other_Fees__c;
            }
            
     		String openDate = '';
            if(prod.Open_Date__c != NULL){
                openDate = convertDateToString(prod.Open_Date__c);
            }
            String lastPaymentDate = '';
            if(prod.Last_Payment_Date__c != NULL){
                lastPaymentDate= convertDateToString(prod.Last_Payment_Date__c);
            }
            
            String delinquencyDate = '';
            if(prod.Last_Delinquency_Date__c != NULL){
                delinquencyDate = convertDateToString(prod.Last_Delinquency_Date__c);
            }
            
            String chargeoffDate = '';
            if(prod.Charged_Off_Date__c != NULL){
                chargeoffDate = convertDateToString(prod.Charged_Off_Date__c);
            }
            
            String pri_dob = '';
            if(prod.Date_of_Birth__c != NULL){
                pri_dob = convertDateToString(prod.Date_of_Birth__c);
            }
            
            String sec_dob = '';
            if(prod.Codebtor_Date_of_Birth__c != NULL){
                sec_dob = convertDateToString(prod.Codebtor_Date_of_Birth__c);
            }
            
            String insolvencyDate = '';
            if(prod.Insolvency_Date__c != NULL){
                insolvencyDate = convertDateToString(prod.Insolvency_Date__c);
            }
            
            String DeceasedDate = '';
            if(prod.Deceased_Date__c != NULL){
                DeceasedDate = convertDateToString(prod.Deceased_Date__c);
            }
            
            String ExtinguishedDate = '';
            if(prod.Extinguished_Date__c != NULL){
                ExtinguishedDate = convertDateToString(prod.Extinguished_Date__c);
            }
            
            String StatuteDate = '';
            if(prod.Statute_Date__c != NULL){
                StatuteDate = convertDateToString(prod.Statute_Date__c);
            }
            
            String InsolvencyDischargeDate = '';
            if(prod.Insolvency_Discharge_Date__c != NULL){
                InsolvencyDischargeDate = convertDateToString(prod.Insolvency_Discharge_Date__c);
            }
            
            String AssignmentDate = '';
            if(prod.Assignment_Date__c != NULL){
                AssignmentDate = convertDateToString(prod.Assignment_Date__c);
            }
            
            String LastPaymentDatePriortoCO = '';
            if(prod.Last_Payment_Date_Prior_to_CO__c != NULL){
                LastPaymentDatePriortoCO = convertDateToString(prod.Last_Payment_Date_Prior_to_CO__c);
            }
            
            FilingDate = '';
            if(judgment.size()>0){
                if(mapProductAndJudgmentIds.containsKey(prod.id) &&
                  mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Filing_Date__c != NULL){
                    FilingDate = convertDateToString(mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Filing_Date__c);
                }
            }
            
            DateDebtorServed = '';
            if(judgment.size()>0){
                if(mapProductAndJudgmentIds.containsKey(prod.id) &&
                   mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Date_Debtor_Served__c != NULL){
                       DateDebtorServed = convertDateToString(mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Date_Debtor_Served__c);
                   }
            }
            
            JudgmentDate = '';
            if(judgment.size()>0){
                if(mapProductAndJudgmentIds.containsKey(prod.id) &&
                   mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Judgment_Date__c != NULL){
                       JudgmentDate = convertDateToString(mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Judgment_Date__c);
                   }
            }
            
      		String InsolvencyAnnulledDate = '';
            if(prod.Customer__c!=null && mapAccount.get(prod.Customer__c).Insolvency_Annulled_Date__c != NULL){
                InsolvencyAnnulledDate = convertDateToString(mapAccount.get(prod.Customer__c).Insolvency_Annulled_Date__c);
            }
            
            String InsolvencyRefusedDate = '';
            if(prod.Customer__c!=null && mapAccount.get(prod.Customer__c).Insolvency_Refused_Date__c != NULL){
                InsolvencyRefusedDate = convertDateToString(mapAccount.get(prod.Customer__c).Insolvency_Refused_Date__c);
            }  
            /*String seller = '';
            if(prod.Seller__c!=null && mapAccountData.containsKey(prod.Seller__c) && mapAccountData.get(prod.Seller__c).Name != NULL){
                seller = mapAccountData.get(prod.Seller__c).Name;
            }*/
            
            JudgmentProvince = '';
            if(judgment.size()>0){
                if(mapProductAndJudgmentIds.containsKey(prod.id) &&
                   mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Judgment_Province__c != NULL){
                       JudgmentProvince = mapJudgment.get(mapProductAndJudgmentIds.get(prod.id)).Judgment_Province__c;
                   }
            }
            string PoolName =prod.Pool_Name__r.Name;
            system.debug('PoolName' +PoolName);
            String recordStr = prod.Collection_Agency__c +'\t'
                            +PoolName  +'\t'
                            + prod.Name +'\t'
                			+ '' +'\t'
                            + prod.Portfolio_Name__c+'\t'
                            + prod.Placement_Status__c+'\t'
                             +'\''+prod.Previous_Primary_Account_Number__c+'\t'+'\''+prod.Previous_Secondary_Account_Number__c+'\t'+prod.Product_Type__c+'\t'+prod.Originating_Creditor__c+'\t'+prod.Interest_Rate__c+'\t'+''+'\t'+''+'\t'+openDate+'\t'+''+'\t'+''+'\t'+lastPaymentDate+'\t'
                +prod.Last_Payment_Amount__c+'\t'+delinquencyDate+'\t'+chargeoffDate+'\t'+prod.Charged_Off_Amount__c+'\t'+prod.Current_Balance__c+'\t'+prod.Current_Principal_Balance__c+'\t'+prod.Current_Interest_Amount__c+'\t'+''+'\t'+''+'\t'
                +prod.Current_Bal_NSF_Fees__c+'\t'+''+'\t'+''+'\t'+prod.Credit_Limit__c+'\t'+prod.SIN__c+'\t'+''+'\t'+pri_dob+'\t'+prod.Last_Name__c+'\t'+prod.Middle_Name__c+'\t'+prod.First_Name__c+'\t'+prod.Company_Name__c+'\t'+prod.Email_Address__c+'\t'+prod.Address_Line1__c+'\t'+prod.Address_Line2__c+'\t'
                +prod.City__c+'\t'+prod.State__c+'\t'+prod.Zip_Code__c+'\t'+prod.Country__c+'\t'+prod.Phone_Home__c+'\t'+prod.Phone_Work__c+'\t'+''+'\t'+prod.Customer_Language__c+'\t'+prod.Homeowner__c+'\t'+''+'\t'+prod.Codebtor_SIN__c+'\t'+''+'\t'+sec_dob+'\t'
                +prod.Codebtor_Last_Name__c+'\t'+prod.Codebtor_Middle_Name__c+'\t'+prod.Codebtor_First_Name__c+'\t'+''+'\t'+prod.Codebtor_Email_Address__c+'\t'+prod.Codebtor_Address_Line1__c+'\t'+prod.Codebtor_Address_Line2__c+'\t'+prod.Codebtor_City__c+'\t'+prod.Codebtor_State__c+'\t'+prod.Codebtor_Zip_Code__c+'\t'+prod.Codebtor_Country__c+'\t'+prod.Codebtor_Phone_Work__c+'\t'+prod.Codebtor_Phone_Home__c+'\t'+''+'\t'
                +prod.Codebtor_Customer_Language__c+'\t'+''+'\t'+''+'\t'+''+'\t'+insolvencyDate+'\t'+prod.Insolvency_Type__c+'\t'+''+'\t'+''+'\t'+DeceasedDate+'\t'+''+'\t'+''+'\t'+FilingDate+'\t'+DateDebtorServed+'\t'+''+'\t'+JudgmentDate+'\t'+JudgmentProvince+'\t'
                +''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'+InsolvencyAnnulledDate+'\t'+''+'\t'+''+'\t'+''+'\t'+''+'\t'
                +prod.Primary_Debtor_AKA_Name__c+'\t'+prod.Co_Borrower_AKA_Name__c+'\t'+StatuteDate+'\t'+prod.Phone_Other__c+'\t'+prod.Codebtor_Phone_Other__c+'\t'+prod.Guarantor_Cell_Phone__c+'\t'+''+'\t'+prod.Portfolio_Group_Name__c+'\t'+''+'\t'+prod.Account_Purchasing_Entity_Value__c+'\t'+''+'\t'+''+'\t'+''+'\t'+prod.Investment_Group__c+'\t'+AssignmentDate+'\t'+prod.FDR_Account_ID__c+'\t'
                +prod.Number_Of_Open_Complaint__c+'\t'+LastPaymentDatePriortoCO+'\t'+prod.Last_Payment_Amount_Prior_to_CO__c+'\t'+prod.Insolvency_On_File_Primary_Debtor__c+'\t'+prod.Insolvency_On_File_Secondary_Debtor__c+'\t'+ExtinguishedDate+'\t'+prod.Value_Tier__c+'\t'+prod.Value_Tier_at_Time_of_Placement__c+'\t'+prod.Commission_Rate_at_Time_of_Placement__c+'\t'+prod.Commission_Rate__c+'\t'+prod.Placed_Settlement_Rate__c+'\t'+prod.Settlement_Rate__c+'\t'+InsolvencyDischargeDate+'\t'
                +InsolvencyRefusedDate+' \n';
    
            csvString = csvString + recordStr.replaceAll('null', '');
        }
        return csvString;
    }
    
    @testvisible
    private static String convertDateToString(DateTime dt){
        if(dt != null){
            //Date dte = dt.Date();
            //return String.valueof(dte.month()+'/'+dte.day()+'/'+dte.year());
            return (dt.formatGMT('MM-dd-yyyy'));
        }
        else{
            return '';
        }
    }
}