({
    // To prepopulate the seleted value pill if value attribute is filled
	doInit : function( component, event, helper ) {
    	$A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
		if( !$A.util.isEmpty(component.get('v.value')) ) {
			helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
		}
	},

    // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            var searchValue = component.get('v.searchString');
            if(searchValue.length >= 3){
		    	helper.searchRecordsHelper( component, event, helper, '' );
            }
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
	},

    // When an item is selected
	selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
    		var recordsList = component.get('v.recordsList');
    		var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            //console.log(JSON.stringify(selectedRecord));
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            //bug:5476 changes starts
           var cmpEvent = cmp.getEvent("cmpEvent");
        cmpEvent.setParams({
            "judgmentId" : selectedRecord
        });
        cmpEvent.fire();
    
          /*  console.log('before helper');
            helper.getProdName(component, event, helper);
            console.log('after helper');
            var action = component.get("c.getJudgmentDetails");
            console.log('calling apex method');
            console.log('selectedRecord--->'+selectedRecord);
            console.log('selectedRecord.value---->'+selectedRecord.value);
            action.setParams({
                'JudgmentId' : selectedRecord.value
            });
            action.setCallback(this, function(response) {
                console.log('set call back');
                var state = response.getState();
                //console.log('response::',response.getReturnValue());
                if (state === "SUCCESS") {
                    console.log('Response--->'+JSON.stringify(response.getReturnValue()));
                    component.set("v.judgmentRecord", JSON.stringify(response.getReturnValue()));
                    var judgment=response.getReturnValue();
                    if(!judgment.product_2__c)
                    {
                        component.set('v.prodName2Flag',true);
                    }
                    else  if(!judgment.product_3__c)
                    {
                        component.set('v.prodName3Flag',true);
                    }
                    else  if(!judgment.product_4__c)
                    {
                        component.set('v.prodName4Flag',true);
                    }
                    else  if(!judgment.product_5__c)
                    {
                        component.set('v.prodName5Flag',true);
                    }
                    console.log('Product name--->'+component.get('v.productNameExisting'));
                 /*   if(judgment.product_2__c)
                    {
                        component.set('v.productNameExisting',judgment.product_2__c);
                    }
                    else  if(judgment.product_3__c)
                    {
                        component.set('v.productNameExisting',judgment.product_2__c);
                    }
                    else  if(judgment.product_4__c)
                    {
                        component.set('v.productNameExisting',judgment.product_2__c);
                    }
                    else  if(judgment.product_5__c)
                    {
                        component.set('v.productNameExisting',judgment.product_2__c);
                    }
                    */
                  //  component.set("v.prodName2Flag", response.getReturnValue());
                   // component.set("v.prodName3Flag", response.getReturnValue());
                   // component.set("v.prodName4Flag", response.getReturnValue());
                   // component.set("v.prodName5Flag", response.getReturnValue());
                 /*   console.log('success');
                    var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            prodName2Flag : component.get('v.prodName2Flag'),
            prodName3Flag : component.get('v.prodName3Flag'),
            prodName4Flag : component.get('v.prodName4Flag'),
            prodName5Flag : component.get('v.prodName5Flag'),
            productNameExisting:component.get('v.productNameExisting')
        });
        cmpEvent.fire();
                }
            });
            $A.enqueueAction(action);
            //bug:5476 changes ends*/
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
	},

    // To remove the selected item.
	removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },

    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
    	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    }
})