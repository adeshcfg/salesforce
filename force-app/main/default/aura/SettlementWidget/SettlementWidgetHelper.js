({
	fetchData: function(component, event, helper) {
        var action = component.get("c.getproduct");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.draftValues", data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})