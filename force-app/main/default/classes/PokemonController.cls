public with sharing class PokemonController {

    @AuraEnabled(cacheable=true)
    public static List<Pokemon__c> getAllPokemon() {
        return [
            SELECT Name,
                   Number__c,
                   Primary_Type__c,
                   Secondary_Type__c,
                   Height__c,
                   Weight__c,
                   Sprite_URL__c
            FROM Pokemon__c
            ORDER BY Number__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<PokeApiService.PokemonDTO> getExternalPokemon(Integer offset, Integer limitSize) {
        return PokeApiService.fetchPokemon(offset, limitSize);
    }
}


