({
	doinit: function(component, event, helper) {
       
        helper.getUploadedFiles(component, event); 
        //helper.fetchDocType(component, helper, event);
        //helper.getPurposeMedia(component, event);
        //helper.getDocumentVisibility(component, event);
    },
    previewFile : function(component, event, helper) {
        helper.previewDocument(component, event);	
    }
})