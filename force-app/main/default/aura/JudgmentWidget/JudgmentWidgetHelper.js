({
    fetchData: function(component, event, helper) {
        var action = component.get("c.getaccountnumbers");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.draftValues", data);
                //$A.get('e.force:refreshView').fire();
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})