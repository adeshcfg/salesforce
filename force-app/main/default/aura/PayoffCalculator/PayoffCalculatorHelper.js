({
	initHelper : function(component, event, helper) {
		
        //alert("v.recordID");
        var action = component.get("c.getproduct");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //component.set("v.productRecord", data);
                component.set("v.PayoffCalculatorWrapper", data);
                //alert("Data set" + data);
                
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
        
	}
})