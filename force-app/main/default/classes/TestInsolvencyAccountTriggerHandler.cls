/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyAccountTriggerHandler
 *  @author : A5E Consulting
 *  @date : 09/18/2016
 *
 *************************************************************************************************/

@isTest
private class TestInsolvencyAccountTriggerHandler {
    @testSetup
    static void testData() {
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;
        
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insolv.Client_Identifiers__c = 'New';
        insolv.Insolvency_Type__c = 'Bankruptcy';
        insert insolv;
        system.debug('insolvency created-->'+insolv.id);
        system.debug('insolvency created-->'+insolv.name);
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456783';
        insolv1.Client_Identifiers__c = 'SPL';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;
         
        //Portfolio record
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c = ' 13';
        insert portfolioName;

        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND Name LIKE '%SDA%']
        );
        //Insolvency Account records
        List<Insolvency_Account__c> iaListNew = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'For Owner Review';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 1000;
        ia1.Insolvency__c = insolv1.Id;
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        ia1.Asset_Status__c = 'Purchased';
        ia1.Distressed_Data_Id__c = '848085644';
        ia1.Sent_For_Owner_Review_Date_Original__c = date.today();
        ia1.Trustee_Not_Providing_LoR__c = false;
        ia1.Distressed_Data_Id__c = '1';
        ia1.Claim_Filed_Date__c = System.now();
        //insert ia1;

        Insolvency_Account__c ia2 = new Insolvency_Account__c();
        ia2.RecordTypeId = recordTypeList[0].Id;
        ia2.Name = 'Test- 001';
        ia2.Insolvency_Status__c = 'New';
        ia2.Claim_Type__c = 'Secured';
        ia2.Claim_Amount__c = 1000;
        ia2.Insolvency__c = insolv1.Id;
        ia2.Portfolio_Group_Name__c = 'CIH002';
        ia2.Investment_Group__c = 'AFFIRM';
        ia2.Portfolio_Name_Lookup__c = portfolioName.id;
        ia2.Asset_Status__c = 'Purchased';
        ia2.Distressed_Data_Id__c = '84565665';
        ia2.Sent_For_Owner_Review_Date_Original__c = date.today();
        ia2.Trustee_Not_Providing_LoR__c = false;
        ia2.Distressed_Data_Id__c = '2';
        ia2.Claim_Filed_Date__c = System.now();
       // insert ia2;

        Insolvency_Account__c ia3 = new Insolvency_Account__c();
        ia3.RecordTypeId = recordTypeList[0].Id;
        ia3.Name = 'Test-0001';
        ia3.Insolvency_Status__c = 'Pending Assignment to Collection Agency';
        ia3.Claim_Type__c = 'Secured';
        ia3.Claim_Amount__c = 1000;
        ia3.Insolvency__c = insolv1.Id;
        ia3.Portfolio_Group_Name__c = 'CIT002';
        ia3.Investment_Group__c = 'AFFIRM';
        ia3.Portfolio_Name_Lookup__c = portfolioName.id;
        ia3.Asset_Status__c = 'Purchased';
        ia3.Sent_For_Owner_Review_Date_Original__c = date.today();
        ia3.Trustee_Not_Providing_LoR__c = false;
        ia3.Distressed_Data_Id__c = '3';
        ia3.Claim_Filed_Date__c = null;
        //insert ia3;
        iaListNew.add(ia1);
        iaListNew.add(ia2);
        iaListNew.add(ia3);
        insert iaListNew;
    }

    //Test Before Insert
    static testMethod void insolvencyBeforeInsertTest() {
        Account accInstance1 = new Account();
        string recrdid3 = [
            SELECT id
            FROM RecordType
            WHERE sobjecttype = 'Account' AND RecordType.Name = 'Canaccede Customer'
        ]
        .id;
        accInstance1.RecordTypeId = recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123';
        insert accInstance1;

        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();

        Insolvency__c insolv2 = new Insolvency__c();
        insolv2.Name = '12456781';
        insolv2.Client_Identifiers__c = 'SPL';
        insolv2.Insolvency_Type__c = 'Bankruptcy';

        insolvList.add(insolv1);
        insolvList.add(insolv2);
        insert insolvList;

        //Portfolio record
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c = '13';
        insert portfolioName;

        //Product Record
        List<Product__c> prodList = new List<Product__c>();

        Product__c prod = new Product__c();
        prod.name = '85565666';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Pending';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 3000.00;
        prod.Collection_Agency__c = 68;
        prod.Purchase_Date__c = Date.newInstance(2016, 12, 9);
        prod.Investment_Group__c = 'BNS1 INSOLVENT';
        prod.Portfolio_Group_Name__c = 'AAL001';
        prod.Account_Purchasing_Entity__c = '14';
        prod.Originating_Creditor__c = 'CUETS';
        prod.Portfolio_Name__c = 'AFSCARDS';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();

        Product__c prod1 = new Product__c();
        prod1.name = '84565665';
        prod1.Payment_Setup_Status__c = 'Automated';
        prod1.Funding_Status__c = 'Pending';
        prod1.Funding_Type__c = 'Automated';
        prod1.Disbursement_Amount__c = 3000.00;
        prod1.Collection_Agency__c = 68;
        prod1.Purchase_Date__c = Date.newInstance(2016, 12, 9);
        prod1.Investment_Group__c = 'BNS1 INSOLVENT';
        prod1.Portfolio_Group_Name__c = 'AAL001';
        prod1.Account_Purchasing_Entity__c = '14';
        prod1.Originating_Creditor__c = 'CUETS';
        prod1.Portfolio_Name__c = 'AFSCARDS';
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();

        prodList.add(prod);
        prodList.add(prod1);
        insert prodList;

        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

        //Insolvency Account records
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'For Owner Review';
        ia1.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        ia1.Asset_Status__c = 'Purchased';
        ia1.Distressed_Data_Id__c = '85565666';
        ia1.Trustee_Not_Providing_LoR__c = true;

        Insolvency_Account__c ia2 = new Insolvency_Account__c();
        ia2.RecordTypeId = recordTypeList[0].Id;
        ia2.Name = 'Test- 002';
        ia2.Insolvency_Status__c = 'New';
        ia2.Claim_Type__c = 'Secured';
        ia2.Insolvency__c = insolv2.Id;
        ia2.Account_Number_Without_Space__c = 'Test-002';
        ia2.Portfolio_Group_Name__c = 'CIH002';
        ia2.Investment_Group__c = 'AFFIRM';
        ia2.Portfolio_Name_Lookup__c = portfolioName.id;
        ia2.Asset_Status__c = 'Purchased';

        Insolvency_Account__c ia3 = new Insolvency_Account__c();
        ia3.RecordTypeId = recordTypeList[0].Id;
        ia3.Name = 'Test- 003';
        ia3.Insolvency_Status__c = 'New';
        ia3.Claim_Type__c = 'Unsecured';
        ia3.Insolvency__c = insolv2.Id;
        ia3.Account_Number_Without_Space__c = 'Test-003';
        ia3.Portfolio_Group_Name__c = 'CIA002';
        ia3.Investment_Group__c = 'AFFIRM';
        ia3.Portfolio_Name_Lookup__c = portfolioName.id;
        ia3.Asset_Status__c = 'Purchased';

        Insolvency_Account__c ia4 = new Insolvency_Account__c();
        ia4.RecordTypeId = recordTypeList[0].Id;
        ia4.Name = 'Test- 004';
        ia4.Insolvency_Status__c = 'Trustee Followup';
        ia4.Claim_Type__c = 'Unsecured';
        ia4.Insolvency__c = insolv2.Id;
        ia4.Portfolio_Group_Name__c = 'CAL004';
        ia4.Investment_Group__c = 'AFFIRM';
        ia4.Portfolio_Name_Lookup__c = portfolioName.id;
        ia4.Asset_Status__c = 'Purchased';

        Insolvency_Account__c ia5 = new Insolvency_Account__c();
        ia5.RecordTypeId = recordTypeList[0].Id;
        ia5.Name = 'Test- 005';
        ia5.Insolvency_Status__c = 'Claim Filed';
        ia5.Claim_Type__c = 'Unsecured';
        ia5.Insolvency__c = insolv2.Id;
        ia5.Portfolio_Group_Name__c = 'ETC001';
        ia5.Investment_Group__c = 'AFFIRM';
        ia5.Portfolio_Name_Lookup__c = portfolioName.id;
        ia5.Asset_Status__c = 'Purchased';

        Insolvency_Account__c ia6 = new Insolvency_Account__c();
        ia6.RecordTypeId = recordTypeList[0].Id;
        ia6.Name = 'Test- 004';
        ia6.Insolvency_Status__c = 'Wait / Hold';
        ia6.Claim_Type__c = 'Unsecured';
        ia6.Insolvency__c = insolv2.Id;
        ia6.Portfolio_Group_Name__c = 'ETC001';
        ia6.Investment_Group__c = 'AFFIRM';
        ia6.Portfolio_Name_Lookup__c = portfolioName.id;
        ia6.Asset_Status__c = 'Purchased';

        List<Insolvency_Account__c> iaList = new List<Insolvency_Account__c>();
        iaList.add(ia1);
        iaList.add(ia2);
        iaList.add(ia3);
        iaList.add(ia4);
        iaList.add(ia5);
        iaList.add(ia6);
        insert iaList;

        InsolvencyAccountTriggerHandler.handleBeforeInsert(iaList);
    }

    //Test Before Update
    static testMethod void insolvencyBeforeUpdateTest() {
        //Insolvency Record
        Insolvency__c insolv=[select id from Insolvency__c where name='12456783' OR Client_Identifiers__c = 'SPL' OR Insolvency_Type__c = 'Bankruptcy' LIMIT 1];
        List<Insolvency_Account__c> iaList = new List<Insolvency_Account__c>();
        Account accInstance1 = new Account();
        string recrdid3 = [
            SELECT id
            FROM RecordType
            WHERE sobjecttype = 'Account' AND RecordType.Name = 'Canaccede Customer'
        ]
        .id;
        accInstance1.RecordTypeId = recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123';
        insert accInstance1;

        //Product Record
        Product__c prod = new Product__c();
        prod.name = '848085644';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Pending';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 3000.00;
        prod.Collection_Agency__c = 68;
        prod.Purchase_Date__c = Date.newInstance(2016, 12, 9);
        prod.Investment_Group__c = 'BNS1 INSOLVENT';
        prod.Portfolio_Group_Name__c = 'AAL001';
        prod.Account_Purchasing_Entity__c = '14';
        prod.Originating_Creditor__c = 'CUETS';
        prod.Portfolio_Name__c = 'AFSCARDS';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod;

        list<RecordType> recordTypeList1 = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND Name LIKE '%SPL%']
        );
        Insolvency_Account__c  ia3 = [
            SELECT
                Id,
                Name,
                RecordTypeId,
                Claim_Type__c,
                Client_Identifier__c,
                Insolvency_Status__c,
                Distressed_Data_Id__c,
                Claim_Filed_Date__c,
                Sent_For_Owner_Review_Date_External__c,
                Do_Not_Run_Status_Validation__c,
                Claim_Amount__c,
                Total_Account_Recovery__c,
                Revival_Date__c,
                Sent_For_Owner_Review_Date_Original__c
            FROM Insolvency_Account__c
            WHERE Distressed_Data_Id__c = '3' AND insolvency__c=:insolv.id
        ];
        Insolvency_Account__c ia2 = [
            SELECT
                Id,
                Name,
                RecordTypeId,
                Claim_Type__c,
                Client_Identifier__c,
                Insolvency_Status__c,
                Distressed_Data_Id__c,
                Claim_Filed_Date__c,
                Sent_For_Owner_Review_Date_External__c,
                Do_Not_Run_Status_Validation__c,
                Claim_Amount__c,
                Total_Account_Recovery__c
            FROM Insolvency_Account__c
            WHERE Distressed_Data_Id__c = '2' AND insolvency__c=:insolv.id
        ];
        Insolvency_Account__c ia1 = [
            SELECT
                Id,
                Name,
                RecordTypeId,
                Claim_Type__c,
                Client_Identifier__c,
                Insolvency_Status__c,
                Distressed_Data_Id__c,
                Claim_Filed_Date__c,
                Sent_For_Owner_Review_Date_External__c,
                Do_Not_Run_Status_Validation__c,
                Claim_Amount__c,
                Total_Account_Recovery__c
            FROM Insolvency_Account__c
            WHERE Distressed_Data_Id__c = '1' AND insolvency__c=:insolv.id
        ];

        //ia3.RecordTypeId = recordTypeList1[0].Id;
        ia3.Name = 'Test-0001';
        ia3.Insolvency_Status__c = 'For Owner Review';
        ia3.Asset_Status__c = 'Duplicate';
        ia3.Insolvency__c = insolv.Id;
        ia3.Distressed_Data_Id__c = '848085644';
        ia3.Trustee_Not_Providing_LoR__c = true;
        ia3.Revival_Date__c = Date.today();
        update ia3;
        iaList.add(ia3);

        ia2.RecordTypeId = recordTypeList1[0].Id;
        ia2.Name = 'Test- 0 01';
        ia2.Insolvency_Status__c = 'For Owner Review';
        ia2.Insolvency__c = insolv.Id;
        ia2.Trustee_Not_Providing_LoR__c = true;
        update ia2;
        iaList.add(ia2);

        ia1.RecordTypeId = recordTypeList1[0].Id;
        ia1.Name = 'Test- 0 02';
        ia1.Insolvency_Status__c = 'Trustee Followup';
        ia1.Insolvency__c = insolv.Id;
        ia1.Trustee_Not_Providing_LoR__c = true;
        update ia1;
        iaList.add(ia1);
        Map<ID, Insolvency_Account__c> iaMap = new Map<ID, Insolvency_Account__c>();
        iaMap.put(ia3.id, ia3);
        iaMap.put(ia2.id, ia2);
        iaMap.put(ia1.id, ia1);
        Test.startTest();
        //Test for Before Update
        InsolvencyAccountTriggerHandler.handleBeforeUpdate(iaList, iaMap);

        //Test for After Delete
        InsolvencyAccountTriggerHandler.handleAfterDelete(iaList, iaMap);

        //Test for After Update
        InsolvencyAccountTriggerHandler.handleAfterUpdate(iaList, iaMap);
        InsolvencyAccountTriggerHandler.getClientIdentifierBasedOnRecordType(recordTypeList[0].Id);
        InsolvencyAccountTriggerHandler.errorMessageOwnerReview = 'test';
        //solvencyAccTrigger.errorMessageOwnerReview = 'test';
        Test.stopTest();
    }

    //Test after insert, update, delete
    static testMethod void afterTest() {
        //Insolvency Record
        Insolvency__c insolv=[select id from Insolvency__c where name='12456789' OR Client_Identifiers__c = 'New' OR Insolvency_Type__c = 'Bankruptcy' LIMIT 1];


        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

        //Insolvency Account Records
        List<Insolvency_Account__c> iaRecords = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.name = 'testAccount1';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 200;
        ia1.Client_Identifier__c = 'Scotia Bank';
        ia1.Insolvency__c = insolv.id;
        //insert ia1;

        Insolvency_Account__c ia2 = new Insolvency_Account__c();
        ia2.RecordTypeId = recordTypeList[0].Id;
        ia2.Insolvency_Status__c = 'New';
        ia2.name = 'testAccount2';
        ia2.Claim_Type__c = 'Secured';
        ia2.Client_Identifier__c = 'SPL';
        ia2.Claim_Amount__c = 300;
        ia2.Insolvency__c = insolv.id;
        //insert ia2;

        Insolvency_Account__c ia3 = new Insolvency_Account__c();
        ia3.RecordTypeId = recordTypeList[0].Id;
        ia3.name = 'testAccount1';
        ia3.Insolvency_Status__c = 'New';
        ia3.Claim_Type__c = 'Unsecured';
        ia3.Claim_Amount__c = 200;
        ia3.Client_Identifier__c = 'Scotia Bank';
        ia3.Insolvency__c = insolv.id;
        ia3.Insolvency_Status__c = 'Claim Filed';
       // insert ia3;
        iaRecords.add(ia1);
        iaRecords.add(ia2);
        iaRecords.add(ia3);
        try{
            insert iaRecords;
            InsolvencyAccountTriggerHandler.handleAfterInsert(iaRecords);
            InsolvencyAccountTriggerHandler.handleAfterInsertUpdate(iaRecords, insolv.id);
        }catch(exception e){
            system.debug('Exception occured -->'+E);
        }
        
    }

    //Test after insert, update, delete
    static testMethod void duplicateCheck() {
        //Insolvency Record
        Insolvency__c insolv=[select id from Insolvency__c where name='12456789' OR Client_Identifiers__c = 'New' OR Insolvency_Type__c = 'Bankruptcy' LIMIT 1];

        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

        //Insolvency Account Records
        List<Insolvency_Account__c> iaRecords = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.name = 'testAccount1';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 200;
        ia1.Client_Identifier__c = 'Scotia Bank';
        ia1.Insolvency__c = insolv.id;
        insert ia1;

        Insolvency_Account__c ia2 = new Insolvency_Account__c();
        ia2.RecordTypeId = recordTypeList[0].Id;
        ia2.Insolvency_Status__c = 'New';
        ia2.name = 'TestAccount1';
        ia2.Claim_Type__c = 'Secured';
        ia2.Client_Identifier__c = 'SPL';
        ia2.Claim_Amount__c = 300;
        ia2.Insolvency__c = insolv.id;

        try {
            insert ia2;
            iaRecords.add(ia1);
            iaRecords.add(ia2);
            Map<ID, Insolvency_Account__c> mapAcc = new Map<ID, Insolvency_Account__c>();

            InsolvencyAccountTriggerHandler.handleBeforeInsert(iaRecords);
            throw new MyException('An exception should have been thrown by the trigger but was not.');
        } catch (Exception exp) {
            Boolean expectedExceptionThrown = (exp.getMessage().contains('trigger but was not')) ? true : false;
        }
    }

    public static testMethod void testForOwnerReviewExternal() {
        //Insolvency Record
        Insolvency__c insolv=[select id from Insolvency__c where name='12456789' OR Client_Identifiers__c = 'New' OR Insolvency_Type__c = 'Bankruptcy' LIMIT 1];

        list<RecordType> recordTypeList = new List<RecordType>(
            [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%'
            ]
        );

        //Insolvency Account Records
        List<Insolvency_Account__c> iaRecords = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.name = 'testAccount1';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 200;
        ia1.Client_Identifier__c = 'SPL';
        ia1.Insolvency__c = insolv.id;
        ia1.Insolvency_Status__c = 'No Poc Required';
        ia1.Reason_for_No_PoC_Required_Dropdown__c = 'No Open Accounts';
        insert ia1;

        iaRecords.add(ia1);

        //BeforeInsert Call
        InsolvencyAccountTriggerHandler.handleBeforeInsert(iaRecords);
        Map<ID, Insolvency_Account__c> iaMap = new Map<ID, Insolvency_Account__c>();
        iaMap.put(ia1.id, ia1);

        ia1.Insolvency_Status__c = 'For Owner Review';
        system.debug('Sent_For_Owner_Review_Date_External__c' + ia1.Sent_For_Owner_Review_Date_External__c);

        List<Insolvency_Account__c> listNewInsolvencyAccount = new List<Insolvency_Account__c>();
        // update ia1;
        listNewInsolvencyAccount.add(ia1);
        system.debug('Sent_For_Owner_Review_Date_External__c' + ia1.Sent_For_Owner_Review_Date_External__c);
        InsolvencyAccountTriggerHandler.handleBeforeUpdate(listNewInsolvencyAccount, iaMap);
        InsolvencyAccountTriggerHandler.handleAfterUpdate(listNewInsolvencyAccount, iaMap);
    }

    public static testMethod void testTotalClaimAmount() {
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        system.debug('run: ' + config.Run_Insolvency_Account_Trigger__c);
        //Insolvency Record
        Insolvency__c insolv=[select id from Insolvency__c where name='12456789' OR Client_Identifiers__c = 'New' OR Insolvency_Type__c = 'Bankruptcy' LIMIT 1];

        list<RecordType> recordTypeList = new List<RecordType>(
            [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%'
            ]
        );

        //Insolvency Account Records
        List<Insolvency_Account__c> iaRecords = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.name = 'testAccount1';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 200;
        ia1.Client_Identifier__c = 'Scotia Bank';
        ia1.Insolvency__c = insolv.id;
        ia1.Insolvency_Status__c = 'Claim Filed';
        insert ia1;

        ia1.Insolvency_Status__c = 'For Owner Review';
        system.debug('Sent_For_Owner_Review_Date_External__c' + ia1.Sent_For_Owner_Review_Date_External__c);
        update ia1;
        system.debug('Sent_For_Owner_Review_Date_External__c' + ia1.Sent_For_Owner_Review_Date_External__c);
        delete ia1;
    }

    @isTest
    public static void testPercentageOfIncreasedReturn() {
        list<RecordType> recordTypeList = new List<RecordType>(
            [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'Insolvency_Account__c' AND DeveloperName = 'Canadian_Tire_Insolvency_Account'
            ]
        );
        Insolvency__c insolv=[select id from Insolvency__c where name='12456789' OR Client_Identifiers__c = 'New' OR Insolvency_Type__c = 'Bankruptcy' LIMIT 1];
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[0].Id;
        ia1.name = 'testAccount1';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 200;
        ia1.Client_Identifier__c = 'Scotia Bank';
        ia1.Insolvency__c = insolv.id;
        ia1.Insolvency_Status__c = 'Claim Filed';
        insert ia1;
        InsolvencyAccountTriggerHandler.updatePercentageOfIncreasedReturn(ia1);
    }

    public class MyException extends Exception {
    }
}
