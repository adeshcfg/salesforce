/* eslint no-console: ["error", { allow: ["error"] }] */
({
    doInit: function (component, event, helper) {
        try {
            var parsedUrl = new URL(window.location.href);
            component.set("v.insolvencyId", parsedUrl.searchParams.get("InsolvencyId"));
            component.find("recordLoader").set("v.recordId", component.get("v.insolvencyId"));
            component.find("recordLoader").reloadRecord();
        } catch (error) {
            console.error(error.message);
        }
    },

    handleRecordChanged: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            entityApiName: "Insolvency_Account__c",
            defaultFieldValues: {
                Insolvency__c: component.get("v.insolvencyId"),
                Borrower_Primary__c: component.get("v.insolvencyRecord").Debtor__c
            }
        });
        switch (event.getParams().changeType) {
            case "ERROR":
                console.error("Error loading record data");
                break;
            case "LOADED":
                createRecordEvent.fire();
                break;
            case "CHANGED":
                createRecordEvent.fire();
                break;
            default:
                break;
        }
    }
});