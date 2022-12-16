({
	fetchAccountJudgments:function(component){
        var customerId = component.get("v.recordId");
        var action = component.get("c.fetchAccountJudgments");
        action.setParams({
            "customerId" : customerId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set('v.existingAccountJudgments', response.getReturnValue());
                component.set('v.showSpinner',false);
            }else{
                 var errorHandling = component.find("errorHandling");
                 component.set("v.serverRespose",response);
                 errorHandling.handleError();
             } 
        });
        $A.enqueueAction(action);
    }
})