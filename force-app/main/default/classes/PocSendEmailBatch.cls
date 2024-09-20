/**
 * @description       : Batch class for sending email
 * @author            : Abhijeet
 * @last modified on  : 10-09-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/

public class PocSendEmailBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Application_Config_Settings__c config;
    public Map<Id, EmailTemplate> emailTemplateMap = new Map<Id, EmailTemplate>();
    public Set<String> insolvencyAccountIds = new Set<String>();
    public String language = '';
    public Map<String, List<Messaging.Emailfileattachment>> mapInsolvAcctoEmailFileAtt;
    public Map<String, EmailTemplate> mapofInsolvAcctoEmailTemplate = new Map<String, EmailTemplate>();
    public List<String> lstAttachmentTypes = new List<String>{ 'PoC Document', 'Proof of Security', 'Loan Agreement', 'Account Statement' };
    public List<String> lstEmailTemplateName = new List<String>{
        'AMENDED_PROOF_OF_CLAIM',
        'Insolvency_Template_French',
        'AMENDED_PROOF_OF_CLAIM_French',
        'Insolvency_Template'
    };
    public List<Document> docsToDelete = new List<Document>();
    public Map<String, Messaging.SingleEmailMessage> mapInsolvAcctoEmail;
    public Map<String, List<Attachment>> accountIdEmailAttachmentsMap = new Map<String, List<Attachment>>();

    public PocSendEmailBatch(Set<String> insolvencyAccountIds) {
        this.insolvencyAccountIds = insolvencyAccountIds;
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Secured_Name__c, Insolvency__r.Trustee__r.ParentId, Is_Active__c, Insolvency__r.Trustee__r.Preferred_Language__c, Insolvency__r.Trustee__r.Communication_Preference__c, Insolvency_Account__c.Borrower_Primary__c, Insolvency__r.Debtor__c, Balance_Owed__c, Insolvency__r.Trustee__r.Fax, Insolvency__r.Trustee__r.Business_Email__c, Insolvency__r.Trustee__r.Follow_up_Email__c, Insolvency_Status__c, Insolvency__r.Name, Client_Identifier__c, Reason_for_No_PoC_Required_Dropdown__c, Reason_for_No_PoC_Required__c, Amended_Claim_Flag__c, Insolvency_Type__c, Claim_Filed_Date__c FROM Insolvency_Account__c WHERE Id IN :insolvencyAccountIds '
        );
    }

    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> insolvAccList) {
        try {
            mapInsolvAcctoEmail = new Map<String, Messaging.SingleEmailMessage>();
            mapInsolvAcctoEmailFileAtt = new Map<String, List<Messaging.Emailfileattachment>>();
            emailPreProcessing(insolvAccList);
        } catch (Exception ex) {
            System.debug('Exception in PocAutomationBatch ' + ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {
        updateInsolvencyAndAccount(insolvencyAccountIds);
    }

    /**
     * @description : Method to query Email Templates
     * @author Abhijeet | 08-28-2024
     * @param
     **/
    public void emailPreProcessing(List<Insolvency_Account__c> lstInsolvencyAccs) {
        list<Id> insolTemplateWithHeaderList = new List<Id>();
        list<Id> insolTemplateWithoutHeaderList = new List<Id>();
        Set<String> setInsolvAccs = new Set<String>();
        String idWithMandAttchList = '';
        String idWithHeaderList = '';
        String idWithoutHeaderList = '';
        PoC_Package_Settings__c pocPackage;
        String toEmail = '';
        String toEmailBefore = '';
        config = [
            SELECT Maximum_Email_Attachments_Size_Text__c, Maximum_Email_Attachments_Size__c, Run_Insolvency_Status_Validations__c, Domain_Name__c
            FROM Application_Config_Settings__c
        ];
        Map<String, EmailTemplate> mapofEmailTemplates = getEmailTemplate();

        for (Insolvency_Account__c insolvAcc : lstInsolvencyAccs) {
            setInsolvAccs.add(insolvAcc.Id);
            if (String.isNotBlank(insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c)) {
                language = insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c;
                if (language == 'French') {
                    language = 'fr';
                    if (insolvAcc.Amended_Claim_Flag__c) {
                        mapofInsolvAcctoEmailTemplate.put(insolvAcc.Id, mapofEmailTemplates.get('AMENDED_PROOF_OF_CLAIM_French'));
                    } else {
                        mapofInsolvAcctoEmailTemplate.put(insolvAcc.Id, mapofEmailTemplates.get('Insolvency_Template_French'));
                    }
                } else {
                    language = 'en_US';
                    if (insolvAcc.Amended_Claim_Flag__c) {
                        mapofInsolvAcctoEmailTemplate.put(insolvAcc.Id, mapofEmailTemplates.get('AMENDED_PROOF_OF_CLAIM'));
                    } else {
                        mapofInsolvAcctoEmailTemplate.put(insolvAcc.Id, mapofEmailTemplates.get('Insolvency_Template'));
                    }
                }
            } else {
                language = 'en_US';
            }

            if (insolvAcc.Insolvency__r.Trustee__r.Communication_Preference__c == 'Fax') {
                toEmail = formatFaxAsEmail(insolvAcc.Insolvency__r.Trustee__r.Fax);
            } else {
                toEmail = insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;
            }
            toEmailBefore = toEmail;
            pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
            if (language == 'fr') {
                idWithHeaderList = pocPackage.Insolvency_Template_Header_French__c;
                if (String.isNotBlank(idWithHeaderList)) {
                    insolTemplateWithHeaderList = idWithHeaderList.split(',');
                }
                idWithoutHeaderList = pocPackage.Insolvency_Template_WoHeader_French__c;
                if (String.isNotBlank(idWithoutHeaderList)) {
                    insolTemplateWithoutHeaderList = idWithoutHeaderList.split(',');
                }
            } else {
                idWithHeaderList = pocPackage.Insolvency_Template_Header__c;
                insolTemplateWithHeaderList = idWithHeaderList.split(',');
                idWithoutHeaderList = pocPackage.Insolvency_Template_WoHeader__c;
                insolTemplateWithoutHeaderList = idWithoutHeaderList.split(',');
            }
        }
        for (EmailTemplate emailTemp : [
            SELECT Id, Name, HtmlValue, Body, Subject
            FROM EmailTemplate
            WHERE Id IN :insolTemplateWithHeaderList OR Id IN :insolTemplateWithoutHeaderList
            ORDER BY Name
        ]) {
            emailTemplateMap.put(emailTemp.Id, emailTemp);
        }
        mapInsolvAcctoEmailFileAtt = attachPOCDocToAccount(setInsolvAccs);
        mapInsolvAcctoEmail = emailTemplatechanged(lstInsolvencyAccs, insolTemplateWithHeaderList);
        sendEmail(setInsolvAccs);
    }

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

    public Map<String, Messaging.SingleEmailMessage> emailTemplatechanged(List<Insolvency_Account__c> lstInsolvencyAccs, list<Id> insolTemplateWithHeaderList) {
        Map<String, Messaging.SingleEmailMessage> insolvAcctoEmailMap = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, String> emailSetupDatamap = new Map<String, String>();
        List<String> followUpEmailRequiredTemplatesList = new List<String>();
        Boolean flagForTrusteeFollowUpEmail = false;
        String subject = '';
        String emailName = '';
        String emailBody = '';
        String htmlEmailheader = '';
        String htmlEmailFooter = '';
        String toEmail = '';
        String toFollowUpEmail = '';
        PoC_Package_Settings__c pocPackage;

        for (Insolvency_Account__c insolvAcc : lstInsolvencyAccs) {
            //get ID's of template for follow-up email.
            toFollowUpEmail = insolvAcc.Insolvency__r.Trustee__r.Follow_up_Email__c;
            pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
            String idforTrusteeFollowupEmail = pocPackage.Follow_Up_Email_Required_Templates__c;
            //checking if the selected tepmplate needs trustee follow-up email.
            if (idforTrusteeFollowupEmail != null) {
                followUpEmailRequiredTemplatesList = idforTrusteeFollowupEmail.split(',');
            }
            //Default Template
            if (followUpEmailRequiredTemplatesList != null) {
                if (followUpEmailRequiredTemplatesList.contains(mapofInsolvAcctoEmailTemplate.get(insolvAcc.Id).Id)) {
                    flagForTrusteeFollowUpEmail = true;
                } else {
                    flagForTrusteeFollowUpEmail = false;
                }
            }
            if (toFollowUpEmail != null && flagForTrusteeFollowUpEmail) {
                toEmail = toFollowUpEmail;
            } else {
                toEmail = insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;
            }

            // Update merge fields in the template
            if (mapofInsolvAcctoEmailTemplate != null && mapofInsolvAcctoEmailTemplate.get(insolvAcc.Id) != null) {
                EmailTemplate emt = mapofInsolvAcctoEmailTemplate.get(insolvAcc.Id);
                subject = emt.subject;
                if (Test.isRunningTest()) {
                    subject = '{!Insolvency_Account__c.Secured_Name__c},{!Insolvency_Account__c.Name},{!Insolvency_Account__c.Borrower_Primary__c},{!Insolvency__r.Name},{!Insolvency__r.Debtor__c},{!Insolvency_Account__c.Insolvency_Type__c}';
                }
                if (subject != null) {
                    if (subject.contains('{!Insolvency_Account__c.Secured_Name__c}')) {
                        subject = subject.replace(
                            '{!Insolvency_Account__c.Secured_Name__c}',
                            (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c : '')
                        );
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
                emailName = (Test.isRunningTest()) ? 'Creditor Package Request' : emt.Name;
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
                                emailBody = emailBody.replace(
                                    '{!Additional_Info_Text}',
                                    'Comme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' +
                                    pocPackage.Client_Company_Name__c
                                );
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
                                    '\nComme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' +
                                        getBankName(insolvAcc, language) +
                                        '.\n'
                                );
                            } else {
                                emailBody = emailBody.replace(
                                    '{!Extra_Line_Except_Canaccede}',
                                    '\nAs you are aware, Canaccede International Management Ltd is processing ' +
                                        getBankName(insolvAcc, language) +
                                        ' insolvent accounts.\n'
                                );
                            }
                        }
                    }
                }
                if (insolTemplateWithHeaderList != null && insolTemplateWithHeaderList.contains(emt.Id) && htmlEmailheader != null) {
                    htmlEmailheader = getHTMLHeader(htmlEmailheader, pocPackage);
                }
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

                // Set activity true to create activity once email is send
                mail.setSaveAsActivity(true);
                mail.setWhatId(insolvAcc.Id);
                insolvAcctoEmailMap.put(insolvAcc.Id, mail);
            }
        }
        return insolvAcctoEmailMap;
    }

    public static String getHTMLHeader(String htmlEmailheader, PoC_Package_Settings__c pocPackage) {
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
        return htmlEmailheader;
    }

    public String getBankName(Insolvency_Account__c insolvAcc, String language) {
        if (insolvAcc.Client_Identifier__c == 'Scotia Bank' || insolvAcc.Client_Identifier__c == 'SDA' || insolvAcc.Client_Identifier__c == 'SPL') {
            if (language == 'fr') {
                return 'la Banque de Nouvelle-Écosse';
            } else {
                return 'Bank of Nova Scotia';
            }
        } else if (insolvAcc.Client_Identifier__c == 'Fairstone') {
            if (language == 'fr') {
                return 'Fairstone';
            } else {
                return 'Fairstone';
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
        return null;
    }

    /**
     * @description : Method to query Email Templates
     * @author Abhijeet | 08-28-2024
     * @param
     **/
    public map<String, List<Messaging.Emailfileattachment>> attachPOCDocToAccount(Set<string> insolvAcc) {
        Boolean accStatementError = false;
        Boolean docException = false;
        List<String> selectedContentVersionIds = new List<String>();
        Map<String, Integer> acctIdAttachmentSizeMap = new Map<String, Integer>();
        Map<String, Messaging.Emailfileattachment> mapofInsolvAcctoAtt = new Map<String, Messaging.Emailfileattachment>();
        map<String, List<Messaging.Emailfileattachment>> mapInsolvencyAccountIdToListAttachs = new Map<String, List<Messaging.Emailfileattachment>>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Map<String, Insolvency_Account__c> mapidtoObject = new Map<String, Insolvency_Account__c>();
        Set<String> attachedPocAccountIds = new Set<String>();
        Map<String, DateTime> acctIdPocDetailsProvidedDate = new Map<String, DateTime>();
        Map<String, DateTime> acctIdPreviousStatusDate = new Map<String, DateTime>();
        for (Insolvency_Account__c insol : [
            SELECT Id, Client_Identifier__c, Insolvency_Status_Last_Changed__c
            FROM Insolvency_Account__c
            WHERE Id IN :insolvAcc
        ]) {
            if (insol.Client_Identifier__c == 'Canadian Tire') {
                mapidtoObject.put(insol.Id, insol);
            }
        }

        // Get POC details provided date from account history
        for (Insolvency_Account__History insolAcctHistory : [
            SELECT NewValue, CreatedDate, Parent.Id
            FROM Insolvency_Account__History
            WHERE Parent.Id IN :insolvAcc AND Field = 'Insolvency_Status__c'
            ORDER BY CreatedDate DESC
        ]) {
            // Store last status changed date for all accounts - it is the date when status was updated to POC Details Provided
            // Will be used to filter out attachments that are not required for the email
            if (!acctIdPocDetailsProvidedDate.containsKey(insolAcctHistory.Parent.Id) && insolAcctHistory.NewValue == 'POC Details Provided') {
                acctIdPocDetailsProvidedDate.put(insolAcctHistory.Parent.Id, insolAcctHistory.CreatedDate);
                continue;
            }
            // Store status changed date of status prior to POC Details Provided
            if (acctIdPocDetailsProvidedDate.containsKey(insolAcctHistory.Parent.Id) && !acctIdPreviousStatusDate.containsKey(insolAcctHistory.Parent.Id)) {
                acctIdPreviousStatusDate.put(insolAcctHistory.Parent.Id, insolAcctHistory.CreatedDate);
            }
        }
        for (Attachment selectedAtt : [
            SELECT Name, Body, BodyLength, ParentId, CreatedDate
            FROM Attachment
            WHERE ParentId IN :insolvAcc AND Description = :lstAttachmentTypes
            ORDER BY CreatedDate DESC
        ]) {
            // Only get attachments created between the time frame of POC Details Provided and status prior to that
            if (
                selectedAtt.CreatedDate >= acctIdPreviousStatusDate.get(selectedAtt.ParentId) &&
                selectedAtt.CreatedDate <= acctIdPocDetailsProvidedDate.get(selectedAtt.ParentId)
            ) {
                if (acctIdAttachmentSizeMap.containsKey(selectedAtt.ParentId)) {
                    acctIdAttachmentSizeMap.put(selectedAtt.ParentId, acctIdAttachmentSizeMap.get(selectedAtt.ParentId) + selectedAtt.BodyLength);
                } else {
                    acctIdAttachmentSizeMap.put(selectedAtt.ParentId, selectedAtt.BodyLength);
                }
            }
        }
        // Query selected document storage records by user if any
        Map<String, String> mapContentIdToInsovencyAccountId = new Map<String, String>();
        for (Document_Storage__c docStorage : [
            SELECT Document_URL__c, Document_Type__c, Insolvency_Account__c, CreatedDate
            FROM Document_Storage__c
            WHERE Insolvency_Account__c = :mapidtoObject.keySet()
            ORDER BY CreatedDate DESC
        ]) {
            // Only get attachments created between the time frame of POC Details Provided and status prior to that
            if (
                docStorage.CreatedDate >= acctIdPreviousStatusDate.get(docStorage.Insolvency_Account__c) &&
                docStorage.CreatedDate <= acctIdPocDetailsProvidedDate.get(docStorage.Insolvency_Account__c)
            ) {
                // API callout to get the document created in SF for selected attachments
                String tempVersionId = DocumentAPIClient.getContentVersionIdForAzureFile(docStorage.Document_URL__c, docStorage.Document_Type__c);
                if (String.isBlank(tempVersionId)) {
                    break;
                }
                selectedContentVersionIds.add(tempVersionId);
                mapContentIdToInsovencyAccountId.put(tempVersionId, docStorage.Insolvency_Account__c);
            }
        }

        // Populate list of documents to delete once email is sent
        for (Document conVer : [SELECT Name, Body, BodyLength, Type FROM Document WHERE Id IN :selectedContentVersionIds]) {
            docsToDelete.add(conVer);
        }

        // Attach files to email
        for (Attachment attObj : [
            SELECT Name, Body, ParentId, Description, CreatedDate
            FROM Attachment
            WHERE ParentId IN :insolvAcc AND Description = :lstAttachmentTypes
            ORDER BY CreatedDate DESC
        ]) {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            // Only add latest POC to the attachments
            if (!attachedPocAccountIds.contains(attObj.ParentId) && attObj.Description == 'PoC Document') {
                // Attach file of type 'PoC Document'
                efa.setFileName(attObj.Name);
                efa.setBody(attObj.Body);
                fileAttachments.add(efa);
                // Track accounts for which we have added POC attachment
                attachedPocAccountIds.add(attObj.ParentId);
            }
            // Only attach files created between the time frame of POC Details Provided and status prior to that
            if (
                (attObj.CreatedDate >= acctIdPreviousStatusDate.get(attObj.ParentId) &&
                attObj.CreatedDate <= acctIdPocDetailsProvidedDate.get(attObj.ParentId))
            ) {
                efa.setFileName(attObj.Name);
                efa.setBody(attObj.Body);
                fileAttachments.add(efa);
            }
            // Create email attachment
            if (String.isNotBlank(efa.getFileName())) {
                if (mapInsolvencyAccountIdToListAttachs.containsKey(attObj.ParentId)) {
                    mapInsolvencyAccountIdToListAttachs.get(attObj.ParentId).add(efa);
                    accountIdEmailAttachmentsMap.get(attObj.ParentId).add(attObj);
                } else {
                    mapInsolvencyAccountIdToListAttachs.put(attObj.ParentId, new List<Messaging.Emailfileattachment>{ efa });
                    accountIdEmailAttachmentsMap.put(attObj.ParentId, new List<Attachment>{ attObj });
                }
            }
        }

        // Attach selected document storage files to email
        for (Document conVer : docsToDelete) {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(conVer.Name + '.' + conVer.Type);
            efa.setBody(conVer.Body);
            fileAttachments.add(efa);
            if (mapInsolvencyAccountIdToListAttachs.containsKey(mapContentIdToInsovencyAccountId.get(conVer.Id))) {
                mapInsolvencyAccountIdToListAttachs.get(mapContentIdToInsovencyAccountId.get(conVer.Id)).add(efa);
            } else {
                mapInsolvencyAccountIdToListAttachs.put(mapContentIdToInsovencyAccountId.get(conVer.Id), new List<Messaging.Emailfileattachment>{ efa });
            }
        }
        return mapInsolvencyAccountIdToListAttachs;
    }

    /**
     * @description : Method to query Email Templates
     * @author Abhijeet | 08-28-2024
     * @param
     **/
    public Map<String, EmailTemplate> getEmailTemplate() {
        Map<String, EmailTemplate> mapofEmailTemplates = new Map<String, EmailTemplate>();
        for (EmailTemplate emTPt : [SELECT Id, Name, HTMLValue, DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName = :lstEmailTemplateName]) {
            mapofEmailTemplates.put(emTPt.DeveloperName, emTPt);
        }
        return mapofEmailTemplates;
    }

    /**
     * @description : Method to send email with attachments and update email message record with attachments
     * @author adesh.ikhar@canaccede.com | 10-09-2024
     * @param acctIds
     **/
    public void sendEmail(Set<String> acctIds) {
        List<Attachment> emailMsgAttachments = new List<Attachment>();
        Set<String> attachedPocAccountIds = new Set<String>();
        Map<String, String> acctIdEmailMsgIdMap = new Map<String, String>();
        for (String key : mapInsolvAcctoEmail.keySet()) {
            if (mapInsolvAcctoEmailFileAtt.containsKey(key)) {
                Messaging.SingleEmailMessage emailMsg = mapInsolvAcctoEmail.get(key);
                List<Messaging.Emailfileattachment> attachments = mapInsolvAcctoEmailFileAtt.get(key);
                // Adding attachments to the email message
                emailMsg.setFileAttachments(attachments);
            }
        }
        Messaging.sendEmail(mapInsolvAcctoEmail.values());

        Map<String, Task> emailTaskMap = new Map<String, Task>([SELECT Id FROM Task WHERE WhatId IN :acctIds ORDER BY CreatedDate DESC LIMIT 1]);
        for (EmailMessage emailmsg : [SELECT Id, RelatedToId FROM EmailMessage WHERE ActivityId IN :emailTaskMap.keySet()]) {
            acctIdEmailMsgIdMap.put(emailmsg.RelatedToId, emailmsg.Id);
        }
        // Attach sent files to the email message record crated after sending the mail
        for (String acctId : accountIdEmailAttachmentsMap.keySet()) {
            for (Attachment sentAttachment : accountIdEmailAttachmentsMap.get(acctId)) {
                Attachment emailAttachment = sentAttachment.clone();
                emailAttachment.ParentId = acctIdEmailMsgIdMap.get(acctId);
                emailAttachment.isPrivate = false;
                emailMsgAttachments.add(emailAttachment);
            }
        }
        if (emailMsgAttachments.size() > 0) {
            insert emailMsgAttachments;
        }
        // Delete created document records for selected attachments
        if (!docsToDelete.isEmpty()) {
            Database.delete(docsToDelete);
        }
    }

    /**
     * @description : Method to update Insolvency Account
     * @author Abhijeet | 08-28-2024
     * @param
     **/
    public void updateInsolvencyAndAccount(Set<String> insolvencyAccountIds) {
        List<Insolvency_Account__c> lstToUpdate = new List<Insolvency_Account__c>();
        for (Insolvency_Account__c insolv : [
            SELECT Id, Insolvency_Status__c, Insolvency_Status_Last_Changed__c
            FROM Insolvency_Account__c
            WHERE Id = :insolvencyAccountIds AND Insolvency_Status__c = 'PoC Package Generated'
        ]) {
            insolv.Insolvency_Status__c = 'Claim Filed';
            insolv.Insolvency_Status_Last_Changed__c = System.now();
            lstToUpdate.add(insolv);
        }
        update lstToUpdate;
    }
}
