import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import mtb_Login_Images from '@salesforce/resourceUrl/mtb_Login_Images';
import login from '@salesforce/apex/mtp_SigninController.login';
import isguest from '@salesforce/user/isGuest';

export default class Mtp_SignIn extends NavigationMixin(LightningElement) {

    boarding_sign = mtb_Login_Images + '/boarding_sign.png';
    presets = mtb_Login_Images + '/presets.png';
    highResLogo = mtb_Login_Images + '/MV_Cloud_HighResLogo.png';
    isguestuser = isguest; //For Checking is user is logged out or not

    @track isSpinner = false;
    username;
    password;

    // Get Background Image
    get backgroundImage() {
        return `background-image:url(${mtb_Login_Images + '/loginImage.png'})`;
    }

    connectedCallback(){
        try {
            this.isSpinner = true;
            if (!this.isguestuser) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__loginPage',
                    attributes: {
                        actionName: 'logout'
                    },
                });
            }
            setTimeout(() => {
                this.isSpinner = false;
            }, 2000);
        } catch (error) {
            console.log({error});
            this.isSpinner = false;
            this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Connected Callback Error', 3000);
        }
    }

    renderedCallback(){

    }

    signin(){
        var inputValues = this.template.querySelectorAll("input");
        inputValues.forEach(element => {
            if (element.name == 'username') {
                this.username = element.value;
            } else if (element.name == 'password'){
                this.password = element.value;
            }
        }); 
        console.log('this.username==>',this.username);
        console.log('this.password==>',this.password);
        login({
            username: this.username,
            password: this.password
        })
        .then((result) => {
            console.log({result});
            if(result != null){
                if (result.startsWith('http')) {
                    window.location.href = result;
                } else {
                    console.log('ELSE');
                    this.template.querySelector('c-mtp_-toast-message').showToast('error', 'Username or password not matched', 3000);
                }
            }
        })
        .catch((error) => {
            console.log({error});
        });
    }
    
}