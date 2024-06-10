import {LightningElement, wire, api}    from 'lwc';
import {CloseActionScreenEvent}         from 'lightning/actions';
import {ShowToastEvent}                 from 'lightning/platformShowToastEvent';

import {getRecord, getFieldValue, getRecordNotifyChange} from "lightning/uiRecordApi";

//Import custom fields
import CURRENCY_FIELD   from '@salesforce/schema/Bike__c.Currency__c';
import PRICE_FIELD      from '@salesforce/schema/Bike__c.Price__c';

// Import custom labels
import error                from "@salesforce/label/c.Error";
import success              from "@salesforce/label/c.Success";
import bikeCurrency         from "@salesforce/label/c.Bike_Currency";
import errorOccurred        from "@salesforce/label/c.Error_Occurred";
import updateCurrency       from "@salesforce/label/c.Update_Currency";
import bikeCurrencyUpdated  from "@salesforce/label/c.Bike_Currency_Updated";

//Import Alex methods
import getCurrentRateAndUpdateRecord from "@salesforce/apex/BikeChangeCurrencyController.getCurrentRateAndUpdateRecord";

const fields = [CURRENCY_FIELD, PRICE_FIELD];

export default class TestComp extends LightningElement {
    @api recordId;
    @api objectApiName;

    dataBaseCurrency;
    currentCurrency;
    value;
    isShowSpinner = false;

    labels = {
        bikeCurrency,
        bikeCurrencyUpdated,
        errorOccurred,
        updateCurrency,
        error,
        success
    };

    get options() {
        return [
            {label: 'EUR', value: 'EUR'},
            {label: 'USD', value: 'USD'},
            {label: 'SEK', value: 'SEK'}
        ];
    }

    @wire(getRecord, {recordId: "$recordId", fields})
    bike({error, data}) {
        if (data) {
            this.dataBaseCurrency   = getFieldValue(data, CURRENCY_FIELD);
            this.currentCurrency    = getFieldValue(data, CURRENCY_FIELD);
            this.error = undefined;
        } else if (error) {
            this.error  = error;
            this.record = undefined;
        }
    }

    handleChangeCurrencyButton() {
        this.isShowSpinner = true;

        if (this.dataBaseCurrency == this.currentCurrency) {
            this.dispatchEvent(new CloseActionScreenEvent());
        } else {
            getCurrentRateAndUpdateRecord({
                recordId:           this.recordId,
                currentCurrency:    this.currentCurrency
            })
                .then(result => {
                    if(result.length > 0) {
                        const notifyChangeIds = result.map((row) => {
                            return { recordId: row.Id };
                        });
                        getRecordNotifyChange(notifyChangeIds);
                        this.showToast('Success!', this.labels.bikeCurrencyUpdated, 'success');
                        this.dispatchEvent(new CloseActionScreenEvent());
                    } else {
                        this.showToast('Error', this.labels.errorOccurred, 'error');
                    }

                })
                .catch(error => {
                    console.log('error => ' + error);
                    this.showToast('Error!', this.labels.errorOccurred, 'error');
                })
                .finally(() => {
                    this.isShowSpinner = false;
                });
        }

    }

    handleChange(event) {
        this.currentCurrency = event.detail.value;
    }

    showToast(title, message, variant) {
        const toastEvent  = new ShowToastEvent({
            title   : title,
            message : message,
            variant :variant,
            mode:'dismissable'
        });
        this.dispatchEvent(toastEvent);
    }

}