/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class is integration layer for the Voting Automation functionality
 *  @author : A5E Consulting
 *  @date : 04/30/2020
 *
 *************************************************************************************************/
public with sharing class VotingEngineClient {
    public static String reason = 'PAST_REVIEW_PERIOD';
    //This submit method is for call to Voting Automation Engine
    public static VotingEngineClientUtil.ParsedResponse submit(Insolvency__c insolvencyRecord) {
        //Fetch details for Voting Automation Engine API Call
        API_Call_Details__c docParseApi = [
            SELECT AuthorizationtUrl__c, Client_ID__c, Client_Secret__c, Proxy_Client_ID__c, Tenand_ID__c, PDF_API_URL__c
            FROM API_Call_Details__c
            WHERE Name = 'Voting Automation API'
        ];

        String tenandId = docParseApi.Tenand_ID__c;
        String proxyClientId = docParseApi.Proxy_Client_ID__c;
        String clientId = docParseApi.Client_ID__c;
        String clientSecret = docParseApi.Client_Secret__c;
        String authorizationtUrl = docParseApi.AuthorizationtUrl__c;
        String votingAutomationURL = docParseApi.PDF_API_URL__c;

        VotingEngineClientUtil.ParsedResponse parsedResponse = new VotingEngineClientUtil.ParsedResponse();

        //generate autherization URL and parameters
        authorizationtUrl = authorizationtUrl.replace('{{dptenandId}}', tenandId);
        String bodyParams = 'client_id=' + clientId;
        bodyParams = bodyParams + '&client_secret=' + clientSecret;
        bodyParams = bodyParams + '&scope=' + 'api://' + proxyClientId + '/.default';
        bodyParams = bodyParams + '&grant_type=client_credentials';
        String accessToken;

        // Get access token by authenticating using key parameters
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);

        HTTPResponse res = http.send(req);
        Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        accessToken = (String) resJson.get('access_token');

        // Send JSON to Voting Automation engine
        HttpRequest votingAutomationApiReq = new HttpRequest();
        votingAutomationApiReq.setEndpoint(votingAutomationURL);
        votingAutomationApiReq.setMethod('POST');
        votingAutomationApiReq.setHeader('Content-Type', 'application/json');
        votingAutomationApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        votingAutomationApiReq.setBody(createJSON(insolvencyRecord));
        votingAutomationApiReq.setTimeout(90000);
        HTTPResponse res2 = new HttpResponse();

        parsedResponse.resultString = '';

        try {
            parsedResponse.request = votingAutomationApiReq.getBody();
            res2 = http.send(votingAutomationApiReq);
            //Store request and response
            parsedResponse.response = res2.getBody();
            //check if webservice reply is success
            if (res2.getStatusCode() == 200) {
                // Check if web service returned error
                VotingEngineClientUtil.ErrorResponse errorResponse = (VotingEngineClientUtil.ErrorResponse) JSON.deserialize(
                    res2.getBody(),
                    VotingEngineClientUtil.ErrorResponse.class
                );
                if (errorResponse?.LeExtendedResults != null && errorResponse.LeExtendedResults.status == '500') {
                    parsedResponse.votingStatus = 'System Error';
                    parsedResponse.resultString = 'Error: ' + errorResponse.LeExtendedResults.title;
                    return parsedResponse;
                }
                //get response
                parsedResponse = parseResponse(res2.getBody(), parsedResponse);
            } else {
                //failed to vote
                parsedResponse.votingStatus = 'System Error';
                parsedResponse.resultString = 'Unsuccessful voting';
            }
        } catch (Exception e) {
            // exception generated
            parsedResponse.votingStatus = 'System Error';
            parsedResponse.resultString = 'Unsuccessful voting - ' + e.getMessage();
        }
        return parsedResponse;
    }

    public static String createJSON(Insolvency__c insolvencyRecord) {
        VotingEngineClientUtil.WebServiceRequestJSONObject WebServiceRequestJSONRecord = new VotingEngineClientUtil.WebServiceRequestJSONObject();

        WebServiceRequestJSONRecord.numberOfPersonsInHousehold = Integer.valueof(insolvencyRecord.Number_Of_Persons_In_Household__c) != null
            ? Integer.valueof(insolvencyRecord.Number_Of_Persons_In_Household__c)
            : 0;
        WebServiceRequestJSONRecord.numberOfPersonsSeventeenOrLess = Integer.valueof(insolvencyRecord.Number_Of_Persons_In_Household_Below_17__c) != null
            ? Integer.valueof(insolvencyRecord.Number_Of_Persons_In_Household_Below_17__c)
            : 0;
        WebServiceRequestJSONRecord.foodAmount = insolvencyRecord.Food_Grocery_Expenses__c != null ? insolvencyRecord.Food_Grocery_Expenses__c : 0;
        WebServiceRequestJSONRecord.entertainmentAmount = insolvencyRecord.Entertainment_Sports_Expenses__c != null
            ? insolvencyRecord.Entertainment_Sports_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.giftsCharitableDonationsAmount = insolvencyRecord.Gifts_Charitable_Expenses__c != null
            ? insolvencyRecord.Gifts_Charitable_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.allowancesAmount = insolvencyRecord.Allowances_Expenses__c != null ? insolvencyRecord.Allowances_Expenses__c : 0;
        WebServiceRequestJSONRecord.diningAmount = insolvencyRecord.Dining_Expenses__c != null ? insolvencyRecord.Dining_Expenses__c : 0;
        WebServiceRequestJSONRecord.laundryAmount = insolvencyRecord.Laundry_Dry_Cleaning_Expenses__c != null
            ? insolvencyRecord.Laundry_Dry_Cleaning_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.groomingAmount = insolvencyRecord.Grooming_Toiletries_Expenses__c != null
            ? insolvencyRecord.Grooming_Toiletries_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.clothingAmount = insolvencyRecord.Clothing_Expenses__c != null ? insolvencyRecord.Clothing_Expenses__c : 0;
        WebServiceRequestJSONRecord.incomeAmount = insolvencyRecord.Total_Monthly_Income_Of_Family__c != null
            ? insolvencyRecord.Total_Monthly_Income_Of_Family__c
            : 0;
        WebServiceRequestJSONRecord.familyUnitMonthlySurplusOrDeficit = insolvencyRecord.Monthly_Surplus_Deficit_Of_Family__c != null
            ? insolvencyRecord.Monthly_Surplus_Deficit_Of_Family__c
            : 0;
        WebServiceRequestJSONRecord.numberOfPayments = Integer.valueof(insolvencyRecord.Number_of_Payments__c) != null
            ? Integer.valueof(insolvencyRecord.Number_of_Payments__c)
            : 0;
        WebServiceRequestJSONRecord.otherExpenditureAmount = insolvencyRecord.Non_Discretionary_Other_Expenditure__c != null
            ? insolvencyRecord.Non_Discretionary_Other_Expenditure__c
            : 0;
        WebServiceRequestJSONRecord.deathClauses = convertToList(insolvencyRecord.Death_Clause__c);
        WebServiceRequestJSONRecord.acceleratedClauses = convertToList(insolvencyRecord.Acceleration_Clause__c);

        if (insolvencyRecord.Trustee_Comments_Notes__c != null) {
            String trustee = insolvencyRecord.Trustee_Comments_Notes__c;
            String normalized = trustee.normalizeSpace();
            WebServiceRequestJSONRecord.trusteeNotes = convertToList(normalized);
        }

        //Send additional fields to insolvency voting engine - This are the updated for voting engine enhancement requirement.
        if (insolvencyRecord.Debtor_1_Mailing_State_Province__c != null) {
            WebServiceRequestJSONRecord.province = getProvince(insolvencyRecord.Debtor_1_Mailing_State_Province__c);
        }
        WebServiceRequestJSONRecord.debtorAge = Integer.valueof(insolvencyRecord.Debtor_Age__c) != null ? Integer.valueof(insolvencyRecord.Debtor_Age__c) : 0;
        WebServiceRequestJSONRecord.dateProcessed = insolvencyRecord.Insolvency_Created_Date__c;
        WebServiceRequestJSONRecord.estateNumber = String.valueof(insolvencyRecord.Name);
        WebServiceRequestJSONRecord.totalUnsecuredDebt = insolvencyRecord.Total_Unsecured_Liabilities_Clc__c != null
            ? insolvencyRecord.Total_Unsecured_Liabilities_Clc__c
            : 0;
        WebServiceRequestJSONRecord.securedDebtsUnsecuredPortion = insolvencyRecord.Secured_Debts_Unsecured_Portion__c != null
            ? insolvencyRecord.Secured_Debts_Unsecured_Portion__c
            : 0;
        WebServiceRequestJSONRecord.bulkPaymentAmount = insolvencyRecord.Bulk_Payment_Amount__c != null ? insolvencyRecord.Bulk_Payment_Amount__c : 0;
        WebServiceRequestJSONRecord.monthlyPaymentOffered = insolvencyRecord.Payment_Amount__c != null ? insolvencyRecord.Payment_Amount__c : 0;
        WebServiceRequestJSONRecord.totalEstimatedRealizableValue = insolvencyRecord.Total_Estimated_Realizable_Value__c != null
            ? insolvencyRecord.Total_Estimated_Realizable_Value__c
            : 0;
        WebServiceRequestJSONRecord.isSpouseDisclosingIncome = insolvencyRecord.Is_Spouse_Disclosing_Income__c;
        WebServiceRequestJSONRecord.availableMonthlyIncomeOfFamily = insolvencyRecord.Available_Monthly_Income_Of_Family__c != null
            ? insolvencyRecord.Available_Monthly_Income_Of_Family__c
            : 0;
        WebServiceRequestJSONRecord.debtorPortionOfMonthlyIncome = insolvencyRecord.Debtor_Portion_Of_Monthly_Income__c != null
            ? insolvencyRecord.Debtor_Portion_Of_Monthly_Income__c / 100
            : 0;
        WebServiceRequestJSONRecord.everBeenBankruptBefore = insolvencyRecord.Ever_been_Bankrupt_Before__c != null &&
            insolvencyRecord.Ever_been_Bankrupt_Before__c == 'Yes'
            ? true
            : false;
        //WebServiceRequestJSONRecord.otherExpenses = insolvencyRecord.Other_Expenses__c != null ? insolvencyRecord.Other_Expenses__c : 0;
        //WebServiceRequestJSONRecord.budgetarySurplusDeficit = insolvencyRecord.Budgetary_Surplus_Deficit__c != null ? insolvencyRecord.Budgetary_Surplus_Deficit__c : 0;
        WebServiceRequestJSONRecord.otherHousingExpensesAmount = insolvencyRecord.Other_Housing_Expenses__c != null
            ? insolvencyRecord.Other_Housing_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.otherPersonalExpensesAmount = insolvencyRecord.Other_Personal_Expenses__c != null
            ? insolvencyRecord.Other_Personal_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.otherMedicalExpensesAmount = insolvencyRecord.Other_Medical_Expenses__c != null
            ? insolvencyRecord.Other_Medical_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.otherLivingExpensesAmount = insolvencyRecord.Other_Living_Expenses__c != null
            ? insolvencyRecord.Other_Living_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.otherTransportationExpensesAmount = insolvencyRecord.Other_TransportationExpenses__c != null
            ? insolvencyRecord.Other_TransportationExpenses__c
            : 0;
        WebServiceRequestJSONRecord.otherInsuranceExpensesAmount = insolvencyRecord.Other_Insurance_Expenses__c != null
            ? insolvencyRecord.Other_Insurance_Expenses__c
            : 0;
        WebServiceRequestJSONRecord.otherPaymentsAmount = insolvencyRecord.Other_Payments__c != null ? insolvencyRecord.Other_Payments__c : 0;
        if (insolvencyRecord.Insolvency_Date__c != null) {
            WebServiceRequestJSONRecord.insolvencyDate = insolvencyRecord.Insolvency_Date__c;
        }
        WebServiceRequestJSONRecord.telephone = insolvencyRecord.Telephone_Expenses__c != null ? insolvencyRecord.Telephone_Expenses__c : 0;
        WebServiceRequestJSONRecord.internet = insolvencyRecord.Internet_Expenses__c != null ? insolvencyRecord.Internet_Expenses__c : 0;
        WebServiceRequestJSONRecord.cable = insolvencyRecord.Cable_Expenses__c != null ? insolvencyRecord.Cable_Expenses__c : 0;
        WebServiceRequestJSONRecord.hydro = insolvencyRecord.Hydro_Expenses__c != null ? insolvencyRecord.Hydro_Expenses__c : 0;
        WebServiceRequestJSONRecord.heatingGasOil = insolvencyRecord.Heating_Gas_Oil_Expenses__c != null ? insolvencyRecord.Heating_Gas_Oil_Expenses__c : 0;
        WebServiceRequestJSONRecord.water = insolvencyRecord.Water_Expenses__c != null ? insolvencyRecord.Water_Expenses__c : 0;
        WebServiceRequestJSONRecord.smoking = insolvencyRecord.Smoking_Expenses__c != null ? insolvencyRecord.Smoking_Expenses__c : 0;
        WebServiceRequestJSONRecord.alcohol = insolvencyRecord.Alcohol_Expenses__c != null ? insolvencyRecord.Alcohol_Expenses__c : 0;
        WebServiceRequestJSONRecord.carLeasePayments = insolvencyRecord.Car_Lease_Payments_Expenses__c != null ? insolvencyRecord.Car_Lease_Payments_Expenses__c : 0;
        WebServiceRequestJSONRecord.repairMaintenanceGas = insolvencyRecord.Repair_Maintenance_Gas_Expenses__c != null ? insolvencyRecord.Repair_Maintenance_Gas_Expenses__c : 0;
        WebServiceRequestJSONRecord.publicTransportation = insolvencyRecord.Public_Transportation_Expenses__c != null ? insolvencyRecord.Public_Transportation_Expenses__c : 0;
        String returnJSONString = JSON.serialize(WebServiceRequestJSONRecord, true);
        return returnJSONString;
    }

    static List<String> convertToList(String stringValue) {
        List<String> listString = new List<String>();
        listString.add(stringValue);
        return listString;
    }

    public static VotingEngineClientUtil.ParsedResponse parseResponse(String response, VotingEngineClientUtil.ParsedResponse parsedResponse) {
        Map<String, Voting_Automation_Reason_Mapping__c> reasonMapping = Voting_Automation_Reason_Mapping__c.getall();
        VotingEngineClientUtil.WebServiceResponse webServiceResponseValue = new VotingEngineClientUtil.WebServiceResponse();
        webServiceResponseValue = webServiceResponseValue.parse(response);
        Boolean successfulVoting = true;
        parsedResponse.resultString = '';

        if (webServiceResponseValue?.dRejection != null && webServiceResponseValue.dRejection.size() > 0) {
            parsedResponse.votingStatus = 'Needs Manual Review';

            for (VotingEngineClientUtil.dRejection val : webServiceResponseValue.dRejection) {
                if (val?.reasonCode != null) {
                    if (reasonMapping.get(val.reasonCode) != null) {
                        parsedResponse.resultString += reasonMapping.get(val.reasonCode).Value__c;
                    } else {
                        parsedResponse.resultString += val.reasonCode;
                    }
                    if (val?.diagnosticInfo != null) {
                        //parsedResponse.resultString += ':=' + val.diagnosticInfo;
                    }
                    parsedResponse.resultString += '\r\n';
                }
            }

            successfulVoting = false;
        }

        //Populating Notes for salesforce field
        if (webServiceResponseValue?.dRejection != null && webServiceResponseValue.dRejection.size() > 0) {
            VotingEngineClientUtil.vExtendedResults leExtendedResults = webServiceResponseValue.vExtendedResults;
            parsedResponse.notesForSalesforce = '';
            for (VotingEngineClientUtil.dRejection val : webServiceResponseValue.dRejection) {
                if (val?.reasonCode != null) {
                    if (reasonMapping.get(val.reasonCode) != null) {
                        parsedResponse.notesForSalesforce += reasonMapping.get(val.reasonCode).Value__c + ' ' + ' ';

                        if (val?.difference != null) {
                            parsedResponse.notesForSalesforce += 'by' + ' ' + val.difference + '\n';
                        }
                    } else {
                        parsedResponse.notesForSalesforce += val.reasonCode + ' ' + ' ' + 'by' + ' ' + val.difference + '\n';
                    }
                    if (val?.diagnosticInfo != null) {
                        //parsedResponse.resultString += ':=' + val.diagnosticInfo;
                    }
                    parsedResponse.resultString += '\r\n';
                }
            }

            if (leExtendedResults.counterWithBKInsteadOfCP == true) {
                parsedResponse.notesForSalesforce += 'BK recovery is higher than the CP';
            }
        }

        if (webServiceResponseValue?.dValidationErrors != null && webServiceResponseValue.dValidationErrors.size() > 0) {
            parsedResponse.votingStatus = 'Needs Manual Review';

            for (VotingEngineClientUtil.dValidationErrors val : webServiceResponseValue.dValidationErrors) {
                if (val?.reasonCode != null) {
                    if (reasonMapping.get(val.reasonCode) != null) {
                        parsedResponse.resultString += reasonMapping.get(val.reasonCode).Value__c;
                    } else {
                        parsedResponse.resultString += val.reasonCode;
                    }
                    parsedResponse.resultString += '\r\n';
                }
            }

            successfulVoting = false;
        }

        // Parse the voting engine respone. - This are the updated for voting engine enhancement requirement.
        if (webServiceResponseValue?.vExtendedResults != null) {
            VotingEngineClientUtil.vExtendedResults leExtendedResults = webServiceResponseValue.vExtendedResults;

            if (leExtendedResults?.proposedMonthlyPayment != null) {
                VotingEngineClientUtil.proposedMonthlyPayment leExtendedResults1 = leExtendedResults.proposedMonthlyPayment;

                if (leExtendedResults1?.amount != null) {
                    parsedResponse.proposedMonthlyPayment = leExtendedResults1.amount;
                }
            }
            if (leExtendedResults?.bkDuration != null) {
                parsedResponse.bkDuration = leExtendedResults.bkDuration;
            }
            if (leExtendedResults?.shouldWeFurtherCounterWithBK != null) {
                parsedResponse.ShouldWeFurtherCounterWithBK = leExtendedResults.shouldWeFurtherCounterWithBK;
            }
            if (leExtendedResults?.counterWithBKInsteadOfCP != null) {
                parsedResponse.counterWithBKInsteadOfCP = leExtendedResults.counterWithBKInsteadOfCP;
            }
            if (leExtendedResults?.maxCounterMonthlyPayment != null) {
                VotingEngineClientUtil.maxCounterMonthlyPayment maxCounterMonthlyPaymentData = leExtendedResults.maxCounterMonthlyPayment;

                if (maxCounterMonthlyPaymentData?.amount != null) {
                    parsedResponse.maxCounterMonthlyPayment = maxCounterMonthlyPaymentData.amount;
                }
            }
            if (leExtendedResults?.totalPayoutOffered != null) {
                VotingEngineClientUtil.totalPayoutOffered totalPayoutOfferedData = leExtendedResults.totalPayoutOffered;

                if (totalPayoutOfferedData?.amount != null) {
                    parsedResponse.totalPayoutOffered = totalPayoutOfferedData.amount;
                }
                if (totalPayoutOfferedData?.totalReturn != null) {
                    parsedResponse.totalPayoutOfferedTR = totalPayoutOfferedData.totalReturn;
                }
                if (totalPayoutOfferedData?.adjustedReturn != null) {
                    parsedResponse.totalPayoutOfferedAR = totalPayoutOfferedData.adjustedReturn;
                }
            }
            if (leExtendedResults?.acceptableMonthlyPayment != null) {
                VotingEngineClientUtil.acceptableMonthlyPayment acceptableMonthlyPaymentData = leExtendedResults.acceptableMonthlyPayment;

                if (acceptableMonthlyPaymentData?.amount != null) {
                    parsedResponse.acceptableMonthlyPayment = acceptableMonthlyPaymentData.amount;
                }
            }
            if (leExtendedResults?.bkNetPayout != null) {
                VotingEngineClientUtil.bkNetPayout bkNetPayoutData = leExtendedResults.bkNetPayout;
                if (bkNetPayoutData.amount != null) {
                    parsedResponse.bkNetPayout = bkNetPayoutData.amount;
                }
                if (bkNetPayoutData?.totalReturn != null) {
                    parsedResponse.bkNetPayoutTR = bkNetPayoutData.totalReturn;
                }
                if (bkNetPayoutData?.adjustedReturn != null) {
                    parsedResponse.bkNetPayoutAR = bkNetPayoutData.adjustedReturn;
                }
            }
            if (leExtendedResults?.maxCounterPayout != null) {
                VotingEngineClientUtil.maxCounterPayout maxCounterPayoutData = leExtendedResults.maxCounterPayout;

                if (maxCounterPayoutData?.amount != null) {
                    parsedResponse.maxCounterPayout = maxCounterPayoutData.amount;
                }
                if (maxCounterPayoutData?.totalReturn != null) {
                    parsedResponse.maxCounterPayoutTR = maxCounterPayoutData.totalReturn;
                }
                if (maxCounterPayoutData?.adjustedReturn != null) {
                    parsedResponse.maxCounterPayoutAR = maxCounterPayoutData.adjustedReturn;
                }
            }
            if (leExtendedResults?.surplusIncomePayments != null) {
                VotingEngineClientUtil.surplusIncomePayments surplusIncomePaymentsData = leExtendedResults.surplusIncomePayments;
                if (surplusIncomePaymentsData?.amount != null) {
                    parsedResponse.surplusIncomePayments = surplusIncomePaymentsData.amount;
                }
            }
            if (leExtendedResults?.proposedCounterPayout != null) {
                VotingEngineClientUtil.proposedCounterPayout proposedCounterPayoutData = leExtendedResults.proposedCounterPayout;

                if (proposedCounterPayoutData?.amount != null) {
                    parsedResponse.proposedCounterPayout = proposedCounterPayoutData.amount;
                }
                if (proposedCounterPayoutData?.totalReturn != null) {
                    parsedResponse.proposedCounterPayoutTR = proposedCounterPayoutData.totalReturn;
                }
                if (proposedCounterPayoutData?.adjustedReturn != null) {
                    parsedResponse.proposedCounterPayoutAR = proposedCounterPayoutData.adjustedReturn;
                }
            }
            if (leExtendedResults?.adjustedUnsecuredDebt != null) {
                VotingEngineClientUtil.adjustedUnsecuredDebt adjustedUnsecuredDebtData = leExtendedResults.adjustedUnsecuredDebt;

                if (adjustedUnsecuredDebtData?.amount != null) {
                    parsedResponse.adjustedUnsecuredDebt = adjustedUnsecuredDebtData.amount;
                }
            }
            if (leExtendedResults?.minAcceptablePayout != null) {
                VotingEngineClientUtil.minAcceptablePayout minAcceptablePayoutData = leExtendedResults.minAcceptablePayout;

                if (minAcceptablePayoutData?.amount != null) {
                    parsedResponse.minAcceptablePayout = minAcceptablePayoutData.amount;
                }
                if (minAcceptablePayoutData?.totalReturn != null) {
                    parsedResponse.minAcceptablePayoutTR = minAcceptablePayoutData.totalReturn;
                }
                if (minAcceptablePayoutData?.adjustedReturn != null) {
                    parsedResponse.minAcceptablePayoutAR = minAcceptablePayoutData.adjustedReturn;
                }
            }
            if (leExtendedResults?.cpNetPayout != null) {
                VotingEngineClientUtil.cpNetPayout cpNetPayoutData = leExtendedResults.cpNetPayout;

                if (cpNetPayoutData?.amount != null) {
                    parsedResponse.cpNetPayout = cpNetPayoutData.amount;
                }
                if (cpNetPayoutData?.totalReturn != null) {
                    parsedResponse.cpNetPayoutTR = cpNetPayoutData.totalReturn;
                }
                if (cpNetPayoutData?.adjustedReturn != null) {
                    parsedResponse.cpNetPayoutAR = cpNetPayoutData.adjustedReturn;
                }
            }
        }

        if (successfulVoting == true) {
            parsedResponse.votingStatus = 'Auto Approved';
            parsedResponse.autoApprovedReason = '';
        } else {
            for (VotingEngineClientUtil.dRejection val : webServiceResponseValue.dRejection) {
                if (val?.reasonCode != null) {
                    if (val.reasonCode == reason) {
                        parsedResponse.votingStatus = 'Auto Approved';
                        parsedResponse.autoApprovedReason = 'Auto Approved - Past 45 days';
                    } else {
                        parsedResponse.autoApprovedReason = '';
                    }
                }
            }
        }

        return parsedResponse;
    }

    // Province name and code map - These are the updated for voting engine enhancement requirement.
    public static Map<String, String> provinceMap = new Map<String, String>{
        'BRITISH COLUMBIA' => 'BC',
        'MANITOBA' => 'MB',
        'NEW BRUNSWICK' => 'NB',
        'NEWFOUNDLAND AND LABRADOR' => 'NL',
        'NORTHWEST TERRITORIES' => 'NT',
        'NOVA SCOTIA' => 'NS',
        'NUNAVUT' => 'NU',
        'ONTARIO' => 'ON',
        'PRINCE EDWARD ISLAND' => 'PE',
        'QUEBEC' => 'QC',
        'SASKATCHEWAN' => 'SK',
        'YUKON' => 'YT',
        'NEWFOUNDLAND & LABRADOR' => 'NL',
        'ALBERTA' => 'AB'
    };

    // Replace provice name with province code and send to voting engine. - These are the updated for voting engine enhancement requirement.
    public static String getProvince(String province) {
        province = province.toUpperCase();

        if (provinceMap.containsKey(province)) {
            return provinceMap.get(province);
        } else {
            return null;
        }
    }
}
