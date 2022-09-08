import { LightningElement } from 'lwc';
import mtp_LeavePageBG from '@salesforce/resourceUrl/mtp_LeavePageBG';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';

export default class Mtp_LeavePage extends LightningElement {

    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    get imghome(){
        return `background-image:url(${mtp_LeavePageBG})`;
    }
}