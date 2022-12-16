({
	handleError : function(component, event, helper) {
		var response = component.get("v.serverRespose");
        console.log(response);
        var state = response.getState();
        if (state === "INCOMPLETE") {
            // do something
        }
         if (state === "ERROR") {
                var errors = response.getError();
                    console.error(errors);
                    var errorMsg = "Could not save data: ";
                    for(var i in errors){
                        if(errors[i].hasOwnProperty('message')){
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                type : "error",
                                message : errorMsg + errors[i].message
                            });
                            resultsToast.fire();
                        }
                        for(var j in errors[i].pageErrors){
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                type : "error",
                                message : errorMsg + errors[i].pageErrors[j].message
                            });
                            resultsToast.fire();
                        }
                        for(var k in errors[i].fieldErrors){
                            for(var l in errors[i].fieldErrors[k]){
                                var resultsToast = $A.get("e.force:showToast");
                                resultsToast.setParams({
                                    type : "error",
                                    message : errorMsg + errors[i].fieldErrors[k][l].message
                                });
                                resultsToast.fire();
                            }
                        }
                    }
            }
        component.set("v.showSpinner", false);
	}
})