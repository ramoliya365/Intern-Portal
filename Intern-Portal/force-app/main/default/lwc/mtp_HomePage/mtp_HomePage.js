import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import homepage from '@salesforce/resourceUrl/homepage';
import course from '@salesforce/resourceUrl/course';
import timesheet from '@salesforce/resourceUrl/timesheet';
import leave from '@salesforce/resourceUrl/leave';
import calender from '@salesforce/resourceUrl/calender';
import arrow from '@salesforce/resourceUrl/arrow';

export default class Mtp_HomePage extends NavigationMixin(LightningElement) {

    imgarrow = arrow;
    courseimg = course;
    timesheetimg = timesheet;
    leaveimg = leave;
    calenderimg = calender;
    @track username;

    get imghome(){
        return `background-image:url(${homepage})`;
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.username = data.fields.Name.value;
        }
    }
    
    navigation(event){
        console.log({event});
        let name = event.currentTarget.dataset.name;
        console.log({name});

        var pageapiname;
        var urlValue = '/s/';

        if(name == "course"){
            pageapiname = 'course__c';
            urlValue += 'course';
        }else if(name == "timesheet"){
            pageapiname = 'Timesheet__c';
            urlValue += 'timesheet';
        }else if(name == "leave"){
            pageapiname = 'Leave__c';
            urlValue += 'leave';
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageapiname,
                url: urlValue
            },
        });
    }
}