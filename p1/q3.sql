SET search_path TO parlgov;

/* Find the end date of each cabinet of each country */
CREATE TABLE cabinet_sequence AS
SELECT country_id, id, start_date, end_date FROM
(SELECT START_PART.country_id, START_PART.id, START_PART.start_date, END_PART.start_date AS end_date FROM 
(SELECT country_id, id, start_date, previous_cabinet_id FROM cabinet) AS END_PART FULL OUTER JOIN
(SELECT country_id, id, start_date FROM cabinet) AS START_PART
ON END_PART.previous_cabinet_id = START_PART.id and START_PART.country_id = END_PART.country_id) AS foo
WHERE foo.id IS NOT NULL;

/* Find all the cabinets whose end date is less than 20 years from now */
CREATE TABLE all_cabinets AS
SELECT DISTINCT country_id, id AS cabinet_id
FROM cabinet_sequence WHERE end_date IS NULL OR NOW() - end_date < '20 years';

/* Find all the parties which are possible to be a committed party */
CREATE TABLE all_parties AS
SELECT party.country_id, all_party_id.party_id
FROM (SELECT DISTINCT party_id
FROM all_cabinets, cabinet_party
WHERE all_cabinets.cabinet_id = cabinet_party.cabinet_id) AS all_party_id, party
WHERE all_party_id.party_id = party.id;

/* Find the parties which couldn't be commited parties */
CREATE TABLE invalid_parties AS
SELECT DISTINCT party_id FROM
((SELECT all_cabinets.cabinet_id, all_parties.party_id
FROM all_cabinets, all_parties
WHERE all_cabinets.country_id = all_parties.country_id)
EXCEPT 
(SELECT cabinet_id, party_id FROM cabinet_party)) AS foo;

/* Get the commited parties */
CREATE TABLE commited_party AS
SELECT country.name as countryName, commited_parties.country_id, commited_parties.party_id, commited_parties.partyName FROM
(SELECT valid_party.party_id, party.country_id, party.name AS partyName FROM
(SELECT party_id FROM
((SELECT party_id FROM all_parties)
EXCEPT
(SELECT * FROM invalid_parties)) AS foo1) AS valid_party, party
WHERE valid_party.party_id = party.id) AS commited_parties, country
WHERE commited_parties.country_id = country.id;

/* Add the party family and stateMarket info */
CREATE TABLE q3 AS
SELECT foo.countryName, foo.partyName, party_family.family as partyFamily, foo.state_market as stateMarket 
FROM (SELECT commited_party.*, part_party_position.state_market 
FROM commited_party LEFT JOIN (SELECT party_id, state_market FROM party_position) AS part_party_position 
ON commited_party.party_id = part_party_position.party_id) AS foo LEFT JOIN party_family
ON foo.party_id = party_family.party_id;

/* Clean the environment and drop all unnecessary tables */
DROP TABLE all_cabinets, all_parties, invalid_parties, commited_party;