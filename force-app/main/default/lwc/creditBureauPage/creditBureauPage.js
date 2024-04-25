import { LightningElement, wire } from "lwc";
import getAccounts from "@salesforce/apex/creditBureauClass.getcreditBureauClass";
import getWorkAssignment from "@salesforce/apex/creditBureauClass.getWorkAssignment";

export default class creditBureauClass extends LightningElement {
    workAssignmentId = "";
    CreditBureauDisabled = false;
    TransUnionDisabled = false;
    EquifaxDisabled = false;

    @wire(getWorkAssignment)
    wiredAssignment({ error, data }) {
        if (data) {
            this.workAssignmentId = `/${data}`;
        } else if (error) {
            console.error(error);
        }
    }

    handleClick(event) {
        let labelName = event.target.label;
        if (labelName === "CreditBureau") {
            getAccounts({ batchName: labelName });
            this.CreditBureauDisabled = true;
        }
        if (labelName === "TransUnion") {
            getAccounts({ batchName: labelName });
            this.TransUnionDisabled = true;
        }
        if (labelName === "Equifax") {
            getAccounts({ batchName: labelName });
            this.EquifaxDisabled = true;
        }
    }
}
