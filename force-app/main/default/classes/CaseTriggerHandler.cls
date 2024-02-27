/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a trigger handler class for Case object. The code is not bulkified. 
 *  @author : A5E Consulting
 *  @date : 10/24/2016
 
 *************************************************************************************************/
 
 public class CaseTriggerHandler {
    
    public static boolean runCaseTrigger = true;
    
    public static Application_Config_Settings__c config;// = Application_Config_Settings__c.getOrgDefaults();
    
    //Record Types
    public static Map <String, Id> caseRecorTypeMap;
    public static Map <String, String> caseRTMap = new Map<String, String>();
    
    //Return Case Record Type Id DeveloperName Map
    public static Map <String, Id> getCaseRecorTypeMap(){
        
        Map <String, Id> caseRecorTypeMap = new Map<String, Id>();
        
        //Fetch Record Type list of Case
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Case'];
        for(RecordType recordType : recordTypes){
            caseRecorTypeMap.put(recordType.DeveloperName, recordType.Id);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.DeveloperName);
        }       
        
        return caseRecorTypeMap;
    }
     
    static{
      //apiUser = [Select id from user where UserName =: config.API_User__c];
        caseRecorTypeMap = getCaseRecorTypeMap(); 
        
        caseRTMap.put('Scotia Bank','Insolvency_Scotia_Community_Case');       
        caseRTMap.put('SPL','Insolvency_SPL_Community_Case');
        caseRTMap.put('SDA','Insolvency_SDA_Community_Case');
        caseRTMap.put('CFG','Insolvency_Case');
        caseRTMap.put('Fairstone','Insolvency_Fairstone_Community_Case');  
        caseRTMap.put('Goeasy','Insolvency_Goeasy_Community_Case');
        caseRTMap.put('Canadian Tire','Insolvency_Canadian_Tire_Community_Case');
        
        //Remittance
        caseRTMap.put('Remittance','Remittance');
        caseRTMap.put('CCS Dividend','CCS_Dividend');
        
        //For CCS Records : Added on 29/03/19 - Chetan Gaikwad
        caseRTMap.put('CCS Case','CCS_Case');  
        
    }
    
    //Before Case is cretaed
    public static void handleBeforeInsert(List<Case> casesNew) { 

        list<case> oldCaseList = new list<case>();
        //case caseObj = casesNew[0];
        List<String> listOfSubject = new List<String>();
        List<Case> listOfCasesToClose = new List<Case> ();
        List<Case> casesWithSubject = new List<Case> ();
        DateTime currentDateTime = System.Now();
        DateTime tenMinutesLessThanNow = currentDateTime.addMinutes(-10);
        Map<String,List<Case>> mapOfSubjectWithCases = new Map<String,List<Case>>();
        for (Case caseNew : casesNew){
            listOfSubject.add(caseNew.Subject);
        }
        System.debug('currentDateTime:: '+currentDateTime);
        System.debug('tenMinutesLessThanNow:: '+tenMinutesLessThanNow);
        List<Case> listOfOldCases = [select id,Subject from Case where Subject in : listOfSubject 
                                        and Status != 'Closed' 
                                        and Status != 'Completed'
                                        and CreatedDate >: tenMinutesLessThanNow
                                        order by CreatedDate Desc];//Older record last created
        System.debug('listOfOldCases:: '+listOfOldCases);
        for(Case oldCase : listOfOldCases){
            casesWithSubject.add(oldcase);
          if(!test.isRunningTest())  mapOfSubjectWithCases.put(oldCase.Subject, casesWithSubject);
        }
        for (Case caseNew : casesNew){
            
            //Remittance + CCS Case
            System.debug('caseNew.recordTypeID '+caseNew.recordTypeID);
            System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('Remittance'));
            System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('CCS_Case'));//Added on 29/03/19 - Chetan Gaikwad
            
            //Remittance + CCS Case condition added on 29/03/19 - Chetan Gaikwad
            if(caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
               caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case') &&
               caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Dividend')){         
            System.debug('in side loop 1');
                if(String.isNotBlank(caseNew.Assign_To__c)){
                    System.debug('in side loop 2 ');
                    caseNew.Entity_Identifiers__c = caseNew.Assign_To__c;   
                }  
                
                //Update Record Type based on Client Identifier
                //caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));  
                if(caseNew.Assign_To__c != 'CFG' && caseNew.Assign_To__c != 'Canaccede'){
                    System.debug('in side loop 3');
                    caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));  
                }
                
                if(caseNew.recordTypeID == caseRecorTypeMap.get('EmailToCase')){
                    System.debug('in side loop 4');
                    caseNew.Is_Email_to_Case__c = true;
                    //if(caseNew.Form_Types__c == 'Creditor Package'){
                        System.debug('map value'+mapOfSubjectWithCases);
                        List<Case> oldCaseRecord = mapOfSubjectWithCases.get(caseNew.Subject);
                        Integer oldCaseRecordCount = oldCaseRecord.size();//5
                        System.debug('oldCaseRecordCount:: '+oldCaseRecordCount);
                        if(oldCaseRecordCount > 0){
                            System.debug('in side loop 5');
                            caseNew.Status = 'Closed';
                            caseNew.Reason = 'Duplicate';//New Record
                            //listOfCasesToClose.add(caseNew);
                            /*for(Case caseRec : oldCaseRecord){
                                if(oldCaseRecordCount != 1){
                                    caseRec.Status = 'Closed';
                                    listOfCasesToClose.add(caseRec);
                                    oldCaseRecordCount--;//4,3,2,1
                                }
                            }*/
                        }
                    //}
                }
            }
            else if(caseNew.recordTypeID == caseRecorTypeMap.get('Remittance') ||
                    caseNew.recordTypeID == caseRecorTypeMap.get('CCS_Dividend')){//Modified - Chetan Gaikwad 1/4/19
                caseNew.status = 'Closed';
                System.debug('in side loop 6');
            }
            else if(caseNew.recordTypeID == caseRecorTypeMap.get('CCS_Case')){
                System.debug('in side loop 7');
                CaseNew.Is_Email_to_Case__c = True;//for Email to Case for CCS
            }
        }
        System.debug('in side loop before updated');
        Update listOfCasesToClose; // this is added for 5302
        System.debug('in side loop after updated');
    }
    
    
    //Before Case is updated
    public static void handleBeforeUpdate(List<Case> casesNew, Map<Id, Case> oldMap) { 
        
        for (Case caseNew : casesNew){
            
            //Remittance + CCS Case
            System.debug('caseNew.recordTypeID '+caseNew.recordTypeID);
            System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('Remittance'));
            System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('CCS_Case'));
            
            //Remittance + [CCS Case condition added on 29/03/19 - Chetan Gaikwad]
            if(caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
              caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case') &&
              caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Dividend')){ 
            
                //Case being updated
                Case caseOld = oldMap.get(caseNew.id);
                
                if(caseNew.recordTypeID == caseRecorTypeMap.get('EmailtoCase')){
                    if(caseOld.status != 'DocParser Processing' && caseNew.status == 'DocParser Processing'){
                        caseNew.Parser_Sent_DateTime__c = system.now();
                    }
                }
                
                //Existing identifier
                String entityIdentifiers = '';
                if(String.isNotBlank(caseNew.Entity_Identifiers__c)){
                    entityIdentifiers = caseNew.Entity_Identifiers__c;
                }
                
                //Assign_To on old case
                if(String.isNotBlank(caseOld.Assign_To__c)){
                    if(!entityIdentifiers.contains(caseOld.Assign_To__c)){
                        entityIdentifiers = entityIdentifiers + ',' + caseOld.Assign_To__c;
                    }
                }   
                
                //Assign_To on new case
                if(String.isNotBlank(caseNew.Assign_To__c)){
                    if(!entityIdentifiers.contains(caseNew.Assign_To__c)){
                        entityIdentifiers = entityIdentifiers + ',' + caseNew.Assign_To__c;
                    }
                } 
                
                //Remove unwanted ,
                if(entityIdentifiers.startsWith(',')){
                    entityIdentifiers = entityIdentifiers.removeStart(',');
                } 
                if(entityIdentifiers.endsWith(',')){
                    entityIdentifiers = entityIdentifiers.removeEnd(',');
                }   
                
                /*
                //Do not allow case to assign to bank if Insolvenyc or Insolvency Account is not linked
                if(caseOld.Assign_To__c != caseNew.Assign_To__c){
                    if(caseold.Insolvency__c == null && caseold.Insolvency_account__c == null){
                        caseNew.addError('This assignment is not linked to Insolvency or Insolvency Account, so assignment to another bank is not allowed');
                    }
                }
                */
                
                //Update Entity_Identifiers__c
                caseNew.Entity_Identifiers__c = entityIdentifiers;   
                
                /*
                //Do not allow case to assign to wrong bank
                if(caseOld.Assign_To__c != caseNew.Assign_To__c && caseNew.Insolvency_Account__c != null){
                    Insolvency_Account__c insAcc = [select id, name, client_identifier__c from Insolvency_Account__c where id = :caseOld.Insolvency_Account__c];
                    
                    if(!entityIdentifiers.contains(insAcc.client_identifier__c)){
                        caseNew.addError('Wrong Assign To for given Insolvency Account');
                    }
                }
                */
                
                  
                
                //Update Record Type based on Client Identifier
                /*
                if(caseNew.Assign_To__c != caseOld.Assign_To__c && caseOld.Assign_To__c == 'CFG'){
                    caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));
                }
                */
                
                if(caseNew.Assign_To__c != caseOld.Assign_To__c && caseNew.Assign_To__c != 'Canaccede'){
                    if(caseNew.Assign_To__c != 'CFG'){
                        caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));
                    }                
                }
            }
        }
    }
    
    /*
    public static void handleAfterInsert(List<Case> casesNew) { 
      
      Set<String> assignToNames = New Set<String>();
      
      for(Case caseNew : casesNew){
        assignToNames.add(caseNew.Assign_To__c);
      }
      
      calculateNumberOfOpenCases(casesNew, assignToNames); 
    }
    */
    
    //After new Case is created
    public static void handleAfterInsert(List<Case> casesNewList) {
        
        Case caseNew = casesNewList.get(0);
        
        //Remittance + CCS Case
        System.debug('caseNew.recordTypeID '+caseNew.recordTypeID);
        System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('Remittance'));
        System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('CCS_Case'));
            
        //Remittance + [CCS Case condition added on 29/03/19 - Chetan Gaikwad]
        if(caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
           caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case') &&
           caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Dividend')){
            if(caseNew.Insolvency__c != null){
                calculateNumberOfOpenCasesIns(caseNew.Insolvency__c);
            }
            else if(caseNew.Insolvency_Account__c != null){
                calculateNumberOfOpenCasesInsAccnt(caseNew.Insolvency_Account__c);
            }
        }
        else if(caseNew.recordTypeID == caseRecorTypeMap.get('Remittance')){//Modified on 29/03/19 - Chetan Gaikwad
            //Create new Insolvency Remittance record
            Remittance__c remittance = new Remittance__c();
            remittance.Status__c = 'New';
            remittance.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' and sobjecttype ='Remittance__C'].Id;
            remittance.Email_to_Case_Reference_Number__c = caseNew.Id;
            insert remittance;
            
            /*
            //Copy email attachments to Remittance records
            List<Attachment> emaiAttList = [SELECT Id, Name, Description, Body 
                                                        FROM Attachment 
                                                        WHERE ParentId in (select id from EMailMessage where relatedToid =: caseNew.Id) 
                                                        ORDER BY CreatedDate DESC];
            
            List<Attachment> remittanceAttList = new List<Attachment>();
            
            for(Attachment emaiAtt : emaiAttList){
                Attachment remittanceAtt = emaiAtt.clone();
                remittanceAtt.parentId = remittance.id;
                
                //Attachment remittanceAtt = new Attachment();
                //remittanceAtt.Name = emaiAtt.Name;
                //remittanceAtt.Description = emaiAtt.Description;
                //remittanceAtt.body = emaiAtt.body;
                //remittanceAtt.IsPrivate = false;
                //remittanceAtt.parentId = remittance.Id;
                
                remittanceAttList.add(remittanceAtt);
            }
            
            //Save Remittance records attachments
            if(remittanceAttList.size() > 0){
                insert remittanceAttList;
            }
            */
        }else if(caseNew.recordTypeID == caseRecorTypeMap.get('CCS_Dividend')){//updated on 4th April 2019 Swapnil Kulkarni
            //Create CCS Remittance record
            Remittance__c remittance = new Remittance__c();
            remittance.Status__c = 'New';
            remittance.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'CCS_Dividend' and sobjecttype ='Remittance__C'].Id;
            remittance.Email_to_Case_Reference_Number__c = caseNew.Id;
            insert remittance;
        }else{
            //Add the code for CCS Case here
        }
        
        
        
    }
    
    /*
    public static void handleAfterUpdate(List<Case> casesNew, Map<Id, Case> oldMap) {   
        
        Set<String> assignToNames = New Set<String>();
        
        List <Case> casesToProcess = new List<Case>();
        for (Case caseNew : casesNew){
            
            Case caseOld = oldMap.get(caseNew.id);
            
            //Checks whether to run the trigger
            if((caseNew.status != caseOld.status) || (caseNew.Assign_To__c != caseOld.Assign_To__c) || (caseNew.RecordTypeID != caseOld.RecordTypeID)){
                casesToProcess.add(caseNew);
                assignToNames.add(caseNew.Assign_To__c);
                assignToNames.add(caseOld.Assign_To__c);
            }           
        }
        
        if(casesToProcess.size() > 0) {
            calculateNumberOfOpenCases(casesToProcess, assignToNames);             
        }  
        
        //updateInsolvancyAccountStatusOnCaseClosed(casesNew, oldMap);                 
    }
    */
    
    //After Case is updated
    public static void handleAfterUpdate(List<Case> casesNew, Map<Id, Case> oldMap) {   
        
        Case caseNew = casesNew.get(0);        
        Case caseOld = oldMap.get(caseNew.id);
        
        //Remittance + CCS Case
        System.debug('caseNew.recordTypeID '+caseNew.recordTypeID);
        System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('Remittance'));
            
        //Remittance + [CCS Case condition added 29/03/19 - Chetan Gaikwad]
        if(caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
           caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case')){
            
            //Checks whether to run the trigger
            if((caseNew.status != caseOld.status) || (caseNew.Assign_To__c != caseOld.Assign_To__c) || (caseNew.RecordTypeID != caseOld.RecordTypeID)){
                if(caseNew.Insolvency__c != null){
                    calculateNumberOfOpenCasesIns(caseNew.Insolvency__c);
                }
                else if(caseNew.Insolvency_Account__c != null){
                    calculateNumberOfOpenCasesInsAccnt(caseNew.Insolvency_Account__c);
                }   
            }   
        }        
    }
    
    /*
    public static void handleAfterDelete(List<Case> casesNew, Map<Id, Case> oldMap) {
      Set<String> assignToNames = New Set<String>();
      
        List <Case> casesToProcess = new List<Case>();
        Set<Id> casesIds = oldMap.keySet();
        for(Id caseId : casesIds){
            casesToProcess.add(oldMap.get(caseId));
            assignToNames.add(oldMap.get(caseId).Assign_To__c);
        }
        
        if(casesToProcess.size() > 0) {
            calculateNumberOfOpenCases(casesToProcess, assignToNames); 
        }
    }
    */
    
    //After Case is Deleted
    public static void handleAfterDelete(List<Case> casesNew, Map<Id, Case> oldMap) {
        
        List <Case> casesToProcess = new List<Case>();
        Set<Id> casesIds = oldMap.keySet();
        for(Id caseId : casesIds){
            casesToProcess.add(oldMap.get(caseId));
        }
        
        Case caseOld = casesToProcess.get(0);
        
        //Remittance + CCS Case
        System.debug('caseOld.recordTypeID '+caseOld.recordTypeID);
        System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('Remittance'));
        System.debug('caseRecorTypeMap.get '+caseRecorTypeMap.get('CCS_Case'));
            
        //Remittance + [CCS Case condition added 29/03/19 - Chetan Gaikwad]
        if(caseOld.recordTypeID != caseRecorTypeMap.get('Remittance') &&
           caseOld.recordTypeID != caseRecorTypeMap.get('CCS_Case')){
      
            if(caseOld.Insolvency__c != null){
                calculateNumberOfOpenCasesIns(caseOld.Insolvency__c);
            }
            else if(caseOld.Insolvency_Account__c != null){
                calculateNumberOfOpenCasesInsAccnt(caseOld.Insolvency_Account__c);
            }    
        }     
    }
    
    //Calculate number of open cases on Insolvency
    private static void calculateNumberOfOpenCasesIns(Id insId) {
        
        config = [SELECT Eligible_for_Open_Assignment_Calculation__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
        //Related Open Cases
        List <Case> insolvencyCases = [Select id, Assign_To__c from Case
                            where status != 'Closed'
                            and (
                            (Insolvency__c!= null and Insolvency__c =: insId)
                            or
                            (Insolvency_Account__c != null and Insolvency_Account__r.Insolvency__c != null and  Insolvency_Account__r.Insolvency__c =: insId)
                            )];
        
        //Assigned to vs count map                    
        Map<String, Decimal> assignToCountMap = new Map<String, Decimal>();
        List<Schema.PicklistEntry> pikListValues = Case.Assign_To__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pikListValue : pikListValues) {
            assignToCountMap.put(pikListValue.getValue(), 0);
        }
        
        //Calculate count
        for(Case insolvencyCase : insolvencyCases){
          if(config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)){
                Decimal assignToORNbr = assignToCountMap.get(insolvencyCase.Assign_To__c);
                assignToCountMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1); 
            }  
        }   
        
        //Initialize Child records
        List<Open_Assignment_Insolvency__c> oais = new List<Open_Assignment_Insolvency__c>();
        for (String assignToName : assignToCountMap.KeySet()){                
            if(config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)){
                Decimal nmbrOpnAssgn = assignToCountMap.get(assignToName); 
                if(nmbrOpnAssgn != null && nmbrOpnAssgn > 0){
                    Open_Assignment_Insolvency__c oai = new Open_Assignment_Insolvency__c();
                    oai.Insolvency__c = insId;
                    oai.Assign_To_Name__c = assignToName;
                    oai.Number_of_Open_Assignments__c = nmbrOpnAssgn;
                    
                    oais.add(oai);  
                }  
            }           
        } 
    
    //Delete existing child records
    delete [Select id from Open_Assignment_Insolvency__c 
                  where 
                  Insolvency__c =: insId];
        
        //Insert Child records          
        if(oais.size() > 0){
            upsert oais;
        }  
    }
    
    //Calculate number of open cases on Insolvency Account
    private static void calculateNumberOfOpenCasesInsAccnt(Id insAccntId) {
      
      config = [SELECT Eligible_for_Open_Assignment_Calculation__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
      //Related Open Cases
      List <Case> insolvencyCases = [Select id, Assign_To__c from Case
                            where status != 'Closed' 
                            and 
                            Insolvency_Account__c != null 
                            and 
                            Insolvency_Account__c =: insAccntId
                            ];
        
        //Assigned to vs count map                    
        Map<String, Decimal> assignToCountMap = new Map<String, Decimal>();
        List<Schema.PicklistEntry> pikListValues = Case.Assign_To__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pikListValue : pikListValues) {
            assignToCountMap.put(pikListValue.getValue(), 0);
        }
        
        //Calculate count
        for(Case insolvencyCase : insolvencyCases){
          if(config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)){
                Decimal assignToORNbr = assignToCountMap.get(insolvencyCase.Assign_To__c);
                assignToCountMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1); 
            }  
        }   
        
        //Initialize Child records
        List<Open_Assignment_Insolvency_Account__c> oaias = new List<Open_Assignment_Insolvency_Account__c>();
        for (String assignToName : assignToCountMap.KeySet()){                
            if(config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)){
                Decimal nmbrOpnAssgn = assignToCountMap.get(assignToName); 
                if(nmbrOpnAssgn != null && nmbrOpnAssgn > 0){
                    Open_Assignment_Insolvency_Account__c oaia = new Open_Assignment_Insolvency_Account__c();
                    oaia.Insolvency_Account__c = insAccntId;
                    oaia.Assign_To_Name__c = assignToName;
                    oaia.Number_of_Open_Assignments__c = nmbrOpnAssgn;
                    
                    oaias.add(oaia);  
                }  
            }           
        } 
    
    //Delete existing child records
    delete [Select id from Open_Assignment_Insolvency_Account__c 
                  where 
                  Insolvency_Account__c =: insAccntId];
        
        //Insert Child records          
        if(oaias.size() > 0){
            upsert oaias;
        }  
        
        //Calculate number of open cases on related Insolvency records
        List<Insolvency_Account__c> insAccnts = [Select Id, Insolvency__c 
                                from Insolvency_Account__c
                                where Id =: insAccntId];
        
        if(insAccnts.Size() > 0){
          Id insId = insAccnts.get(0).Insolvency__c;
          if(insId != null){
            calculateNumberOfOpenCasesIns(insId);
          }
        }
    }
    
    //Utility method to populate number of open cases on Insolvency
    /*
    private static void calculateNumberOfOpenCases(List<Case> cases, Set<String> assignToNames) {
      
      System.debug('assignToNames :'+assignToNames);
      
      //Set of unique Insolvency Ids from Cases
        Set<Id> caseInsolvencyIds = new Set<Id>();  
        
        
        //Set of unique Insolvency Account Ids from Cases
        Set<Id> caseInsolvencyAccountIds = new Set<Id>();
        
        
        //Populate set of unique Insolvency Ids and Insolvency Account Ids
        for(Case cse : cases){
            if(cse.Insolvency__c != null){                
                caseInsolvencyIds.add(cse.Insolvency__c); 
            }
            if(cse.Insolvency_Account__c != null){
                caseInsolvencyAccountIds.add(cse.Insolvency_Account__c);
            }
        }
        System.debug('caseInsolvencyIds1 :'+caseInsolvencyIds);
        System.debug('caseInsolvencyAccountIds1 :'+caseInsolvencyAccountIds);
        
        
        
        //Fetch Client Identifiers Insolvency Account Ids
        List<Insolvency_Account__c> caseInsolvencyAccounts = [Select id, 
                                       Insolvency__c,
                                       Client_Identifier__c  
                                                                   from Insolvency_Account__c
                                                                   where 
                                                                   Id IN :caseInsolvencyAccountIds
                                                               ];
                                                                  
    //Populate Client Identifiers
        Set<String> clientIdentifiers = new Set<String>();
        for(Insolvency_Account__c caseInsolvencyAccount : caseInsolvencyAccounts){
          if(String.isNotBlank(caseInsolvencyAccount.Client_Identifier__c)){
            clientIdentifiers.add(caseInsolvencyAccount.Client_Identifier__c);
          }
        }                                                                  
                                                                      
        
        //Popualte Insolvency IDs from Insolvency Account Ids
        List<Insolvency_Account__c> insolvencyAccountsToUpdate = [Select id, Insolvency__c 
                                                                        from Insolvency_Account__c 
                                                                      where 
                                                                      Client_Identifier__c IN :clientIdentifiers //ToDo - is this needed?
                                                                      and
                                                                      (
                                                                        Id IN :caseInsolvencyAccountIds
                                                                        or
                                                                        Insolvency__c IN : caseInsolvencyIds
                                                                      )
                                                                  ];
                                                                  
        System.debug('insolvencyAccountsToUpdate.size() :'+insolvencyAccountsToUpdate.size());
                                                                
        for(Insolvency_Account__c insolvencyAccount : insolvencyAccountsToUpdate){
            if(insolvencyAccount.Insolvency__c != null){
                caseInsolvencyIds.add(insolvencyAccount.Insolvency__c);
            }           
            caseInsolvencyAccountIds.add(insolvencyAccount.Id);            
        }
        System.debug('caseInsolvencyIds2 :'+caseInsolvencyIds);
        System.debug('caseInsolvencyAccountIds2 :'+caseInsolvencyAccountIds);
        
        //Fetch cases with current status
        List<Case> insolvencyCases = [Select id, Insolvency__c, Insolvency_Account__c, 
                                             Insolvency_Account__r.Insolvency__c,
                                             Assign_To__c 
                                             from Case where status != 'Closed'
                                             and 
                                             (
                                             Insolvency__c IN :caseInsolvencyIds
                                             or
                                             Insolvency_Account__c IN : caseInsolvencyAccountIds
                                             ) 
                                             and Assign_To__c IN :assignToNames
                                             ];
                                             
        //Initialize Maps
        //Initialize Insolvency Map
    Map <Id, Map<String, Decimal>> insolvencyAssignToMap = new Map<Id, Map<String, Decimal>>();  
    for(Id insolvId : caseInsolvencyIds){
            Map<String, Decimal> assignToNameMap = new Map<String, Decimal>();
            for(String assignToName : assignToNames){
                assignToNameMap.put(assignToName, 0);               
            }   
            insolvencyAssignToMap.put(insolvId, assignToNameMap);
        }
        
        //Initialize Insolvency Account Map
        Map <Id, Map<String, Decimal>> insolvencyAccntAssignToMap = new Map<Id, Map<String, Decimal>>();        
        for(Id insolvAccntId : caseInsolvencyAccountIds){
            Map<String, Decimal> assignToNameMap = new Map<String, Decimal>();
            for(String assignToName : assignToNames){
                assignToNameMap.put(assignToName, 0);               
            }   
            insolvencyAccntAssignToMap.put(insolvAccntId, assignToNameMap);
        }
        
        //Insolvency Account Cases
        for(Case insolvencyCase : insolvencyCases){
          if(insolvencyCase.Insolvency_Account__c != null){
                if(caseInsolvencyAccountIds.contains(insolvencyCase.Insolvency_Account__c)){
                    if(!String.isBlank(insolvencyCase.Assign_To__c)){
                        if(config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)){
                            //Multi Bank - open assignments on Insolvency Account                        
                            Map<String, Decimal> assignToIAccDBMap = insolvencyAccntAssignToMap.get(insolvencyCase.Insolvency_Account__c);
                            Decimal assignToIAccORNbr = assignToIAccDBMap.get(insolvencyCase.Assign_To__c);
                            assignToIAccDBMap.put(insolvencyCase.Assign_To__c, assignToIAccORNbr + 1);
                            insolvencyAccntAssignToMap.put(insolvencyCase.Insolvency_Account__c, assignToIAccDBMap);
                            
                            //Multi Bank - open assignments on related Insolvency     
                            if(insolvencyCase.Insolvency_Account__r.Insolvency__c != null){
                                Map<String, Decimal> assignToDBMap = insolvencyAssignToMap.get(insolvencyCase.Insolvency_Account__r.Insolvency__c);
                                Decimal assignToORNbr = assignToDBMap.get(insolvencyCase.Assign_To__c);
                                assignToDBMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1);
                                insolvencyAssignToMap.put(insolvencyCase.Insolvency__c, assignToDBMap); 
                            }
                        }
                    }                    
                }                            
            }
        }   
        
        //Insolvency Cases                                  
    for(Case insolvencyCase : insolvencyCases){
      if(!String.isBlank(insolvencyCase.Assign_To__c)){
              if(insolvencyCase.Insolvency__c != null){
                  if(caseInsolvencyIds.contains(insolvencyCase.Insolvency__c)){
                    
                    //Multi Bank - open assignments on Insolvency
                        if(config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)){
                            Map<String, Decimal> assignToDBMap = insolvencyAssignToMap.get(insolvencyCase.Insolvency__c);
                            Decimal assignToORNbr = assignToDBMap.get(insolvencyCase.Assign_To__c);
                            assignToDBMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1);
                            insolvencyAssignToMap.put(insolvencyCase.Insolvency__c, assignToDBMap); 
                        }
                  } 
              }
      }
    }
    
    //Multibank
        //Open Assignment Insolvency
        List<Open_Assignment_Insolvency__c> oais = new List<Open_Assignment_Insolvency__c>();
        for(Id caseInsolvencyId : caseInsolvencyIds){
      Map<String, Decimal> assignToMap = insolvencyAssignToMap.get(caseInsolvencyId);
            System.debug('insolvencyAssignToMap.get(caseInsolvencyId) :'+assignToMap);
            
            for (String assignToName : assignToMap.KeySet()){
                
                if(config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)){
                    Decimal nmbrOpnAssgn = assignToMap.get(assignToName); 
                    if(nmbrOpnAssgn != null && nmbrOpnAssgn > 0){
                        Open_Assignment_Insolvency__c oai = new Open_Assignment_Insolvency__c();
                        oai.Insolvency__c = caseInsolvencyId;
                        oai.Assign_To_Name__c = assignToName;
                        oai.Number_of_Open_Assignments__c = nmbrOpnAssgn;
                        System.debug('oai.Assign_To_Name__c :'+oai.Assign_To_Name__c);
                        System.debug('oai.Number_of_Open_Assignments__c :'+oai.Number_of_Open_Assignments__c);  
                    
                        oais.add(oai);  
                    }  
                }           
            }
    }
    
    //Multibank
        //Open Assignment Insolvency Account
        List<Open_Assignment_Insolvency_Account__c> oaias = new List<Open_Assignment_Insolvency_Account__c>();
        for(Id caseInsolvencyAccountId : caseInsolvencyAccountIds){
      Map<String, Decimal> assignToMap = insolvencyAccntAssignToMap.get(caseInsolvencyAccountId);
            System.debug('insolvencyAccntAssignToMap.get(caseInsolvencyAccountId) :'+assignToMap);
            for (String assignToName : assignToMap.KeySet()){
                
                if(config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)){
                    Decimal nmbrOpnAssgn = assignToMap.get(assignToName); 
                    if(nmbrOpnAssgn != null && nmbrOpnAssgn > 0){
                        Open_Assignment_Insolvency_Account__c oaia = new Open_Assignment_Insolvency_Account__c();
                        oaia.Insolvency_Account__c = caseInsolvencyAccountId;
                        oaia.Assign_To_Name__c = assignToName;
                        oaia.Number_of_Open_Assignments__c = nmbrOpnAssgn;
                        System.debug('oaia.Assign_To_Name__c :'+oaia.Assign_To_Name__c);
                        System.debug('oaia.Number_of_Open_Assignments__c :'+oaia.Number_of_Open_Assignments__c);  
                    
                        oaias.add(oaia);  
                    }  
                }           
            }
    }
    
    //Delete Open Assignment records
        Delete [Select id from Open_Assignment_Insolvency__c 
                  where 
                  Insolvency__c IN : caseInsolvencyIds 
                  and 
                  Assign_To_Name__c IN :assignToNames];
                  
    //Delete Open Assignment records
        Delete [Select id from Open_Assignment_Insolvency_Account__c 
                  where 
                  Insolvency_Account__c IN : caseInsolvencyAccountIds 
                  and 
                  Assign_To_Name__c IN :assignToNames];                  
        
        //Multibank
        //Insert Open Assignment records
        if(oais.size() > 0){
            upsert oais;
        }
        if(oaias.size() > 0){
            upsert oaias;
        }
    }
    */
    
    //Utility method to populate number of open cases on Insolvency
    /*
    private static void calculateNumberOfOpenCasesBK(List<Case> cases) {
        
        //Set of unique Insolvency Ids from Cases
        Set<Id> insolvencyIds = new Set<Id>();
        
        //Set of unique Insolvency Account Ids from Cases
        Set<Id> insolvencyAccountIds = new Set<Id>();
        
        //Populate set of unique Insolvency Ids and Insolvency Account Ids
        for(Case cse : cases){
            if(cse.Insolvency__c != null || cse.Insolvency_Account__c != null){
                
                if(cse.Insolvency__c != null){
                    insolvencyIds.add(cse.Insolvency__c);                    
                }
                if(cse.Insolvency_Account__c != null){
                    insolvencyAccountIds.add(cse.Insolvency_Account__c);
                }
            }
        }
        
        //Popualte unique Insolvency and Insolvency Account Ids
        List<Insolvency_Account__c> insolvencyAccountsToUpdate = [Select id, Insolvency__c 
                                                                from Insolvency_Account__c 
                                                                where 
                                                                Id IN :insolvencyAccountIds];
                                                                
        for(Insolvency_Account__c insolvencyAccount : insolvencyAccountsToUpdate){
            insolvencyAccountIds.add(insolvencyAccount.Id);
            
            if(insolvencyAccount.Insolvency__c != null){
                insolvencyIds.add(insolvencyAccount.Insolvency__c);
            }           
        }
        
        //Popualte unique Insolvency and Insolvency Account Ids
        insolvencyAccountsToUpdate = [Select id, Insolvency__c 
                                            from Insolvency_Account__c 
                                            where 
                                            Insolvency__c IN : insolvencyIds or Id IN :insolvencyAccountIds];
                                                                
        for(Insolvency_Account__c insolvencyAccount : insolvencyAccountsToUpdate){
            insolvencyAccountIds.add(insolvencyAccount.Id);
            
            if(insolvencyAccount.Insolvency__c != null){
                insolvencyIds.add(insolvencyAccount.Insolvency__c);
            }           
        }
                
        List<Insolvency__c> insolvenciesToUpdate = [Select id from Insolvency__c where Id IN :insolvencyIds];
        
        //Existing Scotia Logic
        //Temporary map to store Insolvency Id and coresponding number of open cases
        //Map <Id, Integer> insolvencyCFGCasesMap = new Map<Id, Integer>();
        //Map <Id, Integer> insolvencyScotiaCasesMap = new Map<Id, Integer>();
        //for(Insolvency__c insolvencyToUpdate : insolvenciesToUpdate){
        //    insolvencyCFGCasesMap.put(insolvencyToUpdate.id, 0);
        //    insolvencyScotiaCasesMap.put(insolvencyToUpdate.id, 0);            
        //}
        
        
        //Existing Scotia Logic
        //Temporary map to store Insolvency Account Id and coresponding number of open cases
        //Map <Id, Integer> insolvencyAccntCFGCasesMap = new Map<Id, Integer>();
        //Map <Id, Integer> insolvencyAccntScotiaCasesMap = new Map<Id, Integer>();
        //for(Insolvency_Account__c insolvencyAccountToUpdate : insolvencyAccountsToUpdate){
        //    insolvencyAccntCFGCasesMap.put(insolvencyAccountToUpdate.id, 0);
        //    insolvencyAccntScotiaCasesMap.put(insolvencyAccountToUpdate.id, 0);            
        //}
        
        
        List<Case> insolvencyCases = [Select id, Insolvency__c, Insolvency_Account__c, 
                                             Insolvency_Account__r.Insolvency__c,
                                             Assign_To__c 
                                             from Case where status != 'Closed'
                                             and 
                                             (Insolvency__c IN :insolvencyIds
                                             or
                                             Insolvency_Account__c IN : insolvencyAccountIds)];
        
        //Multi Bank
        List <String> assignToNames = New List<String>();
        List<Schema.PicklistEntry> pikListValues = Case.Assign_To__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pikListValue : pikListValues) {
            assignToNames.add(pikListValue.getValue());
        }
        System.debug('assignToNames :'+assignToNames);
        
        //Initialize Insolvency Map
        Map <Id, Map<String, Decimal>> insolvencyAssignToMap = new Map<Id, Map<String, Decimal>>();         
        for(Id insolvId : insolvencyIds){
            Map<String, Decimal> assignToNameMap = new Map<String, Decimal>();
            for(String assignToName : assignToNames){
                assignToNameMap.put(assignToName, 0);               
            }   
            insolvencyAssignToMap.put(insolvId, assignToNameMap);
        }
        
        //Multibank
        //Initialize Insolvency Account Map
        Map <Id, Map<String, Decimal>> insolvencyAccntAssignToMap = new Map<Id, Map<String, Decimal>>();        
        for(Id insolvAccntId : insolvencyAccountIds){
            Map<String, Decimal> assignToNameMap = new Map<String, Decimal>();
            for(String assignToName : assignToNames){
                assignToNameMap.put(assignToName, 0);               
            }   
            insolvencyAccntAssignToMap.put(insolvAccntId, assignToNameMap);
        }
        
        //Determine number of open cases on Insolvency record                               
        for(Case insolvencyCase : insolvencyCases){
            if(insolvencyCase.Insolvency__c != null){
                if(insolvencyIds.contains(insolvencyCase.Insolvency__c)){
                    if(!String.isBlank(insolvencyCase.Assign_To__c)){
                        
                        //Existing Scotia Logic
                        //if('CFG'.equalsIgnoreCase(insolvencyCase.Assign_To__c)){
                        //    Integer caseCount = insolvencyCFGCasesMap.get(insolvencyCase.Insolvency__c);
                        //    if(null == caseCount){
                        //        caseCount = 0;
                        //    }
                        //    insolvencyCFGCasesMap.put(insolvencyCase.Insolvency__c, caseCount+1);
                        //}
                        //else if('Scotia Bank'.equalsIgnoreCase(insolvencyCase.Assign_To__c)){
                        //    Integer caseCount = insolvencyScotiaCasesMap.get(insolvencyCase.Insolvency__c);
                        //    if(null == caseCount){
                        //        caseCount = 0;
                        //    }
                        //    insolvencyScotiaCasesMap.put(insolvencyCase.Insolvency__c, caseCount+1);
                        //}    
                        
                        //Multi Bank - open assignments on Insolvency
                        if(config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)){
                            Map<String, Decimal> assignToDBMap = insolvencyAssignToMap.get(insolvencyCase.Insolvency__c);
                            Decimal assignToORNbr = assignToDBMap.get(insolvencyCase.Assign_To__c);
                            assignToDBMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1);
                            insolvencyAssignToMap.put(insolvencyCase.Insolvency__c, assignToDBMap); 
                        }
                    }   
                }               
            }
            
            if(insolvencyCase.Insolvency_Account__c != null){
                if(insolvencyAccountIds.contains(insolvencyCase.Insolvency_Account__c)){
                    if(!String.isBlank(insolvencyCase.Assign_To__c)){
                        
                        //Existing Scotia Logic
                        //
                        //if('CFG'.equalsIgnoreCase(insolvencyCase.Assign_To__c)){
                        //    Integer caseCount = insolvencyAccntCFGCasesMap.get(insolvencyCase.Insolvency_Account__c);
                        //    if(null == caseCount){
                        //        caseCount = 0;
                        //    }
                        //    insolvencyAccntCFGCasesMap.put(insolvencyCase.Insolvency_Account__c, caseCount+1);
                            
                        //    if(insolvencyCase.Insolvency_Account__r.Insolvency__c != null){
                        //        Integer caseInslCount = insolvencyCFGCasesMap.get(insolvencyCase.Insolvency_Account__r.Insolvency__c);
                        //        if(null == caseInslCount){
                        //            caseInslCount = 0;
                        //        }
                        //        insolvencyCFGCasesMap.put(insolvencyCase.Insolvency_Account__r.Insolvency__c, caseInslCount+1);
                        //    }   
                        //}
                        //else if('Scotia Bank'.equalsIgnoreCase(insolvencyCase.Assign_To__c)){
                        //    Integer caseCount = insolvencyAccntScotiaCasesMap.get(insolvencyCase.Insolvency_Account__c);
                        //    if(null == caseCount){
                        //       caseCount = 0;
                        //   }
                        //    insolvencyAccntScotiaCasesMap.put(insolvencyCase.Insolvency_Account__c, caseCount+1);
                            
                        //    if(insolvencyCase.Insolvency_Account__r.Insolvency__c != null){
                        //        Integer caseInslCount = insolvencyScotiaCasesMap.get(insolvencyCase.Insolvency_Account__r.Insolvency__c);
                        //        if(null == caseInslCount){
                        //            caseInslCount = 0;
                        //        }
                        //        insolvencyScotiaCasesMap.put(insolvencyCase.Insolvency_Account__r.Insolvency__c, caseInslCount+1);
                        //    } 
                        //}
                                               
                        
                        if(config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)){
                            //Multi Bank - open assignments on Insolvency Account                        
                            Map<String, Decimal> assignToIAccDBMap = insolvencyAccntAssignToMap.get(insolvencyCase.Insolvency_Account__c);
                            Decimal assignToIAccORNbr = assignToIAccDBMap.get(insolvencyCase.Assign_To__c);
                            assignToIAccDBMap.put(insolvencyCase.Assign_To__c, assignToIAccORNbr + 1);
                            insolvencyAccntAssignToMap.put(insolvencyCase.Insolvency_Account__c, assignToIAccDBMap);
                            
                            //Multi Bank - open assignments on related Insolvency     
                            if(insolvencyCase.Insolvency_Account__r.Insolvency__c != null){
                                Map<String, Decimal> assignToDBMap = insolvencyAssignToMap.get(insolvencyCase.Insolvency_Account__r.Insolvency__c);
                                Decimal assignToORNbr = assignToDBMap.get(insolvencyCase.Assign_To__c);
                                assignToDBMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1);
                                insolvencyAssignToMap.put(insolvencyCase.Insolvency__c, assignToDBMap); 
                            }
                        }
                    }                    
                }                            
            }           
        }
        
        //Multibank
        //Open Assignment Insolvency / Insolvency Account records
        List<Open_Assignment_Insolvency__c> oais = new List<Open_Assignment_Insolvency__c>();
        List<Open_Assignment_Insolvency_Account__c> oaias = new List<Open_Assignment_Insolvency_Account__c>();
        
        //Query and populate Insolvency records
        for(Insolvency__c insolvencyToUpdate : insolvenciesToUpdate){
            
            //Existing Scotia Logic
            //Integer caseCFGCount = insolvencyCFGCasesMap.get(insolvencyToUpdate.Id);
            //insolvencyToUpdate.CFG_Open_Cases__c = caseCFGCount;
            
            //Integer caseScotiaCount = insolvencyScotiaCasesMap.get(insolvencyToUpdate.Id);
            //insolvencyToUpdate.Scotia_Open_Cases__c = caseScotiaCount;
            //
            
            //Multi Bank
            Map<String, Decimal> assignToMap = insolvencyAssignToMap.get(insolvencyToUpdate.Id);
            System.debug('insolvencyAssignToMap.get(insolvencyToUpdate.Id) :'+assignToMap);
            System.debug('assignToMap.KeySet() :'+assignToMap.KeySet());
            for (String assignToName : assignToMap.KeySet()){
                
                if(config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)){
                    Decimal nmbrOpnAssgn = assignToMap.get(assignToName); 
                    if(nmbrOpnAssgn != null && nmbrOpnAssgn > 0){
                        Open_Assignment_Insolvency__c oai = new Open_Assignment_Insolvency__c();
                        oai.Insolvency__c = insolvencyToUpdate.Id;
                        oai.Assign_To_Name__c = assignToName;
                        oai.Number_of_Open_Assignments__c = nmbrOpnAssgn;
                        System.debug('oai.Assign_To_Name__c :'+oai.Assign_To_Name__c);
                        System.debug('oai.Number_of_Open_Assignments__c :'+oai.Number_of_Open_Assignments__c);  
                    
                        oais.add(oai);  
                    }  
                }           
            }
        }
        
        //Query and populate Insolvency records
        for(Insolvency_Account__c insolvencyAccntToUpdate : insolvencyAccountsToUpdate){
            
            //Existing Scotia Logic
            //Integer caseCFGCount = insolvencyAccntCFGCasesMap.get(insolvencyAccntToUpdate.Id);
            //insolvencyAccntToUpdate.CFG_Open_Cases__c = caseCFGCount;     
            
            //Integer caseScotiaCount = insolvencyAccntScotiaCasesMap.get(insolvencyAccntToUpdate.Id);
            //insolvencyAccntToUpdate.Scotia_Open_Cases__c = caseScotiaCount; 
            
            //Multi Bank
            Map<String, Decimal> assignToIAccMap = insolvencyAccntAssignToMap.get(insolvencyAccntToUpdate.Id);
            for (String assignToName : assignToIAccMap.KeySet()){
                if(config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)){
                    Decimal nmbrOpnAssgn = assignToIAccMap.get(assignToName);  
                    if(nmbrOpnAssgn != null && nmbrOpnAssgn > 0){
                        Open_Assignment_Insolvency_Account__c oaia = new Open_Assignment_Insolvency_Account__c();
                        oaia.Insolvency_Account__c = insolvencyAccntToUpdate.Id;
                        oaia.Assign_To_Name__c = assignToName;
                        oaia.Number_of_Open_Assignments__c = nmbrOpnAssgn;  
                        System.debug('oaia.Assign_To_Name__c :'+oaia.Assign_To_Name__c);
                        System.debug('oaia.Number_of_Open_Assignments__c :'+oaia.Number_of_Open_Assignments__c);
                    
                        oaias.add(oaia);
                    }
                }   
            }        
        }
        
        //runas API User
        //System.runAs(apiUser){
        
          //Multibank
          //Delete Open Assignment records
          Delete [Select id from Open_Assignment_Insolvency__c where Insolvency__c IN : insolvencyIds];
          Delete [Select id from Open_Assignment_Insolvency_Account__c where Insolvency_Account__c in : insolvencyAccountIds];
          
          //Multibank
          //Insert Open Assignment records
          if(oais.size() > 0){
              upsert oais;
          }  
          if(oaias.size() > 0){
              upsert oaias;
          } 
          
          //Update Insolvency records
          //Existing Scotia Logic
          //if(insolvenciesToUpdate.size() > 0){
          //    InsolvencyTriggerHandler.runInsolvencyTrigger = false;
          //    update insolvenciesToUpdate;
          //    InsolvencyTriggerHandler.runInsolvencyTrigger = true;
          //}
          
          
          //Update Insolvency records
          //if(insolvencyAccountsToUpdate.size() > 0){
          //    InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
          //    update insolvencyAccountsToUpdate;
          //    InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
          //}
          
          //Existing Scotia Logic
          //
          //if(!insolvencyAccountsToUpdate.isEmpty()){
          //    bypassInsolvancyAccountValidationAndUpdate(insolvencyAccountsToUpdate);
          //}
        //}
    }
    */
    
    //Utility method to update Insolvency Account status when Case is created
    /*
    public static void updateInsolvancyAccountStatus(List<Case> caseList){
       
        //Set of unique Insolvency Account Ids from Cases
        Set<Id> insolvencyAccountIds = new Set<Id>();
        
        //Populate set of unique Insolvency Ids and Insolvency Account Ids
        for(Case cse : caseList){
                if(cse.Insolvency_Account__c != null && cse.Insolvency_Assignment_Type__c == 'Account Validation'){
                    insolvencyAccountIds.add(cse.Insolvency_Account__c);
                }
        }
        
        List<Insolvency_Account__c> insolvAccList =  [Select id, Insolvency__c, Insolvency_Status__c
                                                        from Insolvency_Account__c 
                                                        where 
                                                        Id IN : insolvencyAccountIds ];
        
        // Update insolvancy account status to For Owner Review
        DateTime dtNow = System.now();
        for(Insolvency_Account__c insolvAcc : insolvAccList){
            insolvAcc.Insolvency_Status__c = 'For Owner Review';
            insolvAcc.Insolvency_Status_Last_Changed__c = dtNow;
        }
        
        if(!insolvAccList.isEmpty()){
            bypassInsolvancyAccountValidationAndUpdate(insolvAccList);
        }
    }
    */
    
    //Utility method to update Insolvency Account status when Case is closed
    /*
    public static void updateInsolvancyAccountStatusOnCaseClosed(List<Case> caseList, Map<Id, Case> oldMap){
         //Set of unique Insolvency Account Ids from Cases
        Set<Id> insolvencyAccountIds = new Set<Id>();
        
        //Populate set of unique Insolvency Ids and Insolvency Account Ids
        for(Case cse : caseList){
            if(cse.Insolvency_Account__c != null && cse.Status != oldMap.get(cse.Id).Status && cse.Status == 'Closed'){
                if(cse.Insolvency_Assignment_Type__c == 'Account Validation'){
                    insolvencyAccountIds.add(cse.Insolvency_Account__c);
                }                    
            }            
        }
        
        List<Insolvency_Account__c> insolvAccList =  [Select id, Insolvency__c, Insolvency_Status__c
                                                        from Insolvency_Account__c 
                                                        where 
                                                        Id IN : insolvencyAccountIds ];
        
        // Update insolvancy account status to For Owner Review
        DateTime dtNow = System.now();
        for(Insolvency_Account__c insolvAcc : insolvAccList){
            insolvAcc.Insolvency_Status__c = 'PoC Details Provided';
            insolvAcc.Insolvency_Status_Last_Changed__c = dtNow;
        }
        
        if(!insolvAccList.isEmpty()){
             bypassInsolvancyAccountValidationAndUpdate(insolvAccList);
        }        
    }
    */
    
    // By pass validation rules on Insolvency Account and update
    /*
    public static void bypassInsolvancyAccountValidationAndUpdate(List<Insolvency_Account__c> insolvAccList){
         //Don't run validation rules
        Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c ];
        
        // Read and store actuall value about running validation rule
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        
        //Run InsolvencyAccountTrigger
        //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        try{
            update insolvAccList;
            
            // Revert back custom setting value with previous value
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;          
            
            //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        }
        catch(Exception ex){
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        }
    }
    */
}