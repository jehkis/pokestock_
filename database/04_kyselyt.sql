-- =====================================================
-- PokeStock -- Tehtava 4: SQL SELECT -kyselyt
-- Aja ensin 01_schema.sql ja 03_esimerkkidata.sql.
--
-- Vaatimus                      -> kysely
--   AS                          -> 1 (kaytetty myos muissa)
--   OR                          -> 2
--   AND                         -> 3
--   koostefunktio COUNT         -> 4
--   koostefunktio SUM           -> 5
--   koostefunktio AVG (+MIN/MAX)-> 6
--   GROUP BY                    -> 4
--   HAVING                      -> 7
--   LEFT JOIN                   -> 8
--   INNER JOIN                  -> 9 (myös 3, 10)
--   Tarjous-taulu               -> 10
-- =====================================================

USE pokestock;

-- ---------------------------------------------------
-- 1. (AS) Kymmenen arvokkainta korttia ja hinta 10 %:n alennuksella
--    Kayttaja nakee, mitka kortit kannattaa myyda ensin.
-- ---------------------------------------------------
SELECT nimi                   AS kortti,
       arvo                   AS arvo_eur,
       ROUND(arvo * 0.90, 2)  AS alennushinta_eur
FROM Kortti
ORDER BY arvo DESC
LIMIT 10;

-- ---------------------------------------------------
-- 2. (OR) Erityisen hyvakuntoiset (NM/M) TAI yli 50 euron kortit
--    Kortit, jotka kannattaa sailyttaa suojakotelossa.
-- ---------------------------------------------------
SELECT nimi, kunto, arvo
FROM Kortti
WHERE kunto = 'NM/M' OR arvo > 50
ORDER BY arvo DESC;

-- ---------------------------------------------------
-- 3. (AND) Kiiltokortit, joiden arvo on 10-30 euroa
--    Hyva hintaluokka esim. Tori.fi-myyntiin.
-- ---------------------------------------------------
SELECT k.nimi, k.arvo
FROM Kortti k
INNER JOIN Kategoria kat ON k.kategoria_id = kat.id
WHERE kat.nimi = 'Kiilto' AND k.arvo >= 10 AND k.arvo <= 30
ORDER BY k.arvo DESC;

-- ---------------------------------------------------
-- 4. (COUNT + GROUP BY) Korttien maara kategorioittain
-- ---------------------------------------------------
SELECT kat.nimi   AS kategoria,
       COUNT(k.id) AS korttien_lkm
FROM Kategoria kat
INNER JOIN Kortti k ON k.kategoria_id = kat.id
GROUP BY kat.nimi
ORDER BY korttien_lkm DESC;

-- ---------------------------------------------------
-- 5. (SUM) Myyntitulot yhteensa ja provisioiden jalkeen
--    Vain toteutuneet myynnit (myyty = TRUE).
-- ---------------------------------------------------
SELECT SUM(m.hinta)                                            AS myynti_brutto_eur,
       ROUND(SUM(m.hinta * (1 - mk.provisio_prosentti / 100)), 2) AS myynti_netto_eur
FROM Myynti m
INNER JOIN Myyntikanava mk ON m.kanava_id = mk.id
WHERE m.myyty = TRUE;

-- ---------------------------------------------------
-- 6. (AVG, MIN, MAX) Varaston korttien hintatilastot kunnoittain
-- ---------------------------------------------------
SELECT kunto,
       ROUND(AVG(arvo), 2) AS keskiarvo_eur,
       MIN(arvo)           AS halvin_eur,
       MAX(arvo)           AS kallein_eur
FROM Kortti
GROUP BY kunto;

-- ---------------------------------------------------
-- 7. (HAVING) Kanta-asiakkaat: ostaneet vahintaan 2 korttia
-- ---------------------------------------------------
SELECT a.nimi       AS asiakas,
       COUNT(m.id)  AS ostot,
       SUM(m.hinta) AS ostettu_yhteensa_eur
FROM Asiakas a
INNER JOIN Myynti m ON m.asiakas_id = a.id
WHERE m.myyty = TRUE
GROUP BY a.id, a.nimi
HAVING COUNT(m.id) >= 2
ORDER BY ostettu_yhteensa_eur DESC;

-- ---------------------------------------------------
-- 8. (LEFT JOIN) Kaikki asiakkaat ja heidan ostojensa maara
--    LEFT JOIN nayttaa myos asiakkaat, joilla ei ole yhtaan ostoa (0).
-- ---------------------------------------------------
SELECT a.nimi, a.kaupunki,
       COUNT(m.id) AS ostojen_lkm
FROM Asiakas a
LEFT JOIN Myynti m ON m.asiakas_id = a.id AND m.myyty = TRUE
GROUP BY a.id, a.nimi, a.kaupunki
ORDER BY ostojen_lkm DESC;

-- ---------------------------------------------------
-- 9. (INNER JOIN) Myyntiraportti: kortti, ostaja, kanava ja
--    myyntihinnan ero kortin arvioituun arvoon
-- ---------------------------------------------------
SELECT m.myyty_pvm,
       k.nimi                AS kortti,
       a.nimi                AS ostaja,
       mk.nimi               AS kanava,
       m.hinta               AS myyntihinta,
       k.arvo                AS arvioitu_arvo,
       m.hinta - k.arvo      AS ero_eur
FROM Myynti m
INNER JOIN Kortti k        ON m.kortti_id  = k.id
INNER JOIN Asiakas a       ON m.asiakas_id = a.id
INNER JOIN Myyntikanava mk ON m.kanava_id  = mk.id
WHERE m.myyty = TRUE
ORDER BY m.myyty_pvm;

-- ---------------------------------------------------
-- 10. (INNER JOIN + GROUP BY) Tarjousten tilanne: montako tarjousta
--     kussakin tilassa ja paljonko ne ovat keskimäärin kortin arvosta
-- ---------------------------------------------------
SELECT t.tila,
       COUNT(*)                                        AS tarjouksia,
       ROUND(AVG(t.tarjottu_hinta), 2)                 AS keskim_tarjous_eur,
       ROUND(AVG(t.tarjottu_hinta / k.arvo * 100), 1)  AS prosenttia_arvosta
FROM Tarjous t
INNER JOIN Kortti k ON t.kortti_id = k.id
GROUP BY t.tila
ORDER BY tarjouksia DESC;
