({
    doInit : function(component) {
        var action = component.get("c.getPickListValues");
        action.setParams({
            objectType: component.get("v.sObjectName"),
            selectedField: component.get("v.fieldName")
        });
        action.setCallback(this, function(response) {
            var pklist = response.getReturnValue();
            component.set("v.picklistValues", pklist);
        })
        
        $A.enqueueAction(action);
    }
})