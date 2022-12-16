/***************************************************
* Author         : A5E Consultancy
* Created On     : 1 March 2020
* Description    : Helper class for Trustee TrusteeFollowUpBatch class to generate email message
*
***************************************************/
public class TrusteeFollowupBatchHelper {

    //public static Application_Config_Settings__c acs = [SELECT Domain_Name__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
    public static Trustee_Payment_Followup_Setting__c tps = Trustee_Payment_Followup_Setting__c.getValues('Trustee Payment Followup');

    /***********************************************
    *   Description  :  Initiate composing email message using information from Trustee, and Insolvency Account
    *   Parameters   :  trustee, insolvency, insolvAccounts, and emailTemplate
    *   Returns      :  SingleEmailMessage
    ************************************************/
    public static Messaging.SingleEmailMessage generateSingleEmailMessage(Account trustee, Insolvency__c insolvency, List<Insolvency_Account__c> insolvAccounts, EmailTemplate emailTemplate){
        
        Messaging.SingleEmailMessage mail;
        //PoC_Package_Settings__c pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvency.Client_Identifiers__c);

        //PoC_Package_Settings__c pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues('Scotia Bank');
                
        List<String> toEmails = new List<String>();
        String toEmail = fecthToEmail(trustee);
        //toEmail = 'rakeshm@a5econsulting.net';
        if(toEmail != NULL){
            mail = new Messaging.SingleEmailMessage();
            toEmails.add(toEmail); 
            //toEmails.add('pranali.vedpathak@canaccede.com');
            mail.setToAddresses(toEmails);
            mail.setOrgWideEmailAddressId(tps.Trustee_Email_Org_Wide_Address_Id__c);
            mail.setSubject(populateSubject(emailTemplate.subject, insolvency, insolvAccounts));
            mail.setHTMLBody(emailTemplate.HtmlValue);
            mail.setSaveAsActivity(true);   // Set activity true to create activity once email is send
            mail.setWhatId(insolvency.Id);
        }
        return mail;
    }

    /***********************************************
    *   Description  :  Read Business Email or Fax based on Communication Preferences on Trustee
    *   Parameters   :  trustee
    *   Returns      :  String formated email
    ************************************************/
    public static String fecthToEmail(Account trustee){
        
        String toEmail;

        // Check Communication preference
        if(trustee.Communication_Preference__c != NULL && trustee.Communication_Preference__c == 'Fax' && trustee.Fax != NULL){
                toEmail =  formatFaxAsEmail(trustee.Fax);   // Use generic method to fetch email address from Fax                     
        }
        else if(trustee.Follow_up_Email__c !=NULL){  
            toEmail =trustee.Follow_up_Email__c;             // Use Trustee Follow up Email as Priority
        } 
        else if(trustee.Business_Email__c != NULL){
            toEmail =  trustee.Business_Email__c;
        }
        return toEmail;
    }

    /***********************************************
    *   Description  :  Replace all merge fields from Insolvency, Insolvency Account on subject
    *   Parameters   :  subject, insolvency, insolvAccounts
    *   Returns      :  String with all merge fields populate on Email Subject
    ************************************************/
    public static String populateSubject(String subject, Insolvency__c insolvency, List<Insolvency_Account__c> insolvAccounts){
        
        String insolvencyAccountNames = getInsolvencyAccountNames(insolvAccounts);
        subject = subject.replace('{!Insolvency__c.Name}', insolvency.Name);
        subject = subject.replace('{!Insolvency_Account__c.Name}', insolvencyAccountNames);
        subject = subject.replace('{!Insolvency__c.Debtor_1_First_Name__c}', (insolvency.Debtor_1_First_Name__c != NULL ? insolvency.Debtor_1_First_Name__c : ''));
        subject = subject.replace('{!Insolvency__c.Debtor_1_Last_Name__c}', (insolvency.Debtor_1_Last_Name__c != NULL ? insolvency.Debtor_1_Last_Name__c : ''));

        return subject;
    }

    /***********************************************
    *   Description  :  Method reads all Insolvency Account numbers and frame a string
    *   Parameters   :  insolvAccounts
    *   Returns      :  String
    ************************************************/
    public static String getInsolvencyAccountNames(List<Insolvency_Account__c> insolvAccounts){
        /*String accountNumbers = '';
        for(Insolvency_Account__c insolvAcc: insolvAccounts){
            accountNumbers = accountNumbers+''+insolvAcc.Name+', ';
        }
        accountNumbers.replace(',','');*/
        List<String> inSolvAccNames = new List<String>();
        for(Insolvency_Account__c insolvAcc: insolvAccounts){
            inSolvAccNames.add(insolvAcc.Name);
        }
        String accountNumbers = String.join(inSolvAccNames, ', ');
        return accountNumbers;
    }

    /***********************************************
    *   Description  :  Reset "Number of Emails Sent" on Each trustee to 0
    *   Parameters   :  trusteeIds
    *   Returns      :  Map<Id, Account> 
    ************************************************/
    /*
    public static Map<Id, Account> resetTrusteeEmailSent(Set<Id> trusteeIds){
        Map<Id, Account> trusteeMap = new Map<Id, Account>([ SELECT  Id,
                                                        Number_Of_Emails_Sent_Today__c,
                                                        Communication_Preference__c,
                                                        Business_Email__c,
                                                        Fax,
                                                        Last_Trustee_Followup_Sent_Date__c 
                                                        FROM    Account 
                                                        WHERE 
                                                        Id IN: trusteeIds]);
                
        
        for(Id key : trusteeMap.keySet()){
                Account trustee = trusteeMap.get(key);
                trustee.Number_Of_Emails_Sent_Today__c = 0;
        }
        if(!trusteeMap.isEmpty()){
            update trusteeMap.values();
        }
        return trusteeMap;
    }
    */

    /**************************************************  
    *   Utility method to format Fax As Email Address
    *   Used in class   :   TrusteeEngagementBatchHelper
    *   Parameters      :   faxNo
    **************************************************/
    public static string formatFaxAsEmail(String faxNo){
        String formattedFax = faxNo;
        if(String.isNotBlank(formattedFax)){
            formattedFax = formattedFax.replace('(', '').replace(')', '');
            formattedFax = formattedFax.replaceAll('-', '');
            formattedFax = formattedFax.replaceAll(' ', '');
            //formattedFax =  formattedFax + acs.Domain_Name__c;
            formattedFax =  formattedFax + tps.Domain_Name__c;
        }  
        return formattedFax;
    }
}