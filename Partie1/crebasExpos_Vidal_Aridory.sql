/*==============================================================*/
/* Nom de SGBD :  ORACLE Version 11g                            */
/* Date de cr�ation :  16/05/2024 14:09:59                      */
/* ARIDORY Malcolm, VIDAL Martin                                */
/*==============================================================*/


drop table Achat cascade constraints;

drop table DEPARTEMENT cascade constraints;

drop table EXPO cascade constraints;

drop table GENRE cascade constraints;

drop table LIEU cascade constraints;

drop table TYPELIEU cascade constraints;

drop table OEUVRE cascade constraints;

drop table TYPEOEUVRE cascade constraints;

drop table ARTISTE cascade constraints;


/*==============================================================*/
/* Table : TYPELIEU                                             */
/*==============================================================*/
create table TYPELIEU 
(
   numTpLieu            INTEGER              not null,
   libTpLieu            VARCHAR2(30)         not null,
   constraint PK_TYPELIEU primary key (numTpLieu)
);

/*==============================================================*/
/* Table : DEPARTEMENT                                          */
/*==============================================================*/
create table DEPARTEMENT 
(
   numDpt               NUMBER(2)            not null,
   nomDpt               VARCHAR2(30)         not null,
   constraint PK_DEPARTEMENT primary key (numDpt)
);

/*==============================================================*/
/* Table : LIEU                                                 */
/*==============================================================*/
create table LIEU 
(
   numLieu              INTEGER              not null,
   numDpt               NUMBER(2),
   numTpLieu            INTEGER,
   nomLieu              VARCHAR2(60)         not null,
   missions             VARCHAR2(120),
   arrondissement       INTEGER             
      constraint CKC_ARRONDISSEMENT_LIEU check (arrondissement is null or (arrondissement between 1 and 20)),
   villeLieu            VARCHAR2(30),
   constraint PK_LIEU primary key (numLieu),
   constraint FK_LIEU_ETRE_TYPELIEU foreign key (numTpLieu)
         references TYPELIEU (numTpLieu),
   constraint FK_LIEU_SE_SITUER_DEPARTEM foreign key (numDpt)
         references DEPARTEMENT (numDpt)
);

/*==============================================================*/
/* Table : GENRE                                                */
/*==============================================================*/
create table GENRE 
(
   numGenre             INTEGER              not null,
   libGenre             VARCHAR2(30)         not null,
   constraint PK_GENRE primary key (numGenre)
);

/*==============================================================*/
/* Table : EXPO                                                 */
/*==============================================================*/
create table EXPO 
(
   numLieu              INTEGER              not null,
   numExpo              INTEGER              not null,
   numGenre             INTEGER,
   titreExpo            VARCHAR2(128)         not null,
   dateDeb              DATE                 not null,
   dateFin              DATE,
   resume               VARCHAR2(256),
   tarif                NUMBER(4,2)
      constraint CKC_TARIF_EXPO check (tarif is null or (tarif >= 0)),
   tarifR               NUMBER(4,2)         
      constraint CKC_TARIFR_EXPO check (tarifR is null or (tarifR >= 0)),
   choix                INTEGER             
      constraint CKC_CHOIX_EXPO check (choix is null or (choix in (NULL,1))),
   dureeEv GENERATED ALWAYS AS (CASE WHEN dateFin IS NULL THEN NULL ELSE dateFin - dateDeb END) VIRTUAL,

   constraint PK_EXPO primary key (numLieu, numExpo),
   constraint FK_EXPO_LI_LIEU foreign key (numLieu)
         references LIEU (numLieu),
   constraint FK_EXPO_APPARTENI_GENRE foreign key (numGenre)
         references GENRE (numGenre),
   constraint CKC_DATEFIN_EXPO check (dateFin >= dateDeb)
);

/*==============================================================*/
/* Table : Achat                                                */
/*==============================================================*/
create table Achat 
(
   numLieu              INTEGER              not null,
   numExpo              INTEGER              not null,
   numPers              INTEGER              not null,
   dateAchat            DATE                 not null,
   nbBil                INTEGER,
   nbBilTR              INTEGER,
   modeReglt            CHAR(3),
   constraint CKC_MODEREGLT_ACHAT check (modeReglt is null or (modeReglt in ('CB','CHQ','ESP'))),
   constraint PK_ACHAT primary key (numLieu, numExpo, numPers, dateAchat),
   constraint FK_ACHAT_LI_ACHAT__EXPO foreign key (numLieu, numExpo)
         references EXPO (numLieu, numExpo),
   constraint FK_ACHAT_LI_ACHAT__PERSONNE foreign key (numPers)
         references PERSONNE (numPers)
);

/*==============================================================*/
/* Table : TYPEOEUVRE                                           */
/*==============================================================*/
CREATE TABLE TYPEOEUVRE (
    numTpEvr INTEGER NOT NULL,
    libTpEvr VARCHAR2(30) NOT NULL,
    constraint PK_TYPEOEUVRE primary key (numTpEvr)
);

/*==============================================================*/
/* Table : ARTISTE                                              */
/*==============================================================*/
CREATE TABLE ARTISTE AS
SELECT
    TO_NUMBER(ai.cdArt) as numArt,
    p.cdPays,
    ai.nom as nomArt,
    ai.prnm as pnomArt
FROM
    TESTSAELD.ARTISTE_IMPORT ai
        LEFT JOIN PAYS p ON ai.pays = upper(p.nomFr);

ALTER TABLE ARTISTE ADD CONSTRAINT PK_ARTISTE PRIMARY KEY (numArt);

-- Ajout de la Bavière comme Allemagne

UPDATE ARTISTE
SET
    cdPays = 'DEU'
WHERE
    numArt IN ( SELECT cdArt
                FROM TESTSAELD.ARTISTE_IMPORT
                WHERE UPPER(PAYS) LIKE "BAVIERE");


/*==============================================================*/
/* Table : OEUVRE                                               */
/*==============================================================*/
CREATE TABLE OEUVRE (
    numEvr INTEGER NOT NULL,
    numArt INTEGER NOT NULL,
    numTpEvr INTEGER NOT NULL,
    titre VARCHAR2(50) NOT NULL,
    anneeCr INTEGER,
    constraint PK_OEUVRE primary key (numEvr),
    constraint FK_NUMTPEVR_OEUVRE FOREIGN KEY (numTpEvr) REFERENCES TYPEOEUVRE(numTpEvr) ON DELETE SET NULL,
    constraint FK_NUMART_OEUVRE FOREIGN KEY (numArt) REFERENCES ARTISTE(numArt) ON DELETE CASCADE

);

/*==============================================================*/
/* Création des index                                           */
/*==============================================================*/

-- Index sur les clés étrangères
CREATE INDEX idx_expo_numLieu ON EXPO (numLieu);
CREATE INDEX idx_expo_numGenre ON EXPO (numGenre);
CREATE INDEX idx_lieu_numDpt ON LIEU (numDpt);
CREATE INDEX idx_lieu_numTpLieu ON LIEU (numTpLieu);
CREATE INDEX idx_achat_numLieu ON Achat (numLieu);
CREATE INDEX idx_achat_numExpo ON Achat (numExpo);
CREATE INDEX idx_achat_numPers ON Achat (numPers);
CREATE INDEX idx_oeuvre_numArt ON OEUVRE (numArt);
CREATE INDEX idx_oeuvre_numTpEvr ON OEUVRE (numTpEvr);

-- Index sur le nom des lieux
CREATE INDEX idx_lieu_nomLieu ON LIEU (nomLieu);

-- Index sur les noms-prénoms des personnes
--CREATE INDEX idx_personne_nomPers ON PERSONNE (nomPers);
--CREATE INDEX idx_personne_pnomPers ON PERSONNE (pnomPers);

-- Index sur le titre des œuvres
CREATE INDEX idx_oeuvre_titre ON OEUVRE (titre);

/*==============================================================*/
/* Contrainte de domaine de notre choix                         */
/*==============================================================*/

-- Une contrainte pertinente peut être ajoutée sur le numéro de département, en s'assurant
-- qu'on entre bien un département d'Île-de-France

ALTER TABLE LIEU
    ADD CONSTRAINT CKC_NUMDPT_LIEU CHECK (NUMDPT IN ('75', '77', '78', '91', '92', '93', '94', '95'));