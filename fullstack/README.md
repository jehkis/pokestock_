# PokeStock — Full Stack (Node.js + Express + MongoDB + Docker)

REST API ja siihen kytketty kauppasivusto Joonan Pokemon-korttikokoelmalle.
Tehty full stack -web-kehityksen kurssityötä varten (Node.js, Express, MongoDB, REST API, Docker).

Tämä on erillinen, itsenäinen kokonaisuus samasta PokeStock-ideasta kuin
`database/`-kansion SQL-versio — tässä sama data mallinnetaan
dokumenttitietokantaan (MongoDB) relaatiotietokannan sijaan.

## Kaksi näkymää

- **`/` (public/index.html)** — julkinen kauppasivu. Kuka tahansa (esim.
  Facebook-ryhmän jäsen) voi selata myynnissä olevia kortteja ja tehdä
  tarjouksen. Ei vaadi kirjautumista.
- **`/admin.html`** — ylläpito: korttien lisäys/muokkaus/poisto ja
  saapuneiden tarjousten hyväksyntä/hylkäys. Vaatii ylläpitäjän avaimen
  (kysytään selaimessa kertaalleen, tallentuu istunnon ajaksi).

## Tarjousvuo

1. Ostaja selaa `/`-sivua, painaa "Tee tarjous" jollekin kortille, täyttää
   nimen, sähköpostin ja tarjotun hinnan.
2. Kortti merkitään automaattisesti "tarjottu"-tilaan (ei enää muiden
   tarjottavissa), ja ylläpitäjälle lähtee sähköposti-ilmoitus.
3. Ylläpitäjä käy `/admin.html`-sivulla hyväksymässä tai hylkäämässä
   tarjouksen.
   - **Hyväksytty** → kortti merkitään myydyksi, ostajalle lähtee
     vahvistus-sähköposti. Myyjä sopii toimituksesta/maksusta suoraan
     ostajan kanssa sähköpostitse — sovellus ei käsittele maksuja.
   - **Hylätty** → kortti vapautuu takaisin myyntiin.

## Arkkitehtuuri

```
selain (public/index.html, public/admin.html)
      │  fetch()
      ▼
Express REST API (server.js, portti 3000)
      │  mongoose              │  nodemailer
      ▼                        ▼
MongoDB (portti 27017)      Gmail SMTP
```

## Kansiorakenne

```
docker-compose.yml        Mongo + API, yhdellä komennolla pystyyn
api/
  server.js               Express-sovelluksen käynnistys
  src/
    db.js                 MongoDB-yhteys (uudelleenyrityksellä)
    middleware/adminAuth.js  Kevyt admin-avain-suojaus
    models/Card.js         Kortti-skeema (myynti + tarjottu-tila)
    models/Tarjous.js      Ostotarjous-skeema
    routes/cards.js         Kortti-CRUD (muokkaavat reitit vaativat admin-avaimen)
    routes/tarjoukset.js    Tarjouksen jättö (julkinen) + hyväksyntä/hylkäys (admin)
    routes/hintahaku.js     Hinta-arvion haku TCGdex-rajapinnasta (admin)
    services/tcgdex.js      TCGdex-haku: nimi+numero -> Cardmarket-hinta (EUR)
    services/email.js       Sähköposti-ilmoitukset (Nodemailer + Gmail)
  seed/
    seed.js                 Alustaa kannan 265 omalla kortilla
  public/
    index.html               JULKINEN kauppasivu
    admin.html                YLLÄPITO: hallinta + tarjoukset
  Dockerfile
  package.json
  .env.example
```

## REST-rajapinta

| Metodi | Polku                              | Suojaus  | Kuvaus |
|--------|--------------------------------------|----------|--------|
| GET    | /api/cards                          | julkinen | Listaa kortit (query: kategoria, search, sort, order, myyty) |
| GET    | /api/cards/stats                    | julkinen | Kokoelman arvo ja lkm kategorioittain |
| GET    | /api/cards/:id                       | julkinen | Yksi kortti |
| POST   | /api/cards                          | **admin** | Lisää kortti |
| PUT    | /api/cards/:id                       | **admin** | Muokkaa korttia |
| PATCH  | /api/cards/:id/myyty                  | **admin** | Merkitse myydyksi / palauta myymättömäksi |
| DELETE | /api/cards/:id                       | **admin** | Poista kortti |
| POST   | /api/cards/:id/tarjous                | julkinen | Jätä ostotarjous kortista |
| GET    | /api/tarjoukset?tila=odottaa          | **admin** | Listaa tarjoukset |
| PATCH  | /api/tarjoukset/:id                   | **admin** | `{ "paatos": "hyvaksy" \| "hylkaa" }` |
| GET    | /api/hinta-haku?nimi=X&numero=Y&holo=true | **admin** | Cardmarket-hinta-arvio (EUR) TCGdex-rajapinnasta |

Admin-reitit vaativat headerin `x-admin-key: <ADMIN_KEY>`.

## Hinta-arvion haku (TCGdex)

Ylläpitosivun "Lisää kortti" -lomakkeessa nappi **Hae hinta-arvio** kysyy
hinnan livenä [TCGdex](https://tcgdex.dev)-rajapinnasta (ei API-avainta).
Hinta on Cardmarketin trendihinta euroina; jos kortti on holo tai reverse holo,
rastita "Holo" niin käytetään holo-hintaa. Arvo-kenttä täyttyy automaattisesti
ja sitä voi muokata ennen tallennusta.

- Haku: nimi + korttinumero (`091/086`). Etunollat ja setin koko (`/086`)
  huomioidaan, jotta oikea setti valikoituu, kun samalla numerolla on useita kortteja.
- Jos numerolla löytyy useita settejä, muut näytetään lomakkeessa tarkistettavaksi.
- Hinnat päivittyvät Cardmarketissa kerran päivässä, joten hakutulokset
  pidetään palvelimen muistissa tunnin ajan.
- Haku vaatii ylläpitäjän avaimen, jottei palvelinta voi käyttää välityspalvelimena.
- Cardmarketin oma API ei ole käytössä: se ei tällä hetkellä ota vastaan hakemuksia.

## Testit

```bash
cd api
npm install
npm test        # 21 testiä: hintahaun logiikka + reitti + admin-avain
```

## Sähköpostin käyttöönotto (Gmail App Password)

Koska tili on erillinen eikä henkilökohtainen Gmail, tee näin:
1. Kirjaudu sillä Gmail-tilillä osoitteeseen myaccount.google.com/security
2. Ota käyttöön kaksivaiheinen vahvistus (pakollinen App Password -ominaisuudelle)
3. Hae "App Passwords" / "Sovelluskohtaiset salasanat", luo uusi (esim. nimellä "PokeStock")
4. Kopioi 16-merkkinen salasana `.env`-tiedoston `GMAIL_APP_PASSWORD`-arvoksi
   (**ei** tilin normaalia salasanaa)

## Käyttöönotto

### Docker (suositeltu)

```bash
cd pokestock_fullstack
cp api/.env.example api/.env     # tayta ADMIN_KEY, GMAIL_USER, GMAIL_APP_PASSWORD
docker compose up --build
```

Kun molemmat kontit ovat käynnissä, aja kannan alustus kerran:
```bash
docker compose exec api npm run seed              # 265 omaa korttia
```

Avaa selaimessa:
- Julkinen kauppa: **http://localhost:3000**
- Ylläpito: **http://localhost:3000/admin.html**

### Ilman Dockeria (paikallinen Node + oma Mongo)

```bash
cd api
npm install
cp .env.example .env       # tayta ADMIN_KEY, GMAIL_USER, GMAIL_APP_PASSWORD, MONGO_URI
npm run seed                # alustaa 265 kortilla
npm start
```

## Huomio testauksesta

Koodi on kirjoitettu ja tarkistettu syntaksiltaan (`node --check` jokaiselle
tiedostolle), riippuvuudet on validoitu asentumaan (`npm install`, 0
haavoittuvuutta), reitityksen limittyminen (`/api/cards/:id/tarjous` vs.
`/api/cards/:id`) on testattu erikseen eristetyllä Express-sovelluksella, ja
`requireAdmin`-väliohjelmisto (oikea/väärä/puuttuva avain) on testattu
yksikkötestillä. **TCGdex-hakua ei ole ajettu oikeaa rajapintaa vasten (sandboxista ei pääse ulkoisiin rajapintoihin) — se on testattu vale-vastauksilla, jotka noudattavat rajapinnan dokumentaatiota. Kokeile hakua itse oikealla kortilla ensimmäisenä. Koko putkea Dockerissa asti (`docker compose up`), oikeaa
sähköpostin lähetystä, tai selaimen kautta tehtyä täyttä käyttäjäpolkua ei
ole voitu ajaa läpi tässä kehitysympäristössä**, koska sandboxilla ei ole
verkkoyhteyttä Docker Hubiin, MongoDB:hen tai Gmailin SMTP-palvelimeen. Aja
`docker compose up --build` itse ensimmäisenä askeleena ja ilmoita jos jokin
ei toimi odotetusti — erityisesti sähköpostin lähetys kannattaa testata
tekemällä itse testitarjous heti käyttöönoton jälkeen.
