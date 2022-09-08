import { LightningElement } from 'lwc';
import ErrorImage from '@salesforce/resourceUrl/ErrorImage';
import ArrowLeft from '@salesforce/resourceUrl/ArrowLogo';
export default class Mtp_Error_Page extends LightningElement {
    arrowLeft = ArrowLeft;
    get backgroundImage() {
        return `background-position: center;
        background-repeat: no-repeat;
        background-size: cover;
        height:100%; 
        background-image:url(${ErrorImage})`;
    }    
}