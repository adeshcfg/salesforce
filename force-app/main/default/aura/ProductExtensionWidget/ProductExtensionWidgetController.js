({doinit : function(component, event, helper) {
		helper.fetchData(component, helper);      
	},
     openModel: function(component, event, helper) {
      component.set("v.isModalOpen", true);
   },
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   }
})