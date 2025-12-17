import { LightningElement, wire } from 'lwc';
import getAllPokemon from '@salesforce/apex/PokemonController.getAllPokemon';

export default class PokemonList extends LightningElement {

    searchTerm = '';

    @wire(getAllPokemon)
    pokemons;

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get filteredPokemons() {
        if (!this.pokemons.data) {
            return [];
        }

        if (!this.searchTerm) {
            return this.pokemons.data;
        }

        return this.pokemons.data.filter(p =>
            p.Name.toLowerCase().includes(this.searchTerm)
        );
    }
}
