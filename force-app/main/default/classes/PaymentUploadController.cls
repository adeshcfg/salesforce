/**************************************************************************************************
 *  Class:
 *
 *  @description : This is a controller class to process excel file for EFT Payments
 *  @author : A5E Consulting
 *  @date : 08 July 2020
 *************************************************************************************************/

public class PaymentUploadController {
    public String excelFile { get; set; }
    public boolean showButtons { get; set; }
    public boolean showFileUpload { get; set; }
    public EFT_Files__c eftInstance { get; set; }
    public String postingDate { get; set; }
    EFT_Processing_Config__c eftConfigInstance;

    public PaymentUploadController() {
        showButtons = false;
        Id EFTRecordId = ApexPages.currentPage().getParameters().get('id');
        eftInstance = new EFT_Files__c();
        if (EFTRecordId != null) {
            eftInstance = [
                SELECT
                    Id,
                    Unallocated_Processing_Status__c,
                    Allocated_Processing_Status__c,
                    User_ID__c,
                    Posting_Date__c,
                    Text_URL__c,
                    Allocated_Payments_Count__c,
                    Unallocated_payments_Count__c,
                    Total_Record_Count__c,
                    Allocated_Payments_Amount__c,
                    Unallocated_Payments_Amount__c,
                    Total_Payments_Amount__c
                FROM EFT_Files__c
                WHERE Id = :EFTRecordId
            ][0];
            showButtons = true;
            postingDate = String.valueOf(eftInstance.Posting_Date__c);
        }
        showFileUpload = true;
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
    }

    /**
     * @description : Method to convert and process file uploaded from VF page
     * @author adesh.ikhar@canaccede.com | 02-15-2024
     **/
    public void processExcelFile() {
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accessToken = AzureUtility.getRequestToken(apiCallDetails);
        HttpRequest documentApiReq = new HttpRequest();
        documentApiReq.setEndpoint(apiCallDetails.PDF_API_URL__c + 'converters/excel');
        documentApiReq.setMethod('POST');
        documentApiReq.setHeader('Accept', 'application/json');
        documentApiReq.setHeader('Content-Type', 'application/octet-stream');
        documentApiReq.setHeader('x-ms-blob-type', 'BlockBlob');
        documentApiReq.setHeader('Authorization', 'Bearer ' + accessToken);
        documentApiReq.setBodyAsBlob(EncodingUtil.base64decode(excelFile));
        documentApiReq.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        try {
            HttpResponse response = new Http().send(documentApiReq);
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                importDatatoApex(response.getBody());
            } else {
                StriplistInsolPaymentUploadController.insertApiError(
                    response.getBody(),
                    apiCallDetails.PDF_API_URL__c + 'converters/excel',
                    response.getStatus()
                );
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
            StriplistInsolPaymentUploadController.insertApiError(
                String.valueOf(ex.getCause()),
                apiCallDetails.PDF_API_URL__c + 'converters/excel',
                ex.getMessage()
            );
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Error during API callout, please contact System admin'));
        }
    }

    public void importDatatoApex(String outputJSON) {
        List<EFTUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<EFTUtil.paymentRecordsWrapper>();
        EFTUtil eftUtilInstance = new EFTUtil();
        try {
            String outputJSON1 = outputJSON.replaceAll('ClientName', 'DebtorName');
            listPaymentRecordWrapper = eftUtilInstance.deSerializeJSON(outputJSON1);
            for (EFTUtil.paymentRecordsWrapper payInstance : listPaymentRecordWrapper) {
                if (
                    (String.isNotBlank(payInstance.netPayment) ||
                    (String.isNotBlank(payInstance.fairsharePayment)) ||
                    String.isNotBlank(payInstance.paymentSource) ||
                    String.isNotBlank(payInstance.paymentType)) && (String.isBlank(payInstance.accountNumber))
                ) {
                    Apexpages.addMessage(
                        new ApexPages.message(Apexpages.Severity.ERROR, 'Account Number cannot be blank. Please check the file headers and upload valid file.')
                    );
                    return;
                }
                if (
                    String.isNotBlank(payInstance.accountNumber) &&
                    (String.isBlank(payInstance.netPayment) ||
                    payInstance.netPayment == String.valueOf(0) ||
                    payInstance.netPayment == String.valueOf(0.00) ||
                    payInstance.netPayment == String.valueOf(0.0))
                ) {
                    Apexpages.addMessage(
                        new ApexPages.message(
                            Apexpages.Severity.ERROR,
                            'Net Payment cannot be blank or 0. Please check the file headers and upload valid file.'
                        )
                    );
                    return;
                }
            }
            if (String.isBlank(postingDate)) {
                eftInstance.Posting_Date__c = system.Today();
            } else {
                list<String> dateValue = postingDate.split('-');
                eftInstance.Posting_Date__c = date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
            }
            eftInstance.File_Processing_Status__c = 'In Progress';
            eftInstance.Name = 'CCS Payments ' + system.now();
            eftInstance.User_ID__c = String.valueOf(UserInfo.getUserId());
            if (String.isNotBlank(eftInstance.Text_URL__c)) {
                eftInstance.Text_URL__c = eftInstance.Text_URL__c.trim();
            }
            if (String.isNotBlank(eftConfigInstance.CCS_EFT_RecordTypeID__c)) {
                eftInstance.RecordTypeId = eftConfigInstance.CCS_EFT_RecordTypeID__c;
            }
            if (!listPaymentRecordWrapper.isEmpty()) {
                eftInstance.Total_Record_Count__c = listPaymentRecordWrapper.size();
            }
            insert eftInstance;
            Apexpages.addMessage(
                new ApexPages.message(Apexpages.Severity.INFO, 'File is being processed.  You will receive email once processing is completed.')
            );
            ProcessCCSEFTBatch batchInstance = new ProcessCCSEFTBatch(listPaymentRecordWrapper, eftInstance);
            database.executeBatch(batchInstance);
        } catch (Exception ex) {
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, ex.getMessage()));
        }
    }

    public pageReference showAllocatedProductPayments() {
        PageReference retURL = new PageReference('/apex/DisplayAllocatedProductPayments?id=' + eftInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }

    public PageReference ShowUnallocatedProductPayments() {
        PageReference retURL;
        if (eftInstance.Unallocated_Processing_Status__c == 'Completed') {
            retURL = new PageReference('/apex/DisplayUnallocatedProcessed?id=' + eftInstance.Id + '&rt=CCS');
        } else {
            retURL = new PageReference('/apex/DisplayCCSUnallocatedPayments?id=' + eftInstance.Id);
        }
        retURL.setRedirect(true);
        return retURL;
    }
}
