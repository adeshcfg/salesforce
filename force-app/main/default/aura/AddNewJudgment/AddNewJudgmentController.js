({
    handleOnSuccess : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var record = event.getParam("response");
        var prodId = component.get("v.recordId");
        var action = component.get("c.linkRecords");
        console.log(prodId +'=ddd='+record.id);
        action.setParams({ prodId : prodId, judgId: record.id});
        
           action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                var productRecord = component.get("v.productRecord");
                component.find("notificationsLibrary").showToast({
                    "title": "Saved",
                    "variant": "success",
                    "message": "Judgment {0} is added for Account {1}",
                    "messageData": [
                        {
                            
                            url: '/' + record.id,
                            label: '"'+record.fields.Name.value+'"'
                        },
                        {
                            
                            url: '/' + prodId,
                            label: '"'+productRecord.Name+'"'
                        }
                    ]
                });
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": prodId,
                    "slideDevName": "related"
                });
                navEvt.fire();
                
                $A.get('e.force:refreshView').fire();
                if($A.get("e.force:closeQuickAction ")){
                    $A.get('e.force:closeQuickAction ').fire();
                }
                
                component.set("v.showSpinner", false);        
            }
            else{
                //alert('error');
                component.set("v.showSpinner", false);
                var errorHandling = component.find("errorHandling");
                component.set("v.serverRespose",response);
                errorHandling.handleError();
            }

        }); 
    	$A.enqueueAction(action);
    },
    saveJudgment:function(component, event, helper){
        console.log('inside save');
        var btn = event.getSource();
        btn.set("v.disabled",true);
        //alert('Hi&&' + component.get("v.createNewJudgment"));
        var record = event.getParam("response");
        var prodId = component.get("v.recordId");
        
        if(component.get("v.createNewJudgment")){
            //alert('Inside New Judgement');
            var action = component.get("c.validationRule");
                action.setParams({
                    'prodId' : component.get("v.recordId"),
                    'judgId': null,
                    'judgMap': component.get('v.ObjectMap')
                });
            action.setCallback(this, function(response) {
                    var state = response.getState();
                	var result;
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        //alert('hey**'+ result.length);
                        if(response.getReturnValue().length >0 ){
                            var message = response.getReturnValue();
                            //alert('message**'  + message);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: message,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                    		toastEvent.fire();
                      	}
                        else{
                            //alert('Inside match');
                            component.set("v.showSpinner", true);       					    
                            component.find("recordViewForm").submit();
                        }
                    }
            });
        	$A.enqueueAction(action);
        }
        else{
            //alert('Inside Existing Judgement' +JSON.stringify(component.get("v.selectedRecord").value));
            var action = component.get("c.validationRuleForExistingRecord");
                action.setParams({
                    'prodId' : component.get("v.recordId"),
                    'judgId': component.get("v.selectedRecord").value,
                    'judgMap': component.get('v.ObjectMap')
                });
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //alert(response.getReturnValue());
                        var result = response.getReturnValue();
                        console.log('successful');
                        if(response.getReturnValue().length >0){
                            var message =' ';
                            for(var i =0; i< result.length; i++){
                            	message += result[i]+ "\n";
                                //alert('message**'  + message);
                            }
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: message,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                    	toastEvent.fire();
                      }
                        else{
                            //alert('Inside match');
                            component.set("v.showSpinner", true); 
                            component.find("recordViewForm").submit();
                        }
                   }
                	
            });
        	$A.enqueueAction(action);
        }
		//component.find("recordViewForm").submit();
        component.set("v.showSpinner", false); 
    },
    isNewJudgment:function(component, event, helper){
		var createNew = component.get("v.createNewJudgment");
        if(createNew){
            component.set("v.selectedRecord", ""); 
        }
    },
    doInit: function(component, event, helper){
        var prodId = component.get("v.recordId");
        component.set("v.prodId", prodId);
        console.log('ppp'+prodId);
		var action = component.get("c.getlinkedJudgments");
        console.log('init');
        action.setParams({
            'prodId' : prodId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.excludeIds", response.getReturnValue());
                console.log();
            }
        });
        $A.enqueueAction(action);
    },
    handleOnError : function(component, event, helper) {
        var btn = event.getSource();
        btn.set("v.disabled",true);
        component.set("v.showSpinner", false); 
    },
    textChange: function(component, event, helper) { 
        if(event.getSource){
            var target = event.getSource();  
            var fieldValue = target.get("v.value");
            var fieldAPIName = event.getSource().get("v.fieldName");
            var obj = component.get('v.ObjectMap');
            obj[fieldAPIName] = fieldValue;
            component.set('v.ObjectMap',obj);
        }
    }
})