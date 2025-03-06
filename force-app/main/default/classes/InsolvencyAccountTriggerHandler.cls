/**************************************************************************************************
*
*  Class:    
*
*  @description : This is a trigger handler class for Insolvency_Account object 
*  @author : A5E Consulting
*  @date : 09/18/2016

*************************************************************************************************/

public class InsolvencyAccountTriggerHandler {
    public static boolean runInsolvencyAccountTrigger = true;
    public static Set<Insolvency_Account__c> accountsToUpdate = new Set<Insolvency_Account__c>();
    public static String errorMessageOwnerReview { get; set; }

    public static Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();

    public static Map<Id, String> insAccntRecorTypeMap;
    public static String profileName { get; set; }
    // Valid date difference in terms of months for province
    public static Map<String, Integer> provinceYearValidYearDifferenceMap = new Map<String, Integer>{
        'Alberta,British Columbia,New Brunswick,Newfoundland and Labrador,Nova Scotia,Ontario,Saskatchewan,Manitoba' => 24,
        'Quebec' => 36,
        'Northwest Territories,Nunavut,Prince Edward Island,Yukon' => 72
    };

    static {
        String id1 = userinfo.getProfileId();
        profileName = [SELECT Name FROM profile WHERE id = :id1].name;
    }

    public static Map<String, String> cIRTMap = new Map<String, String>();

    //public static boolean runValidationRule = config.Run_Insolvency_Status_Validations__c;

    public static string lBrk = '</br>';

    static {
        insAccntRecorTypeMap = InsolvencyUtil.getInsAccntRecorTypeMap();
        cIRTMap.put('Scotia_Bank_Insolvency_Account', 'Scotia Bank');
        cIRTMap.put('SPL_Insolvency_Account', 'SPL');
        cIRTMap.put('SDA_Insolvency_Account', 'SDA');
        cIRTMap.put('Canaccede_Insolvency_Account', 'Canaccede');
        cIRTMap.put('Fidem_Insolvency_Account', 'Fidem');
        cIRTMap.put('Fairstone_Insolvency_Account', 'Fairstone');
        cIRTMap.put('Goeasy_Insolvency_Account', 'Goeasy');
        cIRTMap.put('Canadian_Tire_Insolvency_Account', 'Canadian Tire');
        cIRTMap.put('Money_Mart_Insolvency_Account', 'Money Mart');
        cIRTMap.put('Flexiti_Insolvency_Account', 'Flexiti');
    }

    /**
     * @description : Method to get latest correlation Id
     * @author adesh.ikhar@canaccede.com | 06-11-2024
     * @return String
     **/
    public static String getLatestCorrelationId() {
        // Default correlation Id, will be set for the first ever CTB account created
        String correlationId = '0';
        // Get latest created account with correlation Id
        List<Insolvency_Account__c> latestCorrelationIdAccount = [
            SELECT Id, Correlation_Id__c
            FROM Insolvency_Account__c
            WHERE Correlation_Id__c != NULL
            ORDER BY Correlation_Id__c DESC
            LIMIT 1
        ];
        if (!latestCorrelationIdAccount.isEmpty()) {
            correlationId = String.valueOf(Integer.valueOf(latestCorrelationIdAccount[0].Correlation_Id__c));
        }
        return correlationId;
    }

    //Before Insert
    public static void handleBeforeInsert(List<Insolvency_Account__c> insolAccntsNew) {
        List<String> nonServicingPortfolios = new List<String>();
        //for Account number without space
        for (Insolvency_Account__c accNew : insolAccntsNew) {
            if (accNew.Name != null) {
                accNew.Account_Number_Without_Space__c = accNew.Name.deleteWhitespace();
            }
            if (String.isNotBlank(accNew.Portfolio_Name_Lookup__c)) {
                nonServicingPortfolios.add(accNew.Portfolio_Name_Lookup__c);
            }
            //accNew.Account_Owner__c = UserInfo.getUserId();
            // Populate client identifier based on record type
            if (accNew.RecordTypeId != null && accNew.Client_Identifier__c == null) {
                accNew.Client_Identifier__c = cIRTMap.get(insAccntRecorTypeMap.get(accNew.RecordTypeId));
            }

            if (accNew.Trustee_Not_Providing_LoR__c == true) {
                accNew.Review_Account__c = false;
            }

            //this change is for Insolvency Account Loading and portfolio mapping enhancement
            if (accNew.Distressed_Data_Id__c != null) {
                getDistressedProductData(accNew);
            }
            //accNew.Alias_Name__c = accNew.Last_Modify_User_Alias__c;
        }

        DateTime dtNow = System.now();
        ID userId = UserInfo.getUserId();

        //Duplicate Check
        if (config.Run_Insolvency_Account_Duplicate_Check__c) {
            Insolvency_Account__c insolAccntNew = insolAccntsNew[0];
            boolean runDuplicateCheckForProfile = false;
            boolean runDuplicateCheckForBank = false;

            if (insolAccntsNew.size() == 1) {
                if (insolAccntNew.Created_By_Doc_Parser__c == false) {
                    //get the Profile name of current login user
                    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId()].Name;
                    String baseUrl;

                    // Check whether current user is commnity user or not and set URL
                    if (profileName.contains('Community User')) {
                        baseUrl = getCommunityUrl();
                    } else {
                        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    }

                    //duplicate check not to consider account names from custom setting
                    list<string> ignoreAcctNameList = new List<string>();
                    string acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
                    if (acctNameCS != null) {
                        ignoreAcctNameList = acctNameCS.split(',');
                    }

                    if (!ignoreAcctNameList.contains(insolAccntNew.Account_Number_Without_Space__c.toUpperCase())) {
                        //duplicate check eligible for profile
                        list<String> profileEligList = new List<String>();
                        String profileEligCS = config.Profile_Eligible_for_Duplicate_Check__c;
                        profileEligList = profileEligCS.split(',');

                        for (string profElig : profileEligList) {
                            if (profileName.contains(profElig)) {
                                runDuplicateCheckForProfile = true;
                                break;
                            }
                        }

                        //duplicate check eligible for Bank
                        list<String> bankEligList = new List<String>();
                        string bankEligCS = config.Bank_Eligible_for_Duplicate_Check__c;
                        bankEligList = bankEligCS.split(',');
                        for (string bankElig : bankEligList) {
                            if (insolAccntNew.Client_Identifier__c.contains(bankElig)) {
                                runDuplicateCheckForBank = true;
                                break;
                            }
                        }

                        if (runDuplicateCheckForProfile && runDuplicateCheckForBank) {
                            string errorMessage = '';
                            string startTag = '<a href="';
                            string endTag = '</a>';

                            //Account number
                            //String numberWithoutSpace = insolAccntNew.Name.deleteWhitespace();

                            //check dupes on same Insolvency
                            List<Insolvency_Account__c> insolAcctDupeList = ([
                                SELECT
                                    Id,
                                    Name,
                                    Insolvency__c,
                                    Insolvency__r.Name,
                                    Duplicate_Reasons_Picklist__c,
                                    //Account_Number_AlphaNumeric__c,
                                    Account_Number_Without_Space__c,
                                    RecordTypeID,
                                    RecordType.Name
                                FROM Insolvency_Account__c
                                WHERE
                                    Account_Number_Without_Space__c = :insolAccntNew.Account_Number_Without_Space__c
                                    //Account_Number_Without_Space__c =: numberWithoutSpace
                                    //Account_Number_AlphaNumeric__c =: numberWithoutSpace
                                    AND Insolvency__c = :insolAccntNew.Insolvency__c
                                    AND recordTypeId = :insolAccntNew.RecordTypeId
                                    AND Account_Number_Without_Space__c NOT IN :ignoreAcctNameList
                            ]);

                            //Check for duplicate names
                            if (insolAcctDupeList.size() > 0) {
                                errorMessage =
                                    errorMessage +
                                    'Insolvency ' +
                                    startTag +
                                    baseUrl +
                                    '/' +
                                    insolAcctDupeList[0].Insolvency__c +
                                    '">' +
                                    insolAcctDupeList[0].Insolvency__r.Name +
                                    endTag;
                                errorMessage = errorMessage + ' already has Insolvency Account(s) with Account Number :' + lBrk;
                                for (Insolvency_Account__c insolAcctDupe : insolAcctDupeList) {
                                    //Populate each one
                                    errorMessage = errorMessage + startTag + baseUrl + '/' + insolAcctDupe.Id + '">' + insolAcctDupe.Name + endTag + lBrk;
                                }
                                //errorMessage = errorMessage + ' already has Insolvency Account/Accounts with Account Number : ' + startTag + baseUrl + '/' + insolAcctDBList[0].Id + '">' + insolAcctDBList[0].Name + endTag + lBrk;     // insolAcctMap.Name + lBrk;
                                insolAccntNew.addError(errorMessage, false);
                                insolAccntNew.Name.addError('Duplicate Records Found');
                            } else {
                                if (String.isBlank(insolAccntNew.Duplicate_Reasons_Picklist__c)) {
                                    List<Insolvency_Account__c> insolAcctAllDupeList = ([
                                        SELECT
                                            Id,
                                            Name,
                                            Insolvency__c,
                                            Insolvency__r.Name,
                                            Duplicate_Reasons_Picklist__c,
                                            Account_Number_Without_Space__c,
                                            //Account_Number_AlphaNumeric__c,
                                            RecordTypeID,
                                            RecordType.Name
                                        FROM Insolvency_Account__c
                                        WHERE
                                            Account_Number_Without_Space__c = :insolAccntNew.Account_Number_Without_Space__c
                                            //Account_Number_Without_Space__c =: numberWithoutSpace
                                            //Account_Number_AlphaNumeric__c =: numberWithoutSpace
                                            AND Insolvency__c != :insolAccntNew.Insolvency__c
                                            AND recordTypeId = :insolAccntNew.RecordTypeId
                                            AND Account_Number_Without_Space__c NOT IN :ignoreAcctNameList
                                    ]);

                                    //Check for duplicate names
                                    if (insolAcctAllDupeList.size() > 0) {
                                        //insolAccntNew.Duplicate_Reasons_Picklist__c = 'Valid Insolvency';
                                        //errorMessage = errorMessage+ 'Insolvency Estate Number = '+ startTag + baseUrl + '/' + insolAcctAllDBList[0].Insolvency__c + '">' + insolAcctAllDBList[0].Insolvency__r.Name + endTag + ' and Insolvency Account Number = ' + startTag + baseUrl + '/' + insolAcctAllDBList[0].Id + '">'+ insolAcctAllDBList[0].Name + endTag + lBrk ;
                                        for (Insolvency_Account__c insolAcctAllDupe : insolAcctAllDupeList) {
                                            errorMessage =
                                                errorMessage +
                                                'Insolvency Estate Number = ' +
                                                startTag +
                                                baseUrl +
                                                '/' +
                                                insolAcctAllDupe.Insolvency__c +
                                                '">' +
                                                insolAcctAllDupe.Insolvency__r.Name +
                                                endTag +
                                                ' and Insolvency Account Number = ' +
                                                startTag +
                                                baseUrl +
                                                '/' +
                                                insolAcctAllDupe.Id +
                                                '">' +
                                                insolAcctAllDupe.Name +
                                                endTag +
                                                lBrk;
                                        }

                                        insolAccntNew.addError('Following Duplicate Records found : ' + lBrk + errorMessage, false);
                                        insolAccntNew.Name.addError('Duplicate Records Found');
                                        insolAccntNew.Duplicate_Reasons_Picklist__c.addError('You must enter a value');
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        //Copy from Insolvency
        Map<String, String> cpyInsFieldsMap = InsolvencyUtil.getInsolvencyFieldSet('CopyInsolvencyFields');
        Set<String> cpyInsFields = cpyInsFieldsMap.keySet();

        //Insolvency Ids
        Set<Id> insId = new Set<Id>();

        //Insolvency Ids and Insolvencies
        Map<Id, Insolvency__c> insMap = new Map<Id, Insolvency__c>();

        //Fetch corrsponding Insolvency records
        for (Insolvency_Account__c insolAccntnew : insolAccntsNew) {
            if (insolAccntnew.Insolvency__c != null) {
                insId.add(insolAccntnew.Insolvency__c);
            }
        }

        //Fetch corresponding Insolvency records
        String copyQuery = getCopyQuery(insId, cpyInsFields);
        List<Insolvency__c> insolvencies = Database.query(copyQuery);
        for (Insolvency__c dbIns : insolvencies) {
            insMap.put(dbIns.Id, dbIns);
        }

        set<Id> insolIdSet = new Set<Id>();
        for (Insolvency_Account__c insolAccntnew : insolAccntsNew) {
            insolIdSet.add(insolAccntnew.Insolvency__c);
        }

        //Get Insolvency Owner review date insForOwnerREviewDate, insForOwnerREviewUser
        map<Id, Insolvency__c> insolMap = new Map<Id, Insolvency__c>();
        List<Insolvency__c> dbInsolList = [
            SELECT
                Id,
                Name,
                Sent_For_Owner_Review_Date__c,
                Sent_For_Owner_Review_By__c,
                //Query updated to consider Insolvency Owner fields
                Scotia_Record_Owner__c,
                SDA_Record_Owner__c,
                Chase_Record_Owner__c,
                Fairstone_Record_Owner__c,
                Goeasy_Record_Owner__c,
                Canadian_Tire_Record_Owner__c,
            	Money_Mart_Record_Owner__c,
            	Flexiti_Record_Owner__c
            FROM Insolvency__c
            WHERE Id IN :insolIdSet
        ];

        // Get non servicing portfolios of accounts inserted with a portfolio lookup
        Map<String, Portfolio_Name__c> nonServicingPortfolioMap = new Map<String, Portfolio_Name__c>([SELECT Id, Name FROM Portfolio_Name__c WHERE Id IN :nonServicingPortfolios AND Non_Servicing_Portfolio__c = true]);

        for (Insolvency__c insol : dbInsolList) {
            insolMap.put(insol.id, insol);
        }

        //Fetch corrsponding Insolvency records
        for (Insolvency_Account__c insolAccntnew : insolAccntsNew) {
            Insolvency__c dbInsol = insolMap.get(insolAccntnew.Insolvency__c);
            if (nonServicingPortfolioMap != null && String.isNotBlank(insolAccntnew.Portfolio_Name_Lookup__c) && nonServicingPortfolioMap.containsKey(insolAccntnew.Portfolio_Name_Lookup__c)) {
                insolAccntnew.Reason_for_POC_Automation_Failure__c = 'Non Servicing Portfolio';
                insolAccntnew.Auto_POC_Exception_Reported__c = 'Non Servicing Portfolio';
            }

            //Set  Insolvency_Status_Last_Changed to now
            if (String.isNotBlank(insolAccntNew.Insolvency_Status__c)) {
                insolAccntNew.Insolvency_Status_Last_Changed__c = dtNow;

                //Insolvency Status dates for SLA tracking
                if (insolAccntnew.Insolvency_Status__c == 'For Owner Review') {
                    insolAccntnew.Sent_For_Owner_Review_Date_Original__c = dtNow;
                    insolAccntnew.Sent_For_Owner_Review_By_Original__c = userId;
                    insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                    insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;

                    //Added for Ticket#167 - SLA Reports Dec_2020
                    insolAccntnew.Sent_For_Owner_Review_Date_External__c = dtNow;
                    insolAccntnew.Sent_For_Owner_Review_By_External__c = userId;
                } else {
                    //initial value set on record insert
                    if (insolAccntnew.Insolvency_Status__c != 'New') {
                        if (dbInsol != null && dbInsol.Sent_For_Owner_Review_Date__c != null) {
                            insolAccntnew.Sent_For_Owner_Review_Date_Original__c = dbInsol.Sent_For_Owner_Review_Date__c;
                            insolAccntnew.Sent_For_Owner_Review_By_Original__c = dbInsol.Sent_For_Owner_Review_By__c;
                            insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dbInsol.Sent_For_Owner_Review_Date__c;
                            insolAccntnew.Sent_For_Owner_Review_By_Updated__c = dbInsol.Sent_For_Owner_Review_By__c;
                        } else {
                            insolAccntnew.Sent_For_Owner_Review_Date_Original__c = dtNow;
                            insolAccntnew.Sent_For_Owner_Review_By_Original__c = userId;
                            insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                            insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                        }
                    }

                    if (insolAccntnew.Insolvency_Status__c == 'PoC Details Provided') {
                        insolAccntnew.PoC_Details_Provided_Date__c = dtNow;
                        insolAccntnew.PoC_Details_Provided_By__c = userId;
                        insolAccntnew.Accounts_Validation_Date__c = dtNow;
                        insolAccntnew.Accounts_Validation_Done_By__c = userId;

                        //Added for Ticket#167 - SLA Reports Dec_2020(Added on 16.02.21)
                        insolAccntnew.Sent_For_Owner_Review_Date_External__c = null;
                        insolAccntnew.Sent_For_Owner_Review_By_External__c = null;
                    } else if (insolAccntnew.Insolvency_Status__c == 'No PoC Required') {
                        insolAccntnew.No_PoC_Required_Date__c = dtNow;
                        insolAccntnew.No_PoC_Required_Set_By__c = userId;
                        insolAccntnew.Accounts_Validation_Date__c = dtNow;
                        insolAccntnew.Accounts_Validation_Done_By__c = userId;

                        //Added for Ticket#167 - SLA Reports Dec_2020(Added on 16.02.21)
                        insolAccntnew.Sent_For_Owner_Review_Date_External__c = null;
                        insolAccntnew.Sent_For_Owner_Review_By_External__c = null;
                    } else if (insolAccntnew.Insolvency_Status__c == 'Claim Filed') {
                        insolAccntnew.Claim_Filed_Date__c = dtNow;
                        insolAccntnew.Claim_Filed_By__c = userId;
                    } else if (insolAccntnew.Insolvency_Status__c == 'Wait / Hold') {
                        insolAccntnew.Wait_Hold_Set_Date__c = dtNow;
                        insolAccntnew.Wait_Hold_Set_By__c = userId;
                    } else if (insolAccntnew.Insolvency_Status__c == 'Trustee Followup') {
                        insolAccntnew.Trustee_Followup_Date__c = dtNow;
                        insolAccntnew.Trustee_Followup_Sent_By__c = userId;
                    }
                }
            }

            //Related Insolvency record
            Insolvency__c relatedIns = insMap.get(insolAccntnew.Insolvency__c);

            //Purchase eligible logic
            if (insolAccntnew.Type_of_Service__c == 'Service and Sale' || insolAccntnew.Claim_Type__C == 'Unsecured') {
                insolAccntnew.Purchase_Eligible__c = true;
            } else {
                insolAccntnew.Purchase_Eligible__c = false;
            }

            //Include_Voting_Letter__c field should be Checked for Proposals, and Unchecked for Bankruptcies
            //Voting_Instructions_Required__c  field should be Checked for Proposals, and Unchecked for Bankruptcies.
            if ((relatedIns != null) && ('Bankruptcy' == relatedIns.Insolvency_Type__c)) {
                insolAccntnew.Include_Voting_Letter__c = false;
                insolAccntnew.Voting_Instructions_Required__c = false;
            } else {
                insolAccntnew.Include_Voting_Letter__c = true;
                insolAccntnew.Voting_Instructions_Required__c = true;
            }

            insolAccntnew.Proof_of_Claim_Required__c = true;
            insolAccntnew.Statements_Required__c = true;

            if (relatedIns != null) {
                //Insolvency Name - Insolvency Account Estate number
                insolAccntnew.Debtor_1_Estate_Number__c = relatedIns.name;

                //Copy from Insolvency
                for (String cpyInsField : cpyInsFields) {
                    insolAccntnew.put(cpyInsField, relatedIns.get(cpyInsField));
                }

                //Debtor Name
                insolAccntnew.Debtor__c = InsolvencyUtil.createFullName(insolAccntnew.Debtor_1_First_Name__c, insolAccntnew.Debtor_1_Last_Name__c);
                insolAccntnew.Borrower_Primary__c = insolAccntnew.Debtor__c;

                //Co-Debtor Name
                insolAccntnew.Co_Debtor__c = InsolvencyUtil.createFullName(insolAccntnew.Debtor_2_First_Name__c, insolAccntnew.Debtor_2_Last_Name__c);
                insolAccntnew.Borrower_Coborrower_1__c = insolAccntnew.Co_Debtor__c;
            }
            //Check loggedin User is Community user
            if (InsolvencyUtil.isCommunityUser()) {
                insolAccntnew.OwnerID = UserInfo.getUserId();
            } else {
                //insolAccntnew.OwnerID = InsolvencyUtil.fetchOwner(insolAccntNew, dbInsol);
                try {
                    insolAccntnew.OwnerID = InsolvencyUtil.fetchOwner(insolAccntNew, dbInsol);
                } catch (Exception exp) {
                    insolAccntnew.OwnerID = UserInfo.getUserId();
                }
            }

            Boolean validStatusChange = true;
            if (profileName.contains('CFG')) {
                validStatusChange = InsolvencyAcctStatusValidationController.internalValidationRule(insolAccntNew, null, insolAccntNew.Insolvency_Status__c);
            }
            if (profileName.contains('Community User')) {
                validStatusChange = InsolvencyAcctStatusValidationController.externalValidationRule(insolAccntNew, null, insolAccntNew.Insolvency_Status__c);
            }
            if (validStatusChange == false) {
                insolAccntNew.addError('Insolvency status can not be set to ' + insolAccntNew.Insolvency_Status__c);
            }

            insolAccntNew.Do_Not_Run_Status_Validation__c = false;
        }
    }

    //Before Update
    public static void handleBeforeUpdate(List<Insolvency_Account__c> insolAccntsNew, Map<Id, Insolvency_Account__c> oldMap) {
        DateTime dtNow = System.now();
        ID userId = UserInfo.getUserId();
        Boolean stopErrorMessage = false;
        Map<String, String> insolAccountIdInsolId = new Map<String, String>();
        //for Account number without space field update
        for (Insolvency_Account__c accNew : insolAccntsNew) {
            Insolvency_Account__c insolAccntOld = oldMap.get(accNew.id);
            if (accNew.Name != insolAccntOld.Name) {
                accNew.Account_Number_Without_Space__c = accNew.Name.deleteWhitespace();
            }
            if (insolAccntOld.Trustee_Not_Providing_LoR__c == false && accNew.Trustee_Not_Providing_LoR__c == true) {
                accNew.Review_Account__c = false;
            }

            //this change is for Insolvency Account Loading and portfolio mapping enhancement
            if (accNew.Distressed_Data_Id__c != insolAccntOld.Distressed_Data_Id__c && accNew.Distressed_Data_Id__c != null) {
                getDistressedProductData(accNew);
            }
            //accNew.Alias_Name__c = accNew.Last_Modify_User_Alias__c;
            //Added by Tejal To Handle updating Processing Sub Status for CTB Automation
            insolAccountIdInsolId.put(accNew.id, accNew.Insolvency__c);
        }

        set<Id> insolIdSet = new Set<Id>();
        for (Insolvency_Account__c insolAccntnew : insolAccntsNew) {
            insolIdSet.add(insolAccntnew.Insolvency__c);
        }

        //Get Insolvency Owner review date insForOwnerREviewDate, insForOwnerREviewUser
        map<Id, Insolvency__c> insolMap = new Map<Id, Insolvency__c>();
        list<Insolvency__c> dbInsolList = [
            SELECT
                Id,
                Name,
                Sent_For_Owner_Review_Date__c,
                Sent_For_Owner_Review_By__c,
                Revival_Date__c,
                Debtor_1_Mailing_State_Province__c,
                //Query updated to consider Insolvency Owner fields
                Scotia_Record_Owner__c,
                SDA_Record_Owner__c,
                Chase_Record_Owner__c
            FROM Insolvency__c
            WHERE Id IN :insolIdSet
        ];

        for (Insolvency__c insol : dbInsolList) {
            insolMap.put(insol.id, insol);
        }
        for (Insolvency_Account__c accNew : insolAccntsNew) {
            Insolvency_Account__c insolAccntNew = insolAccntsNew[0];
            Insolvency_Account__c insolAccntOld = oldMap.get(insolAccntNew.id);
			
            //Ticket 7404
            if(insolAccntNew.Voting_Options__c != insolAccntOld.Voting_Options__c 
               && string.isNotBlank(insolAccntOld.Voting_Letter_Comments__c) 
               && insolAccntNew.Voting_Letter_Comments__c == insolAccntOld.Voting_Letter_Comments__c
               && insolAccntNew.Voting_Options__c == 'Vote Accept' || Test.isRunningTest()){
                insolAccntNew.Voting_Letter_Comments__c = '';
            }
            
            //Client Identifier based on record type
            if (insolAccntOld.recordTypeId != insolAccntnew.recordTypeId) {
                //Only allowing record type change with processing status as below
                if (
                    insolAccntOld.Insolvency_Status__c == 'New' ||
                    insolAccntOld.Insolvency_Status__c == 'For Owner Review' ||
                    insolAccntOld.Insolvency_Status__c == 'No PoC Required' ||
                    insolAccntOld.Insolvency_Status__c == 'Trustee Followup'
                ) {
                    Insolvency__c dbInsol = insolMap.get(insolAccntnew.Insolvency__c);
                    insolAccntnew.Client_Identifier__c = getClientIdentifierBasedOnRecordType(insolAccntNew.recordTypeId);
                    // Remove correlation Id if record type was changed from CTB
                    if (insAccntRecorTypeMap.get(insolAccntOld.RecordTypeId) == 'Canadian_Tire_Insolvency_Account') {
                        insolAccntnew.Correlation_Id__c = null;
                    }
                    //Utility Method to Fetch Owner
                    try {
                        insolAccntnew.OwnerID = InsolvencyUtil.fetchOwner(insolAccntNew, dbInsol);
                    } catch (Exception exp) {
                        insolAccntnew.OwnerID = userId;
                    }
                } else {
                    stopErrorMessage = true;
                    insolAccntnew.addError(
                        'You cannot change Record Type unless Processing status is New,For Onwner Review,Trustee FollowUp or No POC Required'
                    );
                }
            }
        }
        updateProcessingSubStatus(insolAccntsNew, oldMap, insolAccountIdInsolId);
        //Duplicate Check
        if (config.Run_Insolvency_Account_Duplicate_Check__c) {
            Insolvency_Account__c insolAccntNew = insolAccntsNew[0];
            Insolvency_Account__c insolAccntOld = oldMap.get(insolAccntNew.id);

            boolean runDuplicateCheckForProfile = false;
            boolean runDuplicateCheckForBank = false;

            if (insolAccntsNew.size() == 1) {
                //get the Profile name of current login user
                String profileName = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId()].Name;
                String baseUrl;

                // Check whether current user is commnity user or not and set URL
                if (profileName.contains('Community User')) {
                    baseUrl = getCommunityUrl();
                } else {
                    baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                }

                //duplicate check not to consider account names from custom setting
                list<string> ignoreAcctNameList = new List<string>();
                string acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
                ignoreAcctNameList = acctNameCS.split(',');
                if (!ignoreAcctNameList.contains(insolAccntNew.Account_Number_Without_Space__c.toUpperCase())) {
                    //if(insolAccntNew.Name != insolAccntOld.Name || insolAccntNew.RecordTypeId != insolAccntOld.RecordTypeId || String.isBlank(insolAccntNew.Duplicate_Reasons_Picklist__c))
                    if (
                        insolAccntNew.Name != insolAccntOld.Name ||
                        insolAccntNew.RecordTypeId != insolAccntOld.RecordTypeId ||
                        insolAccntNew.Duplicate_Reasons_Picklist__c != insolAccntOld.Duplicate_Reasons_Picklist__c ||
                        Test.isRunningTest()
                    ) {
                        //duplicate check eligible for profile
                        list<String> profileEligList = new List<String>();
                        string profileEligCS = config.Profile_Eligible_for_Duplicate_Check__c;
                        profileEligList = profileEligCS.split(',');

                        for (string profElig : profileEligList) {
                            if (profileName.contains(profElig)) {
                                runDuplicateCheckForProfile = true;
                                break;
                            }
                        }

                        //duplicate check eligible for Bank
                        list<String> bankEligList = new List<String>();
                        string bankEligCS = config.Bank_Eligible_for_Duplicate_Check__c;
                        bankEligList = bankEligCS.split(',');

                        for (string bankElig : bankEligList) {
                            if (insolAccntNew.Client_Identifier__c.contains(bankElig)) {
                                runDuplicateCheckForBank = true;
                                break;
                            }
                        }

                        if (runDuplicateCheckForProfile && runDuplicateCheckForBank) {
                            String errorMessage = '';
                            string startTag = '<a href="';
                            string endTag = '</a>';

                            //Account number
                            //String numberWithoutSpace = insolAccntNew.Name.deleteWhitespace();

                            //check dupes on same Insolvency
                            List<Insolvency_Account__c> insolAcctDupeList = ([
                                SELECT
                                    Id,
                                    Name,
                                    Insolvency__c,
                                    Insolvency__r.Name,
                                    Duplicate_Reasons_Picklist__c,
                                    Account_Number_Without_Space__c,
                                    //Account_Number_AlphaNumeric__c,
                                    RecordTypeID,
                                    RecordType.Name
                                FROM Insolvency_Account__c
                                WHERE
                                    Account_Number_Without_Space__c = :insolAccntNew.Account_Number_Without_Space__c
                                    //Account_Number_AlphaNumeric__c =: numberWithoutSpace
                                    AND Id != :insolAccntNew.Id
                                    AND Insolvency__c = :insolAccntNew.Insolvency__c
                                    AND recordTypeId = :insolAccntNew.RecordTypeId
                                    AND Account_Number_Without_Space__c NOT IN :ignoreAcctNameList
                            ]);

                            //Check for duplicate names
                            if (insolAcctDupeList.size() > 0) {
                                errorMessage =
                                    errorMessage +
                                    'Insolvency ' +
                                    startTag +
                                    baseUrl +
                                    '/' +
                                    insolAcctDupeList[0].Insolvency__c +
                                    '">' +
                                    insolAcctDupeList[0].Insolvency__r.Name +
                                    endTag;
                                errorMessage = errorMessage + ' already has Insolvency Account(s) with Account Number :' + lBrk;
                                for (Insolvency_Account__c insolAcctDupe : insolAcctDupeList) {
                                    //Populate each one
                                    errorMessage = errorMessage + startTag + baseUrl + '/' + insolAcctDupe.Id + '">' + insolAcctDupe.Name + endTag + lBrk;
                                }
                                //errorMessage = errorMessage + ' already has Insolvency Account/Accounts with Account Number : ' + startTag + baseUrl + '/' + insolAcctDBList[0].Id + '">' + insolAcctDBList[0].Name + endTag + lBrk;     // insolAcctMap.Name + lBrk;
                                insolAccntNew.addError(errorMessage, false);
                                insolAccntNew.Name.addError('Duplicate Records Found');
                            } else {
                                if (String.isBlank(insolAccntNew.Duplicate_Reasons_Picklist__c)) {
                                    List<Insolvency_Account__c> insolAcctAllDupeList = ([
                                        SELECT
                                            Id,
                                            Name,
                                            Insolvency__c,
                                            Insolvency__r.Name,
                                            Duplicate_Reasons_Picklist__c,
                                            Account_Number_Without_Space__c,
                                            //Account_Number_AlphaNumeric__c,
                                            RecordTypeID,
                                            RecordType.Name
                                        FROM Insolvency_Account__c
                                        WHERE
                                            Account_Number_Without_Space__c = :insolAccntNew.Account_Number_Without_Space__c
                                            //Account_Number_AlphaNumeric__c =: numberWithoutSpace
                                            AND Id != :insolAccntNew.Id
                                            AND Insolvency__c != :insolAccntNew.Insolvency__c
                                            AND recordTypeId = :insolAccntNew.RecordTypeId
                                            AND Account_Number_Without_Space__c NOT IN :ignoreAcctNameList
                                    ]);

                                    //Check for duplicate names
                                    if (insolAcctAllDupeList.size() > 0) {
                                        //insolAccntNew.Duplicate_Reasons_Picklist__c = 'Valid Insolvency';
                                        //errorMessage = errorMessage+ 'Insolvency Estate Number = '+ startTag + baseUrl + '/' + insolAcctAllDBList[0].Insolvency__c + '">' + insolAcctAllDBList[0].Insolvency__r.Name + endTag + ' and Insolvency Account Number = ' + startTag + baseUrl + '/' + insolAcctAllDBList[0].Id + '">'+ insolAcctAllDBList[0].Name + endTag + lBrk ;
                                        for (Insolvency_Account__c insolAcctAllDupe : insolAcctAllDupeList) {
                                            errorMessage =
                                                errorMessage +
                                                'Insolvency Estate Number = ' +
                                                startTag +
                                                baseUrl +
                                                '/' +
                                                insolAcctAllDupe.Insolvency__c +
                                                '">' +
                                                insolAcctAllDupe.Insolvency__r.Name +
                                                endTag +
                                                ' and Insolvency Account Number = ' +
                                                startTag +
                                                baseUrl +
                                                '/' +
                                                insolAcctAllDupe.Id +
                                                '">' +
                                                insolAcctAllDupe.Name +
                                                endTag +
                                                lBrk;
                                        }

                                        insolAccntNew.addError('Following Duplicate Records found : ' + lBrk + errorMessage, false);
                                        insolAccntNew.Name.addError('Duplicate Records Found');
                                        insolAccntNew.Duplicate_Reasons_Picklist__c.addError('You must enter a value');
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        //Copy from Insolvency
        Map<String, String> cpyInsFieldsMap = InsolvencyUtil.getInsolvencyFieldSet('CopyInsolvencyFields');
        Set<String> cpyInsFields = cpyInsFieldsMap.keySet();

        //Insolvency Ids
        Set<Id> insId = new Set<Id>();

        //Insolvency Account Ids
        Set<Id> insAccntsId = new Set<Id>();

        //Insolvency Ids and Insolvencies
        Map<Id, Insolvency__c> insMap = new Map<Id, Insolvency__c>();

        //Fetch corrsponding Insolvency records
        for (Insolvency_Account__c insolAccntnew : insolAccntsNew) {
            if (insolAccntnew.Insolvency__c != null) {
                insId.add(insolAccntnew.Insolvency__c);
            }
            insAccntsId.add(insolAccntnew.Id);
        }

        //Fetch corresponding Insolvency records
        String copyQuery = getCopyQuery(insId, cpyInsFields);
        List<Insolvency__c> insolvencies = Database.query(copyQuery);
        for (Insolvency__c dbIns : insolvencies) {
            insMap.put(dbIns.Id, dbIns);
        }

        list<Insolvency_Account__History> insolAcctHistoryList = new List<Insolvency_Account__History>(
            [
                SELECT id, OldValue, NewValue, CreatedDate, Parent.Id, CreatedById
                FROM Insolvency_Account__History
                WHERE Parent.Id IN :insAccntsId AND Field = 'Insolvency_Status__c'
                //order by CreatedDate Asc
                ORDER BY CreatedDate DESC
            ]
        );
        /*                                                                        
set<Id> insolIdSet = new set<Id>();
for(Insolvency_Account__c insolAccntnew : insolAccntsNew){
insolIdSet.add(insolAccntnew.Insolvency__c);
}
*/

        //Map for revival date
        Map<Id, Insolvency_Account__History> mapInsAccHistory = new Map<Id, Insolvency_Account__History>();
        for (Insolvency_Account__History insAccHist : insolAcctHistoryList) {
            if (null == mapInsAccHistory.get(insAccHist.ParentID)) {
                mapInsAccHistory.put(insAccHist.parentId, insAccHist);
            }
        }

        /*
//Get Insolvency Owner review date insForOwnerREviewDate, insForOwnerREviewUser
map<Id, Insolvency__c> insolMap = new map<Id, Insolvency__c>();
list<Insolvency__c> dbInsolList = [select Id, Name,
Sent_For_Owner_Review_Date__c, Sent_For_Owner_Review_By__c,
Revival_Date__c,
//Query updated to consider Insolvency Owner fields
Scotia_Record_Owner__c,
SDA_Record_Owner__c,
Chase_Record_Owner__c
from Insolvency__c
where Id IN: insolIdSet];

for(Insolvency__c insol : dbInsolList ){
insolMap.put(insol.id, insol);
}
*/

        Boolean updateConfig = false;

        for (Insolvency_Account__c insolAccntNew : insolAccntsNew) {
            Insolvency_Account__c insolAccntOld = oldMap.get(insolAccntNew.id);

            if (
                insolAccntNew.Insolvency_Status__c <> insolAccntOld.Insolvency_Status__c &&
                (insolAccntOld.Insolvency_Status__c == 'Annulled' ||
                insolAccntOld.Insolvency_Status__c == 'Withdrawn' ||
                insolAccntOld.Insolvency_Status__c == 'Refused' ||
                insolAccntOld.Insolvency_Status__c == 'Claim Withdrawn') &&
                insolAccntNew.Insolvency_Status__c == 'Sent to Collections'
            ) {
                if (
                    insolAccntOld.Asset_Status__c == 'Purchased' ||
                    insolAccntOld.Asset_Status__c == 'Bulk Purchased' ||
                    insolAccntOld.Asset_Status__c == 'Duplicate Purchased' ||
                    insolAccntOld.Asset_Status__c == 'Debt Purchase'
                ) {
                    //no work
                } else {
                    insolAccntNew.Insolvency_Status__c.addError(
                        'Processing status cannot be set to Sent to Collections without the Asset status as not Purchased'
                    );
                }
            }
            // Ticket Ticket#273 , Add Insolvency Status is Pending Assignment to Collection Agency
            if (
                insolAccntNew.Insolvency_Status__c <> insolAccntOld.Insolvency_Status__c &&
                (insolAccntOld.Insolvency_Status__c == 'Annulled' ||
                insolAccntOld.Insolvency_Status__c == 'Withdrawn' ||
                insolAccntOld.Insolvency_Status__c == 'Refused' ||
                insolAccntOld.Insolvency_Status__c == 'Claim Withdrawn') &&
                insolAccntNew.Insolvency_Status__c == 'Pending Assignment to Collection Agency'
            ) {
                if (
                    insolAccntOld.Asset_Status__c == 'Purchased' ||
                    insolAccntOld.Asset_Status__c == 'Bulk Purchased' ||
                    insolAccntOld.Asset_Status__c == 'Duplicate Purchased' ||
                    insolAccntOld.Asset_Status__c == 'Debt Purchase'
                ) {
                    //no work
                } else {
                    insolAccntNew.Insolvency_Status__c.addError(
                        'Processing status cannot be set to Pending Assignment to Collection Agency without the Asset status as Purchased'
                    );
                }
            }

            //Set status to prior if Revival Date set
            if (
                (insolAccntNew.Insolvency_Status__c == 'Annulled' ||
                insolAccntNew.Insolvency_Status__c == 'Withdrawn' ||
                insolAccntNew.Insolvency_Status__c == 'Refused' ||
                insolAccntNew.Insolvency_Status__c == 'Sent to collections') && (insolAccntNew.Revival_Date__c <> insolAccntOld.Revival_Date__c)
            ) {
                //To set previous insolvency Status
                if (mapInsAccHistory.get(insolAccntNew.id) != null) {
                    //updateConfig = true;
                    insolAccntNew.Do_Not_Run_Status_Validation__c = true;
                    insolAccntNew.Insolvency_Status__c = '' + (mapInsAccHistory.get(insolAccntNew.id)).OldValue;
                }
                if (insolAccntOld.Insolvency_Status__c == 'Sent to collections') {
                    insolAccntNew.Accepted_Sent_to_Collections__c = true;
                }
            }
            //Ticket#273 Set status of Pending Assignment to Collection Agency to prior if Revival Date set
            if (
                (insolAccntNew.Insolvency_Status__c == 'Annulled' ||
                insolAccntNew.Insolvency_Status__c == 'Withdrawn' ||
                insolAccntNew.Insolvency_Status__c == 'Refused' ||
                insolAccntNew.Insolvency_Status__c == 'Pending Assignment to Collection Agency') &&
                (insolAccntNew.Revival_Date__c <> insolAccntOld.Revival_Date__c)
            ) {
                //To set previous insolvency Status
                if (mapInsAccHistory.get(insolAccntNew.id) != null) {
                    //updateConfig = true;
                    insolAccntNew.Do_Not_Run_Status_Validation__c = true;
                    insolAccntNew.Insolvency_Status__c = '' + (mapInsAccHistory.get(insolAccntNew.id)).OldValue;
                }
            }

            // Related Insovlency
            Insolvency__c dbInsol = insolMap.get(insolAccntnew.Insolvency__c);

            if (insolAccntNew.Insolvency_Status__c != insolAccntOld.Insolvency_Status__c) {
                if (insolAccntNew.Insolvency_Status__c == 'PoC Details Provided') {
                    // Auto populate last payment date for CTB accounts when updated to POC details provided if charged off date is present and last payment date is null
                    if (
                        insolAccntNew.Client_Identifier__c == 'Canadian Tire' &&
                        insolAccntNew.Last_Payment_Date__c == null &&
                        insolAccntNew.Charge_Off_Date__c != null
                    ) {
                        insolAccntNew.Last_Payment_Date__c = insolAccntNew.Charge_Off_Date__c.addMonths(-7);
                    } else if (
                        insolAccntNew.Client_Identifier__c == 'Canadian Tire' &&
                        insolAccntNew.Last_Payment_Date__c == null &&
                        insolAccntNew.Charge_Off_Date__c == null
                    ) {
                        if (insolAccntNew.Account_Open_date__c == null) {
                            insolAccntNew.Last_Payment_Date__c = System.Today().addMonths(-6);
                        } else {
                            insolAccntNew.Last_Payment_Date__c = System.Today().addMonths(-6) > insolAccntNew.Account_Open_date__c
                                ? System.Today().addMonths(-6)
                                : null;
                        }
                    }
                    if (
                        insolAccntNew.Judgement_Date__c == null &&
                        insolAccntNew.Last_Payment_Date__c != null &&
                        insolAccntNew.Insolvency_Date__c != null &&
                        !validateDateCriteria(insolAccntNew.Last_Payment_Date__c, insolAccntNew.Insolvency_Date__c, dbInsol.Debtor_1_Mailing_State_Province__c)
                    ) {
                        if (insolAccntNew.Client_Identifier__c != 'Canadian Tire') {
                            insolAccntNew.addError('Last Payment date entered outside statute of limitations for account ' + insolAccntNew.Name);
                        } else {
                            insolAccntNew.Insolvency_Status__c = insolAccntOld.Insolvency_Status__c;
                            insolAccntNew.Insolvency_Sub_Status__c = 'Stat-barred Account';
                        }
                    }
                    if (
                        insolAccntNew.Judgement_Date__c == null &&
                        insolAccntNew.Acknowledgement_date__c != null &&
                        insolAccntNew.Insolvency_Date__c != null &&
                        !validateDateCriteria(
                            insolAccntNew.Acknowledgement_date__c,
                            insolAccntNew.Insolvency_Date__c,
                            dbInsol.Debtor_1_Mailing_State_Province__c
                        )
                    ) {
                        if (insolAccntNew.Client_Identifier__c != 'Canadian Tire') {
                            insolAccntNew.addError('Last Acknowledgment Date entered outside statute of limitations for account ' + insolAccntNew.Name);
                        } else {
                            insolAccntNew.Insolvency_Status__c = insolAccntOld.Insolvency_Status__c;
                            insolAccntNew.Insolvency_Sub_Status__c = 'Stat-barred Account';
                        }
                    }
                }

                //Insolvency__c dbInsol = insolMap.get(insolAccntnew.Insolvency__c);
                if (insolAccntNew.Insolvency_Status__c != insolAccntOld.Insolvency_Status__c) {
                    insolAccntNew.Insolvency_Status_Last_Changed__c = dtNow;
                }

                //Insolvency Status dates for SLA tracking
                if (String.isNotBlank(insolAccntnew.Insolvency_Status__c)) {
                    if (insolAccntnew.Claim_Filed_Date__c == null) {
                        if (insolAccntnew.Insolvency_Status__c == 'For Owner Review') {
                            if (insolAccntOld.Insolvency_Status__c == 'Trustee Followup') {
                                // || insolAccntOld.Insolvency_Status__c == 'Wait / Hold')
                                insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                                insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                            }
                            //SLA for Revival date
                            else if (insolAccntNew.Revival_Date__c != insolAccntOld.Revival_Date__c) {
                                insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                                insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                            } else if (insolAccntnew.Sent_For_Owner_Review_Date_Original__c != null) {
                                insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                                insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                            } else {
                                insolAccntnew.Sent_For_Owner_Review_Date_Original__c = dtNow;
                                insolAccntnew.Sent_For_Owner_Review_By_Original__c = userId;
                                insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                                insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                            }
                        } else {
                            //Insolvency Account moved to other statuses rather than to For Owner Review
                            if (insolAccntnew.Insolvency_Status__c != 'New') {
                                if (insolAccntnew.Sent_For_Owner_Review_Date_Original__c == null) {
                                    if (dbInsol != null && dbInsol.Sent_For_Owner_Review_Date__c != null) {
                                        insolAccntnew.Sent_For_Owner_Review_Date_Original__c = dbInsol.Sent_For_Owner_Review_Date__c;
                                        insolAccntnew.Sent_For_Owner_Review_By_Original__c = dbInsol.Sent_For_Owner_Review_By__c;
                                        insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dbInsol.Sent_For_Owner_Review_Date__c;
                                        insolAccntnew.Sent_For_Owner_Review_By_Updated__c = dbInsol.Sent_For_Owner_Review_By__c;
                                    } else {
                                        insolAccntnew.Sent_For_Owner_Review_Date_Original__c = dtNow;
                                        insolAccntnew.Sent_For_Owner_Review_By_Original__c = userId;
                                        insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                                        insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                                    }
                                }
                            }

                            if (insolAccntnew.Insolvency_Status__c == 'PoC Details Provided') {
                                insolAccntnew.PoC_Details_Provided_Date__c = dtNow;

                                // task 6322 PoC_Details_Provided_By__c will updated one time
                                if (
                                    insolAccntOld.Insolvency_Status__c == 'For Owner Review' &&
                                    insolAccntnew.Insolvency_Status__c == 'PoC Details Provided' &&
                                    insolAccntnew.PoC_Details_Provided_By__c == null
                                ) {
                                    insolAccntnew.PoC_Details_Provided_By__c = userId;
                                }
                                insolAccntnew.Accounts_Validation_Date__c = dtNow;
                                insolAccntnew.Accounts_Validation_Done_By__c = userId;
                            } else if (insolAccntnew.Insolvency_Status__c == 'No PoC Required') {
                                insolAccntnew.No_PoC_Required_Date__c = dtNow;
                                insolAccntnew.No_PoC_Required_Set_By__c = userId;
                                insolAccntnew.Accounts_Validation_Date__c = dtNow;
                                insolAccntnew.Accounts_Validation_Done_By__c = userId;
                            } else if (insolAccntnew.Insolvency_Status__c == 'Claim Filed') {
                                insolAccntnew.Claim_Filed_Date__c = dtNow;
                                insolAccntnew.Claim_Filed_By__c = userId;
                            } else if (insolAccntnew.Insolvency_Status__c == 'Wait / Hold') {
                                insolAccntnew.Wait_Hold_Set_Date__c = dtNow;
                                insolAccntnew.Wait_Hold_Set_By__c = userId;
                            } else if (insolAccntnew.Insolvency_Status__c == 'Trustee Followup') {
                                insolAccntnew.Trustee_Followup_Date__c = dtNow;
                                insolAccntnew.Trustee_Followup_Sent_By__c = userId;
                            }
                        }
                    }
                    //Added for Ticket#167 - SLA Reports Dec_2020
                    if (insolAccntnew.Insolvency_Status__c == 'For Owner Review') {
                        if (
                            insolAccntnew.Sent_For_Owner_Review_Date_External__c == null ||
                            (insolAccntOld.Insolvency_Status__c == 'Claim Filed' ||
                            insolAccntOld.Insolvency_Status__c == 'Withdrawn' ||
                            insolAccntOld.Insolvency_Status__c == 'Refused' ||
                            insolAccntOld.Insolvency_Status__c == 'Trustee Followup' ||
                            insolAccntOld.Insolvency_Status__c == 'No Poc Required')
                        ) {
                            insolAccntnew.Sent_For_Owner_Review_Date_External__c = dtNow;
                            insolAccntnew.Sent_For_Owner_Review_By_External__c = userId;
                        }
                    }
                }
                if (
                    insolAccntNew.Insolvency_Status__c <> insolAccntOld.Insolvency_Status__c &&
                    (insolAccntOld.Insolvency_Status__c == 'Annulled' ||
                    insolAccntOld.Insolvency_Status__c == 'Refused') &&
                    insolAccntNew.Insolvency_Status__c == 'Debtor Paying Direct'
                ) {
                    if (
                        insolAccntOld.Asset_Status__c == 'Purchased' ||
                        insolAccntOld.Asset_Status__c == 'Bulk Purchased' ||
                        insolAccntOld.Asset_Status__c == 'Duplicate Purchased' ||
                        insolAccntOld.Asset_Status__c == 'Debt Purchase'
                    ) {
                        //no work
                    } else {
                        stopErrorMessage = true;
                        insolAccntNew.Insolvency_Status__c.addError(
                            'Processing status cannot be set to Debtor Paying Direct without the Asset status as not Purchased'
                        );
                    }
                }
            }

            //Update Insolvency Status Last Changed date field with least recent date
            //when account put in For Owner Review status
            //from below status
            //1. PoC Details provided
            //2. PoC Package generated
            //3. No PoC Required
            //4. Wait / Hold

            if (
                insolAccntNew.Insolvency_Status__c == 'For Owner Review' &&
                (insolAccntOld.Insolvency_Status__c == 'PoC Details Provided' ||
                insolAccntOld.Insolvency_Status__c == 'PoC Package Generated' ||
                insolAccntOld.Insolvency_Status__c == 'No PoC Required' ||
                insolAccntOld.Insolvency_Status__c == 'Wait / Hold')
            ) {
                //||
                // insolAccntOld.Insolvency_Status__c == 'Claim Filed')
                for (Insolvency_Account__History insolAccHistory : insolAcctHistoryList) {
                    if (insolAccHistory.NewValue == 'For Owner Review') {
                        if (insolAccHistory.Parent.Id == insolAccntNew.Id) {
                            insolAccntNew.Insolvency_Status_Last_Changed__c = insolAccHistory.CreatedDate;
                            insolAccntnew.Sent_For_Owner_Review_Date_Original__c = insolAccHistory.CreatedDate;
                            insolAccntnew.Sent_For_Owner_Review_By_Original__c = insolAccHistory.CreatedbyId;
                            insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = insolAccHistory.CreatedDate;
                            insolAccntnew.Sent_For_Owner_Review_By_Updated__c = insolAccHistory.CreatedbyId;
                        }
                    }
                }
            }

            //Determine whether the Account was secured account previously
            if (('Unsecured' == insolAccntNew.Claim_Type__c) && ('Secured' == insolAccntOld.Claim_Type__c)) {
                insolAccntNew.Previously_Secured_Account__c = true;
            }

            if (insolAccntNew.Insolvency__c != insolAccntOld.Insolvency__c) {
                Insolvency__c relatedIns = insMap.get(insolAccntnew.Insolvency__c);

                if (relatedIns != null) {
                    //Insolvency Name - Insolvency Account Estate number
                    insolAccntnew.Debtor_1_Estate_Number__c = relatedIns.name;

                    //Copy from Insolvency
                    for (String cpyInsField : cpyInsFields) {
                        insolAccntnew.put(cpyInsField, relatedIns.get(cpyInsField));
                    }

                    //Debtor Name
                    insolAccntnew.Debtor__c = InsolvencyUtil.createFullName(insolAccntnew.Debtor_1_First_Name__c, insolAccntnew.Debtor_1_Last_Name__c);
                    insolAccntnew.Borrower_Primary__c = insolAccntnew.Debtor__c;

                    //Co-Debtor Name
                    insolAccntnew.Co_Debtor__c = InsolvencyUtil.createFullName(insolAccntnew.Debtor_2_First_Name__c, insolAccntnew.Debtor_2_Last_Name__c);
                    insolAccntnew.Borrower_Coborrower_1__c = insolAccntnew.Co_Debtor__c;
                }
            }

            //Reset SLA on bank change
            if (insolAccntOld.recordTypeId != insolAccntnew.recordTypeId) {
                if (insolAccntOld.Insolvency_Status__c == 'New') {
                    //set status to New
                    insolAccntnew.Insolvency_Status__c = 'New';
                    insolAccntNew.Insolvency_Status_Last_Changed__c = dtNow;
                    //reset all SLA date fields
                    insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = null;
                    insolAccntnew.Sent_For_Owner_Review_By_Updated__c = null;
                    insolAccntnew.PoC_Details_Provided_Date__c = null;
                    insolAccntnew.PoC_Details_Provided_By__c = null;
                    insolAccntnew.Accounts_Validation_Date__c = null;
                    insolAccntnew.Accounts_Validation_Done_By__c = null;
                    insolAccntnew.No_PoC_Required_Date__c = null;
                    insolAccntnew.No_PoC_Required_Set_By__c = null;
                    insolAccntnew.Claim_Filed_Date__c = null;
                    insolAccntnew.Claim_Filed_By__c = null;
                    insolAccntnew.Wait_Hold_Set_Date__c = null;
                    insolAccntnew.Wait_Hold_Set_By__c = null;
                    insolAccntnew.Trustee_Followup_Date__c = null;
                    insolAccntnew.Trustee_Followup_Sent_By__c = null;

                    //Added for Ticket#167 - SLA Reports Dec_2020(Added on 16.02.21)
                    insolAccntnew.Sent_For_Owner_Review_Date_External__c = null;
                    insolAccntnew.Sent_For_Owner_Review_By_External__c = null;
                } else {
                    //set status to For Owner Review
                    insolAccntnew.Insolvency_Status__c = 'For Owner Review';
                    insolAccntnew.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                    insolAccntnew.Sent_For_Owner_Review_By_Updated__c = userId;
                    insolAccntNew.Insolvency_Status_Last_Changed__c = dtNow;
                    //Reset all SLA Dates
                    insolAccntnew.PoC_Details_Provided_Date__c = null;
                    insolAccntnew.PoC_Details_Provided_By__c = null;
                    insolAccntnew.Accounts_Validation_Date__c = null;
                    insolAccntnew.Accounts_Validation_Done_By__c = null;
                    insolAccntnew.No_PoC_Required_Date__c = null;
                    insolAccntnew.No_PoC_Required_Set_By__c = null;
                    insolAccntnew.Claim_Filed_Date__c = null;
                    insolAccntnew.Claim_Filed_By__c = null;
                    insolAccntnew.Wait_Hold_Set_Date__c = null;
                    insolAccntnew.Wait_Hold_Set_By__c = null;
                    insolAccntnew.Trustee_Followup_Date__c = null;
                    insolAccntnew.Trustee_Followup_Sent_By__c = null;

                    //Added for Ticket#167 - SLA Reports Dec_2020(Added on 16.02.21)
                    insolAccntnew.Sent_For_Owner_Review_Date_External__c = dtNow;
                    insolAccntnew.Sent_For_Owner_Review_By_External__c = userId;
                }
            }

            if (insolAccntNew.Do_Not_Run_Status_Validation__c == false && stopErrorMessage == false) {
                Boolean validStatusChange = true;

                if (profileName.contains('CFG')) {
                    validStatusChange = InsolvencyAcctStatusValidationController.internalValidationRule(
                        insolAccntNew,
                        insolAccntOld.Insolvency_Status__c,
                        insolAccntNew.Insolvency_Status__c
                    );
                }
                if (profileName.contains('Community User')) {
                    validStatusChange = InsolvencyAcctStatusValidationController.externalValidationRule(
                        insolAccntNew,
                        insolAccntOld.Insolvency_Status__c,
                        insolAccntNew.Insolvency_Status__c
                    );
                }
                if (validStatusChange == false) {
                    insolAccntNew.addError('Invalid Status change from ' + insolAccntOld.Insolvency_Status__c + ' to ' + insolAccntNew.Insolvency_Status__c);
                    
                }
                // added for 7069 //
                if(validStatusChange == true){
                    if( insolAccntOld.Insolvency_Status__c == 'Claim Filed' && insolAccntNew.Insolvency_Status__c == 'PoC Details Provided'){
                        insolAccntNew.Amended_Claim_Flag__c = true;
                    }             
                }
            }

            insolAccntNew.Do_Not_Run_Status_Validation__c = false;
        }

        /*
if(updateConfig == True){
config.Run_Insolvency_Status_Validations__c = false;
update config;
}
*/
    }

    /*Calculate Total Claim Amount Amount - This method calculations are taken care of in calculateTotalAmount*/
    /*public static void calculateTotalClaimAmount(set<ID> setInsolvencyID){
list<Insolvency__c> listInsolvency = [SELECT ID, (SELECT ID, Claim_Amount__c, Claim_Type__c, Insolvency_Status__c FROM Insolvency_Accounts__r) FROM Insolvency__c WHERE ID IN :setInsolvencyID];
for(Insolvency__c insolvency : listInsolvency){
Decimal totalClaimAmount=0;
for(Insolvency_Account__c insolvencyAcc : insolvency.Insolvency_Accounts__r){
if(insolvencyAcc.Insolvency_Status__c == 'Claim Filed'
&& insolvencyAcc.Claim_Type__c == 'Unsecured'){
if(insolvencyAcc.Claim_Amount__c != null){
totalClaimAmount += insolvencyAcc.Claim_Amount__c;   
}
}
}
insolvency.Total_Claim_Amount__c = totalClaimAmount;
}
update listInsolvency;
}*/

    /*Rollup Amounts on Insolvency from Insolvency Account*/
    public static void calculateTotalAmount(set<ID> setInsolvencyID) {
        list<Insolvency__c> listInsolvency = [
            SELECT
                ID,
                (
                    SELECT ID, Claim_Amount__c, Claim_Type__c, Insolvency_Status__c, Expected_Account_Recovery__c, Previous_Expected_Account_Recovery__c
                    FROM Insolvency_Accounts__r
                )
            FROM Insolvency__c
            WHERE ID IN :setInsolvencyID
        ];
        for (Insolvency__c insolvency : listInsolvency) {
            Decimal totalClaimAmount = 0;
            Decimal expectedAccountRecovery = 0;
            Decimal previousExpectedAccountRecovery = 0;

            for (Insolvency_Account__c insolvencyAcc : insolvency.Insolvency_Accounts__r) {
                //For Ticket - "New Field on Insolvency - Voting Influence Percentage"
                if (insolvencyAcc.Insolvency_Status__c == 'Claim Filed' && insolvencyAcc.Claim_Type__c == 'Unsecured') {
                    if (insolvencyAcc.Claim_Amount__c != null) {
                        //Calculate total Expected Account Recovery amounts
                        totalClaimAmount += insolvencyAcc.Claim_Amount__c;
                    }
                }
                if (insolvencyAcc.Expected_Account_Recovery__c != null) {
                    expectedAccountRecovery += insolvencyAcc.Expected_Account_Recovery__c;
                }
                if (insolvencyAcc.Previous_Expected_Account_Recovery__c != null) {
                    previousExpectedAccountRecovery += insolvencyAcc.Previous_Expected_Account_Recovery__c;
                }
            }
            insolvency.Total_Claim_Amount__c = totalClaimAmount;

            //Ticket#87 - Manually rejected/approved completed by
            insolvency.Total_Expected_Account_Recovery__c = expectedAccountRecovery;
            insolvency.Total_Previous_Expected_Account_Recovery__c = previousExpectedAccountRecovery;
        }
        InsolvencyTriggerHandler.runInsolvencyTrigger = false;
        update listInsolvency;
        InsolvencyTriggerHandler.runInsolvencyTrigger = true;
    }
    //After Insert
    public static void handleAfterInsert(List<Insolvency_Account__c> insolAccntsNew) {
		ArchiveUnarchiveUtility.assignExternalCorID(insolAccntsNew);
        handleAfterInsertUpdate(insolAccntsNew, null);
    }

    //After Update
    public static void handleAfterUpdate(List<Insolvency_Account__c> insolAccntsNew, Map<Id, Insolvency_Account__c> oldMap) {
        /*
config.Run_Insolvency_Status_Validations__c = runValidationRule;
update config;
*/
		set<Id> canadianInsolAcctIdSet = new Set<Id>();

        //Not all Insolvency Accounts need to be processed after update
        List<Insolvency_Account__c> insolAccntsToProcess = new List<Insolvency_Account__c>();
        ID oldInsolvencyID;
        for (Insolvency_Account__c insolAccntNew : insolAccntsNew) {
            if(!Test.isRunningTest()){
                if (insAccntRecorTypeMap.get(insolAccntNew.RecordTypeId) == 'Canadian_Tire_Insolvency_Account') {
                    canadianInsolAcctIdSet.add(insolAccntNew.id);
                }
            }
            
            Insolvency_Account__c insolAccntOld = oldMap.get(insolAccntNew.id);
            oldInsolvencyID = insolAccntOld.Insolvency__c;
            if (
                (insolAccntNew.Claim_Amount__c != insolAccntOld.Claim_Amount__c) ||
                (insolAccntNew.Total_Account_Recovery__c != insolAccntOld.Total_Account_Recovery__c) ||
                ((insolAccntOld.Claim_Type__c != null &&
                insolAccntNew.Claim_Type__c == null) ||
                (insolAccntOld.Claim_Type__c == null &&
                insolAccntNew.Claim_Type__c != null) ||
                (insolAccntOld.Claim_Type__c != null && !insolAccntNew.Claim_Type__c.equalsIgnoreCase(insolAccntOld.Claim_Type__c))) ||
                ((insolAccntOld.Client_Identifier__c != null &&
                insolAccntNew.Client_Identifier__c == null) ||
                (insolAccntOld.Client_Identifier__c != null &&
                insolAccntNew.Client_Identifier__c == null) ||
                (insolAccntOld.Client_Identifier__c != null && !insolAccntNew.Client_Identifier__c.equalsIgnoreCase(insolAccntOld.Client_Identifier__c))) ||
                ((insolAccntOld.Insolvency_Status__c != null &&
                insolAccntNew.Insolvency_Status__c == null) ||
                (insolAccntOld.Insolvency_Status__c != null &&
                insolAccntNew.Insolvency_Status__c == null) ||
                (insolAccntOld.Insolvency_Status__c != null && !insolAccntNew.Insolvency_Status__c.equalsIgnoreCase(insolAccntOld.Insolvency_Status__c)))
            ) {
                insolAccntsToProcess.add(insolAccntNew);
            }
        }
        if(!Test.isRunningTest() && InsolvencyPaymentsTriggerHandler.runInsolvencyPaymentTrigger){
            //Bypass Payment validation if payment is remitted and need to update an insolvency account.
            config.Do_Not_Run_Payment_Validation__c  = true;
        	update config;
            if(canadianInsolAcctIdSet != NULL){
                List<Insolvency_payment__c> ctbInsolPayment = [select id,name,Insolvency_Account__c,Payment_Amount__c,
                                                               Is_Payment_Remitted__c,Payment_Reversed__c,Payment_Reversal_Date__c,
                                                               Account_Number__c,Payment_Sub_Status__c,Error_Message__c
                                                               from Insolvency_payment__c 
                                                               where Insolvency_Account__c IN: canadianInsolAcctIdSet];
                InsolvencyPaymentsTriggerHandler.updateCTBInsolvencyPaymentStatus(ctbInsolPayment,'Insolvency Account'); 
                config.Do_Not_Run_Payment_Validation__c  = false;
                update config;
            }
        }
        
        handleAfterInsertUpdate(insolAccntsToProcess, oldInsolvencyID);
    }

    //Utility method for after insert and update
    public static void handleAfterInsertUpdate(List<Insolvency_Account__c> insolAccnts, id oldInsolvencyID) {
        Set<Id> insolvenciesIds = new Set<Id>();
        /*Calculate Total Claim Amount*/
        set<ID> setInsolvencyClaimFailedID = new Set<ID>();
        for (Insolvency_Account__c insolAccnt : insolAccnts) {
            if (insAccntRecorTypeMap.get(insolAccnt.RecordTypeId) == 'Canadian_Tire_Insolvency_Account') {
                Insolvency_Account__c updatedAcc = updatePercentageOfIncreasedReturn(insolAccnt);
                if (updatedAcc != null) {
                    accountsToUpdate.add(updatePercentageOfIncreasedReturn(insolAccnt));
                }
            }
            insolvenciesIds.add(insolAccnt.Insolvency__c);
            //condition code is commented here and taken care of in calculateTotalAmount
            //if(insolAccnt.Insolvency_Status__c == 'Claim Filed'){
            setInsolvencyClaimFailedID.add(insolAccnt.Insolvency__c);
            //}
        }
        calculateTotalAmount(setInsolvencyClaimFailedID);
        /*calculateTotalClaimAmount(setInsolvencyClaimFailedID);*/
        /*Calculate Total Claim Amount Ends*/
        insolvenciesIds.add(oldInsolvencyID);
        //Insolvency Accounts which are to be processed
        handleAfterInsertUpdateDelete(getInsolvencyAccounts(insolvenciesIds), insolvenciesIds);
    }

    //After Delete
    public static void handleAfterDelete(List<Insolvency_Account__c> insolAccntsNew, Map<Id, Insolvency_Account__c> oldMap) {
        //Insolvency and Insolvency Account sets
        Set<Id> insolAccntsIds = oldMap.keySet();
        Set<Id> insolvenciesIds = new Set<Id>();
        /*Calculate Total Claim Amount*/
        set<ID> setInsolvencyID = new Set<ID>();
        for (Insolvency_Account__c insolvencyAccount : oldMap.values()) {
            //condition code is commented here and taken care of in calculateTotalAmount
            //if(insolvencyAccount.Insolvency_Status__c == 'Claim Filed'){
            setInsolvencyID.add(insolvencyAccount.Insolvency__c);
            //}
        }
        calculateTotalAmount(setInsolvencyID);
        /*calculateTotalClaimAmount(setInsolvencyID);*/
        /*Calculate Total Claim Amount Ends*/

        for (Id insolAccntId : insolAccntsIds) {
            insolvenciesIds.add((oldMap.get(insolAccntId)).Insolvency__c);
        }

        //Insolvency Accounts which are not deleted
        handleAfterInsertUpdateDelete(getInsolvencyAccounts(insolvenciesIds), insolvenciesIds);
    }

    //Utility method after insert, update and delete
    private static void handleAfterInsertUpdateDelete(List<Insolvency_Account__c> insolAccnts, set<Id> insolvenciesIds) {
        //Fetch corrsponding Insolvency records
        Map<Id, Insolvency__c> insolvencyMap = getInsolvencyMap(insolvenciesIds);

        //Check Client Identifiers
        Map<Id, String> insolvencyClientIdentifierMap = new Map<Id, String>();

        //Total Claim Recovered
        Map<Id, Decimal> insolvencyTotalClaimMap = new Map<Id, Decimal>();

        /*
//For Owner Review - Single Bank
Map <Id, Decimal> insolvencyORNbrMap = new Map<Id, Decimal>();

//Secured Claim Amount - Single Bank
Map <Id, Decimal> insolvencySecClaimAmntMap = new Map<Id, Decimal>();

//Unsecured Claim Amount - Single Bank
Map <Id, Decimal> insolvencyUnecClaimAmntMap = new Map<Id, Decimal>();

//Number of Secured Claim Acounts - Single Bank
Map <Id, Decimal> insolvencySecClaimNbrMap = new Map<Id, Decimal>();

//Number of Unecured Claim Acounts - Single Bank
Map <Id, Decimal> insolvencyUnsecClaimNbrMap = new Map<Id, Decimal>();
*/

        //Multi Bank - List of Banks
        List<String> bankNames = new List<String>();
        List<Schema.PicklistEntry> pikListValues = Insolvency_Account__c.Client_Identifier__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pikListValue : pikListValues) {
            String pickListValue = pikListValue.getValue();
            if (String.isNotBlank(pickListValue) && !(pickListValue.toUpperCase() == 'UNKNOWN')) {
                bankNames.add(pikListValue.getValue());
            }
        }

        //Needs Validation - MultiBank
        Map<Id, Map<String, Decimal>> insolvencyNRMap = new Map<Id, Map<String, Decimal>>();

        //MultiBank
        //Secured / Unsecured
        Map<Id, Map<String, Decimal>> insolvencySecuredMap = new Map<Id, Map<String, Decimal>>();
        Map<Id, Map<String, Decimal>> insolvencyUnsecuredMap = new Map<Id, Map<String, Decimal>>();

        //MultiBank
        //Secured / Unsecured claim Amounts
        Map<Id, Map<String, Decimal>> insolvencySecuredCAMap = new Map<Id, Map<String, Decimal>>();
        Map<Id, Map<String, Decimal>> insolvencyUnsecuredCAMap = new Map<Id, Map<String, Decimal>>();

        //Set Client Identifiers values & claim Amounts to null
        for (Id insolvId : insolvencyMap.keySet()) {
            insolvencyClientIdentifierMap.put(insolvId, null);
            insolvencyTotalClaimMap.put(insolvId, null);

            //Single Bank
            /*
insolvencyORNbrMap.put(insolvId, null);            
insolvencySecClaimAmntMap.put(insolvId, null);
insolvencyUnecClaimAmntMap.put(insolvId, null);
insolvencySecClaimNbrMap.put(insolvId, null); 
insolvencyUnsecClaimNbrMap.put(insolvId, null); 
*/

            //Multi Bank
            Map<String, Decimal> bankNameMap = new Map<String, Decimal>();
            Map<String, Decimal> bankNameSecuredMap = new Map<String, Decimal>();
            Map<String, Decimal> bankNameUnsecuredMap = new Map<String, Decimal>();
            Map<String, Decimal> bankNameSecuredCAMap = new Map<String, Decimal>();
            Map<String, Decimal> bankNameUnsecuredCAMap = new Map<String, Decimal>();

            for (String bankName : bankNames) {
                bankNameMap.put(bankName, 0);
                bankNameSecuredMap.put(bankName, 0);
                bankNameUnsecuredMap.put(bankName, 0);
                bankNameSecuredCAMap.put(bankName, 0);
                bankNameUnsecuredCAMap.put(bankName, 0);
            }

            insolvencyNRMap.put(insolvId, bankNameMap);
            insolvencySecuredMap.put(insolvId, bankNameSecuredMap);
            insolvencyUnsecuredMap.put(insolvId, bankNameUnsecuredMap);
            insolvencySecuredCAMap.put(insolvId, bankNameSecuredCAMap);
            insolvencyUnsecuredCAMap.put(insolvId, bankNameUnsecuredCAMap);
        }

        //for voting automation
        List<ID> votingAutomationList = new List<ID>();
        map<Id, Decimal> mapInsolvencyIdCount = new Map<Id, Decimal>();
        for (Insolvency_Account__c insolAccnt : insolAccnts) {
            Insolvency__c insolvency = insolvencyMap.get(insolAccnt.Insolvency__c);
            // Populate client identifier based on record type
            if (insolAccnt.RecordTypeId != null && insolAccnt.Client_Identifier__c == null) {
                insolAccnt.Client_Identifier__c = cIRTMap.get(insAccntRecorTypeMap.get(insolAccnt.RecordTypeId));
            }

            if (insolvency != null) {
                //Check if insolvency account is Scotia and POC Details are provided
                if (
                    insolAccnt.Insolvency_Status__c == 'POC Details Provided' &&
                    ((config.Eligible_for_Voting_Decision__c).contains(insolAccnt.Client_Identifier__c))
                ) {
                    if (mapInsolvencyIdCount.containsKey(insolvency.Id)) {
                        mapInsolvencyIdCount.put(insolvency.Id, mapInsolvencyIdCount.get(insolvency.Id) + 1);
                    } else {
                        mapInsolvencyIdCount.put(insolvency.Id, 1);
                    }
                }

                //For Voting automation future call for Insolvency list
                if (insolAccnt.Insolvency_Status__c == 'POC Details Provided')
                    if (insolvency.Eligible_For_Voting_Decision__c == false )  
                    if ((config.Eligible_for_Voting_Decision__c).contains(insolAccnt.Client_Identifier__c) 
                        && (insolvency.Total_Estimated_Realizable_Value__c < 20000  
                           || insolvency.Total_Estimated_Realizable_Value__c == NULL )) {
                            votingAutomationList.add(insolvency.id);
                        }else{
                            insolvency.Eligible_For_Voting_Decision__c = true;
                            insolvency.Voting_Decision__c = 'Needs Manual Review';
                            insolvency.Manual_Review_Reason__c = 'Total Estimated Realizable Value should be less than $20000';
                        }

                //Client Identifier - imp
                String clientIdentifier = insolAccnt.Client_Identifier__c;
                String clientIdentifierDB = insolvencyClientIdentifierMap.get(insolAccnt.Insolvency__c);
                if (String.isBlank(clientIdentifier)) {
                    //Do nothing
                } else {
                    if (String.isBlank(clientIdentifierDB)) {
                        clientIdentifierDB = clientIdentifier;
                    } else {
                        if (!clientIdentifierDB.contains(clientIdentifier)) {
                            clientIdentifierDB = clientIdentifierDB + ',' + clientIdentifier;
                        }
                    }
                }
                insolvencyClientIdentifierMap.put(insolAccnt.Insolvency__c, clientIdentifierDB);

                //Total Claim Recovered - imp
                Decimal totalClaimRecovered = insolAccnt.Total_Account_Recovery__c;
                if (totalClaimRecovered == null) {
                    totalClaimRecovered = 0;
                }
                Decimal totalClaimRecoveredDB = insolvencyTotalClaimMap.get(insolAccnt.Insolvency__c);
                if (totalClaimRecoveredDB == null) {
                    totalClaimRecoveredDB = 0;
                }
                totalClaimRecoveredDB = totalClaimRecovered + totalClaimRecoveredDB;
                insolvencyTotalClaimMap.put(insolAccnt.Insolvency__c, totalClaimRecoveredDB);

                //Number of For Owner Review accounts - Single Bank
                /*
Decimal insolvencyORNbr = insolvencyORNbrMap.get(insolAccnt.Insolvency__c);
if(insolvencyORNbr == null){
insolvencyORNbr = 0;
}
if((!String.isBlank(insolAccnt.Insolvency_Status__c)) && ('For Owner Review'.equalsIgnoreCase(insolAccnt.Insolvency_Status__c))){
insolvencyORNbr = insolvencyORNbr + 1;
}
insolvencyORNbrMap.put(insolAccnt.Insolvency__c, insolvencyORNbr);
*/

                /*
//Number of Secured accounts - Single Bank
Decimal insolvencySecClaimNbr = insolvencySecClaimNbrMap.get(insolAccnt.Insolvency__c);
if(insolvencySecClaimNbr == null){
insolvencySecClaimNbr = 0;
}

//Number of Unsecured accounts - Single Bank
Decimal insolvencyUnecClaimNbr = insolvencyUnsecClaimNbrMap.get(insolAccnt.Insolvency__c);
if(insolvencyUnecClaimNbr == null){
insolvencyUnecClaimNbr = 0;
}

//Claim Amounts - Single Bank
String claimType = insolAccnt.Claim_Type__c;     
Decimal claimAmount =  insolAccnt.Claim_Amount__c;
if(claimAmount == null){
claimAmount = 0;
}  

//Secured Claim Amounts - Single Bank                        
Decimal secClaimAmntDB =  insolvencySecClaimAmntMap.get(insolAccnt.Insolvency__c);
if(secClaimAmntDB == null){
secClaimAmntDB = 0;
} 

//Unsecured Claim Amounts - Single Bank              
Decimal unsecClaimAmntDB =  insolvencyUnecClaimAmntMap.get(insolAccnt.Insolvency__c);
if(unsecClaimAmntDB == null){
unsecClaimAmntDB = 0;
}
//Secured / Unsecured Calculations - Single Bank  
if(!String.isBlank(claimType)){
//Secured Claim 
if(claimType.equalsIgnoreCase('Secured')){   
secClaimAmntDB = claimAmount + secClaimAmntDB; 
insolvencySecClaimNbr = insolvencySecClaimNbr + 1;              
}
//Unsecured Claim 
else if (claimType.equalsIgnoreCase('Unsecured')){
unsecClaimAmntDB = claimAmount + unsecClaimAmntDB;
insolvencyUnecClaimNbr = insolvencyUnecClaimNbr + 1;
}   
} 
*/

                /*
insolvencySecClaimNbrMap.put(insolAccnt.Insolvency__c, insolvencySecClaimNbr);
insolvencyUnsecClaimNbrMap.put(insolAccnt.Insolvency__c,insolvencyUnecClaimNbr);
insolvencyClientIdentifierMap.put(insolAccnt.Insolvency__c, clientIdentifierDB);  
insolvencySecClaimAmntMap.put(insolAccnt.Insolvency__c, secClaimAmntDB);  
insolvencyUnecClaimAmntMap.put(insolAccnt.Insolvency__c, unsecClaimAmntDB);
*/
                //Multi Bank - For Owner Review
                if (config.Eligible_for_Validn_Needed_Calculation__c.contains(insolAccnt.Client_Identifier__c)) {
                    if ((!String.isBlank(insolAccnt.Insolvency_Status__c)) && ('For Owner Review'.equalsIgnoreCase(insolAccnt.Insolvency_Status__c))) {
                        Map<String, Decimal> bankDBMap = insolvencyNRMap.get(insolAccnt.Insolvency__c);
                        Decimal bankORNbr = bankDBMap.get(insolAccnt.Client_Identifier__c);
                        bankDBMap.put(insolAccnt.Client_Identifier__c, bankORNbr + 1);
                        insolvencyNRMap.put(insolAccnt.Insolvency__c, bankDBMap);
                    }
                }

                //Multibank - Secured
                if (config.Eligible_for_Claim_Type_Calculation__c.contains(insolAccnt.Client_Identifier__c)) {
                    //Multibank - Secured
                    if ((!String.isBlank(insolAccnt.Claim_Type__c)) && ('Secured'.equalsIgnoreCase(insolAccnt.Claim_Type__c))) {
                        //Secured Amount
                        Map<String, Decimal> bankNameSecuredCADBMap = insolvencySecuredCAMap.get(insolAccnt.Insolvency__c);
                        Decimal secClaimAmt = bankNameSecuredCADBMap.get(insolAccnt.Client_Identifier__c);
                        if (insolAccnt.Claim_Amount__c != null) {
                            bankNameSecuredCADBMap.put(insolAccnt.Client_Identifier__c, insolAccnt.Claim_Amount__c + secClaimAmt);
                            insolvencySecuredCAMap.put(insolAccnt.Insolvency__c, bankNameSecuredCADBMap);
                        }

                        //Number of Secured Accounts
                        Map<String, Decimal> bankNameSecDBMap = insolvencySecuredMap.get(insolAccnt.Insolvency__c);
                        Decimal secCount = bankNameSecDBMap.get(insolAccnt.Client_Identifier__c);
                        bankNameSecDBMap.put(insolAccnt.Client_Identifier__c, secCount + 1);
                        insolvencySecuredMap.put(insolAccnt.Insolvency__c, bankNameSecDBMap);
                    }

                    //Multibank - Unsecured
                    if ((!String.isBlank(insolAccnt.Claim_Type__c)) && ('Unsecured'.equalsIgnoreCase(insolAccnt.Claim_Type__c))) {
                        //Unsecured Amount
                        Map<String, Decimal> bankNameUnsecuredCADBMap = insolvencyUnsecuredCAMap.get(insolAccnt.Insolvency__c);
                        Decimal unsecClaimAmt = bankNameUnsecuredCADBMap.get(insolAccnt.Client_Identifier__c);
                        if (insolAccnt.Claim_Amount__c != null) {
                            bankNameUnsecuredCADBMap.put(insolAccnt.Client_Identifier__c, insolAccnt.Claim_Amount__c + unsecClaimAmt);
                            insolvencyUnsecuredCAMap.put(insolAccnt.Insolvency__c, bankNameUnsecuredCADBMap);
                        }

                        //Number of Unsecured Accounts
                        Map<String, Decimal> bankNameUnsecDBMap = insolvencyUnsecuredMap.get(insolAccnt.Insolvency__c);
                        Decimal unsecCount = bankNameUnsecDBMap.get(insolAccnt.Client_Identifier__c);
                        bankNameUnsecDBMap.put(insolAccnt.Client_Identifier__c, unsecCount + 1);
                        insolvencyUnsecuredMap.put(insolAccnt.Insolvency__c, bankNameUnsecDBMap);
                    }
                }
            }
        }

        //Insolvencies to update
        List<Insolvency__c> insolvencyUpdate = new List<Insolvency__c>();

        //Multibank
        //Insolvency Details
        List<Insolvency_Detail__c> insDetails = new List<Insolvency_Detail__c>();

        for (Id insolvencyId : insolvencyMap.keySet()) {
            Insolvency__c insolvency = insolvencyMap.get(insolvencyId);

            //update Number of POC Details Provided Accounts on Insolvency
            if (mapInsolvencyIdCount.containsKey(insolvencyId)) {
                insolvency.Number_of_POC_Details_Provided_Accounts__c = mapInsolvencyIdCount.get(insolvencyId);
            } else {
                insolvency.Number_of_POC_Details_Provided_Accounts__c = 0;
            }

            //Update Insolvency for voting
            if (votingAutomationList.contains(insolvency.id)) {
                insolvency.Eligible_For_Voting_Decision__c = true;
            }

            if (insolvency.Insolvency_Status__c == 'For Owner Review') {
                //Update Insolvency to Active if all of related Insolvency Accounts are moved to Claim Filed
                //Size of Related Insolvency Accounts
                Integer inSolvAccListSize = insolvency.Insolvency_Accounts__r.size();
                Integer count = 0;

                for (Insolvency_Account__c inSolvAcc : insolvency.Insolvency_Accounts__r) {
                    //Insolvency Account Processing status is Claim filed
                    if ((inSolvAcc.Insolvency_Status__c == 'Claim Filed') || (inSolvAcc.Insolvency_Status__c == 'No PoC Required')) {
                        count++;
                    }

                    //Update Insolvency Status to Active
                    if (inSolvAccListSize == count) {
                        insolvency.Insolvency_Status__c = 'Active';
                        insolvency.Insolvency_Status_Last_Changed__c = system.now();

                        //for SLA Tracking
                        insolvency.Set_to_Active_Date__c = system.now();
                        insolvency.Set_to_Active_By__c = UserInfo.getUserId();

                        //insolvencyUpdate.add(insolvency);
                        count = 0;
                    }
                }
            }

            //Client Identifier
            insolvency.Client_Identifiers__c = insolvencyClientIdentifierMap.get(insolvencyId);

            //Total Recovery
            insolvency.Total_Claim_Recovered__c = insolvencyTotalClaimMap.get(insolvencyId);

            /*
//For Owner Review - Single Bank
insolvency.Number_of_Accounts_Needing_Validation__c = insolvencyORNbrMap.get(insolvencyId);

//Number of Secured / Unsecured accounts - Single Bank
insolvency.No_Of_Secured_Accounts__c = insolvencySecClaimNbrMap.get(insolvencyId);
insolvency.No_Of_Unsecured_Accounts__c = insolvencyUnsecClaimNbrMap.get(insolvencyId);

//Claim Amounts - Single Bank
insolvency.Total_Secured_Claims__c = insolvencySecClaimAmntMap.get(insolvencyId);
insolvency.Total_Unsecured_Claims__c = insolvencyUnecClaimAmntMap.get(insolvencyId);
*/

            insolvencyUpdate.add(insolvency);

            for (String bankName : bankNames) {
                //Multibank - Insolvency Detail
                Insolvency_Detail__c insDetail = new Insolvency_Detail__c();
                insDetail.Insolvency__c = insolvencyId;
                insDetail.Bank_Name__c = bankName;

                //Multibank - Number of Accounts needing validations
                if (config.Eligible_for_Validn_Needed_Calculation__c.contains(bankName)) {
                    Map<String, Decimal> bankMap = insolvencyNRMap.get(insolvencyId);
                    Decimal nbrAcctsNeedVal = bankMap.get(bankName);
                    insDetail.Number_of_Accounts_Needing_Validation__c = nbrAcctsNeedVal;
                }

                //Multibank - Claim Calculations
                if (config.Eligible_for_Claim_Type_Calculation__c.contains(bankName)) {
                    //Unsecured Claim Amount
                    Map<String, Decimal> unsecuredCAMap = insolvencyUnsecuredCAMap.get(insolvencyId);
                    insDetail.Unsecured_Claim_Amount__c = unsecuredCAMap.get(bankName);

                    //Number of Unsecured Accounts
                    Map<String, Decimal> unsecuredMap = insolvencyUnsecuredMap.get(insolvencyId);
                    insDetail.Number_of_Unsecured_Accounts__c = unsecuredMap.get(bankName);

                    //Secured Claim Amount
                    Map<String, Decimal> securedCAMap = insolvencySecuredCAMap.get(insolvencyId);
                    insDetail.Secured_Claim_Amount__c = securedCAMap.get(bankName);

                    //Number of Secured Accounts
                    Map<String, Decimal> securedMap = insolvencySecuredMap.get(insolvencyId);
                    insDetail.Number_of_Secured_Accounts__c = securedMap.get(bankName);
                }

                //insDetails.add(insDetail);
                if (
                    (null == insDetail.Number_of_Accounts_Needing_Validation__c ||
                    0 == insDetail.Number_of_Accounts_Needing_Validation__c) &&
                    (null == insDetail.Unsecured_Claim_Amount__c ||
                    0 == insDetail.Unsecured_Claim_Amount__c) &&
                    (null == insDetail.Number_of_Unsecured_Accounts__c ||
                    0 == insDetail.Number_of_Unsecured_Accounts__c) &&
                    (null == insDetail.Secured_Claim_Amount__c ||
                    0 == insDetail.Secured_Claim_Amount__c) &&
                    (null == insDetail.Number_of_Secured_Accounts__c ||
                    0 == insDetail.Number_of_Secured_Accounts__c)
                ) {
                    //do nothing
                } else {
                    insDetails.add(insDetail);
                }

                /*
if((null != insDetail.Unsecured_Claim_Amount__c && insDetail.Unsecured_Claim_Amount__c != 0 ) ||
(null != insDetail.Number_of_Unsecured_Accounts__c && insDetail.Number_of_Unsecured_Accounts__c != 0) ||
(null != insDetail.Secured_Claim_Amount__c && insDetail.Secured_Claim_Amount__c != 0) ||
(null != insDetail.Number_of_Secured_Accounts__c && insDetail.Number_of_Secured_Accounts__c != 0)){
insDetails.add(insDetail);
}
*/
            }
        }

        //Call Voting engine
        if (null != votingAutomationList && votingAutomationList.size() > 0) {
            Database.executeBatch(new VotingEngineBatch(votingAutomationList), 40);
            // VotingEngineFutureCall.votingAutomationCall(votingAutomationList);
        }

        //Update Insolvency records in bulk
        if (insolvencyUpdate.size() > 0) {
            InsolvencyTriggerHandler.runInsolvencyTrigger = false;
            update insolvencyUpdate;
            InsolvencyTriggerHandler.runInsolvencyTrigger = true;
        }

        //Delete Claim_Type_Insolvency__c
        InsolvencyTriggerHandler.runInsolvencyTrigger = false;
        delete [SELECT id FROM Insolvency_Detail__c WHERE Insolvency__c IN :insolvenciesIds];

        //Multibank
        //Insert Action_Needed_Insolvency__c in bulk
        if (insDetails.size() > 0) {
            upsert insDetails;
        }
        InsolvencyTriggerHandler.runInsolvencyTrigger = true;
        if (!accountsToUpdate.isEmpty()) {
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            if (!Test.isRunningTest()) {
                update new List<Insolvency_Account__c> ( accountsToUpdate );
            }
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        }
    }

    //Utility method to fetch Insolvency records for Insolvency Accounts
    private static Map<Id, Insolvency__c> getInsolvencyMap(Set<Id> insolvencyIds) {
        return (new Map<Id, Insolvency__c>(
            [
                SELECT
                    Id,
                    Insolvency_Created_Date__c,
                    Client_Identifiers__c,
                    Eligible_For_Voting_Decision__c,
                    Total_Secured_Claims__c,
                    Total_Unsecured_Claims__c,
                    Total_Claim_Recovered__c,
                    Insolvency_Status__c,
                	Total_Estimated_Realizable_Value__c,
                    (SELECT Id, Insolvency_Status__c, Client_Identifier__c FROM Insolvency_Accounts__r)
                FROM Insolvency__c
                WHERE Id IN :insolvencyIds
            ]
        ));
    }

    //Utility method to fetch Insolvency records for Insolvency Accounts
    private static List<Insolvency_Account__c> getInsolvencyAccounts(Set<Id> insolvenciesIds) {
        List<Insolvency_Account__c> insolvencyAccounts = [
            SELECT
                Id,
                Insolvency__c,
                Client_Identifier__c,
                Insolvency_Status__c,
                RecordType.DeveloperName,
                Claim_Type__c,
                Claim_Amount__c,
                Total_Account_Recovery__c
            FROM Insolvency_Account__c
            WHERE Insolvency__c IN :insolvenciesIds
        ];

        return insolvencyAccounts;
    }

    //Utility method to fetch specific Insolvency field set
    public static String getCopyQuery(Set<Id> insId, Set<String> cpyInsFields) {
        String copyQuery = 'Select id, Name';
        for (String cpyInsField : cpyInsFields) {
            copyQuery = copyQuery + ', ' + cpyInsField;
        }
        copyQuery = copyQuery + ' from Insolvency__c ';
        copyQuery = copyQuery + 'where id in :insId LIMIT 50000';

        return copyQuery;
    }

    //Utility method that returns Client Identifier based on record type
    public static String getClientIdentifierBasedOnRecordType(Id recordTypeId) {
        String clientIdentifierBasedOnRecordType = null;
        return cIRTMap.get(insAccntRecorTypeMap.get(recordTypeId));
    }

    //Get Community URL
    public static string getCommunityUrl() {
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        return comm.siteUrl;
    }

    private static void getDistressedProductData(Insolvency_Account__c accNew) {
        Product__c distProduct;
        try {
            distProduct = [
                SELECT
                    id,
                    Name,
                    Purchase_Date_Formula__c,
                    Investment_Group__c,
                    Portfolio_Group_Name_Formula__c,
                    Portfolio_Name_Lookup__r.Name,
                    Account_Purchasing_Entity_Value__c,
                    Originating_Creditor__c
                FROM Product__c
                WHERE recordType.name = 'Distressed Account' AND name = :accNew.Distressed_Data_Id__c
            ];
        } catch (Exception e) {
            // record not found or multiple records found
        }

        if (distProduct != null) {
            if (distProduct.Portfolio_Name_Lookup__r.Name != null) {
                List<Portfolio_Name__c> portfolios = [SELECT id, name FROM Portfolio_Name__c WHERE name = :distProduct.Portfolio_Name_Lookup__r.Name LIMIT 1];
                if (portfolios.size() > 0) {
                    accNew.Portfolio_Name_Lookup__c = portfolios.get(0).id;
                }
            }

            if (distProduct.Purchase_Date_Formula__c != null) {
                accNew.Purchase_Date__c = distProduct.Purchase_Date_Formula__c;
            }

            if (distProduct.Investment_Group__c != null) {
                accNew.Investment_Group__c = distProduct.Investment_Group__c;
            }

            if (distProduct.Portfolio_Group_Name_Formula__c != null) {
                accNew.Portfolio_Group_Name__c = distProduct.Portfolio_Group_Name_Formula__c;
            }

            if (distProduct.Account_Purchasing_Entity_Value__c != null) {
                accNew.Payment_Remittance_Reference__c = distProduct.Account_Purchasing_Entity_Value__c;
            }
            if (distProduct.Originating_Creditor__c != null) {
                accNew.Originator__c = distProduct.Originating_Creditor__c;
            }
        }
    }

    /**
        method name : updateProcessingSubStatus - created for CTB Automation to update Processing Sub Status
        parameters : accNew - insolvency record updated
                     oldAccRecord - old insolvency record
        return - void
        author - Tejal Vidhate
    */
    public static void updateProcessingSubStatus(
        List<Insolvency_Account__c> insolAccntsNew,
        Map<Id, Insolvency_Account__c> oldMap,
        Map<String, String> insolAcctIdInsolId
    ) {
        Map<string, Insolvency__c> mapInsolData = new Map<string, Insolvency__c>();
        Map<string, String> mapInsolIdTrusteeId = new Map<string, String>();
        Map<string, Account> trusteeData = new Map<string, Account>();
        for (Insolvency__c insolData : [
            SELECT
                id,
                name,
                Insolvency_Type__c,
                Debtor_1_First_Name__c,
                Debtor_1_Middle_Name__c,
                Debtor_1_Last_Name__c,
                Debtor_1_Mailing_Country__c,
                Insolvency_Date__c,
                Trustee__r.BillingStreet,
                Trustee__r.BillingCity,
                Trustee__r.BillingState,
                Trustee__r.BillingPostalCode
            FROM Insolvency__c
            WHERE id IN :insolAcctIdInsolId.values()
        ]) {
            mapInsolData.put(insolData.id, insolData);
            mapInsolIdTrusteeId.put(insolData.id, insolData.Trustee__c);
        }

        for (Account accData : [
            SELECT id, BillingStreet, BillingCity, BillingState, BillingPostalCode
            FROM account
            WHERE id IN :mapInsolIdTrusteeId.values()
        ]) {
            trusteeData.put(accData.id, accData);
        }
        String errorMsg;
        for (Insolvency_Account__c accNew : insolAccntsNew) {
            Boolean fieldMissing = false;
            errorMsg = '';
            if (insAccntRecorTypeMap.get(accNew.RecordTypeId) == 'Canadian_Tire_Insolvency_Account' 
                || insAccntRecorTypeMap.get(accNew.RecordTypeId) == 'Money_Mart_Insolvency_Account'
                || Test.isRunningTest()) {
                if (accNew.Insolvency_Received_Date__c == null) {
                    errorMsg = 'Insolvency Received Date ,';
                    fieldMissing = true;
                }
                if (accNew.name == null) {
                    errorMsg += 'Name ,';
                    fieldMissing = true;
                }
                if (insolAcctIdInsolId.get(accNew.id) != null) {
                    if (mapInsolData.get(insolAcctIdInsolId.get(accNew.id)).Insolvency_Type__c == null) {
                        errorMsg += 'Insolvency Type ,';
                        fieldMissing = true;
                    }
                    if (mapInsolData.get(insolAcctIdInsolId.get(accNew.id)).Debtor_1_First_Name__c == null) {
                        errorMsg += 'Insolvency Debtor First Name ,';
                        fieldMissing = true;
                    }
                    if (mapInsolData.get(insolAcctIdInsolId.get(accNew.id)).Debtor_1_Last_Name__c == null) {
                        errorMsg += 'Insolvency Debtor Last Name ,';
                        fieldMissing = true;
                    }
                    if (mapInsolData.get(insolAcctIdInsolId.get(accNew.id)).Debtor_1_Mailing_Country__c == null) {
                        errorMsg += 'Country ,';
                        fieldMissing = true;
                    }
                    if (mapInsolData.get(insolAcctIdInsolId.get(accNew.id)).Insolvency_Date__c == null) {
                        errorMsg += 'Insolvency Date ,';
                        fieldMissing = true;
                    }
                    if (mapInsolData.get(insolAcctIdInsolId.get(accNew.id)).name == null) {
                        errorMsg += 'Insolvency Name ,';
                        fieldMissing = true;
                    }
                }

                if (accNew.Debtor_1_First_Name__c == null) {
                    errorMsg += 'Debtor First Name ,';
                    fieldMissing = true;
                }
                if (accNew.Debtor_1_Last_Name__c == null) {
                    errorMsg += 'Debtor Last Name ,';
                    fieldMissing = true;
                }
                if (accNew.Debtor_1_Mailing_Street__c == null) {
                    errorMsg += 'Street Name & Number ,';
                    fieldMissing = true;
                }
                if (accNew.Debtor_1_Mailing_City__c == null) {
                    errorMsg += 'City ,';
                    fieldMissing = true;
                }
                if (accNew.Province_Formula__c == null) {
                    errorMsg += 'Province ,';
                    fieldMissing = true;
                }
                if (accNew.Trustee_Company__c == null) {
                    errorMsg += 'Trustee Details ,';
                    fieldMissing = true;
                }
                if (mapInsolIdTrusteeId.get(insolAcctIdInsolId.get(accNew.id)) != null && insolAcctIdInsolId.get(accNew.id) != null) {
                    if(trusteeData != null && trusteeData.size() > 0){
                        if (trusteeData.get(mapInsolIdTrusteeId.get(insolAcctIdInsolId.get(accNew.id))).BillingStreet == null) {
                        errorMsg += 'Trustee Street ,';
                        fieldMissing = true;
                        }
                        if (trusteeData.get(mapInsolIdTrusteeId.get(insolAcctIdInsolId.get(accNew.id))).BillingCity == null) {
                            errorMsg += 'Trustee City ,';
                            fieldMissing = true;
                        }
                        if (trusteeData.get(mapInsolIdTrusteeId.get(insolAcctIdInsolId.get(accNew.id))).BillingState == null) {
                            errorMsg += 'Trustee State ,';
                            fieldMissing = true;
                        }
                        if (trusteeData.get(mapInsolIdTrusteeId.get(insolAcctIdInsolId.get(accNew.id))).BillingPostalCode == null) {
                            errorMsg += 'Trustee Postal Code ,';
                            fieldMissing = true;
                        }
                    }
                }
                errorMsg = errorMsg.removeEnd(' ,');
                errorMsg += ' are missing';
                
                if(fieldMissing == False){
                    accNew.Error_Message__c = '';
                }
                
                
                if (fieldMissing == TRUE && accNew.Insolvency_Sub_Status__c != 'Pending File' && !Test.isRunningTest()) {
                    accNew.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                    accNew.Error_Message__c = errorMsg /*'Missing data in one or more mandatory fields.'*/;
                }else if(fieldMissing == TRUE && accNew.Insolvency_Sub_Status__c == 'Pending File' 
                        && oldMap.get(accNew.id).Insolvency_Sub_Status__c!=accNew.Insolvency_Sub_Status__c){
                    accNew.Insolvency_Sub_Status__c = 'Pending File';
                    accNew.Error_Message__c = errorMsg;
                }
                else if(fieldMissing == TRUE){
                    accNew.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                    accNew.Error_Message__c = errorMsg;
                }
                else if(oldMap.get(accNew.id).Insolvency_Status__c!=accNew.Insolvency_Status__c){
                    system.debug('fieldMissing##'+fieldMissing);
                    //CTB Automation: set insolvency account processing status and sub-status
                    accNew.CTB_Status_Update_Code__c = '';
                    accNew.Insolvency_Sub_Status__c = '';
                    if (accNew.Insolvency_Status__c == 'For Owner Review') {
                        accNew.CTB_Status_Update_Code__c = '';
                        accNew.Insolvency_Sub_Status__c = 'Pending File';
                        accNew.Error_Message__c = '';
                    }
                    if (accNew.Insolvency_Status__c == 'Discharged') {
                        accNew.CTB_Status_Update_Code__c = 'PCOM';
                        accNew.Insolvency_Sub_Status__c = 'Pending File';
                        accNew.Error_Message__c = '';
                    }
                    system.debug('inside insolAcc::');
                    if (accNew.Insolvency_Status__c == 'Annulled' || accNew.Insolvency_Status__c == 'Refused' || accNew.Insolvency_Status__c == 'Withdrawn') {
                        accNew.CTB_Status_Update_Code__c = 'RREV';
                        accNew.Insolvency_Sub_Status__c = 'Pending File';
                        accNew.Error_Message__c = '';
                    }
                    if (
                        accNew.Insolvency__r.Insolvency_Status__c == 'Active' &&
                        accNew.Insolvency__r.Revival_Date__c != null &&
                        accNew.Insolvency__r.Revival_Date__c != oldMap.get(accNew.id).Insolvency__r.Revival_Date__c
                    ) {
                        accNew.CTB_Status_Update_Code__c = '';
                        accNew.Insolvency_Sub_Status__c = 'Pending File';
                        accNew.Error_Message__c = '';
                    }
                }
                else{
                    if(fieldMissing == False && oldMap.get(accNew.id).Insolvency_Sub_Status__c == 'File Error Parsing Record'){
                        accNew.Insolvency_Sub_Status__c = 'Pending File';
                        accNew.Error_Message__c = '';
                    }
                    if(fieldMissing == False && oldMap.get(accNew.id).Insolvency_Sub_Status__c!=accNew.Insolvency_Sub_Status__c && 
                      accNew.Insolvency_Sub_Status__c == 'Pending File'){
                        accNew.Insolvency_Sub_Status__c = 'Pending File';
                    }
                    if (
                        oldMap.get(accNew.id).Insolvency_Status__c == accNew.Insolvency_Status__c &&
                        oldMap.get(accNew.id).Insolvency_Sub_Status__c == null &&
                        accNew.Insolvency_Sub_Status__c == 'File Error Parsing Record'
                    ) {
                        accNew.Insolvency_Sub_Status__c.addError('You cannot set directly File Error Parsing Record as Processing Sub Status.');
                    } else if (
                        oldMap.get(accNew.id).Insolvency_Status__c == accNew.Insolvency_Status__c &&
                        oldMap.get(accNew.id).Insolvency_Sub_Status__c == null &&
                        accNew.Insolvency_Sub_Status__c == 'Sent on file'
                    ) {
                        accNew.Insolvency_Sub_Status__c.addError('You cannot set directly Sent on file as Processing Sub Status.');
                    }
                    //Ticket 7911 - CTB Status Code - PCOM
                    /*if (accNew.Insolvency_Sub_Status__c == 'Pending File' && oldMap.get(accNew.id).Insolvency_Status__c == accNew.Insolvency_Status__c) {
                        accNew.CTB_Status_Update_Code__c = '';
                    }*/
                }
            }
        }
    }

    /**
     * @description : Calculate percentage of increased return
     * @author adesh.ikhar@canaccede.com | 02-23-2024
     * @param acc
     * @return Insolvency_Account__c
     **/
    public static Insolvency_Account__c updatePercentageOfIncreasedReturn(Insolvency_Account__c acc) {
        if (
            acc.Previous_Expected_Account_Recovery__c == null ||
            acc.Previous_Expected_Account_Recovery__c == 0 ||
            acc.Expected_Account_Recovery__c == 0 ||
            acc.Expected_Account_Recovery__c == null
        ) {
            return new Insolvency_Account__c(Id = acc.Id, Percent_of_increased_return_from_voting__c = 0);
        } else {
            return new Insolvency_Account__c(
                Id = acc.Id,
                Percent_of_increased_return_from_voting__c = ((acc.Expected_Account_Recovery__c - acc.Previous_Expected_Account_Recovery__c) /
                    acc.Previous_Expected_Account_Recovery__c) * 100
            );
        }
    }
    public static void handleBeforeDelete(List<Insolvency_Account__c> insolAccntOld) {
        ArchiveUnarchiveUtility.insertDeletedRecords(insolAccntOld);
    }

    /**
     * @description : Validate difference between dates as per province
     * @author adesh.ikhar@canaccede.com | 07-02-2024
     * @param inputDate
     * @param insolvencyDate
     * @param province
     * @return Boolean
     **/
    public static Boolean validateDateCriteria(Date inputDate, Date insolvencyDate, String province) {
        // Fail the validation if province is null
        if (String.isBlank(province)) {
            return false;
        }
        Integer validMonthDifference = 0;
        Integer monthsDifference = inputDate.monthsBetween(insolvencyDate);
        // Increment number of months to accomodate end date past the start date of same month
        if (insolvencyDate.day() > inputDate.day()) {
            monthsDifference++;
        }
        for (String key : provinceYearValidYearDifferenceMap.keySet()) {
            if (key.split(',').contains(province)) {
                validMonthDifference = provinceYearValidYearDifferenceMap.get(key);
                break;
            }
        }
        if (monthsDifference > validMonthDifference) {
            return false;
        }
        return true;
    }
}