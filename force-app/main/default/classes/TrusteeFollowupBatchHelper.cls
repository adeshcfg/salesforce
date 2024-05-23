/***************************************************
 * Author         : A5E Consultancy
 * Created On     : 1 March 2020
 * Description    : Helper class for Trustee TrusteeFollowUpBatch class to generate email message
 *
 ***************************************************/
public class TrusteeFollowupBatchHelper {
    public static Trustee_Payment_Followup_Setting__c tps = Trustee_Payment_Followup_Setting__c.getValues('Trustee Payment Followup');

    /***********************************************
     *   Description  :  Initiate composing email message using information from Trustee, and Insolvency Account
     *   Parameters   :  trustee, insolvency, insolvAccounts, and emailTemplate
     *   Returns      :  SingleEmailMessage
     ************************************************/
    public static Messaging.SingleEmailMessage generateSingleEmailMessage(
        Account trustee,
        Insolvency__c insolvency,
        List<Insolvency_Account__c> insolvAccounts,
        EmailTemplate emailTemplate
    ) {
        Messaging.SingleEmailMessage mail;

        List<String> toEmails = new List<String>();
        String toEmail = fecthToEmail(trustee);
        if (toEmail != null) {
            mail = new Messaging.SingleEmailMessage();
            toEmails.add(toEmail);
            mail.setToAddresses(toEmails);
            mail.setOrgWideEmailAddressId(tps.Trustee_Email_Org_Wide_Address_Id__c);
            mail.setSubject(populateSubject(emailTemplate.subject, insolvency, insolvAccounts));
            mail.setHTMLBody(updateHtmlValue(emailTemplate.HtmlValue, insolvAccounts));
            mail.setSaveAsActivity(true); // Set activity true to create activity once email is send
            mail.setWhatId(insolvency.Id);
        }
        return mail;
    }

    /**
     * @description : Method to populate merge variables in HTML template
     * @author adesh.ikhar@canaccede.com | 05-10-2024
     * @param htmlValue
     * @param insolvAccounts
     * @return String
     **/
    public static String updateHtmlValue(String htmlValue, List<Insolvency_Account__c> insolvAccounts) {
        String spaceSeparator = '	';
        String accountsHtmlList = '';
        for (Insolvency_Account__c acc : insolvAccounts) {
            if (String.isBlank(acc.Bank_Name__c)) {
                accountsHtmlList += acc.Name + '<br>';
                continue;
            }
            accountsHtmlList += acc.Bank_Name__c + spaceSeparator + acc.Name + '<br>';
        }
        return htmlValue.replace('{!AccountList}', accountsHtmlList);
    }

    /***********************************************
     *   Description  :  Read Business Email or Fax based on Communication Preferences on Trustee
     *   Parameters   :  trustee
     *   Returns      :  String formated email
     ************************************************/
    public static String fecthToEmail(Account trustee) {
        String toEmail;
        // Check Communication preference
        if (trustee.Communication_Preference__c != null && trustee.Communication_Preference__c == 'Fax' && trustee.Fax != null) {
            toEmail = formatFaxAsEmail(trustee.Fax); // Use generic method to fetch email address from Fax
        } else if (trustee.Follow_up_Email__c != null) {
            toEmail = trustee.Follow_up_Email__c; // Use Trustee Follow up Email as Priority
        } else if (trustee.Business_Email__c != null) {
            toEmail = trustee.Business_Email__c;
        }
        return toEmail;
    }

    /***********************************************
     *   Description  :  Replace all merge fields from Insolvency, Insolvency Account on subject
     *   Parameters   :  subject, insolvency, insolvAccounts
     *   Returns      :  String with all merge fields populate on Email Subject
     ************************************************/
    public static String populateSubject(String subject, Insolvency__c insolvency, List<Insolvency_Account__c> insolvAccounts) {
        // String insolvencyAccountNames = getInsolvencyAccountNames(insolvAccounts);
        subject = subject.replace('{!Insolvency__c.Name}', insolvency.Name);
        // subject = subject.replace('{!Insolvency_Account__c.Name}', insolvencyAccountNames);
        subject = subject.replace(
            '{!Insolvency__c.Debtor_1_First_Name__c}',
            (insolvency.Debtor_1_First_Name__c != null ? insolvency.Debtor_1_First_Name__c : '')
        );
        subject = subject.replace('{!Insolvency__c.Debtor_1_Last_Name__c}', (insolvency.Debtor_1_Last_Name__c != null ? insolvency.Debtor_1_Last_Name__c : ''));

        return subject;
    }

    /***********************************************
     *   Description  :  Method reads all Insolvency Account numbers and frame a string
     *   Parameters   :  insolvAccounts
     *   Returns      :  String
     ************************************************/
    /* public static String getInsolvencyAccountNames(List<Insolvency_Account__c> insolvAccounts) {
        List<String> inSolvAccNames = new List<String>();
        for (Insolvency_Account__c insolvAcc : insolvAccounts) {
            inSolvAccNames.add(insolvAcc.Name);
        }
        String accountNumbers = String.join(inSolvAccNames, ', ');
        return accountNumbers;
    } */

    /**************************************************
     *   Utility method to format Fax As Email Address
     *   Used in class   :   TrusteeEngagementBatchHelper
     *   Parameters      :   faxNo
     **************************************************/
    public static string formatFaxAsEmail(String faxNo) {
        String formattedFax = faxNo;
        if (String.isNotBlank(formattedFax)) {
            formattedFax = formattedFax.replace('(', '').replace(')', '');
            formattedFax = formattedFax.replaceAll('-', '');
            formattedFax = formattedFax.replaceAll(' ', '');
            //formattedFax =  formattedFax + acs.Domain_Name__c;
            formattedFax = formattedFax + tps.Domain_Name__c;
        }
        return formattedFax;
    }
}
