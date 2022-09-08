import { LightningElement, track } from 'lwc';
const options = [
                    {'label':'India','value':'India'},
                    {'label':'USA','value':'USA'},
                    {'label':'China','value':'China'},
                    {'label':'Rusia','value':'Rusia'}
                ];
 
export default class MultiSelectPickListParent extends LightningElement {
    @track selectedValue;
    @track selectedValueList = [];
    @track options = options;
     
    //for single select picklist
    handleSelectOption(event){
        console.log(event.detail);
        this.selectedValue = event.detail;
    }
 
    //for multiselect picklist
    handleSelectOptionList(event){
        console.log(event.detail);
        this.selectedValueList = event.detail;
        console.log(this.selectedValueList);
    }
}