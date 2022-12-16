({
	doInit: function(component,event, helper) {
        component.set('v.showSpinner',true);
        helper.fetchAccountJudgments(component);
    }
})