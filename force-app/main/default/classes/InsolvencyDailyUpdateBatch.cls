/*****************************************************************************************************************
* Author         : A5E Consultancy
* Created On     : 02 Nov 2023
* Description    : This file layout is used for DRN to send insolvency updates to an Insolvency Client and 
for the Client to send return detailed information to DRN.
							
******************************************************************************************************************/

public class InsolvencyDailyUpdateBatch implements Database.Batchable<sobject>, Database.Stateful, Database.AllowsCallouts{
   
    public static string headbody;
    public static string mainbody = '';
   	public static string trailerbody = '';
    public string finalHeaderBody = '';
    public Integer bodyCount = 1;
    public static map<String, CTB_File_Automation__mdt> mapCTBFileAutomation = CTB_File_Automation__mdt.getAll();
    public static map<String, CTB_File_Automation__mdt> mapCTBFileAuto = new map<String, CTB_File_Automation__mdt>();
    public static String memberType;
    public static String memberID;
        
    // Start Method
    public Database.Querylocator start(Database.BatchableContext BC) {
        List<String> listNames = new List<String>{'101010','010101'};
        return Database.getQueryLocator([ Select id,name,Insolvency_Received_Date__c,Insolvency__r.Insolvency_Type__c,Debtor_1_First_Name__c,
                                         Debtor_1_Last_Name__c,Province_Formula__c,Insolvency__r.Debtor_1_Mailing_Country__c,Debtor_1_Mailing_Postal_Code__c,
                                         Debtor_1_SIN__c,Debtor_1_Date_of_Birth__c,Insolvency__r.Insolvency_Date__c,Insolvency__r.name,Trustee_Company__c,
                                         Insolvency__r.Trustee__r.BillingStreet,Insolvency__r.Trustee__r.BillingCity,Insolvency__r.Trustee__r.BillingState,
                                         Insolvency__r.Trustee__r.BillingPostalCode,Debtor_1_Mailing_Street__c,Debtor_1_Mailing_City__c

                                         from Insolvency_Account__c 
                                         where Name IN: listNames AND
                                         Recordtype.name = 'Canadian Tire Insolvency Account' AND
                                         (Insolvency_Status__c = 'Annulled' OR
                                         Insolvency_Status__c = 'Refused' OR
                                         Insolvency_Status__c = 'Withdrawn') 
                                         ]
										);
        
    }
    
    //Execute Method
    public void execute(Database.BatchableContext BC, List<Insolvency_Account__c> scope) {
        for(CTB_File_Automation__mdt metaData : mapCTBFileAutomation.values()){
            mapCTBFileAuto.put(metaData.MasterLabel,metaData);
        }
        memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
        memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
        system.debug('memberType@@'+memberType); 
        system.debug('memberID@@'+memberID); 
		String bodyData = getCSVBodyData(scope);
        string csvHeaders = getCSVHeaderData();
        finalHeaderBody = csvHeaders + bodyData;
        bodyCount ++;
    }
    public static string getCSVHeaderData(){ 
        Integer BatchCount = 1;
        String createdDate = convertDateToString(System.today());
        system.debug('today date'+System.today());
        system.debug('createdDate date'+createdDate);
        
        String headerType = mapCTBFileAuto.get('Insolvency Daily Update').Header_Record_Type__c;
        system.debug('headerType'+headerType);
        
        String fileType = mapCTBFileAuto.get('Insolvency Daily Update').File_Type__c;
        String fileFormatIdenfier = mapCTBFileAuto.get('Insolvency Daily Update').File_Format_Identifier__c;
        system.debug('fileType@@'+fileType); 
        headbody = headerType +','+memberType+','+memberID+','+BatchCount+','+createdDate+','+Datetime.now().format('HH:mm:ss')+','+fileType+','+fileFormatIdenfier+' \n';
        BatchCount ++;
        return headbody;
    }
    public static string getCSVBodyData(List<Insolvency_Account__c> insolvencyAccData){ 
        for(Insolvency_Account__c insolAccData : insolvencyAccData){
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
            /*if(insolAccData.CTB_Date_of_Birth__c!=null){
                dateOfBirth = insolAccData.CTB_Date_of_Birth__c;
            }else{*/
                dateOfBirth = convertDateToString(insolAccData.Debtor_1_Date_of_Birth__c);
           // }
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
		   String detailRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Detail_Record_Type__c;
           String productDesc = mapCTBFileAuto.get('Insolvency Daily Update').Product_Description__c;
           String productID = mapCTBFileAuto.get('Insolvency Daily Update').DRN_Debt_Product_ID__c;
           system.debug('productID@@'+productID);  
            mainbody += detailRecordType+','+memberType+','+memberID+','+openDate+','+insolAccData.name+','+insolAccData.Insolvency__r.Insolvency_Type__c+','+
                productDesc+','+DebtorFirstName+','+DebtorLaseName+','+addressLine1+','+''+','+DebtorMailingCity+','+province+','+
                mailingCountry+','+mailingPostalCode+','+SIN+','+dateOfBirth+','+insolvencyDate+','+estateNumber+','+'1'+','+trusteeCompany+','+trusteeAddress+','+''+','+
                trusteeCity+','+trusteeState+','+trusteePostalCode+','+productID+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+','+''+' \n';
        }
    	
        return mainbody;
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
    // Finish Method to generate TAILER record
    public void finish(Database.BatchableContext BC) {
        system.debug('finalHeaderBody@@'+finalHeaderBody);
        system.debug('finalHeaderBody length@@'+finalHeaderBody.length());
        system.debug('trailerbody@@'+trailerbody);
        system.debug('bodyCount@@'+bodyCount);
       Integer finalrecordCount = 2 + bodyCount;
       for(CTB_File_Automation__mdt metaData : mapCTBFileAutomation.values()){
            mapCTBFileAuto.put(metaData.MasterLabel,metaData);
       }
       String trailerRecordType = mapCTBFileAuto.get('Insolvency Daily Update').Trailer_Record_Type__c;
       memberType = mapCTBFileAuto.get('Insolvency Daily Update').Member_Type__c;
       memberID = mapCTBFileAuto.get('Insolvency Daily Update').Member_ID__c;
       system.debug('trailerRecordType@@'+trailerRecordType); 
       String createdDate = convertDateToString(System.today()); 
       trailerbody = trailerRecordType+','+memberType+','+memberID+','+finalrecordCount+','+bodyCount+','+createdDate+','+Datetime.now().format('HH:mm:ss')+' \n';
       String FinalData = finalHeaderBody + trailerbody;
        
       DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+FinalData);
        Blob fileBlob = Blob.valueOf(FinalData);

        if(!Test.isRunningTest()) {
            parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.csv', 'account');
            system.debug('parsedResponse in controller: '+parsedResponse);
        }else{
            parsedResponse.docUrl = 'Test';
            parsedResponse.docId = 'Test';
        }
       
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = 'Insolvency Daily Update';
        docInfo.Work_Assignment__c = 'a3LS0000000h6NCMAY';    
        docInfo.Document_URL__c = parsedResponse.docUrl;
        docInfo.Document_Extension__c = 'csv';
        docInfo.Document_Name__c = 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.csv';
        docInfo.Document_Id__c = parsedResponse.docId;
        docInfo.Visibility__c = 'CFG Only';
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        insert docInfo;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
}