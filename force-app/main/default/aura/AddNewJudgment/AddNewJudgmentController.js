({
    handleOnSuccess : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var record = event.getParam("response");
        var prodId = component.get("v.recordId");
        var action = component.get("c.linkRecords");
       // console.log(prodId +'=ddd='+record.id);
        action.setParams({ prodId : prodId, judgId: record.id});
        
           action.setCallback(this, function(response) {
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
      //  console.log('inside save');
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
                        //console.log('successful');
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
            console.log('create new checkbox checked');
            component.set("v.selectedRecord", ""); 
            //bug:5476 changes starts
            var prodId = component.get("v.recordId");
            component.set("v.prodId", prodId);
            var action = component.get("c.getProductName");
            console.log('calling apex method');
            action.setParams({
                'prodId' : prodId
            });
            action.setCallback(this, function(response) {
                console.log('set call back');
                var state = response.getState();
                //console.log('response::',response.getReturnValue());
                if (state === "SUCCESS") {
                    component.set("v.productName", response.getReturnValue());
                    console.log('success');
                }
            });
            $A.enqueueAction(action);
            //bug:5476 changes ends
        }
    },
    doInit: function(component, event, helper){
        var prodId = component.get("v.recordId");
        component.set("v.prodId", prodId);
       // console.log('ppp'+prodId);
		var action = component.get("c.getlinkedJudgments");
        action.setParams({
            'prodId' : prodId
        });
        /*var action1 = component.get("c.productData");
        var action2 = component.get("c.activeJudgmentCheck");
        console.log('init');
        action1.setParams({
            'prodId' : prodId
        });
        action2.setParams({
            'prodId' : prodId
        });
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response::',response.getReturnValue());
            if (state === "SUCCESS") { 
                var responseVal = JSON.stringify(response.getReturnValue());
                console.log('responseVal::',responseVal);
               if(responseVal == "true"){
                    component.set("v.truthy", true); 
                }
            }
        });
         action2.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response::',response.getReturnValue());
            if (state === "SUCCESS") { 
                var responseVal = JSON.stringify(response.getReturnValue());
                console.log('responseVal::',responseVal);
               if(responseVal == "true"){
                    component.set("v.accJudgment", true); 
                }
            }
        });*/
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('response::',response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.excludeIds", response.getReturnValue());
                console.log();
            }
        });
        $A.enqueueAction(action);
        //$A.enqueueAction(action1);
        //$A.enqueueAction(action2);
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
    },
      //bug:5476 changes starts
      getProdName: function(component, event, helper) { 
      var prodId = component.get("v.recordId");
      component.set("v.prodId", prodId);
      var action = component.get("c.getProductName");
      console.log('calling apex method');
      action.setParams({
          'prodId' : prodId
      });
      action.setCallback(this, function(response) {
          console.log('set call back');
          var state = response.getState();
          //console.log('response::',response.getReturnValue());
          if (state === "SUCCESS") {
              component.set("v.productName", response.getReturnValue());
              console.log('success');
          }
      });
      $A.enqueueAction(action);
    },
 /*   handleComponentEvent : function(component, event) {
       component.set('prodName2Flag',event.getParam("prodName2Flag"));
       component.set('prodName3Flag',event.getParam("prodName3Flag"));
       component.set('prodName4Flag',event.getParam("prodName4Flag"));
       component.set('prodName5Flag',event.getParam("prodName5Flag"));
       component.set('productNameExisting',event.getParam("productNameExisting"));
     console.log('prodName2Flag--->'+component.get('v.prodName2Flag'));
     console.log('prodName3Flag--->'+component.get('v.prodName3Flag'));
     console.log('prodName4Flag--->'+component.get('v.prodName4Flag'));
     console.log('prodName5Flag--->'+component.get('v.prodName5Flag'));
     console.log('productNameExisting--->'+component.get('v.productNameExisting'));
    },*/
            //bug:5476 changes ends
            handleOnLoad :  function(component, event){
                console.log('handle on load');
                var judgData={};
                var prodId = component.get("v.recordId");
            component.set("v.prodId", prodId);
            var action = component.get("c.getProductName");
            console.log('calling apex method');
            action.setParams({
                'prodId' : prodId
            });
            action.setCallback(this, function(response) {
                console.log('set call back');
                var state = response.getState();
                //console.log('response::',response.getReturnValue());
                if (state === "SUCCESS") {
                    component.set("v.productName", response.getReturnValue());
                    console.log('success');
                    for(let i=0;i<6;i++){
                        if(judgment['product_'+i+'__c']){
                            console.log('Judgment product'+i+'is blank');
                            judgData['product_'+i+'__c']=judgment['product_'+i+'__c'];
                        }
                        else{
                            console.log('Judgment product is not blank');
                            judgData['product_'+i+'__c']=response.getReturnValue();
                            break;
                        }
                    }
                }
            });
        component.set('v.allproducts',judgData);
        console.log('Judgment Product data--->'+judgData);
        console.log('products data--->'+component.set('v.allproducts'));
        $A.enqueueAction(action);
    }
      //bug:5476 changes ends
})