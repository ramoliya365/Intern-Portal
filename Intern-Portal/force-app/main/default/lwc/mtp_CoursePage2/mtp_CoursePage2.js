import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import mtb_Login_Images from '@salesforce/resourceUrl/mtb_Login_Images';
import mtp_CourcePage2_Css from '@salesforce/resourceUrl/mtp_CourcePage2_Css';
/* Developer Name: Sakina
   Created Date  : 5th September
   Desciption    : Call apex class
*/
import getModuleData from '@salesforce/apex/mtp_CoursePage2Controller.getModuleData';
import { NavigationMixin } from 'lightning/navigation';

export default class Mtp_CoursePage2 extends NavigationMixin(LightningElement) {

    // Mod_1 = mtb_Login_Images + '/Mod_1.png';
    // Mod_2 = mtb_Login_Images + '/Mod_2.png';
    // Mod_3 = mtb_Login_Images + '/Mod_3.png';
    // Mod_4 = mtb_Login_Images + '/Mod_4.png';
    // Mod_5 = mtb_Login_Images + '/Mod_5.png';
    // Mod_6 = mtb_Login_Images + '/Mod_6.png';
    // image_72 = mtb_Login_Images + '/image_72.png';
    // image_73 = mtb_Login_Images + '/image_73.png';

    /* Created Date:- 6th September 2022
       Developer Name : Sakina
    */
    @track moduleName;
    @track moduleDescription;
    @track modules = [];
    @track moduleImages = [];
    @track error;
    @track recordId;


    /***************************************************
           * Author             : Sakina
           * Created Date       : 6/09/2022
           * Last Modified Date : 6/09/2022
           * Description        : get Module Object Name and Description 
                                  from apex for display on site
           ***************************************************/
    connectedCallback() {
        getModuleData()
            .then(result => {
                this.modules = result;

                this.moduleImages.push(
                    mtb_Login_Images + '/Mod_1.png',
                    mtb_Login_Images + '/Mod_2.png',
                    mtb_Login_Images + '/Mod_3.png',
                    mtb_Login_Images + '/Mod_4.png',
                    mtb_Login_Images + '/Mod_5.png',
                    mtb_Login_Images + '/Mod_6.png',
                );


                for (let i = 0; i < this.modules.length; i++) {

                    for (let j = 0; j < this.moduleImages.length; j++) {
                        this.modules[i]['image'] = this.moduleImages[i];
                    }

                }

                console.log(this.modules);
                console.log(this.moduleImages);
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

    /***************************************************
     * Author             : Sakina
     * Created Date       : 7/09/2022
     * Last Modified Date : 7/09/2022
     * Description        : Navigate to task page .
     ***************************************************/

    handleTaskPageNavigation(event) {
        console.log(event.target.id);
        var Id = event.target.id
        this.recordId = Id.substring(0, 18);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Task__c'
            },
            state: {
                recordId: this.recordId
            }
        });
    }


}