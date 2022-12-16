({
    handleUploadFinished:function(component, event, helper){   
         component.set("v.showModal",false); 
        helper.handleHelperUploadFinished(component,helper,event);            
     }
})