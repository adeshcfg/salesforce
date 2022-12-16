/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a trigger handler class for Application__c object 
 *  @author : A5E Consulting
 *  @date : 04/15/2016
 
 *************************************************************************************************/
 
public class ApplicationTriggerHandler {
    
    public static boolean runApplicationLoadTrigger = true; 
    
    //Line Break
    public static String lBrk = '</br>';
    
    //Validation Rules    
    public void handleBeforeUpdate(List<Application__c> appsNew, Map<Id, Application__c> oldMap) {
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        
        String profileName = Utilities.getUserProfile();
        Boolean isAdmin = false;
        Boolean isCSR = false;
        
        if(profileName.equalsIgnoreCase('CFG - Application Admin') ){
            isAdmin = true;
        }
        
        if(profileName.equalsIgnoreCase('CFG - CSR')){
            isCSR = true;
        }
        
        //Validation Error message
        String valMsg = '';
        
        //Uneditable fields
        Map<String, String> uneditableFieldsMap;
        Set<String> uneditableFieldsName = new Set<String>();        
        if(isAdmin){
            //uneditableFieldsMap = getApplicationFieldsets('UnEditableFieldAdmin');
            //uneditableFieldsName = uneditableFieldsMap.keySet();
        }
        else{
            //uneditableFieldsMap = getApplicationFieldsets('UnEditableFieldsCSR');
            //uneditableFieldsName = uneditableFieldsMap.keySet();            
        }
        
        //All Fields
        Map<String, Schema.SObjectField> applnFieldsMap = Schema.SObjectType.Application__c.fields.getMap(); 
        Set<String> applnFields = applnFieldsMap.keySet();
        
        //Ignore Fields
        Map<String, String> ignoreFieldsMap = getApplicationFieldsets('IgnoreFields'); 
        Set<String> ignoreFields = ignoreFieldsMap.keySet();
        
        for(Application__c appNew : appsNew){ //For Application__c appNew - Start
            
            //Current Application
            Application__c appOld = oldMap.get(appNew.id);
            
            if(appOld.CSR_Reviewed__c != appNew.CSR_Reviewed__c && appNew.CSR_Reviewed__c == True ){
                appNew.Application_Status__c = 'Completed - Credit Card';
            }
            
            //Do not allow edit for fields when application is in 'Completed' Status
            if(appOld.Application_Status__c == 'Completed - Credit Card'){
                Map<String, String> uneditableFieldsCompleteMap = getApplicationFieldsets('Uneditable_Fields_for_Completed');
                Set<String> uneditableFieldsCompleteName = uneditableFieldsCompleteMap.keySet();
                Boolean nonEditableComplete = false;
                for(String uneditableFieldName : uneditableFieldsCompleteName){             
                    if(appNew.get(uneditableFieldName) != (appOld.get(uneditableFieldName))){                   
                        valMsg = valMsg + 'You cannot change :'+uneditableFieldsMap.get(uneditableFieldName) +  lBrk;
                        system.debug('field lable : ' + uneditableFieldName);
                        nonEditableComplete = true;
                    }               
                }
            }
            
            //If Application is moved to Declined and if Lender Approved Amount is missing, 
            //set Lender Approved Amount to zero on Application record
            if(appNew.Application_Status__c == 'System Declined' || appNew.Application_Status__c == 'Analyst Declined') {
                if(appNew.Lender_Approved_Amount__c == null){
                    appNew.Lender_Approved_Amount__c = 0;
                }
            }
            
            //to capture application status changed date
            if(appNew.Application_Status__c != appOld.Application_Status__c){
                appNew.Application_Status_Last_Changed_Date__c = system.now();
            }
            
            //Final validation error message    
            if(String.isNotBlank(valMsg)){
                valMsg = ' Check below Validation Messages' + lBrk + valMsg;            
                appNew.addError(valMsg, false);
            }
            
        }  //For Application__c appNew end
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
    
    }  
    
    //Returns all application object field sets 
    public static Map<String, String> getApplicationFieldsets(string fieldSetLabel){
        
        Map<String, String> fieldsNameLabel = new Map<String, String>();
        
        Map<String, Schema.FieldSet> applnFieldsSets = Schema.SObjectType.Application__c.fieldSets.getMap();
        
        List<Schema.FieldSet> listApplnFieldSets = applnFieldsSets.values();
        
        for(Schema.FieldSet applnFieldSet : listApplnFieldSets){
            
            if(fieldSetLabel == applnFieldSet.getLabel()){
                
                for(Schema.FieldSetMember field : applnFieldSet.getFields()) {    
                    fieldsNameLabel.put(field.getFieldPath(), field.getLabel());
                }               
                break;
            }
        }
        
        return fieldsNameLabel;    
    }     
}