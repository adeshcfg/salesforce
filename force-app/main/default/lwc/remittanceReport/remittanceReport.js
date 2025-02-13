import { LightningElement, wire } from "lwc";
import getReportNameList from "@salesforce/apex/RemittanceReportUtility.getReportNameList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class RemittanceReport extends LightningElement {
    showSpinner = true;
    reportList = [];

     @wire(getReportNameList)
        wiredReportList({ error, data }) {
            this.showSpinner = false;
            if (data) {
                let options = data.map((item) => ({ label: item, value: item }));
                this.reportList = options;
            } else if (error) {
                console.error(error);
            }
        }
        
        showToast(title, message, variant) {
            const evt = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(evt);
        }
}