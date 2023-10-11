/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is utility class for VotingEngineClient class
*  @author : A5E Consulting
*  @date : 04/30/2020   
*
*************************************************************************************************/
public with sharing class VotingEngineClientUtil{
    
    //This inner class will be used for the request JSON
    public class WebServiceRequestJSONObject{
        Public Integer numberOfPersonsInHousehold = 0;
        Public Integer numberOfPersonsSeventeenOrLess = 0;
        Public Decimal foodAmount = 0.0;
        Public Decimal entertainmentAmount = 0.0;
        Public Decimal giftsCharitableDonationsAmount = 0.0;
        Public Decimal allowancesAmount = 0.0;
        Public Decimal diningAmount = 0.0;
        Public Decimal laundryAmount = 0.0;
        Public Decimal groomingAmount = 0.0;
        Public Decimal clothingAmount = 0.0;
        Public Decimal incomeAmount = 0.0;
        Public Decimal familyUnitMonthlySurplusOrDeficit = 0.0;
        Public Integer numberOfPayments = 0;
        Public Decimal otherExpenditureAmount = 0.0;
        Public List<String> deathClauses = null;
        Public List<String> acceleratedClauses = null;
        Public List<String> trusteeNotes = null;
        
        // store additional request JSON - This are the updated for voting engine enhancement requirement.
        Public Integer debtorAge = 0;
        Public String province = null;
        Public date dateProcessed = null;
        Public String estateNumber = null;
        Public Decimal totalUnsecuredDebt = 0.0;
        Public Decimal bulkPaymentAmount = 0.0;
        Public Decimal securedDebtsUnsecuredPortion = 0.0;
        Public Decimal totalEstimatedRealizableValue = 0.0;
        Public Boolean isSpouseDisclosingIncome = null;
        Public Decimal availableMonthlyIncomeOfFamily = 0.0;
        Public Decimal debtorPortionOfMonthlyIncome = 0.0;
        Public Boolean everBeenBankruptBefore = null;
        Public Decimal monthlyPaymentOffered = 0.0;
        Public Decimal otherHousingExpensesAmount = 0.0;
        Public Decimal otherPersonalExpensesAmount = 0.0;
        Public Decimal otherMedicalExpensesAmount = 0.0;
        Public Decimal otherLivingExpensesAmount = 0.0;
        Public Decimal otherTransportationExpensesAmount = 0.0;
        Public Decimal otherInsuranceExpensesAmount = 0.0;
        Public Decimal otherPaymentsAmount = 0.0;
        Public date insolvencyDate = null;
        
        public WebServiceRequestJSONObject parse(String json) {
            return (WebServiceRequestJSONObject) System.JSON.deserialize(json, WebServiceRequestJSONObject.class);
        }
    }
    
    //This inner class will be used for the response JSON
    public class WebServiceResponse{
        public List<DRejection> dRejection = null;
        public List<dResults> dResults = null;
        public List<dValidationErrors> dValidationErrors = null;
        
        
        //This are the updated for voting engine enhancement requirement.
        
        public vExtendedResults vExtendedResults = null;
        
        public WebServiceResponse parse(String json) {
            //Added try-catch blocks for #5137
            try{
            return (WebServiceResponse) System.JSON.deserialize(json, WebServiceResponse.class);
            }
            catch(Exception e){
                API_Error__c apiError=new API_Error__c();
                apiError.Error__c=e.getMessage();
                apiError.response__c=json;
                insert apiError;
               return null; 
            }
        }
    }
    
    public class DRejection {
        public String reasonCode;
        public String diagnosticInfo;
        public String difference;
    }
    
    public class dResults{
        public String rejected;
        public Boolean result;
    }
    
    public class dValidationErrors{
        public String reasonCode;
    }
    
    //This are the updated for voting engine enhancement requirement.
    public class vExtendedResults{
        
        public Integer bkDuration;
        public Boolean counterWithBKInsteadOfCP;
        public Boolean ShouldWeFurtherCounterWithBK;
        
        public proposedMonthlyPayment proposedMonthlyPayment = null;
        public maxCounterMonthlyPayment maxCounterMonthlyPayment = null;
        public totalPayoutOffered totalPayoutOffered = null; 
        public acceptableMonthlyPayment acceptableMonthlyPayment = null;
        public bkNetPayout bkNetPayout = null;
        public maxCounterPayout maxCounterPayout = null;
        public proposedCounterPayout proposedCounterPayout = null;
        public adjustedUnsecuredDebt adjustedUnsecuredDebt = null;
        public minAcceptablePayout minAcceptablePayout= null;
        public cpNetPayout cpNetPayout = null;
        public surplusIncomePayments surplusIncomePayments = null;
        
        
    }
   
    public class proposedMonthlyPayment{
        public Decimal amount;
    }
    public class maxCounterMonthlyPayment{
        public Decimal amount;
    }
    public class totalPayoutOffered{
        public Decimal amount;
        public Decimal totalReturn;
        public Decimal adjustedReturn;
    }
    public class acceptableMonthlyPayment{
        public Decimal amount;
        
    }
    public class bkNetPayout{
        public Decimal amount;
        public Decimal totalReturn;
        public Decimal adjustedReturn;
    }
    public class maxCounterPayout{
        public Decimal amount;
        public Decimal totalReturn;
        public Decimal adjustedReturn;
    }
    public class proposedCounterPayout{
        public Decimal amount;
        public Decimal totalReturn;
        public Decimal adjustedReturn;
    }
    public class adjustedUnsecuredDebt{
        public Decimal amount;
        
    }
    
    public class minAcceptablePayout{
        public Decimal amount;
        public Decimal totalReturn;
        public Decimal adjustedReturn;
    }
    public class cpNetPayout{
        public Decimal amount;
        public Decimal totalReturn;
        public Decimal adjustedReturn;
    }
    public class surplusIncomePayments{
        public Decimal amount;
    }
    //This inner class will be store parsed response
    public class ParsedResponse{
        Public Boolean responseResult{get;set;}
        Public String resultString{get;set;}
        Public String votingStatus{get;set;}
        public String request{get;set;}
        public String response{get;set;}
        
        // This are the updated for voting engine enhancement requirement.
        public Decimal adjustedUnsecuredDebt{get;set;}
        public Decimal totalPayoutOffered{get;set;}
        public Decimal surplusIncomePayments{get;set;}
        public Integer bkDuration{get;set;}
        public Decimal cpNetPayout{get;set;}
        public Decimal bkNetPayout{get;set;}
        public Boolean counterWithBKInsteadOfCP{get;set;}
        public Decimal proposedMonthlyPayment{get;set;}
        public Decimal proposedCounterPayout{get;set;}
        public Decimal maxCounterMonthlyPayment{get;set;}
        public Boolean ShouldWeFurtherCounterWithBK{get;set;}
        public Decimal acceptableMonthlyPayment{get;set;}
        public Decimal minAcceptablePayout{get;set;}
        public String notesForSalesforce{get;set;}
        public Decimal maxCounterPayout{get;set;}
        public Decimal totalPayoutOfferedAR{get;set;}
        public Decimal totalPayoutOfferedTR{get;set;}
        public Decimal bkNetPayoutAR{get;set;}
        public Decimal bkNetPayoutTR{get;set;}
        public Decimal cpNetPayoutAR{get;set;}
        public Decimal cpNetPayoutTR{get;set;}
        public Decimal maxCounterPayoutAR{get;set;}
        public Decimal maxCounterPayoutTR{get;set;}
        public Decimal proposedCounterPayoutAR{get;set;}
        public Decimal proposedCounterPayoutTR{get;set;}
        public Decimal minAcceptablePayoutAR{get;set;}
        public Decimal minAcceptablePayoutTR{get;set;}
        Public String autoApprovedReason{get;set;}
       
     }
}