import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/creditBureauClass.getcreditBureauClass';

export default class creditBureauClass extends LightningElement {
    CreditBureauDisabled = false;
    TransUnionDisabled = false;
    EquifaxDisabled = false;
    handleClick(event){
        let labelName = event.target.label;
        if(labelName == 'CreditBureau'){
            getAccounts({ batchName: labelName })
            this.CreditBureauDisabled = true;
        }
        if(labelName == 'TransUnion'){
            getAccounts({ batchName: labelName })
            this.TransUnionDisabled = true;
        }
        if(labelName == 'Equifax'){
            getAccounts({ batchName: labelName })
            this.EquifaxDisabled = true;
        }
        
    }
}