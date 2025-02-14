import { LightningElement, wire } from "lwc";
import getSellerList from "@salesforce/apex/PutbackBuybackUtility.getSellerList";
import canGenerateFile from "@salesforce/apex/PutbackBuybackUtility.canGenerateFile";
import initiateFormGeneration from "@salesforce/apex/PutbackBuybackUtility.initiateFormGeneration";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PutBuybackSubmissionForm extends LightningElement {
    showSpinner = true;
    sellerList = [];
    disableButton = true;
    selectedSeller;

    @wire(getSellerList)
    wiredSellerList({ error, data }) {
        if (data) {
            let options = data.map((item) => ({ label: item, value: item }));
            this.sellerList = options;
            this.showSpinner = false;
        } else if (error) {
            console.error(error);
        }
    }

    async handleChange(event) {
        this.showSpinner = true;
        this.selectedSeller = event.detail.value;
        let canGenerate = await canGenerateFile({ selectedSeller: this.selectedSeller });
        if (!canGenerate) {
            this.showToast("Processing in progress", "Processing already inititated/completed for selected seller for today", "warning");
        }
        this.disableButton = !canGenerate;
        this.showSpinner = false;
    }

    async handleClick() {
        const allValid = [...this.template.querySelectorAll("lightning-combobox")].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.showSpinner = true;
            try {
                await initiateFormGeneration({ selectedSeller: this.selectedSeller });
                this.disableButton = true;
                this.showToast("Processing started", "You will receive a mail when processing is complete", "success");
            } catch (e) {
                this.disableButton = true;
                this.showToast("Cannot generate Submission Form/Zip file", e.body.message, "error");
                console.error(e);
            }
            this.showSpinner = false;
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
