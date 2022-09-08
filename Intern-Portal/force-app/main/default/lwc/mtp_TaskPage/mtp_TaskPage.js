import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import mtb_Login_Images from '@salesforce/resourceUrl/mtb_Login_Images';
import mtp_CourcePage2_Css from '@salesforce/resourceUrl/mtp_CourcePage2_Css';
import getModuleTasks from '@salesforce/apex/mtp_CoursePage2Controller.getModuleTasks';


export default class Mtp_TaskPage extends LightningElement {
    @track isShowModal = false;
    @track taskName;
    @track taskDescription;
    // @track taskId


    @track moduleId;
    @track taskList = []
    connectedCallback() {
        const queryString = window.location.search;
        this.moduleId = (queryString.substring(queryString.length, queryString.indexOf("=") + 1));
        getModuleTasks({ getModuleId: this.moduleId })
            .then(result => {
                console.log({ result });
                this.taskList = result;
            })
            .catch(error => {
                this.error = error;
                console.log(this.error);
            });



    }
    renderedCallback() {
        Promise.all([
                loadStyle(this, mtp_CourcePage2_Css)
            ]).then(() => {
                console.log('Css loaded');
            })
            .catch(error => {
                console.log({ error });
            });
    }

    // Get Background Image
    get backgroundImage() {
        return `background-image:url(${mtb_Login_Images + '/course_image.png'})`;
    }


    showModalBox(event) {
        this.isShowModal = true;
        this.taskName = event.target.name;
        var description = event.target.value;
        description = description.replaceAll(/(<([^>]+)>)/ig, '');
        this.taskDescription = description;
        // this.taskId = event.target.id;
        // console.log(this.taskId);

    }

    hideModalBox() {
        this.isShowModal = false;
    }
    redirectToCompleted(event) {
        this.isShowModal = false;

    }

}