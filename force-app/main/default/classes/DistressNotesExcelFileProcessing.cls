/**************************************************************************************************
*
*  Class:   
*
*  @description : class to create  Distressed Notes Staging records and check validtaions
*  @author : A5E Consulting
*  @date : 10/01/2022

*************************************************************************************************/
public class DistressNotesExcelFileProcessing {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public ID documentId; 
    public final String dataDocuments;
    String exceptionMessage;
    String success;
    String failed;
    public Id workAssignmentId{get;set;}
     
    public Decimal successRecords;
    public Decimal failedRecords;
    Boolean SuccessHasRecord;
    Boolean FailedHasRecord;
    //public Id workAssignmentId {get;set;}
    
    List<distressedNotesRecordsWrapper> listdistressedNotesRecordsWrapper = new List<distressedNotesRecordsWrapper>();
    
    Map <String, Integer> fieldNumberMap = new Map < String, Integer > ();
    
    
    public DistressNotesExcelFileProcessing (String data, ID documentId) {
        
        system.debug('data**' + data);
        system.debug('class called');
        exceptionMessage = '';
        listdistressedNotesRecordsWrapper = deSerializeJSON(data);
        
        
        this.documentId = documentId;
        processExcelFileRecords();
    }
    
    public List<distressedNotesRecordsWrapper> deSerializeJSON(String dataAsString){
        List<distressedNotesRecordsWrapper>  listdistressedNotesRecordsWrapper = (List<distressedNotesRecordsWrapper>)JSON.deserialize(dataAsString, List<distressedNotesRecordsWrapper>.class);
        return listdistressedNotesRecordsWrapper;
    }
    
    
    public void processExcelFileRecords(){
         list<Document_Storage__c> listDocuments = [Select ID, Creator__c, Work_Assignment__c, Uploaded_By__c 
                                                   FROM Document_Storage__c 
                                                   WHERE ID= :documentID];
        	system.debug('listDocuments:: '+listDocuments);
        try{
            List<Distressed_notes__c> listDisNotesToInsert = new List<Distressed_notes__c>();
           
            List<String> disProductList = new List<String>();
            for(distressedNotesRecordsWrapper wrapRecord : listdistressedNotesRecordsWrapper){
                wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                disProductList.add(wrapRecord.data_id);
            }
            
            Map<Id,Product__c> mapProduct = new Map<Id,Product__c>();
            //Fetch canaccede and fidem accounts
            List<Product__C> listAccount = [select id, name, DebtNext_Data_ID__C, Collection_Agency__c,
                                            Collection_Sub_Status__c,Current_Balance__c,Status__c,
                                            Assignment_Date__c,Recalled_Date__c                                         
                                            from Product__C 
                                            where name in :disProductList];
            system.debug('listAccount:: '+listAccount);
            
            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            //set<ID> setProdutID = new set<ID>();
            set<String> setPlacementNames = new set<String>();
                        
            for(Product__C accountRecord : listAccount ){
                mapAccountNumberID.put(accountRecord.name, accountRecord.id);
                mapProduct.put(accountRecord.id, accountRecord);
            }
            
            system.debug('listdistressedNotesRecordsWrapper::'+listdistressedNotesRecordsWrapper);
            
            for(distressedNotesRecordsWrapper wrapRecord : listdistressedNotesRecordsWrapper){
                Distressed_notes__c dissNotes = new Distressed_notes__c();
                
                dissNotes.Product_Identifier__c = wrapRecord.data_id;
                dissNotes.Title__c = wrapRecord.title;           
                dissNotes.Body__c =wrapRecord.body;
                dissNotes.Visibility__c = wrapRecord.visibility;
                
                listDisNotesToInsert.add(dissNotes);
            }
            
            system.debug('listDisNotesToInsert: '+listDisNotesToInsert);
            
            
            list<Distressed_Note_Staging__c> listDistNotes = validationOnRecordUpdate(listDisNotesToInsert, //.Work_Assignment__c
                                                                               mapAccountNumberID,
                                                                               documentID , 
                                                                               mapProduct); 
            system.debug('listDistNotes'+listDistNotes);
            Database.SaveResult[] sr = database.insert(listDistNotes);
        }
        catch(Exception ex){
            exceptionMessage = String.valueOf(ex);
            system.debug('exceptionMessage::'+exceptionMessage);
        }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(!listDocuments.isEmpty() && listDocuments[0].Uploaded_By__c == 'External User' && String.isnotblank(listDocuments[0].Creator__c)){
            message.toAddresses = new String[] {listDocuments[0].Creator__c};  
        }
        else{
            message.setTargetObjectId(UserInfo.getUserId());    
        }
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Distressed Notes';
        String processingLink = '';
        String processingStatus = '';
        Boolean stagingCreated = false;
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
                'Please click the link below to review Distressed Notes: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DistressedNotesUpdatePage?id='+documentId;           
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DistressedNotesUpdatePage?id='+documentId;
            stagingCreated  = true;
            processingStatus = 'Staging Table Created';
        }
        else{
            message.plainTextBody = 'failed! \nReason: ' +exceptionMessage + '\n\n'+
                'Please click the link below to view page :\n'+
                URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DistressedNotesUpdatePage?id='+documentId;
            if(exceptionMessage.length() > 250){
                exceptionMessage = exceptionMessage.substring(0, 250);    
            }
            else{
                exceptionMessage = exceptionMessage;
            }
            stagingCreated  = false;
            processingStatus = 'Staging Table Creation Failed';
        }
        
        
        /*  if(!Test.isRunningTest()){
Messaging.SingleEmailMessage[] messages = 
new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
if (results[0].success) {
System.debug('The email was sent successfully.');
} else {
System.debug('The email failed to send: '
+ results[0].errors[0].message);
}    
}*/
        
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c doc = new Document_Storage__c(ID = listDocuments[0].ID,
                                                          File_Processing_Link__c = processingLink,
                                                          File_Processing_Date__c = Date.today(),
                                                          File_processing_Error__c = exceptionMessage,
                                                          File_Processing_Status__c = processingStatus,
                                                          Staging_Records_Created__c = stagingCreated
                                                         );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        
    } 
    
    
    
    
    
    //Validation method to be called  before update
    public list<Distressed_Note_Staging__c> validationOnRecordUpdate(List<Distressed_notes__c> distNew, Map<String, ID> mapAccountNumberID,ID documentId , map<ID,Product__c> mapProduct1  ){
        Map<String,Product__c> mapProduct =new Map<String,Product__c>();
        SuccessHasRecord = false;
        FailedHasRecord = false;
        successRecords = 0;
        failedRecords = 0;
        
        list<Distressed_Note_Staging__c> listcustconinfoStaging = new list<Distressed_Note_Staging__c>();
        Distressed_Note_Staging__c distNoteStaging = new Distressed_Note_Staging__c();
        
        for(Product__c prod : [Select ID,Name,collection_agency__c From Product__c 
                               Where id in: mapProduct1.keySet()]){
                                   mapProduct.put(prod.Name, prod);
                               }
        for(Distressed_notes__c distNotes:distNew){
            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';
            
            if(!mapProduct.containsKey(distNotes.Product_Identifier__c)){
                system.debug('product not exists::' +distNotes.Name);
                ERROR_MSG += '<b>ERROR</b> - Account not found.<br/>';
                system.debug('product not exists ERROR_MSG::' +ERROR_MSG);
            }
            if(distNotes.Title__c.length()>100){
                system.debug('Title is greater then 100 char::' +distNotes.Name);
                ERROR_MSG += '<b>ERROR</b> - Title is greater then 100 character.<br/>';
                system.debug('Title is greater then 100 character::' +ERROR_MSG);
            }
            if(distNotes.Body__c.length()>32760){
                system.debug('Title is greater then 32760 char::' +distNotes.Name);
                ERROR_MSG += '<b>ERROR</b> - Title is greater then 32760 character.<br/>';
                system.debug('Title is greater then 32760 character::' +ERROR_MSG);
            }
            if(distNotes.Visibility__c!='CFG only' && distNotes.Visibility__c!='CFG + Requesting Agency' 
               && distNotes.Visibility__c!='CFG + All Agency'){
                system.debug('Visiblilty Can not be ::' +distNotes.Visibility__c);
                ERROR_MSG += '<b>ERROR</b> - Visibility should be::CFG only/CFG + Requesting Agency/CFG + All Agency <br/>';
                system.debug(' Visibilty Error ::' +ERROR_MSG);
               }
            distNoteStaging = new Distressed_Note_Staging__c();
            system.debug('distNotes.Product_Identifier__c: '+ distNotes.Product_Identifier__c);
            system.debug('ERROR_MSG check:: '+ERROR_MSG);
            distNoteStaging.Identifier__c = documentId;
            distNoteStaging.Document_Storage__c = documentId;
            distNoteStaging.Title__c = distNotes.Title__c;
            distNoteStaging.body__c = distNotes.body__c;
            distNoteStaging.Visibility__c = distNotes.Visibility__c;
            distNoteStaging.ProdID__c = distNotes.Product_Identifier__c;
            if(mapProduct.containsKey(distNotes.Product_Identifier__c) && mapProduct.get(distNotes.Product_Identifier__c).Collection_agency__c != null){
                distNoteStaging.Agency_Id__c = String.valueOf(mapProduct.get(distNotes.Product_Identifier__c).Collection_agency__c);
            }
            system.debug('distNoteStaging**:: '+distNoteStaging);
            
            if(mapAccountNumberID.containsKey(distNotes.Product_Identifier__c)){
                distNoteStaging.Product_Id__c = mapAccountNumberID.get(distNotes.Product_Identifier__c);
            }
            if(String.isBlank(ERROR_MSG)){
                distNoteStaging.Comment__c = 'SUCCESS';
            }
            else{
                distNoteStaging.Comment__c = ERROR_MSG;
            }
            if(String.isNotBlank(EXPECTED)){
                distNoteStaging.Expected_Value__c = EXPECTED;
            }
            system.debug('distNoteStaging:: '+ distNoteStaging);
            
            listcustconinfoStaging.add(distNoteStaging);
            
            ERROR_MSG = '';  
        }
        system.debug('listcustconinfoStaging: '+listcustconinfoStaging);
        return listcustconinfoStaging;
    }
    
    //Wrapper class for account status update records
    public class distressedNotesRecordsWrapper{
        // public String accountID{get;set;}
        //public String accountNumber{get;set;}
        public String data_id{get;set;}
        public String title{get;set;}
        public String body{get;set;}
        public String visibility{get;set;}
    }
    
}