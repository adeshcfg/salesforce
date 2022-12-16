({
    initHelper : function(component, event, helper) {
        
        var action1 = component.get("c.eligibleProduct");
        action1.setParams({
            recordId: component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.displayMessage", data);
                
                if(component.get("v.displayMessage") === 'None'){
                    component.set("v.displayScreen", true);
                }else{
                    component.set("v.displayScreen", false);
                }
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
    },
    
    getProductRecord : function(component, event, helper) {
        var action = component.get("c.getproduct");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.productRecord", data);
                
                var radioList = [];
                if(null != component.get("v.productRecord").Customer__r.PersonEmail){
                    radioList.push({'label':'Primary Email Address: ' + component.get("v.productRecord").Customer__r.PersonEmail, 'value':component.get("v.productRecord").Customer__r.PersonEmail});
                    component.set("v.emailAddress", component.get("v.productRecord").Customer__r.PersonEmail)
                }
                if(null != component.get("v.productRecord").Customer__r.Secondary_Email__pc){
                    radioList.push({'label':'Secondary Email Address: ' + component.get("v.productRecord").Customer__r.Secondary_Email__pc, 'value':component.get("v.productRecord").Customer__r.Secondary_Email__pc});
                }
                
                component.set("v.radioOptions", radioList);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    validateform : function(component, event, helper) {
        
        var emailAdd = component.find("emaillAddressRadio").get("v.value");
        if(emailAdd === undefined || emailAdd === '--None--'){
        	component.set("v.missingData" , true);
            component.set("v.missingDataMsg" , 'Please select email address');
            return true;
        }
        
        var paymentFreq = component.find("paymentFrequency").get("v.value");
        var paymentAmount;
        if(paymentFreq === undefined || paymentFreq === '--None--'){
            component.set("v.missingData" , true);
            component.set("v.missingDataMsg" , 'Please select payment frequency');
            return true;
        }else if(paymentFreq === 'Payment in Full'){
            paymentAmount = component.find("fullPayment").get("v.value");
            if(paymentAmount <= 0){
                component.set("v.missingData" , true);
                component.set("v.missingDataMsg" , 'Current balance is less than or equal to zero. Payment cannot be set for this account.');
                return;
            }
        }else{
            paymentAmount = component.find("paymentAmountVal").get("v.value");
        }
        
        if(paymentAmount === "" || paymentAmount === null || paymentAmount === undefined || 
           paymentAmount <= 0 || paymentAmount > component.get("v.productRecord").Current_Balance__c	){
            component.set("v.missingData" , true);
            component.set("v.missingDataMsg" , 'Please add correct payment amount');
            return;
        }
        else if(paymentAmount >= component.get("v.productRecord").Effective_Current_Balance__c){
            console.log('effective balance:',component.get("v.productRecord").Effective_Current_Balance__c);
            component.set("v.missingData" , true);
            component.set("v.missingDataMsg" , 'Payment Amount is greater than effective balance');
            return;
        }
        else{
            component.set("v.missingData" , false);
        }
        
        var endDateValue;
        var dayOfWeekValue;
        var dayOfMonthValue;
        var recurranceTypeValue;
        var noOfPay;
        if(paymentFreq === 'Recurring Payment'){
            //endDateValue = component.find("endDateVal").get("v.value");
            recurranceTypeValue = component.find("RecurranceType").get("v.value");
            
            //alert('values');
            var errorMsg = '';
            var error = false;
            if(recurranceTypeValue === '--None--' || recurranceTypeValue === undefined){
                error = true;
                errorMsg = 'Please select reccurance type';
            }else if(recurranceTypeValue != '--None--'){
                if(recurranceTypeValue === 'Monthly'){
                    dayOfMonthValue = component.find("dayOfMonth").get("v.value");	
                }else{
                    dayOfWeekValue = component.find("DayOfWeek").get("v.value");
                }
                
                if(recurranceTypeValue === 'Monthly' && dayOfMonthValue === '--None--'){
                    error = true;
                    errorMsg = errorMsg + 'Please select day of month';
                    
                }else if(recurranceTypeValue != 'Monthly' && dayOfWeekValue === '--None--'){
                    error = true;
                    errorMsg = errorMsg + 'Please select day of week';
                    
                }else{
                    error = false;
                }
            }else{
                error = false;
            }
            
            noOfPay = component.find("noOfPay").get("v.value");
            if(noOfPay === '--None--' || noOfPay === undefined){
                error = true;
                errorMsg = 'Please select the number of payments';
            }else{
                var totalAmountPaid = noOfPay * paymentAmount;
                if(totalAmountPaid > component.get("v.productRecord").Current_Balance__c){
                    error = true;
                	errorMsg = 'Total amount paid is greater than outstanding balance';
                }
            }
            
            if(error === true){
                component.set("v.missingData" , error);
                component.set("v.missingDataMsg" , errorMsg);
                return;
            }else{
                component.set("v.missingData" , error);
            }
        }else{
            endDateValue = null;
            dayOfMonthValue = null;
            dayOfWeekValue = null;
        }
        
        
        
    },
    
    saveRequestFund : function(component, event, helper) {
        
        var endDateValue;
        var dayOfWeekValue;
        var dayOfMonthValue;
        var recurranceTypeValue;
        var noOfPay;
        var paymentAmount;
        
        var emailAddress = component.find("emaillAddressRadio").get("v.value");
        var paymentFrequencyValue = component.find("paymentFrequency").get("v.value");
        //(paymentFrequencyValue);
        if(paymentFrequencyValue === 'Payment in Full'){
            paymentAmount = component.find("fullPayment").get("v.value");
        }else{
            paymentAmount = component.find("paymentAmountVal").get("v.value");
        }
        
        if(paymentFrequencyValue === 'Recurring Payment'){
        	recurranceTypeValue = component.find("RecurranceType").get("v.value");
            //alert(recurranceTypeValue);
            if(recurranceTypeValue === 'Monthly'){
                dayOfMonthValue = component.find("dayOfMonth").get("v.value");	
            }else{
                dayOfWeekValue = component.find("DayOfWeek").get("v.value");
            }
            noOfPay = component.find("noOfPay").get("v.value");   
            endDateValue = component.find("endDate").get("v.value");
        }
        
        //endDateValue = component.find("endDate").get("v.value");
        console.log('endDateValue in helper:',endDateValue);
        var action = component.get("c.saveTransaction");
        
        action.setParams({
            productrecordId: component.get("v.recordId"),
            transactionType: paymentFrequencyValue,
            recurranceType: recurranceTypeValue,
            paymentAmount: paymentAmount,
            dayOfWeek: dayOfWeekValue,
            dayOfMonth: dayOfMonthValue,
            endDate: endDateValue,
            NumberOfPayments: noOfPay,
            emailAddress: emailAddress
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.successMessage", data);
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            if (state === "ERROR") {
                alert(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
})