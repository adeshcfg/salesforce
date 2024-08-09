/**************************************************************************************************
*
*  Class:    
*
*  @description : This is a helper class for Insolvency_Account object for validation
*  @author : A5E Consulting
*  @date : 09/30/2019

*************************************************************************************************/

public class InsolvencyAcctStatusValidationController {
    static Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();

    public static Boolean internalValidationRule(Insolvency_account__C insolvAcc, String oldValue, String NewValue) {
        if (config.Run_Insolvency_Status_Validations__c == false) {
            return true;
        }
        if (oldValue == NewValue) {
            return true;
        }
        if (
            (insolvAcc.Client_Identifier__c != 'Canaccede' &&
            insolvAcc.Client_Identifier__c != 'Fidem') &&
            config.Run_Insolvency_Status_Validations__c == true &&
            (oldValue == null ||
            oldValue != NewValue)
        ) {
            if (oldValue == null && newValue == 'New')
                return true;
            if (
                (oldValue == 'New' ||
                oldValue == 'PoC Details Provided' ||
                oldValue == 'Poc Package Generated' ||
                oldValue == 'No PoC Required' ||
                oldValue == 'Wait / Hold' ||
                oldValue == 'Trustee Followup') && newValue == 'For Owner Review'
            )
                return true;
            if (
                oldValue == 'For Owner Review' &&
                (newValue == 'PoC Details Provided' ||
                newValue == 'Wait / Hold' ||
                newValue == 'No PoC Required' ||
                newValue == 'Trustee Followup')
            )
                return true;
            if (oldValue == 'BOT Review Completed' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'Wait / Hold' && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'PoC Package Generated' && newValue == 'Claim Filed')
                return true;
            if (oldValue == 'Withdraw PoC' && newValue == 'Claim Withdrawn')
                return true;
            if (oldValue == 'Claim Filed' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'BOT Review completed' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'BOT Review completed' && newValue == 'Claim Filed')
                return true;
            if (oldValue == 'For Owner Review' && newValue == 'New')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'New')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'PoC Details Provided' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'PoC Package Generated' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'Claim Filed' && newValue == 'For Owner Review')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'PoC Details Provided' && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'For Owner Review' && newValue == 'PoC Package Generated')
                return true;
            if (
                (oldValue == 'Annulled' || oldValue == 'Refused' || oldValue == 'Withdrawn' || oldValue == 'Claim Withdrawn') &&
                newValue == 'Sent to collections'
            )
                return true;
            // New condition for Ticket#273
            if (
                (oldValue == 'Annulled' || oldValue == 'Refused' || oldValue == 'Withdrawn' || oldValue == 'Claim Withdrawn') &&
                newValue == 'Pending Assignment to Collection Agency'
            )
                return true;
            if (!(oldValue == null || oldValue == 'Annulled - Filed New') && newValue == 'Withdraw PoC')
                return true;
            if (!(oldValue == null || oldValue == 'Annulled - Filed New') && newValue == 'BOT Review')
                return true;
            if (
                insolvAcc.Asset_Status__c == 'Purchased' ||
                insolvAcc.Asset_Status__c == 'Bulk Purchased' ||
                insolvAcc.Asset_Status__c == 'Duplicate Purchased' ||
                insolvAcc.Asset_Status__c == 'Debt Purchase'
            )
                if ((oldValue == 'Annulled' || oldValue == 'Refused') && newValue == 'Debtor Paying Direct')
                    return true;
            if (oldValue == 'Annulled' && newValue == 'Annulled - Filed new')
                return true;
        }

        if (
            (insolvAcc.Client_Identifier__c == 'Canaccede' ||
            insolvAcc.Client_Identifier__c == 'Fidem') &&
            config.Run_Insolvency_Status_Validations__c == true &&
            (oldValue == null ||
            oldValue != NewValue)
        ) {
            //New Account Recall Requested Processing status for Fidem and Canaccede Insolvency Account
            //This status can only be selected when prior status is "For Owner Review"
            //This status can only be changed to For Owner Review and POC Details Provided

            if (newValue == 'Account Recall Requested') {
                if (oldValue == 'For Owner Review') {
                    return true;
                } else {
                    return false;
                }
            }

            if (oldValue == 'Account Recall Requested') {
                if (newValue == 'For Owner Review' || newValue == 'PoC Details Provided' || newValue == 'No PoC Required') {
                    return true;
                } else {
                    return false;
                }
            }

            if (newValue == 'Debtor Paying Direct') {
                if (oldValue == 'Annulled' || oldValue == 'Refused') {
                    return true;
                }
            } else if (newValue == 'Annulled - Filed New') {
                if (oldValue == 'Annulled')
                    return true;
            } else {
                return true;
            }
        }
        return false;
    }

    public static Boolean externalValidationRule(Insolvency_account__C insolvAcc, String oldValue, String NewValue) {
        if (config.Run_Insolvency_Status_Validations__c == false) {
            return true;
        }
        if (oldValue == NewValue) {
            return true;
        }
        if (config.Run_Insolvency_Status_Validations__c == true && (oldValue == null || oldValue != NewValue)) {
            if (insolvAcc.Client_Identifier__c == 'Canadian Tire' && oldValue == null && newValue == 'For Owner Review') {
                return true;
            }
            if (oldValue == null && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == null && newValue == 'Wait / Hold')
                return true;
            if (oldValue == null && newValue == 'No PoC Required')
                return true;
            if (oldValue == null && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'For Owner Review' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'Trustee Followup' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'Claim Filed' && newValue == 'PoC Details Provided')  
                return true;              
            if (oldValue == 'For Owner Review' && newValue == 'Wait / Hold')
                return true;
            if (oldValue == 'For Owner Review' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'Trustee Followup' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'For Owner Review' && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'Wait / Hold' && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'Wait / Hold' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'PoC Details Provided')
                return true;
            if (oldValue == 'PoC Details Provided' && newValue == 'Wait / Hold')
                return true;
            if (oldValue == 'PoC Details Provided' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'Wait / Hold' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'Wait / Hold')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'Trustee Followup')
                return true;
            if (oldValue == 'PoC Details Provided' && newValue == 'For Owner Review')
                return true;
            if (oldValue == 'No PoC Required' && newValue == 'For Owner Review')
                return true;
            if (oldValue == 'Wait / Hold' && newValue == 'For Owner Review')
                return true;

            if (oldValue != null && newValue == 'Withdraw PoC')
                return true;
            if (oldValue != null && newValue == 'BOT Review')
                return true;

            //Code for new value BOT Mismatch
            if (oldValue == 'BOT Mismatch' && newValue == 'BOT Review')
                return true;
            if (oldValue == 'BOT Review' && newValue == 'BOT Mismatch')
                return true;

            if (oldValue != null && newValue == 'BOT Review completed')
                return true;
            if (oldValue == 'BOT Review completed' && newValue == 'No PoC Required')
                return true;
            if (oldValue == 'BOT Review completed' && newValue == 'PoC Details Provided')
                return true;
            if (
                oldValue == 'BOT Review completed' &&
                newValue == 'Wait / Hold' //This code is added to allow the change in status from BOT Review Completed to Wait / Hold
            )
                return true;
        }

        return false;
    }
}
