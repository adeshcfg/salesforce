/**
 * @description       : Batch class for sending email
 * @author            : Abhijeet
 * @last modified on  : 12-18-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/

public class PocSendEmailBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Set<String> insolvencyAccountIds = new Set<String>();
    public String language = '';
    public List<String> selectedContentVersionIds = new List<String>();
    Map<Id, List<Id>> mapOfInsAcntIdAndListOfConDocId = new Map<Id, List<Id>>();

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
            emailPreProcessing(insolvAccList);
        } catch (Exception ex) {
            System.debug('Exception in PocAutomationBatch ' + ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        updateInsolvencyAndAccount(insolvencyAccountIds);
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
    }

    /**
     * @description : Method to query Email Templates
     * @author Abhijeet | 08-28-2024
     * @param
     **/
    public void emailPreProcessing(List<Insolvency_Account__c> lstInsolvencyAccs) {
        Map<String, List<Messaging.Emailfileattachment>> mapInsolvAcctoEmailFileAtt = new Map<String, List<Messaging.Emailfileattachment>>();
        Map<String, List<Messaging.Emailfileattachment>> mapInsolvAcctoEmailFileConVer = new Map<String, List<Messaging.Emailfileattachment>>();
        Map<String, Messaging.SingleEmailMessage> mapInsolvAcctoEmail = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> mapofInsolvAcctoEmailTemplate = new Map<String, EmailTemplate>();
        list<Id> insolTemplateWithHeaderList = new List<Id>();
        list<Id> insolTemplateWithoutHeaderList = new List<Id>();
        Set<String> setInsolvAccs = new Set<String>();
        String idWithMandAttchList = '';
        String idWithHeaderList = '';
        String idWithoutHeaderList = '';
        PoC_Package_Settings__c pocPackage;
        String toEmail = '';
        String toEmailBefore = '';
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
                if (insolvAcc.Amended_Claim_Flag__c) {
                    mapofInsolvAcctoEmailTemplate.put(insolvAcc.Id, mapofEmailTemplates.get('AMENDED_PROOF_OF_CLAIM'));
                } else {
                    mapofInsolvAcctoEmailTemplate.put(insolvAcc.Id, mapofEmailTemplates.get('Insolvency_Template'));
                }
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
        mapInsolvAcctoEmailFileAtt = attachPOCDocToAccount(setInsolvAccs);
        mapInsolvAcctoEmailFileConVer = attachConVerToEmail(setInsolvAccs);
        mapInsolvAcctoEmail = emailTemplatechanged(lstInsolvencyAccs, insolTemplateWithHeaderList, mapofInsolvAcctoEmailTemplate);
        sendEmail(setInsolvAccs, mapInsolvAcctoEmailFileAtt, mapInsolvAcctoEmailFileConVer, mapInsolvAcctoEmail);
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

    public Map<String, Messaging.SingleEmailMessage> emailTemplatechanged(
        List<Insolvency_Account__c> lstInsolvencyAccs,
        list<Id> insolTemplateWithHeaderList,
        Map<String, EmailTemplate> mapofInsolvAcctoEmailTemplate
    ) {
        Map<String, Messaging.SingleEmailMessage> insolvAcctoEmailMap = new Map<String, Messaging.SingleEmailMessage>();
        String subject = '';
        String emailName = '';
        String emailBody = '';
        String htmlEmailheader = '';
        String htmlEmailFooter = '';
        String toEmail = '';
        PoC_Package_Settings__c pocPackage;

        for (Insolvency_Account__c insolvAcc : lstInsolvencyAccs) {
            pocPackage = (PoC_Package_Settings__c) PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
            toEmail = insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;

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
        List<String> lstAttachmentTypes = new List<String>{ 'PoC Document', 'Proof of Security', 'Loan Agreement', 'Account Statement' };
        List<Document> docsToDelete = new List<Document>();
        Boolean accStatementError = false;
        Boolean docException = false;
        Map<String, Integer> acctIdAttachmentSizeMap = new Map<String, Integer>();
        Map<String, Messaging.Emailfileattachment> mapofInsolvAcctoAtt = new Map<String, Messaging.Emailfileattachment>();
        map<String, List<Messaging.Emailfileattachment>> mapInsolvencyAccountIdToListAttachs = new Map<String, List<Messaging.Emailfileattachment>>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Map<String, Insolvency_Account__c> mapidtoObject = new Map<String, Insolvency_Account__c>();
        Set<String> attachedPocAccountIds = new Set<String>();
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

        // Get For owner review date from account history
        for (Insolvency_Account__History insolAcctHistory : [
            SELECT NewValue, CreatedDate, Parent.Id
            FROM Insolvency_Account__History
            WHERE Parent.Id IN :insolvAcc AND Field = 'Insolvency_Status__c'
            ORDER BY CreatedDate DESC
        ]) {
            // Store For owner review status changed date
            // Will be used to filter out attachments that are not required for the email
            if (!acctIdPreviousStatusDate.containsKey(insolAcctHistory.Parent.Id) && insolAcctHistory.NewValue == 'For Owner Review') {
                acctIdPreviousStatusDate.put(insolAcctHistory.Parent.Id, insolAcctHistory.CreatedDate);
                continue;
            }
        }
        // To do : Add attachment size check
        /* for (Attachment selectedAtt : [
            SELECT Name, Body, BodyLength, ParentId, CreatedDate
            FROM Attachment
            WHERE ParentId IN :insolvAcc AND Description = :lstAttachmentTypes
            ORDER BY CreatedDate DESC
        ]) {
            // Only get attachments created after For owner review status
            if (selectedAtt.CreatedDate >= acctIdPreviousStatusDate.get(selectedAtt.ParentId)) {
                if (acctIdAttachmentSizeMap.containsKey(selectedAtt.ParentId)) {
                    acctIdAttachmentSizeMap.put(selectedAtt.ParentId, acctIdAttachmentSizeMap.get(selectedAtt.ParentId) + selectedAtt.BodyLength);
                } else {
                    acctIdAttachmentSizeMap.put(selectedAtt.ParentId, selectedAtt.BodyLength);
                }
            }
        } */
        // Query selected document storage records by user if any
        Map<String, String> mapContentIdToInsovencyAccountId = new Map<String, String>();
        for (Document_Storage__c docStorage : [
            SELECT Document_URL__c, Document_Type__c, Insolvency_Account__c, CreatedDate
            FROM Document_Storage__c
            WHERE Insolvency_Account__c = :mapidtoObject.keySet()
            ORDER BY CreatedDate DESC
        ]) {
            // Only get attachments created after For owner review status
            if (docStorage.CreatedDate >= acctIdPreviousStatusDate.get(docStorage.Insolvency_Account__c)) {
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
            // Only attach files created after For owner review status
            if (attObj.Description != 'PoC Document' && (attObj.CreatedDate >= acctIdPreviousStatusDate.get(attObj.ParentId))) {
                efa.setFileName(attObj.Name);
                efa.setBody(attObj.Body);
                fileAttachments.add(efa);
            }
            // Create email attachment
            if (String.isNotBlank(efa.getFileName())) {
                if (mapInsolvencyAccountIdToListAttachs.containsKey(attObj.ParentId)) {
                    mapInsolvencyAccountIdToListAttachs.get(attObj.ParentId).add(efa);
                } else {
                    mapInsolvencyAccountIdToListAttachs.put(attObj.ParentId, new List<Messaging.Emailfileattachment>{ efa });
                }
            }
        }

        // Attach ContentDocuments to email
        Map<Id,Id> mapOfConDocIdAndLinkEntityId = new Map<Id,Id>();

        for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityid IN :insolvAcc]){
            mapOfConDocIdAndLinkEntityId.put(conDocLink.ContentDocumentId,conDocLink.LinkedEntityId);
        }
        List<ContentVersion> conVerList = [SELECT Title, VersionData, ContentDocumentId, CreatedDate, Description FROM ContentVersion WHERE Id IN :mapOfConDocIdAndLinkEntityId.keySet() 
        AND Description = :lstAttachmentTypes
        ORDER BY CreatedDate DESC];
        for (ContentVersion conVerObj : conVerList) {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
             // Only add latest POC to the attachments
            if (!attachedPocAccountIds.contains(mapOfConDocIdAndLinkEntityId.get(conVerObj.ContentDocumentId)) && conVerObj.Description == 'PoC Document') {
                efa.setFileName(conVerObj.Title);
                efa.setBody(conVerObj.VersionData);
                fileAttachments.add(efa);
                // Track accounts for which we have added POC attachment
                attachedPocAccountIds.add(mapOfConDocIdAndLinkEntityId.get(conVerObj.ContentDocumentId));
            }
            // Only attach files created after For owner review status
            if (conVerObj.Description != 'PoC Document' && (conVerObj.CreatedDate >= acctIdPreviousStatusDate.get(mapOfConDocIdAndLinkEntityId.get(conVerObj.ContentDocumentId)))) {
                efa.setFileName(conVerObj.Title);
                efa.setBody(conVerObj.VersionData);
                fileAttachments.add(efa);
            }
            // Create email attachment
            if (String.isNotBlank(efa.getFileName())) {
                if (mapInsolvencyAccountIdToListAttachs.containsKey(mapOfConDocIdAndLinkEntityId.get(conVerObj.ContentDocumentId))) {
                    mapInsolvencyAccountIdToListAttachs.get(mapOfConDocIdAndLinkEntityId.get(conVerObj.ContentDocumentId)).add(efa);
                } else {
                    mapInsolvencyAccountIdToListAttachs.put(mapOfConDocIdAndLinkEntityId.get(conVerObj.ContentDocumentId), new List<Messaging.Emailfileattachment>{ efa });
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
     * @description : Method to attach Content Version files to Email
     * @author Abhijeet | 01-02-2025
     * @param
     **/
    public map<String, List<Messaging.Emailfileattachment>> attachConVerToEmail(Set<string> insolvAcc) {
        Map<String, List<Messaging.Emailfileattachment>> mapInsolvencyAccountIdToListConVer = new Map<String, List<Messaging.Emailfileattachment>>();
        List<Messaging.Emailfileattachment> emailAttachments = new List<Messaging.Emailfileattachment>();
        Map<Id, List<ContentDocumentLink>> mapOfConDocIdAndEntityIds = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, ContentVersion> mapOfConDocIdAndConVersion = new Map<Id, ContentVersion>();
        
        List<Id> listOfCondIds = new List<Id>();
        Set<Id> setOfConDocIds = new Set<Id>();
        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
        for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId, LinkedEntityid from ContentDocumentLink where LinkedEntityid in: insolvAcc]){
            if(mapOfConDocIdAndEntityIds.get(conDocLink.LinkedEntityid) != null){
                setOfConDocIds.add(conDocLink.ContentDocumentId);
                conDocLinkList = mapOfConDocIdAndEntityIds.get(conDocLink.LinkedEntityid);
                conDocLinkList.add(conDocLink);
            }else{
                setOfConDocIds.add(conDocLink.ContentDocumentId);
                List<ContentDocumentLink> tempConDocLinkList = new List<ContentDocumentLink>();
                tempConDocLinkList.add(conDocLink);
                mapOfConDocIdAndEntityIds.put(conDocLink.LinkedEntityid, tempConDocLinkList);
            }  
            if(mapOfInsAcntIdAndListOfConDocId.get(conDocLink.LinkedEntityid) != null){
                listOfCondIds = mapOfInsAcntIdAndListOfConDocId.get(conDocLink.LinkedEntityid);
                listOfCondIds.add(conDocLink.ContentDocumentId);
            }else{
                List<Id> tempConDocIdsList = new List<Id>();
                tempConDocIdsList.add(conDocLink.ContentDocumentId);
                mapOfInsAcntIdAndListOfConDocId.put(conDocLink.LinkedEntityid, tempConDocIdsList);
            }    
        }
        for(ContentVersion conVer : [SELECT id, 
                                          ContentDocumentId, 
                                          Title, 
                                          VersionData, 
                                          Description, 
                                          ContentSize, 
                                          CreatedBy.Name, 
                                          LastModifiedDate, 
                                          CreatedDate 
                                          FROM ContentVersion 
                                          WHERE contentDocumentId in : setOfConDocIds ORDER BY CreatedDate DESC]){
        	mapOfConDocIdAndConVersion.put(conVer.ContentDocumentId, conVer);
        }
        
        if(mapOfConDocIdAndEntityIds.size() > 0){   
            for(Id insolvAccId : mapOfConDocIdAndEntityIds.keyset()){
                List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
                contentDocLinkList = mapOfConDocIdAndEntityIds.get(insolvAccId);
                for(ContentDocumentLink conDocLink : contentDocLinkList){
                    ContentVersion conVer = mapOfConDocIdAndConVersion.get(conDocLink.ContentDocumentId);
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(conVer.Title);
                    efa.setBody(conVer.VersionData);
                    emailAttachments.add(efa);
                    mapInsolvencyAccountIdToListConVer.put(conDocLink.LinkedEntityid, emailAttachments);
                }
            }
        }
        return mapInsolvencyAccountIdToListConVer;
    }
    
    /**
     * @description : Method to query Email Templates
     * @author Abhijeet | 08-28-2024
     * @param
     **/
    public Map<String, EmailTemplate> getEmailTemplate() {
        List<String> lstEmailTemplateName = new List<String>{
            'AMENDED_PROOF_OF_CLAIM',
            'Insolvency_Template_French',
            'AMENDED_PROOF_OF_CLAIM_French',
            'Insolvency_Template'
        };
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
    public void sendEmail(
        Set<String> acctIds,
        Map<String, List<Messaging.Emailfileattachment>> mapInsolvAcctoEmailFileAtt,
        Map<String, List<Messaging.Emailfileattachment>> mapInsolvAcctoEmailFileConVer,
        Map<String, Messaging.SingleEmailMessage> mapInsolvAcctoEmail
    ) {
        Map<String, List<Attachment>> accountIdEmailAttachmentsMap = new Map<String, List<Attachment>>();
        List<Document> docsToDelete = new List<Document>();
        List<Attachment> emailMsgAttachments = new List<Attachment>();
        Set<String> attachedPocAccountIds = new Set<String>();
        Map<String, String> acctIdEmailMsgIdMap = new Map<String, String>();
        List<ContentDocumentLink> conDocLinks = new List<ContentDocumentLink>();
        for (String key : mapInsolvAcctoEmail.keySet()) {
            List<Messaging.Emailfileattachment> attachments = mapInsolvAcctoEmailFileAtt.get(key);
            Messaging.SingleEmailMessage emailMsg = mapInsolvAcctoEmail.get(key);
            if (mapInsolvAcctoEmailFileAtt.containsKey(key)) {
                // Add Attachment to Email Message record
                for (Messaging.Emailfileattachment emailAttachment : attachments) {
                    Attachment emailAttachmentToCreate = new Attachment(
                        Body = emailAttachment.getBody(),
                        Name = emailAttachment.getFileName(),
                        isPrivate = false
                    );
                    emailMsgAttachments.add(emailAttachmentToCreate);
                }
                accountIdEmailAttachmentsMap.put(key, emailMsgAttachments);
            }
            if (mapInsolvAcctoEmailFileConVer.containsKey(key)) {
                if(attachments != null){
                    attachments.addAll(mapInsolvAcctoEmailFileConVer.get(key));
                }else{
                    attachments = mapInsolvAcctoEmailFileConVer.get(key);
                }
                
            }
                // Adding attachments to the email message
                emailMsg.setFileAttachments(attachments);
            }
        Messaging.sendEmail(mapInsolvAcctoEmail.values());

        Map<String, Task> emailTaskMap = new Map<String, Task>(
            [SELECT Id FROM Task WHERE WhatId IN :acctIds AND TaskSubtype = 'Email' ORDER BY CreatedDate DESC]
        );
        for (EmailMessage emailmsg : [SELECT Id, RelatedToId FROM EmailMessage WHERE ActivityId IN :emailTaskMap.keySet() ORDER BY CreatedDate DESC]) {
            // Only store latest email message Id for each account
            if (!acctIdEmailMsgIdMap.containsKey(emailmsg.RelatedToId)) {
                acctIdEmailMsgIdMap.put(emailmsg.RelatedToId, emailmsg.Id);
            }
            for(Id InsolAccId : mapOfInsAcntIdAndListOfConDocId.keyset()){
                if(emailmsg.RelatedToId == InsolAccId){
                    List<Id> listOfConDocIds = mapOfInsAcntIdAndListOfConDocId.get(InsolAccId);
                    for(Id conDocId : listOfConDocIds){
                        // Associate the ContentDocument with an EmailMessage
                        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                        contentDocumentLink.ContentDocumentId = conDocId;
                        contentDocumentLink.LinkedEntityId = emailmsg.id; // ID of the EmailMessage record
                        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
                        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
                        conDocLinks.add(contentDocumentLink);
                    }
                }
            }
        }
        // Attach sent files to the email message record created after sending the mail
        for (String acctId : accountIdEmailAttachmentsMap.keySet()) {
            for (Attachment sentAttachment : accountIdEmailAttachmentsMap.get(acctId)) {
                sentAttachment.ParentId = acctIdEmailMsgIdMap.get(acctId);
            }
        }
        if (emailMsgAttachments.size() > 0) {
            insert emailMsgAttachments;
        }

        // Populate list of documents to delete once email is sent
        for (Document conVer : [SELECT Id FROM Document WHERE Id IN :selectedContentVersionIds]) {
            docsToDelete.add(conVer);
        }
        // Delete created document records for selected attachments
        if (!docsToDelete.isEmpty()) {
            Database.delete(docsToDelete);
        }
        
        if(conDocLinks.size() > 0){
            insert conDocLinks;
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