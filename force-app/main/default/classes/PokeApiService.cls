public with sharing class PokeApiService {

    public class PokemonDTO {
        @AuraEnabled public Integer dexNumber;
        @AuraEnabled public String name;
        @AuraEnabled public String spriteUrl;

        public PokemonDTO(Integer dexNumber, String name, String spriteUrl) {
            this.dexNumber = dexNumber;
            this.name = name;
            this.spriteUrl = spriteUrl;
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
        Integer safeOffset = (offset == null) ? 150 : offset;       // 150 => empieza en #151
        Integer safeLimit  = (limitSize == null) ? 50 : limitSize;  // default 50

        if (safeLimit < 1) safeLimit = 1;
        if (safeLimit > 200) safeLimit = 200;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:PokeAPI/pokemon?offset=' + safeOffset + '&limit=' + safeLimit);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new CalloutException('PokeAPI call failed. Status=' + res.getStatus() + ' Body=' + res.getBody());
        }

        PokeApiListResponse parsed =
            (PokeApiListResponse) JSON.deserialize(res.getBody(), PokeApiListResponse.class);

        List<PokemonDTO> out = new List<PokemonDTO>();
        if (parsed == null || parsed.results == null) {
            return out;
        }

        for (PokeApiListItem item : parsed.results) {
            Integer id = extractIdFromUrl(item.url);
            String sprite = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/' + id + '.png';
            String displayName = toTitleCase(item.name);

            out.add(new PokemonDTO(id, displayName, sprite));
        }

        return out;
    }

    private static Integer extractIdFromUrl(String url) {
        if (String.isBlank(url)) return null;

        String trimmed = url.endsWith('/') ? url.substring(0, url.length() - 1) : url;
        Integer lastSlash = trimmed.lastIndexOf('/');
        if (lastSlash < 0 || lastSlash == trimmed.length() - 1) return null;

        String idStr = trimmed.substring(lastSlash + 1);
        return Integer.valueOf(idStr);
    }

    private static String toTitleCase(String s) {
        if (String.isBlank(s)) return s;
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }
}

