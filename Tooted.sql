SET datestyle = dmy;

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

-- Domeenid
CREATE DOMAIN d_nimetus varchar(50) NOT NULL 
CONSTRAINT d_nimetus_CHK_mitte_tuhi CHECK (VALUE!~'^[[:space:]]*$');

CREATE DOMAIN d_kirjeldus Text 
CONSTRAINT d_kirjeldus_CHK_mitte_tuhi CHECK (VALUE!~'^[[:space:]]*$');

CREATE TABLE Amet
(
	amet_kood smallint NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Amet_PK_amet_kood PRIMARY KEY (amet_kood),
	CONSTRAINT Amet_UQ_nimetus UNIQUE (nimetus)
);


CREATE TABLE Riik
(
	riik_kood char(3)	 NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Riik_PK_riik_kood PRIMARY KEY (riik_kood),
	CONSTRAINT Riik_UQ_nimetus UNIQUE (nimetus),
	CONSTRAINT Riik_CHK_Riik_Kood CHECK (riik_kood~'^[[A-Z]{3}]*$')
)
;

CREATE TABLE Isiku_seisundi_liik
(
	isik_seisundi_liik_kood smallint NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Isiku_seisundi_liik_PK_isik_seisundi_liik_kood PRIMARY KEY (isik_seisundi_liik_kood),
	CONSTRAINT Isiku_seisundi_liik_UQ_nimetus UNIQUE (nimetus)
)
;

CREATE TABLE Kliendi_seisundi_liik
(
	klient_seisundi_liik_kood smallint NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Kliendi_seisundi_PK_klient_seisundi_liik_kood PRIMARY KEY (klient_seisundi_liik_kood),
	CONSTRAINT Kliendi_seisundi_UQ_nimetus UNIQUE (nimetus)
)
;

CREATE TABLE Toote_seisundi_liik
(
	toote_seisundi_liik_kood smallint NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Toote_seisundi_liik_PK_toote_seisundi_liik_kood PRIMARY KEY (toote_seisundi_liik_kood),
	CONSTRAINT Toote_seisundi_liik_UQ_nimetus UNIQUE (nimetus)
)
;

CREATE TABLE Tootaja_seisundi_liik
(
	tootaja_seisundi_liik_kood smallint NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Tootaja_seisundi_liik_PK_tootaja_seisundi_liik_kood PRIMARY KEY (tootaja_seisundi_liik_kood),
	CONSTRAINT Tootaja_seisundi_liik_UQ_nimetus UNIQUE (nimetus)
)
;

CREATE TABLE Toote_kategooria
(
	toote_kategooria_kood smallint NOT NULL,
	nimetus d_nimetus,
	kirjeldus d_kirjeldus,
	CONSTRAINT Toote_kategooria_PK_toote_kategooria_kood PRIMARY KEY (toote_kategooria_kood),
	CONSTRAINT Toote_kategooria_UQ_nimetus UNIQUE (nimetus)
)
;

CREATE TABLE Isik
(
	isik_id serial NOT NULL,
	e_meil varchar(254)	 NOT NULL,
    isikukood varchar(50)  NOT NULL,
    riik_kood char(3)  NOT NULL,
    isik_seisundi_liik_kood smallint NOT NULL DEFAULT 1,
    eesnimi varchar(255)   NOT NULL,
    elukoht varchar(254)  ,
    parool varchar(100)    NOT NULL,
    reg_aeg timestamp NOT NULL DEFAULT date_trunc('minute',LOCALTIMESTAMP) ,
    synni_kp date NOT NULL,
    perenimi varchar(255) ,
    CONSTRAINT Isik_PK_isik_id PRIMARY KEY (isik_id),
    CONSTRAINT Isik_UQ_isikukood_riik_kood UNIQUE (isikukood,riik_kood),
    CONSTRAINT Isik_UQ_e_meil UNIQUE (e_meil),
    CONSTRAINT Isik_CHK_Eesnimi CHECK (eesnimi!~'^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_Perenimi CHECK (perenimi!~'^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_Synni_kp CHECK (synni_kp >= '31-12-1900' AND synni_kp <= '31-12-2100'),
    CONSTRAINT Isik_CHK_Elukoht CHECK (elukoht!~'^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_E_meil CHECK (e_meil !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    CONSTRAINT Isik_CHK_Parool CHECK (parool!~'^[[:space:]]*$'),
    CONSTRAINT Isik_CHK_Reg_aeg CHECK (reg_aeg >= '01-01-2010 00:00' AND reg_aeg <= '31-12-2100 23:59'),
    CONSTRAINT Isik_CHK_Reg_Aeg_SuuremVordne_Synni_Kp CHECK (reg_aeg >= synni_kp),
    CONSTRAINT Isik_FK_isik_seisundi_liik_kood FOREIGN KEY (isik_seisundi_liik_kood) REFERENCES Isiku_seisundi_liik (isik_seisundi_liik_kood) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT Isik_FK_riik_kood FOREIGN KEY (riik_kood) REFERENCES Riik (riik_kood) ON DELETE No Action ON UPDATE Cascade
)
;

CREATE INDEX Isik_IDX_isik_seisundi_liik_kood ON Isik (isik_seisundi_liik_kood ASC);
CREATE INDEX Isik_IDX_riik_kood ON Isik (riik_kood ASC);
CREATE INDEX Isik_IDX_perenimi_eesnimi ON Isik (perenimi ASC,eesnimi ASC);

CREATE TABLE Klient
(
	isik_id integer NOT NULL,
	klient_seisundi_liik_kood smallint NOT NULL DEFAULT 1,
	on_nous_otseturundusega boolean NOT NULL DEFAULT false,
	CONSTRAINT Klient_PK_klient_kood PRIMARY KEY (isik_id),
	CONSTRAINT Klient_FK_klient_seisundi_liik_kood FOREIGN KEY (klient_seisundi_liik_kood) REFERENCES Kliendi_seisundi_liik (klient_seisundi_liik_kood) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT Klient_FK_isik_id FOREIGN KEY (isik_id) REFERENCES Isik (isik_id) ON DELETE Cascade ON UPDATE No Action
)
;

CREATE INDEX Klient_IDX_klient_seisundi_liik_kood ON Klient (klient_seisundi_liik_kood ASC);

CREATE TABLE Tootaja
(
	isik_id integer NOT NULL,
	amet_kood smallint NOT NULL DEFAULT 1,
	tootaja_seisundi_liik_kood smallint NOT NULL DEFAULT 1,
    CONSTRAINT Tootaja_PK_isik_id PRIMARY KEY (isik_id),
	CONSTRAINT Tootaja_FK_amet_kood FOREIGN KEY (amet_kood) REFERENCES Amet (amet_kood) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT Tootaja_FK_tootaja_seisundi_liik_kood FOREIGN KEY (tootaja_seisundi_liik_kood) REFERENCES Tootaja_seisundi_liik (tootaja_seisundi_liik_kood) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT Tootaja_FK_isik_id FOREIGN KEY (isik_id) REFERENCES Isik (isik_id) ON DELETE Cascade ON UPDATE No Action
)
;

CREATE INDEX Tootaja_IDX_amet_kood ON Tootaja (amet_kood ASC);
CREATE INDEX Tootaja_IDX_tootaja_seisundi_liik_kood ON Tootaja (tootaja_seisundi_liik_kood ASC);

CREATE TABLE Toode
(
	toode_kood varchar(100)	 NOT NULL,
	nimetus varchar(400)	 NOT NULL,
	registreerija_id integer NOT NULL,
	toote_seisundi_liik_kood smallint NOT NULL DEFAULT 1,
	riik_kood char(3)	 NOT NULL,
	kirjeldus text NOT NULL,
	kaal decimal(7,3) NOT NULL DEFAULT 0,
	korgus decimal(7,3) NOT NULL DEFAULT 0,
	pikkus decimal(7,3) NOT NULL DEFAULT 0,
	laius decimal(7,3) NOT NULL DEFAULT 0,
	reg_aeg timestamp NOT NULL DEFAULT date_trunc('minute',LOCALTIMESTAMP) ,
	hind decimal(19,4) NOT NULL DEFAULT 0,
	min_soovitatav_vanus smallint NOT NULL DEFAULT 0,
	max_soovitatav_vanus smallint,
	pildi_url Text,
	CONSTRAINT Toode_PK_toode_kood PRIMARY KEY (toode_kood),
	CONSTRAINT Toode_UQ_nimetus UNIQUE (nimetus),
    CONSTRAINT Toode_CHK_pildi_url CHECK (pildi_url~'^https?://(?:[a-z0-9\-]+\.)+[a-z]{2,6}(?:/[^/#?]+)+\.(?:jpg|gif|png)$'),
    CONSTRAINT Toode_CHK_nimetus_ei_koosne_tyhikutest_pole_tyhi CHECK (nimetus!~'^[[:space:]]*$'),
    CONSTRAINT Toode_CHK_kirjeldus_ei_koosne_tyhikutest_pole_tyhi CHECK (kirjeldus!~'^[[:space:]]*$'),
    CONSTRAINT Toode_CHK_korgus_nullist_kuni_sada_meetrit CHECK (korgus >= 0 AND korgus <= 100),
    CONSTRAINT Toode_CHK_pikkus_nullist_kuni_sada_meetrit CHECK (pikkus >= 0 AND pikkus <= 100),
    CONSTRAINT Toode_CHK_laius_nullist_kuni_sada_meetrit CHECK (laius >= 0 AND laius <= 100),
    CONSTRAINT Toode_CHK_Toode_hind_null_voi_suurem CHECK (hind >= 0),
    CONSTRAINT Toode_CHK_kaal_nullist_kuni_tuhat_kilo CHECK (kaal >= 0 AND kaal <= 1000),
    CONSTRAINT Toode_CHK_min_soovitatav_vanus_nullist_sajani CHECK (min_soovitatav_vanus >= 0 AND min_soovitatav_vanus <= 100),
    CONSTRAINT Toode_CHK_max_soovitatav_vanus_nullist_suurem_sajani CHECK (max_soovitatav_vanus > 0 AND max_soovitatav_vanus <= 100),
    CONSTRAINT Toode_CHK_min_soovitatav_vaiksem_vordne_max_soovitatavast CHECK (min_soovitatav_vanus <= max_soovitatav_vanus),
    CONSTRAINT Toode_CHK_reg_aeg CHECK (reg_aeg >= '01-01-2010 00:00:00' AND reg_aeg <= '31-12-2100 23:59:00'),
    CONSTRAINT Toode_FK_riik_kood FOREIGN KEY (riik_kood) REFERENCES Riik (riik_kood) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT Toode_FK_toote_seisundi_liik_kood FOREIGN KEY (toote_seisundi_liik_kood) REFERENCES Toote_seisundi_liik (toote_seisundi_liik_kood) ON DELETE No Action ON UPDATE Cascade,
    CONSTRAINT Toode_FK_registreerija_id FOREIGN KEY (registreerija_id) REFERENCES Tootaja (isik_id) ON DELETE No Action ON UPDATE No Action
)
;

CREATE INDEX Toode_IDX_riik_kood ON Toode (riik_kood ASC);
CREATE INDEX Toode_IDX_toote_seisundi_liik_kood ON Toode (toote_seisundi_liik_kood ASC);
CREATE INDEX Toode_IDX_registreerija_id ON Toode (registreerija_id ASC);

CREATE TABLE Toote_kategooria_omamine
(
	toode_kood varchar(100)	 NOT NULL,
	toote_kategooria_kood smallint NOT NULL,
	CONSTRAINT Toote_kategooria_omamine_PK_toode_kood_toote_kategooria_kood PRIMARY KEY (toode_kood,toote_kategooria_kood),
	CONSTRAINT Toote_kategooria_omamine_FK_toode_kood FOREIGN KEY (toode_kood) REFERENCES Toode (toode_kood) ON DELETE Cascade ON UPDATE Cascade,
	CONSTRAINT Toote_kategooria_omamine_FK_toote_kategooria_kood FOREIGN KEY (toote_kategooria_kood) REFERENCES Toote_kategooria (toote_kategooria_kood) ON DELETE Cascade ON UPDATE Cascade
)
;

CREATE INDEX Toote_kategooria_omamine_IDX_toote_kategooria_kood ON Toote_kategooria_omamine (toote_kategooria_kood ASC);

INSERT INTO Amet(amet_kood, nimetus, kirjeldus) VALUES(1, 'Toote haldur', NULL);
INSERT INTO Amet(amet_kood, nimetus, kirjeldus) VALUES(2, 'Juhataja', NULL);

INSERT INTO Riik(riik_kood, nimetus, kirjeldus) VALUES ('EST' ,'Eesti', NULL);
INSERT INTO Riik(riik_kood, nimetus, kirjeldus) VALUES ('BEL' ,'Belgia', NULL);
INSERT INTO Riik(riik_kood, nimetus, kirjeldus) VALUES ('DEU' ,'Saksamaa', NULL);

INSERT INTO Isiku_seisundi_liik(isik_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1 ,'Aktiivne', NULL);
INSERT INTO Isiku_seisundi_liik(isik_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2 ,'Mitteaktiivne', NULL);

INSERT INTO Kliendi_seisundi_liik(klient_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1 ,'Aktiivne', NULL);
INSERT INTO Kliendi_seisundi_liik(klient_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2 ,'Mitteaktiivne', NULL);

INSERT INTO Toote_seisundi_liik(toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1 ,'Ootel', NULL);
INSERT INTO Toote_seisundi_liik(toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2 ,'Aktiivne', NULL);
INSERT INTO Toote_seisundi_liik(toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (3 ,'Mitteaktiivne', NULL);
INSERT INTO Toote_seisundi_liik(toote_seisundi_liik_kood, nimetus, kirjeldus) VALUES (4 ,'Lõpetatud', NULL);

INSERT INTO Tootaja_seisundi_liik(tootaja_seisundi_liik_kood, nimetus, kirjeldus) VALUES (1 ,'Aktiivne', NULL);
INSERT INTO Tootaja_seisundi_liik(tootaja_seisundi_liik_kood, nimetus, kirjeldus) VALUES (2 ,'Mitteaktiivne', NULL);

INSERT INTO Toote_kategooria(toote_kategooria_kood, nimetus, kirjeldus) VALUES (100 ,'Mänguasjad poistele', NULL);
INSERT INTO Toote_kategooria(toote_kategooria_kood, nimetus, kirjeldus) VALUES (200 ,'Mänguasjad tüdrukutele', NULL);

CREATE OR REPLACE VIEW Toodete_nimekiri WITH (security_barrier)
	AS SELECT 
	t.toode_kood, 
	t.nimetus AS toote_nimetus, 
	t.kirjeldus, 
	t.kaal, 
	t.korgus, 
	t.laius,
	t.pikkus, 
	t.hind,
	t.min_soovitatav_vanus,
	t.max_soovitatav_vanus, 
	r.nimetus AS tootja_riik,
	t.pildi_url,
	t.reg_aeg, 
	tsl.nimetus AS toote_seisund, 
	(i.perenimi::text || ', ' || i.eesnimi::text) AS registreerija_nimi
	FROM Toode t
	INNER JOIN Tootaja too ON too.isik_id = t.registreerija_id
	INNER JOIN Isik i ON i.isik_id = too.isik_id
	INNER JOIN Riik r ON r.riik_kood = t.riik_kood
	INNER JOIN Toote_seisundi_liik tsl ON tsl.toote_seisundi_liik_kood = t.toote_seisundi_liik_kood;

COMMENT ON VIEW Toodete_nimekiri IS 'Subjekt tahab mingil põhjusel vaadata toodete detailseid andmeid (sealhulgas juba lõpetatud toodete andmeid). Näiteks soovib subjekt näha, milliseid tooteid on organisatsioon kunagi pakkunud või milliseid see praegu pakub.';
