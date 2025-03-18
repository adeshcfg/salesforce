({
    doinit: function (component, event, helper) {
        // alert ("@@@@@@@@@@@@SobjectName = "+component.get("v.sObjectName"));

        helper.getUploadedFiles(component, event);
        helper.fetchDocType(component, helper, event);
        helper.getPurposeMedia(component, event);
        helper.getDocumentVisibility(component, event);
    },
    openDocumentRecordNow: function (component, event, helper) {
        helper.openDocumentRecord(component, event);
    },
    //Added by Rajesh
    /*  proxyopenDocumentRecordNow: function(component, event, helper){
        helper.openDocumentRecord(component, event);
        
    },    */
    uploadAttch: function (component, event, helper) {
        var doclen = component.find("fileId").get("v.files");
        if (doclen != null && doclen.length > 0) {
            var newDocumentType = component.find("documentType").get("v.value");
            var current_selected_offer;

            /*var existingOffers = component.get("v.offers"); 
           
            for(var i = 0; i < existingOffers.length; i++){
                
                if(existingOffers[i].Id == component.find("offerIdMain").get("v.value")){
                    current_selected_offer = existingOffers[i];
                    break;
                }
            }*/

            //   console.log('@@current_selected_offer '+JSON.stringify(current_selected_offer));
            var existingLetters = component.get("v.files");
            var allowUploadLetter = true;

            /*for(var i = 0; i < existingLetters.length; i++){
                console.log('@@INDEX'+i);
                if(existingLetters[i].Document_Type__c == newDocumentType){
                    
                    var oldOffer = existingLetters[i].Offer__r;
                    if(oldOffer != undefined){
						console.log('oldOffer=='+JSON.stringify(oldOffer));
                        // Letter alaready upload for the selected offer - Duplicate letter for same offer
                        if(oldOffer.Id == current_selected_offer.Id){
                            // 680 - Conditional Release Letter and Final Release Letter - Conditions and Offer List
                            allowUploadLetter = true;
                            helper.showToast(component,event, 'Existing '+newDocumentType+' will be replace for '+oldOffer.Name, 'success');                            
							
                            //allowUploadLetter = false;
                            //helper.showToast(component,event, '@Error 1 '+newDocumentType+' aready avalilabe for offer '+oldOffer.Name);
							   										console.log('@Info '+newDocumentType+' aready avalilabe for offer '+oldOffer.Name);
                            break;
                        }
                        // Check if any existing offered amount (Loan Amount Conditional) selected offer Offered Amount
                        else if( oldOffer.Loan_Amount_Offered__c == current_selected_offer.Loan_Amount_Offered__c){
                            allowUploadLetter = false;
                            helper.showToast(component,event, '@Error 2 '+newDocumentType+' aready avalilabe for offered amount '+oldOffer.Loan_Amount_Offered__c);
							   										console.log('@Error '+newDocumentType+' aready avalilabe for offered amount '+oldOffer.Loan_Amount_Offered__c);
                            break;
                        }
                            // Check if customer request amount ($ Amount of Loan Requested) is greater than offered amount (Loan Amount Conditional) 
                         else if(current_selected_offer.Settlement_Amount__c < 
                                 current_selected_offer.Loan_Amount_Offered__c){
                            allowUploadLetter = false;
                            helper.showToast(component,event, '@Error 3 '+newDocumentType+' aready avalilabe for offered amount '+current_selected_offer.Settlement_Amount__c);
							   										console.log('@Error '+newDocumentType+' aready avalilabe for offer amount '+current_selected_offer.Settlement_Amount__c);
                            break;
                        }	
                    }
                }
            }*/

            //console.log('@@ allowUploadLetter'+allowUploadLetter);

            //if(allowUploadLetter){
            helper.uploadHelper(component, event);
            //}
        } else {
            //helper.showToast(component,event, 'Please Select a Valid File');
        }
    },

    handleFilesChange: function (component, event, helper) {
        var fileName = "No File Selected..";
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]["name"];
        }
        component.set("v.fileName", fileName);
    },
    /*updateApplicationRec: function(component, event, helper) {
        helper.uploadAppRecHelper(component, event);	
    },*/
    previewFile: function (component, event, helper) {
        //helper.previewDocument(component, event);	//commented rajesh
        helper.previewDocumentProxy(component, event); //Added by Rajesh 4134
        ////Added by akansha..
        //helper.previewdocumentDirect(component, event);
    },
    /*deleteSelectedFile : function(component, event, helper) {
        helper.deleteSelectedFile(component, event);	
    },*/
    docSelect: function (component, event, helper) {
        var docType = component.find("documentType").get("v.value");
        if (docType == null || docType == "") {
            component.set("v.isDocTypeSelected", false);
            //console.log('@@@isDocTnooooypeSelected');
        } else {
            //console.log('@@@isDocTypeSelected');
            component.set("v.isDocTypeSelected", true);
        }
    },

    hideModel: function (component, event, helper) {
        component.set("v.showModal", false);
        var pdfContainer = component.get("v.pdfContainer");
        pdfContainer = [];
        component.set("v.pdfContainer", pdfContainer);
    },

    processFile: function (component, event, helper) {
        helper.processFileHelper(component, event);
    },
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var action = component.get("c.contentSize");
        action.setParams({ cid: documentId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var tempList = response.getReturnValue();
                if (tempList == "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: "File size can't be greater than 20 MB ",
                        type: "error"
                    });
                    toastEvent.fire();
                } else {
                    var send = [];
                    var documentids = [];
                    send = component.get("v.documents");
                    for (var i = 0; i < uploadedFiles.length; i++) {
                        var documentId = uploadedFiles[i].documentId;
                        var fileName = uploadedFiles[i].name;
                        documentids.push(documentId);
                        component.set("v.documentid", documentId);
                        component.set("v.fileName", fileName);
                        var ca = { Name: fileName, documentId: documentId };
                        send.push(ca);
                    }
                    component.set("v.documents", send);
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleSendFile: function (component, event, helper) {
        var docType = component.find("documentType").get("v.value");
        var docVisiType = component.find("documentVisibility").get("v.value");
        var isEvidence = component.find("evidence") ? component.find("evidence").get("v.checked") : false;
        if (docType == null || docType == "--None--" || docVisiType == "--None--") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: "documentType and documentVisibility is mandatory, please select",
                type: "error"
            });
            toastEvent.fire();
        } else if (component.get("v.documentid") != null && component.get("v.documentid") != "") {
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            var action = component.get("c.uploadFileToAzure");
            action.setParams({
                documentid: component.get("v.documentid"),
                parentId: component.get("v.recordId"),
                documentType: component.find("documentType").get("v.value"),
                sObjectName: component.get("v.sObjectName"),
                DocumentVisibility: component.find("documentVisibility").get("v.value"),
                isMediaRequest: component.get("v.isMediaRequest"),
                productId: component.get("v.productID"),
                isEvidence: isEvidence
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var tempList = response.getReturnValue();
                    if (tempList == "ERROR") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: "File size can't be greater than 20 MB",
                            type: "Warning"
                        });
                        toastEvent.fire();
                    } else {
                        component.set("v.documentid", "");
                        component.set("v.fileName", "No File Selected..");
                        helper.getUploadedFiles(component, event);
                        helper.getDocumentVisibility(component, event);
                        helper.fetchDocType(component, helper, event);
                        var spinner = component.find("mySpinner");
                        $A.util.toggleClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: "Please select the file before clicking upload button",
                type: "Error"
            });
            toastEvent.fire();
        }
    }
});
