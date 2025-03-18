global class CCSEmailController {
    // Variable to fetch data related to custom settings, exceptions
    /*public CCS_Custom_Setting__c CCSCustom = CCS_Custom_Setting__c.getOrgDefaults();*/
    public CCS_Custom_Settings__c CCSPackage = CCS_Custom_Settings__c.getOrgDefaults();
    // Variable that are used to store emails, email subject, body and exceptions
    public String toEmail { get; set; }
    public Product__c pro { get; set; }
    public Product_Payments__c pay { get; set; }
    public String subject { get; set; }
    public String emailBody { get; set; }
    public String attachmentBody { get; set; }
    public Boolean isAnyException { get; set; }
    public Date nextBusinessDate { get; set; }
    public List<CCS_Email_Templates__c> CCSCustom { get; set; }
    map<String, CCS_Email_Templates__c> empt = new Map<String, CCS_Email_Templates__c>();
    Map<String, String> emailMergeFields;
    Map<String, String> pageBreakPreviewValues;
    Map<String, String> pageBreakPDFValues;
    public String recordType { get; set; }
    public string servicerName = '';
    public string LegalNameofCreditor = '';
    public string settleReference = '';
    public string logoVisiblity = '';
    //template lists for with or without header
    list<Id> proTemplateWithHeaderList { get; set; }
    list<Id> proTemplateWithoutHeaderList { get; set; }

    //template lists for mandatory attchments list
    list<Id> proTemplateWithManAttachList { get; set; }

    // template related variables
    public List<selectOption> templates { get; set; }
    public String selectedTempalteName { get; set; }
    public String GoeasyselectedTempalteName { get; set; }
    public CCS_Email_Templates__c selectedTemplate { get; set; }
    map<Id, EmailTemplate> emailTemplateMap = new Map<Id, EmailTemplate>();

    // Controller to load initial values and insolvancy account details
    public CCSEmailController() {
        String imageUrl = LoRDemandController.getImageUrl('Canaccede_International_Management_Ltd');
        String style = 'style="align:left"';
        String height = '80px';
        String width = 'auto';
        isAnyException = false;
        proTemplateWithHeaderList = new List<ID>();
        proTemplateWithManAttachList = new List<ID>();
        proTemplateWithHeaderList = new List<ID>();
        selectedTemplate = new CCS_Email_Templates__c();
        emailMergeFields = new Map<String, String>();
        pageBreakPreviewValues = new Map<String, String>();
        pageBreakPDFValues = new Map<String, String>();

        pro = [
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
                Bank_Refence_number__c,
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
        //fetch the product payments//

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
            WHERE
                ccs_account__C = :ApexPages.currentPage().getParameters().get('Id')
                AND (RecordType.Name = 'CCS Dividend Payment'
                OR recordtype.name = 'CCS Product Payment')
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!paymentList.isEmpty()) {
            pay = paymentList[0];
        }
        if (pro.RecordType.DeveloperName == 'GoEasy_CCS_Account') {
            selectedTempalteName = 'Balance Request';
            servicerName = 'Servicer for Easyfinancial Services Ltd.';
            settleReference = 'Settlement Offer';
            pro.Proposal_Status__c = 'ACCEPT';
            LegalNameofCreditor = 'Easyfinancial Services Ltd.';
            height = '100px';
            width = '100%';
            imageUrl = LoRDemandController.getImageUrl('Easyfinancial');
            style = '';
        } else if (pro.RecordType.DeveloperName == 'Flexiti_CCS_Account'){
            selectedTempalteName = 'Balance Request';
            settleReference = 'Settlement Offer';
            servicerName = 'Servicer for Flexiti Financial Inc.';
            LegalNameofCreditor = 'Flexiti Financial Inc.';
        }else {
            selectedTempalteName = 'Product Default Template';
            settleReference = 'Settled in Full Confirmation';
        }
        logoVisiblity = '<div ' + style + '> ' + '<img src= ' + imageUrl + ' style="height:' + height + ';width:' + width + '"/>' + '</div>';
        recordType = pro.RecordType.name;
        toEmail = pro.CCS_Agency__r.Business_Email__c;
        loadEmailTemplates();
        listTempletsDropdown();
        populateValuesInTemplate();
        emailTemplatechanged();
    }

    // fetch the emails from the custom settings
    public void loadEmailTemplates() {
        CCSCustom = CCS_Email_Templates__c.getAll().values();
        for (CCS_Email_Templates__c ccsRecord : CCSCustom) {
            if (ccsRecord.Record_Type__c.split(',').contains(pro.RecordType.DeveloperName)) {
                empt.put(ccsRecord.Name, ccsRecord);
            }
        }
    }

    // templeted drop down list
    public void listTempletsDropdown() {
        templates = new List<selectOption>();
        for (string str : empt.keySet()) {
            templates.add(new SelectOption(str, str));
        }
    }

    public void emailTemplatechanged() {
        selectedTemplate = empt.get(selectedTempalteName);
        attachmentBody = '<p style="color: red;">Not Applicable</p>';
        emailBody = '';
        subject = '';
        for (EmailTemplate emt : [
            SELECT Id, Name, HtmlValue, Body, Subject
            FROM EmailTemplate
            WHERE Id = :selectedTemplate.Attachment_Template_Id__c OR Id = :selectedTemplate.Email_Body_Template_id__c
        ]) {
            if (emt.Id == selectedTemplate.Attachment_Template_Id__c) {
                attachmentBody = emt.HtmlValue;
            } else if (emt.Id == selectedTemplate.Email_Body_Template_id__c) {
                subject = emt.subject;
                subject = subject.replace('{!Product__c.Name}', pro.name);
                subject = subject.replace('{!Product__r.Customer__r.Name}', pro.Customer__r.Name);
                emailBody = emt.Body;
            }
        }

        // replace merge fields in email template with actual values in Product Account
        for (String str : emailMergeFields.keySet()) {
            if (emailBody == null) {
            } else
                emailBody = emailBody.replace(str, emailMergeFields.get(str));
            attachmentBody = attachmentBody.replace(str, emailMergeFields.get(str));
        }
    }

    public void populateValuesInTemplate() {
        Date dateToday = System.Today();
        // Convert DateTime to Date format ex: May 01, 2018

        String formattedDate = DateTime.newInstance(dateToday.year(), dateToday.month(), dateToday.day()).formatGMT('MM/dd/yyyy');
        /*string add = system.PersonMailingAddress();*/
        decimal input = 0.00;
        String output = '$' + String.valueOf(input);

        // Merge fields used in email template
        emailMergeFields = new Map<String, String>{
            '{!Today}' => formattedDate,
            '{!Product__c.Name}' => (pro.Name != null ? pro.Name : ''),
            '{!product__c.Payment_Created__c}' => (pay != null &&
                pay.Payment_Created__c != null
                ? DateTime.newInstance(pay.Payment_Created__c.year(), pay.Payment_Created__c.month(), pay.Payment_Created__c.day()).formatGMT('MMM dd, YYYY')
                : ''),
            '{!Product__c.Payment_Amount__c}' => (pay != null && pay.Payment_Amount__c != null ? '$' + String.valueOf(pay.Payment_Amount__c) : ''),
            '{!Product__c.Gross_Payment_Amount__c}' => (pay != null &&
                pay.Gross_Payment_Amount__c != null
                ? '$' + String.valueOf(pay.Gross_Payment_Amount__c)
                : ''),
            '{!Product__c.CCS_Proposed_Payment_Amount__c}' => (pro.CCS_Proposed_Payment_Amount__c != null
                ? '$' + String.valueOf(pro.CCS_Proposed_Payment_Amount__c)
                : ''),
            '{!Product__c.Proposed_Payment_Amount__c}' => (pro.Proposed_Payment_Amount__c != null ? '$' + String.valueOf(pro.Proposed_Payment_Amount__c) : ''),
            '{!Product__c.CCS_Account_Number__c}' => (pro.CCS_Account_Number__c != null ? pro.CCS_Account_Number__c : ''),
            '{!Product__r.CCS_Agency__r.Fax}' => (pro.CCS_Agency__r.Fax != null ? pro.CCS_Agency__r.Fax : ''),
            '{!Product__c.Proposed_Donation_Rate__c}' => (pro.Proposed_Donation_Rate__c != null ? '$' + String.valueOf(pro.Proposed_Donation_Rate__c) : ''),
            '{!Product__c.Accepted_Donation_Rate__c}' => (pro.Accepted_Donation_Rate__c != null ? +String.valueOf(pro.Accepted_Donation_Rate__c) + '%' : ''),
            '{!Product__c.Accepted_Interest_rate__c}' => (pro.Accepted_Interest_rate__c != null ? +String.valueOf(pro.Accepted_Interest_rate__c) + '%' : ''),
            '{!Product__c.Accepted_Payment_Amount__c}' => (pro.Accepted_Payment_Amount__c != null ? '$' + String.valueOf(pro.Accepted_Payment_Amount__c) : ''),
            '{!Product__c.Manually_Fill__c}' => (pro.Manually_Fill__c != null ? '$' + String.valueOf(pro.Manually_Fill__c) : ''),
            '{!Product__c.Originating_Creditor__c}' => (pro.Originating_Creditor__c != null ? pro.Originating_Creditor__c : ''),
            '{!Product__c.Expected_First_disbursement_date__c}' => (pro.Expected_First_disbursement_date__c != null
                ? DateTime.newInstance(
                          pro.Expected_First_disbursement_date__c.year(),
                          pro.Expected_First_disbursement_date__c.month(),
                          pro.Expected_First_disbursement_date__c.day()
                      )
                      .formatGMT('MMM dd, yyyy')
                : ''),
            '{!Product__c.Current_Interest_Rate__c}' => (pro.Current_Interest_Rate__c != null ? +String.valueOf(pro.Current_Interest_Rate__c) + '%' : ''),
            '{!Product__c.Proposal_Reject_Reason__c}' => (pro.Proposal_Reject_Reason__c != null ? pro.Proposal_Reject_Reason__c : ''),
            '{!Product__c.Proposal_Status__c}' => (pro.Proposal_Status__c != null ? pro.Proposal_Status__c : ''),
            '{!Product__r.CCS_Agency__r.Name}' => (pro.CCS_Agency__r.Name != null ? pro.CCS_Agency__r.Name : ''),
            '{!Product__c.Settlement_Amount__c}' => (pro.Settlement_Amount__c != null ? '$' + String.valueOf(pro.Settlement_Amount__c.format()) : ''),
            '{!Product__c.Settlement_Manual_Date__c}' => (pro.Settlement_Manual_Date__c != null
                ? DateTime.newInstance(pro.Settlement_Manual_Date__c.year(), pro.Settlement_Manual_Date__c.month(), pro.Settlement_Manual_Date__c.day())
                      .formatGMT('MMM dd, yyyy')
                : ''),
            '{!product__c.Proposal_Date__c}' => (pro.CCS_Proposal_Date__c != null
                ? DateTime.newInstance(pro.CCS_Proposal_Date__c.year(), pro.CCS_Proposal_Date__c.month(), pro.CCS_Proposal_Date__c.day())
                      .formatGMT('MMM dd, yyyy')
                : ''),
            '{!Product__c.CCS_Client_ID__c}' => (pro.CCS_Client_ID__c != null ? pro.CCS_Client_ID__c : ''),
            '{!Product__c.Proposal_Received_Date__c}' => (pro.Proposal_Received_Date__c != null
                ? DateTime.newInstance(pro.Proposal_Received_Date__c.year(), pro.Proposal_Received_Date__c.month(), pro.Proposal_Received_Date__c.day())
                      .formatGMT('MMM dd, yyyy')
                : ''),
            '{!Product__r.Customer__r.Name}' => (pro.Customer__r.name != null ? pro.Customer__r.name : ''),
            '{!Product__r.CCS_Agency__r.BillingAddress1}' => (pro.CCS_Agency__r.BillingStreet != null ? pro.CCS_Agency__r.BillingStreet : ''),
            '{!Product__r.CCS_Agency__r.BillingAddress2}' => (pro.CCS_Agency__r.BillingCity != null ? pro.CCS_Agency__r.BillingCity : ''),
            '{!Product__r.CCS_Agency__r.BillingAddress3}' => (pro.CCS_Agency__r.BillingPostalCode != null ? pro.CCS_Agency__r.BillingPostalCode : ''),
            '{!Product__r.CCS_Agency__r.BillingAddress4}' => (pro.CCS_Agency__r.BillingState != null ? pro.CCS_Agency__r.BillingState : ''),
            '{!Product__c.Bank_Name__c}' => (pro.Bank_Name__c != null ? pro.Bank_Name__c : ''),
            '{!Product__c.Bank_Reference_Quoted__c}' => (pro.Bank_Reference_Quoted__c != null ? pro.Bank_Reference_Quoted__c : ''),
            '{!Product__c.Purchase_Factor__c}' => (pro.Purchase_Factor__c != null ? String.valueOf(pro.Purchase_Factor__c.format()) : ''),
            '{!Product__c.Purchase_Price__c}' => (pro.Purchase_Price__c != null ? '$' + String.valueOf(pro.Purchase_Price__c.format()) : ''),
            '{!Product__c.Last_Payment_Amount__c}' => (pro.Last_Payment_Amount__c != null ? '$' + String.valueOf(pro.Last_Payment_Amount__c.format()) : ''),
            '{!Product__c.Last_Payment_Date__c}' => (pro.Last_Payment_Date__c != null
                ? DateTime.newInstance(pro.Last_Payment_Date__c.year(), pro.Last_Payment_Date__c.month(), pro.Last_Payment_Date__c.day())
                      .formatGMT('MMM dd, yyyy')
                : ''),
            '{!Product__c.Current_Balance__c}' => (pro.Current_Balance__c != null ? '$' + String.valueOf(pro.Current_Balance__c.format()) : ''),
            '{!Product__c.Monthly_Payment_Amount__c}' => (pro.Monthly_Payment_Amount__c != null
                ? '$' + String.valueOf(pro.Monthly_Payment_Amount__c.format())
                : ''),
            '{!Product__c.Payment_Frequency__c}' => (pro.Payment_Frequency__c != null ? pro.Payment_Frequency__c : ''),
            '{!CCSPackage.CFG_Office_Name__c}' => (CCSPackage.CFG_Office_Name__c != null ? CCSPackage.CFG_Office_Name__c : ''),
            '{!CCSPackage.CFG_Office_City__c}' => (CCSPackage.CFG_Office_City__c != null ? CCSPackage.CFG_Office_City__c : ''),
            '{!CCSPackage.CFG_Office_Province__c}' => (CCSPackage.CFG_Office_Province__c != null ? CCSPackage.CFG_Office_Province__c : ''),
            '{!CCSPackage.CFG_Office_Address_1__c}' => (CCSPackage.CFG_Office_Address_1__c != null ? CCSPackage.CFG_Office_Address_1__c : ''),
            '{!CCSPackage.CFG_Office_Postal_Code__c}' => (CCSPackage.CFG_Office_Postal_Code__c != null ? CCSPackage.CFG_Office_Postal_Code__c : ''),
            '{!CCSPackage.CFG_Office_Phone_Number__c}' => (CCSPackage.CFG_Office_Phone_Number__c != null ? CCSPackage.CFG_Office_Phone_Number__c : ''),
            '{!CCSPackage.CFG_Office_Fax_Number__c}' => (CCSPackage.CFG_Office_Fax_Number__c != null ? CCSPackage.CFG_Office_Fax_Number__c : ''),
            '{!CCSPackage.CFG_Office_Website__c}' => (CCSPackage.CFG_Office_Website__c != null ? CCSPackage.CFG_Office_Website__c : ''),
            '{!CCSPackage.CFG_Name__c}' => (CCSPackage.CFG_Name__c != null ? CCSPackage.CFG_Name__c : ''),
            '{!servicerName}' => servicerName,
            '{!settleReference}' => settleReference,
            '{!LegalNameofCreditor}' => LegalNameofCreditor,    
            '{!logoVisiblity}' => logoVisiblity
        };

        pageBreakPreviewValues = new Map<String, String>{ '{PageBreak}' => '' };
        pageBreakPDFValues = new Map<String, String>{
            '{PageBreak}' => '<p style="text-align:center;" ><br/><b>{!CCSPackage.CFG_Office_Name__c} </b><br/>' +
            '{!CCSPackage.CFG_Office_Address_1__c} | {!CCSPackage.CFG_Office_City__c} | {!CCSPackage.CFG_Office_Province__c} | {!CCSPackage.CFG_Office_Postal_Code__c} <br/>' +
            'Tel: {!CCSPackage.CFG_Office_Phone_Number__c} | Fax: {!CCSPackage.CFG_Office_Fax_Number__c}<br/>' +
            'Email: {!CCSPackage.CFG_Office_Website__c}</p><br/><P style="page-break-before: always">' +
            '<div style="text-align:center;"> ' +
            '<img src= \'https://sb--sb--c.cs42.content.force.com/servlet/servlet.ImageServer?id=01556000000Vc88&oid=00D56000000D0pk&lastMod=1582813793000\' style="width:100%;max-width:150px;height:40px;"/>' +
            '</div></p>'
        };
    }

    public PageReference CCSEmailAgency() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (toEmail.endsWith(';')) {
            toEmail = toEmail.subString(0, toEmail.length() - 1);
        }
        List<String> toEmails = new List<String>(toEmail.split(';'));
        // read email body from VF page and bind with format of new lines
        String emailBodyCustomized = '';
        if (emailBody != null) {
            for (String s : emailBody.split('\n')) {
                emailBodyCustomized = emailBodyCustomized + s + '<br/>';
            }
        }
        mail.setToAddresses(toEmails);
        mail.setOrgWideEmailAddressId(CCSPackage.Trustee_Email_Org_Wide_Address_Id__c);
        mail.setSubject(subject);
        mail.setHTMLBody(emailBodyCustomized);
        mail.setSaveAsActivity(true);
        mail.setWhatId(pro.Id);

        DateTime d = Date.Today();
        String dateStr = d.formatGMT('yyyy-MM-dd');
        string attachmentName =
            selectedTempalteName +
            ' - ' +
            (pro.Name != null ? pro.Name : '') +
            ' - ' +
            dateStr +
            ' - ' +
            (pro.Customer__r.name != null ? pro.Customer__r.name : '') +
            '.pdf';
        // attach the pdf to email templates
        Blob pdfAttachment;
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(attachmentName);
        if (selectedTempalteName != 'Product Default Template' && selectedTempalteName != 'Program drop' && selectedTempalteName != 'Missed Payment Followup') {
            // efa.setBody(Blob.toPDF(attachmentBody));
            PageReference vfp = new PageReference('/apex/CCS_Email_VFP');
            vfp.getParameters().put('Id', ApexPages.currentPage().getParameters().get('Id'));
            vfp.getParameters().put('template', selectedTempalteName);
            pdfAttachment = vfp.getContent();
            efa.setBody(pdfAttachment);
        }
        fileAttachments.add(efa);
        if (selectedTempalteName != 'Product Default Template' && selectedTempalteName != 'Program drop' && selectedTempalteName != 'Missed Payment Followup') {
            mail.setFileAttachments(fileAttachments);
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            // Create Attachment copy in Activity history
            Task emailTask = [SELECT id FROM Task WHERE whatID = :pro.id ORDER BY CreatedDate DESC LIMIT 1];
            EmailMessage emailmsg = [SELECT Id, parentId FROM EmailMessage WHERE activityId = :emailTask.Id];
            if (
                selectedTempalteName != 'Product Default Template' &&
                selectedTempalteName != 'Program drop' &&
                selectedTempalteName != 'Missed Payment Followup'
            ) {
                list<Attachment> emailMsgAttachments = new List<Attachment>();
                Attachment attach = new Attachment();
                attach.ParentId = emailmsg.Id;
                attach.name = attachmentName;
                attach.body = pdfAttachment;
                attach.Description = '';
                emailMsgAttachments.add(attach);

                if (emailMsgAttachments.size() > 0) {
                    insert emailMsgAttachments;
                }
            }
        }
        return null;
    }
}