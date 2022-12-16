/**************************************************************************************************
*
*  Class:    
*
*  @description : This is a Test class for InsolvencyAcctStatusValidationController
*  @author : A5E Consulting
*  @date : 10/04/2019

*************************************************************************************************/
@isTest 
public class TestInsolvencyAcctStatusValidation{
    
    static testMethod void internalStatusValidation(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Insolvency_Status_Validations__c = true;
        
        insert config; 
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger=False;
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insert insolv1;
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c' and Name like '%SDA%']);
        Insolvency_Account__c insacc = new Insolvency_Account__c();
        insacc.RecordTypeId = recordTypeList[0].Id;
        insacc.Name = 'Test-001';
        insacc.Insolvency_Status__c = 'No PoC Required';
        insacc.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insacc.Claim_Type__c = 'Unsecured';
        insacc.Insolvency__c = insolv1.Id;
        insacc.Account_Number_Without_Space__c = 'Test-001';
        insert insacc;
        
        InsolvencyAcctStatusValidationController validCont = new InsolvencyAcctStatusValidationController();
        
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, NULL, 'New');
        config.Run_Insolvency_Status_Validations__c = True;
        update config;
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'NULL', 'Debtor Paying Direct');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'New', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'PoC Package Generated');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'BOT Review Completed', 'No PoC Required');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Wait / Hold', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Package Generated', 'Claim Filed');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Refused', 'Sent to collections');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Refused', 'Pending Assignment to Collection Agency');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Annulled', 'Debtor Paying Direct');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Withdraw PoC', 'Claim Withdrawn');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Claim Filed', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'BOT Review completed', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'BOT Review completed', 'Claim Filed');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'New');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'No PoC Required', 'New');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'No PoC Required', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Details Provided', 'No PoC Required');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Package Generated', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Claim Filed', 'For Owner Review');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'No PoC Required', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Details Provided', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Annulled', 'Annulled - Filed New');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Refused', 'Debtor Paying Direct');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'Account Recall Requested');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Account Recall Requested', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Account Recall Requested', 'For Owner Review');
        
    }
    
    static testMethod void externalStatusValidation(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Insolvency_Status_Validations__c = true;
        
        insert config; 
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger=False;
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insert insolv1;
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c' and Name like '%SDA%']);
        Insolvency_Account__c insacc = new Insolvency_Account__c();
        insacc.RecordTypeId = recordTypeList[0].Id;
        insacc.Name = 'Test-001';
        insacc.Insolvency_Status__c = 'No PoC Required';
        insacc.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insacc.Claim_Type__c = 'Unsecured';
        insacc.Insolvency__c = insolv1.Id;
        insacc.Account_Number_Without_Space__c = 'Test-001';
        insert insacc;
        
        InsolvencyAcctStatusValidationController validCont = new InsolvencyAcctStatusValidationController();
        
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, NULL, 'New');
        config.Run_Insolvency_Status_Validations__c = True;
        update config;
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, NULL, 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, NULL, 'Trustee Followup');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, NULL, 'BOT Review Completed');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Review Completed', 'No PoC Required');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Wait / Hold', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'PoC Package Generated', 'Claim Filed');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Withdraw PoC', 'Claim Withdrawn');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Claim Filed', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Review completed', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Review completed', 'Claim Filed');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'For Owner Review', 'New');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'No PoC Required', 'New');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'No PoC Required', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'PoC Details Provided', 'No PoC Required');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'PoC Package Generated', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Claim Filed', 'For Owner Review');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'No PoC Required', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'PoC Details Provided', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Trustee Followup', 'No PoC Required');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'For Owner Review', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, NULL, 'No PoC Required');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, NULL, 'Wait / Hold');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'For Owner Review', 'Wait / Hold');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Review', 'BOT Mismatch');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Mismatch', 'BOT Review');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Review completed', 'Wait / Hold');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'For Owner Review', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Trustee Followup', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'For Owner Review', 'No PoC Required');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Wait / Hold', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'PoC Details Provided', 'Wait / Hold');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Wait / Hold', 'No PoC Required');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'No PoC Required', 'Wait / Hold');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'PoC Details Provided', 'For Owner Review');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'No PoC Required', 'For Owner Review');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Wait / Hold', 'For Owner Review');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'Wait / Hold', 'Withdraw PoC');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Mismatch', 'BOT Review');
        InsolvencyAcctStatusValidationController.externalValidationRule(insacc, 'BOT Mismatch', 'BOT Review completed');
    }
    
    static testMethod void internalStatusValidationforFidem(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Insolvency_Status_Validations__c = true;
        
        insert config; 
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger=False;
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Fidem';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insert insolv1;
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c' and Name like '%Fidem%']);
        Insolvency_Account__c insacc = new Insolvency_Account__c();
        insacc.RecordTypeId = recordTypeList[0].Id;
        insacc.Name = 'Test-001';
        insacc.Client_Identifier__c = 'Fidem';
        insacc.Insolvency_Status__c = 'No PoC Required';
        insacc.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insacc.Claim_Type__c = 'Unsecured';
        insacc.Insolvency__c = insolv1.Id;
        insacc.Account_Number_Without_Space__c = 'Test-001';
        insacc.Asset_Status__c='Purchased';
        insert insacc;
        
        InsolvencyAcctStatusValidationController validCont = new InsolvencyAcctStatusValidationController();
        
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, NULL, 'New');
        config.Run_Insolvency_Status_Validations__c = True;
        update config;
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'NULL', 'Debtor Paying Direct');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'New', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'PoC Package Generated');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'BOT Review Completed', 'No PoC Required');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Wait / Hold', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Package Generated', 'Claim Filed');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Refused', 'Sent to collections');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Annulled', 'Debtor Paying Direct');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Withdraw PoC', 'Claim Withdrawn');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Claim Filed', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'BOT Review completed', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'BOT Review completed', 'Claim Filed');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'New');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'No PoC Required', 'New');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'No PoC Required', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Details Provided', 'No PoC Required');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Package Generated', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Claim Filed', 'For Owner Review');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'No PoC Required', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Details Provided', 'Trustee Followup');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Annulled', 'Annulled - Filed New');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Refused', 'Debtor Paying Direct');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'For Owner Review', 'Account Recall Requested');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'PoC Details Provided', 'Account Recall Requested');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Account Recall Requested', 'PoC Details Provided');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Account Recall Requested', 'For Owner Review');
        InsolvencyAcctStatusValidationController.internalValidationRule(insacc, 'Account Recall Requested', 'Annulled');
        
    }
}