import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import rwdImageMapJs from '@salesforce/resourceUrl/rwdImageMapJs';
import rwdImageMapMinjs from '@salesforce/resourceUrl/rwdImageMapMinjs';
import mtpCoursePage1Img1 from '@salesforce/resourceUrl/mtp_CoursePage1_Img1';
import mtpCoursePage1Img2 from '@salesforce/resourceUrl/mtp_CoursePage1_Img2';
import mtpCoursePage1Img3 from '@salesforce/resourceUrl/mtp_CoursePage1_Img3';
import mtpCoursePage1Img4 from '@salesforce/resourceUrl/mtp_CoursePage1_Img4';
import mtpCoursePage1Img5 from '@salesforce/resourceUrl/mtp_CoursePage1_Img5';
import mtpCoursePage1bg from '@salesforce/resourceUrl/mtp_CoursePage1_bg';
import getcourse from '@salesforce/apex/CourseController.getcourse';



export default class Mtp_CoursePage1 extends NavigationMixin(LightningElement) {

    @track course;
    @track loaction1;
    @track loaction2;
    @track loaction3;
    @track loaction4;
    @track loaction5;
    @track loaction6;

    renderedCallback(){
        Promise.all([
            loadScript(this,jQuery ),
            loadScript(this, rwdImageMapJs),
            loadScript(this,rwdImageMapMinjs),        
        ])
        .then(() => {
            console.log('JQuery loaded.');
        })
        .catch(error=>{
            console.log('Failed to load the JQuery : ' +error);
        });
    }

    connectedCallback(){
        getcourse()
            .then(result => {
                console.log(result);
                this.course = result;
                // result.forEach( element => {
                    
                // });
                console.log(result[0].Id);
            })
            .catch(error => {
                console.log('error');
                console.log({ error });
            });
    }

    cpImg1 = mtpCoursePage1Img1;    //Image beside professional couse text
    cpImg2 = mtpCoursePage1Img2;    //Cat Image
    cpImg3 = mtpCoursePage1Img3;    //Image beside cat
    cpImg4 = mtpCoursePage1Img4;    //Small airplane image
    cpImg5 = mtpCoursePage1Img5;    //Map Image
    cpbgImg = mtpCoursePage1bg;     //Background Image

    imageareaclicked(event){
        var alter = event.target.alt;
        this.course.forEach(element => {
            console.log(element.Course_Index__c);
            if(element.Course_Index__c == alter){
                console.log(element.Id);
                var urlValue = '/s/course/course2?id='+element.Id;
                var pageapiname = 'Course2__c';
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: pageapiname,
                        url: urlValue
                    },
                });
            }
        });
    }
}