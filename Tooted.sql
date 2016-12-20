-- Kustutab schema ja kõik selle sees ja loob selle uuesti
----------------------------
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;

-- Settingud
CREATE EXTENSION pgcrypto;
SET datestyle = dmy;

-- DROP Laused ---------------------------------------- start
-- Funktsioonid asendavad ennast, kui juba olid loodud.

-- Triggerite DROP laused
DROP TRIGGER IF EXISTS t_kontrolli_seisundi_muutust ON Toode CASCADE;
DROP TRIGGER IF EXISTS t_hash_password ON Isik CASCADE;

-- Vaadete DROP laused
DROP VIEW IF EXISTS Toodete_nimekiri CASCADE;
DROP VIEW IF EXISTS Toodete_kategooriad CASCADE;
DROP VIEW IF EXISTS Toodete_lopetamine CASCADE;

-- Tabelid DROP laused
DROP TABLE IF EXISTS Amet CASCADE;
DROP TABLE IF EXISTS Isik CASCADE;
DROP TABLE IF EXISTS Isiku_seisundi_liik CASCADE;
DROP TABLE IF EXISTS Kliendi_seisundi_liik CASCADE;
DROP TABLE IF EXISTS Klient CASCADE;
DROP TABLE IF EXISTS Riik CASCADE;
DROP TABLE IF EXISTS Toode CASCADE;
DROP TABLE IF EXISTS Tootaja CASCADE;
DROP TABLE IF EXISTS Tootaja_seisundi_liik CASCADE;
DROP TABLE IF EXISTS Toote_kategooria CASCADE;
DROP TABLE IF EXISTS Toote_kategooria_omamine CASCADE;
DROP TABLE IF EXISTS Toote_seisundi_liik CASCADE;

-- Indexid DROP laused
DROP INDEX IF EXISTS Isik_IDX_isik_seisundi_liik_kood CASCADE;
DROP INDEX IF EXISTS Isik_IDX_riik_kood CASCADE;
DROP INDEX IF EXISTS Isik_IDX_perenimi_eesnimi CASCADE;
DROP INDEX IF EXISTS Klient_IDX_kliendi_seisundi_liik_kood CASCADE;
DROP INDEX IF EXISTS Tootaja_IDX_amet_kood CASCADE;
DROP INDEX IF EXISTS Tootaja_IDX_tootaja_seisundi_liik_kood CASCADE;
DROP INDEX IF EXISTS Toode_IDX_riik_kood CASCADE;
DROP INDEX IF EXISTS Toode_IDX_toote_seisundi_liik_kood CASCADE;
DROP INDEX IF EXISTS Toode_IDX_registreerija_id CASCADE;
DROP INDEX IF EXISTS Toote_kategooria_omamine_IDX_toote_kategooria_kood CASCADE;

-- Domeenid DROP laused
DROP DOMAIN IF EXISTS d_nimetus CASCADE;
DROP DOMAIN IF EXISTS d_kirjeldus CASCADE;
-- DROP Laused ---------------------------------------- end

-- Domeenid ---------------------------------------- start
CREATE DOMAIN d_nimetus VARCHAR(50) NOT NULL
CONSTRAINT d_nimetus_CHK_mitte_tuhi CHECK (VALUE !~ '^[[:space:]]*$');

CREATE DOMAIN d_kirjeldus TEXT
CONSTRAINT d_kirjeldus_CHK_mitte_tuhi CHECK (VALUE !~ '^[[:space:]]*$');
-- Domeenid ---------------------------------------- end

-- Baastabelid ---------------------------------------- start
CREATE TABLE Amet
(
    amet_kood SMALLINT NOT NULL,
    nimetus   d_nimetus,
    kirjeldus d_kirjeldus,

    CONSTRAINT Amet_PK_amet_kood PRIMARY KEY (amet_kood),
    CONSTRAINT Amet_UQ_nimetus UNIQUE (nimetus)
);


CREATE TABLE Riik
(
    riik_kood CHAR(3) NOT NULL,
    nimetus   d_nimetus,
    kirjeldus d_kirjeldus,

    CONSTRAINT Riik_PK_riik_kood PRIMARY KEY (riik_kood),
    CONSTRAINT Riik_UQ_nimetus UNIQUE (nimetus),
    CONSTRAINT Riik_CHK_Riik_Kood CHECK (riik_kood ~ '^[[A-Z]{3}]*$')
);

CREATE TABLE Isiku_seisundi_liik
(
    isik_seisundi_liik_kood SMALLINT NOT NULL,
    nimetus                 d_nimetus,
    kirjeldus               d_kirjeldus,

    CONSTRAINT Isiku_seisundi_liik_PK_isik_seisundi_liik_kood PRIMARY KEY (isik_seisundi_liik_kood),
    CONSTRAINT Isiku_seisundi_liik_UQ_nimetus UNIQUE (nimetus)
);

CREATE TABLE Kliendi_seisundi_liik
(
    klient_seisundi_liik_kood SMALLINT NOT NULL,
    nimetus                   d_nimetus,
    kirjeldus                 d_kirjeldus,

    CONSTRAINT Kliendi_seisundi_PK_klient_seisundi_liik_kood PRIMARY KEY (klient_seisundi_liik_kood),
    CONSTRAINT Kliendi_seisundi_UQ_nimetus UNIQUE (nimetus)
);

CREATE TABLE Toote_seisundi_liik
(
    toote_seisundi_liik_kood SMALLINT NOT NULL,
    nimetus                  d_nimetus,
    kirjeldus                d_kirjeldus,

    CONSTRAINT Toote_seisundi_liik_PK_toote_seisundi_liik_kood PRIMARY KEY (toote_seisundi_liik_kood),
    CONSTRAINT Toote_seisundi_liik_UQ_nimetus UNIQUE (nimetus)
);

CREATE TABLE Tootaja_seisundi_liik
(
    tootaja_seisundi_liik_kood SMALLINT NOT NULL,
    nimetus                    d_nimetus,
    kirjeldus                  d_kirjeldus,

    CONSTRAINT Tootaja_seisundi_liik_PK_tootaja_seisundi_liik_kood PRIMARY KEY (tootaja_seisundi_liik_kood),
    CONSTRAINT Tootaja_seisundi_liik_UQ_nimetus UNIQUE (nimetus)
);

CREATE TABLE Toote_kategooria
(
    toote_kategooria_kood SMALLINT NOT NULL,
    nimetus               d_nimetus,
    kirjeldus             d_kirjeldus,

    CONSTRAINT Toote_kategooria_PK_toote_kategooria_kood PRIMARY KEY (toote_kategooria_kood),
    CONSTRAINT Toote_kategooria_UQ_nimetus UNIQUE (nimetus)
);

CREATE TABLE Isik
(
    isik_id                 SERIAL       NOT NULL,
    e_meil                  VARCHAR(254) NOT NULL,
    isikukood               VARCHAR(50)  NOT NULL,
    riik_kood               CHAR(3)      NOT NULL,
    isik_seisundi_liik_kood SMALLINT     NOT NULL DEFAULT 1,
    eesnimi                 VARCHAR(255) NOT NULL,
    elukoht                 VARCHAR(254),
    parool                  VARCHAR(100) NOT NULL,
    reg_aeg                 TIMESTAMP    NOT NULL DEFAULT date_trunc('minute', LOCALTIMESTAMP),
    synni_kp                DATE         NOT NULL,
    perenimi                VARCHAR(255),

    CONSTRAINT Isik_PK_isik_id PRIMARY KEY (isik_id),
    CONSTRAINT Isik_UQ_isikukood_riik_kood UNIQUE (isikukood, riik_kood),
    CONSTRAINT Isik_UQ_e_meil UNIQUE (e_meil),
    CONSTRAINT Isik_CHK_Eesnimi CHECK (eesnimi !~ '^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_Perenimi CHECK (perenimi !~ '^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_Synni_kp CHECK (synni_kp >= '31-12-1900' AND synni_kp <= '31-12-2100'),
    CONSTRAINT Isik_CHK_Elukoht CHECK (elukoht !~ '^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_E_meil CHECK (e_meil ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    CONSTRAINT Isik_CHK_Parool CHECK (parool !~ '^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_Reg_aeg CHECK (reg_aeg >= '01-01-2010 00:00' AND reg_aeg <= '31-12-2100 23:59'),
    CONSTRAINT Isik_CHK_Reg_Aeg_SuuremVordne_Synni_Kp CHECK (reg_aeg >= synni_kp),
    CONSTRAINT Isik_FK_isik_seisundi_liik_kood FOREIGN KEY (isik_seisundi_liik_kood) REFERENCES Isiku_seisundi_liik (isik_seisundi_liik_kood) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT Isik_FK_riik_kood FOREIGN KEY (riik_kood) REFERENCES Riik (riik_kood) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE INDEX Isik_IDX_isik_seisundi_liik_kood
    ON Isik (isik_seisundi_liik_kood ASC);
CREATE INDEX Isik_IDX_riik_kood
    ON Isik (riik_kood ASC);
CREATE INDEX Isik_IDX_perenimi_eesnimi
    ON Isik (perenimi ASC, eesnimi ASC);

CREATE TABLE Klient
(
    isik_id                   INTEGER  NOT NULL,
    klient_seisundi_liik_kood SMALLINT NOT NULL DEFAULT 1,
    on_nous_otseturundusega   BOOLEAN  NOT NULL DEFAULT FALSE,

    CONSTRAINT Klient_PK_klient_kood PRIMARY KEY (isik_id),
    CONSTRAINT Klient_FK_klient_seisundi_liik_kood FOREIGN KEY (klient_seisundi_liik_kood) REFERENCES Kliendi_seisundi_liik (klient_seisundi_liik_kood) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT Klient_FK_isik_id FOREIGN KEY (isik_id) REFERENCES Isik (isik_id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE INDEX Klient_IDX_klient_seisundi_liik_kood
    ON Klient (klient_seisundi_liik_kood ASC);

CREATE TABLE Tootaja
(
    isik_id                    INTEGER  NOT NULL,
    amet_kood                  SMALLINT NOT NULL DEFAULT 1,
    tootaja_seisundi_liik_kood SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT Tootaja_PK_isik_id PRIMARY KEY (isik_id),
    CONSTRAINT Tootaja_FK_amet_kood FOREIGN KEY (amet_kood) REFERENCES Amet (amet_kood) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT Tootaja_FK_tootaja_seisundi_liik_kood FOREIGN KEY (tootaja_seisundi_liik_kood) REFERENCES Tootaja_seisundi_liik (tootaja_seisundi_liik_kood) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT Tootaja_FK_isik_id FOREIGN KEY (isik_id) REFERENCES Isik (isik_id) ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE INDEX Tootaja_IDX_amet_kood
    ON Tootaja (amet_kood ASC);
CREATE INDEX Tootaja_IDX_tootaja_seisundi_liik_kood
    ON Tootaja (tootaja_seisundi_liik_kood ASC);

CREATE TABLE Toode
(
    toode_kood               VARCHAR(100)   NOT NULL,
    nimetus                  VARCHAR(400)   NOT NULL,
    registreerija_id         INTEGER        NOT NULL,
    toote_seisundi_liik_kood SMALLINT       NOT NULL DEFAULT 1,
    riik_kood                CHAR(3)        NOT NULL,
    kirjeldus                TEXT           NOT NULL,
    kaal                     DECIMAL(7, 3)  NOT NULL DEFAULT 0,
    korgus                   DECIMAL(7, 3)  NOT NULL DEFAULT 0,
    pikkus                   DECIMAL(7, 3)  NOT NULL DEFAULT 0,
    laius                    DECIMAL(7, 3)  NOT NULL DEFAULT 0,
    reg_aeg                  TIMESTAMP      NOT NULL DEFAULT date_trunc('minute', LOCALTIMESTAMP),
    hind                     DECIMAL(19, 4) NOT NULL DEFAULT 0,
    min_soovitatav_vanus     SMALLINT       NOT NULL DEFAULT 0,
    max_soovitatav_vanus     SMALLINT,
    pildi_url                TEXT,

    CONSTRAINT Toode_PK_toode_kood PRIMARY KEY (toode_kood),
    CONSTRAINT Toode_UQ_nimetus UNIQUE (nimetus),
    CONSTRAINT Toode_CHK_pildi_url CHECK (pildi_url ~ '^https?://(?:[a-z0-9\-]+\.)+[a-z]{2,6}(?:/[^/#?]+)+\.(?:jpg|gif|png)$'),
    CONSTRAINT Toode_CHK_nimetus_ei_koosne_tyhikutest_pole_tyhi CHECK (nimetus !~ '^[[:space:]]*$'),
    CONSTRAINT Toode_CHK_kirjeldus_ei_koosne_tyhikutest_pole_tyhi CHECK (kirjeldus !~ '^[[:space:]]*$'),
    CONSTRAINT Toode_CHK_korgus_nullist_kuni_sada_meetrit CHECK (korgus >= 0 AND korgus <= 100),
    CONSTRAINT Toode_CHK_pikkus_nullist_kuni_sada_meetrit CHECK (pikkus >= 0 AND pikkus <= 100),
    CONSTRAINT Toode_CHK_laius_nullist_kuni_sada_meetrit CHECK (laius >= 0 AND laius <= 100),
    CONSTRAINT Toode_CHK_Toode_hind_null_voi_suurem CHECK (hind >= 0),
    CONSTRAINT Toode_CHK_kaal_nullist_kuni_tuhat_kilo CHECK (kaal >= 0 AND kaal <= 1000),
    CONSTRAINT Toode_CHK_min_soovitatav_vanus_nullist_sajani CHECK (min_soovitatav_vanus >= 0 AND min_soovitatav_vanus <= 100),
    CONSTRAINT Toode_CHK_max_soovitatav_vanus_nullist_suurem_sajani CHECK (max_soovitatav_vanus > 0 AND max_soovitatav_vanus <= 100),
    CONSTRAINT Toode_CHK_min_soovitatav_vaiksem_vordne_max_soovitatavast CHECK (min_soovitatav_vanus <= max_soovitatav_vanus),
    CONSTRAINT Toode_CHK_reg_aeg CHECK (reg_aeg >= '01-01-2010 00:00:00' AND reg_aeg <= '31-12-2100 23:59:00'),
    CONSTRAINT Toode_FK_riik_kood FOREIGN KEY (riik_kood) REFERENCES Riik (riik_kood) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT Toode_FK_toote_seisundi_liik_kood FOREIGN KEY (toote_seisundi_liik_kood) REFERENCES Toote_seisundi_liik (toote_seisundi_liik_kood) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT Toode_FK_registreerija_id FOREIGN KEY (registreerija_id) REFERENCES Tootaja (isik_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX Toode_IDX_riik_kood
    ON Toode (riik_kood ASC);
CREATE INDEX Toode_IDX_toote_seisundi_liik_kood
    ON Toode (toote_seisundi_liik_kood ASC);
CREATE INDEX Toode_IDX_registreerija_id
    ON Toode (registreerija_id ASC);

CREATE TABLE Toote_kategooria_omamine
(
    toode_kood            VARCHAR(100) NOT NULL,
    toote_kategooria_kood SMALLINT     NOT NULL,

    CONSTRAINT Toote_kategooria_omamine_PK_toode_kood_toote_kategooria_kood PRIMARY KEY (toode_kood, toote_kategooria_kood),
    CONSTRAINT Toote_kategooria_omamine_FK_toode_kood FOREIGN KEY (toode_kood) REFERENCES Toode (toode_kood) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Toote_kategooria_omamine_FK_toote_kategooria_kood FOREIGN KEY (toote_kategooria_kood) REFERENCES Toote_kategooria (toote_kategooria_kood) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX Toote_kategooria_omamine_IDX_toote_kategooria_kood
    ON Toote_kategooria_omamine (toote_kategooria_kood ASC);
-- Baastabelid ---------------------------------------- end

--------------
--------------  Klassifikaatorite väärtused
--------------

INSERT INTO Amet (amet_kood, nimetus, kirjeldus) VALUES (1, 'Toote haldur', 'Haldab ja vastutab toodete info eest.');
INSERT INTO Amet (amet_kood, nimetus, kirjeldus) VALUES (2, 'Juhataja', 'Jälgib ja lõpetab tooteid.');

INSERT INTO Riik (riik_kood, nimetus, kirjeldus) VALUES ('EST', 'Eesti', 'ESTONIA');
INSERT INTO Riik (riik_kood, nimetus, kirjeldus) VALUES ('BEL', 'Belgia', 'BELGIUM');
INSERT INTO Riik (riik_kood, nimetus, kirjeldus) VALUES ('DEU', 'Saksamaa', 'GERMANY');

INSERT INTO Isiku_seisundi_liik (isik_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1, 'Aktiivne', 'Isik on aktiivses seisundis.');
INSERT INTO Isiku_seisundi_liik (isik_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2, 'Mitteaktiivne', 'Isik on mitteaktiivses seisundis.');

INSERT INTO Kliendi_seisundi_liik (klient_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1, 'Aktiivne', 'Klient on aktiivses seisundis.');
INSERT INTO Kliendi_seisundi_liik (klient_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2, 'Mitteaktiivne', 'Klient on mitteaktiivses seisundis.');

INSERT INTO Toote_seisundi_liik (toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1, 'Ootel', 'Toode on ootel.');
INSERT INTO Toote_seisundi_liik (toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2, 'Aktiivne', 'Toode on aktiivne.');
INSERT INTO Toote_seisundi_liik (toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (3, 'Mitteaktiivne', 'Toode on mitteaktiivne.');
INSERT INTO Toote_seisundi_liik (toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (4, 'Lõpetatud', 'Toode on lõpetatud.');

INSERT INTO Tootaja_seisundi_liik (tootaja_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1, 'Aktiivne', 'Töötaja on aktiivne.');
INSERT INTO Tootaja_seisundi_liik (tootaja_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2, 'Mitteaktiivne', 'Töötaja on mitteaktiivne');

--------------
--------------  VAATED
--------------
--------------
CREATE OR REPLACE VIEW Toodete_nimekiri WITH (security_barrier)
AS
    SELECT
        T.toode_kood,
        T.nimetus                                         AS toote_nimetus,
        T.kirjeldus,
        T.kaal,
        T.korgus,
        T.laius,
        T.pikkus,
        T.hind,
        T.min_soovitatav_vanus,
        T.max_soovitatav_vanus,
        R.nimetus                                         AS tootja_riik,
        T.pildi_url,
        T.reg_aeg,
        TSL.nimetus                                       AS toote_seisund,
        (I.perenimi :: TEXT || ', ' || I.eesnimi :: TEXT) AS registreerija_nimi,
        I.e_meil                                          AS registreerija_e_meil
    FROM Toode T
        INNER JOIN Tootaja TOO ON TOO.isik_id = T.registreerija_id
        INNER JOIN Isik I ON I.isik_id = TOO.isik_id
        INNER JOIN Riik R ON R.riik_kood = T.riik_kood
        INNER JOIN Toote_seisundi_liik TSL ON TSL.toote_seisundi_liik_kood = T.toote_seisundi_liik_kood;

COMMENT ON VIEW Toodete_nimekiri IS 'Subjekt tahab mingil põhjusel vaadata toodete detailseid andmeid (sealhulgas juba lõpetatud toodete andmeid). Näiteks soovib subjekt näha, milliseid tooteid on organisatsioon kunagi pakkunud või milliseid see praegu pakub. Samuti vaadata toote detailsemad andmed ning kategooriaid.';

CREATE OR REPLACE VIEW Toodete_kategooriad WITH (security_barrier)
AS
    SELECT
        TK.nimetus,
        TKO.toode_kood
    FROM Toote_kategooria AS TK
        INNER JOIN Toote_kategooria_omamine AS TKO ON TK.toote_kategooria_kood = TKO.toote_kategooria_kood;

COMMENT ON VIEW Toodete_kategooriad IS 'Süsteem kuvab toote kategooriaid toode detailvaades. Toote koodi järgi päring annab kõik toote kategooriaid.';

CREATE OR REPLACE VIEW Toodete_lopetamine WITH (security_barrier)
AS
    SELECT
        T.toode_kood,
        T.nimetus   AS toote_nimetus,
        T.kirjeldus,
        T.reg_aeg,
        T.hind,
        TSL.nimetus AS toote_seisund
    FROM Toode T
        INNER JOIN Toote_seisundi_liik TSL ON TSL.toote_seisundi_liik_kood = T.toote_seisundi_liik_kood
    WHERE (((T.toote_seisundi_liik_kood) = 2 OR (T.toote_seisundi_liik_kood) = 3));

COMMENT ON VIEW Toodete_lopetamine IS 'Subjekt soovib anda kõigile huvitatud osapooltele teada, et konkreetse tootega enam tehinguid ei tehta (kuid kõik käimasolevad tehingud tuleb vastavalt kehtivale korrale lõpetada). Samas soovib ta toote andmete süsteemis säilimist, et ei läheks kaotsi info toote ja sellega seotud tehingute kohta.';

CREATE OR REPLACE VIEW Toodete_koondaruanne WITH (security_barrier)
AS
    SELECT TSL.nimetus AS seisund, COUNT(*) AS kokku
      FROM Toode T
      INNER JOIN Toote_seisundi_liik TSL ON TSL.toote_seisundi_liik_kood = T.toote_seisundi_liik_kood
      GROUP BY TSL.nimetus;
COMMENT ON VIEW Toodete_koondaruanne IS 'Subjekt soovib saada koondaruannet toodetest - mitu toodet on igas seisundis.';

--------------
--------------  FUNKTSIOONID
--------------
--------------
CREATE OR REPLACE FUNCTION f_lopeta_toode(p_toote_kood Toode.toode_kood%TYPE) RETURNS VOID AS $$
BEGIN
    UPDATE Toode
      SET toote_seisundi_liik_kood = 4
      WHERE toode_kood = p_toote_kood;
END;
$$ LANGUAGE 'plpgsql'
SET search_path = public;

COMMENT ON FUNCTION f_lopeta_toode (p_toote_kood
    Toode.toode_kood%TYPE) IS 'Selle funktsiooni abil lõpetatakse toote.
Funktsioon realiseerib andmebaasioperatsioon OP5. Parameetri p_toote_kood oodatav väärtus
on toote identifikaator.';

CREATE OR REPLACE FUNCTION f_kontrolli_seisundi_muutust () RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Tekkis viga seisundi muutmisel';
END;
$$ LANGUAGE 'plpgsql'
SET search_path = public;

COMMENT ON FUNCTION f_kontrolli_seisundi_muutust () IS 'Kuna toote seisundi muutus toimus ebakorrektselt, väljastab see funktsion välja exceptioni.';

CREATE OR REPLACE FUNCTION f_hash_password() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN -- Checking trigger operation here
        -- Topelthashimise vältimine UPDATE klausli korral
        IF OLD.parool <> NEW.parool THEN
            NEW.parool :=  crypt(NEW.parool, gen_salt('bf', 8));
        END IF;
    ELSE
        NEW.parool :=  crypt(NEW.parool, gen_salt('bf', 8));
    END IF;
    RETURN NEW;
END
$$ LANGUAGE 'plpgsql'
SET search_path = public;

COMMENT ON FUNCTION f_hash_password () IS 'Selle funktsiooni abil rakendatakse registreeritud isiku paroolile soolaga krüpteerimise funktsioon. On arvestatud nii UPDATE kui ka INSERT juhtudega, on välditud topelthashimist UPDATE korral.';

--------------
--------------  TRIGGERID
--------------
--------------
CREATE TRIGGER t_kontrolli_seisundi_muutust BEFORE UPDATE OF toote_seisundi_liik_kood ON Toode
FOR EACH ROW
    WHEN ((NOT
        (                                                                                              -- SEISUNDIDIAGRAMM
            (OLD.toote_seisundi_liik_kood =              NEW.toote_seisundi_liik_kood    )        OR   -- Seisund ei muutu
            (OLD.toote_seisundi_liik_kood IN (2, 3)  AND NEW.toote_seisundi_liik_kood = 4)        OR   -- Lõpeta aktiivne või mitteaktiivne toode
            (OLD.toote_seisundi_liik_kood IN (1, 2)  AND NEW.toote_seisundi_liik_kood = 3)        OR   -- Muuda ootel või aktiivne toote mitteaktiivseks
            (OLD.toote_seisundi_liik_kood IN (1, 3)  AND NEW.toote_seisundi_liik_kood = 2)             -- Aktiveeri ootel või mitteaktiivse toote
        )
        ))
EXECUTE PROCEDURE f_kontrolli_seisundi_muutust();
COMMENT ON TRIGGER t_kontrolli_seisundi_muutust ON Toode IS 'See trigger käivitatakse igakord, kui toote seisundit tahetakse muuta UPDATE klausli abil. Käivitatakse funktsioon, mis annab erindi välja, kui on ebakorrektne olekumuutus.';

CREATE TRIGGER t_hash_password BEFORE INSERT OR UPDATE OF parool ON Isik
FOR EACH ROW EXECUTE PROCEDURE f_hash_password();
COMMENT ON TRIGGER t_hash_password ON Isik IS 'See trigger käivitatakse igakord, kui lisatakse uus kirje tabelisse Isik. Igale INSERT kirjele rakendatakse funktsioon, mis rakendab räsifunktsiooni väljale parool.';

--------------
--------------  TEST ANDMED
--------------
INSERT INTO isik (isik_id, e_meil, isikukood, riik_kood, isik_seisundi_liik_kood, eesnimi, elukoht, parool, reg_aeg, synni_kp, perenimi)
VALUES (1, 'max9599@gmail.com', '39509182223', 'EST', 1, 'Maxim', 'Tallinn', '1234', '2016-12-02 21:03:00', '1995-09-18', 'Gromov');
INSERT INTO tootaja (isik_id, amet_kood, tootaja_seisundi_liik_kood) VALUES (1, 1, 1);

INSERT INTO toode (toode_kood, nimetus, registreerija_id, toote_seisundi_liik_kood, riik_kood, kirjeldus, kaal, korgus, pikkus, laius, reg_aeg, hind, min_soovitatav_vanus, max_soovitatav_vanus, pildi_url)
VALUES ('XPK231', 'Karu', 1, 1, 'EST', 'Väga pehme karu', 0.120, 1.500, 0.800, 0.340, '2016-12-02 21:03:00', 79.9900, 2, 100, 'http://www.clipartqueen.com/image-files/teddy-bear-head.png');
INSERT INTO toode (toode_kood, nimetus, registreerija_id, toote_seisundi_liik_kood, riik_kood, kirjeldus, kaal, korgus, pikkus, laius, reg_aeg, hind, min_soovitatav_vanus, max_soovitatav_vanus, pildi_url)
VALUES ('XPK232', 'Jänes', 1, 2, 'BEL', 'Väga pehme jänes', 0.055, 0.850, 0.400, 0.200, '2016-12-03 11:53:00', 48.5500, 2, 100, 'https://i.cbc.ca/1.3463088.1456362180!/fileImage/httpImage/image.png_gen/derivatives/original_620/pr-soft-toy.png');
INSERT INTO toode (toode_kood, nimetus, registreerija_id, toote_seisundi_liik_kood, riik_kood, kirjeldus, kaal, korgus, pikkus, laius, reg_aeg, hind, min_soovitatav_vanus, max_soovitatav_vanus, pildi_url)
VALUES ('XPK233', 'Konn', 1, 3, 'BEL', 'Konn', 0.022, 0.111, 0.342, 0.230, '2016-12-03 11:55:00', 20.8900, 3, 10, 'https://netikink.eu/731-large_default/pehme-manguasi-konn-paddy.jpg');
INSERT INTO toode (toode_kood, nimetus, registreerija_id, toote_seisundi_liik_kood, riik_kood, kirjeldus, kaal, korgus, pikkus, laius, reg_aeg, hind, min_soovitatav_vanus, max_soovitatav_vanus, pildi_url)
VALUES ('XPK234', 'Lehm', 1, 4, 'EST', 'Lehm', 0.300, 0.122, 0.342, 0.222, '2016-12-03 11:56:00', 30.9900, 3, 10, 'http://beebicenter.ee/3769-large_default/teddykompaniet-pehme-xl-manguasi-lehm-120cm.jpg');

INSERT INTO Toote_kategooria (toote_kategooria_kood, nimetus, kirjeldus) VALUES (100, 'Mänguasjad poistele', 'Kategooria, mis sisaldab poistele mõeldud mänguasju.');
INSERT INTO Toote_kategooria (toote_kategooria_kood, nimetus, kirjeldus) VALUES (200, 'Mänguasjad tüdrukutele', 'Kategooria, mis sisaldab tüdrukutele mõeldud mänguasju.');

INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK231', 100);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK231', 200);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK232', 100);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK232', 200);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK233', 100);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK233', 200);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK234', 100);
INSERT INTO Toote_kategooria_omamine (toode_kood, toote_kategooria_kood) VALUES ('XPK234', 200);

