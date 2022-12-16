/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is for to call VF page and generate commission Statement for every agency.
*  @author : A5E Consulting
*  @date : 14/06/2021

*************************************************************************************************/
global class CommissionStatementBatch implements Database.Batchable<Placement__c>,Database.AllowsCallouts,Database.Stateful{
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    
    public Integer num = 1;
    List<Placement__c> listPalce = new List<Placement__c>();
    public List<Id> docStorageIdSet;
    // public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    //Fetch all collection agency data
    
    public CommissionStatementBatch(){
        docStorageIdSet = new List<Id>();
    }
    
    //Fetch all placements for creating commission statement pdf
    public List<Placement__c> start(Database.BatchableContext BC) {
        listPalce = [Select id,name,Agency_Phone_Number__c from Placement__c];        
        return listPalce;
    }
    
    //Call VF page for every agency and create pdf and document storage record.
    public void execute(Database.BatchableContext BC,List<Placement__c> listPlacement) {
        //system.debug('listPlacement::'+listPlacement);
        for(Placement__c place : listPlacement){
            //system.debug('block run');
            PageReference commissionStatement = new PageReference('/apex/CommissionStatementVF');
            commissionStatement.getParameters().put('Id', place.id);
            commissionStatement.getParameters().put('Number',String.ValueOf(num));
            blob pdfBodyCommission;
            if(Test.isRunningTest()) {
                pdfBodyCommission = Blob.valueOf('test');
            }else{
                pdfBodyCommission = commissionStatement.getContent();
            }
            DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
            //Calls the Azure cloud API to store documents on Azure.
            if(!Test.isRunningTest()) {
                parsedResponse = DocumentAPIClient.postDocument(pdfBodyCommission , 'Commission Statement.pdf',  'placement');
            //system.debug('parsedResponse::'+parsedResponse);
            }else{
                parsedResponse.DocUrl = 'Test';
                parsedResponse.docId = 'Test';
            }
            Document_Storage__c docInfo = new Document_Storage__c();
            docInfo.Document_Name__c = 'Placement'+' '+ place.Name +' '+'Commission Statement.pdf';
            docInfo.Document_Type__c = 'Commission Statement';
            //docInfo.Document_URL__c = 'Test';//parsedResponse.DocUrl
            //docInfo.Document_Id__c = '122312312';//parsedResponse.docId
            docInfo.Document_URL__c =parsedResponse.DocUrl;
            docInfo.Document_Id__c = parsedResponse.docId;
            docInfo.Placement_Agency__c = place.id;
            docInfo.Visibility__c = 'CFG + Requesting Agency';
            docInfo.Placement_Identifier__c = place.Name;
            //docInfo.Work_Assignment__c = 'a3A7g0000006bj7EAA';
            //system.debug('docInfo::'+docInfo);
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            //docList.add(docInfo);
            if(!Test.isRunningTest()) {
             PortalNotificationAPI.sendPaymentNotification(place.Name,docInfo.Document_Type__c,docInfo.Document_Name__c,'','Commission Statement Created.');
            }
            insert docInfo;
            //system.debug('docInfo::'+docInfo.id);
            docStorageIdSet.add(docInfo.Id);
            //DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            //system.debug('pdfBodyCommission::'+pdfBodyCommission);
            
        }
        num++ ;
        //insert docList;
        //System.debug('><><'+docStorageIdSet);
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
    
    public void finish(Database.BatchableContext BC){
        //System.debug('>>>>>'+docStorageIdSet);
        //Call the another batch to call portal api for every document storage record.
        if(!Test.isRunningTest()) {
        Database.executeBatch(new SyncDocumentStorageBatch(docStorageIdSet), 50);
        }
    }
}