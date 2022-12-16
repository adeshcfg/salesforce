/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is utility class for integration layer for the Adjudication and AML web service
*  @author : A5E Consulting
*  @date : 03/12/2020   
*
*************************************************************************************************/
public without sharing class DecisionWSUtil{
    
    public virtual class XMLComplexType {
        public Map<String,Object> FieldValues {get;private set;}
        protected String fieldName;
        protected String[] field_order_type_info;
        public XMLComplexType() {
            FieldValues = new Map<String,Object>();
        }
        public void getXmlString(XmlStreamWriter w) {
            w.writeStartElement(null, fieldName, null);
            
            for (String f : field_order_type_info) {
                
                
                Object o = fieldValues.get(f);
                if (o == null && !fieldValues.containsKey(f)) {
                    continue;
                }
                
                if (o instanceof List<XMLComplexType>) {
                    List<XMLComplexType> xmlList = (List<XMLComplexType>)o;
                    for (XMLComplexType xmlct : xmlList) {
                        xmlct.getXmlString(w);
                    }
                } else if (o instanceof XMLComplexType) {
                    XMLComplexType xmlct = (XMLComplexType)o;
                    xmlct.getXmlString(w);
                } else {
                    w.writeStartElement(null, f, null);
                    if (o != null) {
                        if(f == 'Route'){
                            List<String> attributeList = new List<String>(String.valueOf(o).split(':'));
                            
                            for(String str : attributeList){
                                List<String> attributeValuesList = new List<String>(str.split('='));
                                w.writeAttribute(null, null, attributeValuesList[0] , attributeValuesList[1]);
                            }
                        }else{
                            w.writeCharacters(String.valueOf(o));
                        }
                    }
                    w.writeEndElement();
                }
            }
            
            w.writeEndElement();
        }
    }
    
    //This inner class will be used for the response coming from the web service
    public class WebServiceResponse{
        public String REL4Report = '';
        public String IFSXMLRs = '';
        public Map<String,String> IFSXMLError = null;
        public List<DPricing> dPricing = null;
        public List<DRejection> dRejection = null;
        public List<dValidationErrors> dValidationErrors = null;
        
        public WebServiceResponse parse(String json) {
            return (WebServiceResponse) System.JSON.deserialize(json, WebServiceResponse.class);
        }
    }
    
    public class DPricing {
        public Double maximumCreditAmount;
        public Double interestRate;
    }
    
    public class DRejection {
        public String reasonCode;
        public String diagnosticInfo;
    }
    
    public class dValidationErrors{
        public String reasonCode;
    }
    
    //This inner class is used for the AML Error JSON
    public class IFSXMLError{
        Public String status;
        Public String code;
        Public String title;
        Public String detail;
     
    }
    
    //This inner class is used for the XML part of the adjudication request
    public class DecisionXMLRequest extends XMLComplexType {
        public DecisionXMLRequest() {
            fieldName = 'TUCANREL4';
            field_order_type_info = new String[]{'Route','UserReference','MemberCode','Password','Product','TTY','Subject','OptionalRequest'};
        }
    }
    
    //This inner class is used for the XML part of the adjudication request - TTY tag
    public class DecisionXMLRequest_TTY extends XMLComplexType{
        public DecisionXMLRequest_TTY () {
            fieldName = 'TTY';
            field_order_type_info = new String[]{'FFR','Language'};
        }
    }
    
    //This inner class is used for the XML part of the adjudication request - Subject tag
    public class DecisionXMLRequest_Subject extends XMLComplexType{
        public DecisionXMLRequest_Subject() {
            fieldName = 'Subject';
            field_order_type_info = new String[]{'Name','DOB','Address','SIN'};
        }
    }
    
    //This inner class is used for the XML part of the adjudication request - Subject tag - Name tag
    public class DecisionXMLRequest_SubjectName extends XMLComplexType{
        public DecisionXMLRequest_SubjectName() {
            fieldName = 'Name';
            field_order_type_info = new String[]{'LastName','FirstName'};
        }
    }
    
    //This inner class is used for the XML part of the adjudication request - Subject tag - Address tag
    public class DecisionXMLRequest_SubjectAddress extends XMLComplexType{
        public DecisionXMLRequest_SubjectAddress() {
            fieldName = 'Address';
            field_order_type_info = new String[]{'Civic','Street','City','Postal','Prov','Telephone'};
        }
    }
    
    //This inner class is used for the XML part of the adjudication request - OptionalRequest tag
    public class DecisionXMLRequest_OptionalRequest extends XMLComplexType{
        public DecisionXMLRequest_OptionalRequest() {
            fieldName = 'OptionalRequest';
            field_order_type_info = new String[]{'OwningBureau','ErrorText','TradeMop','Summary'};
        }
    }
    
    //This inner class is used for the XML part of the AML request
    public class AMLXMLRequest extends XMLComplexType{
        public AMLXMLRequest() {
            fieldName = 'IFSXML';
            field_order_type_info = new String[]{'Route','UserReference','MemberCode','Password','PRODUCTCODE','AML','PI','Errors'};
        }
    }
    
    //This inner class is used for the XML part of the AML request - AML tag
    public class AMLXMLRequest_AML extends XMLComplexType{
        public AMLXMLRequest_AML() {
            fieldName = 'AML';
            field_order_type_info = new String[]{'LastName','FirstName','Address','Telephone'};
        }
    }
    
    //This inner class is used for the XML part of the AML request - AML tag - Address tag
    public class AMLXMLRequest_Address extends XMLComplexType{
        public AMLXMLRequest_Address() {
            fieldName = 'Address';
            field_order_type_info = new String[]{'Civic','Street','City','Postal','Prov','Telephone'};
        }
    }
    
    //This inner class is used for the XML part of the AML request - PI tag
    public class AMLXMLRequest_PI extends XMLComplexType{
        public AMLXMLRequest_PI() {
            fieldName = 'PI';
            field_order_type_info = new String[]{'DOB'};
        }
    }
    
    //This inner class is used for the XML part of the AML request - PI tag
    public class AMLXMLRequest_Errors extends XMLComplexType{
        public AMLXMLRequest_Errors() {
            fieldName = 'Errors';
            field_order_type_info = new String[]{'Error','Message'};
        }
    }
    
    //This inner class is used for the request created for the web service
    public class RequestJSON{

        public String TUCANREL4 = '';
        public String IFSXMLRq = '';
        public String birthDate = '';//'1955-08-25';
        public String employmentTypeCode = '';//'FullTime';
        public String financialConditionCode = '';//'BK';
        public String dependentsCount='';//'0';
        public String maritalStatusCode = '';//'Married';
        public Boolean homeOwnerInd = null;//true;
        public Double monthlyRentPaymentAmount = null;//1;
        public Double totalOtherMonthlyExpensesAmount = null;//1;
        public String monthsEmployed = '';//'1';
        public Double grossMonthlyIncomeAmount = null;//1;
        public Boolean politicallyExposedInd = null;//true;
        public Boolean otherBeneficiaryInd= null;//true;
        public String campaignCode= '';//TrusteeProduct
    }
    
    //This inner class is used for the redecide request created for the web service
    public class RedecideRequestJSON{

        public String REL4Report = '';
        public String IFSXMLRs = '';
        public String birthDate = '';//'1955-08-25';
        public String employmentTypeCode = '';//'FullTime';
        public String financialConditionCode = '';//'BK';
        public String dependentsCount='';//'0';
        public String maritalStatusCode = '';//'Married';
        public Boolean homeOwnerInd = null;//true;
        public Double monthlyRentPaymentAmount = null;//1;
        public Double totalOtherMonthlyExpensesAmount = null;//1;
        public String monthsEmployed = '';//'1';
        public Double grossMonthlyIncomeAmount = null;//1;
        public Boolean politicallyExposedInd = null;//true;
        public Boolean otherBeneficiaryInd= null;//true;
        
    }
    
    //This inner class is used for the redecide request created for the web service
    public class RedecideRequestAMLJSON{

        public String REL4Report = '';
        public String IFSXMLRq = '';
        public String birthDate = '';//'1955-08-25';
        public String employmentTypeCode = '';//'FullTime';
        public String financialConditionCode = '';//'BK';
        public String dependentsCount='';//'0';
        public String maritalStatusCode = '';//'Married';
        public Boolean homeOwnerInd = null;//true;
        public Double monthlyRentPaymentAmount = null;//1;
        public Double totalOtherMonthlyExpensesAmount = null;//1;
        public String monthsEmployed = '';//'1';
        public Double grossMonthlyIncomeAmount = null;//1;
        public Boolean politicallyExposedInd = null;//true;
        public Boolean otherBeneficiaryInd= null;//true;
        
    }
    
    //Inner class for response from Integration
    public class IntegrationResponse{
       public string request{get;set;}
       public string response{get;set;}
       public string applicationStatus{get;set;}
       public string adjudicationStatus{get;set;}
       public string declineReason{get;set;}
       public Decimal approvedAmount{get;set;}
       public Decimal approvedInterestRate{get;set;}
       public String decisionSummary{get;set;}
       public String amlResponse{get;set;}
       public String adjudicationResponse{get;set;}
       public DateTime adjudicationDecisionTimestamp{get;set;}
       public Integer creditScore{get;set;}
       public Integer totalNumberofBankrupcies{get;set;}
       public String amlDeclineReason{get;set;}
       public String amlSummary{get;set;}
       public String amlStatus{get;set;}
       public DateTime amlTimestamp{get;set;}
       public String adjudicationFile{get;set;}
       public String fraudFlag{get;set;}
       public String needsReviewReason{get;set;}
       public String amlUniqueNumber{get;set;}
    }
    
    public class ParseAuthtoken {

        public String token_type;
        public String expires_in;
        public String ext_expires_in;
        public String access_token;
        
        public ParseAuthtoken parse(String json) {
            return (ParseAuthtoken) System.JSON.deserialize(json, ParseAuthtoken.class);
        }
    }
}