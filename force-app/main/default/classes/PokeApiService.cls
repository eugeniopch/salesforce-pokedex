public with sharing class PokeApiService {

    public class PokemonDTO {
        @AuraEnabled public Integer dexNumber;
        @AuraEnabled public String name;
        @AuraEnabled public String spriteUrl;
        @AuraEnabled public String type; // Nuevo campo para el color

        public PokemonDTO(Integer dexNumber, String name, String spriteUrl, String type) {
            this.dexNumber = dexNumber;
            this.name = name;
            this.spriteUrl = spriteUrl;
            this.type = type;
        }
    }

    private class PokeApiListResponse {
        public List<PokeApiListItem> results;
    }
    private class PokeApiListItem {
        public String name;
        public String url;
    }

    public static List<PokemonDTO> fetchPokemon(Integer offset, Integer limitSize) {
        Integer safeOffset = (offset == null) ? 151 : offset;       
        Integer safeLimit  = (limitSize == null) ? 50 : limitSize;  

        if (safeLimit < 1) safeLimit = 1;
        if (safeLimit > 50) safeLimit = 50; // Limitamos a 50 para no exceder los 100 callouts

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        // Usamos la Named Credential
        req.setEndpoint('callout:PokeAPI/pokemon?offset=' + safeOffset + '&limit=' + safeLimit);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new CalloutException('PokeAPI call failed. Status=' + res.getStatus());
        }

        PokeApiListResponse parsed = (PokeApiListResponse) JSON.deserialize(res.getBody(), PokeApiListResponse.class);

        List<PokemonDTO> out = new List<PokemonDTO>();
        if (parsed == null || parsed.results == null) return out;

        for (PokeApiListItem item : parsed.results) {
            Integer id = extractIdFromUrl(item.url);
            String sprite = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/' + id + '.png';
            String displayName = toTitleCase(item.name);
            
            // OBTENEMOS EL TIPO
            String type = fetchType(item.url); 

            out.add(new PokemonDTO(id, displayName, sprite, type));
        }

        return out;
    }

    private static String fetchType(String pokemonUrl) {
        String endpoint = pokemonUrl.replace('https://pokeapi.co/api/v2/', 'callout:PokeAPI/');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        Http h = new Http();
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200) {
                // OPTIMIZACIÓN: Usamos JSONParser en lugar de deserializeUntyped
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    // Buscamos la primera vez que aparezca la clave "types"
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'types') {
                        parser.nextToken(); // Entra al array [
                        parser.nextToken(); // Entra al objeto {
                        while (parser.nextToken() != null) {
                            // Buscamos el nombre del tipo
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'name') {
                                parser.nextToken();
                                return toTitleCase(parser.getText()); // ¡Encontrado! Salimos rápido.
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return 'Normal'; 
    }

    private static Integer extractIdFromUrl(String url) {
        if (String.isBlank(url)) return null;
        String trimmed = url.endsWith('/') ? url.substring(0, url.length() - 1) : url;
        return Integer.valueOf(trimmed.substring(trimmed.lastIndexOf('/') + 1));
    }

    private static String toTitleCase(String s) {
        if (String.isBlank(s)) return s;
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }
}

