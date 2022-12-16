/**************************************************************************************************
*
*  Class:   
*
*  @description : MegasysWSUtil that contains method for MegaSys login, pass XML to MegaSys, MegaSys Logout etc.
*  @author : A5E Consulting
*  @date : 08/25/2016   

*************************************************************************************************/
public Class MegasysWSUtil{
    
    // Default error message
    private static final String UNEXP_ERROR_MESSAGE = 'An unexpected error has occurred';
    
    // HTTP constants
    private static final String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
    private static final String xsd = 'http://www.w3.org/2001/XMLSchema';
    private static final String serviceNS = 'http://omega.megasys.net/Client/WebServices/';
        
    // HTTP constants
    private static final Integer MAX_TIMEOUT = 120000;
    private static final Integer MIN_TIMEOUT = 1;
    
    //get custom setting records that contain Username, Password, Clientnumber etc for MegaSys
    private static Loan_ReEngineering__c megaSysCS = Loan_ReEngineering__c.getOrgDefaults();
    
    private static Map<String, String> maplistClassNum = MegaSysUtilities.getClassNumber();
    
    //Execution
    /*
    public static Boolean execute(Application__c app){    
        if(app != null){
            
            try{
                
                //send http request XML for Login and get token from MegaSys
                String token = getRespoceLogin(app);
                
                HTTPResponse responce = null;
                //send http request XML for get response from MegaSys
                if(String.isNotBlank(token)){
                    responce = getXMLSingleNewAccountImport(app, token);
                }
                
                //send http request XML for Logout from MegaSys
                if(String.isNotBlank(token)){
                    getRespoceLogout(app, token);
                }
            }
            catch(Exception e){
                System.debug('Error-'+e.getMessage());
                isSuccess = false;
            }
        }
        return isSuccess;    
    }
    */
    
    //Execution
    public static Boolean execute(Application__c app){ 
    	
    	Boolean isSuccess = true;
    	Product__c prod;
    	   
        if(app != null){
            
            try{     
            	//Create Product Record           
                prod = MegaSysUtilities.createProdRecord(app);  
                
                //Update Application Record
                MegaSysUtilities.updateApplication(app); 
                
                //Megasys Callout            
                handleMegasysCallout(app.Id, prod.Id);
            }
            catch(Exception exp){
            	//handleMegasysException(app, prod);            	
                System.debug('Exception :'+exp.getMessage());
                isSuccess = false;
            }
        }
        return isSuccess;   
    }
    
    @future(callout=true)
    public static void handleMegasysCallout(Id appId, Id prodId){
    	Application__c app = MegaSysUtilities.getApplicationById(appId);
    	Product__c prod = MegaSysUtilities.getProductById(prodId);
    	
    	if(app != null){
            
            try{
                
                //send http request XML for Login and get token from MegaSys
                String token = getRespoceLogin(app, prod);
                
                HTTPResponse responce = null;
                
                //send http request XML for get response from MegaSys
                if(String.isNotBlank(token)){
                    responce = getXMLSingleNewAccountImport(app, prod, token);
                }
                
                //send http request XML for Logout from MegaSys
                if(String.isNotBlank(token)){
                    getRespoceLogout(app, prod, token);
                }
            }
            catch(Exception exp){
            	//handleMegasysException(app, prod);            	
                System.debug('Exception :'+exp.getMessage());              
            }
        }
    }
    
    //send http request XML for Login and get token from MegaSys
    public static String getRespoceLogin(Application__c app, Product__c prod){
        
        HttpRequest req = getMegaSysReqXml('Login', null, null, app, prod);
        System.debug('getRespoceLogin request : '+req.getBody());
            
        HTTPResponse res = null;
        try{
            // Send Login request
            Http http = new Http();
            res = http.send(req);
            System.debug('getRespoceLogin response : '+res.getBody());
            System.debug('getRespoceLogin response Status: '+res.getStatus());
            
            if (res.getStatusCode() == 200){
                return getDataFromResponse(res.getBody(), 'LoginResult');
            } 
            else{
            	//handleMegasysException(app, prod);            	
                
                API_Error__c apiError = writeErrorRequest(app,req,'MegaSys', 'MegaSys Login');
                writeErrorResponse(apiError, res);
                insert apiError;
                
                return null;
            }
        }
        catch(Exception e){
        	//handleMegasysException(app, prod);            	
                
            API_Error__c apiError = writeErrorRequest(app, req, 'MegaSys', 'MegaSys Login');
            writeErrorResponse(apiError, res);
            insert apiError;
            
            return null;
        }    
    }
    
    //send http request XML for get response from MegaSys
    public static HTTPResponse getXMLSingleNewAccountImport(Application__c app, Product__c prod, String token){
        
        HttpRequest req = getMegaSysReqXml('SingleNewAccountImport', token , megaSysCS.Megasys_Account_Import_Code__c, app, prod);
        HTTPResponse res = null;
        
        try{
            Http http = new Http();
            res = http.send(req);
            parseAccntImportResponse(req, res, app, prod);
            
            return res;
        }
        catch(Exception e){
        	//handleMegasysException(app, prod);            	
                
            API_Error__c apiError = writeErrorRequest(app, req, 'MegaSys', 'MegaSys Service');
            writeErrorResponse(apiError, res);
            insert apiError;
            return null;
        }
    }
    
    //send http request XML for Logout from MegaSys
    public static void getRespoceLogout(Application__c app, Product__c prod, String token){
        
        HttpRequest req = getMegaSysReqXml('Logout', token, null, app, prod);
        
        HTTPResponse res = null;
        try{
            //Send logout request
            Http http = new Http();
            res = http.send(req);
            
            if (res.getStatusCode() == 200){
                //do nothing                
            } 
            else{
                API_Error__c apiError = writeErrorRequest(app, req, 'MegaSys', 'MegaSys Logout');
                writeErrorResponse(apiError, res);
            }
        }
        catch(Exception e){
            API_Error__c apiError = writeErrorRequest(app, req, 'MegaSys', 'MegaSys Logout');
            writeErrorResponse(apiError, res);
        }    
    }
    
    //Create XML for SingleNewAccountImport
    public static String createMegasysXML(Application__c appln, Product__c prod){
        
        MegasysWS.Customers_element megaSysele = New MegasysWS.Customers_element();
        
        MegasysWS.Customers customerUnderCustomers = New MegasysWS.Customers();
        MegasysWS.Customer customerUnderCustomer = New MegasysWS.Customer();
        customerUnderCustomer.fieldValues.put('CustomerNumber', '1');
        customerUnderCustomer.fieldValues.put('FirstName', appln.First_Name__c);
        
        if(String.isNotBlank(appln.Middle_Name__c)){
            customerUnderCustomer.fieldValues.put('MiddleName', appln.Middle_Name__c);
        }
        
        customerUnderCustomer.fieldValues.put('LastName', appln.Last_Name__c);
        
        if(String.isNotBlank(appln.Alias_Name__c)){
            customerUnderCustomer.fieldValues.put('AKAName', appln.Alias_Name__c);
        }
        
        if(String.isNotBlank(appln.SIN__c)){
            customerUnderCustomer.fieldValues.put('SocialSecurityNumber', appln.SIN__c);
        }
        
        customerUnderCustomer.fieldValues.put('LanguageCode', 'English');
        
        if(appln.Birth_Date__c != null){
            customerUnderCustomer.fieldValues.put('Birthdate', dateToString(appln.Birth_Date__c));
        }
        
        customerUnderCustomer.fieldValues.put('IsHomeOwner', checkIsHomeOwner(appln.Home_Owner__c));
        
        if(String.isNotBlank(appln.Gender__c)){
            customerUnderCustomer.fieldValues.put('Sex', appln.Gender__c);
        }
        else{
           customerUnderCustomer.fieldValues.put('Sex', 'Not_Selected');
        }
        
        if(String.isNotBlank(appln.Marital_Status__c)){
            customerUnderCustomer.fieldValues.put('MaritalStatus', maritualStatus(appln.Marital_Status__c));
        }
        else{
            customerUnderCustomer.fieldValues.put('MaritalStatus', 'Not_Selected');
        }
        
        if(appln.Number_of_Dependants__c != 'More'){
            customerUnderCustomer.fieldValues.put('NumberOfDependents', appln.Number_of_Dependants__c);
        }
        
        if(String.isNotBlank(appln.Email_Address__c)){
            customerUnderCustomer.fieldValues.put('CustomerEmailAddress', appln.Email_Address__c);
        }
        
        customerUnderCustomer.fieldValues.put('PrimaryAddressAsOfDate', dateToString(primaryAddressAsOfDate(appln)));
        
        if(appln.Monthly_Expenses__c != null){
            customerUnderCustomer.fieldValues.put('ExpenseRent', appln.Monthly_Expenses__c);
        }
        
        MegasysWS.PhysicalAddress physicalAddress= New MegasysWS.PhysicalAddress();
        /*
        physicalAddress.fieldValues.put('AddressLine1', addressLine1(appln));
        physicalAddress.fieldValues.put('AddressLine2', addressLine2(appln));
        physicalAddress.fieldValues.put('AddressLine3', addressLine3(appln));
        */
        physicalAddress.fieldValues.put('AddressLine1', MegaSysUtilities.getAddressLine1(appln.Permanent_Address_Unit_Number__c,appln.Permanent_Address_Street_Number__c ,appln.Permanent_Address_Street_Name__c));
        
        if(String.isNotBlank(appln.Permanent_Address_PO_BOX__c)){
            physicalAddress.fieldValues.put('AddressLine2', MegaSysUtilities.getAddressLine2(appln.Permanent_Address_PO_BOX__c));
        }
        
        physicalAddress.fieldValues.put('City', appln.Permanent_Address_City__c);
        physicalAddress.fieldValues.put('ProvinceCode', appln.Permanent_Address_Province__c);
        physicalAddress.fieldValues.put('ProvinceCountry', 'Canada');
        physicalAddress.fieldValues.put('ZipCode', zipCode(appln.Permanent_Address_PostalCode__c));
        physicalAddress.fieldValues.put('AddressType', appln.Permanent_Address_Type__c);
        physicalAddress.fieldValues.put('AddressIsPrimary', true);
        customerUnderCustomer.fieldValues.put('PhysicalAddress', physicalAddress);
        
        /*
        MegasysWS.CustomerPhoneNumbers customerPhoneNumbers = New MegasysWS.CustomerPhoneNumbers();
        
        MegasysWS.Numbers numbers = New MegasysWS.Numbers();
        if(appln.Home_Phone__c != null){            
            numbers.fieldValues.put('PhoneNumber', appln.Home_Phone__c);
            numbers.fieldValues.put('PhoneNumberType', 'Home');
        }
        else{
            numbers.fieldValues.put('PhoneNumber', appln.Work_Phone__c);
            numbers.fieldValues.put('PhoneNumberType', 'Work');
        }
        
        if(appln.Cell_Phone__c != null && appln.Work_Phone__c == null && appln.Home_Phone__c == null )
        {
            numbers.fieldValues.put('PhoneNumber', appln.cell_Phone__c);
            numbers.fieldValues.put('PhoneNumberType', 'Cell');
        }
        numbers.fieldValues.put('NumberIsPrimary', true);
        customerPhoneNumbers.fieldValues.put('Number', numbers);
        customerUnderCustomer.fieldValues.put('CustomerPhoneNumbers', customerPhoneNumbers);
        */
        
        if(appln.Home_Phone__c!= null || appln.Cell_Phone__c!= null || appln.Work_Phone__c!= null){
            MegasysWS.CustomerPhoneNumbers customerPhoneNumbers = New MegasysWS.CustomerPhoneNumbers();
            customerUnderCustomer.fieldValues.put('CustomerPhoneNumbers', customerPhoneNumbers);
            
            List<MegasysWS.XMLComplexType> numberList = new List<MegasysWS.XMLComplexType>();
            customerPhoneNumbers.fieldValues.put('Number', numberList);
            MegasysWS.Numbers numbers;
            
            //send all the 3 numbers to MegaSys if availble
            if(appln.Home_Phone__c != null){
                numbers = New MegasysWS.Numbers();
                numberList.add(numbers);
                numbers.fieldValues.put('PhoneNumber', appln.Home_Phone__c);
                numbers.fieldValues.put('PhoneNumberType', 'Home');
                numbers.fieldValues.put('NumberIsPrimary', true);
            }
            
            if(appln.Work_Phone__c != null){
                numbers = New MegasysWS.Numbers();
                numberList.add(numbers);
                numbers.fieldValues.put('PhoneNumber', appln.Work_Phone__c);
                numbers.fieldValues.put('PhoneNumberType', 'Work');
                if(appln.Home_Phone__c != null){
                    numbers.fieldValues.put('NumberIsPrimary', false);
                }
                else{
                    numbers.fieldValues.put('NumberIsPrimary', true);
                }
            }
            
            if(appln.Cell_Phone__c != null){
                numbers = New MegasysWS.Numbers();
                numberList.add(numbers);
                numbers.fieldValues.put('PhoneNumber', appln.cell_Phone__c);
                numbers.fieldValues.put('PhoneNumberType', 'Cell');
                
                if(appln.Home_Phone__c == null && appln.Work_Phone__c == null ){
                    numbers.fieldValues.put('NumberIsPrimary', true);
                }
                else{
                    numbers.fieldValues.put('NumberIsPrimary', false);
                }
            }
        }        
        
        MegasysWS.CustomerEmployers CustomerEmployers = New MegasysWS.CustomerEmployers();
        
        MegasysWS.Employer employer = New MegasysWS.Employer();
        employer.fieldValues.put('EmployerName', appln.Employer_Name__c);
        employer.fieldValues.put('EmployeeStartDate', dateToString(employeeStartDate(appln)));
        
        if(appln.Gross_Monthly_Income__c != null){
            employer.fieldValues.put('EmployeeSalary', appln.Gross_Monthly_Income__c);
        }
        if(String.isNotBlank(appln.Payment__c)){
            employer.fieldValues.put('EmployeeSalaryFrequency', appln.Payment__c);
        }
        
        if(String.isNotBlank(appln.Occupation__c)){
            employer.fieldValues.put('EmployeeOccupation', appln.Occupation__c);
        }
        
        if(appln.Employer_Phone__c != null){
            MegasysWS.EmployerPhoneNumber employerPhoneNumber = New MegasysWS.EmployerPhoneNumber();
            employerPhoneNumber.fieldValues.put('PhoneNumber', appln.Employer_Phone__c);
            employerPhoneNumber.fieldValues.put('PhoneNumberType', 'Work');
            employerPhoneNumber.fieldValues.put('NumberIsPrimary', true);
            employer.fieldValues.put('EmployerPhoneNumber', employerPhoneNumber);
        }
        
        if(String.isNotBlank(appln.Employer_Unit_Number__c) || String.isNotBlank(appln.Employer_Street_Number__c) || String.isNotBlank(appln.Employer_Street_Name__c)){
        
            MegasysWS.EmployerAddress EmployerAddress = New MegasysWS.EmployerAddress();
            /*
            EmployerAddress.fieldValues.put('AddressLine1', employerAddressLine1(appln));
            EmployerAddress.fieldValues.put('AddressLine2', employerAddressLine2(appln));
            EmployerAddress.fieldValues.put('AddressLine3', employerAddressLine3(appln));
            */
            EmployerAddress.fieldValues.put('AddressLine1', MegaSysUtilities.getAddressLine1(appln.Employer_Unit_Number__c, appln.Employer_Street_Number__c ,appln.Employer_Street_Name__c ));
            
            if(String.isNotBlank(appln.Employer_PO_BOX__c)){
                EmployerAddress.fieldValues.put('AddressLine2', MegaSysUtilities.getAddressLine2(appln.Employer_PO_BOX__c));
            }
            
            if(String.isNotBlank(appln.Employer_City__c)){        
                EmployerAddress.fieldValues.put('City', appln.Employer_City__c);
            }
            
            if(String.isNotBlank(appln.Employer_Province__c)){
                EmployerAddress.fieldValues.put('ProvinceCode', appln.Employer_Province__c);
            }
            
            EmployerAddress.fieldValues.put('ProvinceCountry', 'Canada');
            
            if(String.isNotBlank(appln.Employer_PostalCode__c)){
                EmployerAddress.fieldValues.put('ZipCode', zipCode(appln.Employer_PostalCode__c));
            }
            
            if(String.isNotBlank(appln.Employer_Address_Type__c)){
                EmployerAddress.fieldValues.put('AddressType', appln.Employer_Address_Type__c);
            }
            
            EmployerAddress.fieldValues.put('AddressIsPrimary', true);
            
            employer.fieldValues.put('EmployerAddress', employerAddress);
        }   
        
        customerEmployers.fieldValues.put('Employer', employer);
        
        customerUnderCustomer.fieldValues.put('CustomerEmployers', customerEmployers);
        
        
        customerUnderCustomers.fieldValues.put('Customer', customerUnderCustomer);
        megaSysele.fieldValues.put('Customers', customerUnderCustomers);
        
        System.debug('customerUnderCustomers END:');
        //----End AccountCustomers
        
        
        MegasysWS.NewAccount newAccount = New MegasysWS.NewAccount();
        
        MegasysWS.AccountGeneral accountGeneral = New MegasysWS.AccountGeneral();
        accountGeneral.fieldValues.put('BranchNumber', '1');
        accountGeneral.fieldValues.put('OpenDate', dateToString(appln.Loan_Start_Date__c));
        accountGeneral.fieldValues.put('ClassNumber', maplistClassNum.get(appln.Permanent_Address_Province__c));
        accountGeneral.fieldValues.put('AdminStatusCode', 'A');
        accountGeneral.fieldValues.put('PaymentFrequency', appln.Payment__c);
        
        if(String.isNotBlank(appln.Application_Number__c)){
            accountGeneral.fieldValues.put('ContractNumber', appln.Application_Number__c);
        }
        accountGeneral.fieldValues.put('APR', interestRate(appln.Interest_Rate__c));
        System.debug('appln.Interest_Rate__c :'+appln.Interest_Rate__c);
        System.debug('appln APR :'+interestRate(appln.Interest_Rate__c));
        accountGeneral.fieldValues.put('FirstDueDate', dateToString(appln.First_Payment_Date__c));
        accountGeneral.fieldValues.put('ActualTerm', appln.Number_of_Payments__c);
        accountGeneral.fieldValues.put('Rate', interestRate(appln.Interest_Rate__c));
        accountGeneral.fieldValues.put('FirstPaymentAmount', appln.First_Payment_Amount__c);
        accountGeneral.fieldValues.put('RegularPaymentAmount', appln.Regular_Payment_Amount__c);
        accountGeneral.fieldValues.put('FinalPaymentAmount', appln.Regular_Payment_Amount__c);
        accountGeneral.fieldValues.put('RateType', 'APR');
        accountGeneral.fieldValues.put('TotalOfPayments', appln.Total_of_Payment__c);
        accountGeneral.fieldValues.put('AmortizedTerm', appln.Number_of_Payments__c);
        accountGeneral.fieldValues.put('InterestStartDate', dateToString(appln.Loan_Start_Date__c));
        accountGeneral.fieldValues.put('AmountFinanced', appln.Loan_Amount__c);
        accountGeneral.fieldValues.put('CashPrice', appln.Loan_Amount__c);
        
        //Reference Number
        /*
        if(String.isNotBlank(appln.Customer__r.SF_ID__c)){
            accountGeneral.fieldValues.put('ReferenceNumber', appln.Customer__r.SF_ID__c);
        }
        */
        accountGeneral.fieldValues.put('ReferenceNumber', prod.Id);
        
        System.debug('accountGeneral END:');
        
        newAccount.fieldValues.put('AccountGeneral', accountGeneral );
        
        newAccount.fieldValues.put('Interest', appln.Total_Interest__c);
        
        MegasysWS.AccountDirect accountDirect= New MegasysWS.AccountDirect();
        accountDirect.fieldValues.put('AcquisitionFeeAmount', '0');
        accountDirect.fieldValues.put('PointsAmount', '0');
        newAccount.fieldValues.put('AccountDirect', accountDirect);
        
        
        MegasysWS.AccountCustomers accountCustomers= New MegasysWS.AccountCustomers();
        MegasysWS.AccountCustomersCustomer accountCustomersCustomer= New MegasysWS.AccountCustomersCustomer();
        accountCustomersCustomer.fieldValues.put('CustomerNumber', '1');
        accountCustomersCustomer.fieldValues.put('CustomerType', 'Primary_Customer');
        
        accountCustomers.fieldValues.put('Customer', accountCustomersCustomer);
        
        newAccount.fieldValues.put('AccountCustomers', accountCustomers);
        megaSysele.fieldValues.put('NewAccount', newAccount); 
        
        System.debug('newAccount END:');
        //----End AccountCustomers        
        
        XmlStreamWriter mxw = new XmlStreamWriter();
        mxw.writeStartDocument('UTF-8', '1.0');
        megaSysele.getXMLString(mxw);
        mxw.writeEndDocument();
        
        String megaSyseleXML = mxw.getXmlString();
        mxw.close();
        System.debug('megaSyseleXML :'+megaSyseleXML);
        System.debug('megaSyseleXML :'+megaSysele);
        
        megaSyseleXML.replace('<?xml version="1.0" encoding="UTF-8"?>', '');
        return megaSyseleXML;
    }
    
    //Create megasys request xml for Login, Logout and SingleNewAccountImport
    private static HttpRequest getMegaSysReqXml(String type, String token, String accountImportCode, Application__c app, Product__c prod){
        
        DOM.Document doc = New DOM.Document();
        
        DOM.XMLNode envelope = doc.createRootElement('Envelope', soapNS, 'soap');
        envelope.setNamespace('xsi', xsi);
        envelope.setNamespace('xsd', xsd);
        
        DOM.XMLNode body = envelope.addChildElement('Body', soapNS, null);
        DOM.XMLNode log = body.addChildElement(type, serviceNS,'');
        
        if(type.equalsIgnoreCase('Login')){
            log.addChildElement('clientNumber', null, null).addTextNode(megaSysCS.Megasys_Client_Number__c);
            log.addChildElement('userName', null, null).addTextNode(megaSysCS.Megasys_User_Name__c);
            log.addChildElement('password', null, null).addTextNode(megaSysCS.Megasys_Password__c);
        }
        
        if(type.equalsIgnoreCase('SingleNewAccountImport')){            
            log.addChildElement('token', null, null).addTextNode(token);
            log.addChildElement('accountImportCode', null, null).addTextNode(accountImportCode);
            log.addChildElement('newAccountImportXMLData', null, null).addTextNode(createMegasysXML(app, prod));//newAccountImportXMLData
        }
        
        if(type.equalsIgnoreCase('Logout')){            
            log.addChildElement('token', null, null).addTextNode(token);
        }
        System.debug('Megasys Request xml :'+doc.toXmlString());
        
        HTTPResponse res = null;
        
        //Call webservice via Callouts
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(megaSysCS.Megasys_End_Point__c);
        req.setMethod('POST');        
        req.setHeader('Content-Type','text/xml');
        req.setHeader('Charset','utf-8');
        req.setHeader('SOAPAction','http://omega.megasys.net/Client/WebServices/'+type);
        if (megaSysCS.Request_Timeout__c != null) {
            Integer timeout = Integer.valueOf(megaSysCS.Request_Timeout__c);
            if (timeout >= MIN_TIMEOUT && timeout <= MAX_TIMEOUT) {
                req.setTimeout(timeout);
            }
        }
        req.setBody(doc.toXMLString());
        
        return req;        
    }
    
    //get responce from MegaSys
    public static void parseAccntImportResponse(HttpRequest req, HTTPResponse res, Application__c app, Product__c prod){
        
        Map<String, Dom.XMLNode> derivedVariableByName = new Map<String, Dom.XMLNode>();
		String megaSysAccNum = '';
        
        try{
            Dom.Document soapEnv = res.getBodyDocument();
            Dom.XMLNode rootElem = soapEnv.getRootElement();
            
            megaSysAccNum = getDataFromResponse(res.getBody(), 'SingleNewAccountImportResult');
            
            if(String.isBlank(megaSysAccNum)){
            	//handleMegasysException(app, prod);            	
                
                API_Error__c apiError = writeErrorRequest(app, req, 'MegaSys', 'MegaSys Service');
                writeErrorResponse(apiError, res);
                insert apiError;
            }
            else{
                //Update Megasys Number on Application Field
                //MegaSysUtilities.updateApplication(app, megaSysAccNum);
                MegaSysUtilities.updateMSNumberOnApplication(app, megaSysAccNum);
                
                //Create a product with megaSys Account Number
                //MegaSysUtilities.updatecreateProdRecord(app, megaSysAccNum);
                
                //Update Product record Name
                MegaSysUtilities.updateProdRecord(prod, megaSysAccNum);
            } 
        }
        catch(Exception e){
        	        	
        	//handleMegasysException(app, prod);            	
            
            API_Error__c apiError = writeErrorRequest(app, req, 'MegaSys', 'MegaSys Service');
            writeErrorResponse(apiError, res);
            insert apiError;
            System.debug('Error in Responce'+e.getMessage());
        }
    }
    
    //Fetch responce value between two nodes.
    public static string getDataFromResponse(string xmlStr, string tagName){
        
        string startTag = '<' + tagName + '>';
        string endTag = '</' + tagName + '>';
        
        string finalStr = '';
        
        if(xmlStr.contains(startTag)){          
            if(xmlStr.contains(endTag)) {               
                finalStr = xmlStr.substringBetween(startTag, endTag);                
            }
        }
        return finalStr;
    }
    
    //Populates MegaSys API Error with request information
    private static API_Error__c writeErrorRequest(Application__c app, HttpRequest req, String endpoint, String action) {
        API_Error__c apiError = new API_Error__c();
        apiError.Application__c = app.Id;
        apiError.End_Point__c = endpoint;
        apiError.Action__c = action;
        apiError.Error__c = UNEXP_ERROR_MESSAGE;
        apiError.Request__c = 'Endpoint: ' + req.getEndpoint();
        apiError.Request__c += '\nMethod: ' + req.getMethod();
        apiError.Request__c += '\nHeaders:';
        apiError.Request__c += '\nConnection: ' + req.getHeader('Connection');
        apiError.Request__c += '\nContent-Type: ' + req.getHeader('Content-Type');
        apiError.Request__c += '\nSOAPAction: ' + req.getHeader('SOAPAction');
        apiError.Request__c += '\nBody:\n' + req.getBody().replaceAll('&lt;','<');
        return apiError;
    }
    
    //Populates MegaSys error with response information
    private static void writeErrorResponse(API_Error__c apiError, HttpResponse resp) {
        if(resp!=null){        
            apiError.Response__c = 'Status Code: ' + resp.getStatusCode();
            apiError.Response__c += '\nStatus: ' + resp.getStatus();
            apiError.Response__c += '\nHeaders:';
            for (String h : resp.getHeaderKeys()) {
                if (String.isNotBlank(h)) {
                    apiError.Response__c += '\n' + h + ': ' + resp.getHeader(h);
                }
            }
            apiError.Response__c += '\nBody:\n';
            String respBody = resp.getBody();
            if (String.isNotBlank(respBody)) {
                apiError.Response__c += respBody;
            }
        }     
    }
    
    //Check is Home owner or Not
    private static Boolean checkIsHomeOwner(String ishome){
        
        if(String.isNotBlank(ishome) && ishome.EqualsIgnoreCase('Own Property')){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Convert Date to String with YYYY-MM-DD
    private static String dateToString(Date dt){
        
        if(dt !=null){
            DateTime dtFrmt = DateTime.newInstance(dt.year(), dt.month(),dt.day());
            return dtFrmt.format('yyyy-MM-dd');
        }
        else{
            return '';
        }    
    }
    
    /*
    //AddressLine1
    private static String addressLine1(Application__c app){
        //Permanent_Address_PO_Box__c,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c
        if(String.isNotBlank(app.Permanent_Address_PO_Box__c)){
            return app.Permanent_Address_PO_Box__c;            
        }
        else{
            return app.Permanent_Address_Street_Number__c;
        }
    }
    
    //AddressLine2
    private static String addressLine2(Application__c app){
        
        if(String.isNotBlank(app.Permanent_Address_PO_Box__c)){
            return app.Permanent_Address_Street_Number__c;            
        }
        else{
            return app.Permanent_Address_Street_Name__c;
        }
    }
    
    //AddressLine3
    private static String addressLine3(Application__c app){
        
        if(String.isNotBlank(app.Permanent_Address_PO_Box__c)){
            return app.Permanent_Address_Street_Name__c;            
        }
        else{
            return '';
        }
    }
    
    //Employer AddressLine1
    private static String employerAddressLine1(Application__c app){
        if(String.isNotBlank(app.Employer_PO_Box__c)){
            return app.Employer_PO_Box__c;            
        }
        else{
            return app.Employer_Street_Number__c;
        }
    }
    
    //Employer AddressLine2
    private static String employerAddressLine2(Application__c app){
        
        if(String.isNotBlank(app.Employer_PO_Box__c)){
            return app.Employer_Street_Number__c;            
        }
        else{
            return app.Employer_Street_Name__c;
        }
    }
    
    //Employer AddressLine3
    private static String employerAddressLine3(Application__c app){
        
        if(String.isNotBlank(app.Employer_PO_Box__c)){
            return app.Employer_Street_Name__c;            
        }
        else{
            return '';
        }
    }
    */
    //Calculate Employer Start Date
    private static Date employeeStartDate(Application__c app){
        if(app.Employment_Years__c != null && app.Employment_Months__c != null){
            Date creDate = Date.newInstance(app.CreatedDate.year(),app.CreatedDate.month(),app.CreatedDate.day());
            Date d1 = creDate.addYears(-((Integer)app.Employment_Years__c));
            Date expectedDate = d1.addMonths(-((Integer)app.Employment_Months__c));
            return expectedDate;
        }
        else{
            return null;
        }
    }
    
    //Calculate PrimaryAddressAsOfDate
    private static Date primaryAddressAsOfDate(Application__c app){
        if(app.Months_At_Permanent_Address__c != null && app.Years_At_Permanent_Address__c != null){
            Date creDate = Date.newInstance(app.CreatedDate.year(),app.CreatedDate.month(),app.CreatedDate.day());
            Date d1 = creDate.addYears(-((Integer)app.Years_At_Permanent_Address__c));
            Date expectedDate = d1.addMonths(-((Integer)app.Months_At_Permanent_Address__c));
            return expectedDate;
        }
        else{
            return null;
        }
    }
    
    //return interest rate divide by 100
    private static String interestRate(Decimal interest){
        
        if(interest != null){
            return String.valueof(interest/100);
        }
        else{
            return '';
        }
    }
    
    //return Maritual Status based on values
    @Testvisible
    private static String maritualStatus(String marStatus){
        
        if(marStatus == 'Married'){
            return marStatus;
        }else if(marStatus == 'Single'){
            return marStatus;
        }else{
            return 'Other';
        }
    }
    
    //Remove space from ZipCode
    private static String zipCode(String zipcode){
        if(String.isNotBlank(zipCode)){
            zipcode = zipcode.replaceAll(' ','');
            return zipcode;
        }
        else{
            return '';
        }
    }
    
    //Handle Exceptions, delete Product record created
    /*
    private static void handleMegasysException(Application__c app, Product__c prod){
    	
    	if(prod!=null){
    		if(prod.id!=null){
    			try{
    				delete prod;
    			}
    			catch(Exception exp){
    				//Do nothing
    			}
    		}
    	}
    }
    */
 }