({
	doinit : function(component, event, helper) {
		helper.fetchData(component, helper);      
	},
     openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },  
   openSettlementRecordNow: function(component, event, helper){
        helper.openSettlementRecord(component, event);
    },
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   }
})