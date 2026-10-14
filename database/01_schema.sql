-- =====================================================
-- PokeStock — tietokannan luontiskripti (MySQL)
-- Taulut: Kategoria, Kortti, Asiakas, Myyntikanava, Myynti, Tarjous
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
-- Taulu: Asiakas
-- Kortin ostaja (tai ostoa tiedustellut henkilö)
-- ---------------------------------------------------
CREATE TABLE Asiakas (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nimi        VARCHAR(100) NOT NULL,
    sahkoposti  VARCHAR(150) UNIQUE,
    kaupunki    VARCHAR(50)
);

-- ---------------------------------------------------
-- Taulu: Myyntikanava
-- Missä kortti myytiin, esim. Tori.fi tai Cardmarket
-- ---------------------------------------------------
CREATE TABLE Myyntikanava (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    nimi                VARCHAR(50) NOT NULL UNIQUE,
    provisio_prosentti  DECIMAL(4,2) NOT NULL DEFAULT 0.00
);

-- ---------------------------------------------------
-- Taulu: Myynti
-- Toteutunut (myyty = TRUE) tai varattu (myyty = FALSE)
-- myyntitapahtuma kortille
-- ---------------------------------------------------
CREATE TABLE Myynti (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    kortti_id   INT NOT NULL,
    asiakas_id  INT NOT NULL,
    kanava_id   INT NOT NULL,
    myyty_pvm   DATE,
    hinta       DECIMAL(10,2),
    myyty       BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_myynti_kortti
        FOREIGN KEY (kortti_id) REFERENCES Kortti(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_myynti_asiakas
        FOREIGN KEY (asiakas_id) REFERENCES Asiakas(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_myynti_kanava
        FOREIGN KEY (kanava_id) REFERENCES Myyntikanava(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ---------------------------------------------------
-- Taulu: Tarjous
-- Ostajan jättämä tarjous kortista; myyjä hyväksyy tai hylkää
-- ---------------------------------------------------
CREATE TABLE Tarjous (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    kortti_id           INT NOT NULL,
    ostajan_nimi        VARCHAR(100) NOT NULL,
    ostajan_sahkoposti  VARCHAR(150) NOT NULL,
    tarjottu_hinta      DECIMAL(10,2) NOT NULL,
    tila                VARCHAR(20) NOT NULL DEFAULT 'odottaa',
    lisatty_pvm         DATE NOT NULL,
    lisatty_aika        TIME NOT NULL,
    CONSTRAINT fk_tarjous_kortti
        FOREIGN KEY (kortti_id) REFERENCES Kortti(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Hakuja nopeuttavat indeksit
CREATE INDEX idx_kortti_kategoria ON Kortti(kategoria_id);
CREATE INDEX idx_kortti_arvo      ON Kortti(arvo DESC);
CREATE INDEX idx_myynti_kortti    ON Myynti(kortti_id);
CREATE INDEX idx_myynti_asiakas   ON Myynti(asiakas_id);
CREATE INDEX idx_tarjous_kortti   ON Tarjous(kortti_id);
