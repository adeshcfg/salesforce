({
	handleHelperUploadFinished : function(component,helper,event) {
		var uploadedFiles = event.getParam("files");
        var errorFileName ='';
        var j=1;
       for(var i = 0; i < uploadedFiles.length; i ++){
            var action = component.get("c.contentSize");
            var documentId = uploadedFiles[i].documentId;
            var fileName = uploadedFiles[i].name;
            action.setParams({ cid : documentId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var tempList = response.getReturnValue();
                
                if (state == "SUCCESS") {  
                     var listerr = tempList.split(','); 
                    if(listerr[0] == 'ERROR'){
                      if(errorFileName ==''){
                          errorFileName  = listerr[1];
                        }else if(errorFileName!='' && errorFileName!=null){
                        errorFileName = errorFileName+ ','+listerr[1];
                        }
                  }    
                 if(j == uploadedFiles.length){
                    if(errorFileName!='' && errorFileName!=null){
                          component.set("v.errorFileName", errorFileName);
                         component.set("v.showModal",true); 
                       var outtext = component.find('outputTextId');
       					 $A.util.addClass(outtext, 'textClass');
           				var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": errorFileName+" Files size can\'t be greater than 5.5 MB",
                            "type" : "Warning"
                        });
                        toastEvent.fire();
       			 }
                }
                 j =j +1;
            } 
            });
             $A.enqueueAction(action);
           $A.get('e.force:refreshView').fire();
         }
	}
})