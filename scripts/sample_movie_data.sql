--Strainge darling 
UPDATE movies
SET primary_genre = 27,
 open_startDate ='2024-08-23',
 open_endDate ='2024-08-25',
 open_wknd_theaters = 1135,
 open_wknd_BO = 1142928,
 domestic_BO = 3081296,
 intl_BO = 440250,
 RT_audience = .85,
 RT_critic = .95
WHERE tmdb_id = 1029281;

UPDATE movies
SET total_BO = domestic_BO + intl_BO
WHERE tmdb_id = 1029281; 

--The Substance
UPDATE movies
SET primary_genre = 27,
 open_startDate ='2024-09-20',
 open_endDate ='2024-09-22',
 open_wknd_theaters =1949,
 open_wknd_BO =3205212,
 domestic_BO =7116244,
 intl_BO = 5203897,
 RT_audience = .71,
 RT_critic = .91
WHERE tmdb_id = 933260;

UPDATE movies
SET total_BO = domestic_BO + intl_BO
WHERE tmdb_id = 933260; 

--My Old Ass
UPDATE movies
SET primary_genre = 35,
 open_startDate = '2024-09-13',
 open_endDate = '2024-09-15',
 open_wknd_theaters = 7,
 open_wknd_BO =167853,
 domestic_BO =3269361,
 intl_BO = 89384,
 RT_audience = .91,
 RT_critic = .92
WHERE tmdb_id = 947891;

UPDATE movies
SET total_BO = domestic_BO + intl_BO
WHERE tmdb_id = 947891;

--Blink Twice
UPDATE movies
SET primary_genre = 53,
 open_wknd_theaters = 3067,
 open_startDate ='2024-08-23',
 open_endDate ='2024-08-25',
 open_wknd_BO =7301894,
 domestic_BO =23070922,
 intl_BO = 23300000,
 RT_audience = .7,
 RT_critic = .74
WHERE tmdb_id = 840705;

UPDATE movies
SET total_BO = domestic_BO + intl_BO
WHERE tmdb_id = 840705;