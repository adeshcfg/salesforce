/**************************************************************************************************
*
*  Class:   LoRDemandController
*
*  @description : Implemented functionality to send LoR Notice letter, and save LoR Notice as attachment on Insolvency Account
*  @author : A5E Consulting
*  @date : 08/05/2018

*************************************************************************************************/
public class LoRDemandController {
    public Insolvency_Account__c insolvAcc { get; set; }
    // public List<holiday> holiDayList {set;get;}
    // Variable that are used to store emails, email subject, body and exceptions
    public String toEmail { get; set; }
    public String subject { get; set; }
    public String emailBody { get; set; }
    public String attachmentBody { get; set; }
    PoC_Package_Settings__c pocPackage;
    public Boolean isAnyException { get; set; }
    public Boolean isActive { get; set; }
    //public Date nextBusinessDate{set;get;}

    //Language setting
    public List<selectOption> languageList { get; set; }
    public string language { get; set; }

    // Controller loads Insolvency Account record data
    public LoRDemandController() {
        insolvAcc = [
            SELECT
                Id,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Insolvency__r.Trustee__r.Fax,
                Trustee_Company__c,
                Trustee_Office__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Debtor__c,
                Is_Active__c,
                Insolvency__r.Co_Debtor__c,
                Security_Type__c,
                Security_Description__c,
                Insolvency_Status_Last_Changed__c,
                Client_Identifier__c,
                Claim_Type__c,
                Insolvency__r.Name,
                Name,
                Insolvency__r.Debtor_1_First_Name__c,
                Insolvency__r.Debtor_1_Last_Name__c,
                Date_LOR_received_for_Secured__c,
                PoC_Created_Date__c,
                Insolvency_Status__c,
                Secured_Name__c,
                LOR_Notice_1_Sent_Date__c,
                LOR_Notice_2_Sent_Date__c,
                LoR_Notice_1_FollowUp_Date__c,
                Vehicle_Identification_Number__c,
                Account_Type__c,
                Bank_Name__c
            FROM Insolvency_Account__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
        ];
        invalidCriteriaMsg = '';

        language = ApexPages.currentPage().getParameters().get('language');
        //Populate language list
        languageList = new List<selectOption>();
        languageList.add(new SelectOption('en_US', 'English'));
        languageList.add(new SelectOption('fr', 'French'));

        //Set language as per trustee office
        if (null == language) {
            if (null != insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c) {
                language = insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c;
                if (language == 'French') {
                    language = 'fr';
                } else {
                    language = 'en_US';
                }
            } else {
                language = 'en_US';
            }
        }

        //TrusteeOffice Active Check
        isActive = true;
        validateRecord();
        poulateRecord(language);
        WeekdayCalculate();
    }

    public static String getImageUrl(String fileName) {
        Document[] d = [SELECT LastModifiedDate FROM Document WHERE DeveloperName = :fileName];
        if (d.isEmpty()) {
            return '';
        } else {
            return Url.getSalesforceBaseUrl().toExternalForm() +
                '/servlet/servlet.ImageServer?id=' +
                d[0].Id +
                '&oid=' +
                UserInfo.getOrganizationId() +
                '&lastMod=' +
                d[0].LastModifiedDate.getTime();
        }
    }

    public void poulateRecord(String languageValue) {
        subject = '';
        emailBody = '';
        attachmentBody = '';
		Set<String> fairstoneProductTypes = new Set<String>{ 'Secured', 'PL Unsecured', 'PL Secured', 'PL Auto Secured', 'Retail', 'Auto Loans' };
            
        // Check communication preference and use them to send email
        if (insolvAcc.Insolvency__r.Trustee__r.Communication_Preference__c == 'Fax') {
            toEmail = InsolvencyUtil.formatFaxAsEmail(insolvAcc.Insolvency__r.Trustee__r.Fax);
        } else {
            toEmail = insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;
        }

        // Fetch PoC custom settings which will have critical information about the bank
        pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);

        Date dateToday = System.Today();

        // Convert DateTime to Date format ex: May 01, 2018
        //String formattedDate = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('MMM dd, YYYY');
        String formattedDate = DateTime.newInstance(dateToday.year(), dateToday.month(), dateToday.day()).formatGMT('MMM dd, YYYY');
        String companyName = pocPackage.Company_Name__c;
        String clientCompanyName = pocPackage.Client_Company_Name__c;
        String bankNameWiseCompanyName = pocPackage.Client_Company_Name__c;
        String bankNameWiseFrenchCompanyName = pocPackage.Client_Company_Name_French__c;
        // Only used in French template
        String clientCompanyNameSuffix = ' (« Banque Scotia »)';
        if (insolvAcc.Client_Identifier__c == 'Goeasy' && insolvAcc.Account_Type__c == 'Leasing product') {
            pocPackage.Client_Company_Name__c = pocPackage.CFG_Office_Name_2__c;
            clientCompanyNameSuffix = '';
            companyName = pocPackage.CFG_Office_Name_2__c;
            clientCompanyName = pocPackage.CFG_Office_Name_2__c.toUppercase();
            bankNameWiseCompanyName = pocPackage.Company_Name__c;
            bankNameWiseFrenchCompanyName = pocPackage.Company_Name__c;
            if (languageValue == 'fr') {
                pocPackage.Client_Company_Name_French__c = pocPackage.CFG_Office_Name_2__c;
            }
        }
        if (insolvAcc.Client_Identifier__c == 'Goeasy' && insolvAcc.Account_Type__c != 'Leasing product') {
            clientCompanyNameSuffix = '';
            companyName = 'Easyfinancial';
            clientCompanyName = companyName.toUppercase();
            bankNameWiseCompanyName = pocPackage.Company_Name__c;
            bankNameWiseFrenchCompanyName = pocPackage.Company_Name__c;
            if (languageValue == 'fr') {
                pocPackage.Client_Company_Name_French__c = 'Easyfinancial';
            }
        }
        if (insolvAcc.Client_Identifier__c == 'Fairstone' && fairstoneProductTypes.contains(insolvAcc.Account_Type__c)) {
            clientCompanyName = pocPackage.Fairstone_New_Product_Company_Detail__c;
            companyName = pocPackage.Fairstone_New_Product_Company_Detail__c;
            pocPackage.Client_Company_Name_French__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
        }
        if(insolvAcc.Client_Identifier__c == 'Money Mart'){
            clientCompanyNameSuffix = '';
        }
        // Merge fields used in email template
        Map<String, String> emailMergeFields = new Map<String, String>{
            '{!TODAY()}' => formattedDate,
            '{!insolvAcc.Trustee_Company__c}' => (insolvAcc.Trustee_Company__c != null ? insolvAcc.Trustee_Company__c.toUppercase() : ''),
            '{!insolvAcc.Trustee_Office__c}' => (insolvAcc.Trustee_Office__c != null ? '(' + insolvAcc.Trustee_Office__c.toUppercase() + ')' : ''),
            '{!insolv.Debitors}' => (insolvAcc.Insolvency__r.Debtor__c != null ? insolvAcc.Insolvency__r.Debtor__c : '') +
            (insolvAcc.Insolvency__r.Co_Debtor__c != null
                ? (insolvAcc.Insolvency__r.Debtor__c != null ? ', ' : '') + insolvAcc.Insolvency__r.Co_Debtor__c
                : ''),
            '{!insolvAcc.Security_Type__c}' => (insolvAcc.Security_Type__c != null ? insolvAcc.Security_Type__c : ''),
            '{!insolvAcc.Security_Description__c}' => (insolvAcc.Security_Description__c != null ? insolvAcc.Security_Description__c : ''),
            '{!insolvAcc.Insolvency_Status_Last_Changed__c}' => String.valueOf(insolvAcc.Insolvency_Status_Last_Changed__c.formatGMT('MMM dd, YYYY')),
            '{!pocPackage.Client_Company_Name__c}' => pocPackage.Client_Company_Name__c.toUppercase(),
            '{!pocPackage.Company_Name__c}' => pocPackage.Company_Name__c,
            '{!pocPackage.CFG_Office_Name_2__c}' => pocPackage.CFG_Office_Name_2__c,
            '{!companyName}' => companyName,
            '{!clientCompanyName}' => clientCompanyName,
            '{!clientCompanyNameSuffix}' => clientCompanyNameSuffix,
            '{5 business days}' => WeekdayCalculate(),
            //'{!nextBusinessDate}' => DateTime.newInstance(nextBusinessDate.year(), nextBusinessDate.month(), nextBusinessDate.day()).formatGMT('MMM dd, YYYY'),
            '{!pocPackage.CFG_Office_Phone_Number__c}' => pocPackage.CFG_Office_Phone_Number__c.replace('-', '.'),
            '{!insolvAcc.LOR_Notice_1_Sent_Date__c}' => (insolvAcc.LOR_Notice_1_Sent_Date__c != null
                ? DateTime.newInstance(
                          insolvAcc.LOR_Notice_1_Sent_Date__c.year(),
                          insolvAcc.LOR_Notice_1_Sent_Date__c.month(),
                          insolvAcc.LOR_Notice_1_Sent_Date__c.day()
                      )
                      .format('MMM dd, YYYY')
                : ''),
            '{!pocPackage.CFG_Office_Email_Address__c}' => pocPackage.CFG_Office_Email_Address__c,
            '{!pocPackage.Client_Company_Name}' => pocPackage.Client_Company_Name__c,
            '{!pocPackage.Client_Company_Name_French__c}' => pocPackage.Client_Company_Name_French__c,
            '{!pocPackage.CFG_Office_Fax_Number__c}' => pocPackage.CFG_Office_Fax_Number__c.replace('-', '.'),
            '{!pocPackage.CFG_Office_Name}' => pocPackage.CFG_Office_Name__c,
            '{!Insolvency_Account__c.Vehicle_Identification_Number__c}' => (insolvAcc.Vehicle_Identification_Number__c != null
                ? insolvAcc.Vehicle_Identification_Number__c
                : ''),
            '{!Insolvency_Account__c.Secured_Name__c}' => insolvAcc.Secured_Name__c,
            '{!pocPackage.CFG_Office_Name__c}' => pocPackage.CFG_Office_Name__c,
            '{!pocPackage.BankNameWiseCompanyName}' => bankNameWiseCompanyName,
            '{!pocPackage.BankNameWiseFrenchCompanyName}' => bankNameWiseFrenchCompanyName,
            '{!pocPackage.CFG_Office_Address_1__c}' => pocPackage.CFG_Office_Address_1__c,
            '{!pocPackage.CFG_Office_City__c}' => pocPackage.CFG_Office_City__c,
            '{!pocPackage.CFG_Office_Province__c}' => pocPackage.CFG_Office_Province__c,
            '{!pocPackage.CFG_Office_Postal_Code__c}' => pocPackage.CFG_Office_Postal_Code__c,
            '{!pocPackage.CFG_Office_Website__c}' => pocPackage.CFG_Office_Website__c,
            '{!pocPackage.CFG_French_Office_Name__c}' => pocPackage.CFG_French_Office_Name__c,
            '{!imageURL}' => insolvAcc.Client_Identifier__c == 'Goeasy'
                ? LoRDemandController.getImageUrl('CFG_monogram_Logo')
                : LoRDemandController.getImageUrl('CFG_Logo_Temp1')
        };

        List<EmailTemplate> emtList = new List<EmailTemplate>();

        if (languageValue == 'fr') {
            emtList = [
                SELECT Id, Name, HtmlValue, Body, Subject
                FROM EmailTemplate
                WHERE Id = :pocPackage.LoR_DemandTemplate_French_Id__c OR Id = :pocPackage.LoR_Notice_1_Content_French_Id__c
            ];
        } else {
            emtList = [
                SELECT Id, Name, HtmlValue, Body, Subject
                FROM EmailTemplate
                WHERE Id = :pocPackage.LoR_DemandTemplate_Id__c OR Id = :pocPackage.LoR_Notice_1_Content_Id__c
            ];
        }
        // Fetch LoRNotice1 email template
        for (EmailTemplate emt : emtList) {
            if (emt.Id == pocPackage.LoR_DemandTemplate_Id__c || emt.Id == pocPackage.LoR_DemandTemplate_French_Id__c) {
                attachmentBody = emt.HtmlValue;
                // subject = emt.Subject;
                // emailBody = attachmentBody.stripHtmlTags();
            } else if (emt.Id == pocPackage.LoR_Notice_1_Content_Id__c || emt.Id == pocPackage.LoR_Notice_1_Content_French_Id__c) {
                subject = emt.subject;
                subject = subject.replace('{!insolv.EstateNumber}', insolvAcc.Insolvency__r.Name);
                subject = subject.replace('{!Insolvency_Account__c.Secured_Name__c}', insolvAcc.Secured_Name__c);
                emailBody = emt.Body;
            }
        }

        // replace merge fields in email template with actual values in Insolvency Account
        if (!Test.isRunningTest()) {
            for (String str : emailMergeFields.keySet()) {
                emailBody = emailBody.replace(str, emailMergeFields.get(str));
                attachmentBody = attachmentBody.replace(str, emailMergeFields.get(str));
            }
        }
    }

    public String invalidCriteriaMsg { get; set; }

    // validate insolvency account
    public void validateRecord() {
        if (insolvAcc.Claim_Type__c != 'Secured') {
            invalidCriteriaMsg = invalidCriteriaMsg + ' Claim type is not Secured\n';
        }
        if (insolvAcc.Date_LOR_received_for_Secured__c != null) {
            invalidCriteriaMsg = invalidCriteriaMsg + 'LOR Received date is not blank \n';
        }

        if (insolvAcc.PoC_Created_Date__c == null) {
            invalidCriteriaMsg = invalidCriteriaMsg + 'PoC Created Date is Blank \n';
        } else if (insolvAcc.PoC_Created_Date__c >= System.Today().addDays(-30)) {
            invalidCriteriaMsg = invalidCriteriaMsg + 'PoC is created in last 30 days \n';
        }
        if (insolvacc.Insolvency_Status__c != 'Claim Filed') {
            invalidCriteriaMsg = invalidCriteriaMsg + 'Processing Status is not Claim Filed \n';
        }
        if (insolvAcc.Is_Active__c == false) {
            system.debug('Trustee is not Active so Email cannot be sent');
            invalidCriteriaMsg = invalidCriteriaMsg + 'Trustee Office is not Active so email cannot be sent \n';
            isActive = false;
        }
    }

    public static Map<Date, ID> mapHoliday() {
        List<holiday> holiDayList = [SELECT id, name, ActivityDate FROM holiday];
        Map<Date, ID> mapHolidays = new Map<Date, ID>();
        for (Holiday hDay : holiDayList) {
            mapHolidays.put(hDay.ActivityDate, hDay.id);
        }
        return mapHolidays;
    }

    public static String WeekdayCalculate() {
        DateTime todayDate = system.now();
        Integer count = 0;
        Map<Date, ID> mapHolidays = mapHoliday();
        DateTime workingDay5;
        for (Integer i = 0; count < 5; i++) {
            workingDay5 = todayDate + i;
            if (workingDay5.format('E') == 'sat' || workingDay5.format('E') == 'sun' || mapHolidays.get(workingDay5.Date()) <> null) {
                //Do Nothing
            } else {
                count++;
            }
        }

        String formattedDate = workingDay5.formatGMT('MMM dd, YYYY');
        return formattedDate;
    }

    // Method is used to send email to trustee, and creates Activity under Insolvency account
    public Void sendEmail() {
        String attachmentVfPage = insolvAcc.Client_Identifier__c == 'Goeasy' || insolvAcc.Client_Identifier__c == 'Money Mart' ? 'LOR_Demand_Goeasy_VFP' : 'LOR_Demand_VFP';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (toEmail.endsWith(';')) {
            toEmail = toEmail.subString(0, toEmail.length() - 1);
        }
        List<String> toEmails = new List<String>(toEmail.split(';'));
        mail.setToAddresses(toEmails);
        mail.setOrgWideEmailAddressId(pocPackage.Trustee_Email_Org_Wide_Address_Id__c);
        mail.setSubject(subject);
        mail.setPlainTextBody(emailBody);
        mail.setSaveAsActivity(true);
        mail.setWhatId(insolvAcc.Id);

        DateTime d = Date.Today();
        String dateStr = d.formatGMT('yyyy-MM-dd');
        String attachmentName =
            'Security Letter of Release - ' +
            dateStr +
            ' - ' +
            insolvAcc.Insolvency__r.Name +
            ' - ' +
            insolvAcc.Name +
            ' - ' +
            (insolvAcc.Insolvency__r.Debtor_1_First_Name__c != null ? insolvAcc.Insolvency__r.Debtor_1_First_Name__c : '') +
            ' ' +
            (insolvAcc.Insolvency__r.Debtor_1_Last_Name__c != null ? insolvAcc.Insolvency__r.Debtor_1_Last_Name__c : '') +
            '.pdf';

        // Attach pdf to email message with same content as per LoR Notice Letter 1 template
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(attachmentName);
        Blob pdfAttachment;
        PageReference vfp = new PageReference('/apex/' + attachmentVfPage);
        vfp.getParameters().put('Id', ApexPages.currentPage().getParameters().get('Id'));
        vfp.getParameters().put('selectedLanguage', language);
        if (!Test.isRunningTest()) {
            pdfAttachment = vfp.getContent();
        } else {
            pdfAttachment = Blob.valueOf('Test');
        }
        efa.setBody(pdfAttachment);
        fileAttachments.add(efa);
        mail.setFileAttachments(fileAttachments);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });

        ContentVersion conVer = new ContentVersion();
        try {
            // Update LoR notice sent date
            insolvAcc.LoR_Notice_1_Sent_Date__c = System.Today();
            insolvAcc.Do_Not_Run_Status_Validation__c = true;
            update insolvAcc;

            conVer = InsolvencyUtil.saveContentDocument(insolvAcc.Id, pdfAttachment, attachmentName, 'LoR Request Document');

            // Revert back custom setting value with previous value
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        } catch (Exception ex) {
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            isAnyException = true;
            Insolvency_Error__c inslErr = new Insolvency_Error__c();
            inslErr.Insolvency_Account__c = insolvAcc.Id;
            inslErr.Action__c = 'Email Trustee';
            inslErr.Error__c = 'Exception: ' + ex.getTypeName();
            inslErr.Error__c += '\nMessage: ' + ex.getMessage();
            inslErr.Error__c += '\nStack trace:\n' + ex.getStackTraceString();

            try {
                insert inslErr;
            } catch (Exception inslErrEx) {
                system.debug('inslErr Message :' + inslErrEx.getMEssage());
            }
        }

        // Create Attachment copy in Activity history
        Task emailTask = [SELECT id FROM Task WHERE whatID = :insolvAcc.id ORDER BY CreatedDate DESC LIMIT 1];
        EmailMessage emailmsg = [SELECT Id, parentId FROM EmailMessage WHERE activityId = :emailTask.Id];

        /*list<Attachment> emailMsgAttachments = new List<Attachment>();
        Attachment attach = new Attachment();
        attach.ParentId = emailmsg.Id;
        attach.name = attachmentName;
        attach.body = pdfAttachment;
        attach.Description = 'LoR Request Document';*/

        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId =conVer.ContentDocumentId;
        conDocLink.LinkedEntityId = emailmsg.Id;
        conDocLink.ShareType = 'V';
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;

        /*emailMsgAttachments.add(attach);

        if (emailMsgAttachments.size() > 0) {
            insert emailMsgAttachments;
        }*/
    }

    //change the language
    public void changeLanguage() {
        validateRecord();
        if (language == 'fr') {
            poulateRecord(language);
        } else {
            poulateRecord(language);
        }
    }

    public PageReference popupAttachment() {
        PageReference pgr = new PageReference('/apex/LORDemandAttachment');
        Map<String, String> params = pgr.getParameters();

        params.put('language', language);
        params.put('id', insolvAcc.id);
        pgr.setRedirect(true);
        return pgr;
    }

    public PageReference reDirect() {
        PageReference pgr = Page.LORDemand;
        Map<String, String> params = pgr.getParameters();

        params.put('language', language);
        params.put('id', insolvAcc.id);
        pgr.setRedirect(true);
        return pgr;
    }
}