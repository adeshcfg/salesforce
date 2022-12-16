({
    MAX_FILE_SIZE: 4500000, //Max file size 20 MB 
    
    CHUNK_SIZE: 750000,
    //CHUNK_SIZE: 1250000,      //Chunk Max size 750Kb 
    TWO_MB_FILE_SIZE: 2000000, // file size 2 MB 
    fetchDocType: function(component, event) {
        var action = component.get("c.documentTypeList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.listDocType", data);
                component.find("documentType").set("v.value",'--None--');
            }
            
        });
        $A.enqueueAction(action);
        
    },
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        var fileName = file.name;
        var filetype = file.type;   
        console.log('filetype : ',filetype);
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function 
        if(component.find("documentType").get("v.value") == '--None--'){
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Please select Document Type');
            return;
        }
        if(component.find("documentVisibility").get("v.value") == '--None--'){
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Please select Document Visibility');
            return;
        }
        /*if(component.get("v.isMediaRequest") == true){
            console.log('isMediaCheck',component.get("v.isMediaRequest"));
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'You can upload the documents only on associated Product records');
            return;
        }*/ 
        else if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }else if(file.size > self.TWO_MB_FILE_SIZE){
            fileName = 'L_'+fileName;
        }
            else if(file.size > self.TWO_MB_FILE_SIZE){
                fileName = 'L_'+fileName;
            }
                else if(filetype == "application/x-msdownload"){
                    component.set("v.showLoadingSpinner", false);
                    component.set("v.fileName", 'Alert : EXE file cannot be uploaded ');
                    return;
                }
        var fr = new FileReader();
        
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            
            fileContents = fileContents.substring(dataStart);
            //component.set("v.FileJSON", _response.getValue(fileContents));
            //console.log('result : ',component.get("v.FileJSON"));
            //console.log('@@coming inside.3.fileContents.'+fileContents);
            //console.log('@@fileContents'+encodeURIComponent(fileContents));
            
            //upload document
            var action = component.get("c.uploadFile");
            //console.log('offerId::'+component.find("offerId").get("v.value"));
            action.setParams({
                parentId: component.get("v.recordId"),
                fileName: fileName,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type,
                documentType: component.find("documentType").get("v.value"),
                sObjectName: component.get("v.sObjectName"),
                DocumentVisibility: component.find("documentVisibility").get("v.value"),
                isMediaRequest: component.get("v.isMediaRequest"),
                productId: component.get("v.productID") 
            });
            console.log('here.....');
            action.setCallback(this, function(response) {
				console.timeEnd('TimeTaken**');
                // store the response / Attachment Id   
                //console.log('here..1...'+JSON.stringify(response) );
                //console.log('response file upload::',response);
                var attachId = response.getReturnValue();
                console.log('attachId: ',attachId);
                var state = response.getState();
                console.log('state::',state);
                //console.log('here..1...'+JSON. stringify(state));
                if(attachId == null){
                    console.log('file upload failed');
                }
                 //alert('your File is uploaded error'+attachId);
                if(attachId != null){
                    console.log('file upload success');
                }
                if (attachId != null) {
                    //alert('your File is uploaded successfully');
                    component.find('notifLib').showToast({
                        "variant":"success",
                        "title": "File upload!",
                        "message": "File has been uploaded successfully."
                    }); 
                    component.set("v.showLoadingSpinner", false);
                    //removing css class
                    component.set("v.fileName", 'No File Selected..');
                    //removing css class logic end
                    
                    $A.get('e.force:refreshView').fire();
                    
                } 
                else{
               /*if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " , 
                                 errors);
                    }
                } else {
                    console.log("Unknown error");
                }
            }*/

                    component.find('notifLib').showToast({
                        "variant":"error",
                        "title": "File upload!",
                        "message": "File has been failed."
                    }); 
                    component.set("v.showLoadingSpinner", false);
                    
                    //removing css class
                    component.set("v.fileName", 'No File Selected..');
                    //removing css class logic end
                    
                    $A.get('e.force:refreshView').fire();
                }
                
                
                /*else if (state === "INCOMPLETE") {
                    this.showToast(component,event,"From server: " + response.getReturnValue(), "error");
                    //alert("From server: " + response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            console.log('message::'+errors[0].pageErrors[0].message);
                            let  message = errors[0].pageErrors[0].message;
                            this.showToast(component,event,message, "error");
                        }
                        
                        
                    } else {
                        console.log("Unknown error");
                        this.showToast(component,event,"Unknown error", "error");
                    }
                }*/
            });
			console.time('TimeTaken**');
            window.setTimeout(
    		$A.getCallback(function() {
                    $A.get('e.force:refreshView').fire();
    		}), 3000
			);
            $A.enqueueAction(action);
            
        };
        
        fr.readAsDataURL(file);
        
        
        /*
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);*/
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            console.log('state:',state);
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                console.log('startPosition:',startPosition);
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                console.log('endPosition:',endPosition);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    alert('your File is uploaded successfully');
                    component.set("v.showLoadingSpinner", false);
                    $A.get("e.force:refreshView").fire();
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                this.showToast(component,event,"From server: " + response.getReturnValue(),"error");
                //alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    let  message = errors[0].pageErrors[0].message;
                    this.showToast(component,event,message,"error");
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    getPurposeMedia :function(component, event){
        console.log('getUploadedFiles:::');
        var action = component.get("c.getPurpose");  
        action.setParams({  
            "recordId": component.get("v.recordId") 
        }); 
        action.setCallback(this,function(response){  
            console.log('run Block');
            var state = response.getState();
            if(state=='SUCCESS'){
                //console.log('ResponseForPurpose',response.getReturnValue());
                if(response.getReturnValue() != null){
                    component.set("v.isMediaRequest",true); 
                    component.set("v.productID", response.getReturnValue())
                    //console.log(component.get("v.isMediaRequest"));
                }
                
                if(response.getReturnValue() == 'True'){
                    component.set("v.isMediaRequest",true); 
                    console.log(component.get("v.isMediaRequest"));
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getDocumentVisibility :function(component, event){
        console.log('get picklist values:::');
        var action = component.get("c.getPickListValuesIntoList");  
        action.setCallback(this,function(response){  
            console.log('run Block');
            var state = response.getState();
            if(state=='SUCCESS'){
                if(response.getReturnValue().length > 0){
                    var result = response.getReturnValue(); 
                    
                    component.set("v.listDocVisibility",result); 
                    //console.log('result picklist::',result);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getUploadedFiles : function(component, event){
        console.log('getUploadedFiles:::');
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId": component.get("v.recordId") 
        }); 
        
        action.setCallback(this,function(response){  
            var state = response.getState();
            var filesFilter = [];
            if(state=='SUCCESS'){ 
                //console.log('FILES response.getReturnValue().length::'+response.getReturnValue().length);
                if(response.getReturnValue().length > 0){
                    var result = response.getReturnValue(); 
                    
                    component.set("v.files",result); 
                    console.log('result::',result);
                    for(var i = 0; i < result.length; i++){
                        //console.log('@@att=='+JSON.stringify(result[i]));
                        //console.log('type=='+JSON.stringify(result[i]));
                        //console.log('result[i].Work_Assignment__c !=',result[i].Work_Assignment__c);
                        //console.log('result[i].Work_Assignment_Purpose__c !=',result[i].Work_Assignment_Purpose__c);
                        //console.log('result[i].Parent_WorkAssignment_Product !=',result[i].Parent_WorkAssignment_Product__c);
                        if(result[i].Work_Assignment__c != ''
                           && result[i].Work_Assignment_Purpose__c == 'Media Request'
                           //&& result[i].Parent_WorkAssignment_Product__c != ''
                          ){
                            component.set("v.isMediaRequest",true); 
                            console.log(component.get("v.isMediaRequest"));
                        }    
                        /*if(result[i].Document_Type__c == component.get("v.SETTLEMENT_LETTER")){
                            component.set("v.settlementLetter",result[i]); 
                        }else if(result[i].Document_Type__c == component.get("v.RELEASE_LETTER")){
                            component.set("v.releaseLetter",result[i]); 
                        }
                        var offer = result[i].Offer__r;
                        if(offer != undefined){
                            console.log('offer=='+JSON.stringify(offer));
                            if(offer.Offer_Status__c == ''){
                                   
                            }
                        }*/
                    }
                    //console.log('files:::'+JSON.stringify(result));
                }
                
            }  
        });  
        
        /**var offerAction = component.get("c.getOfferRecords");  
        offerAction.setParams({  
            "applicationId": component.get("v.recordId") 
        });
        
        offerAction.setCallback(this,function(response){  
            var state = response.getState();
            console.log('State::'+state);
            if(state=='SUCCESS'){  
                console.log('response.getReturnValue().length::'+response.getReturnValue().length);
                
                if(response.getReturnValue().length > 0){

                    var result = response.getReturnValue();
                                        
                    console.log('@@result '+result.length);
                    
                    if(response.getReturnValue().length > 1)
                   	result.sort((a, b) => b.Offer_Status__c  - a.Offer_Status__c );
                    //result = result.sort((a,b) => (a.Loan_Amount_Offered__c < b.Loan_Amount_Offered__c) ? 1 : ((b.Loan_Amount_Offered__c < a.Loan_Amount_Offered__c || a.Loan_Amount_Offered__c === null) ? -1 : 0))
                    
                    component.set("v.selectedOffer",result[0]);
                    component.set("v.offers",result);
                    this.setReleaseLetterPicklist(component);
                    console.log("offer results::"+JSON.stringify(result));
                    
                }
            }else {
                
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                       message = errors[0].pageErrors[0].message;
                       this.showToast(component,event,message,"error");
                }
                // Display the message
                console.error(message);
                
            }  
        });*/     
        
        /*var adminCheckAction = component.get("c.isCurrentUserisPortalAdminUser");  
        
        adminCheckAction.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.isAgentAdmin",result);
                console.log("isAgentAdmin results::"+JSON.stringify(result));
            }  
        });
         
        $A.enqueueAction(adminCheckAction);
        $A.enqueueAction(offerAction);  */
        $A.enqueueAction(action);
    },
    
    handleinfoToast : function(component, event) {
        console.log('Inside Handle Toast');
        
    },
    /*uploadAppRecHelper:function(component, event){
         console.log('appAprvStatus::'+component.find("appAprvStatus").get("v.value") );
         console.log('offerIdMain::'+component.find("offerIdMain").get("v.value") );
         //console.log('uploadAppRecHelper::'+component.find("appAprvStatus").get("v.value") );

        
        var action1 = component.get("c.updateApplnOfferStatus");  
        action1.setParams({  
            "appAprvStatus": component.find("appAprvStatus").get("v.value") ,
            "appRecId":component.get("v.recordId"),
            "offerId": component.find("offerIdMain").get("v.value")
        });    
        console.log(JSON.stringify(action1.getParams()));
        action1.setCallback(this,function(response){  
            var state = response.getState(); 
            console.log('state::'+state);
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();
                if(result === true) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": "The record has been updated successfully."
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    //this.getUploadedFiles(component,event);
                }
                console.log('result::'+JSON.stringify(result));
            } else {
                let errors = response.getError();
                console.log('errors::'+JSON.stringify(errors));
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('message::'+errors[0].pageErrors[0].message);
                    message = errors[0].pageErrors[0].message;
                }
                // Display the message
                 console.error(message);
               this.showToast(component,event,message, "error");
            }  
        });
        
        $A.enqueueAction(action1); 
        
        
    },*/
    
    previewDocument : function(component, event){
        // console.log('uploadAppRecHelper::'+component.find("appAprvStatus").get("v.value") );
        var documentId = event.currentTarget.dataset.documentid;
        var fileType = event.currentTarget.dataset.filetype;
        var docType = event.currentTarget.dataset.doctype;
        console.log('dcoumentId::'+event.currentTarget.dataset.documentid);
        console.log('filename::'+event.currentTarget.dataset.filename);
        var fileName = event.currentTarget.dataset.filename;
        console.log('fileType::'+event.currentTarget.dataset.filetype);
        console.log('docType::'+event.currentTarget.dataset.doctype);
        
        var urlString = window.location.href;
        var isCommunity = false;
        
        if(urlString.indexOf("/s/") != -1){
            isCommunity = true;
        }
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var urlEvent = $A.get("e.force:navigateToURL");
        var url = "/apex/PreviewPdf?documentId="+event.currentTarget.dataset.documentid;
        console.log('url: ',url);
        if(event.currentTarget.dataset.doctype == "Bank Scrape") {
            //url = "/apex/PreviewBankScrapeDocument?dcoumentId="+event.currentTarget.dataset.documentid;
        } 
        console.log('url '+url);
        if(isCommunity){
            url = baseURL+'..'+url;
        }
        urlEvent.setParams({
            "url":url
        });
        
        if(fileType=='application/pdf' && docType != "Bank Scrape" && docType!='Bank Statement'
           && !fileName.startsWith("L_")){
            urlEvent.fire(); 
            return;
        }
        this.toggle(component,event);
        var action1 = component.get("c.previewDocument"); 
        console.log(event.currentTarget.dataset.documentid);
        action1.setParams({              
            "documentId":event.currentTarget.dataset.documentid
        });    
        
        action1.setCallback(this,function(response){  
            var state = response.getState(); 
            console.log('state::'+state);
            if(state=='SUCCESS'){  
                
                var doucmentInfo = response.getReturnValue();
                var byteCharacters = atob(doucmentInfo.fileString);
                //var byteCharacters = atob(doucmentInfo.document);//added by shiv
                console.log('byte length::'+byteCharacters.length);
                const buf = new Array(byteCharacters.length);
                for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);// & 0xFF;
                
                const view = new Uint8Array(buf);
                const blob = new Blob([view], {
                    type: doucmentInfo.contentType
                }); 
                // Automatically download the file by appending an a element,
                // 'clicking' it, and removing the element
                const a = window.document.createElement('a');
                // a.href = window.URL.createObjectURL(blob);             
                try {
                    a.href = window.URL.createObjectURL(blob);
                }
                catch(err) {
                    const blob = new Blob([view], {
                        type: 'application/octet-stream'
                    }); 
                    a.href = window.URL.createObjectURL(blob);
                }               
                console.log('fileName::'+fileName);
                a.download =fileName;
               if(doucmentInfo.contentType =='application/pdf' || doucmentInfo.contentType == 'application/json' ){
                    a.download =fileName;
                   /*if(byteCharacters.length<2197743){  // Pushpa: Updated: 05-Jan
                    urlEvent.fire(); 
                    this.toggle(component,event);
                    return;
                    }*/
                }else if(doucmentInfo.contentType =='application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                    a.download =fileName;//+'.docx';
                }
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);               
            } else {
                let errors = response.getError();
                console.log('error::'+JSON.stringify(errors));
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                    this.showToast(component,event,message, "error");
                }
                // Display the message
                console.error(message);
            }  
            
            this.toggle(component,event);
        });
        
        $A.enqueueAction(action1); 
        
        
    },
    /*deleteSelectedFile :  function(component, event){
        var action1 = component.get("c.deleteDocument");  
        action1.setParams({              
            "documentId":event.currentTarget.dataset.documentid
        });    
        console.log(JSON.stringify(action1.getParams()));
        action1.setCallback(this,function(response){  
            var state = response.getState(); 
            console.log('state::'+state);
            if(state=='SUCCESS'){  
                //this.getUploadedFiles;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been deleted successfully."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
            }  
        });
        
        $A.enqueueAction(action1);
    },*/
    
    toggle: function (cmp, event) {
        console.log('toggle start');
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        console.log('toggle end');
    },
    showToast : function (cmp,event,message, result) {                
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : result.toUpperCase(),
            message:message,
            duration:' 5000',
            key: 'info_alt',
            type: result,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    /*setReleaseLetterPicklist: function(component) {
//	 component.set("v.selectedOffer",result[0]);
     //component.set("v.offers",result);
       	var showReleaseLetterPicklist = false;
        var existingOffers = component.get("v.offers"); 
        var offerIdMain = component.find("offerIdMain");
        var selectedOfferId;
         if(offerIdMain != undefined){
             selectedOfferId = offerIdMain.get("v.value");
         }
        //var selectedOfferId = component.find("offerIdMain").get("v.value");
		
        if(selectedOfferId === undefined){
            if(existingOffers[0].Offer_Status__c == 'Final'){
                showReleaseLetterPicklist = true;
            }
        }else{
            
            for(var i = 0; i < existingOffers.length; i++){
                if(selectedOfferId == existingOffers[i].Id){
                   component.set("v.selectedOffer",existingOffers[i]);
                   if(existingOffers[i].Offer_Status__c == 'Final'){
                    showReleaseLetterPicklist = true;
                    break;
                   }
                }
            }
        }
        
        console.log('@@showReleaseLetterPicklist'+showReleaseLetterPicklist);
        if(showReleaseLetterPicklist){
            var opts = [
            	{ value: component.get("v.SETTLEMENT_LETTER"), label: component.get("v.SETTLEMENT_LETTER") },
				{ value: component.get("v.RELEASE_LETTER"), label: component.get("v.RELEASE_LETTER") },
        	];
        component.set("v.letterTypes", opts);
        }else{
            var opts = [
                { value: component.get("v.SETTLEMENT_LETTER"), label: component.get("v.SETTLEMENT_LETTER") }
        	];
        component.set("v.letterTypes", opts);
        }
    }*/
    makeAjaxRequest : function(component, url, fileBlob) {
        sendfile();
        var utils = component.find('processFile');
        //console.log('fileBlob in ajax: ',fileBlob);
        component.set("v.FileJSON", _response.getValue());
        //console.log('JSON--',component.get("v.FileJSON"));
        var response = _Response.getValue();
        //console.log('response::',response);
        /*xmlhttp.open('POST', url, fileBlob);
        xmlhttp.send();
        console.log('xmlhttp.responseText-',xmlhttp.responseText);
        //Make Ajax request by calling method from utils component
        utils.callAjax("POST", url, fileBlob, true,
                       function(xmlhttp){
                           console.log('xmlhttp:', xmlhttp);
                           
                           //Show response text if successful
                           //Display error message otherwise
                           if (xmlhttp.status == 200) {
                               component.set('v.FileJSON', xmlhttp.responseText);
                               //component.set('v.msgSeverity', 'information');
                               //component.set('v.msgTitle', 'Success');
                           }
                           else if (xmlhttp.status == 400) {
                               console.log('There was an error 400');
                               ///component.set('v.msg', 'There was an error 400');
                               //component.set('v.msgSeverity', 'error');
                               //component.set('v.msgTitle', 'Error');
                           }else {
                               console.log('Something else other than 200 was returned');
                               //component.set('v.msg', 'Something else other than 200 was returned');
                               //component.set('v.msgSeverity', 'error');
                               //component.set('v.msgTitle', 'Error');
                           }
                       }
                      );*/
    },
    
    callAjax : function(component, event, helper) {
        //Creaet new request
        var xmlhttp = new XMLHttpRequest();
        //Handle response when complete
        xmlhttp.onreadystatechange = function(component) {
            if (xmlhttp.readyState == 4 ) {
                //console.log('xmlhttp: ' + xmlhttp);
                params.callbackMethod.call(this, xmlhttp);
            }
        };
        
        var params = event.getParam('arguments');
        if (params) {
            console.log('params:', params);
            //Set parameters for the request
            xmlhttp.open(params.method, params.url, params.async);
            //Send the request
            xmlhttp.send();
        }
    },
    
    
    processFileHelper : function(component, event, helper){
        
        console.log('in process file');
        var documentId = event.currentTarget.dataset.documentid;
		var byteCharacters
        console.log('documentId ',documentId)
        var action1 = component.get("c.processProductPaymentFile");  
        action1.setParams({             
            "documentId":documentId
        });    
        action1.setCallback(this,function(response){ 
            var state = response.getState(); 
            console.log('state::'+state);
            if(state=='SUCCESS'){  
              
                var documentInfo = response.getReturnValue();
                console.log('documentInfo::'+documentInfo);
                component.find('notifLib').showToast({
                    "variant":"success",
                    "title": "File Processing!",
                    "message": "You will recieve the email once processing is complete."
                }); 
                component.set("v.showLoadingSpinner", false);
                
                //removing css class
                component.set("v.fileName", 'No File Selected..');
                //removing css class logic end
                
                $A.get('e.force:refreshView').fire();
                
                
            } else {
                let errors = response.getError();
                console.log('error::'+JSON.stringify(errors));
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                       message = errors[0].message;
                       this.showToast(component,event,message, "error");
                }
                // Display the message
                console.error(message);
            }  
        });
        
        $A.enqueueAction(action1);    
    },
    
    openDocumentRecord: function(component, event, helper){
        var documentno = event.currentTarget.dataset.documentno;
        console.log('documentno::',documentno);
        var url = '/'+documentno;
        window.open(url, '_blank');
    },
    //Added by +++..
    previewdocumentDirect:function(component, event){
        // console.log('uploadAppRecHelper::'+component.find("appAprvStatus").get("v.value") );
        var documentId = event.currentTarget.dataset.documentid;
        alert(documentId);
    	var action1 = component.get("c.getPreviewOfDoc"); 
        console.log(event.currentTarget.dataset.documentid);
        action1.setParams({              
            "documentId":documentId
        });  
    	action1.setCallback(this,function(response){  
            var state = response.getState(); 
            if(state=='SUCCESS'){ 
            var urlEvent = $A.get("e.force:navigateToURL");
    		urlEvent.setParams({
      		"url": response.getReturnValue()
    		});
                   let filepath = response.getReturnValue();
                console.log(filepath);
              alert(filepath +"\n" + filepath.indexOf("null"));
                
                if ( filepath.indexOf("null") > 0 )
                {
                       var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'File does not exists',
                            type: 'error',
                        });
                        toastEvent.fire(); 
                   }               	
                else
                   window.open(response.getReturnValue());
//                $A.enqueueAction(response.getReturnValue());
//    		urlEvent.fire();
            }
        });
                
           /*     let filepath = response.getReturnValue();
                console.log(filepath);
              alert(filepath +"\n" + filepath.indexOf("null"));
                component.set('v.returnURL', response.getReturnValue());
                alert(component.get('v.returnURL'));
                if ( filepath.indexOf("null") > 0 )
                {
                /*       var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'File does not exists',
                            type: 'error',
                        });
                        toastEvent.fire(); */
              /*     }               	
                else{
                    alert( window.open(response.getReturnValue()));
                     window.open(response.getReturnValue());
                }
                    
                   
//                $A.enqueueAction(response.getReturnValue());
//    		urlEvent.fire();
            }
        }); */
        
        $A.enqueueAction(action1);

}, 
    //Added by Rajesh 4134
   previewDocumentProxy:function(component, event){
        // console.log('uploadAppRecHelper::'+component.find("appAprvStatus").get("v.value") );
        var documentId = event.currentTarget.dataset.documentid;
      //  alert(documentId);
    	var action1 = component.get("c.uploadDocumentProxy"); 
        console.log(event.currentTarget.dataset.documentid);
        action1.setParams({              
            "documentId":documentId
        });  
    	action1.setCallback(this,function(response){  
            var state = response.getState(); 
            if(state=='SUCCESS'){ 
                let filepath = response.getReturnValue();
               // alert(filepath);
                if(filepath != null){
                window.location.href = filepath;
                }
             }else{
                  var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'File is not available',
                            type: 'error',
                        });
                        toastEvent.fire();
           }
        });
        $A.enqueueAction(action1);

} ,  
 
    
    
})