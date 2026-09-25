# PokeStock

Myyntivalmiin Pokemon-korttivaraston hallintasovellus. Laurea-kurssityö
(SQL Tietokanta -projekti): sovellusidea, relaatiotietokantamalli ja
esimerkkidata, jotka pohjautuvat oikeaan korttikokoelmaan.

## Kansiorakenne

```
database/     SQL-skriptit, aja jarjestyksessa 01 -> 04
  01_schema.sql                    Taulut: Kategoria, Kortti, Myynti
  02_poromagia_hinnasto_import.sql Viitehintataulu (Poromagia.com, ~36 600 riv.)
  03_esimerkkidata.sql             229 oikeaa korttia + 1 myyntiesimerkki
  04_kyselyt.sql                   Valmiit tarkistus-/kayttokyselyt

ui/
  pokestock_app.html          Itsenainen selainsovellus (korttilista, haku,
                               kategoriasuodatus, lisays, myyty-merkinta)

data/
  kortti_master.csv                 229 korttia: nimi, numero, kategoria, arvo (EUR)
  hinnasto_muut.csv                 Kuvista tunnistetut kortit + hinta-arviot
  hinnasto_base_set.csv             Viitehinnasto: koko 1999 Base Set
  hinnasto_sm_unbroken_bonds.csv    Viitehinnasto: koko SM Unbroken Bonds -setti

esitys/
  PokeStock.pptx / .pdf       Kurssin Tehtava 1 -esitys

dokumentaatio/
  AI_kaytto_raporttiin.md     Valmis kappale AI-kayton dokumentointiin raporttiin

fullstack/
  Node.js + Express + MongoDB + Docker -versio samasta ideasta,
  full stack -web-kehityksen kurssityota varten. Katso fullstack/README.md.
```

## Kayttoonotto (MySQL / MariaDB)

```bash
mysql -u root < database/01_schema.sql
mysql -u root < database/02_poromagia_hinnasto_import.sql
mysql -u root < database/03_esimerkkidata.sql
mysql -u root < database/04_kyselyt.sql
```

Kaikki nelja skriptia on ajettu ja validoitu paikallista MariaDB-instanssia
vastaan (229 riviä Kortti-tauluun, FK-relaatiot toimivat, tarkistuskyselyt
palauttavat oikean tuloksen).

## UI

`ui/pokestock_app.html` on itsenainen tiedosto — avaa suoraan selaimessa.
Data on tallennettu sivun mukana; lisatyt/myydyksi merkityt kortit
tallentuvat selaimen localStorageen. Ei (viela) suoraa yhteytta
tietokantaan.

## Data-alkupera

Kortit tunnistettiin Google Drive -kansiosta (kuvat) tekoalyavusteisesti,
hinnoiteltiin verkkohauilla ja tasmatettiin Poromagian
(poromagia.com) oikeaan hintalistaan. Katso dokumentaatio/AI_kaytto_raporttiin.md.
