SET search_path TO parlgov;

/* Assign an alliance_id for each election_result */
CREATE TABLE election_alliance AS
SELECT election_id, party_id, COALESCE(alliance_id, id) AS alliance_id from election_result;

/* Calculate the times of different pair of parties that have been allies with each other */
CREATE TABLE allied_number AS
SELECT country_id, alliedPartyId1, alliedPartyId2, COUNT(*) AS alliedTimes FROM 
(SELECT party_pairs.*, election.country_id
FROM (SELECT A.election_id, A.party_id AS alliedPartyId1, B.party_id AS alliedPartyId2 FROM
election_alliance AS A, election_alliance AS B
WHERE A.alliance_id = B.alliance_id AND A.party_id < B.party_id AND A.election_id = B.election_id) AS party_pairs, election
WHERE party_pairs.election_id = election.id) AS allied_list
GROUP BY country_id, alliedPartyId1, alliedPartyId2;

/* Calculate the number of elections of each country */
CREATE TABLE election_number AS
SELECT country_id, count(*) AS electionTimes FROM
election
GROUP BY country_id;

/* Find qualified pairs of parties */
CREATE TABLE q5 AS
SELECT allied_number.country_id AS countryId, alliedPartyId1, alliedPartyId2
FROM allied_number, election_number
WHERE allied_number.country_id = election_number.country_id and alliedTimes >= 0.3 * electionTimes; 

/* Clean the environment and drop all unnecessary tables */
DROP TABLE election_alliance, allied_number, election_number;