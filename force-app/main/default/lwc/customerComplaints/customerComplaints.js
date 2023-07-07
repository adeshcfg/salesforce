import { LightningElement, api, wire } from "lwc";
import getCustomerComplaints from "@salesforce/apex/CustomerComplaintsController.getCustomerComplaints";

const columns = [
    { label: "Complaint Name", fieldName: "Name", type: "text" },
    { label: "Status", fieldName: "Status__c", type: "text" },
    { label: "Complaint Type", fieldName: "Complaint_Type__c", type: "text" },
    { label: "Root Cause", fieldName: "Root_Cause__c", type: "text" }
];

export default class CustomerComplaints extends LightningElement {
    columns = columns;
    showTable = false;
    complaints = [];
    @api recordId;

    @wire(getCustomerComplaints, { recordId: "$recordId" })
    wiredComplaints({ data, error }) {
        if (data && data.length > 0) {
            this.complaints = data;
            this.showTable = true;
        } else if (error) {
            console.error(error);
        }
    }
}
