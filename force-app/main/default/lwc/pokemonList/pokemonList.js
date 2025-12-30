import { LightningElement, wire } from 'lwc';
import getAllPokemon from '@salesforce/apex/PokemonController.getAllPokemon';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import POKEMON_OBJECT from '@salesforce/schema/Pokemon__c';
import PRIMARY_TYPE_FIELD from '@salesforce/schema/Pokemon__c.Primary_Type__c';

import { NavigationMixin } from 'lightning/navigation';

export default class PokemonList extends NavigationMixin(LightningElement) {

    // =========================
    // Estado del componente
    // =========================
    searchTerm = '';
    selectedType = '';
    debounceTimeout;

    // =========================
    // Datos (Apex)
    // =========================
    @wire(getAllPokemon)
    pokemons;

    // =========================
    // Metadata (Picklist)
    // =========================
    @wire(getObjectInfo, { objectApiName: POKEMON_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PRIMARY_TYPE_FIELD
    })
    typePicklist;

    // =========================
    // Handlers UI
    // =========================
    handleSearch(event) {
        const value = event.target.value.toLowerCase();

        window.clearTimeout(this.debounceTimeout);

        this.debounceTimeout = window.setTimeout(() => {
            this.searchTerm = value;
        }, 300);
    }

    clearSearch() {
        this.searchTerm = '';
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
    }

    handleCardClick(event) {
        const recordId = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Pokemon__c',
                actionName: 'view'
            }
        });
    }

    // =========================
    // Datos filtrados (buscador + tipo)
    // =========================
    get filteredPokemons() {
        if (!this.pokemons.data) {
            return [];
        }

        return this.pokemons.data.filter(p => {
            const matchesName =
                !this.searchTerm ||
                p.Name.toLowerCase().includes(this.searchTerm);

            const matchesType =
                !this.selectedType ||
                p.Primary_Type__c === this.selectedType;

            return matchesName && matchesType;
        });
    }

    // Crea una opción fake arriba de la lista de tipos, que es vacía
    
    get typeOptions() {
        if (!this.typePicklist.data) {
            return [];
        }

        return [
            { label: 'All types', value: '' },
            ...this.typePicklist.data.values
        ];
    }

}

