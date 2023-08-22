({
    doInit: function (component, event, helper) {
        // document.getElementById("newClientSectionId").style.display = "none" ;
        try{
            
      	var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] === 'InsolvencyId') { //lets say you are looking for param name - InsolvencyId
               
            }
        }
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            entityApiName: "Insolvency_Account__c",
            "defaultFieldValues"    : {
                'Insolvency__c' : sParameterName[1]
            }  
        });
        createRecordEvent.fire();

        }catch(e){
            console.log(e.message);
        }
        
    }
    
});