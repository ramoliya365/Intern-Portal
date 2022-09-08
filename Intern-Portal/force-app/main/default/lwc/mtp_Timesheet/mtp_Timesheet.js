import { LightningElement, track } from 'lwc';
import mtp_Timesheet_bg_image from '@salesforce/resourceUrl/mtp_Timesheet_bg_image';
import mtp_Approve_icon from '@salesforce/resourceUrl/mtp_Approve_icon';
import mtp_Reject_icon from '@salesforce/resourceUrl/mtp_Reject_icon';
import mtp_Airplane_StartTime_icon from '@salesforce/resourceUrl/mtp_Airplane_StartTime_icon';
import mtp_Airplane_EndTime_icon from '@salesforce/resourceUrl/mtp_Airplane_EndTime_icon';
import mtp_Calendar_icon from '@salesforce/resourceUrl/mtp_Calendar_icon';

import getTimesheetData from '@salesforce/apex/mtp_TimesheetController.getTimesheetData';
import getTaskList from '@salesforce/apex/mtp_TimesheetController.getTaskList';
import createTimesheetRecord from '@salesforce/apex/mtp_TimesheetController.createTimesheetRecord';
export default class Mtp_Timesheet extends LightningElement {
    bgImage = mtp_Timesheet_bg_image;                       // background-image of timesheet component
    approveIcon = mtp_Approve_icon;                         // approve icon for timesheet
    rejectIcon = mtp_Reject_icon;                           // reject icon for timesheet 
    startTimeIcon = mtp_Airplane_StartTime_icon;            // start time (airplane) icon for timesheet
    endTimeIcon = mtp_Airplane_EndTime_icon;                // end time (airplane) icon for timesheet
    calendarIcon = mtp_Calendar_icon;                       // calendar icon for timesheet

    @track timesheetDataList = [];
    @track taskOptionList = [];
    @track isCreateTimesheetModalOpen = false;

    @track testSD = '';
    @track tsTask = '';
    @track tsStartTime = '';
    @track tsEndTime = '';
    @track tsComments = '';


    connectedCallback() {
        try {
            this.getTimesheetList();
            this.getTaskOptionList();
        } catch (error) {
            console.log({ error });
        }
    }

    getTimesheetList() {
        try {
            getTimesheetData()
                .then(result => {
                    this.timesheetDataList = result;
                    console.log("timesheetDataList ==>");
                    console.log({ result });
                })
                .catch(error => {
                    console.log({ error });
                });
        } catch (error) {
            console.log({ error });
        }
    }

    getTaskOptionList() {
        try {
            let options = [];
            getTaskList()
                .then(result => {
                    console.log("taskList ==>");
                    console.log({ result });
                    for (var key in result) {
                        var splitString = result[key].split(':::');
                        options.push({ label: splitString[0], value: splitString[1] });
                    }
                    this.taskOptionList = options;
                })
                .catch(error => {
                    console.log({ error });
                });
        } catch (error) {
            console.log({ error });
        }
    }

    openTimesheetModal() {
        try {
            console.log("Timesheet popup modal open");
            this.isCreateTimesheetModalOpen = true;
        } catch (error) {
            console.log({ error });
        }
    }

    closeTimesheetModal() {
        try {
            console.log("Timesheet popup modal closed");
            this.isCreateTimesheetModalOpen = false;
        } catch (error) {
            console.log({ error });
        }
    }

    handleChangePopup(event) {
        try {
            if (event.target.name == 'PopupModalTask') {
                this.tsTask = event.target.value;
                console.log("task Name ==>" + this.tsTask);
            } else if (event.target.name == 'PopupModalStartTime') {
                this.tsStartTime = event.target.value;
                console.log("Start Time ==>" + this.tsStartTime);
                var sd = new Date(this.tsStartTime);
                this.tsStartTime = sd;
                console.log("Start Time ==>" + this.tsStartTime);

            } else if (event.target.name == 'PopupModalEndTime') {
                this.tsEndTime = event.target.value;
                console.log("End Time ==>" + this.tsEndTime);
                var ed = new Date(this.tsEndTime);
                this.tsEndTime = ed;
                console.log("End Time ==>" + this.tsEndTime);
            } else if (event.target.name == 'PopupModalComments') {
                this.tsComments = event.target.value;
                console.log("Comments ==>" + this.tsComments);
            }

        } catch (error) {
            console.log({ error });
        }
    }

    createTimesheet() {
        try {
            console.log("Create timesheet called");
            createTimesheetRecord({
                taskId: this.tsTask,
                startTime: this.tsStartTime,
                endTime: this.tsEndTime,
                comments: this.tsComments
            })
                .then(result => {
                    console.log("createTimesheet Result ==>");
                    console.log({ result });
                })
                .catch(error => {
                    console.log({ error });
                });
        } catch (error) {
            console.log({ error });
        }
    }
}