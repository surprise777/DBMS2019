SET search_path TO parlgov;

/* Get cabinet_sequence */
CREATE TABLE cabinet_sequence AS
SELECT country_id, id, start_date, end_date FROM
(SELECT START_PART.country_id, START_PART.id, START_PART.start_date, END_PART.start_date AS end_date FROM 
(SELECT country_id, id, start_date, previous_cabinet_id FROM cabinet) AS END_PART FULL OUTER JOIN
(SELECT country_id, id, start_date FROM cabinet) AS START_PART
ON END_PART.previous_cabinet_id = START_PART.id and START_PART.country_id = END_PART.country_id) AS foo
WHERE foo.id IS NOT NULL;

/* Find the pm party of each cabinet */
CREATE TABLE pm_party AS
SELECT cabinet_sequence.country_id, cabinet_sequence.id AS cabinet_id, start_date, end_date, party_id FROM
cabinet_sequence LEFT JOIN
(SELECT cabinet_id, party_id FROM cabinet_party
WHERE pm = 't') AS pm_party
ON cabinet_sequence.id = pm_party.cabinet_id;

/* Add country name and party name infomation */
CREATE TABLE q4 AS
SELECT country_info.name AS countryName, country_info.cabinet_id AS cabinetId, country_info.start_date AS startDate,
country_info.end_date AS endDate, party.name AS pmParty FROM
(SELECT pm_party.*, country.name
FROM pm_party, country
WHERE pm_party.country_id = country.id) AS country_info LEFT JOIN party
ON country_info.party_id = party.id;

/* Clean the environment and drop all unnecessary tables */
DROP TABLE cabinet_sequence, pm_party;
