# PokeStock — Full Stack (Node.js + Express + MongoDB + Docker)

REST API ja siihen kytketty selainkäyttöliittymä Joonan Pokemon-korttikokoelmalle.
Tehty full stack -web-kehityksen kurssityötä varten (Node.js, Express, MongoDB, REST API, Docker).

Tämä on erillinen, itsenäinen kokonaisuus samasta PokeStock-ideasta kuin
`database/`-kansion SQL-versio — tässä sama data mallinnetaan
dokumenttitietokantaan (MongoDB) relaatiotietokannan sijaan.

## Arkkitehtuuri

```
selain (public/index.html)
      │  fetch()
      ▼
Express REST API (server.js, portti 3000)
      │  mongoose
      ▼
MongoDB (portti 27017)
```

Yksi Express-palvelin sekä tarjoilee staattisen käyttöliittymän
(`api/public/index.html`) että rajapinnan (`/api/*`), joten selaimessa ei
tarvita erillistä CORS-määrittelyä.

## Kansiorakenne

```
docker-compose.yml        Mongo + API, yhdellä komennolla pystyyn
api/
  server.js               Express-sovelluksen käynnistys
  src/
    db.js                 MongoDB-yhteys (uudelleenyrityksellä)
    models/Card.js         Mongoose-skeema (kortti + upotettu myyntitieto)
    routes/cards.js         REST-reitit: CRUD + myynti + tilastot
  seed/
    seed.js                Alustaa kannan oikealla 265 kortin datalla
    kortit.json             Data (sama kuin SQL-version kortti_master.csv)
  public/
    index.html              Selainkäyttöliittymä, kutsuu /api/cards
  Dockerfile
  package.json
  .env.example
```

## REST-rajapinta

| Metodi | Polku                    | Kuvaus                                 |
|--------|---------------------------|-----------------------------------------|
| GET    | /api/cards                | Listaa kortit (query: kategoria, search, sort, order, myyty) |
| GET    | /api/cards/stats          | Kokoelman arvo ja lkm kategorioittain  |
| GET    | /api/cards/:id             | Yksi kortti                             |
| POST   | /api/cards                | Lisää kortti                            |
| PUT    | /api/cards/:id             | Muokkaa korttia                         |
| PATCH  | /api/cards/:id/myyty        | Merkitse myydyksi / palauta myymättömäksi |
| DELETE | /api/cards/:id             | Poista kortti                           |
| GET    | /api/hinta-haku?nimi=X&numero=Y | Hakee hinnan Poromagian 36 600 rivin viitehinnastosta |

Hintahaku-esimerkki:
```
GET /api/hinta-haku?nimi=Charizard%20EX&numero=12/108
→ { "loytyi": true, "paras": { "kortti_nimi": "...", "hinta_eur": 9.50, ... }, "ehdotukset": [...] }
```
UI:n "Lisää kortti" -lomakkeessa on nappi "Hae Poromagialta", joka täyttää
Arvo-kentän automaattisesti tämän haun perusteella — voit silti muokata
hintaa käsin ennen tallennusta.

## Käyttöönotto

### Docker (suositeltu)

```bash
cd pokestock_fullstack
docker compose up --build
```

Kun molemmat kontit ovat käynnissä, aja kannan alustus kerran:
```bash
docker compose exec api npm run seed              # 265 omaa korttia
docker compose exec api npm run seed:poromagia     # Poromagian 36 600 rivin viitehinnasto (kestää hetken)
```

Avaa selaimessa: **http://localhost:3000**

### Ilman Dockeria (paikallinen Node + oma Mongo)

```bash
cd api
npm install
cp .env.example .env      # muokkaa MONGO_URI tarvittaessa
npm run seed               # alustaa 265 kortilla
npm run seed:poromagia     # Poromagian viitehinnasto (36 600 riviä)
npm start
```

## Huomio testauksesta

Koodi on kirjoitettu ja tarkistettu syntaksiltaan (`node --check` jokaiselle
tiedostolle) ja riippuvuudet on validoitu asentumaan (`npm install`).
Mongo-yhteyden virhekäsittely on testattu erikseen oikeaa
`ECONNREFUSED`-tilannetta vasten. **Koko putkea Dockerissa asti (`docker
compose up`) ei ole voitu ajaa läpi tässä kehitysympäristössä**, koska
sandboxilla ei ole verkkoyhteyttä Docker Hubiin tai MongoDBn
asennuslähteisiin. Aja `docker compose up --build` itse ensimmäisenä
askeleena ja ilmoita jos jokin ei toimi odotetusti.
