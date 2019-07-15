SET search_path TO parlgov;

SELECT * FROM q1
ORDER BY countryName ASC, wonElections ASC, partyName DESC;