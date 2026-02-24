# Salesforce Pokédex (LWC + Apex + PokeAPI)

A personal project developed on the Salesforce platform that combines local data management with external service integration to create a functional and dynamic Pokédex.

## 🚀 Features

* **Local Database**: Management of the first 151 Pokémon through the `Pokemon__c` custom object.
* **PokeAPI Integration**: Consumption of the external [PokeAPI](https://pokeapi.co/) to expand the Pokémon list beyond local records.
* **Dynamic Interface**: Lightning Web Component (LWC) featuring a responsive grid and real-time search functionality.
* **Type-based Styling**: Automatic application of background colors on cards based on the Pokémon's primary type (Fire, Water, Grass, etc.), for both local and external data.
* **Navigation**: Integration with `NavigationMixin` to directly access the detailed record of each Pokémon within Salesforce.

## 🛠️ Technical Architecture

* **Frontend**: Lightning Web Components (LWC) utilizing `@wire` for reactive data fetching.
* **Backend**:
* `PokemonController`: Apex controller acting as a bridge between components and business logic.
* `PokeApiService`: Service class specialized in HTTP integration, optimized to process large volumes of JSON data efficiently.


* **Security**: Implementation of **Named Credentials** and **External Credentials** to securely manage authentication and access to external services.
* **Optimization**: Use of `JSONParser` to minimize CPU consumption and respect Salesforce governor limits (`Apex CPU time limit`) when processing multiple external calls.

## ⚙️ Environment Configuration

To ensure the integration works correctly, the following configuration is required in the Salesforce Org:

1. **Named Credentials**: A credential named `PokeAPI` pointing to `https://pokeapi.co/api/v2/`.
2. **External Credentials**: Permission configuration to allow API access through a `Principal` assigned to the user's profile.
3. **CSP Trusted Sites**: Registration of `https://raw.githubusercontent.com` to allow loading Pokémon images (sprites).

## 📈 Future Enhancements (Scalability)

During development, the following strategies were identified to handle even larger data volumes:

* **Batch Apex**: To asynchronously synchronize large amounts of information from the external API with local records.
* **Infinite Scrolling**: Implementation of lazy loading in the LWC to improve interface performance when scrolling through the list.

---

Developed with **Salesforce DX** and **VS Code**.

