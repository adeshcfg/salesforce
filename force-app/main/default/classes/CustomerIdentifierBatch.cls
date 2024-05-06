/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class for Customer object to calculate Collection Agency identifier 
 *                 and RecordTypeIdentifier based on related Products
 *  @author : A5E Consulting
 *  @date : 06/08/2020
 
 *************************************************************************************************/
public class CustomerIdentifierBatch implements Database.Batchable<sObject> {
    public static final string SEPARATOR = 'A';
    public static final string UNPLACED = 'unplaced';
    public static final string CCS_ACCOUNT = 'CCS_Account';
    public static final string DISTRESSED_ACCOUNT = 'Distressed_Account';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(
            [
                SELECT ID, Collection_Agency_Identifier__c, Record_Type_Identifier__c
                FROM Account
                WHERE
                    ID IN (
                        SELECT Customer__c
                        FROM Product__c
                        WHERE
                            (Run_Identifier_Check_On__c = TODAY
                            AND RecordType.name IN ('CCS Account', 'Distressed Account'))
                            OR (customer__r.createdDAte = today
                            AND recordType.name = 'Canaccede Customer')
                    )
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> listAccounts) {
        map<Id, list<Product__c>> mapCustomerProducts = new Map<Id, list<Product__c>>();
        list<Account> listCustomersToUpdate = new List<Account>();
        Account account;
        String AccountClientIdentifier;
        String ProductClientIdentifier;
        String AccountRecordTypeIdentifier;

        //Get Customers and all its related Products
        for (Account accountObj : [
            SELECT
                ID,
                Collection_Agency_Identifier__c,
                Record_Type_Identifier__c,
                (
                    SELECT ID, Name, RecordType.DeveloperName, Collection_Agency__c
                    FROM Products__r
                )
            FROM Account
            WHERE ID IN :listAccounts
        ]) {
            AccountClientIdentifier = '';
            AccountRecordTypeIdentifier = '';
            for (Product__c productObj : accountObj.Products__r) {
                //***Updating Collection Agency Identifier on Account***
                if (productObj.RecordType.DeveloperName == DISTRESSED_ACCOUNT) {
                    if (productObj.Collection_Agency__c == null || productObj.Collection_Agency__c == 9999) {
                        ProductClientIdentifier = SEPARATOR + UNPLACED + SEPARATOR;
                    } else {
                        ProductClientIdentifier = SEPARATOR + String.valueOf((integer) productObj.Collection_Agency__c) + SEPARATOR;
                    }
                    if (String.IsBlank(AccountClientIdentifier)) {
                        AccountClientIdentifier = ProductClientIdentifier;
                    } else {
                        //check if Product collection agency is already present in accpunt client identifier string else append
                        if (!AccountClientIdentifier.contains(ProductClientIdentifier)) {
                            AccountClientIdentifier += ',' + ProductClientIdentifier;
                        }
                    }
                }
                //***Updating Record Type Identifier on Account***
                if (productObj.RecordType.DeveloperName == CCS_ACCOUNT) {
                    if (String.isBlank(AccountRecordTypeIdentifier)) {
                        AccountRecordTypeIdentifier = productObj.RecordType.DeveloperName;
                    } else {
                        //check AccountRecordType identifier does not contain Product record type and append
                        if (!AccountRecordTypeIdentifier.contains(productObj.RecordType.DeveloperName)) {
                            AccountRecordTypeIdentifier += ',' + productObj.RecordType.DeveloperName;
                        }
                    }
                }
            }

            //Create Customer instance to update and add to list
            account = new Account();
            account.Id = accountObj.Id;
            account.Collection_Agency_Identifier__c = AccountClientIdentifier;
            //update External Collection Agency Identifier for Agency Group Sharing Rule
            account.External_Collection_Agency_Identifier__c = account.Collection_Agency_Identifier__c.replace('A68A', '')
                .replace('A6A', '')
                .replace(SEPARATOR + UNPLACED + SEPARATOR, '')
                .replace(',', '');
            account.Record_Type_Identifier__c = AccountRecordTypeIdentifier;
            listCustomersToUpdate.add(account);
        }

        if (!listCustomersToUpdate.isEmpty()) {
            //Do not run the customer trigger
            CustomerTriggerHandler.runCustomerTrigger = false;
            update listCustomersToUpdate;
            CustomerTriggerHandler.runCustomerTrigger = true;
        }
    }
    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
        //Call Judgment Batch
        Database.executeBatch(new JudgmentIdentifierBatch(), 200);
    }
}
