/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class for Insolvency Account Record Type Selection
 *  @author : A5E Consulting
 *  @date : 05/08/2018
 
 *************************************************************************************************/
 
 public class InsolvencyAccountRecordTypeController{
    
    public List<SelectOption> recordTypeOptions {get;set;}  
    public String selectedrecordType {get;set;}
    
    //Constructor
    public InsolvencyAccountRecordTypeController(){
        
        //Populate Record Type options Picklist
        recordTypeOptions = getEligibleRecordTypeOptions();
        
        //Populate pre-selected record type
        Map <String, Id> insAccntRecorTypeIDNameMap = InsolvencyUtil.getInsAccntRecorTypeNameIdMap();
        selectedrecordType = insAccntRecorTypeIDNameMap.get(getRecordTypeToWorkOn());
    }
    
    //Redirect to Record type selection or create page
    public PageReference redirPage(){
        try {
            
            String redirectUrl = '/' +Insolvency_Account__c.SObjectType.getDescribe().getKeyPrefix() + '/e';
            PageReference redirectPg = new PageReference(redirectUrl);
            
            Map<String, String> paramMap = redirectPg.getParameters();
            paramMap.putAll(ApexPages.currentPage().getParameters()); 
            paramMap.put('RecordType', selectedrecordType);
            paramMap.put('nooverride', '1');                       
            redirectPg.setRedirect(true);
            return redirectPg;          
        }
        catch(Exception exp){  
            return null;
        }    
    } 
    
    //Get Eligible Insolvency Account Record Type Options
    public List<SelectOption> getEligibleRecordTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        Map <Id, String> insAccntRecorTypeIDNameMap = InsolvencyUtil.getInsAccntRecorTypeIdNameMap();
        for(Id recordTypeId : insAccntRecorTypeIDNameMap.keySet()){
            options.add(new SelectOption(recordTypeId, insAccntRecorTypeIDNameMap.get(recordTypeId)));
        }
        
        return options;
    }
    
    //Get Eligible Insolvency Account Record Type Options
    public String getRecordTypeToWorkOn() {
        String recordTypeToWorkOn = '';
        
        String recordToWorkOn = getRecordToWorkOn();
        System.debug('recordToWorkOn :'+recordToWorkOn);
        If(Test.isRunningTest()){
            recordToWorkOn = 'Scotia Bank';
        }
        if(String.isNotBlank(recordToWorkOn)){
            Map<String, String> workOnRecordTypeMap = New Map<String, String>();
            
            workOnRecordTypeMap.put('Scotia Bank', 'Scotia Bank Insolvency Account');
            workOnRecordTypeMap.put('SPL', 'SPL Insolvency Account');
            workOnRecordTypeMap.put('SDA', 'SDA Insolvency Account');
            workOnRecordTypeMap.put('Canaccede', 'Canaccede Insolvency Account');
            workOnRecordTypeMap.put('Fidem', 'Fidem Insolvency Account');
            workOnRecordTypeMap.put('Fairstone', 'Fairstone Insolvency Account');
            workOnRecordTypeMap.put('Goeasy', 'Easyfinancial Insolvency Account');
            workOnRecordTypeMap.put('Canadian Tire', 'Canadian Tire Insolvency Account');
            workOnRecordTypeMap.put('Money Mart', 'Money Mart Insolvency Account');
            workOnRecordTypeMap.put('Flexiti', 'Flexiti Insolvency Account');
            recordTypeToWorkOn = workOnRecordTypeMap.get(recordToWorkOn);
            
            System.debug('recordTypeToWorkOn :'+recordTypeToWorkOn);
        }
        
        return recordTypeToWorkOn;
    }
    
    //Get Eligible Insolvency Account Record Type Options
    public String getRecordToWorkOn() {
        return [Select Id, To_Work_On__c from User where Id=:userinfo.getUserId()].To_Work_On__c;
    }
}