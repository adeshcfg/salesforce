/*****************************************************************************************************************
* Author         : A5E Consultancy
* Created On     : 02 Nov 2023
* Description    : This file layout is used for DRN to send insolvency updates to an Insolvency Client and 
for the Client to send return detailed information to DRN.
                            
******************************************************************************************************************/

public class CTBFileGenerator implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts{
    public static map<String, CTB_File_Automation__mdt> mapCTBFileAutomation = CTB_File_Automation__mdt.getAll();
    public map<String, CTB_File_Automation__mdt> mapCTBFileAuto = new map<String, CTB_File_Automation__mdt>();
    public static Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    public String CTBBatchName;
    public static final String recordType = 'Canadian_Tire_Insolvency_Account';
    String FinalData = '';
    List<sObject> queryData = new List<sObject>();
    String createdDate = '';
    public String dateformate = '';
    public static string headbody = '';
    public static string trailerbody = '';
    Integer countVariable=0;
    Integer tejalcounter=0;
    
    public CTBFileGenerator(String batchName){
        CTBBatchName = batchName;
        
        for(CTB_File_Automation__mdt metaData : mapCTBFileAutomation.values()){
            mapCTBFileAuto.put(metaData.MasterLabel,metaData);
        }
        createdDate = convertDateToString(System.today());
        dateformate = Datetime.now().format('HH:mm:ss');
    }    
    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        //List<String> listNames = new List<String>{'101010','010101'};
        String query = '';
        
        if(CTBBatchName == System.Label.CTB_Insolvency_Account){
            query = ' Select id,name,Insolvency_Received_Date__c,Insolvency__r.Insolvency_Type__c,Debtor_1_First_Name__c,'+
                'Debtor_1_Last_Name__c,Province_Formula__c,Insolvency__r.Debtor_1_Mailing_Country__c,Debtor_1_Mailing_Postal_Code__c,'+
                'Debtor_1_SIN__c,Debtor_1_Date_of_Birth__c,Insolvency__r.Insolvency_Date__c,Insolvency__r.name,Trustee_Company__c,Correlation_ID__c,'+
                'Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Debtor_1_First_Name__c,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,CTB_Date_of_Birth__c,'+
                'Insolvency__r.Trustee__r.BillingPostalCode,Debtor_1_Mailing_Street__c,CTB_Status_Update_Code__c,Insolvency__r.Debtor_1_Middle_Name__c,Debtor_1_Mailing_City__c '+
                'FROM Insolvency_Account__c '+
                'WHERE '+
                'RecordType.developerName = :recordType AND '+
                '(Insolvency_Status__c = \'For Owner Review\' OR '+
                'Insolvency_Status__c = \'Discharged\' OR '+
                'Insolvency_Status__c = \'Annulled\'OR '+
                'Insolvency_Status__c = \'Withdrawn\'OR '+  
                'Insolvency_Status__c = \'Refused\') AND '+
                'Insolvency_Sub_Status__c = \'Pending File\'';                                         
        }
        if(CTBBatchName == System.Label.CTB_Payment){
            query = ' Select id,name,Account_Number__c,Payment_Posting_Date__c,Transaction_Id__c,Payment_Type__c,Payment_Amount__c,'+
                'Remitted_Date__c,Remitted_Cheque_Number__c,Estate_Number__c '+
                'FROM Insolvency_Payment__c '+
                'WHERE '+
                'RecordType.developerName = :recordType AND ';                                         
        }
        
        system.debug('query&&'+query);
        return Database.getQueryLocator(query);
    }
    
    //Execute Method
    public void execute(Database.BatchableContext BC, List<sObject> query) {
        if(CTBBatchName == System.Label.CTB_Insolvency_Account){
            queryData = query;
            wrapperClass batchCnt = new wrapperClass();
            batchCnt = getInsolvencyAccountFile(mapCTBFileAuto,query,createdDate,dateformate);
            FinalData += batchCnt.finalDetailBody;
            countVariable += batchCnt.batchCountDetail;
        }
        if(CTBBatchName == System.Label.CTB_Payment){
            queryData = query;
            wrapperClass batchCnt = new wrapperClass();
            batchCnt = getInsolvencyPaymentFile(mapCTBFileAuto,query,createdDate,dateformate);
            FinalData += batchCnt.finalDetailBody;
            countVariable += batchCnt.batchCountDetail;
        }
    }
    

    public static wrapperClass getInsolvencyAccountFile (map<String, CTB_File_Automation__mdt> mapCTBFileAuto , List<Insolvency_Account__c> insolvencyAccData,String createdDate, String dateformate) {
        Integer counter=0;
        string mainbody = '';
        List<ID> listAccIds = new List<ID>();
        List<ID> listAccSuccessIds = new List<ID>();
        wrapperClass batchCntData = new wrapperClass();
        Map<id,Insolvency_Account__c> insolvAcctErrorListMap = new Map<id,Insolvency_Account__c>(); 
        
        try{
            
            String headerType = mapCTBFileAuto.get('Insolvency Daily Update').Header_Record_Type__c;
            String fileType = mapCTBFileAuto.get('Insolvency Daily Update').File_Type__c;
            String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
            String memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
            String memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
            String detailRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Detail_Record_Type__c;
            String productDesc = mapCTBFileAuto.get('Insolvency Daily Update').Product_Description__c;
            String productID = mapCTBFileAuto.get('Insolvency Daily Update').DRN_Debt_Product_ID__c;
            String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
            String DRNTrusteeID = mapCTBFileAuto.get('Insolvency Daily Update').DRN_Trustee_ID__c;
            Integer batchCount = Integer.valueof(config.Insolvency_Account_Batch_Count__c);
            
            
            /*******************************************Body Data*************************************************/
            for(Insolvency_Account__c insolAccData : insolvencyAccData){
                //If mandatory fields are not null then only build CSV file
                if(headerType != NULL && memberType != NULL && memberID != NULL && batchCount != NULL && createdDate != NULL && fileType != NULL && fileFormatIdenfier != NULL
                   && detailRecordType != NULL && insolAccData.Insolvency_Received_Date__c !=null && insolAccData.name !=null && insolAccData.Insolvency__r.Insolvency_Type__c !=null
                   && productDesc != NULL && (insolAccData.Insolvency__r.Debtor_1_First_Name__c !=null || insolAccData.Insolvency__r.Debtor_1_Middle_Name__c !=null || insolAccData.Debtor_1_First_Name__c !=null) 
                   && insolAccData.Debtor_1_Last_Name__c != NULL && insolAccData.Debtor_1_Mailing_Street__c != null && insolAccData.Debtor_1_Mailing_City__c !=null && insolAccData.Province_Formula__c !=null
                   && insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c != NULL && insolAccData.Insolvency__r.Insolvency_Date__c!=null && insolAccData.Insolvency__r.name!=null && DRNTrusteeID != null
                   && insolAccData.Trustee_Company__c!=null && insolAccData.Insolvency__r.Trustee__r.BillingStreet!=null && insolAccData.Insolvency__r.Trustee__r.BillingCity!=null && insolAccData.Insolvency__r.Trustee__r.BillingState!=null
                   && insolAccData.Insolvency__r.Trustee__r.BillingPostalCode!=null && insolAccData.Correlation_ID__c!=null && trailerRecordType != NULL){
                       String DebtorFirstName = '';
                       if(insolAccData.Debtor_1_First_Name__c!=null){
                           if(insolAccData.Debtor_1_First_Name__c.length() > 40){
                               DebtorFirstName =insolAccData.Debtor_1_First_Name__c.subString(0,40);
                           }else{
                               DebtorFirstName = insolAccData.Debtor_1_First_Name__c;
                           }
                       }
                       String DebtorLaseName = '';
                       if(insolAccData.Debtor_1_Last_Name__c!=null){
                           if(insolAccData.Debtor_1_Last_Name__c.length() > 40){
                               DebtorLaseName =insolAccData.Debtor_1_Last_Name__c.subString(0,40);
                           }else{
                               DebtorLaseName = insolAccData.Debtor_1_Last_Name__c;
                           }
                       }
                       String addressLine1 = '';
                       if(insolAccData.Debtor_1_Mailing_Street__c!=null){
                           if(insolAccData.Debtor_1_Mailing_Street__c.length() > 80){
                               addressLine1 =insolAccData.Debtor_1_Mailing_Street__c.subString(0,80);
                           }else{
                               addressLine1 = insolAccData.Debtor_1_Mailing_Street__c;
                           }
                       }
                       String DebtorMailingCity = '';
                       if(insolAccData.Debtor_1_Mailing_City__c!=null){
                           if(insolAccData.Debtor_1_Mailing_City__c.length() > 40){
                               DebtorMailingCity =insolAccData.Debtor_1_Mailing_City__c.subString(0,40);
                           }else{
                               DebtorMailingCity = insolAccData.Debtor_1_Mailing_City__c;
                           }
                       }   
                       String province = '';
                       if(insolAccData.Province_Formula__c!=null){
                           province = CustomerProcessingBatchHelper.getProvinceCode(insolAccData.Province_Formula__c);
                       }
                       String mailingCountry = '';
                       if(insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c!=null){
                           mailingCountry = CustomerProcessingBatchHelper.getMailingCountry(insolAccData.Insolvency__r.Debtor_1_Mailing_Country__c); 
                       }
                       String mailingPostalCode = '';
                       if(insolAccData.Debtor_1_Mailing_Postal_Code__c!=null){
                           if(insolAccData.Debtor_1_Mailing_Postal_Code__c.length() > 15){
                               mailingPostalCode =insolAccData.Debtor_1_Mailing_Postal_Code__c.subString(0,15);
                           }else{
                               mailingPostalCode = insolAccData.Debtor_1_Mailing_Postal_Code__c;
                           }
                       }
                       String SIN = '';
                       if(insolAccData.Debtor_1_SIN__c!=null){
                           if(insolAccData.Debtor_1_SIN__c.length() > 50){
                               SIN =insolAccData.Debtor_1_SIN__c.subString(0,50);
                           }else{
                               SIN = insolAccData.Debtor_1_SIN__c;
                           }
                       }
                       String dateOfBirth = '';
                       if(insolAccData.CTB_Date_of_Birth__c!=null){
                           dateOfBirth = convertDateToString(insolAccData.CTB_Date_of_Birth__c);
                       }else{
                           dateOfBirth = convertDateToString(insolAccData.Debtor_1_Date_of_Birth__c);
                       }
                       String insolvencyDate = '';
                       if(insolAccData.Insolvency__r.Insolvency_Date__c!=null){
                           insolvencyDate = convertDateToString(insolAccData.Insolvency__r.Insolvency_Date__c);
                       }
                       String openDate = '';
                       if(insolAccData.Insolvency_Received_Date__c!=null){
                           openDate = convertDateToString(insolAccData.Insolvency_Received_Date__c);
                       }
                       String estateNumber = '';
                       if(insolAccData.Insolvency__r.name!=null){
                           estateNumber = insolAccData.Insolvency__r.name;
                       }
                       String trusteeCompany = '';
                       if(insolAccData.Trustee_Company__c!=null){
                           if(insolAccData.Trustee_Company__c.length() > 80){
                               trusteeCompany =insolAccData.Trustee_Company__c.subString(0,80);
                           }else{
                               trusteeCompany = insolAccData.Trustee_Company__c;
                           }
                       }
                       String trusteeAddress = '';
                       if(insolAccData.Insolvency__r.Trustee__r.BillingStreet!=null){
                           if(String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet).length() > 80){
                               trusteeAddress =String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet).subString(0,80);
                           }else{
                               trusteeAddress = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingStreet);
                           }
                           trusteeAddress = trusteeAddress.escapeUnicode();
                       }
                       String trusteeCity = '';
                       if(insolAccData.Insolvency__r.Trustee__r.BillingCity!=null){
                           if(String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity).length() > 50){
                               trusteeCity =String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity).subString(0,50);
                           }else{
                               trusteeCity = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingCity);
                           }
                       }
                       String trusteeState = '';
                       if(insolAccData.Insolvency__r.Trustee__r.BillingState!=null){
                           if(String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState).length() > 2){
                               trusteeState =String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState).subString(0,2);
                           }else{
                               trusteeState = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingState);
                           }
                       }
                       String trusteePostalCode = '';
                       if(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode!=null){
                           if(String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode).length() > 15){
                               trusteePostalCode =String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode).subString(0,15);
                           }else{
                               trusteePostalCode = String.valueOf(insolAccData.Insolvency__r.Trustee__r.BillingPostalCode);
                           }
                       }
                        
                       mainbody += detailRecordType+','+memberType+','+memberID+','+openDate+','+insolAccData.name+','+insolAccData.Insolvency__r.Insolvency_Type__c+','+
                           productDesc+','+DebtorFirstName+','+DebtorLaseName+','+addressLine1+','+''+','+DebtorMailingCity+','+province+','+
                           mailingCountry+','+mailingPostalCode+','+SIN+','+dateOfBirth+','+insolvencyDate+','+estateNumber+','+DRNTrusteeID+','+trusteeCompany+','+trusteeAddress+','+''+','+
                           trusteeCity+','+trusteeState+','+trusteePostalCode+','+insolAccData.Correlation_ID__c+insolAccData.CTB_Status_Update_Code__c+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+' \n';
                   counter ++;
                       
                   }
                else{
                    //If mandatory fields are null then dont build CSV file for this record
                    listAccIds.add(insolAccData.id);
                    system.debug('listAccIds***'+listAccIds);
                    
                    //update insolvency sub status to "File Error Parsing Record" on insolvency account records.
                    Insolvency_Account__c insolAccError = new Insolvency_Account__c();
                    if(insolAccData.id != NULL){
                        insolAccError.id = insolAccData.id;
                        insolAccError.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                        insolvAcctErrorListMap.put(insolAccError.id,insolAccError); 
                    }
                }
                
            }
            /*******************************************Body Data Ends*************************************************/
            
            try{
                config.Insolvency_Account_Batch_Count__c = config.Insolvency_Account_Batch_Count__c + 1;
				Update config; 
                
                if(insolvAcctErrorListMap != NULL){
                    update insolvAcctErrorListMap.values();
                } 
            }catch(DMLException dmlEx){
                system.debug('Exception msg@@'+dmlEx.getStackTraceString());
                exceptionHandling(dmlEx.getDMLMessage(0),dmlEx.getStackTraceString(),dmlEx.getDmlId(0)); 
                CFG_EmailNotification.apiFailedEmailNotify(dmlEx.getDMLMessage(0),'Record update Failed');
            }
            
        }
        catch(Exception ex){
            system.debug('Exception msg**'+ex.getStackTraceString());
            exceptionHandling(ex.getMessage(),ex.getStackTraceString(),null);
            CFG_EmailNotification.apiFailedEmailNotify(ex.getMessage(),'CTB Automation Process Failed');
        }

        batchCntData.finalDetailBody = mainbody;
        batchCntData.batchCountDetail = counter;
        return batchCntData;
    }
    
    public static wrapperClass getInsolvencyPaymentFile (map<String, CTB_File_Automation__mdt> mapCTBFileAuto , List<Insolvency_Payment__c> insolvencyPayData,String createdDate, String dateformate ) {
    
        string mainbody = '';
        Integer counter=0;
        wrapperClass batchCntData = new wrapperClass();
        
        try{
            String headerType = mapCTBFileAuto.get('Insolvency Payment Update   ').Header_Record_Type__c;
            String fileType = mapCTBFileAuto.get('Insolvency Payment Update ').File_Type__c;
            String memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
            String memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
            String detailRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Detail_Record_Type__c;
            String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
            String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
            Integer batchCount = Integer.valueof(config.Payment_Batch_Count__c);
            
            for(Insolvency_Payment__c insolPayData : insolvencyPayData){
                if(headerType != NULL && memberType != NULL && memberID != NULL && batchCount != NULL && createdDate != NULL && fileType != NULL && fileFormatIdenfier != NULL
                   && detailRecordType != NULL && insolPayData.Account_Number__c != NULL && insolPayData.Payment_Posting_Date__c != NULL && insolPayData.Payment_Type__c != NULL
                   && insolPayData.Payment_Amount__c != NULL && insolPayData.Remitted_Date__c != NULL && insolPayData.Remitted_Cheque_Number__c != NULL && trailerRecordType != NULL){
                       String paymentPostingDate = '';
                       if(insolPayData.Payment_Posting_Date__c!=null){
                           paymentPostingDate = convertDateToString(insolPayData.Payment_Posting_Date__c);
                       }
                       String remittedDate = '';
                       if(insolPayData.Remitted_Date__c!=null){
                           remittedDate = convertDateToString(insolPayData.Remitted_Date__c);
                       }
                       
                       mainbody += detailRecordType+','+memberType+','+memberID+','+insolPayData.Account_Number__c+','+''+','+''+','+paymentPostingDate+','+insolPayData.Transaction_Id__c+','+
                           insolPayData.Payment_Type__c+','+insolPayData.Payment_Amount__c+','+remittedDate+','+insolPayData.Remitted_Cheque_Number__c+','+insolPayData.Estate_Number__c+' \n';
                    counter ++;
                   }
                else{
                    
                }
            }
            try{
                config.Payment_Batch_Count__c = config.Payment_Batch_Count__c + 1;
				Update config; 
                 
            }catch(DMLException dmlEx){
                system.debug('Exception msg@@'+dmlEx.getStackTraceString());
                exceptionHandling(dmlEx.getDMLMessage(0),dmlEx.getStackTraceString(),dmlEx.getDmlId(0)); 
                CFG_EmailNotification.apiFailedEmailNotify(dmlEx.getDMLMessage(0),'Record update Failed');
            }
        }catch(Exception ex){
            system.debug('Exception msg**'+ex.getStackTraceString());
            exceptionHandling(ex.getMessage(),ex.getStackTraceString(),null);
            CFG_EmailNotification.apiFailedEmailNotify(ex.getMessage(),'CTB Payment Automation Process Failed');
        }
        
        batchCntData.finalDetailBody = mainbody;
        batchCntData.batchCountDetail = counter;
        return batchCntData;
    }
    
    @testvisible
    private static String convertDateToString(DateTime dt){
        if(dt != null){
            return (dt.formatGMT('MM/dd/yyyy'));
        }
        else{
            return '';
        }
    }
    

    public void finish(Database.BatchableContext BC) {
        try{
            String mainFinalData = '';
            if(CTBBatchName == System.Label.CTB_Insolvency_Account){
                Integer finalrecordCount = 2 + countVariable;
                String headerType = mapCTBFileAuto.get('Insolvency Daily Update').Header_Record_Type__c;
                String memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
                String memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
                Integer batchCount = Integer.valueof(config.Insolvency_Account_Batch_Count__c);
                String fileType = mapCTBFileAuto.get('Insolvency Daily Update').File_Type__c;
                String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
                String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
                
                headbody = headerType +','+memberType+','+memberID+','+batchCount+','+createdDate+','+dateformate+','+fileType+','+fileFormatIdenfier+' \n';
                trailerbody = trailerRecordType+','+memberType+','+memberID+','+finalrecordCount+','+countVariable+','+createdDate+','+dateformate+' \n';
                mainFinalData = headbody + FinalData + trailerbody; 
            }
            if(CTBBatchName == System.Label.CTB_Insolvency_Account){
                Integer finalrecordCount = 2 + countVariable;
                String headerType = mapCTBFileAuto.get('Insolvency Payment Update   ').Header_Record_Type__c;
                String memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
                String memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
                Integer batchCount = Integer.valueof(config.Insolvency_Account_Batch_Count__c);
                String fileType = mapCTBFileAuto.get('Insolvency Payment Update ').File_Type__c;
                String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
                String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
                
                headbody = headerType +','+memberType+','+memberID+','+batchCount+','+createdDate+','+Datetime.now().format('HH:mm:ss')+','+fileType+','+fileFormatIdenfier+' \n';
                trailerbody = trailerRecordType+','+memberType+','+memberID+','+finalrecordCount+','+countVariable+','+createdDate+','+Datetime.now().format('HH:mm:ss')+' \n';
                mainFinalData = headbody + FinalData + trailerbody; 
            }
            Blob fileBlob = Blob.valueOf(mainFinalData);
            /*String Filename = 'DRN_DailyUpdate_'+createdDate+dateformate;
            // Create Content Version
            ContentVersion contentVersionData = new ContentVersion();
            contentVersionData.ContentLocation = 'S';
            contentVersionData.VersionData = Blob.valueof(FinalData);
            contentVersionData.Title = 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss');
            contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
            insert contentVersionData;
            
            System.enqueueJob(new CTBApiCalloutsQueueable(contentVersionData.id,queryData,CTBBatchName,Filename));*/
            
            DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
            
            if(!Test.isRunningTest()) {
                parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.csv', 'account');
                system.debug('parsedResponse in controller: '+parsedResponse);
            }else{
                parsedResponse.docUrl = 'Test';
                parsedResponse.docId = 'Test';
            }
            //To DO : We do not need to create Document Storage and in place of it we have to update each insolvency account with CTB Update File Name and CTB Update File Timestamp on rach insolvency account records.
            Document_Storage__c docInfo = new Document_Storage__c();
            docInfo.Document_Type__c = 'Insolvency Daily Update';
            docInfo.Work_Assignment__c = 'a3LS0000000h6NCMAY';    
            docInfo.Document_URL__c = parsedResponse.docUrl;
            docInfo.Document_Extension__c = 'csv';
            docInfo.Document_Name__c = 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.csv';
            docInfo.Document_Id__c = parsedResponse.docId;
            docInfo.File_Processing_Status__c = 'Pending';
            docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            insert docInfo;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        }catch(Exception ex){
            system.debug('Exception msg&&'+ex.getStackTraceString());
            CFG_EmailNotification.apiFailedEmailNotify(ex.getMessage(),'content Version Creation');
        }
    }
    
    public static void exceptionHandling(string errorMsg,string stackTrace,string dataId){
        system.debug('inside exceptionHandling method');
        List<Insolvency_Error__c> listInsolErrors = new List<Insolvency_Error__c>();
        Insolvency_Error__c insolErrorData = New Insolvency_Error__c();
        if(stackTrace != NULL){
            insolErrorData.Error__c = 'Record failed due to'+' '+errorMsg+' '+stackTrace;
        }else{
            insolErrorData.Error__c = 'Record failed due to'+' '+errorMsg;
        }
        if(dataId != NULL){
            insolErrorData.Insolvency_Account__c = dataId;
        }
        listInsolErrors.add(insolErrorData);
        insert listInsolErrors;
    }
    
    public class wrapperClass{
        public Integer batchCountDetail{get;set;}
        public string finalDetailBody{get;set;}
    }
}