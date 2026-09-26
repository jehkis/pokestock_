-- =====================================================
-- PokeStock -- taulujen avaus / katselukyselyt
-- Aja pokestock_schema.sql ja pokestock_esimerkkidata.sql ensin.
-- =====================================================

USE pokestock;

-- ---------------------------------------------------
-- 1. Taulujen sisalto sellaisenaan
-- ---------------------------------------------------

SELECT * FROM Kategoria;

SELECT * FROM Kortti;

SELECT * FROM Myynti;


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
