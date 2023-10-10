/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Product  records from Staging and create success
*                  and failure files for customer contact info
*  @author : A5E Consulting
*  @date : 14/02/2022

*************************************************************************************************/
public class DisplayCustomerContInfoStagingController {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public list<Customer_Staging__c> listCustomerContactStaging { get; set; }
    public list<customerContactInfoStagingWrapper> listCustomerContInfoStagingWrapper { get; set; }
    public static final String PROCESSED = 'Processed';
    public static String CUSTOMER_CONTACT_INFO_UPDATE = 'Customer Contact Information Update File';
    public static final String ERROR = 'ERROR';
    public boolean showButton { get; set; }
    public boolean displayPanel { get; set; }
    public Id workAssignmentId { get; set; }
    public String message { get; set; }
    public String recordIdentfier { get; set; }
    Id recordID;
    Id documentID;
    String success;
    String failed;
    Boolean SuccessHasRecord;
    Boolean FailedHasRecord;
    String placementAgency = '';

    public DisplayCustomerContInfoStagingController() {
        showButton = true;
        displayPanel = false;
        SuccessHasRecord = false;
        FailedHasRecord = false;
        recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        listCustomerContactStaging = [
            SELECT
                ID,
                Name,
                Address_Line1__c,
                Address_Line2__c,
                Cell_Phone__c,
                City__c,
                Country__c,
                Email_Address__c,
                Home_Phone__c,
                Postal_Code__c,
                State__c,
                Work_Phone__c,
                Coborrower_Address1__c,
                Coborrower_Address2__c,
                Coborrower_Cell_Phone__c,
                Coborrower_City__c,
                Coborrower_Country__c,
                Coborrower_Email__c,
                Coborrower_Home_Phone__c,
                Coborrower_Postal_Code__c,
                Coborrower_State__c,
                Coborrower_Work_Phone__c,
                Comment__c,
                Placement_Agency__c,
                ProdID__c,
                Status__c,
                Document_Storage__c,
                Document_Storage__r.File_Processing_Status__c,
                Document_Storage__r.Work_Assignment__c,
                Product_ID__c,
                Expected_Value__c
            FROM Customer_Staging__c
            WHERE Identifier__c = :recordIdentfier AND Include_in_Processing__c = FALSE
        ];

        Integer successCount = [
            SELECT COUNT()
            FROM Customer_Staging__c
            WHERE Include_in_Processing__c = TRUE AND Identifier__c = :recordIdentfier
        ];
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Total Success Records = ' + successCount));

        //To check after positive scenario - Adesh
        if (listCustomerContactStaging.isEmpty()) {
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'There are no Customer Contact  Information  to display'));
        } else {
            workAssignmentId = listCustomerContactStaging[0].Document_Storage__r.Work_Assignment__c;
            listCustomerContInfoStagingWrapper = new List<customerContactInfoStagingWrapper>();
            for (Customer_Staging__c custStaging : listCustomerContactStaging) {
                Boolean disabled = false;
                if (custStaging.Comment__c.contains(ERROR) || (custStaging.Status__c == PROCESSED && custStaging.Comment__c == 'SUCCESS')) {
                    disabled = true;
                }
                listCustomerContInfoStagingWrapper.add(new customerContactInfoStagingWrapper(custStaging, disabled));
                if (custStaging.Status__c != PROCESSED && !custStaging.Comment__c.contains(ERROR)) {
                    showButton = true;
                }
            }
            placementAgency = listCustomerContactStaging[0].Placement_Agency__c;
            documentID = listCustomerContactStaging[0].Document_Storage__c;
            if (showButton == false) {
                if (listCustomerContactStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED) {
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Records are already processed'));
                } else {
                    showButton = false;
                }
            }
        }
    }

    public pageReference Save() {
        transient List<customerContactInfoStagingWrapper> listCustomerContInfoStagingWrapperToUpdate = listCustomerContInfoStagingWrapper;
        System.debug('listCustomerContInfoStagingWrapperToUpdate ' + listCustomerContInfoStagingWrapperToUpdate.size());
        list<Product__c> listProd = new List<Product__c>();
        list<Account> listPersonAcc = new List<Account>();
        map<id, Account> mapPersonAcc = new Map<id, Account>();
        set<String> setProdutNames = new Set<String>();
        Map<String, ID> mapAccountNumberID = new Map<String, ID>();
        Map<String, ID> accNumberCustomerID = new Map<String, ID>();
        List<Customer_Staging__c> listCustomerStaging = new List<Customer_Staging__c>();
        String placementAgency = '';
        System.debug('recordIdentfier ' + recordIdentfier);
        for (Customer_Staging__c customerStaging : [
            SELECT
                ID,
                Name,
                Address_Line1__c,
                Address_Line2__c,
                Cell_Phone__c,
                City__c,
                Country__c,
                Email_Address__c,
                Home_Phone__c,
                Postal_Code__c,
                State__c,
                Work_Phone__c,
                Coborrower_Address1__c,
                Coborrower_Address2__c,
                Coborrower_Cell_Phone__c,
                Coborrower_City__c,
                Coborrower_Country__c,
                Coborrower_Email__c,
                Coborrower_Home_Phone__c,
                Coborrower_Postal_Code__c,
                Coborrower_State__c,
                Coborrower_Work_Phone__c,
                Comment__c,
                Placement_Agency__c,
                ProdID__c,
                Status__c,
                Document_Storage__c,
                Document_Storage__r.File_Processing_Status__c,
                Document_Storage__r.Work_Assignment__c,
                Product_ID__c,
                Expected_Value__c
            FROM Customer_Staging__c
            WHERE Identifier__c = :recordIdentfier AND Include_in_Processing__c = TRUE AND Status__c != 'Processed'
        ]) {
            customerContactInfoStagingWrapper stagingWrapper = new customerContactInfoStagingWrapper(customerStaging, false);
            stagingWrapper.selected = true;
            listCustomerContInfoStagingWrapperToUpdate.add(stagingWrapper);
        }
        System.debug('listCustomerContInfoStagingWrapperToUpdate ' + listCustomerContInfoStagingWrapperToUpdate.size());
        for (customerContactInfoStagingWrapper accStaging : listCustomerContInfoStagingWrapperToUpdate) {
            placementAgency = accStaging.CustStaging.Placement_Agency__c;
            setProdutNames.add(accStaging.CustStaging.ProdID__c);
        }

        //Get Placement ID
        list<Placement__c> listPlacements = [
            SELECT ID
            FROM Placement__c
            WHERE Name = :placementAgency
        ];
        Id placementID;
        if (!listPlacements.isEmpty()) {
            placementID = listPlacements[0].ID;
        }

        //Get Product IDs in map
        for (Product__C accountRecord : [
            SELECT id, name, DebtNext_Data_ID__C, Collection_Agency__c, Customer__c
            FROM Product__C
            WHERE name IN :setProdutNames
        ]) {
            mapAccountNumberID.put(accountRecord.name, accountRecord.id);
            accNumberCustomerID.put(accountRecord.name, accountRecord.Customer__c);
        }

        Decimal successRecords = 0;
        Decimal failedRecords = 0;
        for (customerContactInfoStagingWrapper custStagingWrapper : listCustomerContInfoStagingWrapperToUpdate) {
            Customer_Staging__c CustStaging = custStagingWrapper.CustStaging;

            String comment = '';
            if (String.isNotBlank(CustStaging.Comment__c)) {
                comment = CustStaging.Comment__c;
            }
            if (Test.isRunningTest()) {
                custStagingWrapper.selected = true;
            }
            if (CustStaging.Status__c != PROCESSED && custStagingWrapper.selected == true) {
                //CustStaging.Status__c = PROCESSED;
                Product__c prod = new Product__c();
                if (mapAccountNumberID.ContainsKey(CustStaging.ProdID__c)) {
                    prod.id = mapAccountNumberID.get(CustStaging.ProdID__c);
                }
                list<string> nospacenull = new List<string>();
                list<string> nospaceBlank = new List<string>();
                nospacenull.add(' ');
                nospacenull.add('null');
                nospacenull.add('Null');
                nospacenull.add(null);
                nospacenull.add(null);
                nospacenull.add('-');
                nospaceBlank.add('-');

                if (!nospacenull.contains(CustStaging.Email_Address__c))
                    prod.Email_Address__c = CustStaging.Email_Address__c;
                if (nospaceBlank.contains(CustStaging.Email_Address__c))
                    prod.Email_Address__c = '';

                if (!nospacenull.contains(CustStaging.Address_Line1__c))
                    prod.Address_Line1__c = CustStaging.Address_Line1__c;
                if (nospaceBlank.contains(CustStaging.Address_Line1__c))
                    prod.Address_Line1__c = '';

                if (!nospacenull.contains(CustStaging.Address_Line2__c))
                    prod.Address_Line2__c = CustStaging.Address_Line2__c;
                if (nospaceBlank.contains(CustStaging.Address_Line2__c))
                    prod.Address_Line2__c = '';

                if (!nospacenull.contains(CustStaging.City__c))
                    prod.City__c = CustStaging.City__c;
                if (nospaceBlank.contains(CustStaging.City__c))
                    prod.City__c = '';

                if (!nospacenull.contains(CustStaging.State__c) && CustStaging.State__c != null)
                    prod.State__c = CustStaging.State__c;
                if (nospaceBlank.contains(CustStaging.State__c))
                    prod.State__c = '';

                if (!nospacenull.contains(CustStaging.Postal_Code__c))
                    prod.Zip_Code__c = CustStaging.Postal_Code__c;
                if (nospaceBlank.contains(CustStaging.Postal_Code__c))
                    prod.Zip_Code__c = '';

                if (!nospacenull.contains(CustStaging.Country__c) && CustStaging.Country__c != null)
                    prod.Country__c = CustStaging.Country__c;
                if (nospaceBlank.contains(CustStaging.Country__c))
                    prod.Country__c = '';

                if (!nospacenull.contains(CustStaging.Home_Phone__c))
                    prod.Phone_Home__c = CustStaging.Home_Phone__c;
                if (nospaceBlank.contains(CustStaging.Home_Phone__c))
                    prod.Phone_Home__c = '';

                if (!nospacenull.contains(CustStaging.Work_Phone__c))
                    prod.Phone_Work__c = CustStaging.Work_Phone__c;
                if (nospaceBlank.contains(CustStaging.Work_Phone__c))
                    prod.Phone_Work__c = '';

                if (!nospacenull.contains(CustStaging.Cell_Phone__c))
                    prod.Phone_Other__c = CustStaging.Cell_Phone__c;
                if (nospaceBlank.contains(CustStaging.Cell_Phone__c))
                    prod.Phone_Other__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Email__c))
                    prod.Codebtor_Email_Address__c = CustStaging.Coborrower_Email__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Email__c))
                    prod.Codebtor_Email_Address__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Address1__c))
                    prod.Codebtor_Address_Line1__c = CustStaging.Coborrower_Address1__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Address1__c))
                    prod.Codebtor_Address_Line1__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Address2__c))
                    prod.Codebtor_Address_Line2__c = CustStaging.Coborrower_Address2__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Address2__c))
                    prod.Codebtor_Address_Line2__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_City__c))
                    prod.Codebtor_City__c = CustStaging.Coborrower_City__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_City__c))
                    prod.Codebtor_City__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_State__c))
                    prod.Codebtor_State__c = CustStaging.Coborrower_State__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_State__c))
                    prod.Codebtor_State__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Postal_Code__c))
                    prod.Codebtor_Zip_Code__c = CustStaging.Coborrower_Postal_Code__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Postal_Code__c))
                    prod.Codebtor_Zip_Code__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Country__c))
                    prod.Codebtor_Country__c = CustStaging.Coborrower_Country__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Country__c))
                    prod.Codebtor_Country__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Work_Phone__c))
                    prod.Codebtor_Phone_Work__c = CustStaging.Coborrower_Work_Phone__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Work_Phone__c))
                    prod.Codebtor_Phone_Work__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Home_Phone__c))
                    prod.Codebtor_Phone_Home__c = CustStaging.Coborrower_Home_Phone__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Home_Phone__c))
                    prod.Codebtor_Phone_Home__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Cell_Phone__c))
                    prod.Codebtor_Phone_Other__c = CustStaging.Coborrower_Cell_Phone__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Cell_Phone__c))
                    prod.Codebtor_Phone_Other__c = '';

                listProd.add(prod);
                listCustomerStaging.add(CustStaging);
            }
        }
        //Code modified to Show Exception and avoiding not to generate Success and Failure file 27-Dec-2022: Rasmitha
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        boolean excFlag = false;
        String txt = '';
        try {
            System.debug('listProd ' + listProd.size());
            List<Database.SaveResult> result = Database.update(listProd, false);
            //Create Success and Error file
            GenerateSuccessAndErrorFile(
                listCustomerContInfoStagingWrapperToUpdate,
                listCustomerContactStaging[0].Document_Storage__r.Work_Assignment__c,
                portalSettings.Document_Storage_Default_Visibility__c,
                documentID
            );
        } catch (exception ex) {
            txt = ex.getMessage();
            excFlag = true;
            system.debug('exception Customer file catch--+--' + ex.getLineNumber());
            system.debug('exception Customer file catch--+--' + ex.getMessage());
            for (Customer_Staging__c customerStaging : listCustomerStaging) {
                String msg = '<b>ERROR</b>-' + ex.getMessage();
                if (msg.length() > 254) {
                    msg = msg.substring(0, 254);
                }
                customerStaging.Comment__c = msg;
                customerStaging.status__c = 'Pending';
            }
        }
        if (listCustomerStaging.size() > 0) {
            System.debug('listCustomerStaging ' + listCustomerStaging.size());
            update listCustomerStaging;
        }

        showButton = true;
        displayPanel = true;
        return null;
    }

    public static void GenerateSuccessAndErrorFile(
        list<customerContactInfoStagingWrapper> listCustomerContInfoStagingWrapper,
        Id workAssignmentId,
        String visiblity,
        Id documentID
    ) {
        String success;
        String failed;
        Integer successRecords = 0;
        Integer failedRecords = 0;

        success = 'data_id,pri_email,pri_add1,pri_add2,pri_municipality,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone';
        failed = 'data_id,pri_email,pri_add1,pri_add2,pri_municipality,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';

        for (customerContactInfoStagingWrapper custStagingWrapper : listCustomerContInfoStagingWrapper) {
            Customer_Staging__c CustStaging = custStagingWrapper.CustStaging;
            if (CustStaging.Status__c != PROCESSED && custStagingWrapper.selected == true) {
                CustStaging.Status__c = PROCESSED;
                CustStaging.Include_in_Processing__c = true;
                success += '\n';
                success +=
                    '\'' +
                    CustStaging.ProdID__c +
                    ',' +
                    CustStaging.Email_Address__c +
                    ',' +
                    CustStaging.Address_Line1__c +
                    ',' +
                    CustStaging.Address_Line2__c +
                    ',' +
                    CustStaging.City__c +
                    ',' +
                    CustStaging.State__c +
                    ',' +
                    CustStaging.Postal_Code__c +
                    ',' +
                    CustStaging.Country__c +
                    ',' +
                    CustStaging.Home_Phone__c +
                    ',' +
                    CustStaging.Work_Phone__c +
                    ',' +
                    CustStaging.Cell_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Email__c +
                    ',' +
                    CustStaging.Coborrower_Address1__c +
                    ',' +
                    CustStaging.Coborrower_Address2__c +
                    ',' +
                    CustStaging.Coborrower_City__c +
                    ',' +
                    CustStaging.Coborrower_State__c +
                    ',' +
                    CustStaging.Coborrower_Postal_Code__c +
                    ',' +
                    CustStaging.Coborrower_Country__c +
                    ',' +
                    CustStaging.Coborrower_Work_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Home_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Cell_Phone__c;
                successRecords = successRecords + 1;
            } else {
                failed += '\n';
                String CommentError;
                if (CustStaging.Comment__c != null) {
                    CommentError = CustStaging.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>', '');
                    CommentError = CommentError.replaceAll('</b>', '');
                    CommentError = CommentError.replaceAll('<b>', '');
                    system.debug('CommentError test::' + CommentError);
                }
                failed +=
                    '\'' +
                    CustStaging.ProdID__c +
                    ',' +
                    CustStaging.Email_Address__c +
                    ',' +
                    CustStaging.Address_Line1__c +
                    ',' +
                    CustStaging.Address_Line2__c +
                    ',' +
                    CustStaging.City__c +
                    ',' +
                    CustStaging.State__c +
                    ',' +
                    CustStaging.Postal_Code__c +
                    ',' +
                    CustStaging.Country__c +
                    ',' +
                    CustStaging.Home_Phone__c +
                    ',' +
                    CustStaging.Work_Phone__c +
                    ',' +
                    CustStaging.Cell_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Email__c +
                    ',' +
                    CustStaging.Coborrower_Address1__c +
                    ',' +
                    CustStaging.Coborrower_Address2__c +
                    ',' +
                    CustStaging.Coborrower_City__c +
                    ',' +
                    CustStaging.Coborrower_State__c +
                    ',' +
                    CustStaging.Coborrower_Postal_Code__c +
                    ',' +
                    CustStaging.Coborrower_Country__c +
                    ',' +
                    CustStaging.Coborrower_Work_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Home_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Cell_Phone__c +
                    '"' +
                    ',' +
                    (CustStaging.Comment__c != null ? CommentError : null);

                failedRecords = failedRecords + 1;
            }
        }

        system.enqueueJob(
            new PostDocumentAPI(CUSTOMER_CONTACT_INFO_UPDATE, failed, success, failedRecords, successRecords, workAssignmentId, visiblity, documentID)
        );
    }

    public class customerContactInfoStagingWrapper {
        public Customer_Staging__c custStaging { get; set; }
        public boolean selected { get; set; }
        public boolean disabled { get; set; }
        public customerContactInfoStagingWrapper(Customer_Staging__c cust, Boolean disable) {
            custStaging = cust;
            selected = false;
            disabled = disable;
        }
    }
}
