# Tekoälyn käyttö tässä projektissa

Tämän kurssityön suunnittelussa ja toteutuksessa on hyödynnetty Anthropicin Claude-tekoälyä (Claude Sonnet, claude.ai) seuraavissa vaiheissa:

1. **Esityksen (PokeStock.pptx) sisällön ja rakenteen laadinta** — sovelluskuvaus, käyttötapaukset, UI-mallit ja tietokantamallin visualisointi tuotettiin yhdessä tekoälyn kanssa.

2. **Tietokantaskeeman (pokestock_schema.sql) suunnittelu** — taulurakenteet (Kategoria, Kortti, Myynti), tietotyyppien valinta, primääri- ja viiteavaimet sekä indeksit määriteltiin tekoälyn avustuksella tehtävänannon vaatimusten mukaisesti.

3. **Esimerkkidatan (pokestock_esimerkkidata.sql) kerääminen ja jalostaminen** — tekoäly tunnisti 265 Pokémon-korttia valokuvista (Google Drive), haki niille markkinahintoja verkosta ja täsmäytti hintoja yleiseen markkinahintaviitteeseen. Tunnistus- ja hinnoitteluprosessi eteni useassa vaiheessa, ja lopputulos vietiin SQL-muotoon INSERT-lauseiksi.

4. **Skriptien ajaminen ja testaus** — pokestock_schema.sql ja pokestock_esimerkkidata.sql on ajettu ja validoitu toimiviksi MariaDB-tietokantaa vasten (265 riviä Kortti-tauluun, viiteavainsuhteet toimivat, tarkistuskyselyt tuottavat oikean tuloksen).

5. **Toteutusvaihe (tehtävät 3–6), Claude Code (Claude Opus 5.5)**
   - Suunnitelman tauluihin (Kategoria, Kortti, Myynti, Tarjous) lisättiin toteutusvaiheessa taulut Asiakas ja Myyntikanava. Myynti viittaa niihin viiteavaimilla. Testidataa: 265 korttia, 5 asiakasta, 4 myyntikanavaa, 10 myyntiä ja 7 tarjousta.
   - Tehtävän 4 kymmenen SELECT-kyselyä (AS, OR, AND, COUNT/SUM/AVG, GROUP BY, HAVING, LEFT JOIN, INNER JOIN) laadittiin tekoälyn avulla.
   - Tekoäly testasi skriptit sekä varmuuskopioinnin ja palautuksen (mysqldump → uusi kanta `pokestock_palautus`) paikallisella MySQL-palvelimella. Se myös laati ohjeen ja videon rungon (`database/05_varmuuskopio_ja_palautus.md`).
   - Videotallenteen kuvaosuus käsikirjoitettiin ja nauhoitettiin tekoälyn avulla. Tietokannan luonti, alustus, kyselyt ja palautuksen tarkistus ajettiin MySQL Workbench 26.7:ssä, jota tekoäly ohjasi automaattisesti. Varmuuskopiointi (mysqldump) ja palautus ajettiin päätteessä vhs-työkalulla (`video/`-kansio). Komennot ajettiin oikeasti MySQL-palvelimella, eikä tuloksia ole muokattu.
   - Videon selostus on äänitetty itse.

Kaikki lopullinen sisältö (kategoriointi, tietokantarakenne, liiketoimintalogiikka) on tarkistettu ja hyväksytty ihmisen toimesta ennen palautusta.
