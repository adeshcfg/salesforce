({
	doInit: function(component,event, helper) {
        component.set('v.showSpinner',true);
        helper.fetchLinkedAccounts(component);
    },
    selectAll : function(component, event, helper) {
		let checkBoxState = component.get('v.isDisabled');
        var searchResults = component.get('v.searchResults');
        for(var obj in searchResults){
            console.log(obj);
            searchResults[obj].isSelected = checkBoxState;
        }
        component.set('v.searchResults', searchResults);
        component.set('v.isDisabled', !checkBoxState);
        
	},
    selected : function(component, event, helper) {
        var isDisabled = true;
        var getAllCheckboxes = component.find("prod-checkbox");
        console.log(getAllCheckboxes);
        if(getAllCheckboxes.length == undefined && getAllCheckboxes.get("v.value") == true){
            isDisabled = false;
        }
        for (var i = 0; i < getAllCheckboxes.length; i++) {
            if (getAllCheckboxes[i].get("v.value") == true) {
                isDisabled = false;
                break;
            }
        }
        component.set('v.isDisabled', isDisabled);
    },
    addAccounts : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.saveAccountJudgmentRecord(component, event, helper);
    }
    
})