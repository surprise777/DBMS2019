SET search_path TO parlgov;

/* Find the winner of each election */
CREATE TABLE selection_winner AS 
SELECT country_id, election_id, party_id FROM
(SELECT election_result.election_id, party_id FROM
(SELECT election_id, MAX(votes) AS max_votes FROM election_result GROUP BY election_id) AS winner_votes, election_result
WHERE election_result.election_id = winner_votes.election_id and election_result.votes = winner_votes.max_votes) AS winner_party, election
WHERE winner_party.election_id = election.id;

/* Calculate the winning times of each party of each country;
   If any party doesn't win any election, the win_times should be set to 0 */
CREATE TABLE country_party_wintimes AS
SELECT all_party.country_id, all_party.name, all_party.id AS party_id, COALESCE(win_times, 0) AS win_times FROM
(SELECT DISTINCT country_id, id, name FROM party) AS all_party LEFT JOIN
(SELECT country_id, party_id, count(election_id) AS win_times
FROM selection_winner GROUP BY country_id, party_id) AS win_party
ON all_party.id = win_party.party_id and all_party.country_id = win_party.country_id;

/* Find the target country and party */ 
CREATE TABLE target_country_party AS
SELECT country_id, party_id, name, win_times FROM 
(SELECT country_party_wintimes.country_id, country_party_wintimes.party_id, country_party_wintimes.name, win_times, avg_times
FROM country_party_wintimes,
(SELECT country_id, AVG(win_times) AS avg_times
FROM country_party_wintimes
GROUP BY country_id) AS avg_winners
WHERE country_party_wintimes.country_id = avg_winners.country_id) AS temp_table
WHERE win_times >= 3 * avg_times;

/* Add countryName and partyFamily infomation */
CREATE TABLE temp_result_table AS
SELECT foo1.countryName, party_family.family AS partyFamily, foo1.country_id, foo1.party_id, foo1.partyName, win_times AS wonElections FROM
(SELECT country.name AS  countryName, target_country_party.country_id, target_country_party.party_id, target_country_party.name AS partyName, win_times
FROM target_country_party, country
WHERE target_country_party.country_id = country.id) AS foo1 LEFT JOIN party_family
ON foo1.party_id = party_family.party_id;

/* Find the id and year of most recent wonElection */
CREATE TABLE q1 AS
SELECT temp_result_table.countryName, temp_result_table.partyName, temp_result_table.partyFamily,
temp_result_table.wonElections, recentElection.id AS mostRecentlyWonElectionId, CAST(DATE_PART('year', recentElection.e_date) AS INT)  mostRecentlyWonElectionYear
FROM (SELECT foo1.party_id, foo1.country_id, recentDate, election.id, election.e_date FROM
(SELECT selection_winner.party_id, selection_winner.country_id, MAX(election.e_date) AS recentDate
FROM selection_winner, election
WHERE selection_winner.election_id = election.id
GROUP BY selection_winner.party_id, selection_winner.country_id) AS foo1, election
WHERE election.e_date = foo1.recentDate and foo1.country_id = election.country_id) AS recentElection, temp_result_table
WHERE recentElection.party_id = temp_result_table.party_id and recentElection.country_id = temp_result_table.country_id;

/* Clean the environment and drop all unnecessary tables */
DROP TABLE selection_winner, country_party_wintimes, target_country_party, temp_result_table;
