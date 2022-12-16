({
	doinit: function(component, event, helper) {
        helper.getUploadedFiles(component, event); 
    },
    
    openDocumentRecordNow: function(component, event, helper){
        helper.openDocumentRecord(component, event);
    },
    previewFile : function(component, event, helper) {
        helper.previewDocument(component, event);	
    }
})