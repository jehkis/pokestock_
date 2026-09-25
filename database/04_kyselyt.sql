-- =====================================================
-- PokeStock -- taulujen avaus / katselukyselyt
-- Aja pokestock_schema.sql, poromagia_hinnasto_import.sql
-- ja pokestock_esimerkkidata.sql ensin.
-- =====================================================

USE pokestock;

-- ---------------------------------------------------
-- 1. Taulujen sisalto sellaisenaan
-- ---------------------------------------------------

SELECT * FROM Kategoria;

SELECT * FROM Kortti;

SELECT * FROM Myynti;

SELECT * FROM Poromagia_Hinnasto LIMIT 100;

-- ---------------------------------------------------
-- 2. Kortit arvokkaimmasta halvimpaan
-- ---------------------------------------------------

SELECT nimi, arvo, kunto
FROM Kortti
ORDER BY arvo DESC;

-- ---------------------------------------------------
-- 3. Kortit kategorioittain (esim. pelkat kiiltokortit)
-- ---------------------------------------------------

SELECT k.nimi, k.arvo, k.kunto
FROM Kortti k
JOIN Kategoria kat ON k.kategoria_id = kat.id
WHERE kat.nimi = 'Kiilto'
ORDER BY k.arvo DESC;

-- ---------------------------------------------------
-- 4. Kokoelman kokonaisarvo kategorioittain
-- ---------------------------------------------------

SELECT kat.nimi AS kategoria, COUNT(*) AS lkm, ROUND(SUM(k.arvo), 2) AS yhteisarvo
FROM Kortti k
JOIN Kategoria kat ON k.kategoria_id = kat.id
GROUP BY kat.nimi
ORDER BY yhteisarvo DESC;

-- ---------------------------------------------------
-- 5. Viela myymattomat kortit (arvokkaimmasta alkaen)
-- ---------------------------------------------------

SELECT k.nimi, k.arvo
FROM Kortti k
LEFT JOIN Myynti m ON k.id = m.kortti_id AND m.myyty = TRUE
WHERE m.id IS NULL
ORDER BY k.arvo DESC;

-- ---------------------------------------------------
-- 6. Jo myydyt kortit ja kenelle
-- ---------------------------------------------------

SELECT k.nimi, m.hinta, m.ostaja, m.myyty_pvm
FROM Myynti m
JOIN Kortti k ON m.kortti_id = k.id
WHERE m.myyty = TRUE;

-- ---------------------------------------------------
-- 7. Poromagia-viitehinta samalle kortille (nimen perusteella)
--    Esimerkki: nayttaa oman kortin arvon vs. Poromagian pyyntihinnan
-- ---------------------------------------------------

-- Kortin numero on aina nimen viimeinen sana (esim. "Gardevoir & Sylveon-GX 205/214" -> "205/214")
SELECT
    k.nimi                AS oma_kortti,
    k.arvo                AS oma_arvo,
    p.kortti_nimi         AS poromagia_kortti,
    p.hinta_eur           AS poromagia_hinta,
    p.varastossa_kpl
FROM Kortti k
LEFT JOIN Poromagia_Hinnasto p
    ON p.kortti_nimi LIKE CONCAT('% ', SUBSTRING_INDEX(k.nimi, ' ', -1), ' %')
    AND p.kortti_nimi NOT LIKE '%Reverse Holo%'
ORDER BY k.arvo DESC
LIMIT 30;
