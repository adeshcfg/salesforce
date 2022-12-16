/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is for to call VF page and generate commission Statement for every agency.
*  @author : A5E Consulting
*  @date : 14/06/2021

*************************************************************************************************/
global class CommissionStatementBatch_New implements Database.Batchable<Placement__c>,Database.AllowsCallouts,Database.Stateful{
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    
    public Integer num = 1;
    List<Placement__c> listPalce = new List<Placement__c>();
    public List<Id> docStorageIdSet;
    public String cmyear;
    public String cmmonth;
    public boolean visibUpdate;
    public String visibility;
    public String agencyid;
    public boolean isSuccess;
    // public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    //Fetch all collection agency data
    
    public CommissionStatementBatch_New(String cmyearp,String cmmonthp,string agencyidp, string visibilityp,boolean visibilityUpdate){
        DateTime currentDate = system.now();
        system.debug('Parametr Year ::' + cmyearp);
        system.debug('Current Year'+currentDate.year()); 
        isSuccess = true;
        if(Integer.valueOf(cmyearp)>currentDate.year()){
            //Handle Invalid Year
            system.debug('Wrong Year ::' + cmyearp);
            isSuccess = false;
            return;
            
        }
        system.debug('Parametr Month ::' + cmmonthp);
        system.debug('Current Month'+currentDate.month());
        if(Integer.valueOf(cmyearp)==currentDate.year()){
            if(Integer.valueOf(cmmonthp)>=currentDate.month()){
            //Handle Invalid Month
            system.debug('Wrong Month ::' + cmmonthp);
            isSuccess = false;
            return;
        	}
        } 
        if(visibilityp!='CFG only' && visibilityp!='CFG + Requesting Agency' 
               && visibilityp!='CFG + All Agency'){
                system.debug('Visiblilty Can not be ::' + visibilityp);
                 return;
               }
        system.debug('Checking Error');
        cmyear = cmyearp;
        cmmonth = cmmonthp;
        agencyid = agencyidp;
        visibility = visibilityp;
        visibUpdate = visibilityUpdate;
              
        docStorageIdSet = new List<Id>();
    }
    
    //Fetch all placements for creating commission statement pdf
    public List<Placement__c> start(Database.BatchableContext BC) {
        if(agencyid=='' || agencyid=='0'){
            listPalce = [Select id,name,Agency_Phone_Number__c from Placement__c]; 
        }
        else{
            listPalce = [Select id,name,Agency_Phone_Number__c from Placement__c where name=: agencyid];
        }
                
        return listPalce;
    }
    
    //Call VF page for every agency and create pdf and document storage record.
    public void execute(Database.BatchableContext BC,List<Placement__c> listPlacement) {
        //system.debug('listPlacement::'+listPlacement);
        //IF Commission Statement needs to be generated
        if(isSuccess==false){
            return;
        }
        system.debug('Visibility@@@' + visibUpdate);
        if(visibUpdate==false){
            system.debug('inside visibUpdate@@@');
            for(Placement__c place : listPlacement){
                //system.debug('block run');
                //Check if only Visibility to be Updated
                //
                PageReference commissionStatement = new PageReference('/apex/CommissionStatementVF_New');
                commissionStatement.getParameters().put('Id', place.id);
                commissionStatement.getParameters().put('Number',String.ValueOf(num));
                commissionStatement.getParameters().put('cmmmonth', cmmonth);
                commissionStatement.getParameters().put('cmmyear',cmyear);
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
                docInfo.Visibility__c = visibility;//'CFG only';//CFG + Requesting Agency'; // Will change to 'CFG + Requesting Agency'
                docInfo.Placement_Identifier__c = place.Name;
                docInfo.Commission_Month__c = cmyear+cmmonth;
                //docInfo.Work_Assignment__c = 'a3A7g0000006bj7EAA';
                //system.debug('docInfo::'+docInfo);
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                //docList.add(docInfo);
                //if(!Test.isRunningTest()) {
                    //Pushpa : 06-Jan Turning off Notification till Commission Statement are Manually Generated 
                    if(visibility != 'CFG only'){
                    PortalNotificationAPI.sendPaymentNotification(place.Name,docInfo.Document_Type__c,docInfo.Document_Name__c,'','Commission Statement Created.');
                	}
               // }
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
        else{
            system.debug('inside UpdateVisibility@@@');
            UpdateVisibility(listPlacement);
        }
        if(Test.isRunningTest()){
            UpdateVisibility(listPlacement);
            
        }
    }
    Public void UpdateVisibility(List<Placement__c> listPlacement){
        map<String,ID> mapDocStrg = new map<String,ID>();
        system.debug('Update Visibility');
        system.debug('cmyear+cmmonth ' + cmyear+cmmonth);
        List<Document_Storage__c> docInfolst = new List<Document_Storage__c>();
                docInfoLst=[SELECT CreatedDate,Document_Id__c,Document_Storage_Number__c,Document_Type__c,Id,
                            Placement_Agency__c,Visibility__c FROM Document_Storage__c 
                            Where Document_Type__c='Commission Statement' 
                            //and  Placement_Agency__c =: place.Id
                            and Commission_Month__c=: cmyear+cmmonth
                            order by CreatedDate desc];
        system.debug('Doc Ingo list ' + docInfoLst);
        for(Document_Storage__c docstrg : docInfolst){
            system.debug('Placement agency ' + docstrg.Placement_Agency__c);
             
            if(!mapDocStrg.containsKey(docstrg.Placement_Agency__c)){
                mapDocStrg.put(docstrg.Placement_Agency__c, docstrg.Id);
            }
             
        }
        system.debug('listplacement ' + listPlacement);
        system.debug('mapDocStrg ' + mapDocStrg);
        for(Placement__c place : listPlacement){
            if(mapDocStrg.containsKey(place.Id)){
            	Document_Storage__c docInfo = new Document_Storage__c();
                docInfo.ID = mapDocStrg.get(place.Id);
                docInfo.Visibility__c = visibility;
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                system.debug('Update ' + docInfo.ID);
                if(!Test.isRunningTest()) {
                     
                    if(visibility != 'CFG only'){
                    	PortalNotificationAPI.sendPaymentNotification(place.Name,docInfo.Document_Type__c,docInfo.Document_Name__c,'','Commission Statement Created.');
                	}
                }
                
                update docInfo;
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
       		}
        }
        
    }
    public void finish(Database.BatchableContext BC){
        //System.debug('>>>>>'+docStorageIdSet);
        //Call the another batch to call portal api for every document storage record.
        //if(!Test.isRunningTest() && isSuccess) {
           Database.executeBatch(new SyncDocumentStorageBatch(docStorageIdSet), 50);
       // }
    }
}