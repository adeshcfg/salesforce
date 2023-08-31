({
    openModal: function (component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },

    closeModal: function (component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.isModalOpen", false);
    },

    handleOnSubmit: function (component, event, helper) {
        event.preventDefault();
        var statusDropdown = component.find("statusField");
        var statusValue = component.get("v.statusValue");
        if (!statusValue) {
            statusDropdown.reportValidity();
            return;
        }
        var eventFields = event.getParam("fields");
        eventFields.Status = "Closed";
        component.find("caseCloseForm").submit(eventFields);
    },

    handleSuccess: function (component, event, helper) {
        component.set("v.statusValue", null);
        component.set("v.isModalOpen", false);
    }
});
