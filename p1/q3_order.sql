SET search_path TO parlgov;

SELECT * FROM q3
ORDER BY countryName ASC, partyName ASC, stateMarket DESC;