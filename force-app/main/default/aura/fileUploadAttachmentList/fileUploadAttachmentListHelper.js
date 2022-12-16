({
    fetchData: function(component, event, helper) {  
        var action = component.get("c.getAttachment");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.draftValues", data);
                //component.set("v.isButtonActive",true);
                console.log(data);
                  let button = component.find('disablebuttonid');
                if(data.length != 0){
                   console.log('RUn Block');
    			   button.set('v.disabled',false);
                }else{
                    console.log('RUn Block else');
                    button.set('v.disabled',true);
                }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },   
    populateList: function(component, event, helper){
        var action = component.get("c.getPickListValuesIntoList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.options", data);
                
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    docVisibilityList: function(component, event, helper){
        var action = component.get("c.getDocVisibilityValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                component.set("v.docVisibility", data);
                //component.find("month").set("v.value",'--None--')
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
   
    updateattachment: function(component, event, helper) {
        
       var jvar= JSON.stringify(component.get("v.draftValues"));
        var drafvalu = component.get("v.draftValues");
        var ob;
        for(var i=0;i<drafvalu.length;i++){
            if(drafvalu[i].docType=='--None--' || drafvalu[i].docType==''){
			ob=drafvalu[i].docType;            
            }
		}
        if(ob=='' || ob=='--None--'){
             var showToast = $A.get("e.force:showToast"); 
						showToast.setParams({ 
							title : 'error :', 
							message : 'Document type is mandatory, please select to process your request',
							type : 'error'
                        }); 
                        showToast.fire();
        }
       else{
       var action = component.get("c.updateAttachmentrecord");
        var parentid = component.get("v.recordId");
       var draftValues = component.get("v.draftValues");
       console.log(jvar);
       // console.log(draftValues);
        action.setParams({"jvar" : jvar,
                          "parentid" : parentid
                         });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                $A.get("e.force:refreshView").fire();
                var showToast = $A.get("e.force:showToast"); 
						showToast.setParams({ 
							title : 'Success :', 
							message : 'Record Created Successfully',
							type : 'Success',
							mode : 'pester'
                        }); 
                        showToast.fire();
            } 
            /*else {
                alert('File size cannot exceed 5500000 bytes.');
            }*/
        });
        $A.enqueueAction(action);
       }
    },
    
});