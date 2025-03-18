/**
 * @description       : Controller class for CCS VF email templates
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 08-02-2024
 * @last modified by  : adesh.ikhar@canaccede.com
**/
public class CcsVfTemplateController {
    public CCS_Custom_Settings__c ccsPackage { get; set; }
    public Product__c product { get; set; }
    public CcsInformationWrapper otherInfo { get; set; }
    public CcsVfTemplateController() {
        product = [
            SELECT
                id,
                Name,
                CCS_Account_Number__c,
                CCS_Proposal_Date__c,
                Customer__r.name,
                CCS_Agency__r.Business_Email__c,
                Proposal_Reject_Reason__c,
                Accepted_Payment_Amount__c,
                Accepted_Interest_rate__c,
                Accepted_Donation_Rate__c,
                CCS_Agency__r.BillingAddress,
                RecordType.DeveloperName,
                RecordType.Name,
                Bank_Name__c,
                Proposal_Status__c,
                Proposal_Received_Date__c,
                Purchase_Factor__c,
                Purchase_Price__c,
                Settlement_Amount__c,
                Settlement_Manual_Date__c,
                Current_Interest_Rate__c,
                Proposed_Payment_Amount__c,
                CCS_Proposed_Payment_Amount__c,
                Proposed_Donation_Rate__c,
                Expected_First_disbursement_date__c,
                CCS_Agency__r.BillingState,
                Monthly_Payment_Amount__c,
                Last_Payment_Amount__c,
                Last_Payment_Date__c,
                Current_Balance__c,
                Payment_Frequency__c,
                Originating_Creditor__c,
                Bank_Reference_Quoted__c,
                CCS_Agency__r.Name,
                CCS_Agency__r.Fax,
                CCS_Agency__r.BillingCity,
                CCS_Agency__r.BillingStreet,
                CCS_Agency__r.BillingPostalCode,
                Manually_Fill__c,
                CCS_Client_ID__c
            FROM Product__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
        ];
        populateOtherInfo();
    }

    /**
    * @description : Method to assign/reassign correct values as per conditions
    * @author adesh.ikhar@canaccede.com | 08-02-2024 
    **/
    public void populateOtherInfo() {
        otherInfo = new CcsInformationWrapper();
        otherInfo.template = ApexPages.currentPage().getParameters().get('template');
        ccsPackage = CCS_Custom_Settings__c.getOrgDefaults();
        String imageUrl = LoRDemandController.getImageUrl('Canaccede_International_Management_Ltd');
        String style = 'style="align:left"';
        String height = '80px';
        String width = 'auto';
        Date dateToday = System.Today();
        // Convert DateTime to Date format ex: May 01, 2018

        String formattedDate = DateTime.newInstance(dateToday.year(), dateToday.month(), dateToday.day()).formatGMT('MM/dd/yyyy');
        /*string add = system.PersonMailingAddress();*/
        Decimal input = 0.00;
        String output = '$' + String.valueOf(input);
        Product_Payments__c pay = new Product_Payments__c();
        List<Product_Payments__c> paymentList = [
            SELECT
                id,
                Payment_Amount__c,
                Payment_Posting_Date__c,
                RecordType.name,
                CreatedDate,
                Payment_Created_Date__c,
                Payment_Created__c,
                Gross_Payment_Amount__c
            FROM Product_Payments__c
            WHERE ccs_account__C = :product.Id AND (RecordType.Name = 'CCS Dividend Payment' OR recordtype.name = 'CCS Product Payment')
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!paymentList.isEmpty()) {
            pay = paymentList[0];
        }
        if (product.RecordType.DeveloperName == 'GoEasy_CCS_Account') {
            otherInfo.servicerName = 'Servicer for Easyfinancial Services Ltd.';
            otherInfo.settleReference = 'Settlement Offer';
            product.Proposal_Status__c = 'ACCEPT';
            height = '100px';
            width = '100%';
            imageUrl = LoRDemandController.getImageUrl('Easyfinancial');
            style = '';
        } else {
            otherInfo.settleReference = 'Settled in Full Confirmation';
        }
        otherInfo.logoVisiblity = '<div ' + style + '> ' + '<img src= ' + imageUrl + ' style="height:' + height + ';width:' + width + '"/>' + '</div>';
        otherInfo.today = formattedDate;
        otherInfo.paymentCreatedDate = (pay != null &&
            pay.Payment_Created__c != null
            ? DateTime.newInstance(pay.Payment_Created__c.year(), pay.Payment_Created__c.month(), pay.Payment_Created__c.day()).formatGMT('MMM dd, YYYY')
            : '');
        otherInfo.paymentAmount = (pay != null && pay.Payment_Amount__c != null ? '$' + String.valueOf(pay.Payment_Amount__c) : '');
        otherInfo.grossPaymentAmount = (pay != null && pay.Gross_Payment_Amount__c != null ? '$' + String.valueOf(pay.Gross_Payment_Amount__c) : '');
        otherInfo.ccsProposedPaymentAmount = (product.CCS_Proposed_Payment_Amount__c != null
            ? '$' + String.valueOf(product.CCS_Proposed_Payment_Amount__c)
            : '');
        otherInfo.proposedPaymentAmount = (product.Proposed_Payment_Amount__c != null ? '$' + String.valueOf(product.Proposed_Payment_Amount__c) : '');
        otherInfo.proposedDonationRate = (product.Proposed_Donation_Rate__c != null ? '$' + String.valueOf(product.Proposed_Donation_Rate__c) : '');
        otherInfo.acceptedDonationRate = (product.Accepted_Donation_Rate__c != null ? +String.valueOf(product.Accepted_Donation_Rate__c) + '%' : '');
        otherInfo.acceptedInterestRate = (product.Accepted_Interest_rate__c != null ? +String.valueOf(product.Accepted_Interest_rate__c) + '%' : '');
        otherInfo.acceptedPaymentAmount = (product.Accepted_Payment_Amount__c != null ? '$' + String.valueOf(product.Accepted_Payment_Amount__c) : '');
        otherInfo.expectedFirstDisbursementDate = (product.Expected_First_disbursement_date__c != null
            ? DateTime.newInstance(
                      product.Expected_First_disbursement_date__c.year(),
                      product.Expected_First_disbursement_date__c.month(),
                      product.Expected_First_disbursement_date__c.day()
                  )
                  .formatGMT('MMM dd, yyyy')
            : '');
        otherInfo.currentInterestRate = (product.Current_Interest_Rate__c != null ? +String.valueOf(product.Current_Interest_Rate__c) + '%' : '');
        otherInfo.settlementAmount = (product.Settlement_Amount__c != null ? '$' + String.valueOf(product.Settlement_Amount__c.format()) : '');
        otherInfo.settlementManualDate = (product.Settlement_Manual_Date__c != null
            ? DateTime.newInstance(product.Settlement_Manual_Date__c.year(), product.Settlement_Manual_Date__c.month(), product.Settlement_Manual_Date__c.day())
                  .formatGMT('MMM dd, yyyy')
            : '');
        otherInfo.proposalDate = (product.CCS_Proposal_Date__c != null
            ? DateTime.newInstance(product.CCS_Proposal_Date__c.year(), product.CCS_Proposal_Date__c.month(), product.CCS_Proposal_Date__c.day())
                  .formatGMT('MMM dd, yyyy')
            : '');
        otherInfo.proposalReceivedDate = (product.Proposal_Received_Date__c != null
            ? DateTime.newInstance(product.Proposal_Received_Date__c.year(), product.Proposal_Received_Date__c.month(), product.Proposal_Received_Date__c.day())
                  .formatGMT('MMM dd, yyyy')
            : '');
        otherInfo.purchaseFactor = (product.Purchase_Factor__c != null ? String.valueOf(product.Purchase_Factor__c.format()) : '');
        otherInfo.purchasePrice = (product.Purchase_Price__c != null ? '$' + String.valueOf(product.Purchase_Price__c.format()) : '');
        otherInfo.lastPaymentAmount = (product.Last_Payment_Amount__c != null ? '$' + String.valueOf(product.Last_Payment_Amount__c.format()) : '');
        otherInfo.lastPaymentDate = (product.Last_Payment_Date__c != null
            ? DateTime.newInstance(product.Last_Payment_Date__c.year(), product.Last_Payment_Date__c.month(), product.Last_Payment_Date__c.day())
                  .formatGMT('MMM dd, yyyy')
            : '');
        otherInfo.currentBalance = (product.Current_Balance__c != null ? '$' + String.valueOf(product.Current_Balance__c.format()) : '');
        otherInfo.monthlyPaymentAmount = (product.Monthly_Payment_Amount__c != null ? '$' + String.valueOf(product.Monthly_Payment_Amount__c.format()) : '');
    }

    public class CcsInformationWrapper {
        public String template { get; set; }
        public String today { get; set; }
        public String servicerName { get; set; }
        public String settleReference { get; set; }
        public String logoVisiblity { get; set; }
        public String paymentCreatedDate { get; set; }
        public String paymentAmount { get; set; }
        public String grossPaymentAmount { get; set; }
        public String ccsProposedPaymentAmount { get; set; }
        public String proposedPaymentAmount { get; set; }
        public String proposedDonationRate { get; set; }
        public String acceptedDonationRate { get; set; }
        public String acceptedInterestRate { get; set; }
        public String acceptedPaymentAmount { get; set; }
        public String expectedFirstDisbursementDate { get; set; }
        public String currentInterestRate { get; set; }
        public String settlementAmount { get; set; }
        public String settlementManualDate { get; set; }
        public String proposalDate { get; set; }
        public String proposalReceivedDate { get; set; }
        public String purchaseFactor { get; set; }
        public String purchasePrice { get; set; }
        public String lastPaymentAmount { get; set; }
        public String lastPaymentDate { get; set; }
        public String currentBalance { get; set; }
        public String monthlyPaymentAmount { get; set; }
    }
}
