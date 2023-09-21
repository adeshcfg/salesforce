import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/creditBureauClass.getcreditBureauClass';

export default class CreditBureauPage extends LightningElement {

    handleClick(event){
        disableButtonEquifax = false;
        disableButtonTransUnion = false;
        disableButtonCreditBureau = false;
        window.alert('welcome');
        let labelName = event.target.label;
        if(labelName == 'Equifax'){
            this.disableButtonEquifax = true;
            getAccounts({ batchName: labelName })
        }
        if(labelName == 'TransUnion'){
            this.disableButtonTransUnion = true;
            getAccounts({ batchName: labelName })
        }
        if(labelName == 'CreditBureau'){
            this.disableButtonCreditBureau = true;
            getAccounts({ batchName: labelName })
        }
        
    }
}