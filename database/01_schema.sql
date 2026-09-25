-- =====================================================
-- PokeStock — tietokannan luontiskripti (MySQL)
-- Taulut: Kategoria, Kortti, Myynti
-- =====================================================

DROP DATABASE IF EXISTS pokestock;
CREATE DATABASE pokestock
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE pokestock;

-- ---------------------------------------------------
-- Taulu: Kategoria
-- Kortin luokka, esim. Kiilto, Tähti, Trainer, Bulk...
-- ---------------------------------------------------
CREATE TABLE Kategoria (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    nimi    VARCHAR(50) NOT NULL UNIQUE
);

-- ---------------------------------------------------
-- Taulu: Kortti
-- Yksittäinen myyntiin tarkoitettu kortti
-- ---------------------------------------------------
CREATE TABLE Kortti (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nimi            VARCHAR(100) NOT NULL,
    kategoria_id    INT NOT NULL,
    kunto           VARCHAR(20),
    arvo            DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    lisatty_pvm     DATE NOT NULL,
    lisatty_aika    TIME NOT NULL,
    CONSTRAINT fk_kortti_kategoria
        FOREIGN KEY (kategoria_id) REFERENCES Kategoria(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ---------------------------------------------------
-- Taulu: Myynti
-- Toteutunut tai kirjattu myyntitapahtuma kortille
-- ---------------------------------------------------
CREATE TABLE Myynti (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    kortti_id   INT NOT NULL,
    myyty_pvm   DATE,
    hinta       DECIMAL(10,2),
    ostaja      VARCHAR(100),
    myyty       BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_myynti_kortti
        FOREIGN KEY (kortti_id) REFERENCES Kortti(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Hakuja nopeuttavat indeksit
CREATE INDEX idx_kortti_kategoria ON Kortti(kategoria_id);
CREATE INDEX idx_kortti_arvo      ON Kortti(arvo DESC);
CREATE INDEX idx_myynti_kortti    ON Myynti(kortti_id);
