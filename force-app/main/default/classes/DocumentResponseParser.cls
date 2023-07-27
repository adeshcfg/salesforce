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
   public static Set<String> scotiaBank = new Set<String>{'BANK OF NOVA SCOTIA', 'SCOTIABANK', 'SCOTIA BANK','SCOTIA MORTGAGE CORPORATION'};
   public static Set<String> sdaBank = new Set<String>{'SDA', 'SCOTIA DEALER ADVANTAGE'};
   public static Set<String> splBank = new Set<String>{'5307', '628181'};
   public static Set<String> canaccedeBank = new Set<String>{'CANACCEDE'};
   public static Set<String> fidemBank = new Set<String>{'AFFIRM', 'FIDEM'};
   public static Set<String> fairstone = new Set<String>{'FAIRSTONE','WALMART','DUO'};
   public static Set<String> fairstoneAcc = new Set<String>{'5434','5435'};
   public static Set<String> goEasy = new Set<String>{'EASYFINANCIAL SERVICES', 'EASY FINANCIAL SERVICES', 'EASYFINANCIAL', 'EASY FINANCIAL', 'EASYHOME', 'EASY HOME', 'GOEASY', 'GO EASY'};
   //public static Set<String> fairstoneExcludeAcc = new Set<String>{'676'};
   //public static Set<String> fairstoneExcludeAccData = new Set<String>{'6030'};
      
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
                    'DIVORCED'=> 'Divorced'};
                    
   //Gender Value Map
   public static Map<String, String> genderValueMap = new Map<String, String>{
                    'MALE' => 'Male',
                    'FEMALE' => 'Female',
                    'OTHER' => 'Other',
                    'HOMME' => 'Male',
                    'FEMME' => 'Female',
                    'F' => 'Female',
                    'M' => 'Male'};
   
   //Yes/No Value Map Form79
   public static Map<String, String> yesNoValueMap = new Map<String, String>{
                    'OUI' => 'Yes',
                    'NON' => 'No',
                    'YES' => 'Yes',
                    'NO' => 'No'};

   //Payment Frequency Map Form47
   public static Map<String, String> paymentFrequencyValueMap = new Map<String, String>{
                    'MOIS' => 'Monthly',
                    'MENSUELS' => 'Monthly'
                    };
   
   // Insolvency Account Record Types   
   static Map<String, Id> insolvencyRecordTypeMap = new Map<String, Id>();
   
   //Constant Values
   public static final string UNKNOWN_RECORD_NAME = 'unknown';
   public static final string Other_RECORD_NAME = 'other';
   
   public static Date InsolvencyAccDate;
   // Fetch Insolvency Account record types
   static{
      for(RecordType rtype: [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Insolvency_Account__c']){
         insolvencyRecordTypeMap.put(rtype.DeveloperName, rtype.Id);
      }
   }

   // Method takes Parser Handler Ids and parse JSON reponse                                           
   public static void parseResponse(Id recordId) {
      Parsed_Response_Holder__c parsedResponse = [SELECT Id, Parsed_Response_Formatted__c, Status__c, Error_Details__c, assignment__c FROM Parsed_Response_Holder__c WHERE Id =: recordId ];
      // Production Issue - Converted variable to list
      List<Case> caseRecordList = [select id, Document_ID__c, status, parentID, SuppliedEmail, Creditor_s_Pack_Language__c, createdDate from case where id =: parsedResponse.assignment__c];
      // Production Issue - Added List empty check
      if(caseRecordList.isEmpty()) {
         return;
      }
      Case caseRecord = caseRecordList[0];
      List<EmailMessage> emailMsg = [select id, FromAddress from EmailMessage where RelatedToId =: caseRecord.ID limit 1];
      List<Attachment> attach = new List<Attachment>();
    
      if(emailMsg.size() > 0){
          attach = [select id, name, body, description, createdDate from Attachment where ParentID = :emailMsg[0].Id and description = 'Creditors Package' and name like '%.pdf' order by lastModifiedDate asc];
          if(attach.size() == 0){
              attach = [select id, name, body, description, createdDate from Attachment where ParentID = :emailMsg[0].Id and name like '%.pdf' order by lastModifiedDate asc];
          }
      }
      else{
          attach = [select id, name, body, description from Attachment where ParentID = :caseRecord.Id and description = 'Creditors Package' and name like '%.pdf' order by lastModifiedDate asc];
          if(attach.size() == 0){
              attach = [select id, name, body, description from Attachment where ParentID = :caseRecord.Id and name like '%.pdf' order by lastModifiedDate asc];
          }
      }
      if(parsedResponse.Parsed_Response_Formatted__c != NULL && parsedResponse.Status__c == 'Pending'){
         String parseJson = parsedResponse.Parsed_Response_Formatted__c;
         //parseJson = DocumentParser.formatJson(parseJson);
       try{
            ResponseParser res = (ResponseParser)JSON.deserializeStrict( parseJson, ResponseParser.class);
            Insolvency__c insolv = new Insolvency__c();
            List<Insolvency_Account__c> insolvAccounts = new List<Insolvency_Account__c>();
            List<Creditor_Account__c> creditorAccounts = new List<Creditor_Account__c>();
            
            // Package level
            insolv.Debtor_1_Court_Number__c = res.CourtNo;
            
            insolv.Allow_Insolvency_Date_In_Past__c = TRUE;
            insolv.Created_By_Doc_Parser__c = TRUE;
            
            //insolv.Name= 'unknown';
            insolv.Name= UNKNOWN_RECORD_NAME;
            
            //Do not set Default Insolvency type
            //insolv.Insolvency_Type__c = 'Division 1 Proposal';
            
            if(res.EstateNo != NULL){
               insolv.Name = res.EstateNo[0];
                  if(res.EstateNo.size() > 1){
                     insolv.Debtor_2_Estate_Number__c = res.EstateNo[1];
                  }
            }
            
            if(res.CourtDivision != NULL){
               insolv.Court_Division_Number__c = res.CourtDivision;
            }
            if(res.CourtDistrict != NULL){
               //insolv.Court_District_Name__c = res.CourtDistrict;
               insolv.Court_District_Name__c = getProvince(res.CourtDistrict);
            }
            if(res.CourtProvince != NULL){
               insolv.Court_Province__c = getProvince(res.CourtProvince);
            }
            //Form01Dot1Parts
            if(res.Form01Dot1Parts != NULL){
               Form01Dot1Parts Form01Dot1Parts  = res.Form01Dot1Parts;
               parseForm01Dot1Parts(Form01Dot1Parts, insolv);
            }
            //Form01Dot1Parts END

            // Form47Parts
            if(res.Form47Parts != NULL){
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
            if(res.Form48Parts != NULL){
               parseForm48Parts(res.Form48Parts, insolv);
            }

            // Form49Parts
            if(res.Form49Parts != NULL){
               parseForm49Parts(res.Form49Parts, insolv);
            }
            
            // Form69Parts
            if(res.Form69Parts != NULL){
               parseForm69Parts(res.Form69Parts, insolv);
            }

            // Form65Parts
            if(res.Form65Parts != NULL){
               parseForm65Parts(res.Form65Parts, insolv);
            }

            // Form79Parts
            if(res.Form79Parts != NULL){
               parseForm79Parts(res.Form79Parts, insolv, insolvAccounts, creditorAccounts);
            } // Form79Parts ENDS
               insolv = populateInsolvency(insolv, caseRecord);
               insert insolv;
               
               insolvAccounts = populateInsolvencyAccount(insolvAccounts);

               for(Insolvency_Account__c insolvAccount: insolvAccounts){
                  insolvAccount.Insolvency__c = insolv.Id;
               }
               for( Creditor_Account__c creditorAccount: creditorAccounts){
                  creditorAccount.Insolvency__c = insolv.Id;
               }
               
               if(!insolvAccounts.isEmpty()){
                  insert insolvAccounts;
                  //Database.insert(insolvAccounts, false);
               }
               if(!creditorAccounts.isEmpty()){
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
               for(Attachment att : attach){
                   Attachment newAttach = att.clone(false,false,false,false);
                   newAttach.parentID = insolv.id;
                   newAttach.Description = 'Creditors Package';
                   listInsolvAttach.add(newAttach);
               }
               insert listInsolvAttach;
               
               /*
               //ContentVersion Creation
               ContentVersion attachContent = new ContentVersion(); 
               attachContent.VersionData = attach[0].body;
               attachContent.Title = attach[0].name;
               attachContent.PathOnClient = attach[0].name;
               //tcicnvr.ContentLocation = 'S'; 
               insert attachContent;
                
               // First get the Content Document Id from ContentVersion Object
               Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:attachContent.Id].ContentDocumentId;
                
               //ContentDocumentLink Creation
               ContentDocumentLink attachFile = new ContentDocumentLink();
               attachFile.ContentDocumentId = conDoc;
               attachFile.LinkedEntityId = insolv.id;
               attachFile.ShareType = 'I'; 
               attachFile.Visibility = 'AllUsers';
               insert attachFile;
               */
         }
         catch(Exception ex){
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
         CaseTriggerHandler.runCaseTrigger = True;
      }// End IF
    }
    
    //process Form01 Parts
    public static void parseForm01Dot1Parts(Form01Dot1Parts form01Dot1Parts, Insolvency__c insolv){
      String trusteeCorporateName;
      String trusteeAddress;
      if(Form01Dot1Parts.trusteeCorporateName != NULL){
         trusteeCorporateName = Form01Dot1Parts.trusteeCorporateName;
      }
      if(Form01Dot1Parts.trusteeAddress != NULL){
         String [] address = Form01Dot1Parts.trusteeAddress.split(' ');
         if(address.size() > 3){
            trusteeAddress=address[address.size()-4]; //8250 Decarie Blvd. #140 Montreal QC H4P 2P5
         }
      }
      if(trusteeCorporateName != NULL && trusteeAddress != NULL){
         List<Account> trustee = [  SELECT Id FROM Account
                              WHERE RecordType.Name = 'Trustee Office'
                                    AND Parent.Name =: trusteeCorporateName  
                                    AND Name =: trusteeAddress];
         if(!trustee.isEmpty()){
            insolv.Trustee__c = trustee[0].Id;
         }
      }
    }
    
    // process Form47Parts
    public static void parseForm47Parts(Form47Parts form47Parts, Insolvency__c insolv){
    /*
      //Ticket#408 - Team will enter Payment Amount manually
      if(form47Parts.paymentAmount != NULL){
         insolv.Payment_Amount__c = Decimal.valueOf(form47Parts.paymentAmount);
      }
      */
      if(form47Parts.paymentFrequency != NULL){
         insolv.Payment_Frequency__c = getPaymentFrequencyValues(form47Parts.paymentFrequency);
      }
     /*
     //Ticket#408 - Team will enter Number of Payments manually
     if(form47Parts.numberOfPayments != NULL){
         insolv.Number_of_Payments__c = Integer.valueOf(form47Parts.numberOfPayments);
      }
      */
      if(form47Parts.notice1 != NULL){
        insolv.Maint_Payments_Or_Relinquishing__c = form47Parts.notice1;
      }
      if(form47Parts.notice6 != NULL){
         insolv.Death_Clause__c = form47Parts.notice6;
         insolv.Acceleration_Clause__c = form47Parts.notice6;
       }
    }

   // process Form48Parts
   public static void parseForm48Parts(Form48Parts form48Parts, Insolvency__c insolv){
      if(form48Parts.notice4 != NULL){
         insolv.Reason_For_Individual_Becoming_Insolvent__c = form48Parts.notice4;
      }
      if(form48Parts.notice5 != NULL){
         insolv.Trustee_Comments_Notes__c = form48Parts.notice5;
      }
   }

   //parseForm49Parts
   public static void parseForm49Parts(Form49Parts form49Parts, Insolvency__c insolv){
      if(form49Parts.insolvencyDate != NULL){
         insolv.Insolvency_Date__c = formatDate(form49Parts.insolvencyDate);  // convert 11/03/2020 to Salesforce Date format
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
   public static void parseForm69Parts(Form69Parts form69Parts, Insolvency__c insolv){
      if(form69Parts.insolvencyDate != NULL){
         insolv.Insolvency_Date__c = formatDate(form69Parts.insolvencyDate);  // convert 11/03/2020 to Salesforce Date format
         InsolvencyAccDate = formatDate(form69Parts.insolvencyDate);
      }
      insolv.Insolvency_Type__c = 'Bankruptcy';
   }

   //parseForm65Parts
   public static void parseForm65Parts(Form65Parts form65Parts, Insolvency__c insolv){
      // monthlyIncome
      if (Form65Parts.monthlyIncome != NULL){
         parseMonthlyIncome(Form65Parts.monthlyIncome, insolv);
      }

      // monthlyNonDiscretionaryExpenses
      if (Form65Parts.monthlyNonDiscretionaryExpenses != NULL){
         parseMonthlyNonDiscretionaryExpenses(Form65Parts.monthlyNonDiscretionaryExpenses, insolv);
        
      } // monthlyNonDiscretionaryExpenses END

      // monthlyDiscretionaryExpenses
      if (Form65Parts.monthlyDiscretionaryExpenses != NULL){
         parseMonthlyDiscretionaryExpenses(Form65Parts.monthlyDiscretionaryExpenses, insolv);
      }
   }

   //monthlyIncome
   public static void parseMonthlyIncome(MonthlyIncome monthlyIncome, Insolvency__c insolv){

      if(monthlyIncome.totalMonthlyIncomeOfTheFamilyUnit != NULL){
         insolv.Total_Monthly_Income_Of_Family__c = getDecimalValue(monthlyIncome.totalMonthlyIncomeOfTheFamilyUnit);
      }
      if(monthlyIncome.grossSelfEmploymentIncome != NULL){
         insolv.Gross_Self_Employment_Income__c = getSumOfAmounts(monthlyIncome.grossSelfEmploymentIncome);
      }

      // childTaxBenefit
      if(monthlyIncome.childTaxBenefit != NULL){
         parseChildTaxBenefit(monthlyIncome.childTaxBenefit, insolv);
      }  // childTaxBenefit END
     
      // netChildSupport
      if(monthlyIncome.netChildSupport != NULL){
         parseNetChildSupport(monthlyIncome.netChildSupport, insolv);
      } // netChildSupport END

      // netPensionAnnuities
      if(monthlyIncome.netPensionAnnuities != NULL){
         parseNetPensionAnnuities(monthlyIncome.netPensionAnnuities, insolv);
      } // netChildSupport END

      // netSelfEmploymentIncome
      if(monthlyIncome.netSelfEmploymentIncome != NULL){
         parseNetSelfEmploymentIncome(monthlyIncome.netSelfEmploymentIncome, insolv);
      } // netSelfEmploymentIncome END

      // netSocialAssistance
      if(monthlyIncome.netSocialAssistance != NULL){
         parseNetSocialAssistance(monthlyIncome.netSocialAssistance, insolv);
      } // netSocialAssistance END

      // netSpousalSupport
      if(monthlyIncome.netSpousalSupport != NULL){
         parseNetSpousalSupport(monthlyIncome.netSpousalSupport, insolv);
      } // netSpousalSupport END

      // newEmploymentIncome
      if(monthlyIncome.netEmploymentIncome != NULL){
         parseNetEmploymentIncome(monthlyIncome.netEmploymentIncome, insolv);
      } // newEmploymentIncome END

      // netEmploymentInsuranceBenefits
      if(monthlyIncome.netEmploymentInsuranceBenefits != NULL){
         parseNetEmploymentInsuranceBenefits(monthlyIncome.netEmploymentInsuranceBenefits, insolv);
      } // netEmploymentInsuranceBenefits END

      // otherNetIncome
      if(monthlyIncome.otherNetIncome != NULL){
         parseOtherNetIncome(monthlyIncome.otherNetIncome, insolv);
      } // otherNetIncome END

      // totalMonthlyIncome
      if(monthlyIncome.totalMonthlyIncome != NULL){
         parseTotalMonthlyIncome(monthlyIncome.totalMonthlyIncome, insolv);
      } // totalMonthlyIncome END
   }

   // parseMonthlyNonDiscretionaryExpenses
   public static void parseMonthlyNonDiscretionaryExpenses(MonthlyNonDiscretionaryExpenses monthlyNonDiscretionaryExpenses, Insolvency__c insolv){

      if(monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit != NULL){
         insolv.Total_Non_Discretionary_Expenses_Family__c = getDecimalValue(monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit);
      }
      
      if(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor != NULL){
         insolv.Available_Monthly_Income_Of_Debtor__c = getSumOfAmounts(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheDebtor);
      }
      
      if(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheFamilyUnit != NULL){
        insolv.Available_Monthly_Income_Of_Family__c = getDecimalValue(monthlyNonDiscretionaryExpenses.availableMonthlyIncomeOfTheFamilyUnit);
      }
      
      if(monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit != NULL){
         insolv.Debtor_Portion_Of_Monthly_Income__c = getSumOfAmounts(monthlyNonDiscretionaryExpenses.debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit);
      }

      // childCare
      if(monthlyNonDiscretionaryExpenses.childCare != NULL){
         parsechildCare(monthlyNonDiscretionaryExpenses.childCare, insolv);
      }
      // childCare END

      // childSupportPayments
      if(monthlyNonDiscretionaryExpenses.childSupportPayments != NULL){
         parseChildSupportPayments(monthlyNonDiscretionaryExpenses.childSupportPayments, insolv);
      }
      // childSupportPayments END

      // debtsWhereStayHasBeenLifted
      if(monthlyNonDiscretionaryExpenses.debtsWhereStayHasBeenLifted != NULL){
         parseDebtsWhereStayHasBeenLifted(monthlyNonDiscretionaryExpenses.debtsWhereStayHasBeenLifted, insolv);
      }
      // debtsWhereStayHasBeenLifted END

      // expensesAsAConditionOfEmployment
      if(monthlyNonDiscretionaryExpenses.expensesAsAConditionOfEmployment != NULL){
         parseExpensesAsAConditionOfEmployment(monthlyNonDiscretionaryExpenses.expensesAsAConditionOfEmployment, insolv);
      }
      // expensesAsAConditionOfEmployment END

      // finesPenaltiesImposedByTheCourt
      if(monthlyNonDiscretionaryExpenses.finesPenaltiesImposedByTheCourt != NULL){
         parseFinesPenaltiesImposedByTheCourt(monthlyNonDiscretionaryExpenses.finesPenaltiesImposedByTheCourt, insolv);
      }
      // finesPenaltiesImposedByTheCourt END

      // medicalConditionExpenses
      if(monthlyNonDiscretionaryExpenses.medicalConditionExpenses != NULL){
         parseMedicalConditionExpenses(monthlyNonDiscretionaryExpenses.medicalConditionExpenses, insolv);
      }
      // medicalConditionExpenses END

      // otherExpenses
      if(monthlyNonDiscretionaryExpenses.otherExpenses != NULL){
         parseOtherExpenses(monthlyNonDiscretionaryExpenses.otherExpenses, insolv);
      }
      // otherExpenses END

      // spousalSupportPayments
      if(monthlyNonDiscretionaryExpenses.spousalSupportPayments != NULL){
         parseSpousalSupportPayments(monthlyNonDiscretionaryExpenses.spousalSupportPayments, insolv);
      }
      // spousalSupportPayments END

      // totalMonthlyNonDiscretionaryExpenses
      if(monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpenses != NULL){
         parseTotalMonthlyNonDiscretionaryExpenses(monthlyNonDiscretionaryExpenses.totalMonthlyNonDiscretionaryExpenses, insolv);
      }
      // totalMonthlyNonDiscretionaryExpenses END
   }

   // monthlyDiscretionaryExpenses
   public static void parseMonthlyDiscretionaryExpenses(MonthlyDiscretionaryExpenses monthlyDiscretionaryExpenses, Insolvency__c insolv){

         if(monthlyDiscretionaryExpenses.totalFamilyUnitMonthlyDiscretionaryExpenses != NULL){
            insolv.Monthly_Discretionary_Expenses_Of_Family__c = getDecimalValue(monthlyDiscretionaryExpenses.totalFamilyUnitMonthlyDiscretionaryExpenses);
         }
         
         if(monthlyDiscretionaryExpenses.familyUnitMonthlySurplusOrDeficit != NULL){
            insolv.Monthly_Surplus_Deficit_Of_Family__c = getDecimalValue(monthlyDiscretionaryExpenses.familyUnitMonthlySurplusOrDeficit);
         }

         // housingExpenses
         if(monthlyDiscretionaryExpenses.housingExpenses != NULL){
            parseHousingExpenses(monthlyDiscretionaryExpenses.housingExpenses, insolv);
         }    
         
         // insuranceExpenses
         if(monthlyDiscretionaryExpenses.insuranceExpenses != NULL){
            parseInsuranceExpenses(monthlyDiscretionaryExpenses.insuranceExpenses, insolv);
         } // insuranceExpenses END

         // livingExpenses
         if(monthlyDiscretionaryExpenses.livingExpenses != NULL){
            parseLivingExpenses(monthlyDiscretionaryExpenses.livingExpenses, insolv);
         }// livingExpenses END

         // nonRecoverableMedicalExpenses
         if(monthlyDiscretionaryExpenses.nonRecoverableMedicalExpenses != NULL){
            parseNonRecoverableMedicalExpenses(monthlyDiscretionaryExpenses.nonRecoverableMedicalExpenses, insolv);
         } // nonRecoverableMedicalExpenses END

         // payments
         if(monthlyDiscretionaryExpenses.payments != NULL){
            parsePayments(monthlyDiscretionaryExpenses.payments, insolv);            
         } // payments END

         // personalExpenses
         if(monthlyDiscretionaryExpenses.personalExpenses != NULL){
            parsePersonalExpenses(monthlyDiscretionaryExpenses.personalExpenses, insolv);
         } // personalExpenses END

         // transportationExpenses
         if(monthlyDiscretionaryExpenses.transportationExpenses != NULL){
            parseTransportationExpenses(monthlyDiscretionaryExpenses.transportationExpenses, insolv);
         }  // transportationExpenses END
   }

   // Form79Parts
   public static void parseForm79Parts(Form79Parts form79Parts, Insolvency__c insolv, List<Insolvency_Account__c> insolvAccounts,  List<Creditor_Account__c> creditorAccounts){
    if(form79Parts.everMadeProposal != NULL){
         insolv.Ever_Made_Proposal__c = getYesNoValues(form79Parts.everMadeProposal);
      }
       
       if(form79Parts.everBeenBankruptBefore != NULL){
         insolv.Ever_been_Bankrupt_Before__c = getYesNoValues(form79Parts.everBeenBankruptBefore);
      }
       
       if(form79Parts.numberOfPersonsInHousehold != NULL){
         insolv.Number_Of_Persons_In_Household__c = getDecimalValue(form79Parts.numberOfPersonsInHousehold);
      }
      
      if(form79Parts.numberOfPersonsSeventeenOrLess != NULL){
         insolv.Number_Of_Persons_In_Household_Below_17__c = getDecimalValue(form79Parts.numberOfPersonsSeventeenOrLess);
      }
      
      if(form79Parts.totalSecuredClaims != NULL){
         insolv.Total_Secured_Claims__c = getDecimalValue(form79Parts.totalSecuredClaims);
      }
      
      if(form79Parts.totalUnsecuredClaims != NULL){
         insolv.Total_Unsecured_Claims__c = getDecimalValue(form79Parts.totalUnsecuredClaims);
      }
      
      if(form79Parts.totalAssets != NULL){
         insolv.Total_Assets__c = getDecimalValue(form79Parts.totalAssets);
      }

      // Form79Parts:Assets
      if(form79Parts.assets != NULL){
         Assets assets = form79Parts.assets;
         
         if(assets.totalEstimatedDollarValue != NULL){
            insolv.Total_Estimated_Dollar_Value__c = getDecimalValue(assets.totalEstimatedDollarValue);
         }
         
         if(assets.totalSecuredAmountOrLiens != NULL){
            insolv.Total_Secured_Amount_Or_Liens__c = getDecimalValue(assets.totalSecuredAmountOrLiens);
         }
         
         if(assets.totalEstimatedNetRealizableDollarValue != NULL){
            insolv.Total_Estimated_Realizable_Value__c = getDecimalValue(assets.totalEstimatedNetRealizableDollarValue);
         }
      } // Form79Parts:Assets ENDS

      // Form79Parts:debtors
      if(Form79Parts.debtors != NULL){
         insolv = createDebtors(Form79Parts.debtors, insolv);
      }
      // Form79Parts:debtors ENDS

      // Form79Parts:liabilities
      if(Form79Parts.liabilities != NULL){
         Liability liability = Form79Parts.liabilities;

         if(liability.totalUnsecuredLiabilities != NULL){
            insolv.Total_Insolvency_Unsecured_Liabilities__c = getDecimalValue(liability.totalUnsecuredLiabilities);
         }
         
         if(liability.totalSecuredLiabilities != NULL){
            insolv.Total_Insolvency_Secured_Liabilities__c = getDecimalValue(liability.totalSecuredLiabilities);
         }
         
         if(liability.totalPreferredLiabilities != NULL){
            insolv.Total_Insolvency_Preferred_Liabilities__c = getDecimalValue(liability.totalPreferredLiabilities);
         }
         
         if(liability.totalLiabilities != NULL){
            insolv.Total_Liabilities__c = getDecimalValue(liability.totalLiabilities);
         }

         // if(liability.liabilities != NULL)
         
         if(liability.items != NULL){
            createInsolvencyAccounts(liability.items, insolv, insolvAccounts, creditorAccounts);
         }
      }// Form79Parts:liabilities ENDS
   }

   // childTaxBenefit
   public static void parseChildTaxBenefit(FamilyMembers childTaxBenefit, Insolvency__c insolv){
      if(childTaxBenefit.Debtor != NULL){
         insolv.Child_Tax_Benefit_Debtor__c = getSumOfAmounts(childTaxBenefit.Debtor);
      }
      // else if(childTaxBenefit.Bankrupt != NULL){
      //    insolv.Child_Tax_Benefit_Debtor__c = getDecimalValue(childTaxBenefit.Bankrupt);
      // }
      if(childTaxBenefit.Others != NULL){
         insolv.Child_Tax_Benefit_Other__c = getSumOfAmounts(childTaxBenefit.Others);
      }
      if(childTaxBenefit.Spouse != NULL){
         insolv.Child_Tax_Benefit_Spouse__c = getSumOfAmounts(childTaxBenefit.Spouse);
      }
   }

   // netChildSupport
   public static void parseNetChildSupport(FamilyMembers netChildSupport, Insolvency__c insolv){
      if(netChildSupport.Debtor != NULL){
         insolv.Monthly_Net_Child_Support_Debtor__c = getSumOfAmounts(netChildSupport.Debtor);
      }
      // else if(netChildSupport.Bankrupt != NULL){
      //    insolv.Monthly_Net_Child_Support_Debtor__c = getDecimalValue(netChildSupport.Bankrupt);
      // }
      if(netChildSupport.Others != NULL){
         insolv.Monthly_Net_Child_Support_Other__c = getSumOfAmounts(netChildSupport.Others);
      }
      if(netChildSupport.Spouse != NULL){
         insolv.Monthly_Net_Child_Support_Spouse__c = getSumOfAmounts(netChildSupport.Spouse);
      }
   }

   // parseNetPensionAnnuities
   public static void parseNetPensionAnnuities(FamilyMembers netPensionAnnuities, Insolvency__c insolv){
      if(netPensionAnnuities.Debtor != NULL){
         insolv.Monthly_Net_Pension_Annuities_Debtor__c = getSumOfAmounts(netPensionAnnuities.Debtor);
      }
      // else if(netPensionAnnuities.Bankrupt != NULL){
      //    insolv.Monthly_Net_Pension_Annuities_Debtor__c = getDecimalValue(netPensionAnnuities.Bankrupt);
      // }
      if(netPensionAnnuities.Others != NULL){
         insolv.Monthly_Net_Pension_Annuities_Other__c = getSumOfAmounts(netPensionAnnuities.Others);
      }
      if(netPensionAnnuities.Spouse != NULL){
         insolv.Monthly_Net_Pension_Annuities_Spouse__c = getSumOfAmounts(netPensionAnnuities.Spouse);
      }
   }

   // parseNetSelfEmploymentIncome
   public static void parseNetSelfEmploymentIncome(FamilyMembers netSelfEmploymentIncome, Insolvency__c insolv){
      if(netSelfEmploymentIncome.Debtor != NULL){
         insolv.Net_Self_Employment_Income_Debtor__c = getSumOfAmounts(netSelfEmploymentIncome.Debtor);
      }
      // else if(netSelfEmploymentIncome.Bankrupt != NULL){
      //    insolv.Net_Self_Employment_Income_Debtor__c = getDecimalValue(netSelfEmploymentIncome.Bankrupt);
      // }
      if(netSelfEmploymentIncome.Others != NULL){
         insolv.Net_Self_Employment_Income_Other__c = getSumOfAmounts(netSelfEmploymentIncome.Others);
      }
      if(netSelfEmploymentIncome.Spouse != NULL){
         insolv.Net_Self_Employment_Income_Spouse__c = getSumOfAmounts(netSelfEmploymentIncome.Spouse);
      }
   }

   // netSocialAssistance
   public static void parseNetSocialAssistance(FamilyMembers netSocialAssistance, Insolvency__c insolv){
      if(netSocialAssistance.Debtor != NULL){
         insolv.Monthly_Net_Social_Assistance_Debtor__c = getSumOfAmounts(netSocialAssistance.Debtor);
      }
      // else if(netSocialAssistance.Bankrupt != NULL){
      //    insolv.Monthly_Net_Social_Assistance_Debtor__c = getDecimalValue(netSocialAssistance.Bankrupt);
      // }
      if(netSocialAssistance.Others != NULL){
         insolv.Monthly_Net_Social_Assistance_Other__c = getSumOfAmounts(netSocialAssistance.Others);
      }
      if(netSocialAssistance.Spouse != NULL){
         insolv.Monthly_Net_Social_Assistance_Spouse__c = getSumOfAmounts(netSocialAssistance.Spouse);
      }
   }

   // netSpousalSupport
   public static void parseNetSpousalSupport(FamilyMembers netSpousalSupport, Insolvency__c insolv){
      if(netSpousalSupport.Debtor != NULL){
         insolv.Monthly_Net_Spoucal_Support_Debtor__c = getSumOfAmounts(netSpousalSupport.Debtor);
      }
      // else if(netSpousalSupport.Bankrupt != NULL){
      //    insolv.Monthly_Net_Spoucal_Support_Debtor__c = getDecimalValue(netSpousalSupport.Bankrupt);
      // }
      if(netSpousalSupport.Others != NULL){
         insolv.Monthly_Net_Spoucal_Support_Other__c = getSumOfAmounts(netSpousalSupport.Others);
      }
      if(netSpousalSupport.Spouse != NULL){
         insolv.Monthly_Net_Spoucal_Support_Spouse__c = getSumOfAmounts(netSpousalSupport.Spouse);
      }
   }

   // parseNetEmploymentIncome
   public static void parseNetEmploymentIncome(FamilyMembers netEmploymentIncome, Insolvency__c insolv){
      if(netEmploymentIncome.Debtor != NULL){
         insolv.Monthly_Net_Employment_Income_Debtor__c = getSumOfAmounts(netEmploymentIncome.Debtor);
      }
      // else if(netEmploymentIncome.Bankrupt != NULL){
      //    insolv.Monthly_Net_Employment_Income_Debtor__c = getDecimalValue(netEmploymentIncome.Bankrupt);
      // }
      if(netEmploymentIncome.Others != NULL){
         insolv.Monthly_Net_Employment_Income_Other__c = getSumOfAmounts(netEmploymentIncome.Others);
      }
      if(netEmploymentIncome.Spouse != NULL){
         insolv.Monthly_Net_Employment_Income_Spouse__c = getSumOfAmounts(netEmploymentIncome.Spouse);
      }
   }

   // netEmploymentInsuranceBenefits
   public static void parseNetEmploymentInsuranceBenefits(FamilyMembers netEmploymentInsuranceBenefits, Insolvency__c insolv){
      if(netEmploymentInsuranceBenefits.Debtor != NULL){
         insolv.Monthly_Net_Empl_Ins_Benefits_Debtor__c = getSumOfAmounts(netEmploymentInsuranceBenefits.Debtor);
      }
      // else if(netEmploymentInsuranceBenefits.Bankrupt != NULL){
      //    insolv.Monthly_Net_Empl_Ins_Benefits_Debtor__c = getDecimalValue(netEmploymentInsuranceBenefits.Bankrupt);
      // }
      if(netEmploymentInsuranceBenefits.Others != NULL){
         insolv.Monthly_Net_Empl_Ins_Benefits_Other__c = getSumOfAmounts(netEmploymentInsuranceBenefits.Others);
      }
      if(netEmploymentInsuranceBenefits.Spouse != NULL){
         insolv.Monthly_Net_Empl_Ins_Benefits_Spouse__c = getSumOfAmounts(netEmploymentInsuranceBenefits.Spouse);
      }
   }

   // parseOtherNetIncome
   public static void parseOtherNetIncome(FamilyMembers otherNetIncome, Insolvency__c insolv){
      if(otherNetIncome.Debtor != NULL){
         insolv.Other_Net_Income_Debtor__c = getSumOfAmounts(otherNetIncome.Debtor);
      }
      // else if(otherNetIncome.Bankrupt != NULL){
      //    insolv.Other_Net_Income_Debtor__c = getDecimalValue(otherNetIncome.Bankrupt);
      // }
      if(otherNetIncome.Others != NULL){
         insolv.Other_Net_Income_Other__c = getSumOfAmounts(otherNetIncome.Others);
      }
      if(otherNetIncome.Spouse != NULL){
         insolv.Other_Net_Income_Spouse__c = getSumOfAmounts(otherNetIncome.Spouse);
      }
   }

   // totalMonthlyIncome
   public static void parseTotalMonthlyIncome(FamilyMembers totalMonthlyIncome, Insolvency__c insolv){
      if(totalMonthlyIncome.Debtor != NULL){
         insolv.Total_Monthly_Income_Debtor__c = getSumOfAmounts(totalMonthlyIncome.Debtor);
      }
      // else if(totalMonthlyIncome.Bankrupt != NULL){
      //    insolv.Total_Monthly_Income_Debtor__c = getDecimalValue(totalMonthlyIncome.Bankrupt);
      // }
      if(totalMonthlyIncome.Others != NULL){
         insolv.Total_Monthly_Income_Other__c = getSumOfAmounts(totalMonthlyIncome.Others);
      }
      if(totalMonthlyIncome.Spouse != NULL){
         insolv.Total_Monthly_Income_Spouse__c = getSumOfAmounts(totalMonthlyIncome.Spouse);
      }
   }

   //childCare
   public static void parseChildCare(FamilyMembers childCare, Insolvency__c insolv){
      if(childCare.Debtor != NULL){
         insolv.Monthly_Child_Care_Debtor__c = getSumOfAmounts(childCare.Debtor);
      }
      // else if(childCare.Bankrupt != NULL){
      //    insolv.Monthly_Child_Care_Debtor__c = getDecimalValue(childCare.Bankrupt);
      // }
      if(childCare.Others != NULL){
         insolv.Monthly_Child_Care_Other__c = getSumOfAmounts(childCare.Others);
      }
      if(childCare.Spouse != NULL){
         insolv.Monthly_Child_Care_Spouse__c = getSumOfAmounts(childCare.Spouse);
      }
   }

   //childSupportPayments
   public static void parseChildSupportPayments(FamilyMembers childSupportPayments, Insolvency__c insolv){
      if(childSupportPayments.Debtor != NULL){
         insolv.Monthly_Child_Support_Payments_Debtor__c = getSumOfAmounts(childSupportPayments.Debtor);
      }
      // else if(childSupportPayments.Bankrupt != NULL){
      //    insolv.Monthly_Child_Support_Payments_Debtor__c = getDecimalValue(childSupportPayments.Bankrupt);
      // }
      if(childSupportPayments.Others != NULL){
         insolv.Monthly_Child_Support_Payments_Other__c = getSumOfAmounts(childSupportPayments.Others);
      }
      if(childSupportPayments.Spouse != NULL){
         insolv.Monthly_Child_Support_Payments_Spouse__c = getSumOfAmounts(childSupportPayments.Spouse);
      }
   }

   //debtsWhereStayHasBeenLifted
   public static void parseDebtsWhereStayHasBeenLifted(FamilyMembers debtsWhereStayHasBeenLifted, Insolvency__c insolv){
      if(debtsWhereStayHasBeenLifted.Debtor != NULL){
         insolv.Monthly_Debts_Stay_Lifted_Debtor__c = getSumOfAmounts(debtsWhereStayHasBeenLifted.Debtor);
      }
      // else if(debtsWhereStayHasBeenLifted.Bankrupt != NULL){
      //    insolv.Monthly_Debts_Stay_Lifted_Debtor__c = getDecimalValue(debtsWhereStayHasBeenLifted.Bankrupt);
      // }
      if(debtsWhereStayHasBeenLifted.Others != NULL){
         insolv.Monthly_Debts_Stay_Lifted_Other__c = getSumOfAmounts(debtsWhereStayHasBeenLifted.Others);
      }
      if(debtsWhereStayHasBeenLifted.Spouse != NULL){
         insolv.Monthly_Debts_Stay_Lifted_Spouse__c = getSumOfAmounts(debtsWhereStayHasBeenLifted.Spouse);
      }
   }

   // expensesAsAConditionOfEmployment
   public static void parseExpensesAsAConditionOfEmployment(FamilyMembers expensesAsAConditionOfEmployment, Insolvency__c insolv){
      if(expensesAsAConditionOfEmployment.Debtor != NULL){
         insolv.Monthly_Expenses_Empl_Cond_Debtor__c = getSumOfAmounts(expensesAsAConditionOfEmployment.Debtor);
      }
      // else if(expensesAsAConditionOfEmployment.Bankrupt != NULL){
      //    insolv.Monthly_Expenses_Empl_Cond_Debtor__c = getDecimalValue(expensesAsAConditionOfEmployment.Bankrupt);
      // }
      if(expensesAsAConditionOfEmployment.Others != NULL){
         insolv.Monthly_Expenses_Empl_Cond_Other__c = getSumOfAmounts(expensesAsAConditionOfEmployment.Others);
      }
      if(expensesAsAConditionOfEmployment.Spouse != NULL){
         insolv.Monthly_Expenses_Empl_Cond_Spouse__c = getSumOfAmounts(expensesAsAConditionOfEmployment.Spouse);
      }
   }

   // finesPenaltiesImposedByTheCourt
   public static void parseFinesPenaltiesImposedByTheCourt(FamilyMembers finesPenaltiesImposedByTheCourt, Insolvency__c insolv){
      if(finesPenaltiesImposedByTheCourt.Debtor != NULL){
         insolv.Monthly_Fines_Imposed_Court_Debtor__c = getSumOfAmounts(finesPenaltiesImposedByTheCourt.Debtor);
      }
      // else if(finesPenaltiesImposedByTheCourt.Bankrupt != NULL){
      //    insolv.Monthly_Fines_Imposed_Court_Debtor__c = getDecimalValue(finesPenaltiesImposedByTheCourt.Bankrupt);
      // }
      if(finesPenaltiesImposedByTheCourt.Others != NULL){
         insolv.Monthly_Fines_Imposed_Court_Other__c = getSumOfAmounts(finesPenaltiesImposedByTheCourt.Others);
      }
      if(finesPenaltiesImposedByTheCourt.Spouse != NULL){
         insolv.Monthly_Fines_Imposed_Court_Spouse__c = getSumOfAmounts(finesPenaltiesImposedByTheCourt.Spouse);
      }
   }

   // medicalConditionExpenses
   public static void parseMedicalConditionExpenses(FamilyMembers medicalConditionExpenses, Insolvency__c insolv){
      if(medicalConditionExpenses.Debtor != NULL){
         insolv.Monthly_Health_Condition_Expenses_Debtor__c = getSumOfAmounts(medicalConditionExpenses.Debtor);
      }
      // else if(medicalConditionExpenses.Bankrupt != NULL){
      //    insolv.Monthly_Health_Condition_Expenses_Debtor__c = getDecimalValue(medicalConditionExpenses.Bankrupt);
      // }
      if(medicalConditionExpenses.Others != NULL){
         insolv.Monthly_Health_Condition_Expenses_Other__c = getSumOfAmounts(medicalConditionExpenses.Others);
      }
      if(medicalConditionExpenses.Spouse != NULL){
         insolv.Monthly_Health_Condition_Expenses_Spouse__c = getSumOfAmounts(medicalConditionExpenses.Spouse);
      }
   }

   // otherExpenses
   public static void parseOtherExpenses(FamilyMembers otherExpenses, Insolvency__c insolv){
      if(otherExpenses.Debtor != NULL){
         insolv.Monthly_Other_Expenses_Debtor__c = getSumOfAmounts(otherExpenses.Debtor);
      }
      // else if(otherExpenses.Bankrupt != NULL){
      //    insolv.Monthly_Other_Expenses_Debtor__c = getDecimalValue(otherExpenses.Bankrupt);
      // }
      if(otherExpenses.Others != NULL){
         insolv.Monthly_Other_Expenses_Other__c = getSumOfAmounts(otherExpenses.Others);
      }
      if(otherExpenses.Spouse != NULL){
         insolv.Monthly_Other_Expenses_Spouse__c = getSumOfAmounts(otherExpenses.Spouse);
      }
   }

    // spousalSupportPayments
    public static void parseSpousalSupportPayments(FamilyMembers spousalSupportPayments, Insolvency__c insolv){
      if(spousalSupportPayments.Debtor != NULL){
         insolv.Monthly_Spousal_Support_Payments_Debtor__c = getSumOfAmounts(spousalSupportPayments.Debtor);
      }
      // else if(spousalSupportPayments.Bankrupt != NULL){
      //    insolv.Monthly_Spousal_Support_Payments_Debtor__c = getDecimalValue(spousalSupportPayments.Bankrupt);
      // }
      if(spousalSupportPayments.Others != NULL){
         insolv.Monthly_Spousal_Support_Payments_Other__c = getSumOfAmounts(spousalSupportPayments.Others);
      }
      if(spousalSupportPayments.Spouse != NULL){
         insolv.Monthly_Spousal_Support_Payments_Spouse__c = getSumOfAmounts(spousalSupportPayments.Spouse);
      }
    }

    // totalMonthlyNonDiscretionaryExpenses
    public static void parseTotalMonthlyNonDiscretionaryExpenses(FamilyMembers totalMonthlyNonDiscretionaryExpenses, Insolvency__c insolv){
      if(totalMonthlyNonDiscretionaryExpenses.Debtor != NULL){
         insolv.Total_Non_Discretionary_Expenses_Debtor__c = getSumOfAmounts(totalMonthlyNonDiscretionaryExpenses.Debtor);
      }
      // else if(totalMonthlyNonDiscretionaryExpenses.Bankrupt != NULL){
      //    insolv.Total_Non_Discretionary_Expenses_Debtor__c = getDecimalValue(totalMonthlyNonDiscretionaryExpenses.Bankrupt);
      // }
      if(totalMonthlyNonDiscretionaryExpenses.Others != NULL){
         insolv.Total_Non_Discretionary_Expenses_Other__c = getSumOfAmounts(totalMonthlyNonDiscretionaryExpenses.Others);
      }
      if(totalMonthlyNonDiscretionaryExpenses.Spouse != NULL){
         insolv.Total_Non_Discretionary_Expenses_Spouse__c = getSumOfAmounts(totalMonthlyNonDiscretionaryExpenses.Spouse);
      }
    }

    // housingExpenses
    public static void parseHousingExpenses(HousingExpenses housingExpenses, Insolvency__c insolv){
      if(housingExpenses.rentMortgageHypothec != NULL){
         insolv.Rent_Mortgage_Hypothec_Expenses__c = getSumOfAmounts(housingExpenses.rentMortgageHypothec);
      }
      if(housingExpenses.propertyTaxesCondoFees != NULL){
         insolv.Property_Taxes_Condo_Fees_Expenses__c = getSumOfAmounts(housingExpenses.propertyTaxesCondoFees);
      }
      if(housingExpenses.heatingGasOil != NULL){
         insolv.Heating_Gas_Oil_Expenses__c = getSumOfAmounts(housingExpenses.heatingGasOil);
      }
      if(housingExpenses.telephone != NULL){
         insolv.Telephone_Expenses__c = getSumOfAmounts(housingExpenses.telephone);
      }
      if(housingExpenses.cable != NULL){
         insolv.Cable_Expenses__c = getSumOfAmounts(housingExpenses.cable);
      }
      if(housingExpenses.hydro != NULL){
         insolv.Hydro_Expenses__c = getSumOfAmounts(housingExpenses.hydro);
      }
      if(housingExpenses.water != NULL){
         insolv.Water_Expenses__c = getSumOfAmounts(housingExpenses.water);
      }
      if(housingExpenses.furniture != NULL){
         insolv.Furniture_Expenses__c = getSumOfAmounts(housingExpenses.furniture);
      }
      if(housingExpenses.other != NULL){
         insolv.Other_Housing_Expenses__c = getSumOfAmounts(housingExpenses.other);
      }
    }

    // insuranceExpenses
    public static void parseInsuranceExpenses(InsuranceExpenses insuranceExpenses, Insolvency__c insolv){
      if(insuranceExpenses.vehicle != NULL){
         insolv.Vehicle_Expenses__c = getSumOfAmounts(insuranceExpenses.vehicle);
      }
      if(insuranceExpenses.house != NULL){
         insolv.House_Expenses__c = getSumOfAmounts(insuranceExpenses.house);
      }
      if(insuranceExpenses.furnitureContents != NULL){
         insolv.Furniture_Contents_Expenses__c = getSumOfAmounts(insuranceExpenses.furnitureContents);
      }
      if(insuranceExpenses.lifeInsurance != NULL){
         insolv.Life_Insurance_Expenses__c = getSumOfAmounts(insuranceExpenses.lifeInsurance);
      }
      if(insuranceExpenses.other != NULL){
         insolv.Other_Insurance_Expenses__c = getSumOfAmounts(insuranceExpenses.other);
      }
    }

    //livingExpenses
    public static void parseLivingExpenses(LivingExpenses livingExpenses, Insolvency__c insolv){
      if(livingExpenses.foodGrocery != NULL){
         insolv.Food_Grocery_Expenses__c = getSumOfAmounts(livingExpenses.foodGrocery);
      }
      if(livingExpenses.laundryDryCleaning != NULL){
         insolv.Laundry_Dry_Cleaning_Expenses__c = getSumOfAmounts(livingExpenses.laundryDryCleaning);
      }
      if(livingExpenses.groomingToiletries != NULL){
         insolv.Grooming_Toiletries_Expenses__c = getSumOfAmounts(livingExpenses.groomingToiletries);
      }
      if(livingExpenses.clothing != NULL){
         insolv.Clothing_Expenses__c = getSumOfAmounts(livingExpenses.clothing);
      }
      if(livingExpenses.other != NULL){
         insolv.Other_Living_Expenses__c = getSumOfAmounts(livingExpenses.other);
      }
    }

    //nonRecoverableMedicalExpenses
    public static void parseNonRecoverableMedicalExpenses(NonRecoverableMedicalExpenses nonRecoverableMedicalExpenses, Insolvency__c insolv){
      if(nonRecoverableMedicalExpenses.prescriptions != NULL){
         insolv.Prescriptions_Expenses__c = getSumOfAmounts(nonRecoverableMedicalExpenses.prescriptions);
      }
      if(nonRecoverableMedicalExpenses.dental != NULL){
         insolv.Dental_Expenses__c = getSumOfAmounts(nonRecoverableMedicalExpenses.dental);
      }
      if(nonRecoverableMedicalExpenses.other != NULL){
         insolv.Other_Medical_Expenses__c = getSumOfAmounts(nonRecoverableMedicalExpenses.other);
      }
    }

    // payments
    public static void parsePayments(Payments payments, Insolvency__c insolv){
      if(payments.paymentsToTheProposal != NULL){
         insolv.Payments_To_Proposal__c = getSumOfAmounts(payments.paymentsToTheProposal);
      }
      if(payments.toSecuredCreditor != NULL){
         insolv.Payment_To_Secured_Creditor__c = getSumOfAmounts(payments.toSecuredCreditor);
      }
      if(payments.otherThanMortgageAndVehicle != NULL){
         insolv.Payments_Other_Than_Mortgage_Vehicle__c = getSumOfAmounts(payments.otherThanMortgageAndVehicle);
      }
      if(payments.other != NULL){
         insolv.Other_Payments__c = getSumOfAmounts(payments.other);
      }
    }

    // personalExpenses
    public static void parsePersonalExpenses(PersonalExpenses personalExpenses, Insolvency__c insolv){
      if(personalExpenses.smoking != NULL){
         insolv.Smoking_Expenses__c = getSumOfAmounts(personalExpenses.smoking);
      }
      if(personalExpenses.alcohol != NULL){
         insolv.Alcohol_Expenses__c = getSumOfAmounts(personalExpenses.alcohol);
      }
      if(personalExpenses.diningLunchesRestaurants != NULL){
         insolv.Dining_Expenses__c = getSumOfAmounts(personalExpenses.diningLunchesRestaurants);
      }
      if(personalExpenses.entertainmentSports != NULL){
         insolv.Entertainment_Sports_Expenses__c = getSumOfAmounts(personalExpenses.entertainmentSports);
      }
      if(personalExpenses.giftsCharitableDonations != NULL){
         insolv.Gifts_Charitable_Expenses__c = getSumOfAmounts(personalExpenses.giftsCharitableDonations);
      }
      if(personalExpenses.allowances != NULL){
         insolv.Allowances_Expenses__c = getSumOfAmounts(personalExpenses.allowances);
      }
      if(personalExpenses.other != NULL){
         insolv.Other_Personal_Expenses__c = getSumOfAmounts(personalExpenses.other);
      }
    }

    //transportationExpenses
    public static void parseTransportationExpenses(TransportationExpenses transportationExpenses, Insolvency__c insolv){
      if(transportationExpenses.carLeasePayments != NULL){
         insolv.Car_Lease_Payments_Expenses__c = getSumOfAmounts(transportationExpenses.carLeasePayments);
      }
      if(transportationExpenses.repairMaintenanceGas != NULL){
         insolv.Repair_Maintenance_Gas_Expenses__c = getSumOfAmounts(transportationExpenses.repairMaintenanceGas);
      }
      if(transportationExpenses.publicTransportation != NULL){
         insolv.Public_Transportation_Expenses__c = getSumOfAmounts(transportationExpenses.publicTransportation);
      }
      if(transportationExpenses.other != NULL){
         insolv.Other_TransportationExpenses__c = getSumOfAmounts(transportationExpenses.other);
      }
    }

    // Read all Insolvency Record types and return
    public static Id getInsolvencyRecordType(String creditorName,String creditorAccountNumber){
      creditorName = creditorName.toUpperCase();
      for(String str: scotiaBank){
         if(creditorName.contains(str)){
            return insolvencyRecordTypeMap.get('Scotia_Bank_Insolvency_Account');
         }
      }

      for(String str: sdaBank){
         if(creditorName.contains(str)){
            return insolvencyRecordTypeMap.get('SDA_Insolvency_Account');
         }
      }
      //Ticket 4587: Added excluded account
      String acctNameCS = '676';
      String acctNameCS1 = '6030';
      //Ticket 4587 and 4581: fairstone account not starts with 676 and 6030 and insolvency date should be greater than 23rd May
      for(String str: fairstone){
          if(creditorName.contains(str) && creditorAccountNumber != NULL
             && !(creditorAccountNumber.contains(acctNameCS))
             && !(creditorAccountNumber.contains(acctNameCS1))
             && InsolvencyAccDate > Date.newInstance( 2023, 5, 23 )){
                 return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
             }else{
               if(creditorName.contains(str) && creditorAccountNumber == NULL
                 && InsolvencyAccDate > Date.newInstance( 2023, 5, 23 )){
                   return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
               }
           }
      }

      for(String str: goEasy){
         if(creditorName.contains(str)){
            return insolvencyRecordTypeMap.get('Goeasy_Insolvency_Account');
         }
      }
        
      for(String str: canaccedeBank){
         if(creditorName.contains(str)){
            return insolvencyRecordTypeMap.get('Canaccede_Insolvency_Account');
         }
      }

      for(String str: fidemBank){
         if(creditorName.contains(str)){
            return insolvencyRecordTypeMap.get('Fidem_Insolvency_Account');
         }
      }
      
      return null;
    }

    // Read Insolvency Record types based on account number starts with specific sequence as defined
    public static Id getFairstoneInsolvencyRecordTypeAccNumber(String creditorAccountNumber){
      for(String str: fairstoneAcc){
        if(creditorAccountNumber.startsWith(str) && InsolvencyAccDate > Date.newInstance( 2023, 5, 23 )){
           return insolvencyRecordTypeMap.get('Fairstone_Insolvency_Account');
        }
     }
     return null;
   }

    // Read Insolvency Record types based on account number starts with specific sequence as defined
    public static Id getInsolvencyRecordTypeAccountNumber(String creditorAccountNumber){
       for(String str: splBank){
         if(creditorAccountNumber.startsWith(str)){
            return insolvencyRecordTypeMap.get('SPL_Insolvency_Account');
         }
      }
      return null;
    }

    // Create Insolvency Account from creditor information from JSON
    public static void createInsolvencyAccounts(List<Liabilities> liabilities, Insolvency__c insolv, List<Insolvency_Account__c> insolvAccounts,  List<Creditor_Account__c> creditorAccounts){
      
      // Insolvency calculated fields over accounts
      insolv.Total_Unsecured_Liabilities_Clc__c = 0;
      insolv.Total_Secured_Liabilities_Clc__c = 0;
      insolv.Total_Preferred_Liabilities_Clc__c = 0;
      insolv.Secured_Debts_Unsecured_Portion__c = 0;

      for(Liabilities liability: liabilities){
         Insolvency_Account__c insolvAccount = new Insolvency_Account__c();
         
         //insolvAccount.Name = 'unknown';
         insolvAccount.Name = UNKNOWN_RECORD_NAME;
         
         insolvAccount.Claim_Type__c = 'Unsecured';
         insolvAccount.Created_By_Doc_Parser__c = true;

         if(liability.creditor != NULL){
            insolvAccount.Creditor_Name__c = liability.creditor;
            insolvAccount.RecordTypeId = getInsolvencyRecordType(liability.creditor,liability.accountNumber);
         }
         if(liability.creditorAddress != NULL){
            insolvAccount.Address_of_Creditor__c = liability.creditorAddress;
         }
         if(liability.accountNumber != NULL){
            
            //remove white spaces from Insolvency Account Name
            String formattedName = liability.accountNumber.deleteWhitespace();
            
            //Set default name if value is greater than 20
            if(formattedName.length() <= 20){
               insolvAccount.Name = formattedName;
            }
            else{
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

            // Check if this is SPL or Fairstone account
            if(insolvAccount.RecordTypeId == NULL){
               insolvAccount.RecordTypeId = getInsolvencyRecordTypeAccountNumber(liability.accountNumber);
               insolvAccount.RecordTypeId = getFairstoneInsolvencyRecordTypeAccNumber(liability.accountNumber);
            }
         }
         // Unsecured Account
         if(liability.unsecuredDebt != NULL && getDecimalValue(liability.unsecuredDebt) > 0){
            insolvAccount.Unsecured_Asset_Amount__c = getDecimalValue(liability.unsecuredDebt);
            insolv.Total_Unsecured_Liabilities_Clc__c = insolv.Total_Unsecured_Liabilities_Clc__c+insolvAccount.Unsecured_Asset_Amount__c;
         }
         // Secured Account
         if(liability.securedDebt != NULL && getDecimalValue(liability.securedDebt) > 0){
            insolvAccount.Secured_Asset_Amount__c = getDecimalValue(liability.securedDebt);
            insolvAccount.Claim_Type__c = 'Secured';
            insolv.Total_Secured_Liabilities_Clc__c = insolv.Total_Secured_Liabilities_Clc__c+insolvAccount.Secured_Asset_Amount__c;
            
            // If it has both secured and un secured amount
            if(liability.unsecuredDebt != NULL && getDecimalValue(liability.unsecuredDebt) > 0){
               insolv.Secured_Debts_Unsecured_Portion__c = insolv.Secured_Debts_Unsecured_Portion__c+insolvAccount.Unsecured_Asset_Amount__c;
            }
         }
         if(liability.preferredDebt != NULL && getDecimalValue(liability.preferredDebt) > 0){
            insolvAccount.Claim_Type__c = null;
            insolvAccount.Preferred_Amount__c = getDecimalValue(liability.preferredDebt);
            insolv.Total_Preferred_Liabilities_Clc__c = insolv.Total_Preferred_Liabilities_Clc__c+insolvAccount.Preferred_Amount__c;
         }
         if(liability.ltc != NULL){
            insolvAccount.Liabilities_Type_Code__c = liability.ltc;
         }
        
         // Caputre insolvency account side related creditorId  & liabilityId
         if(liability.creditorId != NULL){
            insolvAccount.Creditor_Id__c = liability.creditorId;
         }
         if(liability.liabilityId != NULL){
            insolvAccount.Liability_Id__c = liability.liabilityId;
         }
        
         // 4798
         if(String.isNotBlank(insolvAccount.Claim_Type__c) && String.isNotBlank(insolvAccount.RecordTypeId) && insolvAccount.RecordTypeId == insolvencyRecordTypeMap.get('Goeasy_Insolvency_Account')){
            insolvAccount.Type_of_Service__c = 'Service and Sale';
            if(insolvAccount.Claim_Type__c == 'Secured'){
               insolvAccount.Type_of_Service__c = 'Service Only';
            }
         }

         // Add to insolvency if it is Scotia bank, SPL, or SDA
         if(insolvAccount.RecordTypeId != NULL){
            insolvAccounts.add(insolvAccount);
         }else{   // Else create creditor account
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
    public static Creditor_Account__c createCreditorAccount(Liabilities liability){
      Creditor_Account__c creditorAccount = new Creditor_Account__c();
      
      //creditorAccount.Name = 'unknown';
      creditorAccount.Name = UNKNOWN_RECORD_NAME;
      
      creditorAccount.Claim_Type__c = 'Unsecured';
      creditorAccount.Created_By_Doc_Parser__c = true;
      
      if(liability.creditor != NULL){
         creditorAccount.Creditor_Name__c = liability.creditor;
      }
      if(liability.creditorAddress != NULL){
         creditorAccount.Address_of_Creditor__c = liability.creditorAddress;
      }
      
       //creditor Account capture creditorId  & liabilityId
      if(liability.creditorId != NULL){
        creditorAccount.Creditor_Id__c = liability.creditorId;
      }
      if(liability.liabilityId != NULL){
         creditorAccount.Liability_Id__c = liability.liabilityId;
      }
       
      if(liability.accountNumber != NULL){
      
        //remove white spaces from Insolvency Account Name
        String formattedName = liability.accountNumber.deleteWhitespace();
        
        //Set default name if value is greater than 20
        if(formattedName.length() <= 20){
           creditorAccount.Name = formattedName;
        }
        else{
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
      if(liability.unsecuredDebt != NULL){
         creditorAccount.Unsecured_Asset_Amount__c = getDecimalValue(liability.unsecuredDebt);
      }
      // Secured Account
      if(liability.securedDebt != NULL && getDecimalValue(liability.securedDebt) > 0){
         creditorAccount.Secured_Asset_Amount__c = getDecimalValue(liability.securedDebt);
         creditorAccount.Claim_Type__c = 'Secured';
      }
      if(liability.preferredDebt != NULL && getDecimalValue(liability.preferredDebt) > 0){
         creditorAccount.Claim_Type__c = null;
         creditorAccount.Preferred_Amount__c = getDecimalValue(liability.preferredDebt);
      }
      if(liability.ltc != NULL){
         creditorAccount.Liabilities_Type_Code__c = liability.ltc;
      }
      return creditorAccount;
    }

    // Create Insolvencies from JSON response debtors
    public static  Insolvency__c createDebtors(List<Debtors> debtors, Insolvency__c insolv){

      // Debtor1
      if(!debtors.isEmpty()){
         Debtors debtor = debtors.get(0);
         if(debtor.firstName != NULL){
            insolv.Debtor_1_First_Name__c = debtor.firstName;
         }
         if(debtor.middleName != NULL){
            insolv.Debtor_1_Middle_Name__c = debtor.middleName;
         }
         if(debtor.lastName != NULL){
            insolv.Debtor_1_Last_Name__c = debtor.lastName;
         }
         if(debtor.gender != NULL){
            //insolv.Debtor_1_Gender__c = debtor.gender;
            insolv.Debtor_1_Gender__c = getGenderValues(debtor.gender);
         }
         if(debtor.dateOfBirth != NULL){
            insolv.Debtor_1_Date_of_Birth__c = formatDate(debtor.dateOfBirth) ;
         }
         if(debtor.alsoKnownAs != NULL){ 
            insolv.Debtor_1_Alias_Name__c = debtor.alsoKnownAs;
         }
         if(debtor.streetAddress != NULL){
            insolv.Debtor_1_Mailing_Street__c = debtor.streetAddress;
         }
         if(debtor.city != NULL){
            insolv.Debtor_1_Mailing_City__c = debtor.city;
         }
         if(debtor.province != NULL){
            insolv.Debtor_1_Mailing_State_Province__c = getProvince(debtor.province);
         }
         if(debtor.postalCode != NULL){
            insolv.Debtor_1_Mailing_Postal_Code__c = debtor.postalCode;
         }
         if(debtor.maritalStatus != NULL){
               insolv.Debtor_1_Marital_Status__c = getMaritalStaus(debtor.maritalStatus);
         }
         if(debtor.nameOfPresentEmployer != NULL){
            insolv.Debtor_1_Employer_Name__c = debtor.nameOfPresentEmployer;
         }
         if(debtor.occupation != NULL){
            insolv.Debtor_1_Occupation__c = debtor.occupation;
         }
      }  // Debtor1 End

         // Debtor2
         if(debtors != NULL && debtors.size() > 1){
            Debtors debtor = debtors.get(1);
            if(debtor.firstName != NULL){
               insolv.Debtor_2_First_Name__c = debtor.firstName;
            }
            if(debtor.middleName != NULL){
                insolv.Debtor_2_Middle_Name__c = debtor.middleName;
            }
            if(debtor.lastName != NULL){
               insolv.Debtor_2_Last_Name__c = debtor.lastName;
            }
            if(debtor.gender != NULL){
               //insolv.Debtor_2_Gender__c = debtor.gender;
               insolv.Debtor_2_Gender__c = getGenderValues(debtor.gender);
            }
            if(debtor.dateOfBirth != NULL){
               insolv.Debtor_2_Date_of_Birth__c = formatDate(debtor.dateOfBirth);
            }
            if(debtor.alsoKnownAs != NULL){
               insolv.Debtor_2_Alias_Name__c = debtor.alsoKnownAs;
            }
            if(debtor.streetAddress != NULL){
               insolv.Debtor_2_Mailing_Street__c = debtor.streetAddress;
            }
            if(debtor.city != NULL){
               insolv.Debtor_2_Mailing_City__c = debtor.city;
            }
            if(debtor.province != NULL){
               insolv.Debtor_2_Mailing_State_Province__c = getProvince(debtor.province);
            }
            if(debtor.postalCode != NULL){
               insolv.Debtor_2_Mailing_Postal_Code__c = debtor.postalCode;
            }
            if(debtor.maritalStatus != NULL){
               insolv.Debtor_2_Marital_Status__c = getMaritalStaus(debtor.maritalStatus);
            }
            if(debtor.nameOfPresentEmployer != NULL){
               insolv.Debtor_2_Employer_Name__c = debtor.nameOfPresentEmployer;
            }
            if(debtor.occupation != NULL){
               insolv.Debtor_2_Occupation__c = debtor.occupation;
            }
         } // Debtor 2 END
      return insolv;
    }

    // Court Province value mapping with JSON values
    public static String getProvince(String province){
      province = province.toUpperCase();
      if(courtProvinceMap.containsKey(province)){
         return courtProvinceMap.get(province);
      }
      else{
         return null;
      }
    }

    // Insolvency Account Marital status value mapping with JSON values
    public static String getMaritalStaus(String maritalStatus){
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
      if(maritalStatusMap.containsKey(maritalStatus)){
         return maritalStatusMap.get(maritalStatus);
      }
      else{
         return null;
      }
    }
    
    // Insolvency Account Gender value mapping with JSON values
    public static String getGenderValues(String genderValue){
      
        genderValue = genderValue.toUpperCase();
        if(genderValueMap.containsKey(genderValue)){
            return genderValueMap.get(genderValue);
        }
        else{
            return null;
        }
    }
    
    // Insolvency Account Yes/No value mapping with JSON values
    public static String getYesNoValues(String yesNoValue){
        yesNoValue = yesNoValue.toUpperCase();
        if(yesNoValueMap.containsKey(yesNoValue)){
            return yesNoValueMap.get(yesNoValue);
        }
        else{
            return '';
        }
    }
    
    //Insolvency Payment Frequency mapping with JSON values
    public static String getPaymentFrequencyValues(String paymentFrequencyValue){
        paymentFrequencyValue = paymentFrequencyValue.toUpperCase();
        if(paymentFrequencyValueMap.containsKey(paymentFrequencyValue)){
            return paymentFrequencyValueMap.get(paymentFrequencyValue);
        }else{
            return paymentFrequencyValue;
        }
    }
    
    // Convert string to deciamal value which is used in JSON response handler
    public static Double getDecimalValue(String decimalString){

      // Remove uncessary spaces from  number recieved
      decimalString = decimalString.replaceAll(' ', '');
      decimalString = decimalString.replaceAll(',', '');
      
      return Decimal.valueOf(decimalString);
    }

    // Method sum ups all the amounts and returns total value
    public static Double getSumOfAmounts(String [] amounts){
       Decimal finalVal = 0.0;
       for(String amount : amounts){
           try{
           finalVal = finalVal + getDecimalValue(amount);
           }catch(Exception ex){
               system.debug('Error in getSumOfAmounts '+ex.getMessage()+', and  value:'+amount);
           }
       }
       return finalVal;
     }
     
    // Format date from 11/03/2020 to Salesforce Date type
    public static Date formatDate(String dateString){
       String[] dt  = dateString.split('/');  // ex: 11/03/2020
       date myDate = date.newInstance(Integer.valueOf(dt[2]), Integer.valueOf(dt[1]), Integer.valueOf(dt[0])); // format to yyyy mm dd
       return myDate;
    }
    
    //update default values on Insolvency
    public static Insolvency__c populateInsolvency(Insolvency__c insolv, Case caseRecord){
        
        insolv.Insolvency_Status__c = 'Staging';
        insolv.Insolvency_Received_Date__c = (caseRecord.createdDate).date();
        
        return insolv;
    }
    
    //update default values on InsolvencyAccount
    public static List<Insolvency_Account__c> populateInsolvencyAccount(List<Insolvency_Account__c> listAccount){
        
        for(Insolvency_Account__c insolvAcc : listAccount){
            insolvAcc.Insolvency_Status__c = 'New';
        }
        
        return listAccount;
    }

    // Note: Do not change any of the wrapper calss variable names, because it should match with JSON attirbute names for parsing
    public class ResponseParser{
        public String CourtNo;   // Debtor_1_Court_Number
        public String [] EstateNo;  // Name, Debtor_2_Estate_Number__c
        public String CourtDivision;   //Court_Division_Number
        public String CourtDistrict;   // Court_District_Name
        public String CourtProvince;   // Court_Province
        public Form01Dot1Parts Form01Dot1Parts;
        public Form47Parts Form47Parts;
        public Form48Parts Form48Parts;
        public Form49Parts Form49Parts;
        public Form65Parts Form65Parts;
        public Form79Parts Form79Parts;
        public Form69Parts Form69Parts;
    }

    public class Form01Dot1Parts{
        public String trusteeCorporateName;
        public String trusteeAddress;
    }

    public class Form47Parts{
      public String paymentAmount;
      public String paymentFrequency;
      public String numberOfPayments;
      public String notice1;
      public String notice4;    // TODO check if these attributes were present in JSON or not
      public String notice6;
    }

    public class Form48Parts{
      public String notice4;
      public String notice5;
    }
   
    public class Assets{
        public String totalEstimatedDollarValue;
        public String totalSecuredAmountOrLiens;
        public String totalEstimatedNetRealizableDollarValue;
         Type [] items;
    }

    public class Type{
        public String type;
        public String description;
        public String estimatedDollarValue;
        public String exemptPropertyYes;
        public String exemptPropertyNo;
        public String securedAmountOrLiens;
        public String estimatedNetRealizableDollarValue;
    }

    public class Liability{
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

    public class Debtors{
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
    }
    
    public class Form49Parts{
      public string insolvencyType;
      public String insolvencyDate;
      //public Date insolvencyAccDate;
    }

    public class Form69Parts{
      public string insolvencyType;
      public String insolvencyDate;
      //public Date insolvencyAccDate;
    }

    public class Form65Parts{
        public MonthlyIncome monthlyIncome;
        public MonthlyNonDiscretionaryExpenses monthlyNonDiscretionaryExpenses;
        public MonthlyDiscretionaryExpenses monthlyDiscretionaryExpenses;
    }

    public class MonthlyIncome{
        public FamilyMembers netEmploymentIncome;
        public FamilyMembers netPensionAnnuities;
        public FamilyMembers netChildSupport;
        public FamilyMembers netSpousalSupport;
        public FamilyMembers netEmploymentInsuranceBenefits;
        public FamilyMembers netSocialAssistance;
        public FamilyMembers childTaxBenefit;
        public FamilyMembers otherNetIncome;
        public FamilyMembers totalMonthlyIncome;
        public String [] headings;
        public String totalMonthlyIncomeOfTheFamilyUnit;
        public String [] grossSelfEmploymentIncome;
        public FamilyMembers netSelfEmploymentIncome;
    }
    
    public class FamilyMembers{
        public String [] Debtor;
        public String [] Spouse;
        public String [] Others;
        public String [] Total;
        public sObject MontlhyIncomeIgnore;   // ignore this attribute we do not use any where
    }

    public class MonthlyNonDiscretionaryExpenses{
        public FamilyMembers childSupportPayments;
        public FamilyMembers spousalSupportPayments;
        public FamilyMembers childCare;
        public FamilyMembers medicalConditionExpenses;
        public FamilyMembers finesPenaltiesImposedByTheCourt;
        public FamilyMembers expensesAsAConditionOfEmployment;
        public FamilyMembers debtsWhereStayHasBeenLifted;
        public FamilyMembers otherExpenses;
        public FamilyMembers totalMonthlyNonDiscretionaryExpenses;
        public String [] headings;
        public String totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit;
        public String [] availableMonthlyIncomeOfTheDebtor;
        public String availableMonthlyIncomeOfTheFamilyUnit;
        public String [] debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit;
    }

    public class MonthlyDiscretionaryExpenses{
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
    
    public class HousingExpenses{
        public String [] rentMortgageHypothec;
        public String [] propertyTaxesCondoFees;
        public String [] heatingGasOil;
        public String [] telephone;
        public String [] cable;
        public String [] hydro;
        public String [] water;
        public String [] furniture;
        public String [] other;
    }

    public class PersonalExpenses{
        public String [] smoking;
        public String [] alcohol;
        public String [] diningLunchesRestaurants;
        public String [] entertainmentSports;
        public String [] giftsCharitableDonations;
        public String [] allowances;
        public String [] other;
    }
    
    public class NonRecoverableMedicalExpenses{
        public String [] prescriptions;
        public String [] dental;
        public String [] other;
    }
    
    public class LivingExpenses{
        public String [] foodGrocery;
        public String [] laundryDryCleaning;
        public String [] groomingToiletries;
        public String [] clothing;
        public String [] other;
    }
    
    public class TransportationExpenses{
        public String [] carLeasePayments;
        public String [] repairMaintenanceGas;
        public String [] publicTransportation;
        public String [] other;
    }
    
    public class InsuranceExpenses{
        public String [] vehicle;
        public String [] house;
        public String [] furnitureContents;
        public String [] lifeInsurance;
        public String [] other;
    }
    
    public class Payments{
      public String [] paymentsToTheProposal;
      public String [] toSecuredCreditor;
      public String [] other;
      public String [] otherThanMortgageAndVehicle;
    }
    /*
    // Creditor Id and Liability Id form Creditor Package
    public class Form47Creditorpackage{
    public String [] creditorId;
    public String [] liabilityId;
    }
    */

    public class Form79Parts{
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
}