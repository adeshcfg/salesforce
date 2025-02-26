public class StriplistInsolPaymentUploadController {
    public String excelFile { get; set; }
    public boolean showallocated { get; set; }
    public boolean showunallocated { get; set; }
    public boolean showButtons { get; set; }
    public boolean showStriplistTab { get; set; }
    public boolean showFileUpload { get; set; }
    public Remittance__c remittanceInstance { get; set; }
    public String postingDate { get; set; }

    //EFT_Processing_Config__c eftConfigInstance;

    public StriplistInsolPaymentUploadController(ApexPages.StandardController stdController) {
        showButtons = false;
        showStriplistTab = false;
        Id dividendId = ApexPages.currentPage().getParameters().get('id');

        remittanceInstance = new Remittance__c();

        if (dividendId != null) {
            remittanceInstance = [
                SELECT
                    Id,
                    Name,
                    Unallocated_Payment_Processing_Status__c,
                    Allocated_Payment_Processing_Status__c,
                    Payment_Posting_Date__c,
                    Allocated_Payments_Count__c,
                    Unallocated_Payments_Count__c,
                    Total_Record_Count__c,
                    Total_Payments_Amount__c,
                    Allocated_Payments_Amount__c,
                    Unallocated_Payments_Amount__c,
                    File_Processing_Status__c,
                    Status__c,
                    Cheque_Payment_Reference_Number__c,
                    Cheque_Amount__c
                FROM Remittance__c
                WHERE Id = :dividendId
            ][0];

            if (remittanceInstance.File_Processing_Status__c == 'Completed') {
                showButtons = true;
            }
            if (remittanceInstance.Status__c == 'Processed') {
                showStriplistTab = true;
                showButtons = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Insolvency Payments for this Dividend are already processed.'));
            }
            if (remittanceInstance.Status__c == 'Payment Reversed') {
                showStriplistTab = true;
                showButtons = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Cannot upload striplist for Dividend after Payment is Reversed!'));
            }
        }
        showFileUpload = true;
    }

    /**
     * @description : Method to convert and process file uploaded from VF page
     * @author adesh.ikhar@canaccede.com | 02-14-2024
     **/
    public void processExcelFile() {
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        HttpRequest documentApiReq = getExcelToJsonRequest(apiCallDetails);
        documentApiReq.setBodyAsBlob(EncodingUtil.base64decode(excelFile));

        // Free up view state
        excelFile = '';
        try {
            HttpResponse response = new Http().send(documentApiReq);
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                importDatatoApex(response.getBody());
            } else {
                insertApiError(response.getBody(), apiCallDetails.PDF_API_URL__c + 'converters/excel', response.getStatus());
                Apexpages.addMessage(
                    new ApexPages.message(
                        Apexpages.Severity.ERROR,
                        'Error during API callout, Response status code ' +
                            String.valueOf(response.getStatusCode()) +
                            ' Response status ' +
                            response.getStatus()
                    )
                );
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            insertApiError(String.valueOf(ex.getCause()), apiCallDetails.PDF_API_URL__c + 'converters/excel', ex.getMessage());
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Error during API callout, please contact System admin'));
        }
    }

    /**
     * @description : Method to create API Error record
     * @author adesh.ikhar@canaccede.com | 02-15-2024
     * @param responseBody
     * @param endPoint
     * @param error
     **/
    public static void insertApiError(String responseBody, String endPoint, String error) {
        API_Error__c apiError = new API_Error__c();
        apiError.Action__c = 'API Failed';
        apiError.Response__c = responseBody;
        apiError.End_Point__c = endPoint;
        apiError.Error__c = error;
        insert apiError;
    }

    /**
     * @description : Generate HttpRequest for Excel to JSON API without the body
     * @author adesh.ikhar@canaccede.com | 02-15-2024
     * @return HttpRequest
     **/
    public static HttpRequest getExcelToJsonRequest(API_Call_Details__c apiCallDetails) {
        String accessToken = AzureUtility.getRequestToken(apiCallDetails);
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiCallDetails.PDF_API_URL__c + 'converters/excel');
        documentApiReq.setMethod('POST');
        documentApiReq.setHeader('Accept', 'application/json');
        documentApiReq.setHeader('Content-Type', 'application/octet-stream');
        documentApiReq.setHeader('x-ms-blob-type', 'BlockBlob');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        documentApiReq.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        return documentApiReq;
    }

    public void importDatatoApex(String outputJSON) {
        List<StriplistUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<StriplistUtil.paymentRecordsWrapper>();

        StriplistUtil striplistUtilInstance = new StriplistUtil();
        try {
            String outputJSON1 = outputJSON.remove('\\n');
            Decimal totalAmount = 0;
            listPaymentRecordWrapper = striplistUtilInstance.deSerializeJSON(outputJSON1);
            for (StriplistUtil.paymentRecordsWrapper payInstance : listPaymentRecordWrapper) {
                if (
                    String.isBlank(payInstance.amount) &&
                    String.isBlank(payInstance.accountID) &&
                    String.isBlank(payInstance.debtorName) &&
                    String.isBlank(payInstance.estateNumber) &&
                    String.isBlank(payInstance.accountNumber)
                ) {
                    continue;
                }
                if (
                    (String.isNotBlank(payInstance.amount) ||
                    (String.isNotBlank(payInstance.accountID)) ||
                    String.isNotBlank(payInstance.debtorName) ||
                    String.isNotBlank(payInstance.estateNumber)) && (String.isBlank(payInstance.accountNumber))
                ) {
                    Apexpages.addMessage(
                        new ApexPages.message(Apexpages.Severity.ERROR, 'Account Number cannot be blank. Please check the file headers and upload valid file.')
                    );
                    return;
                }
                /* //IF condition added by Nagendra part of #5430
                if(String.isBlank(payInstance.debtorName)){
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Debtor Name cannot be blank. Please check the file headers and upload valid file.'));
                    return null;
                }
                */
                //IF condition added by Nagendra part of #5430
                if (String.isBlank(payInstance.estateNumber)) {
                    Apexpages.addMessage(
                        new ApexPages.message(Apexpages.Severity.ERROR, 'Estate Number cannot be blank. Please check the file headers and upload valid file.')
                    );
                    return;
                }
                if (
                    String.isNotBlank(payInstance.accountNumber) &&
                    (String.isBlank(payInstance.amount) ||
                    payInstance.amount == String.valueOf(0) ||
                    payInstance.amount == String.valueOf(0.00) ||
                    payInstance.amount == String.valueOf(0.0))
                ) {
                    Apexpages.addMessage(
                        new ApexPages.message(Apexpages.Severity.ERROR, 'Amount cannot be blank or 0. Please check the file headers and upload valid file')
                    );
                    return;
                } else {
                    if (String.isNotBlank(payInstance.amount)) {
                        totalAmount += decimal.valueOf(payInstance.amount);
                    }
                }
            }
            if (totalAmount <> remittanceInstance.Cheque_Amount__c) {
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Total Amount in excel file does not match with the Dividend Amount.'));
                return;
            }
            remittanceInstance.File_Processing_Status__c = 'In Progress';
            remittanceInstance.Status__c = 'In Progress';
            remittanceInstance.Striplist_User_ID__c = String.valueOf(UserInfo.getUserId());

            update remittanceInstance;
            Apexpages.addMessage(
                new ApexPages.message(Apexpages.Severity.INFO, 'File is being processed. You will receive email once processing is completed.')
            );
            ProcessInsolvencyStriplistBatch batchInstance = new ProcessInsolvencyStriplistBatch(listPaymentRecordWrapper, remittanceInstance);
            database.executeBatch(batchInstance, 40);
        } catch (Exception ex) {
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, ex.getMessage()));
        }
    }

    public pageReference showAllocatedProductPayments() {
        PageReference retURL = new PageReference('/apex/DisplayStriplistInsolAllocatedPayments?id=' + remittanceInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }

    public PageReference ShowUnallocatedProductPayments() {
        PageReference retURL;
        retURL = new PageReference('/apex/DisplayStriplistUnallocatedPayments?id=' + remittanceInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }

    public PageReference backToDividend() {
        PageReference retURL;
        retURL = new PageReference('/' + remittanceInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }
}
