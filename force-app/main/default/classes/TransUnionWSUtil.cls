public class TransUnionWSUtil {
    private static Application_Form_Settings__c afSettings;
    /**
     *  @description SOAP call to send personal information from application to TransUnion to get verification questions
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2015-12-21
     */
    
    //Error message changes
    //Added by A5E Consulting
    public static final String ERROR_MESSAGE_NO_BUREAU_HIT = 'NoBureauHit';
    public static final String ERROR_MESSAGE_THIN_BUREAU_HIT = 'ThinBureauHit';
    public static final String ERROR_MESSAGE_TOO_MANY_ATTEMPTS =  'TooManyAttempts';   
    public static final String ERROR_MESSAGE_SUBMITTED_EXAM_AGAIN = 'SubmittedExamAgain';
    public static final String ERROR_MESSAGE_TECHNICAL_ISSUE = 'TechnicalIssue';
  
    public static final String AUTH_CHOICE_NO_BUREAU_HIT = 'Error-NoBureauHit';
    public static final String AUTH_CHOICE_THIN_BUREAU_HIT = 'Error-ThinBureauHit';
    public static final String AUTH_CHOICE_TOO_MANY_ATTEMPTS =  'Error-TooManyAttempts';   
    public static final String AUTH_CHOICE_SUBMITTED_EXAM_AGAIN = 'Error-SubmittedExamAgain';
    public static final String AUTH_CHOICE_TECHNICAL_ISSUE = 'Error-TechnicalIssue';
  
    
    public static TransUnionWS.ProcessResponse_element sendAuthenticationRequest(Id applicationId) {
    	
        afSettings = Application_Form_Settings__c.getOrgDefaults();

        Application__c application = [SELECT Id, Name, First_Name__c, Last_Name__c, Birth_Date__c, Permanent_Address_PostalCode__c, 
        Permanent_Address_City__c, Permanent_Address_Province__c, Permanent_Address_Street_Number__c, Permanent_Address_Street_Name__c, 
        Permanent_Address_Unit_Number__c, Home_Phone__c, SIN__c FROM Application__c WHERE Id =: applicationId];

        TransUnionProvinceCodes__c transUnionProvinceCode = TransUnionProvinceCodes__c.getValues(application.Permanent_Address_Province__c);

        String provinceCode = transUnionProvinceCode.Province_Code__c;

        String externalId = 'AffirmFinancial_' + application.Name + DateTime.now().format('yyyyMMdd_HHmmssSSS');
        
        TransUnionIdAuthElements.IDAuthentication idAuthElem = new TransUnionIdAuthElements.IDAuthentication();
        
        TransUnionIdAuthElements.Request reqElem = new TransUnionIdAuthElements.Request();
        idAuthElem.Request = reqElem;
        idAuthElem.xmlns = 'http://www.transunion.ca/WS/IDAuthentication';
        
        reqElem.MemberId = afSettings.Trans_Union_Member_Id__c;
        reqElem.Password = afSettings.Trans_Union_Password__c;
        reqElem.ExternalId = externalId;
        
        TransUnionIdAuthElements.NewSession newSessionElem = new TransUnionIdAuthElements.NewSession();
        reqElem.NewSession = newSessionElem;
        newSessionElem.Language = '1';
        newSessionElem.ProcessId = afSettings.Trans_Union_Process_Id__c;
        
        TransUnionIdAuthElements.Subject subjElem = new TransUnionIdAuthElements.Subject();
        newSessionElem.Subject = subjElem;
        
        TransUnionIdAuthElements.Consumer consumerElem = new TransUnionIdAuthElements.Consumer();
        subjElem.Consumer = consumerElem;
        
        TransUnionIdAuthElements.Customer customerElem = new TransUnionIdAuthElements.Customer();
        consumerElem.Customer = customerElem;
        
        TransUnionIdAuthElements.Name nameElem = new TransUnionIdAuthElements.Name();
        customerElem.Name = nameElem;
        nameElem.First = application.First_Name__c;
        nameElem.Last = application.Last_Name__c;
        
        TransUnionIdAuthElements.PersonalInfo piElem = new TransUnionIdAuthElements.PersonalInfo();
        customerElem.PersonalInfo = piElem;
        
        Datetime birthDate = datetime.newInstance(application.Birth_Date__c.year(), application.Birth_Date__c.month(),application.Birth_Date__c.day());
        piElem.BirthDate = birthDate.format('MM/dd/yyyy');
        
        //Added by A5E Consulting
      	//Email Athentication Changes
        if (!String.isBlank(application.SIN__c)){
          piElem.SIN = application.SIN__c;
        }
        
        
        TransUnionIdAuthElements.Residence resElem = new TransUnionIdAuthElements.Residence();
        consumerElem.Residence = resElem;
        
        TransUnionIdAuthElements.Address addrElem = new TransUnionIdAuthElements.Address();
        resElem.Address = addrElem;
        
        addrElem.Country = 'CA'; //TODO: add country field for possible future expansion?
        addrElem.City = application.Permanent_Address_City__c;
        addrElem.StProv = provinceCode;
        addrElem.ZipPostal = application.Permanent_Address_PostalCode__c;
        
        TransUnionIdAuthElements.UnparsedAddr unparsedAddrElem = new TransUnionIdAuthElements.UnparsedAddr();
        addrElem.UnparsedAddr = unparsedAddrElem;
        unparsedAddrElem.Line1 = application.Permanent_Address_Street_Number__c + ' ' + application.Permanent_Address_Street_Name__c;
        if (application.Permanent_Address_Unit_Number__c != null) {
          unparsedAddrElem.Line1 += (' ' + application.Permanent_Address_Unit_Number__c);
        }

        TransUnionIdAuthElements.Phone phoneElem = new TransUnionIdAuthElements.Phone();
        addrElem.Phone = new List<TransUnionIdAuthElements.Phone>();
        addrElem.Phone.add(phoneElem);
        
        phoneElem.Number_x = application.Home_Phone__c.replaceAll('[^0-9]', '');
        
        return sendRequest(idAuthElem, application, 'Get Questions');
    }

    /**
     *  @description SOAP call to send answers to verification questions
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2015-12-21
     */
    public static TransUnionWS.ProcessResponse_element sendAnswersRequest(
            Application__c application, String externalId, String sessionId, List<TransUnionIdAuthElements.Answer> answers) {
        afSettings = Application_Form_Settings__c.getOrgDefaults();
        
        TransUnionIdAuthElements.IDAuthentication idAuthElem = new TransUnionIdAuthElements.IDAuthentication();
        
        TransUnionIdAuthElements.Request reqElem = new TransUnionIdAuthElements.Request();
        idAuthElem.Request = reqElem;
        idAuthElem.xmlns = 'http://www.transunion.ca/WS/IDAuthentication';
        
        reqElem.MemberId = afSettings.Trans_Union_Member_Id__c;
        reqElem.Password = afSettings.Trans_Union_Password__c;
        reqElem.ExternalId = externalId;
        
        TransUnionIdAuthElements.Answers answersElem = new TransUnionIdAuthElements.Answers();
        reqElem.Answers = answersElem;

        answersElem.SessionId = sessionId;
        answersElem.Answer = answers;
        
        return sendRequest(idAuthElem, application, 'Submit Answers');
    }

    private static TransUnionWS.ProcessResponse_element sendRequest(
        TransUnionIdAuthElements.IDAuthentication idAuthElem, Application__c application, String endPointAction) {
        TransUnionWS.soap transUnionSoap = new TransUnionWS.soap();
        transUnionSoap.timeout_x = afSettings.Request_Timeout__c.intValue();
        TransUnionWS.ProcessResponse_element respElem;
        
        try {
            respElem = transUnionSoap.Process(idAuthElem);
            System.debug('Reply: ' + respElem.oIDAuthentication.Reply);
      
		    //Error message changes
		    //Updated by A5E Consulting
		    /*
            if (respElem.oIDAuthentication.Reply.Error != null) {
                API_Error__c apiError = new API_Error__c(
                    Application__c = application.Id, End_Point__c = 'TransUnion', Action__c = 'Get Questions'
                );
                apiError.Request__c = idAuthElem.toString();
                if (respElem != null) {
                    apiError.Response__c = respElem.toString();
                }
                String errText = '';
                for (TransUnionIdAuthElements.Error err : respElem.oIDAuthentication.Reply.Error) {
                    errText += err.Code + ': ' + err.Text + '\n';
                }
                apiError.Error__c = errText;
                insert apiError;

                respElem = null;
            }
            */
            if (respElem.oIDAuthentication.Reply.Error != null) {
            	
            	Set<String> erroMessageCodes = getErrorMessageCodes();
              
              	String errText = '';
                for (TransUnionIdAuthElements.Error err : respElem.oIDAuthentication.Reply.Error) {
                	
                	if(erroMessageCodes.contains(err.Code)){
                    	return respElem;
                  	}
                    
                    errText += err.Code + ': ' + err.Text + '\n';
                }
                
                API_Error__c apiError = new API_Error__c(
                    Application__c = application.Id, End_Point__c = 'TransUnion', Action__c = 'Get Questions'
                );
                apiError.Request__c = idAuthElem.toString();
                if (respElem != null) {
                    apiError.Response__c = respElem.toString();
                }
                
                apiError.Error__c = errText;
                insert apiError;

                respElem = null;
            }
        } catch (Exception e) {
            API_Error__c apiError = new API_Error__c(
                Application__c = application.Id, End_Point__c = 'TransUnion', Action__c = endPointAction
            );
            apiError.Request__c = idAuthElem.toString();
            if (respElem != null) {
                apiError.Response__c = respElem.toString();
            }
            apiError.Error__c = 'Exception: ' + e.getTypeName();
            apiError.Error__c += '\nMessage: ' + e.getMessage();
            apiError.Error__c += '\nStack trace:\n' + e.getStackTraceString();

            insert apiError;

            respElem = null;
        }

        return respElem;
    }

    private static String toXML(TransUnionIdAuthElements.IDAuthentication idAuthElem) {
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument('UTF-8', '1.0');

        if (idAuthElem.Request != null) {
            
        }

        return w.getXmlString();
    }
    
    //Error message changes
    //Added by A5E Consulting
    private static Set<String> getErrorMessageCodes(){
      
      Set<String> erroMessageCodes = new Set<String>(); 
      erroMessageCodes.add('20003');
      erroMessageCodes.add('20006');
      erroMessageCodes.add('20002');
      erroMessageCodes.add('20000');
      
      return erroMessageCodes;
    }
}