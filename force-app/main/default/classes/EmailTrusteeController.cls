/**************************************************************************************************
*
*  Class:   EmailTrusteeController
*
*  @description : This is a controller class to send emails to trustee from Insolvency account page 
*  @author : A5E Consulting
*  @date : 09/26/2017

*************************************************************************************************/
public class EmailTrusteeController {
    // Variable to fetch data related to custom settings, exceptions
    public PoC_Package_Settings__c pocPackage { get; set; }
    public Boolean isSelectedAtt { get; set; }

    //Show validation message when total attachments size is exceeded
    public Application_Config_Settings__c config; // = Application_Config_Settings__c.getOrgDefaults();
    public Boolean attachSizeException { get; set; }
    public String attachSizeExceptionMessage { get; set; }

    public Boolean isAnyException { get; set; }
    public String attachmentSelected { get; set; }
    public Insolvency_Account__c insolvAcc { get; set; }
    public List<InsolvAttachments> insolvAttachList { get; set; }
    public Boolean docException { get; set; }
    public Boolean accStatementError { get; set; }
    public Boolean isAmemdedClaim { get; set; }
    public Boolean isPocRequired { get; set; }
    public Boolean isActive { get; set; }
    // Variable that are used to store emails, email subject, body and footers
    public String toEmail { get; set; }
    public String toEmailBefore { get; set; }
    public String toFollowUpEmail { get; set; }
    public String subject { get; set; }
    public String htmlEmailheader { get; set; }
    public String htmlEmailfooter { get; set; }
    public String emailBody { get; set; }
    public String emailName { get; set; }

    // Stores all attachments that are selected by user
    public Set<String> mySelectedAtt = new Set<String>();

    //template lists for which Trustee follow up email is required
    list<Id> followUpEmailRequiredTemplatesList { get; set; }
    public Boolean flagForTrusteeFollowUpEmail { get; set; }

    //template lists for with or without header
    list<Id> insolTemplateWithHeaderList { get; set; }
    list<Id> insolTemplateWithoutHeaderList { get; set; }

    //template lists for mandatory attchments list
    list<Id> insolTemplateWithManAttachList { get; set; }

    // template related variables
    public List<selectOption> templates { get; set; }
    public Id selectedTemplate { get; set; }
    map<Id, EmailTemplate> emailTemplateMap = new Map<Id, EmailTemplate>();
	Set<String> fairstoneProductTypes = new Set<String>{ 'Secured', 'PL Unsecured', 'PL Secured', 'PL Auto Secured', 'Retail', 'Auto Loans' };
    //Language setting
    public List<selectOption> languageList { get; set; }
    public string language { get; set; }

    // Controller to load initial values and insolvancy account details
    public EmailTrusteeController() {
        isAnyException = false;
        isAmemdedClaim = false;
        isPocRequired = false;
        flagForTrusteeFollowUpEmail = false;
        //Atachment Size limit check
        attachSizeException = false;
        //TrusteeOffice Active Check
        isActive = true;

        subject = '';
        emailBody = '';
        htmlEmailheader = '';

        //Populate language list
        languageList = new List<selectOption>();
        languageList.add(new SelectOption('en_US', 'English'));
        languageList.add(new SelectOption('fr', 'French'));

        insolTemplateWithHeaderList = new List<ID>();
        insolTemplateWithoutHeaderList = new List<ID>();
        config = [
            SELECT Maximum_Email_Attachments_Size_Text__c, Maximum_Email_Attachments_Size__c, Run_Insolvency_Status_Validations__c, Domain_Name__c
            FROM Application_Config_Settings__c
        ];

        attachSizeExceptionMessage = config.Maximum_Email_Attachments_Size_Text__c;

        insolvAcc = [
            SELECT
                Id,
                Name,
                Secured_Name__c,
                Insolvency__r.Trustee__r.ParentId,
                Is_Active__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency_Account__c.Borrower_Primary__c,
                Insolvency__r.Debtor__c,
                Balance_Owed__c,
                Insolvency__r.Trustee__r.Fax,
                Insolvency__r.Trustee__r.Business_Email__c,
                Insolvency__r.Trustee__r.Follow_up_Email__c,
                Insolvency_Status__c,
                Insolvency__r.Name,
                Client_Identifier__c,
            	Account_Type__c,
                Reason_for_No_PoC_Required_Dropdown__c,
                Reason_for_No_PoC_Required__c,
                Amended_Claim_Flag__c,
                Insolvency_Type__c,
                Portfolio_Name_Lookup__r.Non_Servicing_Portfolio__c,
                Claim_Filed_Date__c //for SLA tracking
            FROM Insolvency_Account__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
        ];

        //Set language as per trustee office
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

        if (insolvAcc.Insolvency__r.Trustee__r.Communication_Preference__c == 'Fax') {
            toEmail = formatFaxAsEmail(insolvAcc.Insolvency__r.Trustee__r.Fax);
        } else {
            toEmail = insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;
            toFollowUpEmail = insolvAcc.Insolvency__r.Trustee__r.Follow_up_Email__c;
        }
        toEmailBefore = toEmail;

        //checking if Trustee Office is Active
        if (insolvAcc.Is_Active__c == false) {
            //system.debug('Trustee Office is not Active so email cannot be sent');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Trustee Office is not Active so email cannot be sent'));
            isActive = false;
        }
        if (insolvAcc.Portfolio_Name_Lookup__r.Non_Servicing_Portfolio__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot send email as Account is linked to Non servicing Portfolio'));
            isActive = false;
        }
        insolvAttachList = new List<InsolvAttachments>();

        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);

        // Read all attachments related to insolvacny account
        for (Attachment attchmt : [
            SELECT Name, Body, BodyLength, Description, createdDate
            FROM Attachment
            WHERE ParentId = :insolvAcc.Id
            ORDER BY lastmodifieddate DESC
        ]) {
            InsolvAttachments temp = new InsolvAttachments();
            temp.attId = attchmt.Id;
            temp.selected = false;
            temp.fileName = attchmt.Name;
            temp.fileDesc = attchmt.Description;
            temp.fileCreatedDate = attchmt.createdDate.addSeconds(offset / 1000);
            temp.displaySize = InsolvencyUtil.fileSizeToString((attchmt.BodyLength));
            insolvAttachList.add(temp);
        }
        // Read all contentversions related to insolvacny account
        Set<Id> conDocIds = new Set<Id>();
        List<ContentVersion> conVerList = new List<ContentVersion>();
        for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId from ContentDocumentLink where LinkedEntityid =: insolvAcc.Id]){
            conDocIds.add(conDocLink.ContentDocumentId);
        }
        if(conDocIds.size() > 0){
            conVerList = [SELECT id, ContentDocumentId, Title, Description, CreatedDate, ContentSize  FROM ContentVersion WHERE contentDocumentId in : conDocIds ORDER BY CreatedDate DESC];
        }
        for(ContentVersion conVer: conVerList){
            InsolvAttachments temp = new InsolvAttachments();
            temp.attId = conVer.ContentDocumentId;
            temp.selected = false;
            temp.fileName = conVer.Title;
            temp.fileDesc = conVer.Description;
            temp.fileCreatedDate = conVer.createdDate.addSeconds(offset / 1000);
            temp.displaySize = InsolvencyUtil.fileSizeToString((conVer.ContentSize));
            insolvAttachList.add(temp);
        }
        // Check for statements stored as document storage records
        if (insolvAcc.Client_Identifier__c == 'Canadian Tire') {
            for (Document_Storage__c docStorage : [
                SELECT Document_Name__c, Document_URL__c, Document_Type__c, CreatedDate
                FROM Document_Storage__c
                WHERE Insolvency_Account__c = :insolvAcc.Id
                ORDER BY LastModifiedDate DESC
            ]) {
                InsolvAttachments temp = new InsolvAttachments();
                temp.attId = docStorage.Document_URL__c;
                temp.selected = false;
                temp.fileName = docStorage.Document_Name__c;
                temp.fileDesc = 'Account Statement';
                temp.fileCreatedDate = docStorage.createdDate.addSeconds(offset / 1000);
                insolvAttachList.add(temp);
            }
        }

        // Read custom settings to use hard code values in poc package
        pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        changeLanguage();
    }

    //Loads template which names start with Insolvency
    public void loadEmailTemplates() {
        //Fetcth Id's List for With or Without Header
        string idWithHeaderList = pocPackage.Insolvency_Template_Header__c;
        insolTemplateWithHeaderList = idWithHeaderList.split(',');
        string idWithoutHeaderList = pocPackage.Insolvency_Template_WoHeader__c;
        insolTemplateWithoutHeaderList = idWithoutHeaderList.split(',');

        //Fetcth Id's List for Attachment Required Email Templates
        String idWithMandAttchList = pocPackage.Attachment_Required_Email_Templates__c;
        insolTemplateWithManAttachList = idWithMandAttchList.split(',');

        //Default Template
        selectedTemplate = insolTemplateWithoutHeaderList.get(0);

        templates = new List<selectOption>();
        //templates.add(new SelectOselectedTemplateption('','--select--'));
        //for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Name LIKE 'Insolvency %' OR Name LIKE 'POC %') AND (NOT NAME LIKE '%Error%')])
        for (EmailTemplate emailTemp : [
            SELECT Id, Name, HtmlValue, Body, Subject
            FROM EmailTemplate
            WHERE Id IN :insolTemplateWithHeaderList OR Id IN :insolTemplateWithoutHeaderList /*OR Id IN: insolTemplateWithManAttachList */
            ORDER BY Name
        ]) {
            emailTemplateMap.put(emailTemp.Id, emailTemp);
            templates.add(new SelectOption(emailTemp.Id, emailTemp.Name));
        }
    }

    //Loads French template which names start with Insolvency
    public void loadFrenchEmailTemplates() {
        //Fetcth Id's List for With or Without Header
        string idWithHeaderList = pocPackage.Insolvency_Template_Header_French__c;
        if (String.isNotBlank(idWithHeaderList)) {
            insolTemplateWithHeaderList = idWithHeaderList.split(',');
        }
        string idWithoutHeaderList = pocPackage.Insolvency_Template_WoHeader_French__c;
        if (String.isNotBlank(idWithoutHeaderList)) {
            insolTemplateWithoutHeaderList = idWithoutHeaderList.split(',');
        }

        //Fetcth Id's List for Attachment Required Email Templates
        String idWithMandAttchList = pocPackage.Attachment_Required_Email_Templates__c;
        if (String.isNotBlank(idWithMandAttchList)) {
            insolTemplateWithManAttachList = idWithMandAttchList.split(',');
        }

        //Default Template
        if (insolTemplateWithoutHeaderList != null && !insolTemplateWithoutHeaderList.isEmpty()) {
            selectedTemplate = insolTemplateWithoutHeaderList.get(0);
        }

        templates = new List<selectOption>();
        //templates.add(new SelectOption('','--select--'));
        //for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Name LIKE 'Insolvency %' OR Name LIKE 'POC %') AND (NOT NAME LIKE '%Error%')])
        if (insolTemplateWithHeaderList != null) {
            for (EmailTemplate emailTemp : [
                SELECT Id, Name, HtmlValue, Body, Subject
                FROM EmailTemplate
                WHERE Id IN :insolTemplateWithHeaderList OR Id IN :insolTemplateWithoutHeaderList /*OR Id IN: insolTemplateWithManAttachList */
                ORDER BY Name
            ]) {
                emailTemplateMap.put(emailTemp.Id, emailTemp);
                templates.add(new SelectOption(emailTemp.Id, emailTemp.Name));
            }
        }
    }

    //Load email template body, subject seelcted from drop down
    public void emailTemplatechanged() {
        if (insolvAcc.Client_Identifier__c == 'Fairstone' && fairstoneProductTypes.contains(insolvAcc.Account_Type__c)) {
            pocPackage.Company_Name__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
            pocPackage.Client_Company_Name_French__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
            pocPackage.Client_Company_Name__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
        }
        
        flagForTrusteeFollowUpEmail = false;
        //get ID's of template for follow-up email.
        string idforTrusteeFollowupEmail = pocPackage.Follow_Up_Email_Required_Templates__c;
        //checking if the selected tepmplate needs trustee follow-up email.
        if (idforTrusteeFollowupEmail != null) {
            followUpEmailRequiredTemplatesList = idforTrusteeFollowupEmail.split(',');
        }

        if (followUpEmailRequiredTemplatesList != null) {
            if (followUpEmailRequiredTemplatesList.contains(selectedTemplate)) {
                flagForTrusteeFollowUpEmail = true;
            } else {
                flagForTrusteeFollowUpEmail = false;
            }
        }
        if (toFollowUpEmail != null && flagForTrusteeFollowUpEmail == true) {
            toEmail = toFollowUpEmail;
        } else {
            toEmail = toEmailBefore;
        }
        if (emailTemplateMap.containsKey(selectedTemplate)) {
            EmailTemplate emt = emailTemplateMap.get(selectedTemplate);
            subject = emt.subject;
            if (Test.isRunningTest()) {
                subject = '{!Insolvency_Account__c.Secured_Name__c},{!Insolvency_Account__c.Name},{!Insolvency_Account__c.Borrower_Primary__c},{!Insolvency__r.Name},{!Insolvency__r.Debtor__c},{!Insolvency_Account__c.Insolvency_Type__c}';
            }
            if (subject != null) {
                if (subject.contains('{!Insolvency_Account__c.Secured_Name__c}')) {
                    subject = subject.replace('{!Insolvency_Account__c.Secured_Name__c}', (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c : ''));
                }

                if (subject.contains('{!Insolvency_Account__c.Name}')) {
                    subject = subject.replace('{!Insolvency_Account__c.Name}', (insolvAcc.Name != null ? insolvAcc.Name : ''));
                }

                if (subject.contains('{!Insolvency_Account__c.Borrower_Primary__c}')) {
                    subject = subject.replace(
                        '{!Insolvency_Account__c.Borrower_Primary__c}',
                        (insolvAcc.Borrower_Primary__c != null ? insolvAcc.Borrower_Primary__c : '')
                    );
                }

                if (subject.contains('{!Insolvency__r.Name}')) {
                    subject = subject.replace('{!Insolvency__r.Name}', insolvAcc.Insolvency__r.Name);
                }

                if (subject.contains('{!Insolvency__r.Debtor__c}')) {
                    subject = subject.replace('{!Insolvency__r.Debtor__c}', insolvAcc.Insolvency__r.Debtor__c);
                }

                if (insolvAcc.Insolvency_Type__c != null) {
                    if (subject.contains('{!Insolvency_Account__c.Insolvency_Type__c}')) {
                        subject = subject.replace('{!Insolvency_Account__c.Insolvency_Type__c}', insolvAcc.Insolvency_Type__c);
                    }
                }
            }

            emailBody = emt.body;
            emailName = emt.Name;
            String[] emailContent = emt.HTMLValue.split('<body>');
            if (emailContent.size() == 1) {
                htmlEmailheader = emailContent[0];
            }
            if (emailContent.size() == 2) {
                emailContent = emailContent[1].split('</body>');
                htmlEmailFooter = emailContent[1];
            }
            // replace all merge fields that are in email template
            if (Test.isRunningTest()) {
                emailBody = '{!Insolvency_Account__c.Balance_Owed__c},{!Insolvency_Account__c.Secured_Name__c},{!pocPackage.CFG_Office_Fax_Number__c},{!pocPackage.CFG_Office_Phone_Number__c},{!Insolvency__r.Name},{!Insolvency_Account__c.Reason_for_No_PoC_Required_Dropdown__c},{!Insolvency_Account__c.Reason_for_No_PoC_Required__c},{!pocPackage.CFG_Office_Address_1__c},{!pocPackage.CFG_Office_Address__c},{!pocPackage.Name},{!pocPackage.CFG_Office_City__c},{!pocPackage.CFG_Office_Province_Short_Code__c},{!pocPackage.CFG_Office_Postal_Code__c},{!pocPackage.CFG_Payment_Postal_Code__c},{!pocPackage.CFG_Office_Email_Address__c}';
            }
            if (emailBody != null) {
                if (emailBody.contains('{!Insolvency_Account__c.Balance_Owed__c}')) {
                    emailBody = emailBody.replace('{!Insolvency_Account__c.Balance_Owed__c}', '$' + String.valueOf(insolvAcc.Balance_Owed__c));
                }

                if (emailBody.contains('{!Insolvency_Account__c.Secured_Name__c}')) {
                    emailBody = emailBody.replace(
                        '{!Insolvency_Account__c.Secured_Name__c}',
                        (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c : '')
                    );
                }

                if (emailBody.contains('{!Insolvency__r.Name}')) {
                    emailBody = emailBody.replace('{!Insolvency__r.Name}', insolvAcc.Insolvency__r.Name);
                }

                if (emailBody.contains('{!Insolvency_Account__c.Reason_for_No_PoC_Required_Dropdown__c}')) {
                    emailBody = emailBody.replace(
                        '{!Insolvency_Account__c.Reason_for_No_PoC_Required_Dropdown__c}',
                        (insolvAcc.Reason_for_No_PoC_Required_Dropdown__c != null ? insolvAcc.Reason_for_No_PoC_Required_Dropdown__c : '')
                    );
                }

                if (emailBody.contains('{!Insolvency_Account__c.Reason_for_No_PoC_Required__c}')) {
                    emailBody = emailBody.replace(
                        '{!Insolvency_Account__c.Reason_for_No_PoC_Required__c}',
                        (insolvAcc.Reason_for_No_PoC_Required__c != null ? insolvAcc.Reason_for_No_PoC_Required__c : '')
                    );
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Name__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Name__c}', pocPackage.CFG_Office_Name__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Website__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Website__c}', pocPackage.CFG_Office_Website__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Province__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Province__c}', pocPackage.CFG_Office_Province__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Address_1__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Address_1__c}', pocPackage.CFG_Office_Address_1__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Address__c}')) {
                    emailBody = emailBody.replace(
                        '{!pocPackage.CFG_Office_Address__c}',
                        (pocPackage.CFG_Office_Address__c != null ? pocPackage.CFG_Office_Address__c : '')
                    );
                }

                if (emailBody.contains('{!pocPackage.Name}')) {
                    emailBody = emailBody.replace('{!pocPackage.Name}', pocPackage.Name);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_City__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_City__c}', pocPackage.CFG_Office_City__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Province_Short_Code__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Province_Short_Code__c}', pocPackage.CFG_Office_Province_Short_Code__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Postal_Code__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Postal_Code__c}', pocPackage.CFG_Office_Postal_Code__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Payment_Postal_Code__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Payment_Postal_Code__c}', pocPackage.CFG_Payment_Postal_Code__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Email_Address__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Email_Address__c}', pocPackage.CFG_Office_Email_Address__c);
                }

                if (emailBody.contains('{!pocPackage.Company_Name__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.Company_Name__c}', pocPackage.Company_Name__c);
                }

                if (emailBody.contains('{!pocPackage.Client_Company_Name_French__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.Client_Company_Name_French__c}', pocPackage.Client_Company_Name_French__c);
                }

                if (emailBody.contains('{!pocPackage.Client_Company_Name__c}')) {
                    emailBody = emailBody.replace('{!pocPackage.Client_Company_Name__c}', pocPackage.Client_Company_Name__c);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Fax_Number__c}')) {
                    String numberVal = pocPackage.CFG_Office_Fax_Number__c;
                    if (language == 'fr') {
                        numberVal = numberVal.replace('-', '.');
                    }
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Fax_Number__c}', numberVal);
                }

                if (emailBody.contains('{!pocPackage.CFG_Office_Phone_Number__c}')) {
                    String numberVal = pocPackage.CFG_Office_Phone_Number__c;
                    if (language == 'fr') {
                        numberVal = numberVal.replace('-', '.');
                    }
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Phone_Number__c}', numberVal);
                }

                if (emailName == 'Notice Received to Prove Claim' && insolvAcc.Client_Identifier__c == 'Canaccede') {
                    if (language == 'fr') {
                        emailBody = emailBody.replace(
                            'La raison pour laquelle nous n\'avons pas déposé une réclamation au nom de Scotiabank est',
                            'La raison pour laquelle Canaccede n\'a pas déposé une preuve de réclamation est'
                        );
                    } else {
                        emailBody = emailBody.replace(
                            'The reason that we have not filed a claim on behalf of Scotiabank is',
                            'The reason Canaccede has not filed a claim is'
                        );
                    }
                }

                if (emailName == 'Additional Information Required') {
                    if (insolvAcc.Client_Identifier__c == 'Canaccede') {
                        if (language == 'fr') {
                            emailBody = emailBody.replace('{!Additional_Info_Text}', System.Label.Canaccede_Additional_Info_French_Text);
                        } else {
                            emailBody = emailBody.replace('{!Additional_Info_Text}', System.Label.Canaccede_Additional_Info_Text);
                        }
                    } else {
                        if (language == 'fr') {
                            if (insolvAcc.Client_Identifier__c == 'Flexiti') {
                                emailBody = emailBody.replace(
                                    '{!Additional_Info_Text}',
                                    'Comme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de la ' +
                                    pocPackage.Client_Company_Name__c
                                );
                            }else{
                                emailBody = emailBody.replace(
                                    '{!Additional_Info_Text}',
                                    'Comme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' +
                                    pocPackage.Client_Company_Name__c
                                );
                            }
                            
                        } else {
                            emailBody = emailBody.replace(
                                '{!Additional_Info_Text}',
                                'As you are aware, Canaccede International Management Ltd is processing ' +
                                    pocPackage.Client_Company_Name__c +
                                    ' insolvent accounts'
                            );
                        }
                    }
                }

                if (emailName == 'Creditor Package Request') {
                    if (insolvAcc.Client_Identifier__c == 'Canaccede') {
                        emailBody = emailBody.replace('{!Extra_Line_Except_Canaccede}', '');
                    } else {
                        if (language == 'fr') {
                            emailBody = emailBody.replace(
                                '{!Extra_Line_Except_Canaccede}',
                                '\nComme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' + getBankName() + '.\n'
                            );
                        } else {
                            emailBody = emailBody.replace(
                                '{!Extra_Line_Except_Canaccede}',
                                '\nAs you are aware, Canaccede International Management Ltd is processing ' + getBankName() + ' insolvent accounts.\n'
                            );
                        }
                    }
                }
            }

            if (insolTemplateWithHeaderList.contains(emt.Id)) {
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Name__c}',
                    (pocPackage.CFG_Office_Name__c != null ? pocPackage.CFG_Office_Name__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Address_1__c}',
                    (pocPackage.CFG_Office_Address_1__c != null ? pocPackage.CFG_Office_Address_1__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_City__c}',
                    (pocPackage.CFG_Office_City__c != null ? pocPackage.CFG_Office_City__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Province__c}',
                    (pocPackage.CFG_Office_Province__c != null ? pocPackage.CFG_Office_Province__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Postal_Code__c}',
                    (pocPackage.CFG_Office_Postal_Code__c != null ? pocPackage.CFG_Office_Postal_Code__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Phone_Number__c}',
                    (pocPackage.CFG_Office_Phone_Number__c != null ? pocPackage.CFG_Office_Phone_Number__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Fax_Number__c}',
                    (pocPackage.CFG_Office_Fax_Number__c != null ? pocPackage.CFG_Office_Fax_Number__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Website__c}',
                    (pocPackage.CFG_Office_Website__c != null ? pocPackage.CFG_Office_Website__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Address__c}',
                    (pocPackage.CFG_Office_Address__c != null ? pocPackage.CFG_Office_Address__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Office_Province_Short_Code__c}',
                    (pocPackage.CFG_Office_Province_Short_Code__c != null ? pocPackage.CFG_Office_Province_Short_Code__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.CFG_Payment_Postal_Code__c}',
                    (pocPackage.CFG_Payment_Postal_Code__c != null ? pocPackage.CFG_Payment_Postal_Code__c : '')
                );
                htmlEmailheader = htmlEmailheader.replace(
                    '{!pocPackage.Client_Company_Name__c}',
                    (pocPackage.Client_Company_Name__c != null ? pocPackage.Client_Company_Name__c : '')
                );
            }
        }
    }

    public String getBankName() {
        if (insolvAcc.Client_Identifier__c == 'Scotia Bank' || insolvAcc.Client_Identifier__c == 'SDA' || insolvAcc.Client_Identifier__c == 'SPL') {
            if (language == 'fr') {
                return 'la Banque de Nouvelle-Écosse';
            } else {
                return 'Bank of Nova Scotia';
            }
        } else if (insolvAcc.Client_Identifier__c == 'Fairstone') {
            if(fairstoneProductTypes.contains(insolvAcc.Account_Type__c)){
                if (language == 'fr') {
                    return 'Fairstone Financial Inc.';
                } else {
                    return 'Fairstone Financial Inc.';
                }
            }else{
                if (language == 'fr') {
                    return 'Fairstone';
                } else {
                    return 'Fairstone';
                }
            }
            
        } else if (insolvAcc.Client_Identifier__c == 'Goeasy') {
            if (language == 'fr') {
                return 'Easyhome/Easyfinancial Services Ltd';
            } else {
                return 'Easyhome/Easyfinancial Services Ltd';
            }
        } else if (insolvAcc.Client_Identifier__c == 'Canadian Tire') {
            if (language == 'fr') {
                return 'la Banque Canadian Tire';
            } else {
                return 'Canadian Tire Bank';
            }
        }
        else if (insolvAcc.Client_Identifier__c == 'Money Mart') {
            if (language == 'fr') {
                return 'Money Mart';
            } else {
                return 'Money Mart';
            }
        }
        else if (insolvAcc.Client_Identifier__c == 'Flexiti') {
            if (language == 'fr') {
                return 'Flexiti Financial';
            } else {
                return 'Flexiti Financial';
            }
        }
        return null;
    }

    // Method implementes functionality to send email to trustee with selected attachments
    public PageReference sendEmail() {
        accStatementError = false;
        docException = false;
        attachSizeException = false;
        isPocRequired = false;
        isAmemdedClaim = false;
        if (emailName == 'Amended Proof of Claim' && insolvAcc.Amended_Claim_Flag__c != true) {
            isAmemdedClaim = true;
            isPocRequired = false;
            return null;
        }
        /*
        if(emailName == 'Notice Received to Prove Claim' && insolvAcc.Insolvency_Status__c != 'No PoC Required'){
            isPocRequired = true;
            isAmemdedClaim = false;
            return null;
        }
        */
        //to check if NovaScotia trustee
        if (checkEligibleTrustee()) {
            if (checkAttachmentForAccState()) {
                accStatementError = true;
                return null;
            }
        }
        //send Email with selected attachments for header templates
        if (insolTemplateWithManAttachList.contains(selectedTemplate)) {
            if (checkAttachment()) {
                System.debug('docException');
                docException = true;
                return null;
            }
        }
        //Atachment Size limit check
        Decimal totalFilesize = 0;
        Decimal maxAttachSize = config.Maximum_Email_Attachments_Size__c;
        List<String> selectedContentVersionIds = new List<String>();
        List<Document> docsToDelete = new List<Document>();
        for (Attachment selectedAtt : [SELECT Name, Body, BodyLength FROM Attachment WHERE Id IN :mySelectedAtt]) {
            totalFilesize = totalFilesize + selectedAtt.BodyLength;
        }
        for (ContentVersion conVerSelected : [SELECT id, Title, ContentSize, ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId in : mySelectedAtt]) {
            totalFilesize = totalFilesize + conVerSelected.ContentSize;
        }
        // Only for CTB which can have document storage records for statements
        if (insolvAcc.Client_Identifier__c == 'Canadian Tire') {
            // Query selected document storage records by user if any
            for (Document_Storage__c docStorage : [
                SELECT Document_URL__c, Document_Type__c
                FROM Document_Storage__c
                WHERE Document_URL__c IN :mySelectedAtt
            ]) {
                // API callout to get the document created in SF for selected attachments
                selectedContentVersionIds.add(DocumentAPIClient.getContentVersionIdForAzureFile(docStorage.Document_URL__c, docStorage.Document_Type__c));
            }
            // Calculate total file size and list of documents to delete once email is sent
            for (Document conVer : [SELECT Name, Body, BodyLength, Type FROM Document WHERE Id IN :selectedContentVersionIds]) {
                docsToDelete.add(conVer);
                totalFilesize = totalFilesize + conVer.BodyLength;
            }
        }
        if (totalFilesize > maxAttachSize) {
            attachSizeException = true;
            // Delete created document records for selected attachments
            if (!docsToDelete.isEmpty()) {
                Database.delete(docsToDelete);
            }
            return null;
        } else {
            attachSizeException = false;
        }
        try {
            isAnyException = false;
            // Use single email message feature of salesforce
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
            mail.setOrgWideEmailAddressId(pocPackage.Trustee_Email_Org_Wide_Address_Id__c);
            mail.setSubject(subject);

            if (htmlEmailheader == null) {
                htmlEmailheader = '';
            }
            if (htmlEmailFooter == null) {
                htmlEmailFooter = '';
            }

            String htmlBody = htmlEmailheader + '<body style="clear:both;">' + emailBodyCustomized + '</body>' + htmlEmailFooter;
            mail.setHTMLBody(htmlBody);

            // Set activity tru to create activity once email is send
            mail.setSaveAsActivity(true);
            mail.setWhatId(insolvAcc.Id);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

            // Attach files to email
            for (Attachment attObj : [SELECT Name, Body FROM Attachment WHERE Id IN :mySelectedAtt]) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(attObj.Name);
                efa.setBody(attObj.Body);
                fileAttachments.add(efa);
            }
            //7935
            // Attach files to email
           	List<ContentVersion> conVerList = [SELECT Title, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :mySelectedAtt];
            for (ContentVersion conVerObj : conVerList) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(conVerObj.Title);
                efa.setBody(conVerObj.VersionData);
                fileAttachments.add(efa);
            }
            // Attach selected document storage files to email
            for (Document conVer : docsToDelete) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(conVer.Name + '.' + conVer.Type);
                efa.setBody(conVer.Body);
                fileAttachments.add(efa);
            }

            mail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });

            // Delete created document records for selected attachments
            if (!docsToDelete.isEmpty()) {
                Database.delete(docsToDelete);
            }

            if (insolTemplateWithManAttachList.contains(selectedTemplate)) {
                EmailTrusteeController.updateInsolvencyAccount(insolvAcc.Id, mySelectedAtt);
            }

            // Create Attachment against activity history on Insolvency Account
            List<Task> emailTask = [SELECT id FROM Task WHERE whatID = :insolvAcc.Id ORDER BY CreatedDate DESC LIMIT 1];
            List<EmailMessage> emailmsg = [SELECT Id, parentId FROM EmailMessage WHERE activityId = :emailTask[0].Id];

            list<Attachment> emailMsgAttachments = new List<Attachment>();
            for (Attachment emailMsgAtt : [SELECT Name, Body, ParentId, Description FROM Attachment WHERE Id IN :mySelectedAtt]) {
                Attachment emailAttachment = new Attachment();
                emailAttachment.body = emailMsgAtt.body;
                emailAttachment.Name = emailMsgAtt.Name;
                emailAttachment.Description = emailMsgAtt.Description;
                emailAttachment.ParentId = emailmsg[0].id;
                emailAttachment.isPrivate = false;
                emailMsgAttachments.add(emailAttachment);
            }
            if (emailMsgAttachments.size() > 0) {
                insert emailMsgAttachments;
            }
            List<ContentDocumentLink> conDocLinks = new List<ContentDocumentLink>();
            for (ContentVersion conVerObj : conVerList) {
                // Associate the ContentDocument with an EmailMessage
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = conVerObj.ContentDocumentId; // ID of the uploaded ContentDocument
                contentDocumentLink.LinkedEntityId = emailmsg[0].id; // ID of the EmailMessage record
                contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
                contentDocumentLink.Visibility = 'AllUsers'; // File visibility
                conDocLinks.add(contentDocumentLink);
            }
            if(conDocLinks.size() > 0){
                insert conDocLinks;
            }
        } catch (Exception ex) {
            system.debug('====' + ex.getMessage());
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
        return null;
    }

    // This method updates insolvency Account and inserts attachment against EmailMessages
    @future
    @TestVisible
    private static void updateInsolvencyAccount(String insonvAccId, Set<String> mySelectedAtt) {
        //Querying Insolvency Account again as this is a future method and different transaction
        List<Insolvency_Account__c> insolvAccToUpdate = [
            SELECT id, Insolvency_Status__c, Insolvency_Status_Last_Changed__c, Claim_Filed_Date__c, Do_Not_Run_Status_Validation__c
            FROM Insolvency_Account__c
            WHERE Id = :insonvAccId
            FOR UPDATE
        ];
        if (insolvAccToUpdate != null && insolvAccToUpdate.size() > 0) {
            if (insolvAccToUpdate[0].Insolvency_Status__c == 'PoC Package Generated') {
                insolvAccToUpdate[0].Insolvency_Status__c = 'Claim Filed';
                insolvAccToUpdate[0].Insolvency_Status_Last_Changed__c = System.now();

                if (insolvAccToUpdate[0].Claim_Filed_Date__c == null) {
                    insolvAccToUpdate[0].Claim_Filed_Date__c = System.now();
                    insolvAccToUpdate[0].Claim_Filed_By__c = UserInfo.getUserId();
                }
                insolvAccToUpdate[0].Do_Not_Run_Status_Validation__c = true;
                update insolvAccToUpdate;
            }
        }
    }

    //Handles to store list of attachments selected by user
    public void attachmentSelected() {
        if (attachmentSelected != null) {
            mySelectedAtt.add(attachmentSelected);
            attachmentSelected = null;
        }
    }

    //Handles to remove attachments un selected by user
    public void attachmentRemoved() {
        if (attachmentSelected != null) {
            mySelectedAtt.remove(attachmentSelected);
            attachmentSelected = null;
        }
    }

    //Utility method to format Fax As Email Address
    private static string formatFaxAsEmail(String faxNo) {
        String formattedFax = faxNo;
        if (String.isNotBlank(formattedFax)) {
            formattedFax = formattedFax.replace('(', '').replace(')', '');
            formattedFax = formattedFax.replaceAll('-', '');
            formattedFax = formattedFax.replaceAll(' ', '');
            Application_Config_Settings__c acs = [SELECT Domain_Name__c FROM Application_Config_Settings__c];
            formattedFax = formattedFax + acs.Domain_Name__c;
        }
        return formattedFax;
    }

    // Wrapper class used to frame attachments with checkboxes
    public class InsolvAttachments {
        public Boolean selected { get; set; }
        public String attId { get; set; }
        public String filename { get; set; }
        public String fileDesc { get; set; }
        public DateTime fileCreatedDate { get; set; }
        public String displaySize { get; set; }
    }

    //Check if attachment selcted or not
    public boolean checkAttachment() {
        boolean error = true;
        Set<Id> conDocIds = new Set<Id>();
        List<ContentDocumentLink> listOfConDoc = new List<ContentDocumentLink>();
        System.debug('mySelectedAtt:: '+mySelectedAtt);
        if(mySelectedAtt.size() > 0){
            listOfConDoc = [select Id, ContentDocumentId from ContentDocumentLink where ContentDocumentId in :mySelectedAtt];
        }
        System.debug('listOfConDoc:: '+listOfConDoc);
        for(ContentDocumentLink conDocLink : listOfConDoc){
            if(conDocLink != null || conDocLink.ContentDocumentId != null){
                conDocIds.add(conDocLink.ContentDocumentId);
            }
        }
        for(ContentVersion conVer: [SELECT Id, Description from ContentVersion where ContentDocumentId in :conDocIds]){
            System.debug('conVer:: '+conVer);
            if (conVer.Description == 'PoC Document') {
                error = false;
                return error;
            }
        }
        list<Attachment> checkedAttchList = new List<Attachment>(
            [SELECT Name, Body, BodyLength, Description, createdDate FROM Attachment WHERE ParentId = :insolvAcc.Id AND Id IN :mySelectedAtt]
        );
        for (Attachment selectedAttach : checkedAttchList) {
            if (selectedAttach.Description == 'PoC Document') {
                error = false;
                return error;
            }
        }
        return error;
    }

    // Check the Attachment for Account Statement
    public boolean checkAttachmentForAccState() {
        Boolean trusteeCheckErrorForAttach = checkEligibleTrustee();
        boolean accountStateError = false;
        list<Attachment> checkedAttchList = new List<Attachment>(
            [SELECT Name, Body, BodyLength, Description, createdDate FROM Attachment WHERE ParentId = :insolvAcc.Id AND Id IN :mySelectedAtt]
        );
        List<ContentDocumentLink> listOfConDoc = new List<ContentDocumentLink>();
        if(mySelectedAtt.size() > 0){
            listOfConDoc = [select Id, ContentDocumentId from ContentDocumentLink where ContentDocumentId in :mySelectedAtt];
        }
        Set<Id> conDocIds = new Set<Id>();
        for(ContentDocumentLink conDocLink : listOfConDoc){
            if(conDocLink != null || conDocLink.ContentDocumentId != null){
                conDocIds.add(conDocLink.ContentDocumentId);
            }
        }
        for(ContentVersion conVer: [SELECT Id, Description from ContentVersion where ContentDocumentId in :conDocIds]){
            if (conVer.Description == 'Account Statement') {
                accountStateError = true;
                return accountStateError;
            }
        }
        for (Attachment selectedAttach : checkedAttchList) {
            if (selectedAttach.Description == 'Account Statement') {
                accountStateError = true;
                return accountStateError;
            }
        }
        if (insolvAcc.Client_Identifier__c == 'Canadian Tire') {
            for (Document_Storage__c docStorage : [SELECT Document_Type__c FROM Document_Storage__c WHERE Document_URL__c IN :mySelectedAtt]) {
                if (docStorage.Document_Type__c.containsIgnoreCase('statement')) {
                    accountStateError = true;
                    return accountStateError;
                }
            }
        }
        return accountStateError;
    }

    // Check the trustee
    public boolean checkEligibleTrustee() {
        List<String> trusteeCheckList = new List<String>();
        Boolean trusteeCheckError = false;
        //pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        String idWithAccountStatement = pocPackage.Account_Statement_Not_Allowed__c;
        trusteeCheckList = idWithAccountStatement.split(',');
        for (String trusteeCheck : trusteeCheckList) {
            if (insolvAcc.Insolvency__r.Trustee__r.ParentId == trusteeCheck) {
                trusteeCheckError = true;
                return trusteeCheckError;
            }
        }
        return trusteeCheckError;
    }

    //change the language
    public void changeLanguage() {
        if (language == 'fr') {
            loadFrenchEmailTemplates();
        } else {
            loadEmailTemplates();
        }
        emailTemplatechanged();
    }
}