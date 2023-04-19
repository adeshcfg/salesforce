({
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
                   // console.log('result::',result);
                  //  console.log('files:::'+JSON.stringify(result));// commented this line as part of bug #4442
                }
            }  
        });  
        
       
        $A.enqueueAction(action);
    },
    openDocumentRecord: function(component, event, helper){
        var documentno = event.currentTarget.dataset.documentno;
      //  console.log('documentno::',documentno);
        var url = '/'+documentno;
        window.open(url, '_blank');
    },
     //Added by Satyajit 
   previewDocumentProxy:function(component, event){
        // console.log('uploadAppRecHelper::'+component.find("appAprvStatus").get("v.value") );
        var documentId = event.currentTarget.dataset.documentid;
      //  alert(documentId);
    	var action1 = component.get("c.uploadDocumentProxy"); 
       // console.log(event.currentTarget.dataset.documentid);
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
 
    /*previewDocument : function(component, event){
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
        var action1 = component.get("c.previewDocument");  
        action1.setParams({              
            "documentId":event.currentTarget.dataset.documentid
        });    
        
        action1.setCallback(this,function(response){  
            var state = response.getState(); 
            console.log('state::'+state);
            if(state=='SUCCESS'){  
                
                var doucmentInfo = response.getReturnValue();
                var byteCharacters = atob(doucmentInfo.fileString);
                console.log('byte length::'+byteCharacters.length);
                const buf = new Array(byteCharacters.length);
                for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);// & 0xFF;
                
                const view = new Uint8Array(buf);
                const blob = new Blob([view], {
                    type: doucmentInfo.contentType
                }); 
                console.log('content type::'+doucmentInfo.contentType);
              
                // Automatically download the file by appending an a element,
                // 'clicking' it, and removing the element
                const a = window.document.createElement('a');
                try {
                    a.href = window.URL.createObjectURL(blob);
                }
                catch(err) {
                    const blob = new Blob([view], {
                        type: 'application/octet-stream'
                    }); 
                    a.href = window.URL.createObjectURL(blob);
                } 
                
                console.log('href:::'+a.href);
                //fileName = fileName.split(" ").join("");
                console.log('fileName::'+fileName);
                a.download =fileName; //event.currentTarget.dataset.filename;
                if(doucmentInfo.contentType =='application/pdf' || doucmentInfo.contentType == 'application/json' ){
                    a.download =fileName+'.pdf';
                    urlEvent.fire(); 
                    return;
                }else if(doucmentInfo.contentType =='application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                    a.download =fileName+'.docx';
                }
                console.log('a.download---',a.download);
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a); 
                console.log('fileName::'+fileName);
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
    }*/
})