@isTest
private class TestCustomerStagingExcelFileProcessing {
    @testSetup
    static void testData() {
        API_Call_Details__c apiCallDetails = new API_Call_Details__c();
        apiCallDetails.name = 'Agency Portal API';
        apiCallDetails.API_Request_Timeout__c = 90000;
        apiCallDetails.PDF_API_URL__c = 'https://test.com/customerstaging/';
        apiCallDetails.Tenand_ID__c = '123';
        apiCallDetails.Proxy_Client_ID__c = '123';
        apiCallDetails.Client_ID__c = '1234';
        apiCallDetails.Client_Secret__c = '1234';
        apiCallDetails.AuthorizationtUrl__c = 'https://test.com/endpointurl';
        apiCallDetails.Scope_Prefix__c = 'scopep.com';
        apiCallDetails.Scope_Suffix__c = '/.default';
        insert apiCallDetails;

        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        portalSettings.Work_Assignment_Status__c = 'Requested,In Progress';
        portalSettings.Agency_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.CFG_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.Media_Status__c = 'Requested,In Progress';
        portalSettings.Excel_File_Processing_Status__c = 'Requested,In Progress,Completed';
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;

        Placement__c placementcObj = new Placement__c(Name = '12435');
        insert placementcObj;

        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.PersonBirthdate = system.today().addYears(-20);
        accInstance.PersonMailingStreet = '3024 Port Street';
        accInstance.PersonMailingCity = 'T';
        accInstance.PersonMailingState = 'ON';
        accInstance.PersonMailingPostalCode = '91762';
        accInstance.PersonHomePhone = '613-555-0172';
        accInstance.Work_Phone__pc = '613-555-0162';
        accInstance.PersonOtherPhone = '613-555-0122';
        accInstance.PersonEmail = 'annatestt@email.com';
        accInstance.SIN__pc = '0123';
        insert accInstance;

        Product__c product = new Product__c();
        product.Name = '2500P316';
        product.customer__c = accInstance.id;
        product.Status__c = 'New Allocation - New Allocation';
        product.Sub_Status__c = 'Ready';
        product.Product_Status__c = 'Test';
        insert product;

        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

        Document_storage__c documentstoragecObj = new Document_storage__c(
            Creator__c = 'test value',
            Uploaded_By__c = 'Internal User',
            Work_Assignment__c = wrkAss.Id,
            Document_URL__c = 'task/testing'
        );
        insert documentstoragecObj;
    }

    @isTest
    static void testNegative() {
        Placement__c placementcObj = [SELECT Name FROM Placement__c LIMIT 1];
        Document_storage__c documentstoragecObj = [SELECT Id, Document_URL__c FROM Document_storage__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        System.enqueueJob(new CustomerStagingExcelFileProcessing(documentstoragecObj.Document_URL__c, '32', documentstoragecObj.Id));
        Test.stopTest();
        /* new CustomerStagingExcelFileProcessing(
            '[{"data_id":"2500P316","pri_email":"test@email.com","pri_add1":"TEST 7607 172 ST NW A408","pri_add2":"TEST APT A408","pri_municipality":"TEST Edmonton","pri_province":"ON","pri_postcode":"T5T2P2","pri_country":"CAN","pri_hphone":"780-999-0548","pri_wphone":"780-433-4729","pri_cphone":"519-555-1212","sec_email":"test@email.com","sec_add1":"TEST sec addy1","sec_add2":"TEST sec addy2","sec_municipality":"TEST mun","sec_province":"TEST prov","sec_postcode":"T5T2P2","sec_country":"CAN","sec_hphone":"780-999-0548","sec_wphone":"780-433-4729","sec_cphone":"519-555-1212"}]',
            placementcObj.Name,
            documentstoragecObj.Id
        );
        new CustomerStagingExcelFileProcessing(
            '[{"data_id":"2500P316","pri_email":"testwrongemail.com","pri_add1":"TEST 7607 172 ST NW A408","pri_add2":"TEST APT A408","pri_municipality":"TEST Edmonton","pri_province":"ON","pri_postcode":"T5T2P2","pri_country":"CAN","pri_hphone":"780-999-05480","pri_wphone":"780-433-4729","pri_cphone":"519-555-1212","sec_email":"test@email.com","sec_add1":"TEST sec addy1","sec_add2":"TEST sec addy2","sec_municipality":"TEST mun","sec_province":"TEST prov","sec_postcode":"T5T2P2","sec_country":"CAN","sec_hphone":"780-999-0548","sec_wphone":"780-433-4729","sec_cphone":"519-555-1212"}]',
            placementcObj.Name,
            documentstoragecObj.Id
        );
        new CustomerStagingExcelFileProcessing(
            '[{"pri_email":"test@email.com","pri_add1":"TEST 7607 172 ST NW A408","pri_add2":"TEST APT A408","pri_municipality":"TEST Edmonton","pri_province":"ON","pri_postcode":"T5T2P2","pri_country":"CAN","pri_hphone":"780-999-0548","pri_wphone":"780-433-4729","pri_cphone":"519-555-1212","sec_email":"test@email.com","sec_add1":"TEST sec addy1","sec_add2":"TEST sec addy2","sec_municipality":"TEST mun","sec_province":"TEST prov","sec_postcode":"T5T2P2","sec_country":"CAN","sec_hphone":"780-999-0548","sec_wphone":"780-433-4729","sec_cphone":"519-555-1212"}]',
            placementcObj.Name,
            documentstoragecObj.Id
        );
        new CustomerStagingExcelFileProcessing(
            '[{"data_id":"0000000","pri_email":"test@email.com","pri_add1":"TEST 7607 172 ST NW A408","pri_add2":"TEST APT A408","pri_municipality":"TEST Edmonton","pri_province":"ON","pri_postcode":"T5T2P2","pri_country":"CAN","pri_hphone":"780-999-0548","pri_wphone":"780-433-4729","pri_cphone":"519-555-1212","sec_email":"test@email.com","sec_add1":"TEST sec addy1","sec_add2":"TEST sec addy2","sec_municipality":"TEST mun","sec_province":"TEST prov","sec_postcode":"T5T2P2","sec_country":"CAN","sec_hphone":"780-999-0548","sec_wphone":"780-433-4729","sec_cphone":"519-555-1212"}]',
            placementcObj.Name,
            documentstoragecObj.Id
        ); */
    }
}
