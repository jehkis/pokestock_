SELECT 'Kategoria' AS taulu, COUNT(*) AS rivit FROM Kategoria
UNION ALL SELECT 'Kortti',       COUNT(*) FROM Kortti
UNION ALL SELECT 'Asiakas',      COUNT(*) FROM Asiakas
UNION ALL SELECT 'Myyntikanava', COUNT(*) FROM Myyntikanava
UNION ALL SELECT 'Myynti',       COUNT(*) FROM Myynti
UNION ALL SELECT 'Tarjous',      COUNT(*) FROM Tarjous;
