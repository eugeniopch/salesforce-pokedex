import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Pokemon__c.Name',
    'Pokemon__c.Sprite_URL__c',
    'Pokemon__c.Primary_Type__c',
    'Pokemon__c.Secondary_Type__c'
];

export default class PokemonHeader extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    get name() {
        return this.record?.data?.fields?.Name?.value;
    }

    get spriteUrl() {
        return this.record?.data?.fields?.Sprite_URL__c?.value;
    }

    get primaryType() {
        return this.record?.data?.fields?.Primary_Type__c?.value || '';
    }

    get secondaryType() {
        const value = this.record?.data?.fields?.Secondary_Type__c?.value;
        return value ? ` / ${value}` : '';
    }
}
