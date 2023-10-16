/**************************************************************************************************
*
*  Class:   
*
*  @description : \ class to create  Customer contact info Staging records and check customer validation  validtaions
*  @author : A5E Consulting
*  @date : 08/03/2022

*************************************************************************************************/
public class CustomerStagingExcelFileProcessing {
    public ID documentId;
    public final String dataDocuments;
    String exceptionMessage;
    String workAssignmentPlacement;
    List<customerContactInfoRecordsWrapper> listCustomerContactInfoRecordsWrapper = new List<customerContactInfoRecordsWrapper>();

    Map<String, Integer> fieldNumberMap = new Map<String, Integer>();

    public CustomerStagingExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId) {
        exceptionMessage = '';
        listCustomerContactInfoRecordsWrapper = deSerializeJSON(data);
        this.workAssignmentPlacement = workAssignmentPlacement;
        this.documentId = documentId;
        processExcelFileRecords();
    }

    public List<customerContactInfoRecordsWrapper> deSerializeJSON(String dataAsString) {
        List<customerContactInfoRecordsWrapper> listCustomerContactInfoRecordsWrapper = (List<customerContactInfoRecordsWrapper>) JSON.deserialize(
            dataAsString,
            List<customerContactInfoRecordsWrapper>.class
        );
        return listCustomerContactInfoRecordsWrapper;
    }

    public void processExcelFileRecords() {
        try {
            List<Product__c> listProductToInsert = new List<Product__c>();

            List<String> customerContactList = new List<String>();
            for (CustomerContactInfoRecordsWrapper wrapRecord : listCustomerContactInfoRecordsWrapper) {
                wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                customerContactList.add(wrapRecord.data_id);
            }
            list<Placement__c> listPlacements = [
                SELECT ID
                FROM Placement__c
                WHERE Name = :workAssignmentPlacement
            ];
            Id placementID;
            if (!listPlacements.isEmpty()) {
                placementID = listPlacements[0].ID;
            }
            Map<Id, Product__c> mapProduct = new Map<Id, Product__c>();
            //Fetch canaccede and fidem accounts
            List<Product__C> listAccount = [
                SELECT
                    id,
                    name,
                    DebtNext_Data_ID__C,
                    Collection_Agency__c,
                    Collection_Sub_Status__c,
                    Current_Balance__c,
                    Status__c,
                    Assignment_Date__c,
                    Recalled_Date__c
                FROM Product__C
                WHERE name IN :customerContactList
            ];

            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            //set<ID> setProdutID = new set<ID>();
            set<String> setPlacementNames = new Set<String>();
            //Rasmitha : 28-Dec Map to check duplicate Account in file
            Map<String, Decimal> mapProductDup = new Map<String, Decimal>();

            for (Product__C accountRecord : listAccount) {
                mapAccountNumberID.put(accountRecord.name, accountRecord.id);
                mapProduct.put(accountRecord.id, accountRecord);
                //setProdutID.add(accountRecord.id);
                setPlacementNames.add(String.valueOf(accountRecord.Collection_Agency__c));
            }
            for (String dataid : customerContactList) {
                if (mapProductDup.containsKey(String.valueOf(dataid))) {
                    mapProductDup.put(String.valueOf(dataid), mapProductDup.get(dataid) + 1);
                } else {
                    mapProductDup.put(String.valueOf(dataid), 1);
                }
            }

            for (CustomerContactInfoRecordsWrapper wrapRecord : listCustomerContactInfoRecordsWrapper) {
                Product__c prod = new Product__c();
                // prod.Name = mapAccountNumberID.get(wrapRecord.data_id);
                prod.Name = wrapRecord.data_id;
                prod.Email_Address__c = wrapRecord.pri_email;
                prod.Address_Line1__c = wrapRecord.pri_add1;
                prod.Address_Line2__c = wrapRecord.pri_add2;
                prod.City__c = wrapRecord.pri_municipality;
                prod.Provinces__c = wrapRecord.pri_province;
                prod.Zip_Code__c = wrapRecord.pri_postcode;
                prod.Country__c = wrapRecord.pri_country;
                prod.Phone_Home__c = wrapRecord.pri_hphone;
                prod.Phone_Work__c = wrapRecord.pri_wphone;
                prod.Phone_Other__c = wrapRecord.pri_cphone;
                prod.Codebtor_Email_Address__c = wrapRecord.sec_email;
                prod.Codebtor_Address_Line1__c = wrapRecord.sec_add1;
                prod.Codebtor_Address_Line2__c = wrapRecord.sec_add2;
                prod.Codebtor_City__c = wrapRecord.sec_municipality;
                prod.Codebtor_State__c = wrapRecord.sec_province;
                prod.Codebtor_Zip_Code__c = wrapRecord.sec_postcode;
                prod.Codebtor_Country__c = wrapRecord.sec_country;
                prod.Codebtor_Phone_Work__c = wrapRecord.sec_wphone;
                prod.Codebtor_Phone_Home__c = wrapRecord.sec_hphone;
                prod.Codebtor_Phone_Other__c = wrapRecord.sec_cphone;

                listProductToInsert.add(prod);
            }

            list<Customer_Staging__c> listCustStaging = validationOnRecordUpdate(
                listProductToInsert,
                setPlacementNames,
                mapAccountNumberID,
                documentId,
                workAssignmentPlacement,
                mapProduct,
                mapProductDup
            );
            Database.SaveResult[] sr = database.insert(listCustStaging);
        } catch (Exception ex) {
            exceptionMessage = String.valueOf(ex.getMessage());
            system.debug('Exception in processExcelFileRecords ::' + ex.getStackTraceString());
        }

        list<Document_Storage__c> listDocuments = [
            SELECT ID, Creator__c, Work_Assignment__c, Uploaded_By__c
            FROM Document_Storage__c
            WHERE ID = :documentID
        ];
        //Send email of File processing completion
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if (!listDocuments.isEmpty() && listDocuments[0].Uploaded_By__c == 'External User' && String.isnotblank(listDocuments[0].Creator__c)) {
            message.toAddresses = new List<String>{ listDocuments[0].Creator__c };
        } else {
            message.setTargetObjectId(UserInfo.getUserId());
        }
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Customer Contact Information Upload Status';
        String processingLink = '';
        String processingStatus = '';
        Boolean stagingCreated = false;

        if (String.isBlank(exceptionMessage)) {
            message.plainTextBody =
                'Please click the link below to review Customer Contact Information: \n' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/CustomerContactInfoUpdatePage?id=' +
                documentId;
            processingLink = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/CustomerContactInfoUpdatePage?id=' + documentId;
            stagingCreated = true;
            processingStatus = 'Staging Table Created';
        } else {
            message.plainTextBody =
                'failed! \nReason: ' +
                exceptionMessage +
                '\n\n' +
                'Please click the link below to view page :\n' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/CustomerContactInfoUpdatePage?id=' +
                documentId;
            if (exceptionMessage.length() > 250) {
                exceptionMessage = exceptionMessage.substring(0, 250);
            } else {
                exceptionMessage = exceptionMessage;
            }
            stagingCreated = false;
            processingStatus = 'Staging Table Creation Failed';
        }
        /*  if(!Test.isRunningTest()){
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }    
        }*/

        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c doc = new Document_Storage__c(
            ID = listDocuments[0].ID,
            File_Processing_Link__c = processingLink,
            File_Processing_Date__c = Date.today(),
            File_processing_Error__c = exceptionMessage,
            File_Processing_Status__c = processingStatus,
            Staging_Records_Created__c = stagingCreated
        );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }

    //Validation method to be called  before update
    public static list<Customer_Staging__c> validationOnRecordUpdate(
        List<Product__c> prodNew,
        set<String> setPlacementNames,
        Map<String, ID> mapAccountNumberID,
        ID documentId,
        String workAssignmentPlacement,
        map<ID, Product__c> mapProduct1,
        map<String, Decimal> mapProductDup
    ) {
        Map<String, Product__c> mapProduct = new Map<String, Product__c>();

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        String phoneNumberRegex = '[0-9]{3}[-][0-9]{3}[-][0-9]{4}';

        list<Customer_Staging__c> listcustconinfoStaging = new List<Customer_Staging__c>();
        Customer_Staging__c customerUpdateStaging = new Customer_Staging__c();

        for (Product__c prod : [
            SELECT
                ID,
                Name,
                Collection_Agency_Placement__c,
                Collection_Sub_Status__c,
                Current_Balance__c,
                Assignment_Date__c,
                Recalled_Date__c,
                Product_Status__c,
                Status__c,
                Collection_Agency__c,
                Data_Status_Description__c,
                Email_Address__c
            FROM Product__c
            WHERE id IN :mapProduct1.keySet()
        ]) {
            mapProduct.put(prod.Name, prod);
        }
        for (Product__c prod : prodNew) {
            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';
            Matcher MyMatcherHome;
            Matcher MyMatcherWork;
            Matcher MyMatcherOther;
            Matcher MyMatcherHomeSec;
            Matcher MyMatcherWorkSec;
            Matcher MyMatcherOtherSec;
            Pattern MyPattern1 = Pattern.compile(phoneNumberRegex);
            if (prod.Phone_Home__c != null) {
                MyMatcherHome = MyPattern1.matcher(prod.Phone_Home__c);
            }
            if (prod.Phone_Work__c != null) {
                MyMatcherWork = MyPattern1.matcher(prod.Phone_Work__c);
            }
            if (prod.Phone_Other__c != null) {
                MyMatcherOther = MyPattern1.matcher(prod.Phone_Other__c);
            }
            if (prod.Codebtor_Phone_Home__c != null) {
                MyMatcherHomeSec = MyPattern1.matcher(prod.Codebtor_Phone_Home__c);
            }
            if (prod.Codebtor_Phone_Work__c != null) {
                MyMatcherWorkSec = MyPattern1.matcher(prod.Codebtor_Phone_Work__c);
            }
            if (prod.Codebtor_Phone_Other__c != null) {
                MyMatcherOtherSec = MyPattern1.matcher(prod.Codebtor_Phone_Other__c);
            }
            if (
                (MyMatcherHome != null &&
                MyMatcherHome.matches() == false) ||
                (MyMatcherWork != null &&
                MyMatcherWork.matches() == false) ||
                (MyMatcherOther != null &&
                MyMatcherOther.matches() == false) ||
                (MyMatcherHomeSec != null &&
                MyMatcherHomeSec.matches() == false) ||
                (MyMatcherWorkSec != null &&
                MyMatcherWorkSec.matches() == false) ||
                (MyMatcherOtherSec != null &&
                MyMatcherOtherSec.matches() == false)
            ) {
                ERROR_MSG += '<b>WARNING</b> - Invalid Phone Number.<br/>';
                EXPECTED += 'Phone numbers should have a format of ###-###-#### <br/>';
            }

            String newAgency = '';
            /*if(mapProduct.containsKey(prod.Name) && mapProduct.get(prod.Name).Collection_Agency__c == null){   
               system.debug('inside if condition collection agency');
                  ERROR_MSG += '<b>WARNING</b> - Placement Number Missing.<br/>';
            }
             */
            if (mapProduct.containsKey(prod.Name) && mapProduct.get(prod.Name).Collection_Agency__c != null) {
                newAgency = String.valueOf(Math.floor(mapProduct.get(prod.Name).Collection_Agency__c));
            }
            if (mapProduct.containsKey(prod.Name) && mapProduct.get(prod.Name).Status__c != null && mapProduct.get(prod.Name).Status__c.startswith('Recall')) {
                ERROR_MSG += '<b>WARNING</b> - Product is in Recall Status.<br/>';
            }
            //Account must not be closed
            if (
                mapProduct.containsKey(prod.Name) &&
                String.isnotblank(mapProduct.get(prod.Name).Data_Status_Description__c) &&
                mapProduct.get(prod.Name).Data_Status_Description__c.startsWith('Closed')
            ) {
                ERROR_MSG += '<b>WARNING</b> - Account is closed.<br/>';
            }
            //this validation for valid the product from two different agency.
            if (String.isNotBlank(workAssignmentPlacement) && workAssignmentPlacement != newAgency) {
                //10-Jan Pushpa : for 4178 changed Warning to Error
                ERROR_MSG += '<b>ERROR</b> - This account is not available in this Placement.<br/>';
                if (newAgency == '') {
                    EXPECTED += 'WorkAssignment Agency = ' + workAssignmentPlacement + '.<br/>Product Agency is not assign.<br/>';
                } else {
                    EXPECTED += 'WorkAssignment Agency = ' + workAssignmentPlacement + '.<br/>Product Agency = ' + newAgency + '.<br/>';
                }
            }

            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher;
            Matcher MyMatchersec;
            if (prod.Email_Address__c != null) {
                MyMatcher = MyPattern.matcher(prod.Email_Address__c);
            }
            if (prod.Codebtor_Email_Address__c != null) {
                MyMatchersec = MyPattern.matcher(prod.Codebtor_Email_Address__c);
            }

            if ((MyMatcher != null && MyMatcher.matches() == false) || (MyMatchersec != null && MyMatchersec.matches() == false)) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Email Address.<br/>';
                EXPECTED += 'Emails should have a format of xxxxx@xxxxx.xxx <br/>';
            }

            if (!mapProduct.containsKey(prod.Name)) {
                ERROR_MSG += '<b>ERROR</b> - Account not found.<br/>';
            }
            if (mapProductDup.containsKey(prod.Name) && mapProductDup.get(prod.Name) > 1) {
                ERROR_MSG += '<b>ERROR</b> - A duplicate transaction was found in this File Update.<br/>';
            }
            customerUpdateStaging = new Customer_Staging__c();
            customerUpdateStaging.ProdID__c = prod.Name;
            customerUpdateStaging.Email_Address__c = prod.Email_Address__c;
            customerUpdateStaging.Address_Line1__c = prod.Address_Line1__c;
            customerUpdateStaging.Address_Line2__c = prod.Address_Line2__c;
            customerUpdateStaging.City__c = prod.City__c;
            customerUpdateStaging.State__c = prod.Provinces__c;
            customerUpdateStaging.Postal_Code__c = prod.Zip_Code__c;
            customerUpdateStaging.Country__c = prod.Country__c;
            customerUpdateStaging.Home_Phone__c = prod.Phone_Home__c;
            customerUpdateStaging.Work_Phone__c = prod.Phone_Work__c;
            customerUpdateStaging.Cell_Phone__c = prod.Phone_Other__c;
            customerUpdateStaging.Coborrower_Email__c = prod.Codebtor_Email_Address__c;
            customerUpdateStaging.Coborrower_Address1__c = prod.Codebtor_Address_Line1__c;
            customerUpdateStaging.Coborrower_Address2__c = prod.Codebtor_Address_Line2__c;
            customerUpdateStaging.Coborrower_City__c = prod.Codebtor_City__c;
            customerUpdateStaging.Coborrower_State__c = prod.Codebtor_State__c;
            customerUpdateStaging.Coborrower_Postal_Code__c = prod.Codebtor_Zip_Code__c;
            customerUpdateStaging.Coborrower_Country__c = prod.Codebtor_Country__c;
            customerUpdateStaging.Coborrower_Work_Phone__c = prod.Codebtor_Phone_Work__c;
            customerUpdateStaging.Coborrower_Home_Phone__c = prod.Codebtor_Phone_Home__c;
            customerUpdateStaging.Coborrower_Cell_Phone__c = prod.Codebtor_Phone_Other__c;
            customerUpdateStaging.Status__c = 'Pending';
            customerUpdateStaging.Identifier__c = documentId;
            customerUpdateStaging.Placement_Agency__c = workAssignmentPlacement;
            customerUpdateStaging.Document_Storage__c = documentId;
            customerUpdateStaging.Comment__c = ERROR_MSG;
            if (mapAccountNumberID.containsKey(prod.Name)) {
                customerUpdateStaging.Product_ID__c = mapAccountNumberID.get(prod.Name);
            }
            if (String.isBlank(ERROR_MSG)) {
                customerUpdateStaging.Comment__c = 'SUCCESS';
                customerUpdateStaging.Include_in_Processing__c = true;
            }
            if (String.isNotBlank(EXPECTED)) {
                customerUpdateStaging.Expected_Value__c = EXPECTED;
            }
            listcustconinfoStaging.add(customerUpdateStaging);

            ERROR_MSG = '';
        }
        return listcustconinfoStaging;
    }

    //Wrapper class for account status update records
    public class customerContactInfoRecordsWrapper {
        // public String accountID{get;set;}
        //public String accountNumber{get;set;}
        public String data_id { get; set; }
        public String pri_email { get; set; }
        public String pri_add1 { get; set; }
        public String pri_add2 { get; set; }
        public String pri_municipality { get; set; }
        public String pri_province { get; set; }
        public String pri_postcode { get; set; }
        public String pri_country { get; set; }
        public String pri_hphone { get; set; }
        public String pri_wphone { get; set; }
        public String pri_cphone { get; set; }
        public String sec_email { get; set; }
        public String sec_add1 { get; set; }
        public String sec_add2 { get; set; }
        public String sec_municipality { get; set; }
        public String sec_province { get; set; }
        public String sec_postcode { get; set; }
        public String sec_country { get; set; }
        public String sec_wphone { get; set; }
        public String sec_hphone { get; set; }
        public String sec_cphone { get; set; }
        //public EFT_Files__c prodLookup {get;set;}
    }
}