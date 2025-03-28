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

    public static Application_Config_Settings__c config; // = Application_Config_Settings__c.getOrgDefaults();

    //Record Types
    public static Map<String, Id> caseRecorTypeMap;
    public static Map<String, String> caseRTMap = new Map<String, String>();

    //Return Case Record Type Id DeveloperName Map
    public static Map<String, Id> getCaseRecorTypeMap() {
        Map<String, Id> caseRecorTypeMap = new Map<String, Id>();

        //Fetch Record Type list of Case
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sobjecttype = 'Case'];
        for (RecordType recordType : recordTypes) {
            caseRecorTypeMap.put(recordType.DeveloperName, recordType.Id);
        }
        return caseRecorTypeMap;
    }

    static {
        //apiUser = [Select id from user where UserName =: config.API_User__c];
        caseRecorTypeMap = getCaseRecorTypeMap();

        caseRTMap.put('Scotia Bank', 'Insolvency_Scotia_Community_Case');
        caseRTMap.put('SPL', 'Insolvency_SPL_Community_Case');
        caseRTMap.put('SDA', 'Insolvency_SDA_Community_Case');
        caseRTMap.put('CFG', 'Insolvency_Case');
        caseRTMap.put('Fairstone', 'Insolvency_Fairstone_Community_Case');
        caseRTMap.put('Goeasy', 'Insolvency_Goeasy_Community_Case');
        caseRTMap.put('Canadian Tire', 'Insolvency_Canadian_Tire_Community_Case');
        caseRTMap.put('Money Mart', 'Insolvency_Money_Mart_Community_Case');
        caseRTMap.put('Flexiti', 'Insolvency_Flexiti_Community_Case');

        //Remittance
        caseRTMap.put('Remittance', 'Remittance');
        caseRTMap.put('CCS Dividend', 'CCS_Dividend');

        //For CCS Records : Added on 29/03/19 - Chetan Gaikwad
        caseRTMap.put('CCS Case', 'CCS_Case');
        caseRTMap.put('Flexiti CCS Case', 'Flexiti_CCS_Case');
    }

    //Before Case is cretaed
    public static void handleBeforeInsert(List<Case> casesNew) {
        list<case> oldCaseList = new List<case>();
        //case caseObj = casesNew[0];
        List<String> listOfSubject = new List<String>();
        List<Case> listOfCasesToClose = new List<Case>();
        List<Case> casesWithSubject = new List<Case>();
        Map<String, List<Case>> mapOfSubjectWithCases = new Map<String, List<Case>>();
        for (Case caseNew : casesNew) {
            listOfSubject.add(caseNew.Subject);
        }
        List<Case> listOfOldCases = [
            SELECT id, Subject
            FROM Case
            WHERE Subject IN :listOfSubject AND Status != 'Closed' AND Status != 'Completed'
            ORDER BY CreatedDate DESC
        ]; //Older record last
        for (Case oldCase : listOfOldCases) {
            casesWithSubject.add(oldcase);
            mapOfSubjectWithCases.put(oldCase.Subject, casesWithSubject);
        }
        for (Case caseNew : casesNew) {
            //Remittance + CCS Case condition added on 29/03/19 - Chetan Gaikwad
            if (
                caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
                caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case') &&
                caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Dividend')
            ) {
                if (String.isNotBlank(caseNew.Assign_To__c)) {
                    caseNew.Entity_Identifiers__c = caseNew.Assign_To__c;
                }
                //Update Record Type based on Client Identifier
                //caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));
                if (caseNew.Assign_To__c != 'CFG' && caseNew.Assign_To__c != 'Canaccede' && caseNew.Assign_To__c != 'Flexiti') {
                    caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));
                }

                if (caseNew.recordTypeID == caseRecorTypeMap.get('EmailToCase')) {
                    caseNew.Is_Email_to_Case__c = true;
                    if (caseNew.Form_Types__c == 'Creditor Package') {
                        List<Case> oldCaseRecord = mapOfSubjectWithCases.get(caseNew.Subject);
                        Integer oldCaseRecordCount = oldCaseRecord.size(); //5
                        if (oldCaseRecordCount > 0) {
                            caseNew.Status = 'Closed'; //New Record
                            //listOfCasesToClose.add(caseNew);
                            for (Case caseRec : oldCaseRecord) {
                                if (oldCaseRecordCount != 1) {
                                    caseRec.Status = 'Closed';
                                    listOfCasesToClose.add(caseRec);
                                    oldCaseRecordCount--; //4,3,2,1
                                }
                            }
                        }
                    }
                }
            } else if (caseNew.recordTypeID == caseRecorTypeMap.get('Remittance') || caseNew.recordTypeID == caseRecorTypeMap.get('CCS_Dividend')) {
                //Modified - Chetan Gaikwad 1/4/19
                caseNew.status = 'Closed';
            } else if (caseNew.recordTypeID == caseRecorTypeMap.get('CCS_Case')) {
                CaseNew.Is_Email_to_Case__c = true; //for Email to Case for CCS
            }
        }
        update listOfCasesToClose; // this is added for 5302
    }

    //Before Case is updated
    public static void handleBeforeUpdate(List<Case> casesNew, Map<Id, Case> oldMap) {
        for (Case caseNew : casesNew) {
            //Remittance + [CCS Case condition added on 29/03/19 - Chetan Gaikwad]
            if (
                caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
                caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case') &&
                caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Dividend')
            ) {
                //Case being updated
                Case caseOld = oldMap.get(caseNew.id);

                if (caseNew.recordTypeID == caseRecorTypeMap.get('EmailtoCase')) {
                    if (caseOld.status != 'DocParser Processing' && caseNew.status == 'DocParser Processing') {
                        caseNew.Parser_Sent_DateTime__c = system.now();
                    }
                }

                //Existing identifier
                String entityIdentifiers = '';
                if (String.isNotBlank(caseNew.Entity_Identifiers__c)) {
                    entityIdentifiers = caseNew.Entity_Identifiers__c;
                }

                //Assign_To on old case
                if (String.isNotBlank(caseOld.Assign_To__c)) {
                    if (!entityIdentifiers.contains(caseOld.Assign_To__c)) {
                        entityIdentifiers = entityIdentifiers + ',' + caseOld.Assign_To__c;
                    }
                }

                //Assign_To on new case
                if (String.isNotBlank(caseNew.Assign_To__c)) {
                    if (!entityIdentifiers.contains(caseNew.Assign_To__c)) {
                        entityIdentifiers = entityIdentifiers + ',' + caseNew.Assign_To__c;
                    }
                }

                //Remove unwanted ,
                if (entityIdentifiers.startsWith(',')) {
                    entityIdentifiers = entityIdentifiers.removeStart(',');
                }
                if (entityIdentifiers.endsWith(',')) {
                    entityIdentifiers = entityIdentifiers.removeEnd(',');
                }
                //Update Entity_Identifiers__c
                caseNew.Entity_Identifiers__c = entityIdentifiers;
                if (caseNew.Assign_To__c != caseOld.Assign_To__c && caseNew.Assign_To__c != 'Canaccede') {
                    if (caseNew.Assign_To__c != 'CFG') {
                        caseNew.RecordTypeID = caseRecorTypeMap.get(caseRTMap.get(caseNew.Assign_To__c));
                    }
                }
            }
        }
    }

    //After new Case is created
    public static void handleAfterInsert(List<Case> casesNewList) {
        Case caseNew = casesNewList.get(0);
        //Remittance + [CCS Case condition added on 29/03/19 - Chetan Gaikwad]
        if (
            caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') &&
            caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case') &&
            caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Dividend')
        ) {
            if (caseNew.Insolvency__c != null) {
                calculateNumberOfOpenCasesIns(caseNew.Insolvency__c);
            } else if (caseNew.Insolvency_Account__c != null) {
                calculateNumberOfOpenCasesInsAccnt(caseNew.Insolvency_Account__c);
            }
        } else if (caseNew.recordTypeID == caseRecorTypeMap.get('Remittance')) {
            //Modified on 29/03/19 - Chetan Gaikwad
            //Create new Insolvency Remittance record
            Remittance__c remittance = new Remittance__c();
            remittance.Status__c = 'New';
            remittance.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' AND sobjecttype = 'Remittance__C'].Id;
            remittance.Email_to_Case_Reference_Number__c = caseNew.Id;
            insert remittance;
        } else if (caseNew.recordTypeID == caseRecorTypeMap.get('CCS_Dividend')) {
            //updated on 4th April 2019 Swapnil Kulkarni
            //Create CCS Remittance record
            Remittance__c remittance = new Remittance__c();
            remittance.Status__c = 'New';
            remittance.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'CCS_Dividend' AND sobjecttype = 'Remittance__C'].Id;
            remittance.Email_to_Case_Reference_Number__c = caseNew.Id;
            insert remittance;
        } else {
            //Add the code for CCS Case here
        }
    }

    //After Case is updated
    public static void handleAfterUpdate(List<Case> casesNew, Map<Id, Case> oldMap) {
        Case caseNew = casesNew.get(0);
        Case caseOld = oldMap.get(caseNew.id);
        //Remittance + [CCS Case condition added 29/03/19 - Chetan Gaikwad]
        if (caseNew.recordTypeID != caseRecorTypeMap.get('Remittance') && caseNew.recordTypeID != caseRecorTypeMap.get('CCS_Case')) {
            //Checks whether to run the trigger
            if ((caseNew.status != caseOld.status) || (caseNew.Assign_To__c != caseOld.Assign_To__c) || (caseNew.RecordTypeID != caseOld.RecordTypeID)) {
                if (caseNew.Insolvency__c != null) {
                    calculateNumberOfOpenCasesIns(caseNew.Insolvency__c);
                } else if (caseNew.Insolvency_Account__c != null) {
                    calculateNumberOfOpenCasesInsAccnt(caseNew.Insolvency_Account__c);
                }
            }
        }
    }

    //After Case is Deleted
    public static void handleAfterDelete(List<Case> casesNew, Map<Id, Case> oldMap) {
        List<Case> casesToProcess = new List<Case>();
        Set<Id> casesIds = oldMap.keySet();
        for (Id caseId : casesIds) {
            casesToProcess.add(oldMap.get(caseId));
        }
        Case caseOld = casesToProcess.get(0);
        //Remittance + [CCS Case condition added 29/03/19 - Chetan Gaikwad]
        if (caseOld.recordTypeID != caseRecorTypeMap.get('Remittance') && caseOld.recordTypeID != caseRecorTypeMap.get('CCS_Case')) {
            if (caseOld.Insolvency__c != null) {
                calculateNumberOfOpenCasesIns(caseOld.Insolvency__c);
            } else if (caseOld.Insolvency_Account__c != null) {
                calculateNumberOfOpenCasesInsAccnt(caseOld.Insolvency_Account__c);
            }
        }
    }

    //Calculate number of open cases on Insolvency
    private static void calculateNumberOfOpenCasesIns(Id insId) {
        config = [SELECT Eligible_for_Open_Assignment_Calculation__c FROM Application_Config_Settings__c];
        //Related Open Cases
        List<Case> insolvencyCases = [
            SELECT id, Assign_To__c
            FROM Case
            WHERE
                status != 'Closed'
                AND ((Insolvency__c != NULL
                AND Insolvency__c = :insId)
                OR (Insolvency_Account__c != NULL
                AND Insolvency_Account__r.Insolvency__c != NULL
                AND Insolvency_Account__r.Insolvency__c = :insId))
        ];

        //Assigned to vs count map
        Map<String, Decimal> assignToCountMap = new Map<String, Decimal>();
        List<Schema.PicklistEntry> pikListValues = Case.Assign_To__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pikListValue : pikListValues) {
            assignToCountMap.put(pikListValue.getValue(), 0);
        }

        //Calculate count
        for (Case insolvencyCase : insolvencyCases) {
            if (config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)) {
                Decimal assignToORNbr = assignToCountMap.get(insolvencyCase.Assign_To__c);
                assignToCountMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1);
            }
        }

        //Initialize Child records
        List<Open_Assignment_Insolvency__c> oais = new List<Open_Assignment_Insolvency__c>();
        for (String assignToName : assignToCountMap.KeySet()) {
            if (config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)) {
                Decimal nmbrOpnAssgn = assignToCountMap.get(assignToName);
                if (nmbrOpnAssgn != null && nmbrOpnAssgn > 0) {
                    Open_Assignment_Insolvency__c oai = new Open_Assignment_Insolvency__c();
                    oai.Insolvency__c = insId;
                    oai.Assign_To_Name__c = assignToName;
                    oai.Number_of_Open_Assignments__c = nmbrOpnAssgn;

                    oais.add(oai);
                }
            }
        }

        InsolvencyTriggerHandler.runInsolvencyTrigger = false;
        //Delete existing child records
        delete [
            SELECT id
            FROM Open_Assignment_Insolvency__c
            WHERE Insolvency__c = :insId
        ];

        //Insert Child records
        if (oais.size() > 0) {
            upsert oais;
        }
        InsolvencyTriggerHandler.runInsolvencyTrigger = true;
    }

    //Calculate number of open cases on Insolvency Account
    private static void calculateNumberOfOpenCasesInsAccnt(Id insAccntId) {
        config = [SELECT Eligible_for_Open_Assignment_Calculation__c FROM Application_Config_Settings__c];
        //Related Open Cases
        List<Case> insolvencyCases = [
            SELECT id, Assign_To__c
            FROM Case
            WHERE status != 'Closed' AND Insolvency_Account__c != NULL AND Insolvency_Account__c = :insAccntId
        ];

        //Assigned to vs count map
        Map<String, Decimal> assignToCountMap = new Map<String, Decimal>();
        List<Schema.PicklistEntry> pikListValues = Case.Assign_To__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pikListValue : pikListValues) {
            assignToCountMap.put(pikListValue.getValue(), 0);
        }

        //Calculate count
        for (Case insolvencyCase : insolvencyCases) {
            if (config.Eligible_for_Open_Assignment_Calculation__c.contains(insolvencyCase.Assign_To__c)) {
                Decimal assignToORNbr = assignToCountMap.get(insolvencyCase.Assign_To__c);
                assignToCountMap.put(insolvencyCase.Assign_To__c, assignToORNbr + 1);
            }
        }

        //Initialize Child records
        List<Open_Assignment_Insolvency_Account__c> oaias = new List<Open_Assignment_Insolvency_Account__c>();
        for (String assignToName : assignToCountMap.KeySet()) {
            if (config.Eligible_for_Open_Assignment_Calculation__c.contains(assignToName)) {
                Decimal nmbrOpnAssgn = assignToCountMap.get(assignToName);
                if (nmbrOpnAssgn != null && nmbrOpnAssgn > 0) {
                    Open_Assignment_Insolvency_Account__c oaia = new Open_Assignment_Insolvency_Account__c();
                    oaia.Insolvency_Account__c = insAccntId;
                    oaia.Assign_To_Name__c = assignToName;
                    oaia.Number_of_Open_Assignments__c = nmbrOpnAssgn;

                    oaias.add(oaia);
                }
            }
        }

        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        //Delete existing child records
        delete [
            SELECT id
            FROM Open_Assignment_Insolvency_Account__c
            WHERE Insolvency_Account__c = :insAccntId
        ];

        //Insert Child records
        if (oaias.size() > 0) {
            upsert oaias;
        }

        //Calculate number of open cases on related Insolvency records
        List<Insolvency_Account__c> insAccnts = [
            SELECT Id, Insolvency__c
            FROM Insolvency_Account__c
            WHERE Id = :insAccntId
        ];

        if (insAccnts.Size() > 0) {
            Id insId = insAccnts.get(0).Insolvency__c;
            if (insId != null) {
                calculateNumberOfOpenCasesIns(insId);
            }
        }
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
    }
}
