SET search_path TO parlgov;

SELECT * FROM q5
ORDER BY countryID DESC, alliedPartyId1 DESC, alliedPartyId2 DESC;