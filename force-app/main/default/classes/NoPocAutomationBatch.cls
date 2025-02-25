/**
 * @description       : Batch to automate additional information/Trustee follow up
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-25-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class NoPocAutomationBatch implements Schedulable, Database.Batchable<SObject> {
    public Map<String, String> clientIdentifierTemplateNameMap = new Map<String, String>{
        'Fidem' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
        'Goeasy' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
        'Fairstone' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
        'Money Mart' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
        'Canadian Tire' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
        'Canaccede' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
        'Scotia Bank' => 'ADDITIONAL_INFORMATION_REQUIRE',
        'SPL' => 'ADDITIONAL_INFORMATION_REQUIRE',
        'SDA' => 'ADDITIONAL_INFORMATION_REQUIRE',
        'Goeasy_French' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE_French',
        'Fairstone_French' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE_French',
        'Money Mart_French' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE_French',
        'Canaccede_French' => 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE_French',
        'Scotia Bank_French' => 'ADDITIONAL_INFORMATION_REQUIRE_French',
        'SPL_French' => 'ADDITIONAL_INFORMATION_REQUIRE_French',
        'SDA_French' => 'ADDITIONAL_INFORMATION_REQUIRE_French',
        'Canadian Tire_French' => 'ADDITIONAL_INFORMATION_REQUIRE_CANADIAN_TIRE_French'
    };
    public Database.Querylocator start(Database.BatchableContext bc) {
        List<String> eligibleStatuses = System.Label.Additional_Info_Required_Statuses.split(',');
        List<String> eligibleReasons = System.Label.Additional_Info_Required_Reasons.split(',');
        return Database.getQueryLocator(
            'SELECT Id, Insolvency__r.Trustee__r.Preferred_Language__c, Insolvency__r.Trustee__r.Business_Email__c, Client_Identifier__c, Secured_Name__c, Name, Insolvency__r.Name From Insolvency_Account__c WHERE Insolvency_Status__c IN :eligibleStatuses AND Reason_for_No_PoC_Required_Dropdown__c IN :eligibleReasons'
        );
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new NoPocAutomationBatch(), 10);
    }

    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> insolvAccList) {
        Savepoint sp = Database.setSavepoint();
        try {
            startProcessing(insolvAccList);
            updateAccountStatus(insolvAccList);
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Exception in PocAutomationBatch ' + ex.getStackTraceString());
            insert PocDocUtility.handleException(ex, insolvAccList[0].Id);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    /**
     * @description : Method to update account status to 'Trustee Followup'
     * @author adesh.ikhar@canaccede.com | 02-24-2025
     * @param insolvAccList
     **/
    public void updateAccountStatus(List<Insolvency_Account__c> insolvAccList) {
        for (Insolvency_Account__c insolvAcc : insolvAccList) {
            insolvAcc.Insolvency_Status__c = 'Trustee Followup';
        }
        Database.update(insolvAccList);
    }

    /**
     * @description : Process accounts to send email
     * @author adesh.ikhar@canaccede.com | 02-24-2025
     * @param insolvAccList
     **/
    public void startProcessing(List<Insolvency_Account__c> insolvAccList) {
        List<Messaging.SingleEmailMessage> singleEmailMessages = new List<Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> templateMap = new Map<String, EmailTemplate>();
        Map<String, PoC_Package_Settings__c> clientIdentifierPocPackageMap = new Map<String, PoC_Package_Settings__c>();
        Set<String> templateDevNameSet = new Set<String>(clientIdentifierTemplateNameMap.values());
        for (EmailTemplate template : [
            SELECT DeveloperName, Subject, Body
            FROM EmailTemplate
            WHERE DeveloperName IN :templateDevNameSet
        ]) {
            templateMap.put(template.DeveloperName, template);
        }
        for (PoC_Package_Settings__c pocSettings : PoC_Package_Settings__c.getall().values()) {
            clientIdentifierPocPackageMap.put(pocSettings.Name, pocSettings);
        }
        for (Insolvency_Account__c insolvAcc : insolvAccList) {
            String language = String.isBlank(insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c)
                ? 'English'
                : insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c;
            String templateName = language == 'English' ? insolvAcc.Client_Identifier__c : insolvAcc.Client_Identifier__c + '_French';
            EmailTemplate template = clientIdentifierTemplateNameMap.containsKey(templateName)
                ? templateMap.get(clientIdentifierTemplateNameMap.get(templateName))
                : templateMap.get('ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE');
            PoC_Package_Settings__c pocPackageSettings = clientIdentifierPocPackageMap.get(insolvAcc.Client_Identifier__c);
            // Generate email message record
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ insolvAcc.Insolvency__r.Trustee__r.Business_Email__c });
            mail.setSubject(updateSubject(template.subject, insolvAcc));
            mail.setHTMLBody(updateBody(template.Body, pocPackageSettings, insolvAcc, language));
            // Set activity true to create activity once email is send
            mail.setSaveAsActivity(true);
            mail.setWhatId(insolvAcc.Id);
            mail.setOrgWideEmailAddressId(pocPackageSettings.Trustee_Email_Org_Wide_Address_Id__c);
            singleEmailMessages.add(mail);
        }
        // Send emails
        if (!singleEmailMessages.isEmpty()) {
            Messaging.sendEmail(singleEmailMessages);
        }
    }

    /**
     * @description : Method to update subject using merge fields
     * @author adesh.ikhar@canaccede.com | 02-24-2025
     * @param subject
     * @param insolvAcc
     **/
    public String updateSubject(String subject, Insolvency_Account__c insolvAcc) {
        if (subject.contains('{!Insolvency_Account__c.Secured_Name__c}')) {
            subject = subject.replace('{!Insolvency_Account__c.Secured_Name__c}', (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c : ''));
        }
        if (subject.contains('{!Insolvency_Account__c.Name}')) {
            subject = subject.replace('{!Insolvency_Account__c.Name}', (insolvAcc.Name != null ? insolvAcc.Name : ''));
        }
        if (subject.contains('{!Insolvency__r.Name}')) {
            subject = subject.replace('{!Insolvency__r.Name}', insolvAcc.Insolvency__r.Name);
        }
        return subject;
    }

    /**
     * @description : Method to update email body using merge fields
     * @author adesh.ikhar@canaccede.com | 02-24-2025
     * @param emailBody
     * @param pocPackage
     * @param insolvAcc
     * @param language
     **/
    public String updateBody(String emailBody, PoC_Package_Settings__c pocPackage, Insolvency_Account__c insolvAcc, String language) {
        if (emailBody.contains('{!Insolvency_Account__c.Secured_Name__c}')) {
            emailBody = emailBody.replace('{!Insolvency_Account__c.Secured_Name__c}', (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c : ''));
        }
        if (emailBody.contains('{!Insolvency__r.Name}')) {
            emailBody = emailBody.replace('{!Insolvency__r.Name}', insolvAcc.Insolvency__r.Name);
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
            if (language == 'French') {
                numberVal = numberVal.replace('-', '.');
            }
            emailBody = emailBody.replace('{!pocPackage.CFG_Office_Fax_Number__c}', numberVal);
        }
        if (emailBody.contains('{!pocPackage.CFG_Office_Phone_Number__c}')) {
            String numberVal = pocPackage.CFG_Office_Phone_Number__c;
            if (language == 'French') {
                numberVal = numberVal.replace('-', '.');
            }
            emailBody = emailBody.replace('{!pocPackage.CFG_Office_Phone_Number__c}', numberVal);
        }
        if (language == 'French') {
            emailBody = emailBody.replace(
                '{!Additional_Info_Text}',
                'Comme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' + pocPackage.Client_Company_Name__c
            );
        } else {
            emailBody = emailBody.replace(
                '{!Additional_Info_Text}',
                'As you are aware, Canaccede International Management Ltd is processing ' + pocPackage.Client_Company_Name__c + ' insolvent accounts'
            );
        }
        String emailBodyCustomized = '';
        if (emailBody != null) {
            for (String s : emailBody.split('\n')) {
                emailBodyCustomized = emailBodyCustomized + s + '<br/>';
            }
        }
        String htmlBody = '<body style="clear:both;">' + emailBodyCustomized + '</body>';
        return htmlBody;
    }
}
