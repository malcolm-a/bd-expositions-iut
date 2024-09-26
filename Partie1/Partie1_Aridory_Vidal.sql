/* SAÉMS204
 * PARTIE 1
 * ARIDORY MALCOLM, VIDAL MARTIN
 * LOGIN : ARID0002
 */
 
-- 1 Génération du jeu de donnÃ©es

-- 1.b

ALTER TABLE PERSONNE
    ADD CONSTRAINT pk_pers_numpers PRIMARY KEY (numPers);
    
-- 1.c

ALTER TABLE PAYS
    ADD CONSTRAINT pk_pays_cdpays PRIMARY KEY (cdPays);
    
-- 1.d

SELECT DISTINCT
    pe.pays
FROM
    PERSONNE pe
WHERE
    pe.pays NOT IN (SELECT nomAng FROM PAYS);
    
    
SAVEPOINT countrynames1;
    
-- Requête permettant d'enlever les espaces superflus à la fin des noms français
-- de certains pays grâce aux fonctions SUBSTR et LENGTH

UPDATE PAYS
SET nomFr = SUBSTR(nomFr, 1, LENGTH(nomFr) - 1)
WHERE SUBSTR(nomFr, LENGTH(nomFr), 1) = ' ';

-- Requête permettant d'enlever les espaces superflus à la fin des noms anglais
-- de certains pays grâce aux fonctions SUBSTR et LENGTH

UPDATE PAYS
SET nomAng = SUBSTR(nomAng, 1, LENGTH(nomAng) - 1)
WHERE SUBSTR(nomAng, LENGTH(nomAng), 1) = ' ';


-- Requêtes permettant de rectifier le nom du pays en utilisant
-- le nom anglais de la table PAYS

-- 1) United States of America

UPDATE PERSONNE    
SET
    PAYS = 'United States of America'
WHERE
    PAYS = 'United States';
    
-- 2) the Republic of Korea    
    
UPDATE PERSONNE    
SET
    PAYS = 'Korea (the Republic of)'
WHERE
    PAYS = 'South Korea';   
    
-- 3) Vietnam

UPDATE PERSONNE
SET 
    PAYS = 'Viet Nam'
WHERE 
    PAYS = 'Vietnam';
   
-- 4) UK 

UPDATE PERSONNE    
SET
    PAYS = 'United Kingdom of Great Britain and Northern Ireland'
WHERE
    PAYS = 'United Kingdom';


-- On n'a plus de pays dans personne qui ne sont pas dans pays
    
SELECT DISTINCT
    pe.pays
FROM
    PERSONNE pe
WHERE
    pe.pays NOT IN (SELECT nomAng FROM PAYS);
    
COMMIT;

-- Remplacement de la colonne PAYS par la colonne cdPays

ALTER TABLE personne ADD cdPays CHAR(3);

UPDATE personne p
SET p.cdPays = (SELECT pays.cdPays FROM pays WHERE pays.nomAng = p.pays);

ALTER TABLE personne 
    DROP COLUMN pays;
        
ALTER TABLE personne 
    ADD CONSTRAINT fk_cdpays FOREIGN KEY (cdPays) REFERENCES pays (cdPays);
      
        
-- DELETE FROM pays WHERE nomAng = 'France';
-- Violation de contrainte d'intérité : l'opération a été empêchée
-- pour éviter d'avoir des enregistrements orphelins dans la table PERSONNE


-- e) Requêtes sur les tables PERSONNE et PAYS
    
-- R1

SELECT
    COUNT(DISTINCT cdPays) "NOMBRE DE PAYS"
FROM
    PERSONNE;
    
-- R2

SELECT 
    c.nomFr "PAYS", 
    p.region "RÉGION", 
    COUNT(*) "NB PERSONNES"
FROM 
    PERSONNE p
    JOIN PAYS c ON (c.cdPays = p.cdPays)    
WHERE 
    p.cdPays IN ('FRA', 'BEL')
GROUP BY 
    c.nomFr, p.region
ORDER BY 
    c.nomFr, p.region;


-- R3

SELECT 
    c.nomFr AS "PAYS",
    COUNT(*) AS "NB PERSONNES"
FROM
    PERSONNE p
    JOIN PAYS c ON (c.cdPays = p.cdPays) 
GROUP BY
    c.nomFr
HAVING
    COUNT(*) >= 8
ORDER BY
    c.nomFr;
    
-- R4    

SELECT 
    nomPers "NOM", 
    pnomPers "PRÉNOM"
FROM 
    PERSONNE
WHERE 
    dateNais = (SELECT MIN(dateNais) FROM PERSONNE);
    
-- R5

SELECT 
    c.nomFr
FROM 
    PAYS c
WHERE 
    c.cdPays = (SELECT p.cdPays
                FROM personne p
                GROUP BY p.cdPays
                HAVING COUNT(*) = (
                    SELECT MAX(nb_personnes)
                    FROM (
                        SELECT COUNT(*) as nb_personnes
                        FROM personne
                        GROUP BY cdPays
                        )
                    )
                );
                
                
-- R6

SELECT 
    c.nomFr "PAYS", 
    p.nomPers "NOM", 
    p.pnomPers "PRÉNOM", 
    FLOOR(MONTHS_BETWEEN(SYSDATE, p.dateNais)/12) "ÂGE"
FROM 
    PERSONNE p
    JOIN PAYS c ON p.cdPays = c.cdPays
WHERE 
    (p.cdPays, p.dateNais) IN (
        SELECT cdPays, MIN(dateNais)
        FROM PERSONNE
        GROUP BY cdPays
        )
ORDER BY "ÂGE" DESC;

-- R7

SELECT 
    c.nomFr "PAYS", 
    COUNT(p.cdPays) "NB PERSONNES"
FROM 
    PAYS c
    LEFT JOIN PERSONNE p ON c.cdPays = p.cdPays
WHERE 
    UPPER(c.continent) = 'OCÉANIE'
    AND UPPER(c.nomFr) LIKE '%A%'
    AND UPPER(c.nomFr) LIKE '%E'
GROUP BY 
    c.nomFr
ORDER BY 
    "NB PERSONNES" DESC;
