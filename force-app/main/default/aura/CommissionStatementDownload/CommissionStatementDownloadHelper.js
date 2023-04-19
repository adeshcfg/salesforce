({
	previewDocument : function(component, event){
        // console.log('uploadAppRecHelper::'+component.find("appAprvStatus").get("v.value") );
        var documentId = event.currentTarget.dataset.documentid;
        var fileType = event.currentTarget.dataset.filetype;
        var docType = event.currentTarget.dataset.doctype;
     //   console.log('dcoumentId::'+event.currentTarget.dataset.documentid);
       // console.log('filename::'+event.currentTarget.dataset.filename);
        var fileName = event.currentTarget.dataset.filename;
        //console.log('fileType::'+event.currentTarget.dataset.filetype);
        //console.log('docType::'+event.currentTarget.dataset.doctype);
        
        var urlString = window.location.href;
        var isCommunity = false;
        
          if(urlString.indexOf("/s/") != -1){
            isCommunity = true;
        }
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var url = "/apex/PreviewPdf?documentId=d39e290e-7db7-481e-87e3-4b5ddf38305a";
     //   console.log('url: ',url);
        if('Drivers License' == "Bank Scrape") {
            //url = "/apex/PreviewBankScrapeDocument?dcoumentId="+event.currentTarget.dataset.documentid;
        } 
       // console.log('url '+url);
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
        //this.toggle(component,event);
        var action1 = component.get("c.previewDocument");  
        action1.setParams({              
            "documentId": event.currentTarget.dataset.documentid
        });    
        
        action1.setCallback(this,function(response){  
            var state = response.getState(); 
        //    console.log('state::'+state);
            if(state=='SUCCESS'){  
                
                var doucmentInfo = response.getReturnValue();
                var byteCharacters = atob(doucmentInfo.fileString);
             //   console.log('byte length::'+byteCharacters.length);
                const buf = new Array(byteCharacters.length);
                for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);// & 0xFF;
                
                const view = new Uint8Array(buf);
                
                
                const blob = new Blob([view], {
                    type: doucmentInfo.contentType
                }); 
               // console.log('content type::'+doucmentInfo.contentType);
                /* const blob = new Blob([view], {
                    type: event.currentTarget.dataset.filetype
                });*/
              
                // Automatically download the file by appending an a element,
                // 'clicking' it, and removing the element
                const a = window.document.createElement('a');
                // a.href = window.URL.createObjectURL(blob);
                //console.log('href1:::'+a.href);
                try {
                    a.href = window.URL.createObjectURL(blob);
                    //alert(a.href);
                }
                catch(err) {
                    const blob = new Blob([view], {
                        type: 'application/octet-stream'
                    }); 
                    a.href = window.URL.createObjectURL(blob);
                } 
                
              //  console.log('href:::'+a.href);
                //fileName = fileName.split(" ").join("");
                //console.log('fileName::'+fileName);
                a.download =fileName+'.pdf'; //event.currentTarget.dataset.filename;
                /*if(doucmentInfo.contentType =='application/pdf' || doucmentInfo.contentType == 'application/json' ){
                    // a.download =fileName+'.pdf';
                    urlEvent.fire(); 
                    //this.toggle(component,event);
                    return;
                }else if(doucmentInfo.contentType =='application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                    a.download =fileName+'.docx';
                }*/
               // console.log('a.download---',a.download);
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a); 
               // console.log('fileName::'+fileName);
            } else {
                let errors = response.getError();
               // console.log('error::'+JSON.stringify(errors));
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                    //this.showToast(component,event,message, "error");
                }
                // Display the message
                console.error(message);
            }  
            
            //this.toggle(component,event);
        });
        
        $A.enqueueAction(action1); 
        
        
        
    },
     getUploadedFiles : function(component, event){
       // console.log('getUploadedFiles:::');
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
                  //  console.log('result::',result);
                    for(var i = 0; i < result.length; i++){
                        //console.log('@@att=='+JSON.stringify(result[i]));
                        //console.log('type=='+JSON.stringify(result[i]));
                        //console.log('result[i].Work_Assignment__c !=',result[i].Work_Assignment__c);
                        //console.log('result[i].Work_Assignment_Purpose__c !=',result[i].Work_Assignment_Purpose__c);
                        //console.log('result[i].Parent_WorkAssignment_Product !=',result[i].Parent_WorkAssignment_Product__c);
                        /*if(result[i].Work_Assignment__c != ''
                           && result[i].Work_Assignment_Purpose__c == 'Media Request'
                           //&& result[i].Parent_WorkAssignment_Product__c != ''
                          ){
                            component.set("v.isMediaRequest",true); 
                            console.log(component.get("v.isMediaRequest"));
                        } */   
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
     
        $A.enqueueAction(action);
    }
})