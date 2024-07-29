/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Bulk Product Status Update from agency portal
*  @author : A5E Consulting
*  @date : 18/08/2021

*************************************************************************************************/
public class PortalProductStatusBulkProcessingUtil {
    public static String PLACEMENT_ACTIVE_CODE = '301000';
    public static String PLACEMENT_ACTIVE = 'Placement (3); Active';
	public static Map<String, Map<String, String>> productIdAgencyInfoMap = new Map<String, Map<String, String>>();
    public static Application_Config_Settings__c applicationConfigSetting = Application_Config_Settings__c.getOrgDefaults(); 
    
    public class ProductBulkAPIWrapper {
        public String accountList;
        public String PlacementStatus;
        public String AssignmentDate;
        public String Remark;
        public String Placement_Identifier;
        public String Type;
        public String SubmittedBy;
    }

    public static String processBulkProducts(String postJSON) {
        map<String, string> mapAgencyUser = new Map<String, string>();
        map<String, Judgment_product_codes_mapping__c> mapJudgment = Judgment_product_codes_mapping__c.getAll();
        map<String, string> mapJudgmentCodes = new map<String, string>();                                            
		List<Account_Judgment__c> accJudgStatusUpdateList = new List<Account_Judgment__c>();
        Map<String, ID> mapProductJudgment = new Map<String, ID>();
        List<Judgment__c> judgmentToUpdateList;
        ProductBulkAPIWrapper requestWrapper = (ProductBulkAPIWrapper) JSON.deserialize(postJSON, ProductBulkAPIWrapper.class);
        List<String> listProductNames = new List<String>();
        if (String.isNotBlank(requestWrapper.accountList)) {
            listProductNames = requestWrapper.accountList.split(',');
        }
        
        for(Judgment_product_codes_mapping__c judgmentCodes : mapJudgment.values()){
            mapJudgmentCodes.put(judgmentCodes.Judgment_Legal_Status__c+judgmentCodes.Judgment_Legal_Sub_Status__c, judgmentCodes.Codes__c);
        }
        
        List<String> listProductStatus = new List<String>();
        //split PlacementStatus
        if (String.isNotBlank(requestWrapper.PlacementStatus)) {
            listProductStatus = requestWrapper.PlacementStatus.split(',');
        }
        map<string, string> mapStatuses = new Map<string, string>();
        if (requestWrapper.Type == 'Allocation') {
            // Rasmitha : Checking if its from Allocation Confirm
            if (listProductStatus.get(0) == '100010') {
                for (Integer i = 1; i < listProductNames.size(); i++) {
                    listProductStatus.add('100010'); // Updated from 1000010 to 100010 - Bug #4445
                }
            }
        } else {
            if (listProductNames.size() != listProductStatus.size()) {
                return 'Count of status and product are different';
            }
        }
        //created map for product name and product status
        for (Integer i = 0; i < listProductNames.size(); i++) {
            mapStatuses.put(listProductNames.get(i), listProductStatus.get(i));
        }
        ID placementID;
        if (requestWrapper.Type == 'Allocation' && String.isNotBlank(requestWrapper.Placement_identifier)) {
            placementID = [SELECT ID FROM Placement__c WHERE Name = :requestWrapper.Placement_identifier LIMIT 1].ID;
        }

        List<Placement_Status_Code_Mapping__c> listStatusCodes = [
            SELECT Parent_Status__c, Placement_Status_Code__c, Status__c, Sub_Status__c, Data_Status_Code__c, Data_Status_Description__c
            FROM Placement_Status_Code_Mapping__c
            WHERE Placement_Status_Code__c = :requestWrapper.PlacementStatus
            LIMIT 1
        ];
        map<String, Placement_Status_Code_Mapping__c> mapStatusCodes = Placement_Status_Code_Mapping__c.getAll();
        for (Agency_User__c Agency_UserName : [
            SELECT First_Name__c, Last_Name__c, Email_Address__c
            FROM Agency_User__c
            WHERE Email_Address__c = :requestWrapper.SubmittedBy
        ]) {
            mapAgencyUser.put(Agency_UserName.Email_Address__c, Agency_UserName.First_Name__C + ' ' + Agency_UserName.Last_Name__c);
        }
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();

        Placement__c placement = [
            SELECT ID, Name
            FROM Placement__c
            WHERE Name = :'9999'
            LIMIT 1
        ];
        map<String,String> mapJudgmentCode = new map<String,String>();
		for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c, Product__r.Name,
                                               Judgment__r.Legal_Status__c,Judgment__r.Legal_Sub_Status__c
                                               	FROM Account_Judgment__c
                                                  WHERE  Product__r.Name IN :listProductNames
                                                  AND Status__c = 'Active']){
                mapProductJudgment.put(accJudgment.Product__c, accJudgment.id);
                mapJudgmentCode.put(accJudgment.Product__c,mapJudgmentCodes.get(accJudgment.Judgment__r.Legal_Status__c+accJudgment.Judgment__r.Legal_Sub_Status__c));                                                                                  
        }
        
        list<Product__c> listProductsToUpdate = new List<Product__c>();
        list<Placement_History__c> listPlacementHistoryToCreate = new List<Placement_History__c>();
        list<Product__c> listProducts = [
            SELECT
                ID,
                Name,
                Collection_Agency_Placement__c,
                Assignment_Date__c,
                Collection_Agency__c,
                Status__c,
                Pool_Name__c,
                Invalid_Submission_Reason__c,
                Allocated_Amount_Fees__c,
                Allocated_Amount_Interest__c,
                Allocated_Amount_Principal__c,
                Timestamp_Of_Invalid_Submission__c,
            	Placement_Status__c
            FROM Product__c
            WHERE Name IN :listProductNames
        ];
        list<Id> listPoolId = new List<Id>();
        list<Placement_History__c> listPlacementHistToInsert = new List<Placement_History__c>();
        List<Pool__c> poolRecordList = new List<Pool__c>();
        List<ID> prodIds = new List<ID>();
        Map<ID, Product__c> mapProd = new Map<ID, Product__c>();
        Map<ID, String> placeStatus = new Map<ID, String>();
        for (Product__c product : listProducts) {
            listPoolId.add(product.Pool_Name__c);
            mapProd.put(product.Id, product);
            //set placement status dynamically
            product.Placement_Status__c = mapStatuses.get(product.name); //requestWrapper.PlacementStatus;
            //Set Status and Sub Status fields on product
            if (!listStatusCodes.isEmpty()) {
                product.Status__c = listStatusCodes[0].Parent_Status__c + ' - ' + listStatusCodes[0].Status__c;
                product.Sub_Status__c = listStatusCodes[0].Sub_Status__c;
            }
            if (requestWrapper.Type == 'Recall' && String.isBlank(requestWrapper.Placement_identifier)) {
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                placeStatus.put(product.ID, mapStatuses.get(product.name));
                prodIds.add(product.ID);
                //ticket 4333 - Agency User Unable to accept recalls when completing multiple accounts : added by satyajit
                if (product.Status__c != null) {
                    if (product.Status__c.startsWith('Pending Recall')) {
                        product.Status__c = product.Status__c.Replace('Pending Recall', 'Recall');
                    }
                }
				
                //Ticket 6430 : Point 2
                if(mapJudgmentCode.containsKey(product.id) && System.Label.Exclude_Judgment_Codes.contains(mapJudgmentCode.get(product.id)) 
                   && mapProductJudgment.containsKey(product.id)){
                       Account_Judgment__c accJudgment = new Account_Judgment__c();
                       accJudgment.id =  mapProductJudgment.get(product.id);  
                       accJudgment.Status__c = 'Inactive';
                       accJudgStatusUpdateList.add(accJudgment);
                   }
                if (product.Placement_Status__c.startsWith('8')) {
                    product.Placement_Status__c = product.Placement_Status__c.Replace('8', '9');
                }

                if (
                    mapStatusCodes.containsKey(product.Placement_Status__c) &&
                    String.isNotBlank(mapStatusCodes.get(product.Placement_Status__c).Data_Status_Code__c)
                ) {
                    product.Product_Status__c = mapStatusCodes.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapStatusCodes.get(product.Placement_Status__c).Data_Status_Description__c;
                } else {
                    product.Product_Status__c = '110000';
                    product.Data_Status_Description__c = 'Pending Allocation (1); Recalled';
                }
                product.Placement_Status__c = null;
                product.Status__c = null;
                product.Sub_Status__c = null;
                //product.Collection_Sub_Status__c = null; Rasmitha : 27-Dec as per #4177 Collection Sub Status should not get blank on recall
                product.External_Status_Current__c = null;
                
                productIdAgencyInfoMap.put(
                    product.Id,
                    new Map<String, String>{
                        'Agency' => String.valueOf(product.Collection_Agency__c),
                            'AgencyPlacement' => product.Collection_Agency_Placement__c
                            }
                );
            }
            if (requestWrapper.Type == 'Allocation' && String.isNotBlank(requestWrapper.AssignmentDate)) {
                product.Collection_Agency__c = Decimal.valueOf(requestWrapper.Placement_identifier);
                product.Collection_Agency_Placement__c = placementID;
                product.Assignment_Accepted_Date__c = Date.Today();
                product.Product_Status__c = PLACEMENT_ACTIVE_CODE;
                product.Data_Status_Description__c = PLACEMENT_ACTIVE;
            }
            if (requestWrapper.Type == 'InvalidSubmission') {
                product.Invalid_Submission__c = true;
                if (String.isNotBlank(requestWrapper.Remark)) {
                    product.Invalid_Submission_Reason__c = requestWrapper.Remark;
                }
                if (String.isNotBlank(requestWrapper.AssignmentDate)) {
                    product.Timestamp_Of_Invalid_Submission__c = Datetime.now();
                }

                if (String.isNotBlank(requestWrapper.SubmittedBy)) {
                    product.Invalid_Submission_Initiated_By__c = mapAgencyUser.get(requestWrapper.SubmittedBy);
                }
                //In case of Invalid Submission is Rejected new Task is to be created
                Work_Assignment__c workAssignment = new Work_Assignment__c();
                workAssignment.Requested_Date__c = Date.today();
                workAssignment.Title__c = 'Invalid Submission for Account ' + product.Name;
                workAssignment.Description__c = 'Account - ' + product.Name + ' has been marked as Invalid Submission from ' + product.Collection_Agency__c;
                workAssignment.Status__c = 'Requested';
                workAssignment.Assign_To__c = 'Agency';
                //workAssignment.Priority__c = 'High';
                workAssignment.Purpose__c = 'Query';
                workAssignment.Sub_Purpose__c = 'Invalid Submission';
                workAssignment.Placement_Agency__c = product.Collection_Agency_Placement__c;
                workAssignment.Product__c = product.ID;
                workAssignment.Comment_Reply__c =
                    'Invalid Submission Remark By Agency : ' +
                    product.Invalid_Submission_Reason__c +
                    'Invalid Submission Timestamp : ' +
                    product.Timestamp_Of_Invalid_Submission__c;
            }
            listProductsToUpdate.add(product);
        }
        DistressedUtilities.updatePlacementHistory_New(prodIds, placeStatus);

        //Update Active settlement to inactivate
        DistressedUtilities.UpdateSettlement(prodIds);
        List<Pool__c> poolRecord = [
            SELECT id, Name, Placement_agency_lookup__c, Placement_Agency__c
            FROM Pool__c
            WHERE id = :listPoolId
        ];
        for (Pool__c pRecord : poolRecord) {
            if (requestWrapper.Type == 'Recall' && String.isBlank(requestWrapper.Placement_identifier)) {
                Pool__c pRecord1 = new Pool__c();
                pRecord1.Id = pRecord.Id;
                pRecord1.Placement_Agency__c = null;
                pRecord1.Placement_agency_lookup__c = null;
                poolRecordList.add(pRecord1);
            }
        }
        PoolTriggerHandler.runPoolTrigger = false;
        update poolRecordList;
        PoolTriggerHandler.runPoolTrigger = true;
        if (!listProductsToUpdate.isEmpty()) {
            try {
                ProductTriggerHandler.runProductTrigger = false;
                //commented line 188 for CPU Time Limit
                //update listProductsToUpdate;
                //added below for CPU Time Limit
                System.enqueueJob(new BulkDmlQueueable(listProductsToUpdate, 0, 'Update'));
                //end CPU Time Limit
                ProductTriggerHandler.runProductTrigger = true;
                
                update accJudgStatusUpdateList;
                
                if(productIdAgencyInfoMap.values() <> NULL){
                    judgmentToUpdateList = ProductRecallIndividualController.updateJudgmentAgency(productIdAgencyInfoMap);
                    if (!judgmentToUpdateList.isEmpty()) {
                        JudgmentTriggerHandler.runJudgmentTrigger = false;
                        //bypass judgment validation rule
                        applicationConfigSetting.Bypass_Judgement_Validation__c = false;
                        update applicationConfigSetting;
                        Database.update(judgmentToUpdateList);
                        //bypass judgment validation rule
                        applicationConfigSetting.Bypass_Judgement_Validation__c = true;
                        JudgmentTriggerHandler.runJudgmentTrigger = true;
                        update applicationConfigSetting;
                       Database.executeBatch(new JudgmentAPIBatch(judgmentToUpdateList,null,null,'Account Status Update File'), 50);
                    } 
                }
                
                return 'Success';
            } catch (Exception ex) {
                System.debug(ex.getStackTraceString());
                return ex.getMessage();
            }
        } else {
            return 'No Products to process found in Salesforce';
        }
    }
}