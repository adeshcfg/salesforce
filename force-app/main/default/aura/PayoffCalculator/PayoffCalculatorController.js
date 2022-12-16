({
    doinit : function(component, event, helper) {
        helper.initHelper(component, event, helper);
        var today = new Date();
        component.set('v.paymentDueDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        
        component.get("c.calculate");
    },
    
    cancelBtn : function(component, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    calculate : function(component, event) {
        
        var principalBal = component.find("principalBalance").get("v.value");
        //alert("principalBal " + principalBal);        
        var PrincipalBalDate = component.find("principalBalanceDate").get("v.value");
        //alert("PrincipalBalDate " + PrincipalBalDate);
        var intRate = component.find("interestRate").get("v.value");
        //alert("intRate " + intRate);
        var paymentDueDate = component.find("paymentDueDate").get("v.value");
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        if(intRate < 0 || intRate > 100){
            component.set("v.interestRateValidationError" , true);
            return true;            
        }else{
            component.set("v.interestRateValidationError" , false);
        }
        
        //today = mm + '/' + dd + '/' + yyyy;
        var todayFormat = yyyy + '-' + mm + '-' + dd;
        //alert(todayFormat);
        //alert(paymentDueDate);
        if(paymentDueDate < todayFormat){
            //alert('Error - Due date should not be is past');
            component.set("v.dateValidationError" , true);
            return true;
        }else{
            component.set("v.dateValidationError" , false);
        }
        //alert("paymentDueDate " + paymentDueDate);
        var noOfDays = component.find("noOfDaysInYear").get("v.value");
        //alert("noOfDays " + noOfDays);
        
        var perDiemInterestRate = (principalBal * (intRate/100) / noOfDays).toFixed(2);
        
        const diffTime = new Date(Date.parse(paymentDueDate) - Date.parse(PrincipalBalDate));
        //alert("diffTime " + diffTime);
		const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        var totalDaystoCalculate = diffDays;
        //alert("totalDaystoCalculate " + totalDaystoCalculate);
        
        if(totalDaystoCalculate < 0){
            component.set("v.balanceDateValidationError" , true);
            return true;
        }else{
            component.set("v.balanceDateValidationError" , false);
        }
        
        var interestDue = (perDiemInterestRate * totalDaystoCalculate).toFixed(2);
        
        var totalAmountDue = parseFloat(principalBal) + parseFloat(interestDue);
        
        component.set("v.interestDue", interestDue);
        component.set("v.totalAmountDue", totalAmountDue);
        component.set("v.perDiemInterest", perDiemInterestRate);
        
        /*component.find("v.payDueBal").set("v.format",'$#,###.00');
        component.find("v.interestDueAmount").set("v.format",'$#,###.00');
        component.find("v.totalAmount").set("v.format",'$#,###.00');
        component.find("v.perDiemInt").set("v.format",'$#,###.00');*/
    }
})