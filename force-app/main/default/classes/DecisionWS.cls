/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is integration layer for the Adjudication and AML web service
*  @author : A5E Consulting
*  @date : 03/12/2020   
*
*************************************************************************************************/
public without sharing class DecisionWS{
    
    public Application_Form_Configuration__c appFormSettings = Application_Form_Configuration__c.getOrgDefaults();
    
    //this function creates the XML for the adjudication 
    public static String getDecisionRequestXML(Application__c app, Application_Form_Configuration__c afSettings){
        
        DecisionWSUtil.DecisionXMLRequest decisionXMLRequest = new DecisionWSUtil.DecisionXMLRequest();
        decisionXMLRequest.fieldValues.put('Route', 'RouteDest=' + afSettings.RouteDest__c + ':RouteType=' + afSettings.RouteType__c);
        decisionXMLRequest.fieldValues.put('UserReference', afSettings.UserReference__c);
        decisionXMLRequest.fieldValues.put('MemberCode', afSettings.Member_Code__c);
        decisionXMLRequest.fieldValues.put('Password', afSettings.Password__c);
        decisionXMLRequest.fieldValues.put('Product', afSettings.Product__c);
        
        DecisionWSUtil.DecisionXMLRequest_TTY decisionTTYXML = new DecisionWSUtil.DecisionXMLRequest_TTY();
        decisionXMLRequest.fieldValues.put('TTY', decisionTTYXML);
        
        decisionTTYXML.fieldValues.put('FFR', afSettings.FFR__c);
        decisionTTYXML.fieldValues.put('Language', afSettings.Language__c);
        
        DecisionWSUtil.DecisionXMLRequest_Subject decisionSubjectXML = new DecisionWSUtil.DecisionXMLRequest_Subject();
        decisionXMLRequest.fieldValues.put('Subject', decisionSubjectXML);
        
        DecisionWSUtil.DecisionXMLRequest_SubjectName subjectNameXML = new DecisionWSUtil.DecisionXMLRequest_SubjectName();
        decisionSubjectXML.fieldValues.put('Name', subjectNameXML);
        
        subjectNameXML.fieldValues.put('LastName', app.Last_Name__c);
        subjectNameXML.fieldValues.put('FirstName', app.First_Name__c);
        
        String BirthMonth = string.valueOf(app.Birth_Date__c.month());
        String Birthday = string.valueOf(app.Birth_Date__c.day());
        String Birthyear = string.valueOf(app.Birth_Date__c.year()); 
        String FinalBirthdate = Birthyear+(BirthMonth.length()==1?('0'+BirthMonth):BirthMonth)+(Birthday.length()==1?('0'+Birthday):Birthday);
        decisionSubjectXML.fieldValues.put('DOB', FinalBirthdate);
        
        decisionSubjectXML.fieldValues.put('SIN', app.SIN__C);
        
        DecisionWSUtil.DecisionXMLRequest_SubjectAddress subjectAddressXML = new DecisionWSUtil.DecisionXMLRequest_SubjectAddress();
        decisionSubjectXML.fieldValues.put('Address', subjectAddressXML);
        
        subjectAddressXML.fieldValues.put('Civic', app.Permanent_Address_Street_Number__c);
        subjectAddressXML.fieldValues.put('Street', app.Permanent_Address_Street_Name__c);
        subjectAddressXML.fieldValues.put('City', app.Permanent_Address_City__c);
        subjectAddressXML.fieldValues.put('Postal', app.Permanent_Address_PostalCode__c);
        subjectAddressXML.fieldValues.put('Prov', app.Permanent_Address_Province__c);
        if(app.Primary_Phone_Number__c == 'Home Phone'){
            subjectAddressXML.fieldValues.put('Telephone', unformattedPhoneNumber(app.Home_Phone__c));
        }else if(app.Primary_Phone_Number__c == 'Mobile Phone'){
            subjectAddressXML.fieldValues.put('Telephone', unformattedPhoneNumber(app.Cell_Phone__c));
        }else if(app.Primary_Phone_Number__c == 'Work Phone'){
            subjectAddressXML.fieldValues.put('Telephone', unformattedPhoneNumber(app.Work_Phone__c));
        }
        
        DecisionWSUtil.DecisionXMLRequest_OptionalRequest decisionOptionRequestXML = new DecisionWSUtil.DecisionXMLRequest_OptionalRequest();
        decisionXMLRequest.fieldValues.put('OptionalRequest', decisionOptionRequestXML);
        
        decisionOptionRequestXML.fieldValues.put('OwningBureau', afSettings.Owning_Bureau__c);
        decisionOptionRequestXML.fieldValues.put('ErrorText', afSettings.Error_Text__c );
        decisionOptionRequestXML.fieldValues.put('TradeMop', afSettings.TradeMop__c);
        decisionOptionRequestXML.fieldValues.put('Summary', afSettings.Summary__c);
        
        
        XmlStreamWriter w = new XmlStreamWriter();
        decisionXMLRequest.getXMLString(w);

        String decisionRequestXML = w.getXmlString();
        w.close();
        
        decisionRequestXML.replace('\"', '\\"');
        System.debug('decisionRequestXML :');
        System.debug(decisionRequestXML);
        
        return decisionRequestXML;
        
    }
    
    //this function creates the XML for the adjudication 
    private static String getAMLRequestXML(Application__c app, Application_Form_Configuration__c afSettings){
        
        DecisionWSUtil.AMLXMLRequest amlXMLRequest = new DecisionWSUtil.AMLXMLRequest ();
        
        amlXMLRequest.fieldValues.put('Route', 'RouteType=' + afSettings.AML_Route_Type__c);
        amlXMLRequest.fieldValues.put('UserReference', afSettings.AML_User_Reference__c);
        amlXMLRequest.fieldValues.put('MemberCode', afSettings.AML_Member_Code__c   );
        amlXMLRequest.fieldValues.put('Password', afSettings.AML_Password__c);
        amlXMLRequest.fieldValues.put('PRODUCTCODE', afSettings.AML_Product_Code__c);
        
        DecisionWSUtil.AMLXMLRequest_AML amlXMLRequest_AML = new DecisionWSUtil.AMLXMLRequest_AML();
        amlXMLRequest.fieldValues.put('AML', amlXMLRequest_AML);
        
        amlXMLRequest_AML.fieldValues.put('LastName', app.Last_Name__c);
        amlXMLRequest_AML.fieldValues.put('FirstName', app.First_name__c);
        
        DecisionWSUtil.AMLXMLRequest_Address amlXMLRequest_Address = new DecisionWSUtil.AMLXMLRequest_Address();
        amlXMLRequest_AML.fieldValues.put('Address', amlXMLRequest_Address);
        
        amlXMLRequest_Address.fieldValues.put('Civic', app.Permanent_Address_Street_Number__c);
        amlXMLRequest_Address.fieldValues.put('Street', app.Permanent_Address_Street_Name__c);
        amlXMLRequest_Address.fieldValues.put('City', app.Permanent_Address_City__c);
        amlXMLRequest_Address.fieldValues.put('Postal', app.Permanent_Address_PostalCode__c);
        amlXMLRequest_Address.fieldValues.put('Prov', app.Permanent_Address_Province__c);
        if(app.Primary_Phone_Number__c == 'Home Phone'){
            amlXMLRequest_Address.fieldValues.put('Telephone', unformattedPhoneNumber(app.Home_Phone__c));
        }else if(app.Primary_Phone_Number__c == 'Mobile Phone'){
            amlXMLRequest_Address.fieldValues.put('Telephone', unformattedPhoneNumber(app.Cell_Phone__c));
        }else if(app.Primary_Phone_Number__c == 'Work Phone'){
            amlXMLRequest_Address.fieldValues.put('Telephone', unformattedPhoneNumber(app.Work_Phone__c));
        }
        
        if(app.Primary_Phone_Number__c == 'Home Phone'){
            amlXMLRequest_AML.fieldValues.put('Telephone', unformattedPhoneNumber(app.Home_Phone__c));
        }else if(app.Primary_Phone_Number__c == 'Mobile Phone'){
            amlXMLRequest_AML.fieldValues.put('Telephone', unformattedPhoneNumber(app.Cell_Phone__c));
        }else if(app.Primary_Phone_Number__c == 'Work Phone'){
            amlXMLRequest_AML.fieldValues.put('Telephone', unformattedPhoneNumber(app.Work_Phone__c));
        }
        
        DecisionWSUtil.AMLXMLRequest_PI amlXMLRequest_PI = new DecisionWSUtil.AMLXMLRequest_PI();
        amlXMLRequest.fieldValues.put('PI', amlXMLRequest_PI);
        
        String BirthMonth = string.valueOf(app.Birth_Date__c.month());
        String Birthday = string.valueOf(app.Birth_Date__c.day());
        String Birthyear = string.valueOf(app.Birth_Date__c.year()); 
        String FinalBirthdate = Birthyear+(BirthMonth.length()==1?('0'+BirthMonth):BirthMonth)+(Birthday.length()==1?('0'+Birthday):Birthday);
        amlXMLRequest_PI.fieldValues.put('DOB', FinalBirthdate);
        
        XmlStreamWriter w = new XmlStreamWriter();
        amlXMLRequest.getXMLString(w);

        String decisionRequestXML = w.getXmlString();
        w.close();
        System.debug('decisionRequestXML :');
        System.debug(decisionRequestXML);
        
        return decisionRequestXML;   
    }
    
    //generate JSON request fordecision
    private static String createJSONRequest(Application__c app, Application_Form_Configuration__c afSettings){
        DecisionWSUtil.RequestJSON request = new DecisionWSUtil.RequestJSON();
        
        request.TUCANREL4 = DecisionWS.getDecisionRequestXML(app, afSettings);
        request.IFSXMLRq = DecisionWS.getAMLRequestXML(app, afSettings);
        request.birthDate = string.valueOf(app.Birth_Date__c);
        request.employmentTypeCode = app.Employment_Status__c;
        if(app.CurrentBKCP__c=='BK'){
            request.financialConditionCode = 'BK';
        }else if(app.CurrentBKCP__c=='CP'){
            request.financialConditionCode = 'CP';
        }
        request.dependentsCount = app.Number_of_Dependants__c;
        request.maritalStatusCode = app.Marital_Status__c;
        if(app.Home_Owner__c=='Own Property'){
            request.homeOwnerInd = true;
        }else if(app.Home_Owner__c=='Rent'){
            request.homeOwnerInd = false;
        }
        request.monthlyRentPaymentAmount = app.Housing_Costs__c;
        request.totalOtherMonthlyExpensesAmount = app.Monthly_Expenses__c;
        
        //Need to send greater of current employment length and previous employment length
        //request.monthsEmployed = string.valueOf(app.Employment_Years__c * 12 + app.Employment_Months__c);
        request.monthsEmployed = string.valueOf(getGreaterOfEmpLength(app));
                
        request.grossMonthlyIncomeAmount = app.Gross_Monthly_Income__c;
        request.politicallyExposedInd = app.Politically_Exposed_Foreign_Person__c;
        request.otherBeneficiaryInd = app.Third_Party_Direction__c;
        
        if(String.isNotBlank(app.Campaign_Code__c)){
            request.campaignCode = app.Campaign_Code__c;
        }
        
        String returnJSONString = JSON.serialize(request);
        
        System.debug('decisionRequestXML :');
        System.debug(returnJSONString );
        
        return returnJSONString;
    }
    
    //This method parse the response 
    private static DecisionWSUtil.IntegrationResponse parseJSONResponse(DecisionWSUtil.WebServiceResponse decResp, DecisionWSUtil.IntegrationResponse intResponse){
        
        if(null != decResp.dValidationErrors && decResp.dValidationErrors.size() > 0 ){
            system.debug('Validation');
            intResponse.adjudicationStatus = 'Declined';
            intResponse.declineReason = declineReasonValue(decResp.dValidationErrors[0].reasonCode);
            intResponse.decisionSummary = declineReasonValue(decResp.dValidationErrors[0].reasonCode);
            if(decResp.dValidationErrors.size() > 1){
                for(Integer i = 1; i < decResp.dValidationErrors.size(); i++){
                    intResponse.decisionSummary += ',\n' + declineReasonValue(decResp.dValidationErrors[i].reasonCode);
                }
            }
            system.debug(intResponse.declineReason );
            
        }else if (null != decResp.dRejection && decResp.dRejection.size() > 0){
            intResponse.adjudicationStatus = 'Declined';
            if(null != decResp.dRejection[0].reasonCode){
                intResponse.declineReason = declineReasonValue(decResp.dRejection[0].reasonCode);
                intResponse.decisionSummary = declineReasonValue(decResp.dRejection[0].reasonCode);
            }
            if(decResp.dRejection.size() > 1){
                for(Integer i = 1; i < decResp.dRejection.size(); i++){
                    intResponse.decisionSummary += ',\n' + declineReasonValue(decResp.dRejection[i].reasonCode);
                }
            }
            
            if(decResp.dPricing[0].maximumCreditAmount != null)
                intResponse.ApprovedAmount = decResp.dPricing[0].maximumCreditAmount;
            if(decResp.dPricing[0].interestRate != null)
                intResponse.ApprovedInterestRate = decResp.dPricing[0].interestRate;
        }else{
            intResponse.adjudicationStatus = 'Approved';
            if(decResp.dPricing[0].maximumCreditAmount != null)
                intResponse.ApprovedAmount = decResp.dPricing[0].maximumCreditAmount;
            if(decResp.dPricing[0].interestRate != null)
                intResponse.ApprovedInterestRate = decResp.dPricing[0].interestRate;
        }
        
        intResponse.adjudicationResponse = decResp.REL4Report;
        if(null != decResp.IFSXMLError){
            intResponse.amlStatus = 'Needs Review';
            intResponse.needsReviewReason = 'System Not Reachable - AML';
            
        }else{
            intResponse.amlResponse = decResp.IFSXMLRs;
        }
        
        return intResponse;
    }
    
    //function to parse adjudication XML
    public static DecisionWSUtil.IntegrationResponse parseXMLResponseAdjudication(String xmlString, DecisionWSUtil.IntegrationResponse intResponse){
        
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        
        //load root element
        Dom.XMLNode drRoot = doc.getRootElement();
        system.debug('Root Element :' + drRoot);
        //drRoot = drRoot.getChildElement('REL4Report',null);
        
        //Adjudication Decision timestamp
        String adjudicationDate = drRoot.getChildElement('Date',null).getText();
        String adjudicationTime = drRoot.getChildElement('Time',null).getText();
        System.debug('Date : '+ adjudicationDate + 'time: '+ adjudicationTime );
        intResponse.adjudicationDecisionTimestamp = DecisionWS.parseDateTime(adjudicationDate, adjudicationTime);
        
        Dom.XMLNode TUFFRReport = drRoot.getChildElement('TU_FFR_Report',null);
        
        //Credit Score value
        if(null != TUFFRReport.getChildElement('ScoreProducts',null)){
            Dom.XMLNode ScoreCardProducts = TUFFRReport.getChildElement('ScoreProducts',null);
            Dom.XMLNode ScoreCardProduct = ScoreCardProducts.getChildElement('ScoreProduct',null);
            intResponse.creditScore = Integer.valueOf(ScoreCardProduct.getChildElement('Score',null).getText());
        }
        
        //number of bankrupcies
        Dom.XMLNode bankrupcies = TUFFRReport.getChildElement('Bankruptcies',null);
        if(null != bankrupcies ){
            Dom.XMLNode[] bankrupciesList = bankrupcies.getChildren();
            intResponse.totalNumberofBankrupcies = bankrupciesList.size();
        }
        
        //Decision summary comments
        Dom.XMLNode messages = TUFFRReport.getChildElement('Messages',null);
        Dom.XMLNode[] messageList = messages.getChildren();
        if(String.isBlank(intResponse.decisionSummary)){
            intResponse.decisionSummary = '';
        }
        for(Dom.XMLNode node : messageList){
            if(null != node.getChildElement('Code',null)){
                Dom.XMLNode code = node.getChildElement('Code',null);
                intResponse.decisionSummary += '\n' + code.getText();
            }
            if(null != node.getChildElement('Text',null)){
                Dom.XMLNode text = node.getChildElement('Text',null);
                intResponse.decisionSummary += ' := ' + text.getText();
            }
        }
        
        //Adjudication file data
        if(xmlString.contains('<![CDATA[')){
            intResponse.adjudicationFile = xmlString.substring(xmlString.indexOf('<![CDATA['), xmlString.indexOf(']]'));
            intResponse.adjudicationFile = (intResponse.adjudicationFile).remove('<![CDATA[');
        }
        
        system.debug('adjudication file data :: ' + intResponse.adjudicationFile);
        
        return intResponse;
    }
    
    //function to parse AML XML
    public static DecisionWSUtil.IntegrationResponse parseXMLResponseAML(String xmlString, DecisionWSUtil.IntegrationResponse intResponse){
        
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        
        //load root element
        Dom.XMLNode drRoot = doc.getRootElement();
        //drRoot = drRoot.getChildElement('IFSXML',null);
        
        //system.debug('root element:' + drRoot);
        //AML Flag value
        if(null != drRoot.getChildElement('AML',null)){
            Dom.XMLNode amlNodes = drRoot.getChildElement('AML',null);
            Dom.XMLNode BureauHit = amlNodes.getChildElement('BureauHit',null);
            String BureauHitFlag = BureauHit.getText();
            String fraudFlag = amlNodes.getChildElement('FraudFlag',null).getText();
            intResponse.fraudFlag = fraudFlag;
            //Unique number from AML
            intResponse.amlUniqueNumber = drRoot.getChildElement('UniqueID',null).getText();
            
            //aml decision time stamp
            intResponse.amlTimestamp = system.now();
            
            //If Fraud flag is Y then populate AML Decision Summary values with ConsumerStatement values with AML status and 
            //if declined then decline status to populate
            if(BureauHitFlag == 'N' || fraudFlag == 'Y'){
                
                if(BureauHitFlag == 'N'){
                    intResponse.amlStatus = 'Needs Review';
                    intResponse.NeedsReviewReason = 'No Hit – AML';
                    intResponse.fraudFlag = null;
                }
                if(fraudFlag == 'Y'){
                    intResponse.amlStatus = 'Declined';
                    intResponse.amlDeclineReason = 'AML Failed';
                }
                
                Dom.XMLNode[] consumerStatementNodes = drRoot.getChildren();
                String errorType = '';
                intResponse.amlSummary = '';
                for(Dom.XMLNode nodeValue : consumerStatementNodes){
                    if(nodeValue.getName() == 'ConsumerStatement'){
                        //Dom.XMLNode errorSummary = nodeValue.getChildElement('ConsumerStatement',null);
                        
                        String code = nodeValue.getChildElement('Type',null).getText();
                        String text = nodeValue.getChildElement('Text',null).getText();
                        if(errorType != code){
                            intResponse.amlSummary += '\n' + code + ' := ' + text;
                            errorType = code;
                        }else{
                            intResponse.amlSummary += text;
                        }
                    }
                }
            }else{
                intResponse.amlStatus = 'Approved';
            }
        }else if(null != drRoot.getChildElement('Errors',null)){
            Dom.XMLNode errorSummary = drRoot.getChildElement('Errors',null);
            intResponse.amlStatus = 'Needs Review';
            intResponse.amlSummary = 'AML Errors';
            String error = errorSummary.getChildElement('Error',null).getText();
            String message = errorSummary.getChildElement('Message',null).getText();
            intResponse.amlSummary += ' - ' + error + ' := ' + message;
        }
        
        return intResponse;
    }
    
    //To create DateTime from Date and time values
    //<Date>20200310</Date>
    //<Time>183447</Time>
    private static DateTime parseDateTime(String dateVal, string timeVal){
        
        Integer year = Integer.valueOf(dateVal.subString(0,4));
        Integer month = Integer.valueOf(dateVal.subString(4,6));
        Integer dateValue = Integer.valueOf(dateVal.subString(6,8));
        
        Integer hour = Integer.valueOf(timeVal.subString(0,2));
        Integer minute = Integer.valueOf(timeVal.subString(2,4));
        Integer second = Integer.valueOf(timeVal.subString(4,6));
        system.debug('year : ' + year);
        system.debug('month : ' + month);
        system.debug('dateValue : ' + dateValue );
        system.debug('hour: ' + hour);
        system.debug('minute: ' + minute);
        system.debug('second : ' + second);
        
        return DateTime.newInstance(year, month, dateValue, hour, minute, second);
    }
    
    //This submit method is for AdjudicationEngine request and response generation
    public static DecisionWSUtil.IntegrationResponse submit(Application__c app, Application_Form_Configuration__c afSettings){
        
        //return value veriable
        DecisionWSUtil.IntegrationResponse intResponse = new DecisionWSUtil.IntegrationResponse();
        
        //Request for AuthProvider
        String Authprovider = 'client_id=' + afSettings.Client_ID__c + '&client_secret=' + afSettings.Client_Secret__c + '&scope=' + afSettings.Scope__c +'&grant_type=' + afSettings.Grant_Type__c;
        system.debug('Authprovider' + Authprovider);
        
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint(afSettings.Auth_Endpoint__c);
        req2.setHeader('Content-Type','application/x-www-form-urlencoded');
        req2.setBody(Authprovider);
        req2.setMethod('POST');
        req2.setTimeout(Integer.valueOf(afSettings.Timeout_for_Webservice__c));
        system.debug('CheckAuthreq2' +  req2);
        HttpResponse res2 = new HttpResponse();
        Http http = new Http();
        res2 = http.send(req2);
        
        system.debug('Authentication response : ' + res2.getBody());
        //Request for AdjudicationEngine
        HttpResponse res = new HttpResponse();
        DecisionWSUtil.ParseAuthtoken token = new DecisionWSUtil.ParseAuthtoken();
        token = token.parse(res2.getbody());
        String sToken = 'Bearer ' + token.access_token;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(afSettings.Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Authorization', sToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(DecisionWS.createJSONRequest(app, afSettings));
        req.setTimeout(Integer.valueOf(afSettings.Timeout_for_Webservice__c));
        
        //To catch exception during sending request, getting response and processing response
        try{
            //send request and get response
            res = http.send(req);
            
            //check if request is processed correctly
            if(res.getStatusCode()==200){
                DecisionWSUtil.WebServiceResponse responseValue = new DecisionWSUtil.WebServiceResponse();
                //Parse the response to JSON object
                responseValue = responseValue.parse(res.getBody());
                
                //Parse JSON object response
                intResponse = DecisionWS.parseJSONResponse(responseValue, intResponse);
                
                //Parse Adjudication XML
                if(String.isNotBlank(responseValue.REL4Report)){
                    system.debug('Adjudication response :' + responseValue.REL4Report);
                    intResponse = DecisionWS.parseXMLResponseAdjudication(responseValue.REL4Report, intResponse);
                }
                //parse AMl XML
                system.debug('AML REsponse:' + responseValue.IFSXMLRs);
                if(String.isNotBlank(responseValue.IFSXMLRs)){
                    intResponse = DecisionWS.parseXMLResponseAML(responseValue.IFSXMLRs, intResponse);
                }
                
                
            }else{//if request is failed
                intResponse.adjudicationStatus = 'Needs Review';
                intResponse.NeedsReviewReason = 'System Not Reachable – Adjudication';
                
                API_Error__c apiError = new API_Error__c(
                    Application__c = app.Id, End_Point__c = 'A', Action__c = 'Create Application'
                );
                apiError.error__c = 'Request Failed';
                insert apiError;
            }
            
        }catch(Exception e){
        
            intResponse.adjudicationStatus = 'Needs Review';
            intResponse.decisionSummary = 'Exception during API call';
            intResponse.NeedsReviewReason = 'System Exception';
            
            API_Error__c apiError = new API_Error__c(
                Application__c = app.Id, End_Point__c = 'A', Action__c = 'Create Application'
            );
            apiError.error__c = e.getMessage();
            insert apiError;
        }
        
        intResponse.request = req.getBody();
        intResponse.response = res.getBody();
        
        return intResponse;
    }
    
    public static String unformattedPhoneNumber(String PhoneNumberValue){
        
        String unformattedPhoneNumber = '';
        if(String.isNotBlank(PhoneNumberValue)){
             unformattedPhoneNumber = PhoneNumberValue.replaceAll('[^0-9]', '');
        }
        
        return unformattedPhoneNumber;
    }
    
    //to map decline reasons to readable values
    private static string declineReasonValue(String reason){
        map<String, Adjudication_Reason_Mapping__c> reasonMappingMap = Adjudication_Reason_Mapping__c.getAll();
        
        Adjudication_Reason_Mapping__c reasonValue = reasonMappingMap.get(reason);
        if(null == reasonValue){
            return reason;
        }else{
            return reasonValue.reason__c;
        }
    }
    
    //This method creates the JSON request for the reDecide flow
    private static String reDecideJSONRequest(Application__c app, Application_Form_Configuration__c afSettings){
        
        DecisionWSUtil.RedecideRequestJSON request = new DecisionWSUtil.RedecideRequestJSON();
        
        request.REL4Report = app.Adjudication_Response__c;
        request.IFSXMLRs = app.AML_Response__c;
        
        request.birthDate = string.valueOf(app.Birth_Date__c);
        request.employmentTypeCode = app.Employment_Status__c;
        if(app.CurrentBKCP__c=='BK'){
            request.financialConditionCode = 'BK';
        }else if(app.CurrentBKCP__c=='CP'){
            request.financialConditionCode = 'CP';
        }
        request.dependentsCount = app.Number_of_Dependants__c;
        request.maritalStatusCode = app.Marital_Status__c;
        if(app.Home_Owner__c=='Own Property'){
            request.homeOwnerInd = true;
        }else if(app.Home_Owner__c=='Rent'){
            request.homeOwnerInd = false;
        }
        request.monthlyRentPaymentAmount = app.Housing_Costs__c;
        request.totalOtherMonthlyExpensesAmount = app.Monthly_Expenses__c;
                
        //Need to send greater of current employment length and previous employment length
        //request.monthsEmployed = string.valueOf(app.Employment_Years__c * 12 + app.Employment_Months__c);
        request.monthsEmployed = string.valueOf(getGreaterOfEmpLength(app));
                
        request.grossMonthlyIncomeAmount = app.Gross_Monthly_Income__c;
        request.politicallyExposedInd = app.Politically_Exposed_Foreign_Person__c;
        request.otherBeneficiaryInd = app.Third_Party_Direction__c;
        
        String returnJSONString = JSON.serialize(request);
        
        System.debug('decisionRequestXML :');
        System.debug(returnJSONString );
        
        return returnJSONString;
    }
    
    //This method creates the JSON request for the reDecide flow AML XML not present
    private static String reDecideJSONNoAMLRequest(Application__c app, Application_Form_Configuration__c afSettings){
        
        DecisionWSUtil.RedecideRequestAMLJSON request = new DecisionWSUtil.RedecideRequestAMLJSON();
        
        request.REL4Report = app.Adjudication_Response__c;
        request.IFSXMLRq = DecisionWS.getAMLRequestXML(app, afSettings);
        
        request.birthDate = string.valueOf(app.Birth_Date__c);
        request.employmentTypeCode = app.Employment_Status__c;
        if(app.CurrentBKCP__c=='BK'){
            request.financialConditionCode = 'BK';
        }else if(app.CurrentBKCP__c=='CP'){
            request.financialConditionCode = 'CP';
        }
        request.dependentsCount = app.Number_of_Dependants__c;
        request.maritalStatusCode = app.Marital_Status__c;
        if(app.Home_Owner__c=='Own Property'){
            request.homeOwnerInd = true;
        }else if(app.Home_Owner__c=='Rent'){
            request.homeOwnerInd = false;
        }
        request.monthlyRentPaymentAmount = app.Housing_Costs__c;
        request.totalOtherMonthlyExpensesAmount = app.Monthly_Expenses__c;
        
        //Need to send greater of current employment length and previous employment length
        //request.monthsEmployed = string.valueOf(app.Employment_Years__c * 12 + app.Employment_Months__c);
        request.monthsEmployed = string.valueOf(getGreaterOfEmpLength(app));
                
        request.grossMonthlyIncomeAmount = app.Gross_Monthly_Income__c;
        request.politicallyExposedInd = app.Politically_Exposed_Foreign_Person__c;
        request.otherBeneficiaryInd = app.Third_Party_Direction__c;
        
        String returnJSONString = JSON.serialize(request);
        
        System.debug('decisionRequestXML :');
        System.debug(returnJSONString );
        
        return returnJSONString;
    }
    
    //This ReDecide method is for AdjudicationEngine request and response generation
    public static DecisionWSUtil.IntegrationResponse reDecide(Application__c app, Application_Form_Configuration__c afSettings){
        
        //return value veriable
        DecisionWSUtil.IntegrationResponse intResponse = new DecisionWSUtil.IntegrationResponse();
        
        //Request for AuthProvider
        String Authprovider = 'client_id=' + afSettings.Client_ID__c + '&client_secret=' + afSettings.Client_Secret__c + '&scope=' + afSettings.Scope__c +'&grant_type=' + afSettings.Grant_Type__c;
        system.debug('Authprovider' + Authprovider);
        
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint(afSettings.Auth_Endpoint__c);
        req2.setHeader('Content-Type','application/x-www-form-urlencoded');
        req2.setBody(Authprovider);
        req2.setMethod('POST');
        req2.setTimeout(Integer.valueOf(afSettings.Timeout_for_Webservice__c));
        system.debug('CheckAuthreq2' +  req2);
        HttpResponse res2 = new HttpResponse();
        Http http = new Http();
        res2 = http.send(req2);
        
        system.debug('Authentication response : ' + res2.getBody());
        //Request for AdjudicationEngine
        HttpResponse res = new HttpResponse();
        DecisionWSUtil.ParseAuthtoken token = new DecisionWSUtil.ParseAuthtoken();
        token = token.parse(res2.getbody());
        String sToken = 'Bearer ' + token.access_token;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(afSettings.Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Authorization', sToken);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(Integer.valueOf(afSettings.Timeout_for_Webservice__c));
        
        if(String.IsNotBlank(app.AML_Response__c) && (app.AML_Response__c).contains('<BureauHit>Y</BureauHit>')){
            req.setBody(DecisionWS.reDecideJSONRequest(app, afSettings));
        }else{
            req.setBody(DecisionWS.reDecideJSONNoAMLRequest(app, afSettings));
        }
        
        //To catch exception during sending request, getting response and processing response
        try{
            //send request and get response
            res = http.send(req);
            
            //check if request is processed correctly
            if(res.getStatusCode() == 200){
                DecisionWSUtil.WebServiceResponse responseValue = new DecisionWSUtil.WebServiceResponse();
                //Parse the response to JSON object
                responseValue = responseValue.parse(res.getBody());
                
                //Parse JSON object response
                intResponse = DecisionWS.parseJSONResponse(responseValue, intResponse);
                
                //Parse Adjudication XML
                if(String.isNotBlank(responseValue.REL4Report)){
                    system.debug('Adjudication response :' + responseValue.REL4Report);
                    intResponse = DecisionWS.parseXMLResponseAdjudication(responseValue.REL4Report, intResponse);
                }
                //parse AMl XML
                system.debug('AML REsponse:' + responseValue.IFSXMLRs);
                if(String.isNotBlank(responseValue.IFSXMLRs)){
                    intResponse = DecisionWS.parseXMLResponseAML(responseValue.IFSXMLRs, intResponse);
                }
                
                
            }else{//if request is failed
                intResponse.adjudicationStatus = 'Needs Review';
                API_Error__c apiError = new API_Error__c(
                    Application__c = app.Id, End_Point__c = 'EBDM', Action__c = 'Update Application'
                );
                apiError.error__c = 'Request Failed';
                insert apiError;
            }
            
        }catch(Exception e){
            API_Error__c apiError = new API_Error__c(
                Application__c = app.Id, End_Point__c = 'EBDM', Action__c = 'Update Application'
            );
            apiError.error__c = e.getMessage();
            insert apiError;
        }
        
        intResponse.request = req.getBody();
        intResponse.response = res.getBody();
        
        return intResponse;
    }
    
    //Returns the greater of current employment length and previous employment length
    public static Decimal getGreaterOfEmpLength (Application__c appln){
        
        //current employment length
        Decimal currentEmpLength = getTotalEmploymentMonths(appln.Employment_Years__c, appln.Employment_Months__c);
        
        //previous employment length
        Decimal previousEmpLength = getTotalEmploymentMonths(appln.Previous_Employment_Years__c, appln.Previous_Employment_Months__c);
            
        return ((currentEmpLength >  previousEmpLength ) ? currentEmpLength : previousEmpLength);      
    }
    
    //Get Total Employment Months
    public static Decimal getTotalEmploymentMonths (Decimal employmentYears, Decimal employmentMonths){
        
        Decimal totalEmploymentMonths = 0;
        
        if(employmentYears != null && employmentYears != 0){
            totalEmploymentMonths = totalEmploymentMonths + employmentYears * 12;
        }
        
        if(EmploymentMonths != null && EmploymentMonths != 0){
            totalEmploymentMonths = totalEmploymentMonths + employmentMonths;
        }
                
        return totalEmploymentMonths;        
    }
}