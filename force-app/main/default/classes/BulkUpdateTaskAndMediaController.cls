public with sharing class BulkUpdateTaskAndMediaController {
    private ApexPages.StandardSetController standardController;
    Public string selectedname{get;set;}
    public Work_Assignment__c objEmp {get;set;}
    public list<selectoption> checkStatus{set;get;}
    public boolean showWorkAssRecordType {get;set;}
    public boolean showComplaintRecordType {get;set;}
    public boolean showMediaRecordType {get;set;}
    public boolean showExcelFileProcssingRecordType {get;set;}
    public List<Work_Assignment__c> selectedCases{get; set;}
    
    public BulkUpdateTaskAndMediaController(ApexPages.StandardSetController standardController){    
        this.standardController = standardController;
    }
    
    public PageReference bulkUpdatemethod(){ 
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        list<String> validWrkAssStatus = new list<String>();
        list<String> validAgencyComplaintStatus = new list<String>();
        list<String> validCFGComplaintStatus = new list<String>();
        list<String> validMediaStatus = new list<String>();
        list<String> validExcelFileProcessingStatus = new list<String>();
        Map<String,Id> rectordTypeCheck = new Map<String,Id>();
        
        validWrkAssStatus = portalSettings.Work_Assignment_Status__c.split(',');
        validAgencyComplaintStatus = portalSettings.Agency_Complaint_Status__c.split(',');
        validCFGComplaintStatus = portalSettings.CFG_Complaint_Status__c.split(',');
        validMediaStatus = portalSettings.Media_Status__c.split(',');
        validExcelFileProcessingStatus = portalSettings.Excel_File_Processing_Status__c.split(',');
        
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Work_Assignment__c'];
        for(RecordType recordType : recordTypes){
            rectordTypeCheck.put(recordType.DeveloperName, recordType.Id);
        } 
        system.debug('standardController' +standardController);
        // Get the selected records
        selectedCases = (List<Work_Assignment__c>) standardController.getSelected();
        
        checkStatus =  new list<selectoption>();
        checkStatus.add(new selectoption('None','None'));
        
        if(selectedCases!=null && !selectedCases.isEmpty()){
            if(selectedCases[0].RecordTypeId == rectordTypeCheck.get('CFG') ||
              selectedCases[0].RecordTypeId == rectordTypeCheck.get('Agency')){
                  showWorkAssRecordType=true;
                  showComplaintRecordType=false;
                  showMediaRecordType=false;
                  showExcelFileProcssingRecordType=false;
                for(String WrkAssStatus : validWrkAssStatus){           
                    checkStatus.add(new selectoption(WrkAssStatus,WrkAssStatus));
                    system.debug('checkStatus workAss::' +checkStatus);
                }
            }else if(selectedCases[0].RecordTypeId == rectordTypeCheck.get('CFG_Complaint')){
                  showWorkAssRecordType=false;
                  showComplaintRecordType=true;
                  showMediaRecordType=false;
                  showExcelFileProcssingRecordType=false;
                for(String CFGComplaintStatus : validCFGComplaintStatus){           
                    checkStatus.add(new selectoption(CFGComplaintStatus,CFGComplaintStatus));
                    system.debug('checkStatus complaint::' +checkStatus);
                }
            }else if(selectedCases[0].RecordTypeId == rectordTypeCheck.get('Agency_Complaint')){
                showWorkAssRecordType=false;
                  showComplaintRecordType=true;
                  showMediaRecordType=false;
                  showExcelFileProcssingRecordType=false; 
                for(String AgencyComplaintStatus : validAgencyComplaintStatus){           
                    checkStatus.add(new selectoption(AgencyComplaintStatus,AgencyComplaintStatus));
                    system.debug('checkStatus complaint::' +checkStatus);
                }
            }else if(selectedCases[0].RecordTypeId == rectordTypeCheck.get('CFG_Media') ||
                    selectedCases[0].RecordTypeId == rectordTypeCheck.get('Agency_Media')){
                  showWorkAssRecordType=false;
                  showComplaintRecordType=false;
                  showMediaRecordType=true;
                  showExcelFileProcssingRecordType=false;
                  for(String MediaStatus : validMediaStatus){           
                    checkStatus.add(new selectoption(MediaStatus,MediaStatus));
                    system.debug('checkStatus complaint::' +checkStatus);
                }
             }else if(selectedCases[0].RecordTypeId == rectordTypeCheck.get('CFG_Excel_Processing') ||
                    selectedCases[0].RecordTypeId == rectordTypeCheck.get('Agency_Excel_Processing')){
                  showWorkAssRecordType=false;
                  showComplaintRecordType=false;
                  showMediaRecordType=false;
                  showExcelFileProcssingRecordType=true;
                  for(String ExcelFileProcessingStatus : validExcelFileProcessingStatus){           
                    checkStatus.add(new selectoption(ExcelFileProcessingStatus,ExcelFileProcessingStatus));
                    system.debug('checkStatus complaint::' +checkStatus);
                }
              }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select records from list view before you proceed.'));
        }
        system.debug('checkStatus outside if::' +checkStatus);
        // Update records       
        for(Work_Assignment__c selectedCase : selectedCases){
            objEmp = new Work_Assignment__c(RecordTypeId = selectedCase.RecordTypeId);
            selectedCase.Status__c = selectedCase.Status__c;
        }     
        return null;         
    }
    
    public PageReference updateCases(){     
        List<Work_Assignment__c> selectedCases = (List<Work_Assignment__c>) standardController.getSelected();
        List<Work_Assignment__c> StatusUpdate = new List<Work_Assignment__c>();
        
        if(selectedname == 'None' || selectedname == NULL){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select new status value before you proceed.'));
            return null; 
        }
        system.debug('selectedCases test::' +selectedCases);
        for(Work_Assignment__c selectedCase : selectedCases){
                selectedCase.Status__c = selectedname;
        }
        //update StatusUpdate;
         return standardController.save();
    }
    
    public pageReference Redirect(){
        PageReference retURL = new PageReference('/apex/BulkUpdateTaskAndMedia');
        retURL.setRedirect(true);
        return retURL;
    }
        
}