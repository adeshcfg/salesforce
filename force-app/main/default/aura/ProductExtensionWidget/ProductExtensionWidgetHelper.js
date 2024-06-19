({
	fetchData: function(component, event, helper) {
        var action = component.get("c.getProductExtension");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.draftValues", data);
                
            }
            
        });
        $A.enqueueAction(action);
		
	}
    
})