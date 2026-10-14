# Tehtävä 5: Varmuuskopiointi ja palautus toiseen tietokantaan

Varmuuskopion muoto on SQL-dump (`.sql`): tekstitiedosto, joka sisältää
`CREATE TABLE`- ja `INSERT`-lauseet. Sen voi siirtää minkä tahansa
MySQL/MariaDB-palvelimen välillä.

## A) Komentorivi (mysqldump)

```bash
# 1. Varmuuskopio pokestock-kannasta
mysqldump -u root -p --single-transaction --set-gtid-purged=OFF pokestock > pokestock_backup.sql

# 2. Uusi, tyhjä tietokanta
mysql -u root -p -e "CREATE DATABASE pokestock_palautus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 3. Palautus uuteen kantaan
mysql -u root -p pokestock_palautus < pokestock_backup.sql
```

`--set-gtid-purged=OFF` on tarpeen MySQL 8+:ssa. Ilman sitä palautus samalle
palvelimelle kaatuu virheeseen `ERROR 3546 ... GTID_PURGED cannot be changed`.
MariaDB:ssä valitsinta ei ole, joten jätä se pois.

## B) HeidiSQL

1. Klikkaa `pokestock`-kantaa hiiren oikealla → **Export database as SQL**.
2. Rastita *Create* (tables) ja *Data: Insert*. Jätä *Database: Create* pois,
   jotta dumppi ei luo vanhaa kantaa uudelleen. Output: *Single .sql file* →
   `pokestock_backup.sql` → **Export**.
3. Luo uusi kanta: oikea klikkaus yhteyteen → **Create new → Database** →
   nimeksi `pokestock_palautus`, collation `utf8mb4_unicode_ci`.
4. Valitse `pokestock_palautus` → **File → Run SQL file...** → `pokestock_backup.sql`.

## Uuden kannan aktivointi ja tarkistus

```sql
USE pokestock_palautus;
SELECT DATABASE() AS aktiivinen_kanta;

SELECT 'Kategoria' AS taulu, COUNT(*) AS rivit FROM Kategoria
UNION ALL SELECT 'Kortti',       COUNT(*) FROM Kortti
UNION ALL SELECT 'Asiakas',      COUNT(*) FROM Asiakas
UNION ALL SELECT 'Myyntikanava', COUNT(*) FROM Myyntikanava
UNION ALL SELECT 'Myynti',       COUNT(*) FROM Myynti
UNION ALL SELECT 'Tarjous',      COUNT(*) FROM Tarjous;
-- Odotettu: 7 / 265 / 5 / 4 / 10 / 7
```

Lopuksi voi ajaa `04_kyselyt.sql`:n uutta kantaa vasten vaihtamalla
tiedoston alun `USE pokestock;` muotoon `USE pokestock_palautus;`.

---

# Tehtävä 6: Videon runko (n. 8–12 min)

1. **Esittely (1 min).** Mikä PokeStock on: Pokémon-korttivaraston ja -myynnin hallinta.
2. **Tietokantamalli (1–2 min).** Kuusi taulua ja niiden suhteet:
   - Kategoria 1–N Kortti
   - Kortti 1–N Myynti
   - Asiakas 1–N Myynti
   - Myyntikanava 1–N Myynti
   - Kortti 1–N Tarjous
   Näytä pää- ja viiteavaimet `01_schema.sql`:stä.
3. **Luonti (1 min).** Aja `01_schema.sql` ja näytä taulut HeidiSQL:n puussa.
4. **Alustus (1–2 min).** Aja `03_esimerkkidata.sql` ja näytä rivimäärät
   tarkistuskyselyllä (yllä).
5. **Kyselyt (3–4 min).** Aja `04_kyselyt.sql` kysely kerrallaan. Kerro, mikä
   vaatimus kustakin täyttyy (AS, OR, AND, COUNT/SUM/AVG, GROUP BY, HAVING,
   LEFT JOIN, INNER JOIN). Kyselyssä 8 näkyy LEFT JOINin ero: Jari Mäkisellä on 0 ostoa.
6. **Varmuuskopio (1 min).** Ota dump (A tai B) ja avaa tiedosto hetkeksi.
7. **Palautus (1–2 min).** Luo `pokestock_palautus`, palauta dump,
   `USE pokestock_palautus;` ja aja tarkistuskysely.
8. **Lopuksi.** Mainitse tekoälyn käyttö (ks. `dokumentaatio/AI_kaytto_raporttiin.md`).
