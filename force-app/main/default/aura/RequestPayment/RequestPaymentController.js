({
	doinit : function(component, event, helper) {
        helper.initHelper(component, helper);
        helper.getProductRecord(component, helper);
		
	},
    
    paymentFrequencyChanged : function(component, event, helper) {
    	var paymentFreq = component.find("paymentFrequency").get("v.value");
        
        if(paymentFreq === undefined || paymentFreq === '--None--'){
            component.set("v.missingData" , true);
            component.set("v.missingDataMsg" , 'Please select payment frequency');
            return true;
        }else if(paymentFreq === 'Recurring Payment'){
            component.set("v.recurringPayment" , true);
            component.set("v.fullPaymentType" , false);
            component.set("v.monthlyValue" , false);
            component.set("v.weekDays" , false);
            component.set("v.missingData" , false);
            return true;
        }else if(paymentFreq === 'Payment in Full'){
            component.set("v.fullPaymentType" , true);
            component.set("v.recurringPayment" , false);
            component.set("v.monthlyValue" , false);
            component.set("v.weekDays" , false);
            component.set("v.missingData" , false);
            return true;
        }else{
            component.set("v.fullPaymentType" , false);
            component.set("v.recurringPayment" , false);
            component.set("v.monthlyValue" , false);
            component.set("v.weekDays" , false);
            component.set("v.missingData" , false);
            return true;
        }
        
	},
    
    recurranceTypeChange : function(component, event, helper) {
    	var paymentFreq = component.find("RecurranceType").get("v.value");
        
        if(paymentFreq === 'Monthly'){
            component.set("v.monthlyValue" , true);
            component.set("v.weekDays" , false);
            component.set("v.selectedDayOfMonth" , '--None--');
            component.set("v.selectedNoOfPay" , '--None--');
            component.set("v.endDate" , "");
            return true;
        }else{
            component.set("v.monthlyValue" , false);
            component.set("v.weekDays" , true);
            component.set("v.selectedDayOfWeek" , '--None--');
            component.set("v.selectedNoOfPay" , '--None--');
            component.set("v.endDate" , "");
            return true;
        }
    },
    
    calculateEndDate : function(component, event, helper) {
        
        helper.validateform(component, helper);
        
        //Calculate end date
        var paymentFreq = component.find("paymentFrequency").get("v.value");
        if(false == component.get("v.missingData") && paymentFreq === 'Recurring Payment'){
        	//alert('calculate');
            
        	var paymentAmount = component.find("paymentAmountVal").get("v.value");
            var recurranceTypeValue = component.find("RecurranceType").get("v.value");
            var noOfPay = component.find("noOfPay").get("v.value");
            var endDate = new Date();
            var dayOfMonthValue;
            var dayOfWeekValue;
            var today = new Date();
            /*var today = today1.getDate();
            console.log('today:', today1);
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            
            //today = mm + '/' + dd + '/' + yyyy;*/
            
            if(recurranceTypeValue === 'Monthly'){
                dayOfMonthValue = component.find("dayOfMonth").get("v.value");
                
                var nextDate = new Date();
                var dateVal = nextDate.getDate();
                var yearVal;
               // console.log('year:',today.getFullYear());
                //console.log('Month:',today.getMonth());
                //console.log('date--',today.getDate());
                if(today.getMonth() === 12){
                    yearVal = today.getFullYear() + 1;
                }else{
                    yearVal = today.getFullYear();
                }
                //console.log('check date');
                //console.log('dayOfMonthValue: '+dayOfMonthValue);
                if(dayOfMonthValue <= today.getDate()){
                  //  console.log('lesser than today');
                    nextDate = new Date(yearVal, today.getMonth() + 1, dayOfMonthValue);
                    if(dayOfMonthValue == 'Last Day of the Month'){
                        var date = new Date(), y = date.getFullYear(), m = date.getMonth();
                        var lastDay2 = new Date(y, m + 1, 0);
                     //   console.log('lastDay2:',lastDay2);
                        var lastDay = new Date(yearVal, today.getMonth() + 1, 0);
                       // console.log('lastDay1:',lastDay);
                        endDate = new Date(yearVal, today.getMonth() + 1, 0);
                        endDate.setMonth(endDate.getMonth()+parseInt(noOfPay-1));
                        endDate.setDate(endDate.getDate() + 1); 
                    }
                    else{
                        endDate = new Date(yearVal, today.getMonth() + 1, dayOfMonthValue);
                        endDate.setMonth(endDate.getMonth()+parseInt(noOfPay-1));
                        endDate.setDate(endDate.getDate() + 1);    
                    }
                    
                }else{
                   // console.log('greater than today');
                    //console.log('dayOfMonthValue: ',dayOfMonthValue);
                    if(dayOfMonthValue == 'Last Day of the Month'){
                        var month = today.getMonth(); // January
                        var d = new Date(today.getFullYear(), month +1+parseInt(noOfPay-1), 0);
                       // console.log(d.toString());
                        endDate = d;
                        endDate.setDate(endDate.getDate() + 1);
                    }
                    else{
                    	nextDate = new Date(yearVal, today.getMonth(), dayOfMonthValue);
                        endDate = new Date(yearVal, today.getMonth(), dayOfMonthValue);
                   //     console.log('endDate number: ',endDate);
                        endDate.setMonth(endDate.getMonth()+parseInt(noOfPay-1));
                     //   console.log('endDate number month set: ',endDate);
                        endDate.setDate(endDate.getDate() + 1);    
                       // console.log('endDate number Date set: ',endDate);
                    }
                    
                }
           //     console.log('nextDate final:',nextDate);
             //   console.log('endDate final:',endDate);
				//alert('End Date 1' + endDate);
                
            }else{
                dayOfWeekValue = component.find("DayOfWeek").get("v.value");
                
                var weekMap = new Map([["Monday", 1], ["Tuesday", 2],["Wednesday", 3],
                                  ["Thursday", 4],["Friday", 5],["Saturday", 6],
                                  ["Sunday", 0]]);
                
                var d = new Date();
                var i;
                var day = weekMap.get(dayOfWeekValue);
                for(i = 0; i < 7; i++){
                    d.setDate(d.getDate() + 1);
                    var dayVal = d.getDay();
                    if(dayVal === day){
                        break;
                    }
                }
                
                if(recurranceTypeValue === 'Weekly'){
                    endDate = new Date(d.valueOf() + (7 * (noOfPay - 1) * (1000*3600*24)));
                }else if(recurranceTypeValue === 'Biweekly'){
                    endDate = new Date(d.valueOf() + (14 * (noOfPay - 1) * (1000*3600*24)));
                }
            }
        	//alert('End Date 2' + endDate);
            component.set("v.endDate" , endDate);
                
        }else{
            //alert('Donot calculate');
        }
    },
    
    requestPayment : function(component, event, helper) {
        helper.validateform(component, helper);
        if(false == component.get("v.missingData")){
        	helper.saveRequestFund(component, helper);
        }else{
            //Do nothing
        }
    	
    }
})