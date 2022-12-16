/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to Reject Invalid Submission on Product
*  @author : A5E Consulting
*  @date : 30/05/2022

*************************************************************************************************/
public class RejectInvalidSubmissionController {
    
    public String productID {get;set;}
    public Product__c product {get;set;}
    public Boolean notMarkedForInvalid {get;set;}
    public Boolean alreadyRejectedState {get;set;}
    public Boolean disableConfirmBtn {get;set;}
    public map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    public static final String Placement_Status_Code = '100010';
    public static Map <String, Id> WorkAssRecTypeMap;
    
    public static Map <String, Id> getCaseRecorTypeMap(){
        Map <String, Id> WorkAssRecTypeMap = new Map<String, Id>();
        //Fetch Record Type list of Case
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Work_Assignment__c'];
        for(RecordType recordType : recordTypes){
            WorkAssRecTypeMap.put(recordType.DeveloperName, recordType.Id);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.DeveloperName);
        }    
        return WorkAssRecTypeMap;
    }
    
    static{
        WorkAssRecTypeMap = getCaseRecorTypeMap(); 
    }
    
    public RejectInvalidSubmissionController(ApexPages.StandardController stdController) {
        productID =  ApexPages.currentPage().getParameters().get('id'); 
        product = [Select Id,Name,Status__c,Sub_Status__c,Placement_Status__c,Collection_Agency_Placement__c,
                   Invalid_Submission__c,Invalid_Submission_Reason__c,Timestamp_Of_Invalid_Submission__c,
                   Invalid_Submission_Initiated_By__c
                   from Product__c
                   Where ID= :productID];
        
        List<Placement_Status_Code_Mapping__c> listStatusCodes = [SELECT Parent_Status__c,Placement_Status_Code__c,
                                                                  Status__c,Sub_Status__c 
                                                                  FROM Placement_Status_Code_Mapping__c
                                                                  WHERE Placement_Status_Code__c = :Placement_Status_Code
                                                                  ORDER BY Status__c ASC NULLS LAST];
        mapRecallCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        for(Placement_Status_Code_Mapping__c mapping : listStatusCodes){
            system.debug('mapping.Status__c: '+mapping.Status__c);
            system.debug('mapping.Sub_Status__c: '+mapping.Sub_Status__c);
            system.debug('mapping.Placement_Status_Code__c: '+mapping.Placement_Status_Code__c);
            mapRecallCodeStatus.put(mapping.Placement_Status_Code__c, mapping);
        }
        alreadyRejectedState = false;
        if(product.Invalid_Submission__c == false){
            notMarkedForInvalid = true;    
        }
        if(product.Placement_Status__c == Placement_Status_Code){
            alreadyRejectedState = true;
        }
        
        
    } 
    public PageReference confirmRejection(){
        disableConfirmBtn = true;
        system.debug('disableConfirmBtn '+disableConfirmBtn);
        product.Placement_Status__c =  Placement_Status_Code;
        product.Invalid_Submission_Reason__c = null;
        product.Timestamp_Of_Invalid_Submission__c = null;
        product.Invalid_Submission_Initiated_By__c = null;
        product.Invalid_Submission__c = false;
        
       if(!mapRecallCodeStatus.isEmpty()){
       		product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
            product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
        }
       ProductTriggerHandler.runProductTrigger = false;
       update product;
       PortalProductProcessingAPI.processProduct(product.ID);
       ProductTriggerHandler.runProductTrigger = true;
        
        //Create Task record and assign it to Agency       
            Work_Assignment__c workAssignment = new Work_Assignment__c();       
            workAssignment.Title__c = 'Invalid Submission Rejected for ' + product.Name;
            workAssignment.Description__c = 'Invalid Submission Rejected for ' + product.Name;
           // workAssignment.RecordTypeId = '0127g000001QfozAAC';
         	workAssignment.RecordTypeId = WorkAssRecTypeMap.get('CFG');
            workAssignment.Purpose__c = 'Query';
            workAssignment.Sub_Purpose__c = 'Invalid Submission';
            workAssignment.Product__c =  product.id;
            workAssignment.Assign_To__c = 'Agency';
            workAssignment.Placement_Agency__c = product.Collection_Agency_Placement__c;
            insert workAssignment; 
        
        return  backToProduct();
    }
    public pageReference backToProduct(){
        PageReference pageRef = new PageReference('/'+productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
}