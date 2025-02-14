import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import uploadDocumentProxy from "@salesforce/apex/FileUploadToAzureController.uploadDocumentProxy";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import DOC_URL from "@salesforce/schema/Document_Storage__c.Document_URL__c";

const FIELDS = [DOC_URL];

export default class DocStorageDownload extends LightningElement {
    @api recordId;
    showSpinner = false;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    docStorage;

    async handleClick() {
        this.showSpinner = true;
        try {
            let downloadUrl = await uploadDocumentProxy({ documentURL: getFieldValue(this.docStorage.data, DOC_URL) });
            window.open(downloadUrl, "_blank");
        } catch (error) {
            console.error(error);
            this.showToast("Error downloading file", error.body.message, "error");
        }
        this.showSpinner = false;
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
