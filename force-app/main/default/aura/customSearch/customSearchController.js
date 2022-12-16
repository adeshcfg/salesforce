({
    handleClick : function(component, event, helper) {
      component.set("v.showSpinner", true);
      var searchText = component.get('v.searchText');
      var ac =  component.get('v.searchFields');
      var action = component.get('c.search');
      action.setParams({
                          searchText: searchText,
                          searchObject: component.get('v.searchObject'),
                          searchFields: component.get('v.searchFields'),
                          returnFields: component.get('v.returnFields'),
                          excludeRecords: component.get('v.excludeRecords'),
          				searchRecordTypes: component.get('v.searchRecordTypes')
      					});
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === 'SUCCESS') {
            var searchResults = response.getReturnValue();              
            var recordsWithBooleanCheck=[];
            
            // Add Boolean check for each record
            for (var i=0; i< searchResults.length; i++){
                var record = searchResults[i];
                record.isSelected = false;
                recordsWithBooleanCheck.push(record);
            }  
            //Pass items into component
            component.set("v.searchResults", recordsWithBooleanCheck);
            component.set("v.showSpinner", false);
        }else{
            var errorHandling = component.find("errorHandling");
            component.set("v.serverRespose",response);
            errorHandling.handleError();
        }
      });
      $A.enqueueAction(action);
    },
    searchEvents: function(component, event, helper) {
      if(event.getParams().keyCode == 13){
          var a = component.get('c.handleClick');
          $A.enqueueAction(a);
      }
   }
})