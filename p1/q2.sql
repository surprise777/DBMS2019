SET search_path TO parlgov;

/* Select election data of valid year */
CREATE TABLE valid_year AS
SELECT country_id, year, AVG(participationRatio) AS avgParticipationRatio FROM
(SELECT *, votes_cast * 1.0 / electorate AS participationRatio, DATE_PART('year', e_date) as year FROM election
WHERE DATE_PART('year', e_date) >= 2001 AND DATE_PART('year', e_date) <= 2016) AS foo
GROUP BY country_id, year;

/* Find the country whose participation ratio is not non-dearscing */
CREATE TABLE not_valid_country AS
SELECT DISTINCT yearSort.country_id FROM
(SELECT country_id, year, avgParticipationRatio, ROW_NUMBER() OVER(ORDER BY country_id ASC, year ASC, avgParticipationRatio ASC)
 as index FROM valid_year WHERE avgParticipationRatio IS NOT NULL) AS yearSort,
(SELECT country_id, year, avgParticipationRatio, ROW_NUMBER() OVER(ORDER BY country_id ASC, avgParticipationRatio ASC, year ASC)
 as index FROM valid_year WHERE avgParticipationRatio IS NOT NULL) AS participationSort
WHERE yearSort.index = participationSort.index and yearSort.year <> participationSort.year;

/* Get all the non-decreasing country */
CREATE TABLE q2 AS
SELECT country.name as countryName, CAST(foo.year AS INT), CAST(CAST(foo.avgParticipationRatio AS DECIMAL(38, 6)) AS FLOAT) AS participationRatio FROM
(SELECT valid_country.country_id, year, avgParticipationRatio FROM
(SELECT DISTINCT country_id FROM valid_year
EXCEPT SELECT * FROM not_valid_country) AS valid_country, valid_year
WHERE valid_country.country_id = valid_year.country_id) AS foo, country
WHERE foo.country_id = country.id;

/* Clean the environment and drop all unnecessary tables */
DROP TABLE valid_year, not_valid_country;