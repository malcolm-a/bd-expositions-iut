/* SAÉ MS204
 * PARTIE 1
 * ARIDORY MALCOLM, VIDAL MARTIN
 * LOGIN : ARID0002
 */


/*==============================================================*/
/* 4 CHARGEMENT DE LA BASE INFO_EXPO                            */
/*==============================================================*/

-- 4.a

-- TYPELIEU
INSERT INTO TYPELIEU VALUES (1, 'Musée municipal');
INSERT INTO TYPELIEU VALUES (2, 'Musée National');
INSERT INTO TYPELIEU VALUES (3, 'Musée Privé');
INSERT INTO TYPELIEU VALUES (4, 'Musée Départemental');
INSERT INTO TYPELIEU VALUES (5, 'Galerie d’art');
INSERT INTO TYPELIEU VALUES (6, 'Châteaux');
INSERT INTO TYPELIEU VALUES (7, 'Institutions culturelles');

-- DEPARTEMENT
INSERT INTO DEPARTEMENT VALUES (75, 'Paris');
INSERT INTO DEPARTEMENT VALUES (77, 'Seine-et-Marne');
INSERT INTO DEPARTEMENT VALUES (78, 'Yvelines');
INSERT INTO DEPARTEMENT VALUES (91, 'Essonne');
INSERT INTO DEPARTEMENT VALUES (92, 'Hauts-de-Seine');
INSERT INTO DEPARTEMENT VALUES (93, 'Seine-Saint-Denis');
INSERT INTO DEPARTEMENT VALUES (94, 'Val-de-Marne');
INSERT INTO DEPARTEMENT VALUES (95, 'Val-d’Oise');

-- GENRE
INSERT INTO GENRE VALUES (1, 'Architecture/Design/Mode');
INSERT INTO GENRE VALUES (2, 'Art Contemporain');
INSERT INTO GENRE VALUES (3, 'Beaux-Arts');
INSERT INTO GENRE VALUES (4, 'Châteaux/Monuments');
INSERT INTO GENRE VALUES (5, 'Galeries');
INSERT INTO GENRE VALUES (6, 'Histoire/Civilisations');
INSERT INTO GENRE VALUES (7, 'Instituts culturels');
INSERT INTO GENRE VALUES (8, 'Jeunes Publics');
INSERT INTO GENRE VALUES (9, 'Photographie');
INSERT INTO GENRE VALUES (10, 'Salons');
INSERT INTO GENRE VALUES (11, 'Sciences et Techniques');


-- 4.b : import des données de lieux.csv


-- 4.c : on importe typeoeuvre, puis oeuvre puis expo

-- TYPEOEUVRE

INSERT INTO TYPEOEUVRE
    (NUMTPEVR, LIBTPEVR)
SELECT
    NUMTPEVR,
    LIBTPEVR
FROM
    TESTSAELD.TYPEOEUVRE_IMPORT;

-- OEUVRE

INSERT INTO OEUVRE
(NUMEVR, NUMART, NUMTPEVR, TITRE, ANNEECR)
SELECT
    OI.NUMEVR,
    OI.NUMART,
    OI.NUMTPEVR,
    OI.TITRE,
    OI.ANNEECR
FROM
    TESTSAELD.OEUVRE_IMPORT OI
    INNER JOIN TYPEOEUVRE TPO ON OI.NUMTPEVR = TPO.NUMTPEVR;

-- EXPO

INSERT INTO EXPO
(NUMLIEU, NUMEXPO, NUMGENRE, TITREEXPO, DATEDEB, DATEFIN, RESUME, TARIF, TARIFR, CHOIX)
SELECT
    EI.NUMLIEU,
    EI.NUMEXPO,
    EI.NUMGENRE,
    EI.TITREEXPO,
    EI.DATEDEB,
    EI.DATEFIN,
    EI.RESUME,
    EI.TARIF,
    EI.TARIFREDUIT,
    EI.CHOIX
FROM
    TESTSAELD.EXPO_IMPORT EI
    INNER JOIN LIEU LI ON (EI.NUMLIEU = LI.NUMLIEU);


-- 4.d

ALTER TABLE PRESENTATION
ADD CONSTRAINT
    FK_PRESENTATION_NUMEVR FOREIGN KEY (numEvr) REFERENCES OEUVRE(numEvr);

ALTER TABLE PRESENTATION
ADD CONSTRAINT
    FK_PRESENTATION_EXPO FOREIGN KEY (numLieu, numExpo) REFERENCES EXPO(numLieu, numExpo);


-- 4.e

-- Insertions des données pour la personne (1) qui a été voir toutes les expos du centre Pompidou

INSERT INTO ACHAT (numLieu, numExpo, numPers, dateAchat, nbBil, nbBilTR, modeReglt)
SELECT numLieu, numExpo, 1, SYSDATE, 1, 0, 'CB'
FROM EXPO
WHERE numLieu = (SELECT numLieu FROM LIEU WHERE nomLieu LIKE 'Centre Pompidou');

-- Insertion de deux achats de la personne (2) en dehors de Paris

INSERT INTO ACHAT
SELECT E.numLieu, numExpo, 2, SYSDATE-30, 0, 1, 'CHQ'
FROM EXPO E JOIN LIEU L ON E.NUMLIEU = L.NUMLIEU
WHERE UPPER(L.VILLELIEU) <> 'PARIS' AND ROWNUM IN (1, 2);

-- Insertion d'un achat après la fin de l'exposition (Personne 3)

INSERT INTO ACHAT
SELECT E.NUMLIEU, E.NUMEXPO, 3, E.DATEFIN+10, 2, 0, 'CB'
FROM EXPO E
WHERE ROWNUM = 1;

-- INSERTION D'AUTRES ACHATS (Personnes 5, 8, 13, 21, 34, 55, 89, 144)

-- On va utiliser des expositions sélectionnées aléatoirement avec la fonction oracle DBMS_RANDOM
-- https://docs.oracle.com/database/timesten-18.1/TTPLP/d_random.htm#TTPLP040

-- PERSONNE 5

INSERT INTO ACHAT
SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 5, SYSDATE-90, 0, 1, 'ESP'
    FROM EXPO E
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM < 4;

-- PERSONNE 8

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 8, SYSDATE-60, 2, 1, 'CB'
    FROM EXPO E
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM < 4;


-- PERSONNE 13    

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 13, SYSDATE+20, 2, 1, 'CB'
    FROM EXPO E
    ORDER BY DATEFIN DESC)
WHERE
    ROWNUM < 5;


-- PERSONNE 21

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 21, SYSDATE-16, 1, 0, 'ESP'
    FROM EXPO E
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM = 1;

-- PERSONNE 34    

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 34, SYSDATE-55, 1, 0, 'CB'
    FROM EXPO E
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM < 9;

-- PERSONNE 55

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 55, SYSDATE+2, 1, 0, 'CB'
    FROM EXPO E
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM < 3;

-- PERSONNE 89

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 89, SYSDATE-144, 0, 2, 'CB'
    FROM EXPO E
    WHERE E.NUMGENRE = 1
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM < 3;


-- PERSONNE 144

INSERT INTO ACHAT

SELECT *
FROM (
    SELECT E.NUMLIEU, E.NUMEXPO, 144, SYSDATE-89, 1, 0, 'ESP'
    FROM EXPO E
    ORDER BY DBMS_RANDOM.VALUE)
WHERE
    ROWNUM < 5;


/*==============================================================*/
/* 5 EXTRACTIONS DE LA BASE                                     */
/*==============================================================*/

-- 5.a.1 -- 1 ligne

SELECT DISTINCT
    nomPers || ' ' || pnomPers "Personne"
FROM
    PERSONNE
WHERE
    numPers IN (SELECT numPers
                FROM ACHAT
                WHERE numLieu IN (
                    SELECT numLieu
                    FROM LIEU
                    WHERE UPPER(villeLieu) NOT LIKE 'PARIS%'
                )
);

SELECT DISTINCT
    nomPers || ' ' || pnomPers "Personne"
FROM
    PERSONNE
WHERE
    EXISTS (SELECT 1
            FROM
                ACHAT
                JOIN LIEU ON ACHAT.numLieu = LIEU.numLieu
            WHERE
                UPPER(villeLieu) NOT LIKE 'PARIS%'
                AND PERSONNE.numPers = ACHAT.numPers
);

-- 5.a.2 -- 13 lignes

SELECT
    E.titreExpo,
    G.libGenre,
    L.nomLieu,
    NVL(A.nbBil, 0) AS nbBil,
    NVL(A.nbBilTR, 0) AS nbBilTR,
    E.tarif,
    E.tarifR AS tarifReduit,
    (NVL(A.nbBil, 0) * E.tarif + NVL(A.nbBilTR, 0) * E.tarifR) AS recette
FROM
    EXPO E
    JOIN GENRE G ON E.numGenre = G.numGenre
    JOIN LIEU L ON E.numLieu = L.numLieu
    LEFT JOIN ACHAT A ON E.numLieu = A.numLieu AND E.numExpo = A.numExpo
WHERE
    E.choix = 1
    AND E.numGenre IN (1, 2)
ORDER BY
    G.libGenre;

-- 5.a.3 -- 52 lignes

SELECT
    L.nomLieu Lieu,
    E.titreExpo Exposition,
    O.titre Oeuvre
FROM
    EXPO E
    JOIN LIEU L ON E.numLieu = L.numLieu
    JOIN GENRE G ON E.numGenre = G.numGenre
    LEFT JOIN PRESENTATION P ON E.numLieu = P.numLieu AND E.numExpo = P.numExpo
    LEFT JOIN OEUVRE O ON P.numEvr = O.numEvr
WHERE
    UPPER(L.nomLieu) LIKE 'MUSÉE%'
    AND UPPER(G.libGenre) = 'BEAUX-ARTS'
ORDER BY
    L.nomLieu, E.titreExpo;

-- 5.a.4 -- 4 lignes

-- left join

SELECT
    O.titre
FROM
    OEUVRE O
    LEFT JOIN PRESENTATION P ON O.numEvr = P.numEvr
WHERE
    P.numEvr IS NULL;

-- not exists

SELECT
    O.titre
FROM
    OEUVRE O
WHERE
    NOT EXISTS (
        SELECT NULL
        FROM
            PRESENTATION P
        WHERE
            O.numEvr = P.numEvr
    );

-- sous requete

SELECT
    O.titre
FROM
    OEUVRE O
WHERE
    O.numEvr NOT IN (
        SELECT numEvr
        FROM PRESENTATION
    );

-- sous requete avec minus

SELECT
    titre
FROM
    OEUVRE
WHERE
    numEvr IN ( SELECT
                    numEvr
                FROM
                    OEUVRE
                MINUS
                SELECT
                    numEvr
                FROM
                    PRESENTATION )
;


-- 5.b figures libres

-- 5.b.5 Nombre d'œuvres présentées pour chaque exposition.
-- 16 lignes

SELECT
    (SELECT titreExpo FROM EXPO WHERE numLieu = P.numLieu AND numExpo = P.numExpo) AS Exposition,
    COUNT(P.numEvr) AS Nombre_Oeuvres
FROM
    PRESENTATION P
GROUP BY
    P.numLieu, P.numExpo;

-- 5.b.6 tarif moyen des expos ayant commencé entre janvier et juin 2024 pour chaque genre
-- 9 lignes

SELECT
    G.libGenre,
    ROUND(AVG(NVL(E.tarif, 0)), 2) AS "Tarif Moyen (Normal)",
    ROUND(AVG(NVL(E.tarifR, 0)), 2) AS "Tarif Moyen (Réduit)"
FROM
    GENRE G
    LEFT JOIN EXPO E ON G.numGenre = E.numGenre
WHERE
    E.dateDeb BETWEEN TO_DATE('01-01-2024', 'DD-MM-YYYY') AND TO_DATE('30-06-2024', 'DD-MM-YYYY')
GROUP BY
    G.libGenre
ORDER BY
    "Tarif Moyen (Normal)" DESC;

-- 5.b.7 artistes qui ont créé plus de 2 œuvres d'un même type
-- 6 lignes

SELECT
    A.nomArt || ' ' || A.pnomArt AS Nom_Artiste,
    T.libTpEvr AS Type_Oeuvre,
    COUNT(O.numEvr) AS Nombre_Oeuvres
FROM
    OEUVRE O
    JOIN ARTISTE A ON O.numArt = A.numArt
    JOIN TYPEOEUVRE T ON O.numTpEvr = T.numTpEvr
GROUP BY
    A.nomArt || ' ' || A.pnomArt, T.libTpEvr
HAVING
    COUNT(O.numEvr) > 2
ORDER BY
    nombre_oeuvres DESC,
    nom_artiste;

-- 5.b.8 nombre d'oeuvres exposées et nombre d'oeuvres total par artiste ayant au moins 1 oeuvre
-- 21 lignes

SELECT DISTINCT
    A.nomArt,
    A.pnomArt,
    (   SELECT COUNT(*)
        FROM OEUVRE O
        WHERE O.numArt = A.numArt) AS "Oeuvres",
    (   SELECT COUNT(*)
        FROM OEUVRE O
        WHERE O.numArt = A.numArt
          AND O.numEvr IN (SELECT P.numEvr FROM PRESENTATION P)) AS "Oeuvres présentées"
FROM
    ARTISTE A
    JOIN OEUVRE O ON A.numArt = O.numArt
WHERE
    O.numEvr IS NOT NULL
ORDER BY
    "Oeuvres" DESC,
    "Oeuvres présentées" DESC;

-- 5.b.9 Personnes et Artistes venant de France et d'Italie
-- 52 lignes

SELECT
    A.nomArt || ' ' || A.pnomArt AS "Nom",
    P.nomFr "Pays"
FROM
    ARTISTE A
    JOIN PAYS P ON (A.CDPAYS = P.CDPAYS)
WHERE
    UPPER(P.nomFr) LIKE '%ITALIE%'
    OR UPPER(P.nomFr) LIKE '%FRANCE%'

UNION

SELECT
    PE.nomPers || ' ' || PE.pnomPers,
    P2.nomFr "Pays"
FROM
    PERSONNE PE
    JOIN PAYS P2 ON (PE.CDPAYS = P2.CDPAYS)
WHERE
     UPPER(P2.nomFr) LIKE '%ITALIE%'
  OR UPPER(P2.nomFr) LIKE '%FRANCE%'

ORDER BY
        "Pays",
        "Nom";

-- 5.b.10 (division) expos pour lesquelles personne n'a acheté de billet
-- 121 lignes

SELECT
    E.numLieu,
    E.numExpo,
    E.titreExpo
FROM
    EXPO E
WHERE
    NOT EXISTS  (   SELECT NULL
                    FROM ACHAT A
                    WHERE A.numLieu = E.numLieu AND A.numExpo = E.numExpo
);


-- 5.c Vues et séquences

CREATE SEQUENCE numPers_seq START WITH 201;

INSERT INTO PERSONNE (NUMPERS, NOMPERS, PNOMPERS, DATENAIS, REGION, VILLE, CDPAYS)
SELECT
    numPers_seq.NEXTVAL,
    nomPers,
    pnomPers,
    dateNais,
    region,
    ville,
    cdPays
FROM TESTSAELD.PERSONNE_IMPORT;

SELECT * FROM PERSONNE WHERE DATENAIS < TO_DATE('01-01-1960', 'DD-MM-YYYY');

DROP VIEW CHINOIS;

CREATE VIEW CHINOIS AS
SELECT
    numPers,
    nomPers,
    pnomPers,
    ville,
    region
FROM
    PERSONNE
WHERE
    CDPAYS = 'CHN';

INSERT INTO CHINOIS
VALUES (numPers_seq.nextval, 'CHAN', 'Jacky', 'Hong Kong', 'Victoria Peak');

SELECT * FROM CHINOIS; -- Jackie CHAN n'apparaît pas dans la vue car il n'a pas le cdPays chinois

SELECT * FROM PERSONNE WHERE VILLE = 'Hong Kong'; -- il a cependant bien été inséré

UPDATE PERSONNE
SET CDPAYS = 'CHN'
WHERE UPPER(VILLE) = 'HONG KONG';

SELECT * FROM CHINOIS; -- Cette fois-ci, Jackie CHAN apparaît bien dans la vue CHINOIS

-- Ajout de la date de naissance de Jackie CHAN
UPDATE PERSONNE
SET DATENAIS = TO_DATE('07-04-1954', 'DD-MM-YYYY')
WHERE UPPER(NOMPERS) = 'CHAN' AND UPPER(PNOMPERS) = 'JACKY';

-- Chinois dont la ville commence par un H
SELECT * FROM CHINOIS WHERE VILLE LIKE 'H%';

-- Chinois ayant acheté des billets pour des expositions (1 personne)
SELECT COUNT(DISTINCT NUMPERS) FROM ACHAT WHERE NUMPERS IN (SELECT NUMPERS FROM CHINOIS);


-- 5.d Droits et privilèges

-- accès en écriture, modification et suppression de la table LIEU
GRANT INSERT, UPDATE, DELETE ON LIEU TO vida0018;

-- accès suppression et en modification de la table ACHAT.
GRANT UPDATE(nbBil, nbBilTR, dateAchat, modeReglt) ON ACHAT TO vida0018;
GRANT DELETE ON ACHAT TO vida0018;


-- accès en insertion et modification de la table EXPO

CREATE VIEW EXPO_PARIS_MARS_2024 AS
SELECT
    numLieu,
    numExpo,
    titreExpo,
    dateDeb
FROM
    EXPO
WHERE
    numLieu IN (SELECT numLieu FROM LIEU WHERE numDpt = 75)
    AND EXTRACT(MONTH FROM dateDeb) = 3 AND EXTRACT(YEAR FROM dateDeb) = 2024;

GRANT SELECT, INSERT, UPDATE ON EXPO_PARIS_MARS_2024 TO vida0018;
GRANT SELECT ON EXPO TO vida0018;

-- En tant que vida0018 :

-- changement de date pour l'expo d'impressionnisme

UPDATE ARID0002.EXPO_PARIS_MARS_2024
SET DATEDEB = TO_DATE('15-05-2024', 'DD-MM-YYYY')
WHERE UPPER(TITREEXPO) LIKE '%IMPRESSIONNISME%';

-- suppression des achats faits après la date de fin de l'expo

DELETE FROM ARID0002.ACHAT A
WHERE A.dateAchat > (
    SELECT E.dateFin
    FROM ARID0002.EXPO E
    WHERE A.numExpo = E.numExpo
);


/*==============================================================*/
/* 6 VISUALISATION DES DONNÉES                                  */
/*==============================================================*/

-- 6.a Préparation et Transformation des données

CREATE VIEW VUE_EXPOSITIONS AS
SELECT 
    e.NUMEXPO,
    e.TITREEXPO,
    e.DATEDEB,
    e.DATEFIN,
    e.RESUME,
    e.TARIF,
    e.TARIFR,
    g.LIBGENRE,
    l.NOMLIEU,
    l.VILLELIEU,
    l.MISSIONS,
    d.NOMDPT,
    CASE 
        WHEN e.DATEFIN IS NULL THEN NULL 
        ELSE e.DATEFIN - e.DATEDEB 
    END AS DUREEEV
FROM 
    EXPO e
JOIN 
    GENRE g ON e.NUMGENRE = g.NUMGENRE
JOIN 
    LIEU l ON e.NUMLIEU = l.NUMLIEU
JOIN 
    DEPARTEMENT d ON l.NUMDPT = d.NUMDPT;
