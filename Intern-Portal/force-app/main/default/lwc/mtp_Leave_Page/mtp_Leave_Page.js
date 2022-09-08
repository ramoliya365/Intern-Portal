import { LightningElement, api } from 'lwc';
import middleflight from '@salesforce/resourceUrl/mtp_leaveflighticon';

export default class Mtp_Leave_Page extends LightningElement {
    @api recordId;
    leaveTypevalue;
    dayTypevalue;
    informvalue;
    flighticon = middleflight;

    get leaveTypeOption() {
        return [
            { label: 'Loss of pay', value: 'option1' },
            { label: 'Optional', value: 'option2' },
        ];
    }
    get dayTypeOption() {
        return [
            { label: 'Full', value: 'option1' },
            { label: 'First Half', value: 'option2' },
            { label: 'Second Half', value: 'option2' },
        ];
    }
    get informOption() {
        return [
            { label: 'Prakash (prakash.m@mvclouds.com)', value: 'option1' },
            { label: 'Devansh (devansh.s@mvclouds.com)', value: 'option2' },
        ];
    }
}