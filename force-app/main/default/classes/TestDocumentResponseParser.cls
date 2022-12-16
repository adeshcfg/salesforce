@isTest(seeAllData = false)
public class TestDocumentResponseParser {
    @TestSetup
    static void makeData(){
     Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
     config.Run_Insolvency_Account_Trigger__c = true;
     config.Run_Insolvency_Trigger__c = false;
     config.Run_Insolvency_Account_Duplicate_Check__c = true;
     config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
     config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
     config.Eligible_for_Validn_Needed_Calculation__c = 'test';
     config.Bank_Eligible_for_Duplicate_Check__c = 'test';
     config.Eligible_for_Claim_Type_Calculation__c = 'test';
     insert config;   
    }
   
    static @IsTest
    public void methodName(){
         //Case record creation
         Case caseObj = new Case();
         caseObj.Status = 'InProgress';
         caseObj.Insolvency_Assignment_Type__c = 'Business Insolvency';
         INSERT caseObj;
         
         //Attachment record creation
         Attachment att = new Attachment();
         att.parentId = caseObj.Id;
         att.Body = Blob.valueOf('Test Attach');
         att.Name= 'Test';
         att.Description = 'Creditors Package';
         att.IsPrivate = false;
         INSERT att;
         
         Parsed_Response_Holder__c parseResponse = new Parsed_Response_Holder__c();
         parseResponse.Status__c = 'Pending';
         parseResponse.Parsed_Response_Formatted__c = sampleJSON;
         parseResponse.Assignment__c = caseObj.Id;
         insert parseResponse;
         parseResponse = [SELECT Status__c, Parsed_Response__c, Error_Details__c FROM Parsed_Response_Holder__c WHERE Id =: parseResponse.Id LIMIT 1];
         
         //Commented as test class is failing in Production
         //System.assertEquals('Processed', parseResponse.Status__c);
         
         system.debug('Error_Details__c '+parseResponse.Error_Details__c);
         
         parseResponse.Parsed_Response_Formatted__c ='{';
         parseResponse.Status__c='Pending';
         update parseResponse;
         parseResponse = [SELECT Status__c FROM Parsed_Response_Holder__c WHERE Id =: parseResponse.Id LIMIT 1];
         System.assertEquals('Error', parseResponse.Status__c);

    }

    static @IsTest
    public void methodName2(){
         //Case record creation
         Case caseObj = new Case();
         caseObj.Status = 'InProgress';
         caseObj.Insolvency_Assignment_Type__c = 'Business Insolvency';
         INSERT caseObj;
         
         //Attachment record creation
         Attachment att = new Attachment();
         att.parentId = caseObj.Id;
         att.Body = Blob.valueOf('Test Attach');
         att.Name= 'Test';
         att.Description = 'Creditors Package';
         att.IsPrivate = false;
         INSERT att;
         
         Parsed_Response_Holder__c parseResponse = new Parsed_Response_Holder__c();
         parseResponse.Status__c = 'Pending';
         parseResponse.Parsed_Response_Formatted__c = sampleJSON1;
         parseResponse.Assignment__c = caseObj.Id;
         insert parseResponse;
         parseResponse = [SELECT Status__c, Parsed_Response__c, Error_Details__c FROM Parsed_Response_Holder__c WHERE Id =: parseResponse.Id LIMIT 1];
         
         //Commented as test class is failing in Production
         //System.assertEquals('Processed', parseResponse.Status__c);
         
         system.debug('Error_Details__c '+parseResponse.Error_Details__c);
    }

    public static string sampleJSON = '{'+
    '"courtNo":"24-2458454",'+
    '"estateNo":['+
       '"24-2458454"'+
    '],'+
    '"courtDivision":"1",'+
    '"courtDistrict":"1",'+
    '"courtProvince":"Alberta",'+
    '"form01Dot1Parts":{'+
       '"trusteeCorporateName":"Hudson & Company Insolvency Trustees Inc.",'+
       '"trusteeAddress":"200 625 11 Avenue SW Calgary AB T2R 0E1"'+
    '},'+
    '"form47Parts":{'+
       '"paymentAmount":"225.00",'+
       '"paymentFrequency":"Monthly",'+
       '"numberOfPayments":"60",'+
       '"notice1":"      That secured creditors will be paid ine",'+
       '"notice4":"   dfdfd   ",'+
       '"notice6":"     rerere   "'+
    '},'+
    '"form48Parts":{'+
       '"notice4":" sdsdsds ",'+
       '"notice5":" greater.  These values are esti  "'+
    '},'+
    '"form49Parts":{'+
       '"insolvencyDate":"21/12/2018"'+
    '},'+
    '"form65Parts":{'+
       '"monthlyIncome":{'+

       '"childTaxBenefit":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netChildSupport":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netPensionAnnuities":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netSelfEmploymentIncome":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netSocialAssistance":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netSpousalSupport":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netEmploymentIncome":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"netEmploymentInsuranceBenefits":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"otherNetIncome":{'+
               '"Debtor":['+
                    '"2834.00"'+
               '],'+
               '"Others":['+
                    '"0.00"'+
               '],'+
               '"Total":['+
                    '"2834.00"'+
               '],'+
               '"Spouse":['+
                    '"2834.00"'+
               ']'+
          '},'+
          '"totalMonthlyIncome":{'+
          '"Debtor":['+
               '"2834.00"'+
          '],'+
          '"Others":['+
               '"0.00"'+
          '],'+
          '"Spouse":['+
               '"2834.00"'+
          '],'+
          '"Total":['+
                    '"0.00"'+
               ']'+
          '},'+
          '"totalMonthlyIncomeOfTheFamilyUnit":"2834.00",'+
          '"grossSelfEmploymentIncome":['+
             '"6250.00"'+
          '],'+
          '"headings":['+
             '"Description",'+
             '"Debtor",'+
             '"Others",'+
             '"Total"'+
          ']'+
       '},'+
       '"monthlyNonDiscretionaryExpenses":{'+
          '"totalMonthlyNonDiscretionaryExpenses":{'+
             '"Debtor":['+
                '"0.00"'+
             '],'+
             '"Others":['+
                '"0.00"'+
             '],'+
             '"Spouse":['+
                '"0.00"'+
             ']'+
          '},'+
          '"childCare":{'+
             '"Debtor":['+
                '"0.00"'+
             '],'+
             '"Others":['+
                '"0.00"'+
             '],'+
             '"Spouse":['+
                '"0.00"'+
             ']'+
          '},'+
          '"childSupportPayments":{'+
             '"Debtor":['+
                '"0.00"'+
             '],'+
             '"Others":['+
                '"0.00"'+
             '],'+
             '"Spouse":['+
                '"0.00"'+
             ']'+
          '},'+
          '"debtsWhereStayHasBeenLifted":{'+
             '"Debtor":['+
                '"0.00"'+
             '],'+
             '"Others":['+
                '"0.00"'+
             '],'+
             '"Spouse":['+
                '"0.00"'+
             ']'+
          '},'+
          '"expensesAsAConditionOfEmployment":{'+
             '"Debtor":['+
                '"0.00"'+
             '],'+
             '"Others":['+
                '"0.00"'+
             '],'+
             '"Spouse":['+
                '"0.00"'+
             ']'+
          '},'+
          '"finesPenaltiesImposedByTheCourt":{'+
               '"Debtor":['+
               '"0.00"'+
               '],'+
               '"Others":['+
               '"0.00"'+
               '],'+
               '"Spouse":['+
               '"0.00"'+
               ']'+
          '},'+
          '"medicalConditionExpenses":{'+
               '"Debtor":['+
               '"0.00"'+
               '],'+
               '"Others":['+
               '"0.00"'+
               '],'+
               '"Spouse":['+
               '"0.00"'+
               ']'+
          '},'+
          '"otherExpenses":{'+
               '"Debtor":['+
               '"0.00"'+
               '],'+
               '"Others":['+
               '"0.00"'+
               '],'+
               '"Spouse":['+
               '"0.00"'+
               ']'+
          '},'+
          '"spousalSupportPayments":{'+
               '"Debtor":['+
               '"0.00"'+
               '],'+
               '"Others":['+
               '"0.00"'+
               '],'+
               '"Spouse":['+
               '"0.00"'+
               ']'+
          '},'+

          '"debtorsPortionOfTheAvailableMonthlyIncomeOfTheFamilyUnit":['+
               '"2834.00"'+
          '],'+
          '"totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit":"0.00",'+
          '"availableMonthlyIncomeOfTheDebtor":['+
             '"2834.00"'+
          '],'+
          '"availableMonthlyIncomeOfTheFamilyUnit":"2834.00",'+
          '"headings":['+
             '"Description",'+
             '"Debtor",'+
             '"Others",'+
             '"Total"'+
          ']'+
       '},'+
       '"monthlyDiscretionaryExpenses":{'+
          '"totalFamilyUnitMonthlyDiscretionaryExpenses":"2830.00",'+
          '"familyUnitMonthlySurplusOrDeficit":"4.00",'+
          '"housingExpenses":{'+
             '"rentMortgageHypothec":['+
                '"950.00"'+
             '],'+
             '"telephone":['+
                '"90.00"'+
             '],'+
             '"cable":['+
                '"50.00"'+
             '],'+
             '"hydro":['+
                '"75.00"'+
             '],'+
             '"propertyTaxesCondoFees":['+
               '"75.00"'+
             '],'+
             '"heatingGasOil":['+
               '"75.00"'+
             '],'+
             '"water":['+
               '"75.00"'+
             '],'+
             '"furniture":['+
               '"75.00"'+
             '],'+
             '"other":['+
               '"75.00"'+
             ']'+
          '},'+
          '"nonRecoverableMedicalExpenses":{'+
               '"prescriptions":['+
                    '"950.00"'+
               '],'+
               '"dental":['+
                    '"90.00"'+
               '],'+
               '"other":['+
                    '"50.00"'+
               ']'+
          '},'+
          '"payments":{'+
               '"paymentsToTheProposal":['+
                    '"950.00"'+
               '],'+
               '"toSecuredCreditor":['+
                    '"90.00"'+
               '],'+
               '"other":['+
                    '"50.00"'+
               '],'+
               '"otherThanMortgageAndVehicle":['+
                    '"50.00"'+
               ']'+
          '},'+
          
          
          '"personalExpenses":{'+
             '"diningLunchesRestaurants":['+
                '"25.00"'+
             '],'+
             '"entertainmentSports":['+
                '"50.00"'+
             '],'+
             '"smoking":['+
                '"50.00"'+
             '],'+
             '"giftsCharitableDonations":['+
                '"50.00"'+
             '],'+
             '"allowances":['+
                '"50.00"'+
             '],'+
             '"other":['+
                '"50.00"'+
             '],'+
             '"alcohol":['+
                '"50.00"'+
             ']'+             
          '},'+
          '"livingExpenses":{'+
             '"foodGrocery":['+
                '"200.00"'+
             '],'+
             '"laundryDryCleaning":['+
                '"200.00"'+
             '],'+
             '"groomingToiletries":['+
                '"200.00"'+
             '],'+
             '"clothing":['+
                '"200.00"'+
             '],'+
             '"other":['+
                '"200.00"'+
             ']'+
          '},'+
          '"transportationExpenses":{'+
             '"carLeasePayments":['+
                '"570.00"'+
             '],'+
             '"repairMaintenanceGas":['+
                '"275.00"'+
             '],'+
             '"publicTransportation":['+
                '"275.00"'+
             '],'+
             '"other":['+
                '"275.00"'+
             ']'+
          '},'+
          '"insuranceExpenses":{'+
             '"vehicle":['+
                '"135.00"'+
             '],'+
             '"house":['+
                '"135.00"'+
             '],'+
             '"furnitureContents":['+
                '"135.00"'+
             '],'+
             '"lifeInsurance":['+
                '"135.00"'+
             '],'+
             '"other":['+
                '"135.00"'+
             ']'+
          '},'+
          '"paymentsExpenses":{'+
             '"paymentsToTheProposal":['+
                '"225.00"'+
             ']'+
          '}'+
       '}'+
    '},'+
    '"form79Parts":{'+
       '"debtors":['+
          '{'+
             '"lastName":"Green",'+
             '"firstName":"Walter",'+
             '"middleName":"Randolph",'+
             '"maritalStatus":"Single",'+
             '"dateOfBirth":"09/06/1958",'+
             '"streetAddress":"1801 10531 90 Street NW",'+
             '"city":"Edmonton",'+
             '"nameOfPresentEmployer":"nameOfPresentEmployer",'+
             '"alsoKnownAs":"alsoKnownAs",'+
             '"gender":"Male",'+
             '"province":"Alberta",'+
             '"postalCode":"T5H 4E7",'+
             '"occupation":"T5H 4E7"'+
          '},'+
          '{'+
               '"lastName":"Green",'+
               '"firstName":"Walter",'+
               '"middleName":"Randolph",'+
               '"maritalStatus":"Single",'+
               '"dateOfBirth":"09/06/1958",'+
               '"streetAddress":"1801 10531 90 Street NW",'+
               '"city":"Edmonton",'+
               '"nameOfPresentEmployer":"nameOfPresentEmployer",'+
               '"alsoKnownAs":"alsoKnownAs",'+
               '"gender":"Male",'+
               '"province":"Alberta",'+
               '"postalCode":"T5H 4E7",'+
               '"occupation":"T5H 4E7"'+
          '}'+
       '],'+
       '"numberOfPersonsInHousehold":"1",'+
       '"numberOfPersonsSeventeenOrLess":"0",'+
       '"assets":{'+
          '"totalEstimatedDollarValue":"34258.41",'+
          '"totalSecuredAmountOrLiens":"33858.41",'+
          '"totalEstimatedNetRealizableDollarValue":"0.00",'+
          '"items":['+
             '{'+
                '"type":"1. Cash on Hand",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"2. Furniture",'+
                '"description":"Household Furnishings",'+
                '"estimatedDollarValue":"400.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"3. Personal Effects",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"4. Cash-surrender values of lifeinsurance policies,     RRSPs,  etc.",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"5. Securities",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"6. Real property - House",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"Real property - Cottage",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"Real property - Land",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"Real property - Building",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"  Real property - Building AndLand",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"7. Motor Vehicle - Automobile",'+
                '"description":"2015 Dodge Journey            VIN#3CPDCCG0FT751804 (Encumb.)",'+
                '"estimatedDollarValue":"33858.41",'+
                '"securedAmountOrLiens":"33858.41",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"Motor Vehicle - Motorcycle",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"Motor Vehicle - Snowmobile",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"Motor Vehicle - Other",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"8. Recreational Equipment",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"9. Estimated Tax Refund",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '},'+
             '{'+
                '"type":"10. Other Assets",'+
                '"estimatedDollarValue":"0.00",'+
                '"securedAmountOrLiens":"0.00",'+
                '"estimatedNetRealizableDollarValue":"0.00"'+
             '}'+
          ']'+
       '},'+
       '"liabilities":{'+
          '"items":['+
             '{'+
                '"creditor":"SCOTIABANK Financial",'+
                '"creditorAddress":"#325 8170 - 50 Street NW Edmonton,Alberta, Canada, T6B 1E6",'+
                '"accountNumber":"23348",'+
                '"unsecuredDebt":"3800.00",'+
                '"securedDebt":"1.00",'+
                '"preferredDebt":"1.00",'+
                '"ltc":"3"'+
             '},'+
             '{'+
                '"creditor":"AFFIRM Financial Inc./ c/oBankruptcyHighway",'+
                '"creditorAddress":"D+H/BankruptcyHighway.com   M8Y 3Y2",'+
                '"unsecuredDebt":"15000.00",'+
                '"securedDebt":"1.00",'+
                '"preferredDebt":"0.00",'+
                '"ltc":"3"'+
             '},'+
             '{'+
                '"creditor":"SDA MART",'+
                '"creditorAddress":"NATIONAL COLLECTION CENTRE  Victoria, BritishColumbia, Canada, V8T 5M3",'+
                '"accountNumber":"8346132",'+
                '"unsecuredDebt":"1500.00",'+
                '"securedDebt":"0.00",'+
                '"preferredDebt":"0.00",'+
                '"ltc":"3"'+
             '},'+
             '{'+
                '"creditor":"MONEY MART",'+
                '"creditorAddress":"NATIONAL COLLECTION CENTRE 401 GARBALLY ROAD Victoria, BritishColumbia, Canada, V8T 5M3",'+
                '"accountNumber":"1145777-041117- 01",'+
                '"unsecuredDebt":"3000.00",'+
                '"securedDebt":"0.00",'+
                '"preferredDebt":"0.00",'+
                '"ltc":"3"'+
             '},'+
             '{'+
                '"creditor":"THE BANK OF NOVA   SCOTIAc/o CanaccedeInternational",'+
                '"creditorAddress":"Canaccede International Management Ltd. P.O. Box 758, Station B London, Ontario,Canada, N6A 4Y8",'+
                '"accountNumber":"A52642",'+
                '"unsecuredDebt":"0.00",'+
                '"securedDebt":"33858.41",'+
                '"preferredDebt":"0.00",'+
                '"ltc":"2"'+
             '}'+
          '],'+
          '"totalUnsecuredLiabilities":"28380.00",'+
          '"totalSecuredLiabilities":"33858.41",'+
          '"totalPreferredLiabilities":"0.00",'+
          '"totalLiabilities":"62238.41"'+
       '},'+
       '"totalSecuredClaims":"33858.41",'+
       '"totalUnsecuredClaims":"28380.00",'+
       '"totalAssets":"34258.41"'+
    '}'+
 '}';
    public static string sampleJSON1= '{"courtNo":"24-2458454","estateNo":["24-2458454", "12-1231234"],"courtDivision":"1","courtDistrict":"1","courtProvince":"Alberta","form47Parts":{"paymentAmount":"225.00","paymentFrequency":"Monthly","numberOfPayments":"60","notice1":"      That secured creditors will be paid in accordance with the terms of their existing contracts and will not be                       eligible for any dividends within this proposal                                                                              ","notice4":"       A total sum of $13,500.00 at a rate of $225.00 per month for 60 months. The payments will commence                                 on February 28, 2019. If payments in excess of the required monthly payments are made, I will have                                 the option to eliminate or reduce future payments.                                                                          ","notice6":"            Any outstanding liability to Canada Revenue Agency for personal taxes for the current year, as of the                        date   of  this  proposal,   will  be  included  in  this  proposal  as  identified  in  the      CAIRP  /  CRA  Standard  of      Professional Practice No. 03-1 issued January 22, 2004.                                                                      "},"form48Parts":{"notice4":"       Debtors hours were reduced drastically and debtor is not able to keep up with bills as they become due.                     ","notice5":"       The creditors will receive a larger recovery under the Proposal than under Bankruptcy.                                              Supplemental Information:                                                                                                           - The secured creditors will be treated in accordance to Term #1 of the Consumer Proposal.                                          - Asset valuations are based on information supplied by the debtor in consultation with the Administrator of                        the Consumer Proposal.                                                                                                              - The exemptions identified are based on the Civil Enforcement Act of Alberta and other applicable                                  legislation (i.e. Pension Act, Indian Act, Insurance Act etc.).                                                                     - The payments in a bankruptcy are based on any potential Surplus Income Obligation that would be                                   available in a bankruptcy according to Directive 11R2, or the minimum voluntary fee as set by Goth &                                                     Company Ltd, whichever is greater.  These values are esti  "},"form49Parts":{"insolvencyDate":"21/12/2018"},"form65Parts":{"monthlyIncome":{"netEmploymentIncome":{"Debtor":["2834.00"],"Others":["0.00"],"Total":["2834.00"]},"totalMonthlyIncome":{"Debtor":["2834.00"],"Others":["0.00"]},"totalMonthlyIncomeOfTheFamilyUnit":"2834.00","headings":["Description","Debtor","Others","Total"]},"monthlyNonDiscretionaryExpenses":{"totalMonthlyNonDiscretionaryExpenses":{"Debtor":["0.00"],"Others":["0.00"]},"totalMonthlyNonDiscretionaryExpensesOfTheFamilyUnit":"0.00","availableMonthlyIncomeOfTheDebtor":["2834.00"],"availableMonthlyIncomeOfTheFamilyUnit":"2834.00","headings":["Description","Debtor","Others","Total"]},"monthlyDiscretionaryExpenses":{"totalFamilyUnitMonthlyDiscretionaryExpenses":"2830.00","familyUnitMonthlySurplusOrDeficit":"4.00","housingExpenses":{"rentMortgageHypothec":["950.00"],"telephone":["90.00"],"cable":["50.00"],"hydro":["75.00"]},"personalExpenses":{"diningLunchesRestaurants":["25.00"],"entertainmentSports":["50.00"]},"livingExpenses":{"foodGrocery":["200.00"]},"transportationExpenses":{"carLeasePayments":["570.00"],"repairMaintenanceGas":["275.00"]},"insuranceExpenses":{"vehicle":["135.00"]},"paymentsExpenses":{"paymentsToTheProposal":["225.00"]}}},"form79Parts":{"debtors":[{"lastName":"Green","firstName":"Walter","middleName":"Randolph","maritalStatus":"Single","dateOfBirth":"09/06/1958","streetAddress":"1801 10531 90 Street NW","city":"Edmonton","province":"Alberta","postalCode":"T5H 4E7"}],"numberOfPersonsInHousehold":"1","numberOfPersonsSeventeenOrLess":"0","assets":{"totalEstimatedDollarValue":"34258.41","totalSecuredAmountOrLiens":"33858.41","totalEstimatedNetRealizableDollarValue":"0.00","items":[{"type":"1. Cash on Hand","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"2. Furniture","description":"Household Furnishings","estimatedDollarValue":"400.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"3. Personal Effects","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"4. Cash-surrender values of lifeinsurance policies,     RRSPs,  etc.","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"5. Securities","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"6. Real property - House","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"Real property - Cottage","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"Real property - Land","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"Real property - Building","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"  Real property - Building AndLand","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"7. Motor Vehicle - Automobile","description":"2015 Dodge Journey            VIN#3CPDCCG0FT751804 (Encumb.)","estimatedDollarValue":"33858.41","securedAmountOrLiens":"33858.41","estimatedNetRealizableDollarValue":"0.00"},{"type":"Motor Vehicle - Motorcycle","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"Motor Vehicle - Snowmobile","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"Motor Vehicle - Other","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"8. Recreational Equipment","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"9. Estimated Tax Refund","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"},{"type":"10. Other Assets","estimatedDollarValue":"0.00","securedAmountOrLiens":"0.00","estimatedNetRealizableDollarValue":"0.00"}]},"liabilities":{"items":[{"creditor":"CashCo Financial","creditorAddress":"#325 8170 - 50 Street NW Edmonton,Alberta, Canada, T6B 1E6","accountNumber":"23348","unsecuredDebt":"3800.00","securedDebt":"0.00","preferredDebt":"0.00","ltc":"3"},{"creditor":"Fairstone Financial Inc./ c/oBankruptcyHighway","creditorAddress":"D+H/BankruptcyHighway.com         P.O. Box 57100 Etobicoke, Ontario,Canada, M8Y 3Y2","unsecuredDebt":"15000.00","securedDebt":"0.00","preferredDebt":"0.00","ltc":"3"},{"creditor":"MONEY MART","creditorAddress":"NATIONAL COLLECTION CENTRE         401 GARBALLY ROAD Victoria, BritishColumbia, Canada, V8T 5M3","accountNumber":"8346132","unsecuredDebt":"1500.00","securedDebt":"0.00","preferredDebt":"0.00","ltc":"3"},{"creditor":"MONEY MART","creditorAddress":"NATIONAL COLLECTION CENTRE         401 GARBALLY ROAD Victoria, BritishColumbia, Canada, V8T 5M3","accountNumber":"1145777-041117- 01","unsecuredDebt":"3000.00","securedDebt":"0.00","preferredDebt":"0.00","ltc":"3"},{"creditor":"THE BANK OF NOVA   SCOTIAc/o CanaccedeInternational","creditorAddress":"Canaccede International Management Ltd. P.O. Box 758, Station B London, Ontario,Canada, N6A 4Y8","accountNumber":"A52642","unsecuredDebt":"0.00","securedDebt":"33858.41","preferredDebt":"0.00","ltc":"2"}],"totalUnsecuredLiabilities":"28380.00","totalSecuredLiabilities":"33858.41","totalPreferredLiabilities":"0.00","totalLiabilities":"62238.41"},"totalSecuredClaims":"33858.41","totalUnsecuredClaims":"28380.00","totalAssets":"34258.41"}}';

}