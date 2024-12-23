({
	fetchData: function(component, event, helper) {
        var action = component.get("c.getproductName");
        action.setParams({
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //alert(data.length);
                component.set("v.draftValues", data);
                component.set("v.isDataAvailable", true);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                component.set("v.isDataAvailable", false);
                //alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    openSettlementRecord: function(component, event, helper){
        var documentno = event.currentTarget.dataset.documentno;
      //  console.log('documentno::',documentno);
        var url = '/'+documentno;
        window.open(url, '_blank');
    }
})