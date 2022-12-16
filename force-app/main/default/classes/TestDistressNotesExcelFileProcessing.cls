@isTest
private class TestDistressNotesExcelFileProcessing {
	@isTest static void testMethod1() {
        API_Call_Details__c apiCallDetails = new API_Call_Details__c();
        apiCallDetails.name = 'Agency Portal API';
        apiCallDetails.API_Request_Timeout__c = 90000;
        apiCallDetails.PDF_API_URL__c = 'https://api-agencies-uat.canaccede.com/api/Document/';
        apiCallDetails.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        apiCallDetails.Client_ID__c = 'f647baee-683f-4e34-95f0-611a3482baae';
        apiCallDetails.Client_Secret__c = '.uE7Q~glV.Ks.SacXYsRRRnWbXAT~2dxHkiPW';
        apiCallDetails.Proxy_Client_ID__c = 'd4849d4d-eb42-4933-9403-7c512af05dd5';
        apiCallDetails.Scope_Prefix__c = 'https://canaccedeb2ctestdev.onmicrosoft.com/';
        apiCallDetails.Scope_Suffix__c = '/.default';
        apiCallDetails.Tenand_ID__c = '3724313f-5b9b-496f-b8e9-411e00dd3e02';
        insert apiCallDetails;
        
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        portalSettings.Work_Assignment_Status__c = 'Requested,In Progress';
        portalSettings.Agency_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.CFG_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.Media_Status__c = 'Requested,In Progress';
        portalSettings.Excel_File_Processing_Status__c = 'Requested,In Progress,Completed';
        portalSettings.Valid_Payment_Types__c='3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;

        

		Placement__c placementcObj = new Placement__c (
			Name = '12435'
		);
		insert placementcObj;
        
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

		 Document_storage__c documentstoragecObj = new Document_storage__c (
			Creator__c = 'test value', 
			Uploaded_By__c ='Internal User', 
			Work_Assignment__c = wrkAss.Id
		);
		insert documentstoragecObj;
        
        DistressNotesExcelFileProcessing cs = new DistressNotesExcelFileProcessing('[{"data_id":"2500P316","title":"Test Distressed Notes","body":"Testing using file processing","visibility":"CFG only"}]',documentstoragecObj.Id);
		 
	}

	@isTest static void testMethod2() {
		// code_block	
	}
}