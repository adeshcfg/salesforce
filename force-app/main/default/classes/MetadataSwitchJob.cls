/**************************************************************************************************
*
*  Class:   
*
*  @description : This class will activate and deactivate the Metadata on the given object
*  @author : A5E Consulting
*  @date : 16th November 2021
* 
*************************************************************************************************/
public class MetadataSwitchJob implements Schedulable {
    
    //Execute Job Scheduled
    public void execute(SchedulableContext sc) {
        //deactivate metadata
        deactivateProductMetadata();
        
        //call product data processing job
        Database.executeBatch(new DistressedProductProcessingBatch(), 200);
    }
    
    //to deactivate Metadata on Product object
    public static void deactivateProductMetadata(){
        system.debug('Block run');
        updateProductMetadata(true);
    }
    
    //to activate Metadata on Product object
    public static void activateProductMetadata(){
        updateProductMetadata(false);         
    }
    
    @future(callout=true)
    //to deactivate Metadata on Product object
    public static void updateProductMetadata(Boolean status){
        Disable_Metadata_Settings__c  disMeta = [Select Id,Disable_Product_Validation_WF__c  from Disable_Metadata_Settings__c where SetupOwnerId =:UserInfo.getUserId()];
		disMeta.Disable_Product_Validation_WF__c  = status;
		update disMeta;
         
        //Get validation rule on Product
        /*MetadataService.MetadataPort service;
        service = createService();
        // Read Validation Rules
        List<Metadata_Object__c> metaData = [select id, name, Object_Name__c, Metadata_Type__c, Metadata_Rule_Name__c
                                             from Metadata_Object__c where Object_Name__c = 'Product' AND Metadata_Type__c = 'ValidationRule'];
        
        for(Metadata_Object__c data : metaData){
            // MetadataService.ValidationRule validationRule;
            if(!Test.isRunningTest()) {
                MetadataService.ValidationRule validationRule =
                    (MetadataService.ValidationRule) service.readMetadata(data.Metadata_Type__c,
                                                                          new String[] {data.Metadata_Rule_Name__c}).getRecords()[0];
                validationRule.active = status;
                // Update Validation Rule
                
                handleSaveResults( service.updateMetadata(new MetadataService.Metadata[] { validationRule })[0]);
            }
        }
        
        //Get workflow rule on product
        List<Metadata_Object__c> metaData1 = [select id, name, Object_Name__c, Metadata_Type__c, Metadata_Rule_Name__c
                                              from Metadata_Object__c where Object_Name__c = 'Product' AND Metadata_Type__c = 'WorkflowRule'];
        for(Metadata_Object__c workflowData : metaData1){
            system.debug('workflowData:'+workflowData.Metadata_Rule_Name__c);
            //MetadataService.WorkflowRule workflowRule;
            list<MetadataService.WorkflowRule> workflowRuleList = new list<MetadataService.WorkflowRule>();
            if(!Test.isRunningTest()) {
                MetadataService.WorkflowRule workflowRule= (MetadataService.WorkflowRule) service.readMetadata(workflowData.Metadata_Type__c,
                                                                                                               new String[] {workflowData.Metadata_Rule_Name__c}).getRecords()[0];        
                workflowRule.active = status;
                // Update Workflow Rule
                system.debug('WorkflowRule:'+WorkflowRule);
                workflowRuleList.add(workflowRule);            
                handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { workflowRule })[0]);
            }
        }*/
    }
    
    //Create metadata service
    /*private static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    @testVisible
    //Helper method to interpret a SaveResult
    private static void handleSaveResults(MetadataService.SaveResult saveResult){
        system.debug('saveResult:::'+saveResult);
        // Nothing to see?
        if(saveResult==null || (saveResult != NULL && saveResult.success)){
        	return;   
        }
            
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add((saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                         'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(error.message + ' (' + error.statusCode + ').' +
                             ( error.fields!=null && error.fields.size()>0 ?
                              ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                system.debug('size error');
        }
        if(!saveResult.success)
            system.debug('Request failed with no specified error');
    }*/
    
}