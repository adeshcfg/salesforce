({doinit : function(component, event, helper) {
		helper.fetchData(component, helper);      
	},
     openModel: function(component, event, helper) {
      component.set("v.isModalOpen", true);
   }
})