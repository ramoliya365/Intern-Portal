import { LightningElement, track, api } from 'lwc';
import success from '@salesforce/resourceUrl/success';
import error from '@salesforce/resourceUrl/error';
import celebrate from '@salesforce/resourceUrl/celebrate';

export default class Mtp_ToastMessage extends LightningElement {

    @track success = false;
    @track error = false;
    successimg = success;
    errorimg = error;
    message;
    autoCloseTime;
   
    @api
    showToast(type, message, time) {
        console.log('Show Toast');
        
        if(type== 'error'){
            this.error = true;
            this.message = message;
            this.autoCloseTime=time;
            setTimeout(() => {
                this.closeModel();
            }, this.autoCloseTime);
        }else {
            this.success = true;
        }
        
    }

    get celebrategif(){
        return `background-image:url(${celebrate})`;
    }

    closeModel() {
        this.success = false;
        this.error = false;
        this.type = '';
        this.message = '';
    }

}