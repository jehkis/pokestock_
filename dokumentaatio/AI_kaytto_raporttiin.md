# Tekoälyn käyttö tässä projektissa

Tämän kurssityön suunnittelussa ja toteutuksessa on hyödynnetty Anthropicin Claude-tekoälyä (Claude Sonnet, claude.ai) seuraavissa vaiheissa:

1. **Esityksen (PokeStock.pptx) sisällön ja rakenteen laadinta** — sovelluskuvaus, käyttötapaukset, UI-mallit ja tietokantamallin visualisointi tuotettiin yhdessä tekoälyn kanssa.

2. **Tietokantaskeeman (pokestock_schema.sql) suunnittelu** — taulurakenteet (Kategoria, Kortti, Myynti), tietotyyppien valinta, primääri- ja viiteavaimet sekä indeksit määriteltiin tekoälyn avustuksella tehtävänannon vaatimusten mukaisesti.

3. **Esimerkkidatan (pokestock_esimerkkidata.sql) kerääminen ja jalostaminen** — tekoäly tunnisti 229 Pokémon-korttia valokuvista (Google Drive), haki niille markkinahintoja verkosta ja täsmäytti hintoja Poromagia-verkkokaupan (poromagia.com) todelliseen hintalistaan. Tunnistus- ja hinnoitteluprosessi eteni useassa vaiheessa, ja lopputulos vietiin SQL-muotoon INSERT-lauseiksi.

4. **Skriptien ajaminen ja testaus** — pokestock_schema.sql ja pokestock_esimerkkidata.sql on ajettu ja validoitu toimiviksi MariaDB-tietokantaa vasten (229 riviä Kortti-tauluun, viiteavainsuhteet toimivat, tarkistuskyselyt tuottavat oikean tuloksen).

Kaikki lopullinen sisältö (kategoriointi, tietokantarakenne, liiketoimintalogiikka) on tarkistettu ja hyväksytty ihmisen toimesta ennen palautusta.
