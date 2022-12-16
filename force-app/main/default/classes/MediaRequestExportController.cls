/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class for Media request csv file export
*  @author : A5E Consulting
*  @date : 31/03/2022

*************************************************************************************************/
public class MediaRequestExportController {
    public String documentID {get;set;}
    public String blobContents {get;set;}
    public String contentType {get;set;}
    public list<Work_Assignment__c> listWorkAssg;      
    public String ERROR_MSG {get;set;}
	public boolean DisableExportBtn{get;set;}
    public list<Document_Storage__c> listDocStorage {get;set;}
    public Blob pdfBlob{get;set;}
    //public String test1{get;set;}
    String headerCSV ;
    
   public MediaRequestExportController(ApexPages.StandardController stdController){
        listWorkAssg = [Select id,Name,Status__c,Original_Creditor__c,Product__r.Name,Last_Name__c,
                        First_Name__c,Loan_Number_Primary__c,AssetID_Secondary__c,Account_Type__c,
                        Application__c,Statements__c,Note_Lines__c,Cardholder_Agreement__c,Check_Copy__c,
                        Sale_Date__c,Priority__c,End_Year__c,Start_Year__c,End_Month__c,Start_Month__c,Charge_Off_Date__c,Charge_Off_Statement__c,Last_Payment_Statement__c,
                        Drivers_License__c,PPSA_Registration__c,Repossession_And_Auction_Documents__c,Other__c,Other_Media_Request__c,Latest_Comment__c
                        from Work_Assignment__c Where Status__c = 'Requested' AND Purpose__c = 'Media Request' 
                        AND ( RecordType.Name = 'CFG Media'  OR RecordType.Name = 'Agency Media' )]; 
       
       system.debug('listWorkAssg '+listWorkAssg);
       if(listWorkAssg.isEmpty()){
            ERROR_MSG = '&nbsp;&nbsp;No Media Request Records to Export';
            DisableExportBtn = true;
        }
       listDocStorage =  [Select id,Name,Media_Request__c,File_Processing_Date__c,
                          Document_Type__c,Creator__c,Document_Id__c,Document_URL__c
                         from Document_Storage__c Where Media_Request__c = TRUE ORDER BY Name DESC LIMIT 8];
    }
    
   
    public PageReference downloadFile(){        
       system.debug('Inside download');       
       for(Document_Storage__c docstorage : listDocStorage){          
        //  getDocument(docstorage.Document_Id__c);
       }
        return null;
    } 
    
    public  PageReference getDocumentInfo(){
        DocumentDetails docDetails = DocumentAPIClient.getDocumentInfo(documentId);
        system.debug('docDetails: '+docDetails);
        if(docDetails.document != NULL){
            blobContents = EncodingUtil.base64Encode(docDetails.document);
            contentType = docDetails.contentType;
        }
        else{
            blobContents ='';
        }
        system.debug('docDetails.fileString: '+docDetails.fileString); 
        return null;        
    }
   
    public  PageReference createCSV(){
     
      // String headerCSV ='';
       headerCSV = 'WorkAssignment Name' + ','
            + 'Seller'+',' 
            + 'Debt#' +','                
            + 'Sale Date' +','
            + 'Last Name' +',' 
            + 'First Name' +',' 
            + 'Acct#' +',' 
            + 'AssetID Secondary' +',' 
            + 'Account Type' +','
            + 'Charge Off Date' +',' 
            + 'Application' +',' 
            + 'Statements' +',' 
            + 'Start Date' +','            
            + 'End Date' +','            
            + 'Note Lines' +',' 
            + 'Cardholder Agreement' +',' 
            + 'Check Copy' +','
            + 'Drivers License' +','
            + 'PPSA Registration' +','
            + 'Repossession And Auction Documents' +','
            + 'Other' +','
            + 'Other Media Request' +','
            + 'Charge Off Statement' +','
            + 'Last Payment Statement' +','
            + 'Comments' +','
           
           // + 'Normal/High' +','
            + '' +''
            + '\n'; 
        system.debug('listWorkAssg'+listWorkAssg);
      //  list<Work_Assignment__c> listWorkAssg = fecthMediaRequestRecords();
        for(Work_Assignment__c workassh : listWorkAssg){
              String saleDate='';
              String chargeOffDate='';
              saleDate = convertDateToString(workassh.Sale_Date__c);
              chargeOffDate = convertDateToString(workassh.Charge_Off_Date__c);
            //  String statementStartDate='';
            //  String statementEndDate='';
          
            String application ='';
            String statement ='';
            String noteLines ='';
            String cardHolderAgreement ='';
            String CheckCopy ='';
            String DriversLicense ='';
            String PPSARegistration ='';
            String RepossessionAndAuctionDocuments ='';
            String ChargeOffStatement ='';
            String LastPaymentStatement ='';
            String Other ='';
            
            if(workassh.Application__c == true){
                application = 'Yes';
            }else{
                application = 'No';
            }
            if(workassh.Statements__c == true){
                statement = 'Yes';
            }else{
                statement = 'No';
            }
            if(workassh.Note_Lines__c == true){
                noteLines = 'Yes';
            }else{
                noteLines = 'No';
            }
            if(workassh.Cardholder_Agreement__c == true){
                cardHolderAgreement = 'Yes';
            }else{
                cardHolderAgreement = 'No';
            }
            if(workassh.Check_Copy__c == true){
                CheckCopy = 'Yes';
            }else{
                CheckCopy = 'No';
            }
            if(workassh.Drivers_License__c == true){
                DriversLicense = 'Yes';
            }else{
                DriversLicense = 'No';
            }
            if(workassh.PPSA_Registration__c == true){
                PPSARegistration = 'Yes';
            }else{
                PPSARegistration = 'No';
            }
            if(workassh.Repossession_And_Auction_Documents__c == true){
                RepossessionAndAuctionDocuments = 'Yes';
            }else{
                RepossessionAndAuctionDocuments = 'No';
            }
            if(workassh.Charge_Off_Statement__c == true){
                ChargeOffStatement = 'Yes';
            }else{
                ChargeOffStatement = 'No';
            }
            if(workassh.Last_Payment_Statement__c == true){
                LastPaymentStatement = 'Yes';
            }else{
                LastPaymentStatement = 'No';
            }
            if(workassh.Other__c == true){
                Other = 'Yes';
            }else{
                Other = 'No';
            }
            
            String originalCreditor;
            String productName;
            String lastName;
            String firstName;
            String loanNumberPrimary;
            String assetIdSecondary;
            String accountType;
            String startMonth;
            String startYear;
            String endMonth;
            String endYear;
            String priority;
            String startDate;
            String endDate;
            String otherMediaRequest;
            String comments;
            
            if(workassh.Original_Creditor__c == null){
                originalCreditor = ' ';
            }else{
                originalCreditor = workassh.Original_Creditor__c;
            }
            if(workassh.Product__r.Name == null){
                productName = ' ';
            }else{
                productName = workassh.Product__r.Name;
            }
            if(workassh.Last_Name__c == null){
                lastName = ' ';
            }else{
                lastName = workassh.Last_Name__c;
            }
            if(workassh.First_Name__c == null){
                firstName = ' ';
            }else{
                firstName = workassh.First_Name__c;
            }
            if(workassh.Loan_Number_Primary__c == null){
                loanNumberPrimary = ' ';
            }else{
                loanNumberPrimary = workassh.Loan_Number_Primary__c;
            }
            if(workassh.AssetID_Secondary__c == null){
                assetIdSecondary = ' ';
            }else{
                assetIdSecondary = workassh.AssetID_Secondary__c;
            }
            if(workassh.Account_Type__c == null){
                accountType = ' ';
            }else{
                accountType = workassh.Account_Type__c;
            } 
            if(workassh.Start_Month__c == null){
                startMonth = ' ';
            }else{
                startMonth = workassh.Start_Month__c;
            } 
            if(workassh.Start_Year__c == null){
                startYear = ' ';
            }else{
                startYear = workassh.Start_Year__c;
            }
            if(workassh.End_Month__c == null){
                endMonth = ' ';
            }else{
                endMonth = workassh.End_Month__c;
            }
            if(workassh.End_Year__c == null){
                endYear = ' ';
            }else{
                endYear = workassh.End_Year__c;
            }
            if(workassh.Priority__c == null){
                priority = ' ';
            }else{
                priority = workassh.Priority__c;
            }
            if(workassh.Other_Media_Request__c == null){
                otherMediaRequest = ' ';
            }else{
                otherMediaRequest = workassh.Other_Media_Request__c;
            }
            if(workassh.Latest_Comment__c == null){
                comments = ' ';
            }else{
                comments = workassh.Latest_Comment__c;
            }
            startDate = startMonth + ' - ' + startYear;
            endDate = endMonth + ' - ' + endYear;
            
      		  String mediaRqstCSV = '';
              mediaRqstCSV = checkComma(workassh.Name)+',' 
                                + checkComma(originalCreditor)+',' 
                                + checkComma(productName) +','
                                + checkComma(saleDate) +',' 
                                + checkComma(lastName) +','
                   			    + checkComma(firstName) +','
                    			+ checkComma(loanNumberPrimary) +','
                   			    + checkComma(assetIdSecondary) +','
                    			+ checkComma(accountType) +','
                  				+ checkComma(chargeOffDate) +',' 
                  				+ checkComma(application) +','
                  				+ checkComma(statement) +','
                   			    + checkComma(startDate) +',' 
                   			    + checkComma(endDate) +','
                   				//+ checkComma(endMonth) +',' 
                  			   // + checkComma(endYear) +',' 
                  				+ checkComma(noteLines) +','
                  				+ checkComma(cardHolderAgreement) +','
                       			+ checkComma(CheckCopy) +','
                  				+ checkComma(DriversLicense) +','
                  				+ checkComma(PPSARegistration) +','
                  				+ checkComma(RepossessionAndAuctionDocuments) +','
                  				+ checkComma(Other) +','
                  				+ checkComma(otherMediaRequest) +','
                                + checkComma(ChargeOffStatement) +','
                                + checkComma(LastPaymentStatement) +','
                                + checkComma(comments) +','
                   				//+ checkComma(priority) +','
                                + '' +''
                                + '\n'; 
            
              if(String.isNotBlank(mediaRqstCSV)){
                headerCSV += mediaRqstCSV;
              } 
            
        }
      
      
        system.debug('headerCSV '+headerCSV);
        postDocumentAPI(headerCSV);
    
        return null;
    }   
    
    public void postDocumentAPI(String cSV){
        Map<String,Object> rawObj;       
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        system.debug('123');
        Blob fileBlob;
        if(Test.isRunningTest()) {
        	fileBlob = Blob.valueOf('test');
        }else{
            fileBlob = Blob.valueOf(cSV);
        }
        if(!Test.isRunningTest()) {
        	parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Media Request file Exported.csv', 'Task');
        }
        else{
            parsedResponse.DocUrl = 'Test';
            parsedResponse.docId = 'Test';
        } 
        system.debug('parsedResponse in controller: '+parsedResponse);
        //rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response); 
        
        //Create  CSV Document Storage Record
        Document_Storage__c  DocStorage = new Document_Storage__c();
        
        if(null != parsedResponse
           && String.isnotBlank(parsedResponse.docId)){
            DocStorage.Document_Name__c = 'Media Request Export Document.csv';
            DocStorage.Document_Extension__c = 'csv';
            DocStorage.Document_ID__c =  parsedResponse.docId;
            DocStorage.Document_Type__C = 'Media Request File';
            DocStorage.Document_URL__c = parsedResponse.DocUrl;
            DocStorage.Uploaded_By__c = 'Internal User';
            DocStorage.Creator__c = UserInfo.getName();
            DocStorage.Document_Related_To__c = 'Media Request';
            DocStorage.Media_Request__c = TRUE;
            DocStorage.File_Processed_By__c = UserInfo.getName();
            DocStorage.File_Processing_Date__c = Date.today();
            insert DocStorage;
        }
        
        List<Work_Assignment__c> listWorkassignmentUpdate = New List<Work_Assignment__c>();
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger=false;
        for(Work_Assignment__c updateWorkassign : listWorkAssg){
           updateWorkassign.Status__c = 'In Progress';
            listWorkassignmentUpdate.add(updateWorkassign);
            system.debug('listWorkassignmentUpdate '+listWorkassignmentUpdate);
        }
        
        update listWorkassignmentUpdate;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger=true;
        ERROR_MSG = '&nbsp;&nbsp;Media Request Records Exported Successfully';
        DisableExportBtn = true;
        listDocStorage = [Select id,Name,Media_Request__c,File_Processing_Date__c,
                          Document_Type__c,Creator__c,Document_Id__c,Document_URL__c
                         from Document_Storage__c Where Media_Request__c = TRUE ORDER BY Name DESC LIMIT 8];
    }
    
    
     //Convert Date to String
    @testvisible
    private static String convertDateToString(DateTime dt){
        if(dt != null){
            //Date dte = dt.Date();
            //return String.valueof(dte.month()+'/'+dte.day()+'/'+dte.year());
            return (dt.formatGMT('MM/dd/yyyy'));
        }
        else{
            return '';
        }
    }
    
    //if value contains comma',' , append quote in trailing and heading
    @testvisible
    private static String checkComma(String str){

        if(String.isNotBlank(str) && str.contains(',')){
                return +' \"'+str+'\" ';
        }
        else{
            return str;
        }
    }

}