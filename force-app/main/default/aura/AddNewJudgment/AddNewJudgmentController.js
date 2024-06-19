({
    handleOnSuccess: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var record = event.getParam("response");
        var prodId = component.get("v.recordId");
        var action = component.get("c.linkRecords");
        // console.log(prodId +'=ddd='+record.id);
        action.setParams({ prodId: prodId, judgId: record.id });

        action.setCallback(this, function (response) {
            var state = response.getState();
            //   console.log('state'+state);
            if (state === "SUCCESS") {
                var productRecord = component.get("v.productRecord");
                component.find("notificationsLibrary").showToast({
                    "title": "Saved",
                    "variant": "success",
                    "message": "Judgment {0} is added for Account {1}",
                    "messageData": [
                        {

                            url: '/' + record.id,
                            label: '"' + record.fields.Name.value + '"'
                        },
                        {

                            url: '/' + prodId,
                            label: '"' + productRecord.Name + '"'
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
                if ($A.get("e.force:closeQuickAction ")) {
                    $A.get('e.force:closeQuickAction ').fire();
                }

                component.set("v.showSpinner", false);
            }
            else {
                //alert('error');
                component.set("v.showSpinner", false);
                var errorHandling = component.find("errorHandling");
                component.set("v.serverRespose", response);
                errorHandling.handleError();
            }

        });
        $A.enqueueAction(action);
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        var btn = event.getSource();
        btn.set("v.disabled", true);

        if (component.get("v.createNewJudgment")) {
            //alert('Inside New Judgement');
            var action = component.get("c.validationRule");
            action.setParams({
                'prodId': component.get("v.recordId"),
                'judgId': null,
                'judgMap': component.get('v.ObjectMap')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //alert('hey**'+ result.length);
                    if (response.getReturnValue().length > 0) {
                        var message = response.getReturnValue();
                        //alert('message**'  + message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: message,
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else {
                        //alert('Inside match');
                        component.set("v.showSpinner", true);
                        fields.Product_1__c = component.get("v.productName");
                        component.find("recordViewForm").submit(fields);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else {
            //alert('Inside Existing Judgement' +JSON.stringify(component.get("v.selectedRecord").value));
            var action = component.get("c.validationRuleForExistingRecord");
            action.setParams({
                'prodId': component.get("v.recordId"),
                'judgId': component.get("v.selectedRecord").value,
                'judgMap': component.get('v.ObjectMap')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue());
                    var result = response.getReturnValue();
                    //console.log('successful');
                    if (response.getReturnValue().length > 0) {
                        var message = ' ';
                        for (var i = 0; i < result.length; i++) {
                            message += result[i] + "\n";
                            //alert('message**'  + message);
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: message,
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else {
                        //alert('Inside match');
                        component.set("v.showSpinner", true);
                        component.find("recordViewForm").submit(component.get('v.ObjectMap'));
                    }
                }
            });
            $A.enqueueAction(action);

        }
        //component.find("recordViewForm").submit();
        component.set("v.showSpinner", false);
    },
    isNewJudgment: function (component, event, helper) {
        var createNew = component.get("v.createNewJudgment");
        if (createNew) {
            component.set('v.ObjectMap', { 'Product_1__c': component.get("v.productName") });
            component.set("v.selectedRecord", "");
        }
    },
    doInit: function (component, event, helper) {
        var prodId = component.get("v.recordId");
        component.set("v.prodId", prodId);
        // console.log('ppp'+prodId);
        var action = component.get("c.getlinkedJudgments");
        action.setParams({
            'prodId': prodId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.excludeIds", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var getProductName = component.get("c.getProductName");
        getProductName.setParams({
            'prodId': prodId
        });
        getProductName.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.productName", response.getReturnValue());
            } else if (state === "ERROR") {
                var error = response.getError();
                if (error) {
                    console.error(error);
                }
            }
        });
        $A.enqueueAction(getProductName);
    },
    handleOnError: function (component, event, helper) {
        var btn = event.getSource();
        btn.set("v.disabled", true);
        component.set("v.showSpinner", false);
    },
    textChange: function (component, event, helper) {
        if (event.getSource) {
            var target = event.getSource();
            var fieldValue = target.get("v.value");
            var fieldAPIName = event.getSource().get("v.fieldName");
            var obj = component.get('v.ObjectMap');
            obj[fieldAPIName] = fieldValue;
            component.set('v.ObjectMap', obj);
        }
    },
    //bug:5476 changes starts
    getProdName: function (component, event, helper) {
        var prodId = component.get("v.recordId");
        component.set("v.prodId", prodId);
        var action = component.get("c.getProductName");
        action.setParams({
            'prodId': prodId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('response::',response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.productName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    onSelectedRecordChange: function (component, event) {
        var selectedJudgment = event.getParam("value");
        var judgData = { 'Product_1__c': '', 'Product_2__c': '', 'Product_3__c': '', 'Product_4__c': '', 'Product_5__c': '' };
        if (!selectedJudgment) {
            component.set("v.allProductFields", judgData);
            return;
        }
        var action = component.get("c.getProductJudgmentDetails");
        action.setParams({
            'judgmentId': selectedJudgment.value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var judgmentRecord = response.getReturnValue();
                for (var i = 1; i < 6; i++) {
                    var fieldApiName = 'Product_' + i + '__c';
                    if (judgmentRecord[fieldApiName]) {
                        judgData[fieldApiName] = judgmentRecord[fieldApiName];
                    }
                    else {
                        judgData[fieldApiName] = component.get("v.productName");
                        break;
                    }
                }
                component.set("v.allProductFields", judgData);
                component.set('v.ObjectMap', judgData);
            } else if (state === "ERROR") {
                var error = response.getError();
                if (error) {
                    console.error(error);
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleCancel: function (component, event, helper) {
        if ($A.get("e.force:closeQuickAction ")) {
            $A.get('e.force:refreshView').fire();
            $A.get('e.force:closeQuickAction ').fire();
        }
    }
})