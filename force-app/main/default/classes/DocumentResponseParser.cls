/**************************************************************************************************
 *
 *  Class:    DocumentResponseParser
 *
 *  @description : This is a DocumentResponseParser class for reading information from Petru system that is
 *                   stored under Parsed Response Holder Object
 *  @author : A5E Consulting
 *  @date : 04/28/2020
 *  Note: Do not change any of the Wrapper class variable names, because it should match with JSON attirbute names for parsing
 *************************************************************************************************/
public class DocumentResponseParser {
    // Creditor Name check to assign Record Type
    public static Set<String> scotiaBank = new Set<String>{ 'BANK OF NOVA SCOTIA', 'SCOTIABANK', 'SCOTIA BANK', 'SCOTIA MORTGAGE CORPORATION' };
    public static Set<String> sdaBank = new Set<String>{ 'SDA', 'SCOTIA DEALER ADVANTAGE' };
    public static Set<String> splBank = new Set<String>{ '5307', '628181' };
    public static Set<String> canaccedeBank = new Set<String>{ 'CANACCEDE' };
    public static Set<String> fidemBank = new Set<String>{ 'AFFIRM', 'FIDEM' };
    public static Set<String> fairstone = new Set<String>{ 'FAIRSTONE', 'WALMART', 'DUO' };
    public static Set<String> fairstoneAcc = new Set<String>{ '5434', '5435' };
    public static Set<String> canadianTire = new Set<String>{
        'CANADIAN TIRE BANK',
        'CANADIAN TIRE',
        'OPTIONS MASTERCARD',
        'BANQUE CANADIAN TIRE',
        'CANADIANTIRE'
    };
    public static Set<String> canadianTireBins = new Set<String>{ '525995', '544612', '544614', '544618', '544629', '544644' };
    public static Set<String> goEasy = new Set<String>{
        'EASYFINANCIAL SERVICES',
        'EASY FINANCIAL SERVICES',
        'EASYFINANCIAL',
        'EASY FINANCIAL',
        'GOEASY',
        'GO EASY',
        'EASY-HOME',
        'EASY HOME',
        'RTO ASSET MANAGEMENT'
    };
     public static Set<String> moneyMart = new Set<String>{
        'MONEY MART',//Money Mart  
        'NATIONAL MONEY MART',//National Money Mart 
        'MOMENTUM FINANCIAL SERVICES GROUP',//Momentum Financial Services Group
        'MONEYMART'//moneymart 
    };   
        public static Set<String> flexiti  = new Set<String>{
        'FLEXITI',//Flexiti 
        'FLEXITI FINANCIAL',//Flexiti Financial   
        'FLEXITICARD',//FLEXITICARD 
        'FLEXITI FINANCIERE', //Flexiti Financiere
        'FLEXITI FINANCIÈRE'//FLEXITI FINANCIÈRE 
    }; 
     //5093: 'EASYHOME', 'EASY HOME',
    //public static Set<String> fairstoneExcludeAcc = new Set<String>{'676'};
    //public static Set<String> fairstoneExcludeAccData = new Set<String>{'6030'};
    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();

    //Court Province Map
    public static Map<String, String> courtProvinceMap = new Map<String, String>{
        'AB' => 'Alberta',
        'BC' => 'British Columbia',
        'MB' => 'Manitoba',
        'NB' => 'New Brunswick',
        'NL' => 'Newfoundland and Labrador',
        'NS' => 'Nova Scotia',
        'ON' => 'Ontario',
        'PE' => 'Prince Edward Island',
        'QC' => 'Quebec',
        'SK' => 'Saskatchewan',
        'NT' => 'Northwest Territories',
        'NU' => 'Nunavut',
        'YT' => 'Yukon',
        'ALBERTA' => 'Alberta',
        'BRITISH COLUMBIA' => 'British Columbia',
        'MANITOBA' => 'Manitoba',
        'NEW BRUNSWICK' => 'New Brunswick',
        'NEWFOUNDLAND AND LABRADOR' => 'Newfoundland and Labrador',
        'NORTHWEST TERRITORIES' => 'Northwest Territories',
        'NOVA SCOTIA' => 'Nova Scotia',
        'NUNAVUT' => 'Nunavut',
        'ONTARIO' => 'Ontario',
        'PRINCE EDWARD ISLAND' => 'Prince Edward Island',
        'QUEBEC' => 'Quebec',
        'SASKATCHEWAN' => 'Saskatchewan',
        'YUKON' => 'Yukon',
        'NOUVEAU-BRUNSWICK' => 'New Brunswick',
        'QUÉBEC' => 'Quebec',
        'NEWFOUNDLAND & LABRADOR' => 'Newfoundland and Labrador'
    };

    //Marital Status Map
    public static Map<String, String> maritalStatusMap = new Map<String, String>{
        'COMMON-LAW' => 'Common law',
        'CONJOINT DE FAIT' => 'Common law',
        'SINGLE' => 'Single',
        'MARRIED' => 'Married',
        'COMMON LAW' => 'Common law',
        'SEPARATED' => 'Separated',
        'DIVORCED' => 'Divorced'
    };

    //Gender Value Map
    public static Map<String, String> genderValueMap = new Map<String, String>{
        'MALE' => 'Male',
        'FEMALE' => 'Female',
        'OTHER' => 'Other',
        'HOMME' => 'Male',
        'FEMME' => 'Female',
        'F' => 'Female',
        'M' => 'Male'
    };

    //Yes/No Value Map Form79
    public static Map<String, String> yesNoValueMap = new Map<String, String>{
        'OUI' => 'Yes',
        'NON' => 'No',
        'YES' => 'Yes',
        'NO' => 'No',
        'RECEIVED' => 'Yes',
        'NOT RECEIVED' => 'No'
    };

    //Payment Frequency Map Form47
    public static Map<String, String> paymentFrequencyValueMap = new Map<String, String>{ 'MOIS' => 'Monthly', 'MENSUELS' => 'Monthly' };

    // Insolvency Account Record Types
    static Map<String, Id> insolvencyRecordTypeMap = new Map<String, Id>();

    //Constant Values
    public static final string UNKNOWN_RECORD_NAME = 'unknown';
    public static final string Other_RECORD_NAME = 'other';

    public static Date InsolvencyAccDate;
    // Fetch Insolvency Account record types
    static {
        for (RecordType rtype : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Insolvency_Account__c']) {
            insolvencyRecordTypeMap.put(rtype.DeveloperName, rtype.Id);
        }
    }

    // Method takes Parser Handler Ids and parse JSON reponse
    public static void parseResponse(Id recordId) {
        Parsed_Response_Holder__c parsedResponse = [
            SELECT Id, Parsed_Response_Formatted__c, Status__c, Error_Details__c, assignment__c
            FROM Parsed_Response_Holder__c
            WHERE Id = :recordId
        ];
        // Production Issue - Converted variable to list
        List<Case> caseRecordList = [
            SELECT id, Document_ID__c, status, parentID, SuppliedEmail, Creditor_s_Pack_Language__c, createdDate
            FROM case
            WHERE id = :parsedResponse.assignment__c
        ];
        // Production Issue - Added List empty check
        if (caseRecordList.isEmpty()) {
            return;
        }
        Case caseRecord = caseRecordList[0];
        List<EmailMessage> emailMsg = [SELECT id, FromAddress FROM EmailMessage WHERE RelatedToId = :caseRecord.ID LIMIT 1];
        List<Attachment> attach = new List<Attachment>();

        if (emailMsg.size() > 0) {
            attach = [
                SELECT id, name, body, description, createdDate
                FROM Attachment
                WHERE ParentID = :emailMsg[0].Id AND description = 'Creditors Package' AND name LIKE '%.pdf'
                ORDER BY lastModifiedDate ASC
            ];
            if (attach.size() == 0) {
                attach = [
                    SELECT id, name, body, description, createdDate
                    FROM Attachment
                    WHERE ParentID = :emailMsg[0].Id AND name LIKE '%.pdf'
                    ORDER BY lastModifiedDate ASC
                ];
            }
        } else {
            attach = [
                SELECT id, name, body, description
                FROM Attachment
                WHERE ParentID = :caseRecord.Id AND description = 'Creditors Package' AND name LIKE '%.pdf'
                ORDER BY lastModifiedDate ASC
            ];
            if (attach.size() == 0) {
                attach = [
                    SELECT id, name, body, description
                    FROM Attachment
                    WHERE ParentID = :caseRecord.Id AND name LIKE '%.pdf'
                    ORDER BY lastModifiedDate ASC
                ];
            }
        }
        if (parsedResponse.Parsed_Response_Formatted__c != null && parsedResponse.Status__c == 'Pending') {
            String parseJson = parsedResponse.Parsed_Response_Formatted__c;
            //parseJson = DocumentParser.formatJson(parseJson);
            try {
                ResponseParser res = (ResponseParser) JSON.deserialize(parseJson, ResponseParser.class);
                Insolvency__c insolv = new Insolvency__c();
                List<Insolvency_Account__c> insolvAccounts = new List<Insolvency_Account__c>();
                List<Creditor_Account__c> creditorAccounts = new List<Creditor_Account__c>();

                // Package level
                insolv.Debtor_1_Court_Number__c = res.CourtNo;

                insolv.Allow_Insolvency_Date_In_Past__c = true;
                insolv.Created_By_Doc_Parser__c = true;

                //insolv.Name= 'unknown';
                insolv.Name = UNKNOWN_RECORD_NAME;

                //Do not set Default Insolvency type
                //insolv.Insolvency_Type__c = 'Division 1 Proposal';

                if (res.EstateNo != null) {
                    insolv.Name = res.EstateNo[0];
                    if (res.EstateNo.size() > 1) {
                        insolv.Debtor_2_Estate_Number__c = res.EstateNo[1];
                    }
                }

                if (res.CourtDivision != null) {
                    insolv.Court_Division_Number__c = res.CourtDivision;
                }
                if (res.CourtDistrict != null) {
                    //insolv.Court_District_Name__c = res.CourtDistrict;
                    insolv.Court_District_Name__c = getProvince(res.CourtDistrict);
                }
                if (res.CourtProvince != null) {
                    insolv.Court_Province__c = getProvince(res.CourtProvince);
                }
                //Form01Dot1Parts
                if (res.Form01Dot1Parts != null) {
                    Form01Dot1Parts Form01Dot1Parts = res.Form01Dot1Parts;
                    parseForm01Dot1Parts(Form01Dot1Parts, insolv);
                }
                //Form01Dot1Parts END

                // Form47Parts
                if (res.Form47Parts != null) {
                    parseForm47Parts(res.Form47Parts, insolv);
                }

                /*
            //No need for Code
            // creditor and Liability package
            if(res.Form47Creditorpackage != NULL){
              form47package(res.Form47Creditorpackage, insolv);
            }
            
            
            */

                // Form48Parts
                if (res.Form48Parts != null) {
                    parseForm48Parts(res.Form48Parts, insolv);
                }

                // Form49Parts
                if (res.Form49Parts != null) {
                    parseForm49Parts(res.Form49Parts, insolv);
                }

                // Form69Parts
                if (res.Form69Parts != null) {
                    parseForm69Parts(res.Form69Parts, insolv);
                }

                // Form65Parts (for old format xml)
                if (res.Form65Parts != null) {
                    parseForm65Parts(res.Form65Parts, insolv);
                }
                // Form65BisParts (for new format xml)
                else if (res.Form65Parts == null && res.form65BisParts != null) {
                    parseForm65BisParts(res.form65BisParts, insolv);
                }

                // Form79Parts
                if (res.Form79Parts != null) {
                    parseForm79Parts(res.Form79Parts, insolv, insolvAccounts, creditorAccounts);
                } else if (res.Form79Parts == null && res.form79BisParts != null) {
                    parseForm79BisParts(res.form79BisParts, insolv, insolvAccounts, creditorAccounts);
                }
                insolv = populateInsolvency(insolv, caseRecord);
                List<Insolvency__c> existingInsolvency = [SELECT Id FROM Insolvency__c WHERE Name = :insolv.Name];
                // Don't do anything if Insolvency already exists
                if (insolv.Name != UNKNOWN_RECORD_NAME && !existingInsolvency.isEmpty()) {
                    CaseComment addCom = new CaseComment();
                    addCom.CommentBody = 'Insolvency Record already exists with Estate Number : ' + insolv.Name;
                    addCom.ParentID = caseRecord.id;
                    insert addCom;
                    return;
                }
                insert insolv;

                insolvAccounts = populateInsolvencyAccount(insolvAccounts);

                for (Insolvency_Account__c insolvAccount : insolvAccounts) {
                    insolvAccount.Insolvency__c = insolv.Id;
                }
                for (Creditor_Account__c creditorAccount : creditorAccounts) {
                    creditorAccount.Insolvency__c = insolv.Id;
                }

                if (!insolvAccounts.isEmpty()) {
                    insert insolvAccounts;
                    //Database.insert(insolvAccounts, false);
                }
                if (!creditorAccounts.isEmpty()) {
                    Database.insert(creditorAccounts, false);
                }
                parsedResponse.Error_Details__c = null;
                parsedResponse.Status__c = 'Processed';

                caseRecord.Insolvency__c = insolv.id;
                caseRecord.status = 'Completed';

                parsedResponse.Insolvency__c = insolv.id;

                CaseComment addCom = new CaseComment();
                addCom.CommentBody = 'Insolvency Record is created. Insolvency Estate Number : ' + insolv.Name;
                addCom.ParentID = caseRecord.id;
                insert addCom;

                List<Attachment> listInsolvAttach = new List<Attachment>();
                for (Attachment att : attach) {
                    Attachment newAttach = att.clone(false, false, false, false);
                    newAttach.parentID = insolv.id;
                    newAttach.Description = 'Creditors Package';
                    listInsolvAttach.add(newAttach);
                }
                insert listInsolvAttach;
            } catch (Exception ex) {
                parsedResponse.Error_Details__c = ex.getMessage();
                parsedResponse.Status__c = 'Error';
                caseRecord.status = 'Manually Process';
                CaseComment addCom = new CaseComment();
                addCom.CommentBody = ex.getMessage();
                addCom.ParentID = caseRecord.id;
                insert addCom;
            }
            update parsedResponse;
            CaseTriggerHandler.runCaseTrigger = false;
            update caseRecord;
            CaseTriggerHandler.runCaseTrigger = true;
        } // End IF
    }

    //process Form01 Parts
    public static void parseForm01Dot1Parts(Form01Dot1Parts form01Dot1Parts, Insolvency__c insolv) {
        String trusteeCorporateName;
        String trusteeAddress;
        if (Form01Dot1Parts.trusteeCorporateName != null) {
            trusteeCorporateName = Form01Dot1Parts.trusteeCorporateName;
        }
        if (Form01Dot1Parts.trusteeAddress != null) {
            String[] address = Form01Dot1Parts.trusteeAddress.split(' ');
            if (address.size() > 3) {
                trusteeAddress = address[address.size() - 4]; //8250 Decarie Blvd. #140 Montreal QC H4P 2P5
            }
        }
        if (trusteeCorporateName != null && trusteeAddress != null) {
            List<Account> trustee = [
                SELECT Id
                FROM Account
                WHERE RecordType.Name = 'Trustee Office' AND Parent.Name = :trusteeCorporateName AND Name = :trusteeAddress
            ];
            if (!trustee.isEmpty()) {
                insolv.Trustee__c = trustee[0].Id;
            }
        }
    }

    // process Form47Parts
    public static void parseForm47Parts(Form47Parts form47Parts, Insolvency__c insolv) {
        /*
      //Ticket#408 - Team will enter Payment Amount manually
      if(form47Parts.paymentAmount != NULL){
         insolv.Payment_Amount__c = Decimal.valueOf(form47Parts.paymentAmount);
      }
      */
        if (form47Parts.paymentFrequency != null) {
            insolv.Payment_Frequency__c = getPaymentFrequencyValues(form47Parts.paymentFrequency);
        }
        /*
     //Ticket#408 - Team will enter Number of Payments manually
     if(form47Parts.numberOfPayments != NULL){
         insolv.Number_of_Payments__c = Integer.valueOf(form47Parts.numberOfPayments);
      }
      */
        if (form47Parts.notice1 != null) {
            insolv.Maint_Payments_Or_Relinquishing__c = form47Parts.notice1;
        }
        if (form47Parts.notice6 != null) {
            insolv.Death_Clause__c = form47Parts.notice6;
            insolv.Acceleration_Clause__c = form47Parts.notice6;
        }
    }

    // process Form48Parts
    public static void parseForm48Parts(Form48Parts form48Parts, Insolvency__c insolv) {
        if (form48Parts.notice4 != null) {
            insolv.Reason_For_Individual_Becoming_Insolvent__c = form48Parts.notice4;
        }
        if (form48Parts.notice5 != null) {
            insolv.Trustee_Comments_Notes__c = form48Parts.notice5;
        }
    }

    //parseForm49Parts
    public static void parseForm49Parts(Form49Parts form49Parts, Insolvency__c insolv) {
        if (form49Parts.insolvencyDate != null) {
            insolv.Insolvency_Date__c = formatDate(form49Parts.insolvencyDate); // convert 11/03/2020 to Salesforce Date format
        }

        /*
      if(form49Parts.insolvencyType != NULL){
          insolv.Insolvency_Type__c = form49Parts.insolvencyType;
      }
      */
        InsolvencyAccDate = insolv.Insolvency_Date__c;
        insolv.Insolvency_Type__c = 'Consumer Proposal';
    }

    //parseForm69Parts
    public static void parseForm69Parts(Form69Parts form69Parts, Insolvency__c insolv) {
        if (form69Parts.insolvencyDate != null) {
            insolv.Insolvency_Date__c = formatDate(form69Parts.insolvencyDate); // convert 11/03/2020 to Salesforce Date format
            InsolvencyAccDate = formatDate(form69Parts.insolvencyDate);
        }
        insolv.Insolvency_Type__c = 'Bankruptcy';
    }

    public static void parseCommonForm65Parts(MonthlyIncome monthlyIncome, MonthlyDiscretionaryExpenses monthlyDiscretionaryExpenses, Insolvency__c insolv) {
        if (monthlyIncome != null) {
            parseMonthlyIncome(monthlyIncome, insolv);
        }
        if (monthlyDiscretionaryExpenses != null) {
            parseMonthlyDiscretionaryExpenses(monthlyDiscretionaryExpenses, insolv);
        }
    }

    public static void parseForm65Parts(Form65Parts form65Parts, Insolvency__c insolv) {
        parseCommonForm65Parts(form65Parts.monthlyIncome, form65Parts.monthlyDiscretionaryExpenses, insolv);
        if (form65Parts.monthlyNonDiscretionaryExpenses != null) {
            parseMonthlyNonDiscretionaryExpenses(form65Parts.monthlyNonDiscretionaryExpenses, insolv);
        }
    }

    public static void parseForm65BisParts(Form65BisParts form65BisParts, Insolvency__c insolv) {
        parseCommonForm65Parts(form65BisParts.monthlyIncome, form65BisParts.monthlyDiscretionaryExpenses, insolv);
        if (form65BisParts.monthlyNonDiscretionaryExpenses != null) {
            parseNewMonthlyNonDiscretionaryExpenses(form65BisParts.monthlyNonDiscretionaryExpenses, insolv);
        }
        if (form65BisParts?.agreedToPay?.Debtor != null) {
            Decimal paymentAmount = getSumOfAmounts(form65BisParts.agreedToPay.Debtor);
            // Set payment amount to null if it comes as 0 from CP
            insolv.Payment_Amount__c = paymentAmount != 0 ? paymentAmount : null;
        }
        if (form65BisParts?.repurchaseAssets?.Debtor != null) {
            insolv.Amount_Bankrupt_will_pay_to_repurchase__c = getSumOfAmounts(form65BisParts.repurchaseAssets.Debtor);
        }
        if (form65BisParts?.residualAmount?.Debtor != null) {
            insolv.Residual_amount_paid_into_the_estate__c = getSumOfAmounts(form65BisParts.residualAmount.Debtor);
        }
        if (form65BisParts?.requiredMonthlyAmount?.Debtor != null) {
            insolv.Surplus_Income_Form65__c = getSumOfAmounts(form65BisParts.requiredMonthlyAmount.Debtor);
        }
        if (form65BisParts?.requiredAmountDifference?.Debtor != null) {
            insolv.Residual_amount_paid_surplus_income__c = getSumOfAmounts(form65BisParts.requiredAmountDifference.Debtor);
        }
    }

    //monthlyIncome
    public static void parseMonthlyIncome(MonthlyIncome monthlyIncome, Insolvency__c insolv) {
        if (monthlyIncome.totalMonthlyIncomeOfTheFamilyUnit != null) {
            insolv.Total_Monthly_Income_Of_Family__c = getDecimalValue(monthlyIncome.totalMonthlyIncomeOfTheFamilyUnit);
        }
        if (monthlyIncome.grossSelfEmploymentIncome != null) {
            insolv.Gross_Self_Employment_Income__c = getSumOfAmounts(monthlyIncome.grossSelfEmploymentIncome);
        }
        if (monthlyIncome.childTaxBenefit != null) {
            parseChildTaxBenefit(monthlyIncome.childTaxBenefit, insolv);
        }
        if (monthlyIncome.netChildSupport != null) {
            parseNetChildSupport(monthlyIncome.netChildSupport, insolv);
        }
        if (monthlyIncome.netPensionAnnuities != null) {
            parseNetPensionAnnuities(monthlyIncome.netPensionAnnuities, insolv);
        }
        if (monthlyIncome.netSelfEmploymentIncome != null) {
            parseNetSelfEmploymentIncome(monthlyIncome.netSelfEmploymentIncome, insolv);
        }
        if (monthlyIncome.netSocialAssistance != null) {
            parseNetSocialAssistance(monthlyIncome.netSocialAssistance, insolv);
        }
        if (monthlyIncome.netSpousalSupport != null) {
            parseNetSpousalSupport(monthlyIncome.netSpousalSupport, insolv);
        }
        if (monthlyIncome.netEmploymentIncome != null) {
            parseNetEmploymentIncome(monthlyIncome.netEmploymentIncome, insolv);
        }
        if (monthlyIncome.netEmploymentInsuranceBenefits != null) {
            parseNetEmploymentInsuranceBenefits(monthlyIncome.netEmploymentInsuranceBenefits, insolv);
        }
        if (monthlyIncome.otherNetIncome != null) {
            parseOtherNetIncome(monthlyIncome.otherNetIncome, insolv);
        }
        if (monthlyIncome.totalMonthlyIncome != null) {
            parseTotalMonthlyIncome(monthlyIncome.totalMonthlyIncome, insolv);
        }
        if (monthlyIncome?.netOtherInsuranceBenefits?.Debtor != null) {
            insolv.Net_other_insurance_benefits_Debtor__c = getSumOfAmounts(monthlyIncome.netOtherInsuranceBenefits.Debtor);
        }
        if (monthlyIncome?.netGovernmentBenefits?.Debtor != null) {
            insolv.Net_government_benefits_Debtor__c = getSumOfAmounts(monthlyIncome.netGovernmentBenefits.Debtor);
        }
        if (monthlyIncome?.netOtherBenefits?.Debtor != null) {
            insolv.Net_other_benefits_Debtor__c = getSumOfAmounts(monthlyIncome.netOtherBenefits.Debtor);
        }
    }

    // parseMonthlyNonDiscretionaryExpenses
    public static void parseMonthlyNonDiscretionaryExpenses(MonthlyNonDiscretionaryExpenses monthlyNonDiscretionaryExpenses, Insolvency__c insolv) {
        if (monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit != null) {
            insolv.Total_Non_Discretionary_Expenses_Family__c = getDecimalValue(
                monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit
            );
        }

        if (monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor != null) {
            insolv.Available_Monthly_Income_Of_Debtor__c = getSumOfAmounts(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor);
        }

        if (monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheFamilyUnit != null) {
            insolv.Available_Monthly_Income_Of_Family__c = getDecimalValue(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheFamilyUnit);
        }

        if (monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit != null) {
            insolv.Debtor_Portion_Of_Monthly_Income__c = getSumOfAmounts(
                monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit
            );
        }

        // childCare
        if (monthlyNonDiscretionaryExpenses.childCare != null) {
            parsechildCare(monthlyNonDiscretionaryExpenses.childCare, insolv);
        }
        // childCare END

        // childSupportPayments
        if (monthlyNonDiscretionaryExpenses.childSupportPayments != null) {
            parseChildSupportPayments(monthlyNonDiscretionaryExpenses.childSupportPayments, insolv);
        }
        // childSupportPayments END

        // debtsWhereStayHasBeenLifted
        if (monthlyNonDiscretionaryExpenses.debtsWhereStayHasBeenLifted != null) {
            parseDebtsWhereStayHasBeenLifted(monthlyNonDiscretionaryExpenses.debtsWhereStayHasBeenLifted, insolv);
        }
        // debtsWhereStayHasBeenLifted END

        // expensesAsAConditionOfEmployment
        if (monthlyNonDiscretionaryExpenses.expensesAsAConditionOfEmployment != null) {
            parseExpensesAsAConditionOfEmployment(monthlyNonDiscretionaryExpenses.expensesAsAConditionOfEmployment, insolv);
        }
        // expensesAsAConditionOfEmployment END

        // finesPenaltiesImposedByTheCourt
        if (monthlyNonDiscretionaryExpenses.finesPenaltiesImposedByTheCourt != null) {
            parseFinesPenaltiesImposedByTheCourt(monthlyNonDiscretionaryExpenses.finesPenaltiesImposedByTheCourt, insolv);
        }
        // finesPenaltiesImposedByTheCourt END

        // medicalConditionExpenses
        if (monthlyNonDiscretionaryExpenses.medicalConditionExpenses != null) {
            parseMedicalConditionExpenses(monthlyNonDiscretionaryExpenses.medicalConditionExpenses, insolv);
        }
        // medicalConditionExpenses END

        // otherExpenses
        if (monthlyNonDiscretionaryExpenses.otherExpenses != null) {
            parseOtherExpenses(monthlyNonDiscretionaryExpenses.otherExpenses, insolv);
        }
        // otherExpenses END

        // spousalSupportPayments
        if (monthlyNonDiscretionaryExpenses.spousalSupportPayments != null) {
            parseSpousalSupportPayments(monthlyNonDiscretionaryExpenses.spousalSupportPayments, insolv);
        }
        // spousalSupportPayments END

        // totalMonthlyNonDiscretionaryExpenses
        if (monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpenses != null) {
            parseTotalMonthlyNonDiscretionaryExpenses(monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpenses, insolv);
        }
        // totalMonthlyNonDiscretionaryExpenses END
    }

    // Used for form65Bis
    public static void parseNewMonthlyNonDiscretionaryExpenses(NewMonthlyNonDiscretionaryExpenses monthlyNonDiscretionaryExpenses, Insolvency__c insolv) {
        if (monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit != null) {
            insolv.Total_Non_Discretionary_Expenses_Family__c = getDecimalValue(
                monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit
            );
        }
        if (
            monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor != null &&
            monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor.Debtor != null
        ) {
            insolv.Available_Monthly_Income_Of_Debtor__c = getSumOfAmounts(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor.Debtor);
        }
        if (monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheFamilyUnit != null) {
            insolv.Available_Monthly_Income_Of_Family__c = getDecimalValue(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheFamilyUnit);
        }
        if (
            monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit != null &&
            monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit.Debtor != null
        ) {
            insolv.Debtor_Portion_Of_Monthly_Income__c = getSumOfAmounts(
                monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit.Debtor
            );
        }
        if (monthlyNonDiscretionaryExpenses.childCare != null) {
            parsechildCare(monthlyNonDiscretionaryExpenses.childCare, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.childSupportPayments != null) {
            parseChildSupportPayments(monthlyNonDiscretionaryExpenses.childSupportPayments, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.debtsWhereStayHasBeenLifted != null) {
            parseDebtsWhereStayHasBeenLifted(monthlyNonDiscretionaryExpenses.debtsWhereStayHasBeenLifted, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.expensesAsAConditionOfEmployment != null) {
            parseExpensesAsAConditionOfEmployment(monthlyNonDiscretionaryExpenses.expensesAsAConditionOfEmployment, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.finesPenaltiesImposedByTheCourt != null) {
            parseFinesPenaltiesImposedByTheCourt(monthlyNonDiscretionaryExpenses.finesPenaltiesImposedByTheCourt, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.medicalConditionExpenses != null) {
            parseMedicalConditionExpenses(monthlyNonDiscretionaryExpenses.medicalConditionExpenses, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.otherExpenses != null) {
            parseOtherExpenses(monthlyNonDiscretionaryExpenses.otherExpenses, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.spousalSupportPayments != null) {
            parseSpousalSupportPayments(monthlyNonDiscretionaryExpenses.spousalSupportPayments, insolv);
        }
        if (monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpenses != null) {
            parseTotalMonthlyNonDiscretionaryExpenses(monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpenses, insolv);
        }
    }

    // monthlyDiscretionaryExpenses
    public static void parseMonthlyDiscretionaryExpenses(MonthlyDiscretionaryExpenses monthlyDiscretionaryExpenses, Insolvency__c insolv) {
        if (monthlyDiscretionaryExpenses.totalFamilyUnitMonthlyDiscretionaryExpenses != null) {
            insolv.Monthly_Discretionary_Expenses_Of_Family__c = getDecimalValue(monthlyDiscretionaryExpenses.totalFamilyUnitMonthlyDiscretionaryExpenses);
        }
        if (monthlyDiscretionaryExpenses.familyUnitMonthlySurplusOrDeficit != null) {
            insolv.Monthly_Surplus_Deficit_Of_Family__c = getDecimalValue(monthlyDiscretionaryExpenses.familyUnitMonthlySurplusOrDeficit);
        }
        if (monthlyDiscretionaryExpenses.housingExpenses != null) {
            parseHousingExpenses(monthlyDiscretionaryExpenses.housingExpenses, insolv);
        }
        if (monthlyDiscretionaryExpenses.insuranceExpenses != null) {
            parseInsuranceExpenses(monthlyDiscretionaryExpenses.insuranceExpenses, insolv);
        }
        if (monthlyDiscretionaryExpenses.livingExpenses != null) {
            parseLivingExpenses(monthlyDiscretionaryExpenses.livingExpenses, insolv);
        }
        if (monthlyDiscretionaryExpenses.nonRecoverableMedicalExpenses != null) {
            parseNonRecoverableMedicalExpenses(monthlyDiscretionaryExpenses.nonRecoverableMedicalExpenses, insolv);
        }
        if (monthlyDiscretionaryExpenses.payments != null) {
            parsePayments(monthlyDiscretionaryExpenses.payments, insolv);
        }
        if (monthlyDiscretionaryExpenses.personalExpenses != null) {
            parsePersonalExpenses(monthlyDiscretionaryExpenses.personalExpenses, insolv);
        }
        if (monthlyDiscretionaryExpenses.transportationExpenses != null) {
            parseTransportationExpenses(monthlyDiscretionaryExpenses.transportationExpenses, insolv);
        }
    }

    /**
     * @description : Parse and populate assets
     * @author adesh.ikhar@canaccede.com | 10-29-2024
     * @param assetList
     * @param insolv
     **/
    public static void parseAssets(List<Type> assetList, Insolvency__c insolv) {
        List<String> homeAssetTypes = new List<String>{ 'PRINCIPAL RESIDENCE', 'HOUSE', 'COTTAGE' };
        Decimal otherAssets = 0;
        Decimal homeAssets = 0;
        for (Type asset : assetList) {
            if (homeAssetTypes.contains(asset.type.toUpperCase())) {
                homeAssets += Decimal.valueOf(asset.estimatedDollarValue);
            }
            otherAssets += Decimal.valueOf(asset.estimatedDollarValue);
        }
        otherAssets = otherAssets - homeAssets;
        insolv.Home_Assets__c = homeAssets == 0 ? null : homeAssets;
        insolv.Other_Assets__c = otherAssets == 0 ? null : otherAssets;
    }

    public static void parseCommonForm79Parts(
        Assets assets,
        List<Debtors> debtors,
        Liability liabilities,
        Insolvency__c insolv,
        List<Insolvency_Account__c> insolvAccounts,
        List<Creditor_Account__c> creditorAccounts
    ) {
        if (assets != null) {
            if (assets.totalEstimatedDollarValue != null) {
                insolv.Total_Estimated_Dollar_Value__c = getDecimalValue(assets.totalEstimatedDollarValue);
            }

            if (assets.totalSecuredAmountOrLiens != null) {
                insolv.Total_Secured_Amount_Or_Liens__c = getDecimalValue(assets.totalSecuredAmountOrLiens);
            }

            if (assets.totalEstimatedNetRealizableDollarValue != null) {
                insolv.Total_Estimated_Realizable_Value__c = getDecimalValue(assets.totalEstimatedNetRealizableDollarValue);
            }
            if (assets.items != null && !assets.items.isEmpty()) {
                parseAssets(assets.items, insolv);
            }
        }

        if (debtors != null) {
            insolv = createDebtors(debtors, insolv);
        }

        if (liabilities != null) {
            Liability liability = liabilities;

            if (liability.totalUnsecuredLiabilities != null) {
                insolv.Total_Insolvency_Unsecured_Liabilities__c = getDecimalValue(liability.totalUnsecuredLiabilities);
            }

            if (liability.totalSecuredLiabilities != null) {
                insolv.Total_Insolvency_Secured_Liabilities__c = getDecimalValue(liability.totalSecuredLiabilities);
            }

            if (liability.totalPreferredLiabilities != null) {
                insolv.Total_Insolvency_Preferred_Liabilities__c = getDecimalValue(liability.totalPreferredLiabilities);
            }

            if (liability.totalLiabilities != null) {
                insolv.Total_Liabilities__c = getDecimalValue(liability.totalLiabilities);
            }

            if (liability.items != null) {
                createInsolvencyAccounts(liability.items, insolv, insolvAccounts, creditorAccounts);
            }
        }
    }

    // Form79Parts
    public static void parseForm79Parts(
        Form79Parts form79Parts,
        Insolvency__c insolv,
        List<Insolvency_Account__c> insolvAccounts,
        List<Creditor_Account__c> creditorAccounts
    ) {
        if (form79Parts.everMadeProposal != null) {
            insolv.Ever_Made_Proposal__c = getYesNoValues(form79Parts.everMadeProposal);
        }
        if (form79Parts.everBeenBankruptBefore != null) {
            insolv.Ever_been_Bankrupt_Before__c = getYesNoValues(form79Parts.everBeenBankruptBefore);
        }
        if (form79Parts.numberOfPersonsInHousehold != null) {
            insolv.Number_Of_Persons_In_Household__c = getDecimalValue(form79Parts.numberOfPersonsInHousehold);
        }
        if (form79Parts.numberOfPersonsSeventeenOrLess != null) {
            insolv.Number_Of_Persons_In_Household_Below_17__c = getDecimalValue(form79Parts.numberOfPersonsSeventeenOrLess);
        }
        if (form79Parts.totalSecuredClaims != null) {
            insolv.Total_Secured_Claims__c = getDecimalValue(form79Parts.totalSecuredClaims);
        }
        if (form79Parts.totalUnsecuredClaims != null) {
            insolv.Total_Unsecured_Claims__c = getDecimalValue(form79Parts.totalUnsecuredClaims);
        }
        if (form79Parts.totalAssets != null) {
            insolv.Total_Assets__c = getDecimalValue(form79Parts.totalAssets);
        }
        parseCommonForm79Parts(form79Parts.assets, form79Parts.debtors, form79Parts.liabilities, insolv, insolvAccounts, creditorAccounts);
    }

    public static void parseFinancialAdvisorInfo(List<AdvisorInformation> advisorInformation, Insolvency__c insolv) {
        AdvisorInformation advisorInfo = advisorInformation[0];
        if (advisorInfo.firstName != null || advisorInfo.middleName != null || advisorInfo.lastName != null) {
            insolv.Name_of_Financial_Advisor__c = advisorInfo.firstName + ' ' + checkAndGetStringValue(advisorInfo.middleName) + ' ' + advisorInfo.lastName;
        }
        if (advisorInfo.org != null) {
            insolv.Organization_for_the_Financial_Advisor__c = advisorInfo.org;
        }
        if (advisorInfo.streetAddress != null || advisorInfo.city != null || advisorInfo.province != null || advisorInfo.postalCode != null) {
            insolv.Address_of_Financial_Advisor__c =
                advisorInfo.streetAddress +
                ',' +
                advisorInfo.city +
                ',' +
                advisorInfo.province +
                ',' +
                advisorInfo.postalCode;
        }
        if (advisorInfo.amountPaid != null) {
            insolv.Total_paid_to_Financial_Advisor__c = getDecimalValue(advisorInfo.amountPaid);
        }
        if (advisorInfo.amountCommitted != null) {
            insolv.Total_to_be_paid_to_Financial_Advisor__c = getDecimalValue(advisorInfo.amountCommitted);
        }
    }

    // Form79BisParts
    public static void parseForm79BisParts(
        Form79BisParts form79BisParts,
        Insolvency__c insolv,
        List<Insolvency_Account__c> insolvAccounts,
        List<Creditor_Account__c> creditorAccounts
    ) {
        if (form79BisParts?.debtors != null && !form79BisParts.debtors.isEmpty()) {
            Debtors primaryDebtor = form79BisParts.debtors[0];
            if (primaryDebtor.maritalStatusEvents != null && !primaryDebtor.maritalStatusEvents.isEmpty()) {
                List<MaritalStatusEvents> debtorMaritalStatusEvents = primaryDebtor.maritalStatusEvents;
                debtorMaritalStatusEvents.sort();
                insolv.Debtor_1_Marital_Status__c = getMaritalStaus(debtorMaritalStatusEvents[0].maritalStatus);
            }
            if (primaryDebtor.everMadeProposal != null) {
                insolv.Ever_Made_Proposal__c = getYesNoValues(primaryDebtor.everMadeProposal);
            }
            if (primaryDebtor.everBeenBankruptBefore != null) {
                insolv.Ever_been_Bankrupt_Before__c = getYesNoValues(primaryDebtor.everBeenBankruptBefore);
            }
            if (primaryDebtor.numberOfPersonsInHousehold != null) {
                insolv.Number_Of_Persons_In_Household_Debtor__c = getDecimalValue(primaryDebtor.numberOfPersonsInHousehold);
                insolv.Number_Of_Persons_In_Household__c = insolv.Number_Of_Persons_In_Household_Debtor__c;
            }
            if (primaryDebtor.numberOfPersonsSeventeenOrLess != null) {
                insolv.No_Of_Persons_In_House_Below_17_Debtor__c = getDecimalValue(primaryDebtor.numberOfPersonsSeventeenOrLess);
                insolv.Number_Of_Persons_In_Household_Below_17__c = insolv.No_Of_Persons_In_House_Below_17_Debtor__c;
            }
            if (primaryDebtor.spouseFirstName != null || primaryDebtor.spouseMiddleName != null || primaryDebtor.spouseLastName != null) {
                insolv.Debtor_1_Spouse_CommonLaw_Partner_Name__c =
                    primaryDebtor.spouseFirstName +
                    ' ' +
                    checkAndGetStringValue(primaryDebtor.spouseMiddleName) +
                    ' ' +
                    primaryDebtor.spouseLastName;
            }
            if (primaryDebtor.employmentStatus != null) {
                insolv.Employment_Status__c = primaryDebtor.employmentStatus;
            }
            if (primaryDebtor.fromWhenEmployed != null) {
                insolv.Employment_From_Date__c = Date.valueOf(primaryDebtor.fromWhenEmployed + '-01');
            }
            if (primaryDebtor.toWhenEmployed != null) {
                insolv.Employment_To_Date__c = Date.valueOf(primaryDebtor.toWhenEmployed + '-01');
            }
            if (primaryDebtor.adviceReceived != null) {
                insolv.Used_a_Financial_Advisor__c = getYesNoValues(primaryDebtor.adviceReceived);
            }
            if (insolv.Used_a_Financial_Advisor__c == 'Yes') {
                parseFinancialAdvisorInfo(primaryDebtor.advisorInformation, insolv);
            }
            // Secondary debtor field mapping
            if (form79BisParts.debtors.size() > 1) {
                Debtors secondaryDebtor = form79BisParts.debtors[1];
                if (secondaryDebtor.maritalStatusEvents != null && !secondaryDebtor.maritalStatusEvents.isEmpty()) {
                    List<MaritalStatusEvents> debtorMaritalStatusEvents = secondaryDebtor.maritalStatusEvents;
                    debtorMaritalStatusEvents.sort();
                    insolv.Debtor_2_Marital_Status__c = getMaritalStaus(debtorMaritalStatusEvents[0].maritalStatus);
                }
                if (secondaryDebtor.everMadeProposal != null) {
                    insolv.Ever_Made_Proposal_Debtor1__c = getYesNoValues(secondaryDebtor.everMadeProposal);
                }
                if (secondaryDebtor.everBeenBankruptBefore != null) {
                    insolv.Ever_been_Bankrupt_Before_Debtor1__c = getYesNoValues(secondaryDebtor.everBeenBankruptBefore);
                }
                if (secondaryDebtor.numberOfPersonsInHousehold != null) {
                    insolv.Number_Of_Persons_In_Household_Debtor1__c = getDecimalValue(secondaryDebtor.numberOfPersonsInHousehold);
                }
                if (secondaryDebtor.numberOfPersonsSeventeenOrLess != null) {
                    insolv.No_Of_Persons_In_House_Below_17_Debtor1__c = getDecimalValue(secondaryDebtor.numberOfPersonsSeventeenOrLess);
                }
                if (secondaryDebtor.spouseFirstName != null || secondaryDebtor.spouseMiddleName != null || secondaryDebtor.spouseLastName != null) {
                    insolv.Debtor_2_Spouse_CommonLaw_Partner_Name__c =
                        secondaryDebtor.spouseFirstName +
                        ' ' +
                        checkAndGetStringValue(secondaryDebtor.spouseMiddleName) +
                        ' ' +
                        secondaryDebtor.spouseLastName;
                }
                if (secondaryDebtor.employmentStatus != null) {
                    insolv.Employment_Status_Debtor1__c = secondaryDebtor.employmentStatus;
                }
                if (secondaryDebtor.fromWhenEmployed != null) {
                    insolv.Employment_From_Date_Debtor1__c = Date.valueOf(secondaryDebtor.fromWhenEmployed + '-01');
                }
                if (secondaryDebtor.toWhenEmployed != null) {
                    insolv.Employment_To_Date_Debtor1__c = Date.valueOf(secondaryDebtor.toWhenEmployed + '-01');
                }
                if (secondaryDebtor.adviceReceived != null) {
                    insolv.Used_a_Financial_Advisor_Debtor1__c = getYesNoValues(secondaryDebtor.adviceReceived);
                }
                if (insolv.Used_a_Financial_Advisor_Debtor1__c == 'Yes') {
                    AdvisorInformation advisorInfo = secondaryDebtor.advisorInformation[0];
                    if (advisorInfo.firstName != null || advisorInfo.middleName != null || advisorInfo.lastName != null) {
                        insolv.Name_of_Financial_Advisor_Debtor1__c =
                            advisorInfo.firstName +
                            ' ' +
                            checkAndGetStringValue(advisorInfo.middleName) +
                            ' ' +
                            advisorInfo.lastName;
                    }
                    if (advisorInfo.org != null) {
                        insolv.Org_for_the_Financial_Advisor_Debtor1__c = advisorInfo.org;
                    }
                    if (advisorInfo.streetAddress != null || advisorInfo.city != null || advisorInfo.province != null || advisorInfo.postalCode != null) {
                        insolv.Address_of_Financial_Advisor_Debtor1__c =
                            advisorInfo.streetAddress +
                            ',' +
                            advisorInfo.city +
                            ',' +
                            advisorInfo.province +
                            ',' +
                            advisorInfo.postalCode;
                    }
                    if (advisorInfo.amountPaid != null) {
                        insolv.Total_paid_to_Financial_Advisor_Debtor1__c = getDecimalValue(advisorInfo.amountPaid);
                    }
                    if (advisorInfo.amountCommitted != null) {
                        insolv.Total_to_be_paid_to_Fin_Adv_Debtor1__c = getDecimalValue(advisorInfo.amountCommitted);
                    }
                }
            }
        }
        if (form79BisParts.totalSecuredClaims != null) {
            insolv.Total_Secured_Claims__c = getDecimalValue(form79BisParts.totalSecuredClaims);
        }
        if (form79BisParts.totalUnsecuredClaims != null) {
            insolv.Total_Unsecured_Claims__c = getDecimalValue(form79BisParts.totalUnsecuredClaims);
        }
        if (form79BisParts.totalAssets != null) {
            insolv.Total_Assets__c = getDecimalValue(form79BisParts.totalAssets);
        }
        parseCommonForm79Parts(form79BisParts.assets, form79BisParts.debtors, form79BisParts.liabilities, insolv, insolvAccounts, creditorAccounts);
    }

    // childTaxBenefit
    public static void parseChildTaxBenefit(FamilyMembers childTaxBenefit, Insolvency__c insolv) {
        if (childTaxBenefit.Debtor != null) {
            insolv.Child_Tax_Benefit_Debtor__c = getSumOfAmounts(childTaxBenefit.Debtor);
        }
        // else if(childTaxBenefit.Bankrupt != NULL){
        //    insolv.Child_Tax_Benefit_Debtor__c = getDecimalValue(childTaxBenefit.Bankrupt);
        // }
        if (childTaxBenefit.Others != null) {
            insolv.Child_Tax_Benefit_Other__c = getSumOfAmounts(childTaxBenefit.Others);
        }
        if (childTaxBenefit.Spouse != null) {
            insolv.Child_Tax_Benefit_Spouse__c = getSumOfAmounts(childTaxBenefit.Spouse);
        }
    }

    // netChildSupport
    public static void parseNetChildSupport(FamilyMembers netChildSupport, Insolvency__c insolv) {
        if (netChildSupport.Debtor != null) {
            insolv.Monthly_Net_Child_Support_Debtor__c = getSumOfAmounts(netChildSupport.Debtor);
        }
        // else if(netChildSupport.Bankrupt != NULL){
        //    insolv.Monthly_Net_Child_Support_Debtor__c = getDecimalValue(netChildSupport.Bankrupt);
        // }
        if (netChildSupport.Others != null) {
            insolv.Monthly_Net_Child_Support_Other__c = getSumOfAmounts(netChildSupport.Others);
        }
        if (netChildSupport.Spouse != null) {
            insolv.Monthly_Net_Child_Support_Spouse__c = getSumOfAmounts(netChildSupport.Spouse);
        }
    }

    // parseNetPensionAnnuities
    public static void parseNetPensionAnnuities(FamilyMembers netPensionAnnuities, Insolvency__c insolv) {
        if (netPensionAnnuities.Debtor != null) {
            insolv.Monthly_Net_Pension_Annuities_Debtor__c = getSumOfAmounts(netPensionAnnuities.Debtor);
        }
        // else if(netPensionAnnuities.Bankrupt != NULL){
        //    insolv.Monthly_Net_Pension_Annuities_Debtor__c = getDecimalValue(netPensionAnnuities.Bankrupt);
        // }
        if (netPensionAnnuities.Others != null) {
            insolv.Monthly_Net_Pension_Annuities_Other__c = getSumOfAmounts(netPensionAnnuities.Others);
        }
        if (netPensionAnnuities.Spouse != null) {
            insolv.Monthly_Net_Pension_Annuities_Spouse__c = getSumOfAmounts(netPensionAnnuities.Spouse);
        }
    }

    // parseNetSelfEmploymentIncome
    public static void parseNetSelfEmploymentIncome(FamilyMembers netSelfEmploymentIncome, Insolvency__c insolv) {
        if (netSelfEmploymentIncome.Debtor != null) {
            insolv.Net_Self_Employment_Income_Debtor__c = getSumOfAmounts(netSelfEmploymentIncome.Debtor);
        }
        // else if(netSelfEmploymentIncome.Bankrupt != NULL){
        //    insolv.Net_Self_Employment_Income_Debtor__c = getDecimalValue(netSelfEmploymentIncome.Bankrupt);
        // }
        if (netSelfEmploymentIncome.Others != null) {
            insolv.Net_Self_Employment_Income_Other__c = getSumOfAmounts(netSelfEmploymentIncome.Others);
        }
        if (netSelfEmploymentIncome.Spouse != null) {
            insolv.Net_Self_Employment_Income_Spouse__c = getSumOfAmounts(netSelfEmploymentIncome.Spouse);
        }
    }

    // netSocialAssistance
    public static void parseNetSocialAssistance(FamilyMembers netSocialAssistance, Insolvency__c insolv) {
        if (netSocialAssistance.Debtor != null) {
            insolv.Monthly_Net_Social_Assistance_Debtor__c = getSumOfAmounts(netSocialAssistance.Debtor);
        }
        // else if(netSocialAssistance.Bankrupt != NULL){
        //    insolv.Monthly_Net_Social_Assistance_Debtor__c = getDecimalValue(netSocialAssistance.Bankrupt);
        // }
        if (netSocialAssistance.Others != null) {
            insolv.Monthly_Net_Social_Assistance_Other__c = getSumOfAmounts(netSocialAssistance.Others);
        }
        if (netSocialAssistance.Spouse != null) {
            insolv.Monthly_Net_Social_Assistance_Spouse__c = getSumOfAmounts(netSocialAssistance.Spouse);
        }
    }

    // netSpousalSupport
    public static void parseNetSpousalSupport(FamilyMembers netSpousalSupport, Insolvency__c insolv) {
        if (netSpousalSupport.Debtor != null) {
            insolv.Monthly_Net_Spoucal_Support_Debtor__c = getSumOfAmounts(netSpousalSupport.Debtor);
        }
        // else if(netSpousalSupport.Bankrupt != NULL){
        //    insolv.Monthly_Net_Spoucal_Support_Debtor__c = getDecimalValue(netSpousalSupport.Bankrupt);
        // }
        if (netSpousalSupport.Others != null) {
            insolv.Monthly_Net_Spoucal_Support_Other__c = getSumOfAmounts(netSpousalSupport.Others);
        }
        if (netSpousalSupport.Spouse != null) {
            insolv.Monthly_Net_Spoucal_Support_Spouse__c = getSumOfAmounts(netSpousalSupport.Spouse);
        }
    }

    // parseNetEmploymentIncome
    public static void parseNetEmploymentIncome(FamilyMembers netEmploymentIncome, Insolvency__c insolv) {
        if (netEmploymentIncome.Debtor != null) {
            insolv.Monthly_Net_Employment_Income_Debtor__c = getSumOfAmounts(netEmploymentIncome.Debtor);
        }
        // else if(netEmploymentIncome.Bankrupt != NULL){
        //    insolv.Monthly_Net_Employment_Income_Debtor__c = getDecimalValue(netEmploymentIncome.Bankrupt);
        // }
        if (netEmploymentIncome.Others != null) {
            insolv.Monthly_Net_Employment_Income_Other__c = getSumOfAmounts(netEmploymentIncome.Others);
        }
        if (netEmploymentIncome.Spouse != null) {
            insolv.Monthly_Net_Employment_Income_Spouse__c = getSumOfAmounts(netEmploymentIncome.Spouse);
        }
    }

    // netEmploymentInsuranceBenefits
    public static void parseNetEmploymentInsuranceBenefits(FamilyMembers netEmploymentInsuranceBenefits, Insolvency__c insolv) {
        if (netEmploymentInsuranceBenefits.Debtor != null) {
            insolv.Monthly_Net_Empl_Ins_Benefits_Debtor__c = getSumOfAmounts(netEmploymentInsuranceBenefits.Debtor);
        }
        // else if(netEmploymentInsuranceBenefits.Bankrupt != NULL){
        //    insolv.Monthly_Net_Empl_Ins_Benefits_Debtor__c = getDecimalValue(netEmploymentInsuranceBenefits.Bankrupt);
        // }
        if (netEmploymentInsuranceBenefits.Others != null) {
            insolv.Monthly_Net_Empl_Ins_Benefits_Other__c = getSumOfAmounts(netEmploymentInsuranceBenefits.Others);
        }
        if (netEmploymentInsuranceBenefits.Spouse != null) {
            insolv.Monthly_Net_Empl_Ins_Benefits_Spouse__c = getSumOfAmounts(netEmploymentInsuranceBenefits.Spouse);
        }
    }

    // parseOtherNetIncome
    public static void parseOtherNetIncome(FamilyMembers otherNetIncome, Insolvency__c insolv) {
        if (otherNetIncome.Debtor != null) {
            insolv.Other_Net_Income_Debtor__c = getSumOfAmounts(otherNetIncome.Debtor);
        }
        // else if(otherNetIncome.Bankrupt != NULL){
        //    insolv.Other_Net_Income_Debtor__c = getDecimalValue(otherNetIncome.Bankrupt);
        // }
        if (otherNetIncome.Others != null) {
            insolv.Other_Net_Income_Other__c = getSumOfAmounts(otherNetIncome.Others);
        }
        if (otherNetIncome.Spouse != null) {
            insolv.Other_Net_Income_Spouse__c = getSumOfAmounts(otherNetIncome.Spouse);
        }
    }

    // totalMonthlyIncome
    public static void parseTotalMonthlyIncome(FamilyMembers totalMonthlyIncome, Insolvency__c insolv) {
        if (totalMonthlyIncome.Debtor != null) {
            insolv.Total_Monthly_Income_Debtor__c = getSumOfAmounts(totalMonthlyIncome.Debtor);
        }
        // else if(totalMonthlyIncome.Bankrupt != NULL){
        //    insolv.Total_Monthly_Income_Debtor__c = getDecimalValue(totalMonthlyIncome.Bankrupt);
        // }
        if (totalMonthlyIncome.Others != null) {
            insolv.Total_Monthly_Income_Other__c = getSumOfAmounts(totalMonthlyIncome.Others);
        }
        if (totalMonthlyIncome.Spouse != null) {
            insolv.Total_Monthly_Income_Spouse__c = getSumOfAmounts(totalMonthlyIncome.Spouse);
        }
    }

    //childCare
    public static void parseChildCare(FamilyMembers childCare, Insolvency__c insolv) {
        if (childCare.Debtor != null) {
            insolv.Monthly_Child_Care_Debtor__c = getSumOfAmounts(childCare.Debtor);
        }
        // else if(childCare.Bankrupt != NULL){
        //    insolv.Monthly_Child_Care_Debtor__c = getDecimalValue(childCare.Bankrupt);
        // }
        if (childCare.Others != null) {
            insolv.Monthly_Child_Care_Other__c = getSumOfAmounts(childCare.Others);
        }
        if (childCare.Spouse != null) {
            insolv.Monthly_Child_Care_Spouse__c = getSumOfAmounts(childCare.Spouse);
        }
    }

    //childSupportPayments
    public static void parseChildSupportPayments(FamilyMembers childSupportPayments, Insolvency__c insolv) {
        if (childSupportPayments.Debtor != null) {
            insolv.Monthly_Child_Support_Payments_Debtor__c = getSumOfAmounts(childSupportPayments.Debtor);
        }
        // else if(childSupportPayments.Bankrupt != NULL){
        //    insolv.Monthly_Child_Support_Payments_Debtor__c = getDecimalValue(childSupportPayments.Bankrupt);
        // }
        if (childSupportPayments.Others != null) {
            insolv.Monthly_Child_Support_Payments_Other__c = getSumOfAmounts(childSupportPayments.Others);
        }
        if (childSupportPayments.Spouse != null) {
            insolv.Monthly_Child_Support_Payments_Spouse__c = getSumOfAmounts(childSupportPayments.Spouse);
        }
    }

    //debtsWhereStayHasBeenLifted
    public static void parseDebtsWhereStayHasBeenLifted(FamilyMembers debtsWhereStayHasBeenLifted, Insolvency__c insolv) {
        if (debtsWhereStayHasBeenLifted.Debtor != null) {
            insolv.Monthly_Debts_Stay_Lifted_Debtor__c = getSumOfAmounts(debtsWhereStayHasBeenLifted.Debtor);
        }
        // else if(debtsWhereStayHasBeenLifted.Bankrupt != NULL){
        //    insolv.Monthly_Debts_Stay_Lifted_Debtor__c = getDecimalValue(debtsWhereStayHasBeenLifted.Bankrupt);
        // }
        if (debtsWhereStayHasBeenLifted.Others != null) {
            insolv.Monthly_Debts_Stay_Lifted_Other__c = getSumOfAmounts(debtsWhereStayHasBeenLifted.Others);
        }
        if (debtsWhereStayHasBeenLifted.Spouse != null) {
            insolv.Monthly_Debts_Stay_Lifted_Spouse__c = getSumOfAmounts(debtsWhereStayHasBeenLifted.Spouse);
        }
    }

    // expensesAsAConditionOfEmployment
    public static void parseExpensesAsAConditionOfEmployment(FamilyMembers expensesAsAConditionOfEmployment, Insolvency__c insolv) {
        if (expensesAsAConditionOfEmployment.Debtor != null) {
            insolv.Monthly_Expenses_Empl_Cond_Debtor__c = getSumOfAmounts(expensesAsAConditionOfEmployment.Debtor);
        }
        // else if(expensesAsAConditionOfEmployment.Bankrupt != NULL){
        //    insolv.Monthly_Expenses_Empl_Cond_Debtor__c = getDecimalValue(expensesAsAConditionOfEmployment.Bankrupt);
        // }
        if (expensesAsAConditionOfEmployment.Others != null) {
            insolv.Monthly_Expenses_Empl_Cond_Other__c = getSumOfAmounts(expensesAsAConditionOfEmployment.Others);
        }
        if (expensesAsAConditionOfEmployment.Spouse != null) {
            insolv.Monthly_Expenses_Empl_Cond_Spouse__c = getSumOfAmounts(expensesAsAConditionOfEmployment.Spouse);
        }
    }

    // finesPenaltiesImposedByTheCourt
    public static void parseFinesPenaltiesImposedByTheCourt(FamilyMembers finesPenaltiesImposedByTheCourt, Insolvency__c insolv) {
        if (finesPenaltiesImposedByTheCourt.Debtor != null) {
            insolv.Monthly_Fines_Imposed_Court_Debtor__c = getSumOfAmounts(finesPenaltiesImposedByTheCourt.Debtor);
        }
        // else if(finesPenaltiesImposedByTheCourt.Bankrupt != NULL){
        //    insolv.Monthly_Fines_Imposed_Court_Debtor__c = getDecimalValue(finesPenaltiesImposedByTheCourt.Bankrupt);
        // }
        if (finesPenaltiesImposedByTheCourt.Others != null) {
            insolv.Monthly_Fines_Imposed_Court_Other__c = getSumOfAmounts(finesPenaltiesImposedByTheCourt.Others);
        }
        if (finesPenaltiesImposedByTheCourt.Spouse != null) {
            insolv.Monthly_Fines_Imposed_Court_Spouse__c = getSumOfAmounts(finesPenaltiesImposedByTheCourt.Spouse);
        }
    }

    // medicalConditionExpenses
    public static void parseMedicalConditionExpenses(FamilyMembers medicalConditionExpenses, Insolvency__c insolv) {
        if (medicalConditionExpenses.Debtor != null) {
            insolv.Monthly_Health_Condition_Expenses_Debtor__c = getSumOfAmounts(medicalConditionExpenses.Debtor);
        }
        // else if(medicalConditionExpenses.Bankrupt != NULL){
        //    insolv.Monthly_Health_Condition_Expenses_Debtor__c = getDecimalValue(medicalConditionExpenses.Bankrupt);
        // }
        if (medicalConditionExpenses.Others != null) {
            insolv.Monthly_Health_Condition_Expenses_Other__c = getSumOfAmounts(medicalConditionExpenses.Others);
        }
        if (medicalConditionExpenses.Spouse != null) {
            insolv.Monthly_Health_Condition_Expenses_Spouse__c = getSumOfAmounts(medicalConditionExpenses.Spouse);
        }
    }

    // otherExpenses
    public static void parseOtherExpenses(FamilyMembers otherExpenses, Insolvency__c insolv) {
        if (otherExpenses.Debtor != null) {
            insolv.Monthly_Other_Expenses_Debtor__c = getSumOfAmounts(otherExpenses.Debtor);
        }
        // else if(otherExpenses.Bankrupt != NULL){
        //    insolv.Monthly_Other_Expenses_Debtor__c = getDecimalValue(otherExpenses.Bankrupt);
        // }
        if (otherExpenses.Others != null) {
            insolv.Monthly_Other_Expenses_Other__c = getSumOfAmounts(otherExpenses.Others);
        }
        if (otherExpenses.Spouse != null) {
            insolv.Monthly_Other_Expenses_Spouse__c = getSumOfAmounts(otherExpenses.Spouse);
        }
    }

    // spousalSupportPayments
    public static void parseSpousalSupportPayments(FamilyMembers spousalSupportPayments, Insolvency__c insolv) {
        if (spousalSupportPayments.Debtor != null) {
            insolv.Monthly_Spousal_Support_Payments_Debtor__c = getSumOfAmounts(spousalSupportPayments.Debtor);
        }
        // else if(spousalSupportPayments.Bankrupt != NULL){
        //    insolv.Monthly_Spousal_Support_Payments_Debtor__c = getDecimalValue(spousalSupportPayments.Bankrupt);
        // }
        if (spousalSupportPayments.Others != null) {
            insolv.Monthly_Spousal_Support_Payments_Other__c = getSumOfAmounts(spousalSupportPayments.Others);
        }
        if (spousalSupportPayments.Spouse != null) {
            insolv.Monthly_Spousal_Support_Payments_Spouse__c = getSumOfAmounts(spousalSupportPayments.Spouse);
        }
    }

    // totalMonthlyNonDiscretionaryExpenses
    public static void parseTotalMonthlyNonDiscretionaryExpenses(FamilyMembers totalMonthlyNonDiscretionaryExpenses, Insolvency__c insolv) {
        if (totalMonthlyNonDiscretionaryExpenses.Debtor != null) {
            insolv.Total_Non_Discretionary_Expenses_Debtor__c = getSumOfAmounts(totalMonthlyNonDiscretionaryExpenses.Debtor);
        }
        // else if(totalMonthlyNonDiscretionaryExpenses.Bankrupt != NULL){
        //    insolv.Total_Non_Discretionary_Expenses_Debtor__c = getDecimalValue(totalMonthlyNonDiscretionaryExpenses.Bankrupt);
        // }
        if (totalMonthlyNonDiscretionaryExpenses.Others != null) {
            insolv.Total_Non_Discretionary_Expenses_Other__c = getSumOfAmounts(totalMonthlyNonDiscretionaryExpenses.Others);
        }
        if (totalMonthlyNonDiscretionaryExpenses.Spouse != null) {
            insolv.Total_Non_Discretionary_Expenses_Spouse__c = getSumOfAmounts(totalMonthlyNonDiscretionaryExpenses.Spouse);
        }
    }

    // housingExpenses
    public static void parseHousingExpenses(HousingExpenses housingExpenses, Insolvency__c insolv) {
        if (housingExpenses.rentMortgageHypothec != null) {
            insolv.Rent_Mortgage_Hypothec_Expenses__c = getSumOfAmounts(housingExpenses.rentMortgageHypothec);
        }
        if (housingExpenses.propertyTaxesCondoFees != null) {
            insolv.Property_Taxes_Condo_Fees_Expenses__c = getSumOfAmounts(housingExpenses.propertyTaxesCondoFees);
        }
        if (housingExpenses.heatingGasOil != null) {
            insolv.Heating_Gas_Oil_Expenses__c = getSumOfAmounts(housingExpenses.heatingGasOil);
        }
        if (housingExpenses.telephone != null) {
            insolv.Telephone_Expenses__c = getSumOfAmounts(housingExpenses.telephone);
        }
        if (housingExpenses.cable != null) {
            insolv.Cable_Expenses__c = getSumOfAmounts(housingExpenses.cable);
        }
        if (housingExpenses.hydro != null) {
            insolv.Hydro_Expenses__c = getSumOfAmounts(housingExpenses.hydro);
        }
        if (housingExpenses.water != null) {
            insolv.Water_Expenses__c = getSumOfAmounts(housingExpenses.water);
        }
        if (housingExpenses.furniture != null) {
            insolv.Furniture_Expenses__c = getSumOfAmounts(housingExpenses.furniture);
        }
        if (housingExpenses.other != null) {
            insolv.Other_Housing_Expenses__c = getSumOfAmounts(housingExpenses.other);
        }
        if (housingExpenses.internet != null) {
            insolv.Internet_Expenses__c = getSumOfAmounts(housingExpenses.internet);
        }
    }

    // insuranceExpenses
    public static void parseInsuranceExpenses(InsuranceExpenses insuranceExpenses, Insolvency__c insolv) {
        if (insuranceExpenses.vehicle != null) {
            insolv.Vehicle_Expenses__c = getSumOfAmounts(insuranceExpenses.vehicle);
        }
        if (insuranceExpenses.house != null) {
            insolv.House_Expenses__c = getSumOfAmounts(insuranceExpenses.house);
        }
        if (insuranceExpenses.furnitureContents != null) {
            insolv.Furniture_Contents_Expenses__c = getSumOfAmounts(insuranceExpenses.furnitureContents);
        }
        if (insuranceExpenses.lifeInsurance != null) {
            insolv.Life_Insurance_Expenses__c = getSumOfAmounts(insuranceExpenses.lifeInsurance);
        }
        if (insuranceExpenses.other != null) {
            insolv.Other_Insurance_Expenses__c = getSumOfAmounts(insuranceExpenses.other);
        }
    }

    //livingExpenses
    public static void parseLivingExpenses(LivingExpenses livingExpenses, Insolvency__c insolv) {
        if (livingExpenses.foodGrocery != null) {
            insolv.Food_Grocery_Expenses__c = getSumOfAmounts(livingExpenses.foodGrocery);
        }
        if (livingExpenses.laundryDryCleaning != null) {
            insolv.Laundry_Dry_Cleaning_Expenses__c = getSumOfAmounts(livingExpenses.laundryDryCleaning);
        }
        if (livingExpenses.groomingToiletries != null) {
            insolv.Grooming_Toiletries_Expenses__c = getSumOfAmounts(livingExpenses.groomingToiletries);
        }
        if (livingExpenses.clothing != null) {
            insolv.Clothing_Expenses__c = getSumOfAmounts(livingExpenses.clothing);
        }
        if (livingExpenses.other != null) {
            insolv.Other_Living_Expenses__c = getSumOfAmounts(livingExpenses.other);
        }
    }

    //nonRecoverableMedicalExpenses
    public static void parseNonRecoverableMedicalExpenses(NonRecoverableMedicalExpenses nonRecoverableMedicalExpenses, Insolvency__c insolv) {
        if (nonRecoverableMedicalExpenses.prescriptions != null) {
            insolv.Prescriptions_Expenses__c = getSumOfAmounts(nonRecoverableMedicalExpenses.prescriptions);
        }
        if (nonRecoverableMedicalExpenses.dental != null) {
            insolv.Dental_Expenses__c = getSumOfAmounts(nonRecoverableMedicalExpenses.dental);
        }
        if (nonRecoverableMedicalExpenses.other != null) {
            insolv.Other_Medical_Expenses__c = getSumOfAmounts(nonRecoverableMedicalExpenses.other);
        }
    }

    // payments
    public static void parsePayments(Payments payments, Insolvency__c insolv) {
        if (payments.paymentsToTheProposal != null) {
            insolv.Payments_To_Proposal__c = getSumOfAmounts(payments.paymentsToTheProposal);
        }
        if (payments.toSecuredCreditor != null) {
            insolv.Payment_To_Secured_Creditor__c = getSumOfAmounts(payments.toSecuredCreditor);
        }
        if (payments.otherThanMortgageAndVehicle != null) {
            insolv.Payments_Other_Than_Mortgage_Vehicle__c = getSumOfAmounts(payments.otherThanMortgageAndVehicle);
        }
        if (payments.other != null) {
            insolv.Other_Payments__c = getSumOfAmounts(payments.other);
        }
        if (payments.otherFinancialAdvisor != null) {
            insolv.Payment_to_Financial_Advisor__c = getSumOfAmounts(payments.otherFinancialAdvisor);
        }
        if (payments.otherSecuredCreditor != null) {
            insolv.Payments_Other_Than_Mortgage_Vehicle__c = getSumOfAmounts(payments.otherSecuredCreditor);
        }
    }

    // personalExpenses
    public static void parsePersonalExpenses(PersonalExpenses personalExpenses, Insolvency__c insolv) {
        if (personalExpenses.smoking != null) {
            insolv.Smoking_Expenses__c = getSumOfAmounts(personalExpenses.smoking);
        }
        if (personalExpenses.alcohol != null) {
            insolv.Alcohol_Expenses__c = getSumOfAmounts(personalExpenses.alcohol);
        }
        if (personalExpenses.diningLunchesRestaurants != null) {
            insolv.Dining_Expenses__c = getSumOfAmounts(personalExpenses.diningLunchesRestaurants);
        }
        if (personalExpenses.entertainmentSports != null) {
            insolv.Entertainment_Sports_Expenses__c = getSumOfAmounts(personalExpenses.entertainmentSports);
        }
        if (personalExpenses.giftsCharitableDonations != null) {
            insolv.Gifts_Charitable_Expenses__c = getSumOfAmounts(personalExpenses.giftsCharitableDonations);
        }
        if (personalExpenses.allowances != null) {
            insolv.Allowances_Expenses__c = getSumOfAmounts(personalExpenses.allowances);
        }
        if (personalExpenses.other != null) {
            insolv.Other_Personal_Expenses__c = getSumOfAmounts(personalExpenses.other);
        }
    }

    //transportationExpenses
    public static void parseTransportationExpenses(TransportationExpenses transportationExpenses, Insolvency__c insolv) {
        if (transportationExpenses.carLeasePayments != null) {
            insolv.Car_Lease_Payments_Expenses__c = getSumOfAmounts(transportationExpenses.carLeasePayments);
        }
        if (transportationExpenses.repairMaintenanceGas != null) {
            insolv.Repair_Maintenance_Gas_Expenses__c = getSumOfAmounts(transportationExpenses.repairMaintenanceGas);
        }
        if (transportationExpenses.publicTransportation != null) {
            insolv.Public_Transportation_Expenses__c = getSumOfAmounts(transportationExpenses.publicTransportation);
        }
        if (transportationExpenses.other != null) {
            insolv.Other_TransportationExpenses__c = getSumOfAmounts(transportationExpenses.other);
        }
    }

    // Read all Insolvency Record types and return
    public static Id getInsolvencyRecordType(String creditorName, String creditorAccountNumber, String creditorAddress) {
        creditorName = creditorName.toUpperCase();
        for (String str : scotiaBank) {
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('Scotia_Bank_Insolvency_Account');
            }
        }

        for (String str : sdaBank) {
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('SDA_Insolvency_Account');
            }
        }

        for (String str : splBank) {
            if (creditorAccountNumber != null && creditorAccountNumber.startsWith(str)) {
                return insolvencyRecordTypeMap.get('SPL_Insolvency_Account');
            }
        }

        //Ticket 4587: Added excluded account
        //String acctNameCS = '676';
        //String acctNameCS1 = '6030';
        //Ticket 4587 and 4581: fairstone account not starts with 676 and 6030 and insolvency date should be greater than 23rd May
        for (String str : fairstone) {
            /*if (
                creditorName.contains(str) &&
                creditorAccountNumber != null &&
                !(creditorAccountNumber.contains(acctNameCS)) &&
                !(creditorAccountNumber.contains(acctNameCS1)) &&
                InsolvencyAccDate > Date.newInstance(2023, 5, 23)
            ) {
                return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
            } else {
                if (creditorName.contains(str) && creditorAccountNumber == null && InsolvencyAccDate > Date.newInstance(2023, 5, 23)) {
                    return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
                }
            }*/
            //Ticket 7898: Doc Parsing Logic - Fairstone
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
            }
        }

        for (String str : fairstoneAcc) {
            if (creditorAccountNumber != null && creditorAccountNumber.startsWith(str)) {
                return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
            }
        }

        for (String str : goEasy) {
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('Goeasy_Insolvency_Account');
            }
        }

        for (String str : canadianTire) {
            if (creditorName.contains(str) && lrpSetting.Turn_On_CTB__c == true) {
                return insolvencyRecordTypeMap.get('Canadian_Tire_Insolvency_Account');
            }
        }

        for (String str : canadianTireBins) {
            if (lrpSetting.Turn_On_CTB__c == true && creditorAccountNumber != null && creditorAccountNumber.startsWith(str)) {
                return insolvencyRecordTypeMap.get('Canadian_Tire_Insolvency_Account');
            }
        }

        for (String str : canaccedeBank) {
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('Canaccede_Insolvency_Account');
            }
        }

        for (String str : fidemBank) {
            String address = String.isNotBlank(creditorAddress) ? creditorAddress.toUpperCase() : '';
            if (creditorName.contains(str)) {
                if (str != 'AFFIRM') {
                    return insolvencyRecordTypeMap.get('Fidem_Insolvency_Account');
                } else if (
                    str == 'AFFIRM' &&
                    (address.contains('PO BOX 53') &&
                    (address.contains('STATION B') || address.contains('STN B')) &&
                    address.contains('LONDON') &&
                    (address.contains('ONTARIO') || address.contains('ON')) &&
                    (address.contains('CANADA') || address.contains('CA')) &&
                    address.contains('N6A 4V3'))
                ) {
                    return insolvencyRecordTypeMap.get('Fidem_Insolvency_Account');
                }
            }
        }
        for (String str : moneyMart) {
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('Money_Mart_Insolvency_Account');
            }
        }
        for (String str : flexiti) {
            if (creditorName.contains(str)) {
                return insolvencyRecordTypeMap.get('Flexiti_Insolvency_Account');
            }
        }
        
        return null;
    }

    // Create Insolvency Account from creditor information from JSON
    public static void createInsolvencyAccounts(
        List<Liabilities> liabilities,
        Insolvency__c insolv,
        List<Insolvency_Account__c> insolvAccounts,
        List<Creditor_Account__c> creditorAccounts
    ) {
        // Insolvency calculated fields over accounts
        insolv.Total_Unsecured_Liabilities_Clc__c = 0;
        insolv.Total_Secured_Liabilities_Clc__c = 0;
        insolv.Total_Preferred_Liabilities_Clc__c = 0;
        insolv.Secured_Debts_Unsecured_Portion__c = 0;
		Decimal claimAmount;
        for (Liabilities liability : liabilities) {
            claimAmount = 0;
            Insolvency_Account__c insolvAccount = new Insolvency_Account__c();

            //insolvAccount.Name = 'unknown';
            insolvAccount.Name = UNKNOWN_RECORD_NAME;

            insolvAccount.Claim_Type__c = 'Unsecured';
            insolvAccount.Created_By_Doc_Parser__c = true;

            if (liability.creditor != null) {
                insolvAccount.Creditor_Name__c = liability.creditor;
                insolvAccount.RecordTypeId = getInsolvencyRecordType(liability.creditor, liability.accountNumber, liability.creditorAddress);
            }           
            if (liability.creditorAddress != null) {
                insolvAccount.Address_of_Creditor__c = liability.creditorAddress;
            }
            if (liability.accountNumber != null && liability.accountNumber != '') {
                //remove white spaces from Insolvency Account Name
                String formattedName = liability.accountNumber.deleteWhitespace();

                //Set default name if value is greater than 20
                if (formattedName.length() <= 20) {
                    insolvAccount.Name = formattedName;
                } else {
                    insolvAccount.Name = Other_RECORD_NAME;
                }

                /*
            //Set default name if value is greater than 20
            if(liability.accountNumber.length() <= 20){
               insolvAccount.Name = liability.accountNumber;
            }
            else{
                insolvAccount.Name = Other_RECORD_NAME;
            }
            */
            }
			//Ticket 7956: Logic for Fairstone Doc parsing
            if(insolvAccount.RecordTypeId == insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account')){
                if(!insolvAccount.Name.startsWith('5434') && !insolvAccount.Name.startsWith('5435') && insolvAccount.Creditor_Name__c.toUpperCase().contains('FAIRSTONE')) {
                    insolvAccount.Account_Type__c = 'Unknown';
                }else{
                    insolvAccount.Account_Type__c = 'Core Walmart Rewards Mastercard';
                }
            }                                            
            
            // Set default values for Canadian Tire account
            if (
                String.isNotBlank(insolvAccount.RecordTypeId) && insolvAccount.RecordTypeId == insolvencyRecordTypeMap.get('Canadian_Tire_Insolvency_Account')
            ) {
                insolvAccount.Claim_Type__c = 'Unsecured';
                insolvAccount.Type_of_Service__c = 'Service Only';
            }
            
            // Unsecured Account
            if (liability.unsecuredDebt != null && getDecimalValue(liability.unsecuredDebt) > 0) {
                insolvAccount.Unsecured_Asset_Amount__c = getDecimalValue(liability.unsecuredDebt);
                insolv.Total_Unsecured_Liabilities_Clc__c = insolv.Total_Unsecured_Liabilities_Clc__c + insolvAccount.Unsecured_Asset_Amount__c;
            	claimAmount = insolvAccount.Unsecured_Asset_Amount__c;
            }
            // Secured Account
            if (liability.securedDebt != null && getDecimalValue(liability.securedDebt) > 0) {
                insolvAccount.Secured_Asset_Amount__c = getDecimalValue(liability.securedDebt);
                insolvAccount.Claim_Type__c = 'Secured';
                insolv.Total_Secured_Liabilities_Clc__c = insolv.Total_Secured_Liabilities_Clc__c + insolvAccount.Secured_Asset_Amount__c;
				claimAmount += insolvAccount.Secured_Asset_Amount__c;
                // If it has both secured and un secured amount
                if (liability.unsecuredDebt != null && getDecimalValue(liability.unsecuredDebt) > 0) {
                    insolv.Secured_Debts_Unsecured_Portion__c = insolv.Secured_Debts_Unsecured_Portion__c + insolvAccount.Unsecured_Asset_Amount__c;
                }
            }
            if (liability.preferredDebt != null && getDecimalValue(liability.preferredDebt) > 0) {
                insolvAccount.Claim_Type__c = null;
                insolvAccount.Preferred_Amount__c = getDecimalValue(liability.preferredDebt);
                claimAmount += insolvAccount.Secured_Asset_Amount__c;
                insolv.Total_Preferred_Liabilities_Clc__c = insolv.Total_Preferred_Liabilities_Clc__c + insolvAccount.Preferred_Amount__c;
            }
            if (liability.ltc != null) {
                insolvAccount.Liabilities_Type_Code__c = liability.ltc;
            }

            // Caputre insolvency account side related creditorId  & liabilityId
            if (liability.creditorId != null) {
                insolvAccount.Creditor_Id__c = liability.creditorId;
            }
            if (liability.liabilityId != null) {
                insolvAccount.Liability_Id__c = liability.liabilityId;
            }

            // 4798
            if (
                String.isNotBlank(insolvAccount.Claim_Type__c) &&
                String.isNotBlank(insolvAccount.RecordTypeId) &&
                insolvAccount.RecordTypeId == insolvencyRecordTypeMap.get('Goeasy_Insolvency_Account')
            ) {
                insolvAccount.Type_of_Service__c = 'Service and Sale';
                if (insolvAccount.Claim_Type__c == 'Secured') {
                    insolvAccount.Type_of_Service__c = 'Service Only';
                }
            }
			//Ticket 7740: Parsing debtor amounts on creditor package accounts 
			//(sum of Secured, Unsecured and preferred amount from LIABILITIES) 
            if(claimAmount != NULL && claimAmount > 0){
                insolvAccount.Claim_Amount__c = claimAmount;
            }
            
            // Add to insolvency if it is Scotia bank, SPL, or SDA
            if (insolvAccount.RecordTypeId != null) {
                insolvAccounts.add(insolvAccount);
            } else {
                // Else create creditor account
                creditorAccounts.add(createCreditorAccount(liability));
            }
        }
    }
    /*
    //No Need For Code
    //Creditor liability Creditor package
    public static void form47package(Form47Creditorpackage Form47Creditorpackage, Insolvency__c insolv){
      if(Form47Creditorpackage.creditorId != NULL){
         insolv.Creditor_Id__c =Form47Creditorpackage.creditorId;
      }
      if(Form47Creditorpackage.liabilityId != NULL){
         insolv.Liability_Id__c = Form47Creditorpackage.liabilityId;
      }

    }
    */

    // Create Creditor Account from creditor information from JSON
    public static Creditor_Account__c createCreditorAccount(Liabilities liability) {
        Creditor_Account__c creditorAccount = new Creditor_Account__c();

        //creditorAccount.Name = 'unknown';
        creditorAccount.Name = UNKNOWN_RECORD_NAME;

        creditorAccount.Claim_Type__c = 'Unsecured';
        creditorAccount.Created_By_Doc_Parser__c = true;

        if (liability.creditor != null) {
            creditorAccount.Creditor_Name__c = liability.creditor;
        }
        if (liability.creditorAddress != null) {
            creditorAccount.Address_of_Creditor__c = liability.creditorAddress;
        }

        //creditor Account capture creditorId  & liabilityId
        if (liability.creditorId != null) {
            creditorAccount.Creditor_Id__c = liability.creditorId;
        }
        if (liability.liabilityId != null) {
            creditorAccount.Liability_Id__c = liability.liabilityId;
        }

        if (liability.accountNumber != null && liability.accountNumber != '') {
            //remove white spaces from Insolvency Account Name
            String formattedName = liability.accountNumber.deleteWhitespace();

            //Set default name if value is greater than 20
            if (formattedName.length() <= 20) {
                creditorAccount.Name = formattedName;
            } else {
                creditorAccount.Name = Other_RECORD_NAME;
            }

            /*
        //Set default name if value is greater than 20
        if(liability.accountNumber.length() <= 20){
            creditorAccount.Name = liability.accountNumber;
        }
        else{
            creditorAccount.Name = Other_RECORD_NAME;
        }
        */
        }

        // Unsecured Account
        if (liability.unsecuredDebt != null) {
            creditorAccount.Unsecured_Asset_Amount__c = getDecimalValue(liability.unsecuredDebt);
        }
        // Secured Account
        if (liability.securedDebt != null && getDecimalValue(liability.securedDebt) > 0) {
            creditorAccount.Secured_Asset_Amount__c = getDecimalValue(liability.securedDebt);
            creditorAccount.Claim_Type__c = 'Secured';
        }
        if (liability.preferredDebt != null && getDecimalValue(liability.preferredDebt) > 0) {
            creditorAccount.Claim_Type__c = null;
            creditorAccount.Preferred_Amount__c = getDecimalValue(liability.preferredDebt);
        }
        if (liability.ltc != null) {
            creditorAccount.Liabilities_Type_Code__c = liability.ltc;
        }
        return creditorAccount;
    }

    // Create Insolvencies from JSON response debtors
    public static Insolvency__c createDebtors(List<Debtors> debtors, Insolvency__c insolv) {
        // Debtor1
        if (!debtors.isEmpty()) {
            Debtors debtor = debtors.get(0);
            if (debtor.firstName != null) {
                insolv.Debtor_1_First_Name__c = debtor.firstName;
            }
            if (debtor.middleName != null) {
                insolv.Debtor_1_Middle_Name__c = debtor.middleName;
            }
            if (debtor.lastName != null) {
                insolv.Debtor_1_Last_Name__c = debtor.lastName;
            }
            if (debtor.gender != null) {
                //insolv.Debtor_1_Gender__c = debtor.gender;
                insolv.Debtor_1_Gender__c = getGenderValues(debtor.gender);
            }
            if (debtor.dateOfBirth != null) {
                insolv.Debtor_1_Date_of_Birth__c = formatDate(debtor.dateOfBirth);
            }
            if (debtor.alsoKnownAs != null) {
                insolv.Debtor_1_Alias_Name__c = debtor.alsoKnownAs;
            }
            if (debtor.streetAddress != null) {
                insolv.Debtor_1_Mailing_Street__c = debtor.streetAddress;
            }
            if (debtor.city != null) {
                insolv.Debtor_1_Mailing_City__c = debtor.city;
            }
            if (debtor.province != null) {
                insolv.Debtor_1_Mailing_State_Province__c = getProvince(debtor.province);
            }
            if (debtor.postalCode != null) {
                insolv.Debtor_1_Mailing_Postal_Code__c = debtor.postalCode;
            }
            if (debtor.maritalStatus != null) {
                insolv.Debtor_1_Marital_Status__c = getMaritalStaus(debtor.maritalStatus);
            }
            if (debtor.nameOfPresentEmployer != null) {
                insolv.Debtor_1_Employer_Name__c = debtor.nameOfPresentEmployer;
            }
            if (debtor.occupation != null) {
                insolv.Debtor_1_Occupation__c = debtor.occupation;
            }
        } // Debtor1 End

        // Debtor2
        if (debtors != null && debtors.size() > 1) {
            Debtors debtor = debtors.get(1);
            if (debtor.firstName != null) {
                insolv.Debtor_2_First_Name__c = debtor.firstName;
            }
            if (debtor.middleName != null) {
                insolv.Debtor_2_Middle_Name__c = debtor.middleName;
            }
            if (debtor.lastName != null) {
                insolv.Debtor_2_Last_Name__c = debtor.lastName;
            }
            if (debtor.gender != null) {
                //insolv.Debtor_2_Gender__c = debtor.gender;
                insolv.Debtor_2_Gender__c = getGenderValues(debtor.gender);
            }
            if (debtor.dateOfBirth != null) {
                insolv.Debtor_2_Date_of_Birth__c = formatDate(debtor.dateOfBirth);
            }
            if (debtor.alsoKnownAs != null) {
                insolv.Debtor_2_Alias_Name__c = debtor.alsoKnownAs;
            }
            if (debtor.streetAddress != null) {
                insolv.Debtor_2_Mailing_Street__c = debtor.streetAddress;
            }
            if (debtor.city != null) {
                insolv.Debtor_2_Mailing_City__c = debtor.city;
            }
            if (debtor.province != null) {
                insolv.Debtor_2_Mailing_State_Province__c = getProvince(debtor.province);
            }
            if (debtor.postalCode != null) {
                insolv.Debtor_2_Mailing_Postal_Code__c = debtor.postalCode;
            }
            if (debtor.maritalStatus != null) {
                insolv.Debtor_2_Marital_Status__c = getMaritalStaus(debtor.maritalStatus);
            }
            if (debtor.nameOfPresentEmployer != null) {
                insolv.Debtor_2_Employer_Name__c = debtor.nameOfPresentEmployer;
            }
            if (debtor.occupation != null) {
                insolv.Debtor_2_Occupation__c = debtor.occupation;
            }
        } // Debtor 2 END
        return insolv;
    }

    // Court Province value mapping with JSON values
    public static String getProvince(String province) {
        province = province.toUpperCase();
        if (courtProvinceMap.containsKey(province)) {
            return courtProvinceMap.get(province);
        } else {
            return null;
        }
    }

    // Insolvency Account Marital status value mapping with JSON values
    public static String getMaritalStaus(String maritalStatus) {
        /*
      Map<String, String> maritalStatusMap = new Map<String, String>{
            'COMMON-LAW' => 'Common law',
            'CONJOINT DE FAIT' => 'Common law',
            'SINGLE' => 'Single',
            'MARRIED' => 'Married',
            'COMMON LAW' => 'Common law',
            'SEPARATED' => 'Separated',
            'DIVORCED'=> 'Divorced'};
      */

        maritalStatus = maritalStatus.toUpperCase();
        if (maritalStatusMap.containsKey(maritalStatus)) {
            return maritalStatusMap.get(maritalStatus);
        } else {
            return null;
        }
    }

    // Insolvency Account Gender value mapping with JSON values
    public static String getGenderValues(String genderValue) {
        genderValue = genderValue.toUpperCase();
        if (genderValueMap.containsKey(genderValue)) {
            return genderValueMap.get(genderValue);
        } else {
            return null;
        }
    }

    // Insolvency Account Yes/No value mapping with JSON values
    public static String getYesNoValues(String yesNoValue) {
        yesNoValue = yesNoValue.toUpperCase();
        if (yesNoValueMap.containsKey(yesNoValue)) {
            return yesNoValueMap.get(yesNoValue);
        } else {
            return '';
        }
    }

    //Insolvency Payment Frequency mapping with JSON values
    public static String getPaymentFrequencyValues(String paymentFrequencyValue) {
        paymentFrequencyValue = paymentFrequencyValue.toUpperCase();
        if (paymentFrequencyValueMap.containsKey(paymentFrequencyValue)) {
            return paymentFrequencyValueMap.get(paymentFrequencyValue);
        } else {
            return paymentFrequencyValue;
        }
    }

    // Convert string to deciamal value which is used in JSON response handler
    public static Double getDecimalValue(String decimalString) {
        // Remove uncessary spaces from  number recieved
        decimalString = decimalString.replaceAll(' ', '');
        decimalString = decimalString.replaceAll(',', '');

        return Decimal.valueOf(decimalString);
    }

    // Method sum ups all the amounts and returns total value
    public static Double getSumOfAmounts(String[] amounts) {
        Decimal finalVal = 0.0;
        for (String amount : amounts) {
            try {
                finalVal = finalVal + getDecimalValue(amount);
            } catch (Exception ex) {
                system.debug('Error in getSumOfAmounts ' + ex.getMessage() + ', and  value:' + amount);
            }
        }
        return finalVal;
    }

    // Format date from 11/03/2020 to Salesforce Date type
    public static Date formatDate(String dateString) {
        String[] dt = dateString.split('/'); // ex: 11/03/2020
        date myDate = date.newInstance(Integer.valueOf(dt[2]), Integer.valueOf(dt[1]), Integer.valueOf(dt[0])); // format to yyyy mm dd
        return myDate;
    }

    //update default values on Insolvency
    public static Insolvency__c populateInsolvency(Insolvency__c insolv, Case caseRecord) {
        insolv.Insolvency_Status__c = 'Staging';
        insolv.Insolvency_Received_Date__c = (caseRecord.createdDate).date();

        return insolv;
    }

    //update default values on InsolvencyAccount
    public static List<Insolvency_Account__c> populateInsolvencyAccount(List<Insolvency_Account__c> listAccount) {
        for (Insolvency_Account__c insolvAcc : listAccount) {
            insolvAcc.Insolvency_Status__c = 'New';
        }

        return listAccount;
    }

    /**
     * @description : Method to check string value and return '' if not null
     * @author adesh.ikhar@canaccede.com | 09-02-2024
     * @param value
     * @return String
     **/
    public static String checkAndGetStringValue(String value) {
        if (String.isNotBlank(value)) {
            return value;
        }
        return '';
    }

    // Note: Do not change any of the wrapper calss variable names, because it should match with JSON attirbute names for parsing
    public class ResponseParser {
        public String CourtNo; // Debtor_1_Court_Number
        public String[] EstateNo; // Name, Debtor_2_Estate_Number__c
        public String CourtDivision; //Court_Division_Number
        public String CourtDistrict; // Court_District_Name
        public String CourtProvince; // Court_Province
        public Form01Dot1Parts Form01Dot1Parts;
        public Form47Parts Form47Parts;
        public Form48Parts Form48Parts;
        public Form49Parts Form49Parts;
        public Form65Parts Form65Parts;
        public Form65BisParts form65BisParts;
        public Form79Parts Form79Parts;
        public Form79BisParts form79BisParts;
        public Form69Parts Form69Parts;
    }

    public class Form01Dot1Parts {
        public String trusteeCorporateName;
        public String trusteeAddress;
    }

    public class Form47Parts {
        public String paymentAmount;
        public String paymentFrequency;
        public String numberOfPayments;
        public String notice1;
        public String notice4; // TODO check if these attributes were present in JSON or not
        public String notice6;
    }

    public class Form48Parts {
        public String notice4;
        public String notice5;
    }

    public class Assets {
        public String totalEstimatedDollarValue;
        public String totalSecuredAmountOrLiens;
        public String totalEstimatedNetRealizableDollarValue;
        Type[] items;
    }

    public class Type {
        public String type;
        public String description;
        public String estimatedDollarValue;
        public String exemptPropertyYes;
        public String exemptPropertyNo;
        public String securedAmountOrLiens;
        public String estimatedNetRealizableDollarValue;
    }

    public class Liability {
        public String totalUnsecuredLiabilities;
        public String totalSecuredLiabilities;
        public String totalPreferredLiabilities;
        public String totalLiabilities;
        List<Liabilities> items;
    }

    public class Liabilities {
        public String creditor;
        public String creditorAddress;
        public String accountNumber;
        public String unsecuredDebt;
        public String securedDebt;
        public String preferredDebt;
        public String ltc;
        public String creditorId;
        public String liabilityId;
    }

    public class Debtors {
        public String firstName;
        public String middleName;
        public String lastName;
        public String alsoKnownAs;
        public String gender;
        public String dateOfBirth;
        public String streetAddress;
        public String city;
        public String province;
        public String postalCode;
        public String maritalStatus;
        public String nameOfPresentEmployer;
        public String occupation;
        // form79bisParts properties
        public String numberOfPersonsInHousehold;
        public String numberOfPersonsSeventeenOrLess;
        public String everMadeProposal;
        public String everBeenBankruptBefore;
        public String spouseFirstName;
        public String spouseMiddleName;
        public String spouseLastName;
        public String employmentStatus;
        public String fromWhenEmployed;
        public String toWhenEmployed;
        public String adviceReceived;
        public List<MaritalStatusEvents> maritalStatusEvents;
        public List<AdvisorInformation> advisorInformation;
    }

    // form79bisParts properties
    public class MaritalStatusEvents implements Comparable {
        public String maritalStatus;
        public String whenMaritalStatusChanged;

        // Comparator to sort JSON by whenMaritalStatusChanged key in descending order
        public Integer compareTo(Object compareTo) {
            MaritalStatusEvents compareToEvent = (MaritalStatusEvents) compareTo;
            if (Date.valueOf(this.whenMaritalStatusChanged + '-01') == Date.valueOf(compareToEvent.whenMaritalStatusChanged + '-01')) {
                return 0;
            }
            if (Date.valueOf(this.whenMaritalStatusChanged + '-01') < Date.valueOf(compareToEvent.whenMaritalStatusChanged + '-01')) {
                return 1;
            }
            return -1;
        }
    }

    // form79bisParts properties
    public class AdvisorInformation {
        public String firstName;
        public String middleName;
        public String lastName;
        public String org;
        public String streetAddress;
        public String city;
        public String province;
        public String postalCode;
        public String amountPaid;
        public String amountCommitted;
    }

    public class Form49Parts {
        public string insolvencyType;
        public String insolvencyDate;
        //public Date insolvencyAccDate;
    }

    public class Form69Parts {
        public string insolvencyType;
        public String insolvencyDate;
        //public Date insolvencyAccDate;
    }

    public class Form65Parts {
        public MonthlyIncome monthlyIncome;
        public MonthlyNonDiscretionaryExpenses monthlyNonDiscretionaryExpenses;
        public MonthlyDiscretionaryExpenses monthlyDiscretionaryExpenses;
    }

    public class Form65BisParts {
        public MonthlyIncome monthlyIncome;
        public NewMonthlyNonDiscretionaryExpenses monthlyNonDiscretionaryExpenses;
        public MonthlyDiscretionaryExpenses monthlyDiscretionaryExpenses;
        public FamilyMembers agreedToPay;
        public FamilyMembers repurchaseAssets;
        public FamilyMembers residualAmount;
        public FamilyMembers requiredMonthlyAmount;
        public FamilyMembers requiredAmountDifference;
    }

    public class MonthlyIncome {
        public FamilyMembers netEmploymentIncome;
        public FamilyMembers netPensionAnnuities;
        public FamilyMembers netChildSupport;
        public FamilyMembers netSpousalSupport;
        public FamilyMembers netEmploymentInsuranceBenefits;
        public FamilyMembers netSocialAssistance;
        public FamilyMembers childTaxBenefit;
        public FamilyMembers otherNetIncome;
        public FamilyMembers totalMonthlyIncome;
        public String[] headings;
        public String totalMonthlyIncomeOfTheFamilyUnit;
        public String[] grossSelfEmploymentIncome;
        public FamilyMembers netSelfEmploymentIncome;
        // New property for Form65BisParts
        public FamilyMembers netOtherInsuranceBenefits;
        public FamilyMembers netGovernmentBenefits;
        public FamilyMembers netOtherBenefits;
    }

    public class FamilyMembers {
        public String[] Debtor;
        public String[] Spouse;
        public String[] Others;
        // We don't map this to any field
        // public String Total;
        public sObject MontlhyIncomeIgnore; // ignore this attribute we do not use any where
    }

    public class MonthlyNonDiscretionaryExpenses {
        public FamilyMembers childSupportPayments;
        public FamilyMembers spousalSupportPayments;
        public FamilyMembers childCare;
        public FamilyMembers medicalConditionExpenses;
        public FamilyMembers finesPenaltiesImposedByTheCourt;
        public FamilyMembers expensesAsAConditionOfEmployment;
        public FamilyMembers debtsWhereStayHasBeenLifted;
        public FamilyMembers otherExpenses;
        public FamilyMembers totalMonthlyNonDiscretionaryExpenses;
        public String[] headings;
        public String totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit;
        public String[] availableMonthlyIncomeOfTheDebtor;
        public String availableMonthlyIncomeOfTheFamilyUnit;
        public String[] debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit;
    }

    // New structure for Form65BisParts
    public class NewMonthlyNonDiscretionaryExpenses {
        public FamilyMembers childSupportPayments;
        public FamilyMembers spousalSupportPayments;
        public FamilyMembers childCare;
        public FamilyMembers medicalConditionExpenses;
        public FamilyMembers finesPenaltiesImposedByTheCourt;
        public FamilyMembers expensesAsAConditionOfEmployment;
        public FamilyMembers debtsWhereStayHasBeenLifted;
        public FamilyMembers otherExpenses;
        public FamilyMembers totalMonthlyNonDiscretionaryExpenses;
        public String[] headings;
        public String totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit;
        public FamilyMembers availableMonthlyIncomeOfTheDebtor;
        public String availableMonthlyIncomeOfTheFamilyUnit;
        public FamilyMembers debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit;
    }

    public class MonthlyDiscretionaryExpenses {
        public HousingExpenses housingExpenses;
        public personalExpenses personalExpenses;
        public NonRecoverableMedicalExpenses nonRecoverableMedicalExpenses;
        public livingExpenses livingExpenses;
        public transportationExpenses transportationExpenses;
        public insuranceExpenses insuranceExpenses;
        public payments payments;
        public payments paymentsExpenses;
        public String totalFamilyUnitMonthlyDiscretionaryExpenses;
        public String familyUnitMonthlySurplusOrDeficit;
    }

    public class HousingExpenses {
        public String[] rentMortgageHypothec;
        public String[] propertyTaxesCondoFees;
        public String[] heatingGasOil;
        public String[] telephone;
        public String[] cable;
        public String[] hydro;
        public String[] water;
        public String[] furniture;
        public String[] other;
        // New property for Form65BisParts
        public String[] internet;
    }

    public class PersonalExpenses {
        public String[] smoking;
        public String[] alcohol;
        public String[] diningLunchesRestaurants;
        public String[] entertainmentSports;
        public String[] giftsCharitableDonations;
        public String[] allowances;
        public String[] other;
    }

    public class NonRecoverableMedicalExpenses {
        public String[] prescriptions;
        public String[] dental;
        public String[] other;
    }

    public class LivingExpenses {
        public String[] foodGrocery;
        public String[] laundryDryCleaning;
        public String[] groomingToiletries;
        public String[] clothing;
        public String[] other;
    }

    public class TransportationExpenses {
        public String[] carLeasePayments;
        public String[] repairMaintenanceGas;
        public String[] publicTransportation;
        public String[] other;
    }

    public class InsuranceExpenses {
        public String[] vehicle;
        public String[] house;
        public String[] furnitureContents;
        public String[] lifeInsurance;
        public String[] other;
    }

    public class Payments {
        public String[] paymentsToTheProposal;
        public String[] toSecuredCreditor;
        public String[] other;
        public String[] otherThanMortgageAndVehicle;
        // New property for Form65BisParts
        public String[] otherFinancialAdvisor;
        public String[] otherSecuredCreditor;
    }
    /*
    // Creditor Id and Liability Id form Creditor Package
    public class Form47Creditorpackage{
    public String [] creditorId;
    public String [] liabilityId;
    }
    */

    public class Form79Parts {
        public List<Debtors> debtors;
        public String numberOfPersonsInHousehold;
        public String numberOfPersonsSeventeenOrLess;
        public String totalSecuredClaims;
        public String totalUnsecuredClaims;
        public String totalAssets;
        public Assets assets;
        public Liability liabilities;

        //ToDo - add actual business logic
        public String everMadeProposal;
        public String everBeenBankruptBefore;
    }

    public class Form79BisParts {
        public List<Debtors> debtors;
        public String numberOfPersonsInHousehold;
        public String numberOfPersonsSeventeenOrLess;
        public String totalSecuredClaims;
        public String totalUnsecuredClaims;
        public String totalAssets;
        public Assets assets;
        public Liability liabilities;
    }
}