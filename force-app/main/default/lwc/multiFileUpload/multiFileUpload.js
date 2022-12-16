import { LightningElement, api,wire,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import UpdateFiles from '@salesforce/apex/FileUploadLWC.UpdateFiles';
export default class Uploadfile extends LightningElement {
    @api recordId;
   
    //@wire(UpdateFiles, {documentId:'$documentId', title:'$title', recordId:'$recordId'})UpdateFiles;
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg','.doc','.docx','.xls','.xlsx','.csv','.txt','.rtf','.html','.zip','.mp3','.wma','.mpg','.flv','.avi','.gif'];
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        let documentId = '';
        let title = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
            documentId = uploadedFiles[i].documentId;
            title = uploadedFiles[i].name;

            UpdateFiles({documentId: documentId, title: title, recordId: this.recordId})
   .then(r => {
        console.log('r', r);
   })
     this.documentId = null;
     this.title = null;
       
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
        eval("$A.get('e.force:refreshView').fire();");
        
        //this.template.querySelector("c-MultipleFileUploadList").handleValueChange();
    }
}